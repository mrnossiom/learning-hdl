#!/usr/bin/env -S cargo +nightly -Zscript
---
package.edition = "2024"
---

use std::io;
use std::io::{BufRead, Write};

type MudError = Box<dyn std::error::Error>;
type MudResult<T> = Result<T, MudError>;

fn main() -> MudResult<()> {
    let mut stdin = io::stdin().lock();

    let mut line = String::new();
    let mut instr = String::new();

    loop {
        line.clear();
        instr.clear();

        let num_bytes = stdin.read_line(&mut line)?;
        if num_bytes == 0 {
            break;
        }

        let line = line.trim();

        if let Ok(raw_instr) = u16::from_str_radix(line, 16) {
            decode_instr(&mut instr, raw_instr);
        } else {
            instr.push_str("error(");
            instr.push_str(line);
            instr.push_str(")");
        };

        println!("{instr}");
        io::stdout().flush()?;
    }

    Ok(())
}

fn decode_instr(instr: &mut String, raw: u16) {
    let extra = raw & 0xF;

    match (raw >> 4) & 0xF {
        reg @ 0b0000..=0b1010 => {
            let mut post = "";
            instr.push_str(match reg {
                0b0000 => "add ",
                0b0001 => "sub ",
                0b0010 => "mul ",
                0b0011 => "and ",
                0b0100 => "or ",
                0b0101 => "xor ",

                0b1000 => "cp acc,",
                0b1001 => {
                    post = ",acc";
                    "cp "
                }

                0b1010 => "cmp ",

                _ => "<illegal> ",
            });
            instr.push('r');
            instr.push_str(&format!("{}", extra));
            instr.push_str(post);
        }

        imm @ 0b1011..=0b1110 => {
            instr.push_str(match imm {
                0b1011 => "b ",
                0b1100 => "beq ",
                0b1101 => "lli ",
                0b1110 => "lui ",

                _ => "<illegal> ",
            });
            instr.push_str(&format!("{}", extra));
        }

        0b1111 => instr.push_str(match extra {
            0b1000 => "ls",
            0b1001 => "rs",
            0b1010 => "cls",
            0b1011 => "crs",
            0b1100 => "asr",

            0b1101 => "inc",
            0b1110 => "dec",

            0b0000 => "nop",
            0b0111 => "halt",

            _ => "<illegal>",
        }),

        _ => instr.push_str("<illegal>"),
    }
}
