package main

import "core:bufio"
import "core:fmt"
import "core:os"
import "core:strconv"
import "core:strings"

// main :: proc() {
// 	// fix_file("instruction_memory.mem", "instruction_memory.mem.v")
// 	// fix_file("data_memory.mem", "data_memory.mem.v")
// 	gen_controller("controls.mem")
// }

fix_file :: proc(path: string, out_path: string) {
	file, ok := os.read_entire_file(path)
	if !ok {
		panic("failed to read file")
	}

	out, err := os.open(out_path, os.O_CREATE | os.O_TRUNC, 0o666)
	if err != nil {
		panic(fmt.tprint(err))
	}
	defer os.close(out)

	lines := strings.split_lines(string(file))

	i := 0
	for line in lines {
		if line == "" {
			continue
		}

		num, _ := strconv.parse_u64_of_base(line, 16)

		fmt.fprintfln(out, "memory[%d] <= 32'h%8x;", i, num)
		i += 1
	}
}

gen_controller_mem :: proc(out_path: string, code_like := false) {
	out, err := os.open(out_path, os.O_CREATE | os.O_TRUNC, 0o666)
	if err != nil {
		panic(fmt.tprint(err))
	}
	defer os.close(out)

	for c, i in instruction_controls() {
		if code_like {
			fmt.fprintfln(out, "assign insts[12'o%4o] = 20'h%5x;", i, transmute(u32)c)
		} else {
			fmt.fprintfln(out, "%5x", transmute(u32)c)
		}
	}
}

gen_controller_verilog :: proc(out_path: string) {
	out_file, err := os.open(out_path, os.O_CREATE | os.O_TRUNC, 0o666)
	if err != nil {
		panic(fmt.tprint(err))
	}
	defer os.close(out_file)

	buf_w := bufio.Writer{}
	bufio.writer_init(&buf_w, os.stream_from_handle(out_file))
	defer bufio.writer_destroy(&buf_w)
	defer bufio.writer_flush(&buf_w)

	w := bufio.writer_to_writer(&buf_w)

	ctrls := instruction_controls()
	// for c, i in ctrls {
	// 	fmt.fprintfln(out, "assign insts[12'o%4o] = 20'h%5x;", i, transmute(u32)c)
	// }

	out_names := [20]string {
		"",
		"MemRead",
		"MemWrite",
		"AluSrc",
		"MemToReg",
		"",
		"",
		"RegDest[0]",
		"RegDest[1]",
		"BranchType[0]",
		"BranchType[1]",
		"BranchType[2]",
		"JumpType[0]",
		"JumpType[1]",
		"MemWidth[0]",
		"MemWidth[1]",
		"AluFunc[0]",
		"AluFunc[1]",
		"AluFunc[2]",
		"AluFunc[3]",
	}

	in_names := [12]string {
		"LowerFunct[0]",
		"LowerFunct[1]",
		"LowerFunct[2]",
		"LowerFunct[3]",
		"LowerFunct[4]",
		"LowerFunct[5]",
		"Instruction[26]",
		"Instruction[27]",
		"Instruction[28]",
		"Instruction[29]",
		"Instruction[30]",
		"Instruction[31]",
	}

	optimized := optimize_controls(ctrls[:])
	for cor, i in optimized {
		fmt.printfln("generating bit %d", i)
		if out_names[i] == "" {
			continue
		}

		fmt.wprintf(w, "    assign %s = ", out_names[i])
		for cand, i in cor {
			if i != 0 {
				fmt.wprint(w, "\n        || ")
			}

			fmt.wprint(w, "(")

			for citem, i in cand {
				if .Used in citem {
					if i != 0 {
						fmt.wprint(w, " && ")
					}

					if .True not_in citem {
						fmt.wprint(w, "!")
					}
					fmt.wprint(w, in_names[i])
				}
			}

			fmt.wprint(w, ")")
		}
		fmt.wprint(w, ";\n")
	}


}

