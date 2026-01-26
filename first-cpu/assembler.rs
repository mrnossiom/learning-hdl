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
            writeln!(file, "{:08b}", instr.emit(&self.labels)?)?;
        }

        Ok(())
    }
}

/// Register number limited to 2^4 register
#[derive(Debug, Clone, Copy)]
struct Rn(u8);

impl Rn {
    fn new(n: u8) -> Option<Self> {
        (n >> 4 == 0).then_some(Self(n))
    }

    fn num(&self) -> u8 {
        self.0
    }
}

impl std::str::FromStr for Rn {
    type Err = MudError;
    fn from_str(s: &str) -> Result<Self, Self::Err> {
        let Some(num) = s.strip_prefix('r') else {
            return Err("register should start with an `r`".into());
        };
        let Some(rn) = Self::new(num.parse()?) else {
            return Err("register number is out of range".into());
        };
        Ok(rn)
    }
}

#[derive(Debug, Clone, Copy)]
struct Imm<const N: usize>(u32);

type Imm4 = Imm<4>;

impl<const N: usize> Imm<N> {
    fn new(imm: u32) -> Option<Self> {
        (imm >> N == 0).then_some(Self(imm))
    }

    fn value(&self) -> u32 {
        self.0
    }
}

impl<const N: usize> std::str::FromStr for Imm<N> {
    type Err = MudError;
    fn from_str(s: &str) -> Result<Self, Self::Err> {
        let bytes = s.as_bytes();

        let raw_value = if let Some(b'0') = bytes.get(0) {
            let radix = match bytes.get(1) {
                Some(b'x') => 16,
                Some(b'o') => 8,
                Some(b'b') => 2,
                Some(_) => return Err("immediate radix specifier is invalid".into()),
                None => return Err("immediate radix specifier must be followed by a value".into()),
            };
            u32::from_str_radix(&s[2..], radix)?
        } else {
            u32::from_str_radix(&s, 10)?
        };

        let Some(imm) = Self::new(raw_value) else {
            return Err(format!("value doesn't fit immediate of size `{}`", N).into());
        };
        Ok(imm)
    }
}

#[derive(Debug, Clone)]
enum Instruction {
    // Reg
    Add(Rn),
    Sub(Rn),
    Mul(Rn),
    And(Rn),
    Or(Rn),
    Xor(Rn),

    CopyToAcc(Rn),
    CopyFromAcc(Rn),

    Cmp(Rn),

    // Imm
    Branch(String),
    Beq(String),

    LoadLowerImmediate(Imm4),
    LoadUpperImmediate(Imm4),

    // Custom
    Nop,
    Inc,
    Dec,
    Halt,
}

impl Instruction {
    fn parse(instr: &str) -> MudResult<Self> {
        let (mnemonic, operands) = if let Some((mnemonic, operands)) = instr.split_once(' ') {
            (mnemonic, operands.trim().split(',').collect::<Vec<_>>())
        } else {
            (instr, Vec::new())
        };

        let instr = match (mnemonic, operands.as_slice()) {
            // Reg
            ("add", [rn]) => Instruction::Add(rn.parse()?),
            ("sub", [rn]) => Instruction::Sub(rn.parse()?),
            ("mul", [rn]) => Instruction::Mul(rn.parse()?),
            ("and", [rn]) => Instruction::And(rn.parse()?),
            ("or", [rn]) => Instruction::Or(rn.parse()?),
            ("xor", [rn]) => Instruction::Xor(rn.parse()?),

            ("cp", [rn, "acc"]) => Instruction::CopyToAcc(rn.parse()?),
            ("cp", ["acc", rn]) => Instruction::CopyFromAcc(rn.parse()?),

            ("cmp", [rn]) => Instruction::Cmp(rn.parse()?),

            // Imm
            ("b", [label]) => Instruction::Branch(label.to_string()),
            ("beq", [label]) => Instruction::Beq(label.to_string()),

            ("lli", [imm4]) => Instruction::LoadLowerImmediate(imm4.parse()?),
            ("lui", [imm4]) => Instruction::LoadUpperImmediate(imm4.parse()?),

            // Custom
            ("nop", []) => Instruction::Nop,
            ("inc", []) => Instruction::Inc,
            ("dec", []) => Instruction::Dec,
            ("halt", []) => Instruction::Halt,

            _ => return Err(format!("incorrect format for `{mnemonic}`").into()),
        };

        Ok(instr)
    }

    fn emit(&self, labels: &BTreeMap<String, usize>) -> MudResult<u8> {
        fn instr_opcode_rn(opcode: u8, rn: &Rn) -> u8 {
            assert!(opcode >> 4 == 0, "opcode should be 4 bits or less");
            (opcode << 4) | rn.num()
        }
        fn instr_opcode_imm4(opcode: u8, imm4: &Imm4) -> u8 {
            assert!(opcode >> 4 == 0, "opcode should be 4 bits or less");
            (opcode << 4) | imm4.value() as u8
        }

        let encoded = match self {
            // Reg
            Instruction::Add(rn) => instr_opcode_rn(0x0, rn),
            Instruction::Sub(rn) => instr_opcode_rn(0x1, rn),
            Instruction::Mul(rn) => instr_opcode_rn(0x2, rn),
            Instruction::And(rn) => instr_opcode_rn(0x3, rn),
            Instruction::Or(rn) => instr_opcode_rn(0x4, rn),
            Instruction::Xor(rn) => instr_opcode_rn(0x5, rn),

            Instruction::CopyToAcc(rn) => instr_opcode_rn(0x8, rn),
            Instruction::CopyFromAcc(rn) => instr_opcode_rn(0x9, rn),

            Instruction::Cmp(rn) => instr_opcode_rn(0xA, rn),

            // Imm
            Instruction::Beq(label) => {
                let Some(address) = labels.get(label).copied() else {
                    return Err("could not find label".into());
                };
                let Some(address) = Imm4::new(address as u32) else {
                    return Err("address range is too far".into());
                };
                instr_opcode_imm4(0xB, &address)
            }
            Instruction::Branch(label) => {
                let Some(address) = labels.get(label).copied() else {
                    return Err("could not find label".into());
                };
                let Some(address) = Imm4::new(address as u32) else {
                    return Err("address range is too far".into());
                };
                instr_opcode_imm4(0xC, &address)
            }

            Instruction::LoadLowerImmediate(imm4) => instr_opcode_imm4(0xD, imm4),
            Instruction::LoadUpperImmediate(imm4) => instr_opcode_imm4(0xE, imm4),

            Instruction::Nop => 0xF0,
            Instruction::Inc => 0xF1,
            Instruction::Dec => 0xF2,
            Instruction::Halt => 0xFF,
        };

        Ok(encoded)
    }
}
