#!/usr/bin/env -S cargo +nightly -Zscript
---
[dependencies]
clap = { version = "4", features = ["derive"] }
---

use std::collections::BTreeMap;
use std::io::Write;
use std::path::{Path, PathBuf};

use clap::Parser;

type MudError = Box<dyn std::error::Error>;
type MudResult<T> = Result<T, MudError>;

#[derive(Parser)]
struct Args {
    assembly: PathBuf,

    #[clap(long)]
    output: PathBuf,
}

fn main() -> MudResult<()> {
    let args = Args::parse();

    let content = std::fs::read_to_string(&args.assembly)?;
    let assembly = Assembly::parse(&content)?;

    assembly.emit(&args.output)?;

    Ok(())
}

struct Assembly {
    instrs: Vec<Instruction>,
    labels: BTreeMap<String, usize>,
}

impl Assembly {
    fn parse(content: &str) -> MudResult<Self> {
        let mut instrs = Vec::new();
        let mut labels = BTreeMap::new();

        let mut address: usize = 0;

        for line in content.lines() {
            let line = line.trim();
            if line.starts_with(";") || line.is_empty() {
                continue;
            }

            if let Some(label) = line.strip_prefix('.') {
                println!("label `{label}` points to address {address:X}");
                labels.insert(label.to_string(), address);
            } else {
                let instr = Instruction::parse(line)?;
                println!("instr `{instr:?}`");
                instrs.push(instr);

                address += 1;
            }
        }

        Ok(Self { instrs, labels })
    }

    fn emit(&self, path: &Path) -> MudResult<()> {
        let mut file = std::fs::OpenOptions::new()
            .create(true)
            .write(true)
            .open(path)?;

        for instr in &self.instrs {
            writeln!(file, "{:08b}", instr.emit(&self.labels))?;
        }

        Ok(())
    }
}

/// Register number
#[derive(Debug, Clone, Copy)]
struct Rn(u8);

impl Rn {
    fn new(n: u8) -> Self {
        assert!(n < 0xF0, "register number is only 4 bits");
        Self(n)
    }

    fn num(&self) -> u8 {
        self.0
    }
}

impl std::str::FromStr for Rn {
    type Err = MudError;
    fn from_str(s: &str) -> Result<Self, Self::Err> {
        Ok(Self::new(s.parse()?))
    }
}

#[derive(Debug, Clone, Copy)]
struct Imm4(u8);

impl Imm4 {
    fn new(imm: u8) -> Self {
        assert!(imm < 0x10, "immediate is only 4 bits");
        Self(imm)
    }

    fn imm(&self) -> u8 {
        self.0
    }
}

#[derive(Debug, Clone)]
enum Instruction {
    Nop,
    Halt,

    Add(Rn),
    Sub(Rn),
    Mul(Rn),
    And(Rn),
    Or(Rn),
    Xor(Rn),

    CopyToAcc(Rn),
    CopyFromAcc(Rn),

    Inc,
    Dec,

    Cmp(Rn),
    Beq(String),
    Branch(String),
}

impl Instruction {
    fn parse(instr: &str) -> MudResult<Self> {
        let (mnemonic, operands) = if let Some((mnemonic, operands)) = instr.split_once(' ') {
            (mnemonic, operands.split(',').collect::<Vec<_>>())
        } else {
            (instr, Vec::new())
        };

        let instr = match (mnemonic, operands.as_slice()) {
            ("nop", []) => Instruction::Nop,
            ("halt", []) => Instruction::Halt,

            ("add", [rn]) => Instruction::Add(rn.parse()?),
            ("sub", [rn]) => Instruction::Sub(rn.parse()?),
            ("mul", [rn]) => Instruction::Mul(rn.parse()?),
            ("and", [rn]) => Instruction::And(rn.parse()?),
            ("or", [rn]) => Instruction::Or(rn.parse()?),
            ("xor", [rn]) => Instruction::Xor(rn.parse()?),

            ("cp", [rn, "acc"]) => Instruction::CopyToAcc(rn.parse()?),
            ("cp", ["acc", rn]) => Instruction::CopyFromAcc(rn.parse()?),

            ("inc", []) => Instruction::Inc,
            ("dec", []) => Instruction::Dec,

            ("cmp", [rn]) => Instruction::Cmp(rn.parse()?),
            ("beq", [label]) => Instruction::Beq(label.to_string()),
            ("b", [label]) => Instruction::Branch(label.to_string()),
            _ => return Err(format!("incorrect format for `{mnemonic}`").into()),
        };

        Ok(instr)
    }

    fn emit(&self, labels: &BTreeMap<String, usize>) -> u8 {
        fn instr_op_rn(op: u8, rn: &Rn) -> u8 {
            assert!(op < 0x10, "op should be 4 bits or less");
            (op << 4) | rn.num()
        }

        match self {
            Instruction::Nop => 0x00,

            Instruction::Add(rn) => instr_op_rn(0x1, rn),
            Instruction::Sub(rn) => instr_op_rn(0x2, rn),
            Instruction::Mul(rn) => instr_op_rn(0x3, rn),
            Instruction::And(rn) => instr_op_rn(0x4, rn),
            Instruction::Or(rn) => instr_op_rn(0x5, rn),
            Instruction::Xor(rn) => instr_op_rn(0x6, rn),

            Instruction::CopyToAcc(rn) => instr_op_rn(0x9, rn),
            Instruction::CopyFromAcc(rn) => instr_op_rn(0xA, rn),

            Instruction::Inc => 0x06,
            Instruction::Dec => 0x07,

            Instruction::Cmp(rn) => instr_op_rn(0x7, rn),
            Instruction::Beq(label) => {
                let address = *labels.get(label).expect("could not find label");
                if address >= 0x10 {
                    todo!("address range is too far")
                }

                0x80 | address as u8
            }
            Instruction::Branch(label) => {
                let address = *labels.get(label).expect("could not find label");
                if address >= 0x10 {
                    todo!("address range is too far")
                }

                0x90 | address as u8
            }

            Instruction::Halt => 0xFF,
        }
    }
}