instruction_controls :: proc() -> (insts: []Controls) {
	R_Alu_Inst :: Control_Flags{.Mem_To_Reg}
	I_Alu_Inst :: Control_Flags{.Alu_Src, .Mem_To_Reg}

	Load_Inst :: Control_Flags{.Alu_Src, .Mem_Read}
	Store_Inst :: Control_Flags{.Alu_Src, .Mem_Write}

	insts = make([]Controls, 1 << 12)
	for &cs, i in insts {
		cs = controls({.Fault})

		#partial switch Op(i).code {
		case .Use_Funct:
			#partial switch cast(Op_Funct)Op(i).lower {
			case .Add:
				cs = controls(R_Alu_Inst, .Add, .From_RD)
			case .Sub:
				cs = controls(R_Alu_Inst, .Sub, .From_RD)
			// case .Mult:
			// 	cs = controls(R_Alu_Inst, .Mul, .From_RD)
			// case .Div:
			// 	cs = controls(R_Alu_Inst, .Div, .From_RD)
			case .Jr:
				cs = controls({.Alu_Src}, j_type = {.Reg}, b_type = .Always)
			case .Jalr:
				cs = controls(
					{.Mem_To_Reg, .Alu_Src},
					.PC,
					reg_dest = .Ret_Addr,
					j_type = {.Reg},
					b_type = .Always,
				)
			case .And:
				cs = controls(R_Alu_Inst, .And, .From_RD)
			case .Or:
				cs = controls(R_Alu_Inst, .Or, .From_RD)
			case .Nor:
				cs = controls(R_Alu_Inst, .Nor, .From_RD)
			case .Xor:
				cs = controls(R_Alu_Inst, .Xor, .From_RD)
			case .Sll:
				cs = controls(R_Alu_Inst, .Shl, .From_RD)
			case .Srl:
				cs = controls(R_Alu_Inst, .Shr, .From_RD)
			case .Slt:
				cs = controls(R_Alu_Inst, .Lt, .From_RD)
			}
		case .Use_RegImm:
			switch cast(Op_RegImm)Op(i).lower {
			case .Bltz:
				cs = controls({.Alu_Src}, j_type = {.Rel}, b_type = .Lt)
			case .Bgez:
				cs = controls({.Alu_Src}, j_type = {.Rel}, b_type = .Ge)
			}
		case .Use_Funct2:
			switch cast(Op_Funct2)Op(i).lower {
			case .Mul:
				cs = controls(R_Alu_Inst, .Mul, .From_RD)
			}
		case .Addi:
			cs = controls(I_Alu_Inst, .Add, .From_RT)
		case .Lw:
			cs = controls(Load_Inst, .Add, .From_RT, mem_width = 3)
		case .Sw:
			cs = controls(Store_Inst, .Add, mem_width = 3)
		case .Lh:
			cs = controls(Load_Inst, .Add, .From_RT, mem_width = 1)
		case .Sh:
			cs = controls(Store_Inst, .Add, mem_width = 1)
		case .Lb:
			cs = controls(Load_Inst, .Add, .From_RT, mem_width = 0)
		case .Sb:
			cs = controls(Store_Inst, .Add, mem_width = 0)
		case .Beq:
			cs = controls({}, j_type = {.Rel}, b_type = .Eq)
		case .Bne:
			cs = controls({}, j_type = {.Rel}, b_type = .Ne)
		case .Bgtz:
			cs = controls({.Alu_Src}, j_type = {.Rel}, b_type = .Gt)
		case .Blez:
			cs = controls({.Alu_Src}, j_type = {.Rel}, b_type = .Le)
		case .J:
			cs = controls({.Alu_Src}, b_type = .Always)
		case .Jal:
			cs = controls({.Mem_To_Reg, .Alu_Src}, .PC, reg_dest = .Ret_Addr, b_type = .Always)
		case .Andi:
			cs = controls(I_Alu_Inst, .And, .From_RT)
		case .Ori:
			cs = controls(I_Alu_Inst, .Or, .From_RT)
		case .Xori:
			cs = controls(I_Alu_Inst, .Xor, .From_RT)
		case .Slti:
			cs = controls(I_Alu_Inst, .Lt, .From_RT)
		}
	}
	return
}


Op :: bit_field (u16) {
	lower: u8     | 6,
	code:  Opcode | 6,
}


op_code :: #force_inline proc(code: Opcode) -> Op {
	return Op{code = code, lower = 0}
}

op_funct :: #force_inline proc(lower: Op_Funct) -> Op {
	return Op{code = .Use_Funct, lower = cast(u8)lower}
}

