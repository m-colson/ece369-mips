# ECE369 MIPS
This repository contains Verilog source code for an implementation of a pipelined,
MIPS32 processor. It can execute a subset of the ISA, including the most common,
basic instructions.

## Building Processor
The processor modules has been compiled and tested using
[Vivado](https://www.amd.com/en/products/software/adaptive-socs-and-fpgas/vivado.html).

`git clone` or download this source.

Create new Verilog Project in Vivado.

Add all the obtained `*.v`, `*.xdc`, and `*.mem` files as sources.

Generate FPGA bit stream.

## Building Controller LUT
The processor's controller uses an auto-generated look up table to translate
MIPS instructions to control signals.

Install the [Odin Compiler](https://odin-lang.org/docs/install/)

Download, build, and run the generator using,
```sh
git clone https://github.com/m-colson/ece369-mips
cd ece369-mips
odin run .
```

Replace the entire `assign` section of the `Lab5.srcs/sources_1/new/Controller.v` file
with the contents of the newly generated file `controls.mem.v`.