op_regimm :: #force_inline proc(lower: Op_RegImm) -> Op {
	return Op{code = .Use_RegImm, lower = cast(u8)lower}
}

op_funct2 :: #force_inline proc(lower: Op_Funct2) -> Op {
	return Op{code = .Use_Funct2, lower = cast(u8)lower}
}

Opcode :: enum (u8) {
	Use_Funct  = 0,
	Use_RegImm = 1,
	J          = 2,
	Jal        = 3,
	Beq        = 4,
	Bne        = 5,
	Blez       = 6,
	Bgtz       = 7,
	Addi       = 8,
	Addiu      = 9,
	Slti       = 10,
	Sltiu      = 11,
	Andi       = 12,
	Ori        = 13,
	Xori       = 14,
	Lui        = 15,
	Use_Funct2 = 28,
	Lb         = 32,
	Lh         = 33,
	Lwl        = 34,
	Lw         = 35,
	Lbu        = 36,
	Lhu        = 37,
	Lwr        = 38,
	Sb         = 40,
	Sh         = 41,
	Swl        = 42,
	Sw         = 43,
	Swr        = 46,
	Cache      = 47,
	Ll         = 48,
	Lwc1       = 49,
	Lwc2       = 50,
	Pref       = 51,
	Ldc1       = 53,
	Ldc2       = 54,
	Sc         = 56,
	Swc1       = 57,
	Swc2       = 58,
	Sdc1       = 61,
	Sdc2       = 62,
}

Op_Funct :: enum (u8) {
	Sll     = 0,
	Srl     = 2,
	Sra     = 3,
	Sllv    = 4,
	Srlv    = 6,
	Srav    = 7,
	Jr      = 8,
	Jalr    = 9,
	Movz    = 10,
	Movn    = 11,
	Syscall = 12,
	Break   = 13,
	Sync    = 15,
	Mfhi    = 16,
	Mthi    = 17,
	Mflo    = 18,
	Mtlo    = 19,
	Mult    = 24,
	Multu   = 25,
	Div     = 26,
	Divu    = 27,
	Add     = 32,
	Addu    = 33,
	Sub     = 34,
	Subu    = 35,
	And     = 36,
	Or      = 37,
	Xor     = 38,
	Nor     = 39,
	Slt     = 42,
	Sltu    = 43,
	Tge     = 48,
	Tgeu    = 49,
	Tlt     = 50,
	Tltu    = 51,
	Teq     = 52,
	Tne     = 54,
}

Op_RegImm :: enum (u8) {
	Bltz = 0,
	Bgez = 1,
}

Op_Funct2 :: enum (u8) {
	Mul = 2,
}


Control_Flags :: bit_set[enum {
	Fault,
	Mem_Read,
	Mem_Write,
	Alu_Src,
	Mem_To_Reg,
};u8]

Alu_Func :: enum (u8) {
	Add,
	Sub,
	Mul,
	Div,
	And,
	Or,
	Nor,
	Xor,
	Shl,
	Shr,
	Lt,
	PC = 15,
}

Jump_Type :: bit_set[enum {
	Reg,
	Rel,
};u8]

Branch_Type :: enum (u8) {
	Never  = 0b000,
	Eq     = 0b001,
	Lt     = 0b010,
	Le     = 0b011,
	Always = 0b100,
	Ne     = 0b101,
	Ge     = 0b110,
	Gt     = 0b111,
}

Reg_Dest :: enum (u8) {
	None,
	Ret_Addr,
	From_RT,
	From_RD,
}

Controls :: bit_field (u32) {
	flags:     u8       | 7,
	reg_dest:  u8       | 2,
	b_type:    u8       | 3,
	j_type:    u8       | 2,
	mem_width: u8       | 2,
	func:      Alu_Func | 4,
}

controls :: proc(
	flags: Control_Flags,
	func: Alu_Func = nil,
	reg_dest: Reg_Dest = .None,
	mem_width: u8 = 0,
	j_type: Jump_Type = {},
	b_type: Branch_Type = .Never,
) -> Controls {
	return Controls {
		flags = transmute(u8)flags,
		reg_dest = transmute(u8)reg_dest,
		b_type = transmute(u8)b_type,
		j_type = transmute(u8)j_type,
		mem_width = mem_width,
		func = func,
	}
}
