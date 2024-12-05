package main

import "core:fmt"
import "core:io"
import "core:os"

main :: proc() {
	// gen_controller_verilog("controls.v")
	gen_controller_mem("controls.mem.v", true)

	if err := copy_file("lab7\\vbsme_inst.mem", "instruction_memory.mem"); err != nil {
		panic(fmt.tprint(err))
	}
	if err := copy_file("lab7\\vbsme_data.mem", "data_memory.mem"); err != nil {
		panic(fmt.tprint(err))
	}

	// prog := collatz(1)
	// defer delete(prog)

	// if err := write_inst_mem(prog[:], 1); err != nil {
	// 	panic(fmt.tprint(err))
	// }
}

copy_file :: proc(src: string, dst: string) -> (err: os.Errno) {
	out := os.open(dst, os.O_CREATE | os.O_TRUNC) or_return
	defer os.close(out)

	inp := os.open(src) or_return
	defer os.close(inp)

	_, err = io.copy(os.stream_from_handle(out), os.stream_from_handle(inp))
	return
}

write_inst_mem :: proc(
	prog: []Inst,
	gap := 6,
	out_path := "instruction_memory.mem",
) -> (
	err: os.Errno,
) {
	out := os.open(out_path, os.O_CREATE | os.O_TRUNC) or_return
	defer os.close(out)

	for inst, i in prog {
		fmt.fprintfln(out, "%8x\n", to_u32(inst))
		for _ in 1 ..< gap {
			fmt.fprintfln(out, "%8x\n", 0)
		}

		fmt.printfln("%x: %v", i * gap * 4, inst)
	}

	final_loop := []Inst{brn(.Eq, .Z, .Z, -1), alu(.Or, .S7, 0, .S7)}

	final_base := len(prog) * gap * 4
	for inst, i in final_loop {
		fmt.fprintfln(out, "%8x\n", to_u32(inst))
		fmt.printfln("%x: %v", final_base + i * 4, inst)
	}

	return
}

collatz :: proc(gap: i16 = 6) -> (out: [dynamic]Inst) {
	Val :: Reg.S0
	Num1 :: Reg.T4
	Num3 :: Reg.T5
	Steps :: Reg.S7

	return [dynamic]Inst {
		lv(3, Val),
		lv(1, Num1),
		lv(3, Num3),
		lv(0, Steps),
		alu(.And, Val, 1, .T0),
		brn(.Ne, .T0, .Z, 4 * gap - 1),
		nop(),
		alu(.Shr, Val, Num1, Val),
		brn(.Eq, .Z, .Z, 4 * gap - 1),
		nop(),
		alu(.Mul, Val, Num3, Val),
		alu(.Add, Val, 1, Val),
		alu(.Add, Steps, 1, Steps),
		brn(.Ne, Val, Num1, -(9 * gap + 1)),
		nop(),
	}
}

branches :: proc() -> (out: [dynamic]Inst) {
	singlez_test :: proc(out: ^[dynamic]Inst, op: Branch_Cond_Zero, a: Reg, should: bool) {
		if should {
			append(out, brnz(op, a, 2 * 6 - 1), jmp(1028))
		} else {
			append(out, brnz(op, a, 1024))
		}
	}

	bz_test :: proc(out: ^[dynamic]Inst, op: Branch_Cond_Zero, gt: bool, eq: bool, lt: bool) {
		singlez_test(out, op, .S0, gt)
		singlez_test(out, op, .Z, eq)
		singlez_test(out, op, .S1, lt)
	}

	single_test :: proc(out: ^[dynamic]Inst, op: Branch_Cond, a: Reg, b: Reg, should: bool) {
		if should {
			append(out, brn(op, a, b, 2 * 6 - 1), jmp(1028))
		} else {
			append(out, brn(op, a, b, 1024))
		}
	}

	out = [dynamic]Inst{lv(5, .S0), lv(-3, .S1), lv(.S0, .S2)}
	bz_test(&out, .Lt, false, false, true)
	bz_test(&out, .Le, false, true, true)
	bz_test(&out, .Gt, true, false, false)
	bz_test(&out, .Ge, true, true, false)

	single_test(&out, .Eq, .S0, .S2, true)
	single_test(&out, .Eq, .S0, .S1, false)

	single_test(&out, .Ne, .S2, .S0, false)
	single_test(&out, .Ne, .S1, .S0, true)

	append(&out, brn(.Eq, .Z, .Z, -1))

	return
}

fibnums :: proc(gap: i16 = 6) -> [dynamic]Inst {
	N :: Reg.T0
	N_1 :: Reg.S1
	N_2 :: Reg.S2
	Addr :: Reg.S7

	return [dynamic]Inst {
		// init
		lv(0, Addr),
		lv(0, N_2),
		lv(1, N_1),
		jmp(u32(14 * gap), link = true),
		nop(),
		// loop 
		store(N_2, Addr),
		alu(.Add, N_2, N_1, N),
		lv(N_1, N_2),
		lv(N, N_1),
		alu(.Add, Addr, 4, Addr),
		// until about to overflow
		brnz(.Gt, N_1, -(5 * gap + 1)),
		nop(),
		jmp(0),
		nop(),
		// clear mem
		lv(-196, .T0),
		store(.Z, .T0, 196),
		alu(.Add, .T0, 4, .T0),
		brnz(.Le, .T0, -(2 * gap + 1)),
		nop(),
		jmp(.RA),
		nop(),
	}
}

test_prog :: proc() -> [dynamic]Inst {
	return [dynamic]Inst {
		lv(5, .T0),
		alu(.Add, .T0, 3, .T0),
		store(.T0, .Z, 0), // 8
		alu(.Add, .T0, -2, .T1),
		store(.T1, .Z, 4), // 6
		alu(.Add, .T0, .T1, .T2),
		store(.T2, .Z, 8), // 14
		alu(.Sub, .T0, .T1, .T2),
		store(.T2, .Z, 12), // 2
		alu(.Mul, .T0, .T1, .T2),
		store(.T2, .Z, 16), // 48
		alu(.Xor, .T2, 78, .T2),
		store(.T2, .Z, 20), // 126
		alu(.Xor, .T2, .T0, .T2),
		store(.T2, .Z, 24), //  118
	}
}

Reg :: enum (u8) {
	Z,
	AT,
	V0,
	V1,
	A0,
	A1,
	A2,
	A3,
	T0,
	T1,
	T2,
	T3,
	T4,
	T5,
	T6,
	T7,
	S0,
	S1,
	S2,
	S3,
	S4,
	S5,
	S6,
	S7,
	T8,
	T9,
	K0,
	K1,
	GP,
	SP,
	FP,
	RA,
}


Reg_Imm :: union {
	Reg,
	i16,
}

Inst :: union {
	I_Inst,
	R_Inst,
	RI_Inst,
	J_Inst,
}

to_u32 :: proc(inst: Inst) -> u32 {
	switch inst in inst {
	case I_Inst:
		return u32(inst)
	case R_Inst:
		return u32(inst)
	case RI_Inst:
		return u32(inst)
	case J_Inst:
		return u32(inst)
	}

	panic("unreachable")
}

load :: proc(
	base: Reg,
	offset: i16,
	dst: Reg,
	width: Mem_Width = .Word,
	unsigned := false,
) -> I_Inst {
	signed_codes := [Mem_Width]Opcode {
		.Byte = .Lb,
		.Half = .Lh,
		.Word = .Lw,
	}
	unsigned_codes := [Mem_Width]Opcode {
		.Byte = .Lbu,
		.Half = .Lhu,
		.Word = .Lw,
	}

	codes := (unsigned_codes if unsigned else signed_codes)
	return {code = codes[width], rs = base, rt = dst, imm = offset}
}

store :: proc(src: Reg, base: Reg, offset: i16 = 0, width: Mem_Width = .Word) -> I_Inst {
	codes := [Mem_Width]Opcode {
		.Byte = .Sb,
		.Half = .Sh,
		.Word = .Sw,
	}

	return {code = codes[width], rs = base, rt = src, imm = offset}
}

Mem_Width :: enum {
	Byte,
	Half,
	Word,
}

nop :: #force_inline proc() -> Inst {
	return alu(.Shl, .Z, .Z, .Z)
}

lv :: #force_inline proc(b: Reg_Imm, dst: Reg, loc := #caller_location) -> Inst {
	return alu(.Or, .Z, b, dst, loc = loc)
}

alu :: proc(
	func: Alu_Func,
	a: Reg,
	b: Reg_Imm,
	dst: Reg,
	unsigned := false,
	loc := #caller_location,
) -> Inst {
	switch b in b {
	case Reg:
		ops := #partial #sparse[Alu_Func]R_Inst_Kind {
			.Add = .Add,
			.Sub = .Sub,
			.Mul = .Mul,
			// .Div = .Div,
			.And = .And,
			.Or  = .Or,
			.Nor = .Nor,
			.Xor = .Xor,
			.Shl = .Sll,
			.Shr = .Srl,
			.Lt  = .Slt,
		}
		if ops[func] == ._ILLEGAL {
			panic(fmt.tprintf("illegal alu function %v", func), loc)
		}
		return instr(ops[func], a, b, dst, unsigned)
	case i16:
		ops := #partial #sparse[Alu_Func]I_Inst_Kind {
			.Add = .Add,
			.And = .And,
			.Or  = .Or,
			.Xor = .Xor,
			.Lt  = .Slt,
		}
		if ops[func] == ._ILLEGAL {
			panic(fmt.tprintf("illegal immediate alu function %v", func), loc)
		}
		return insti(ops[func], a, b, dst, unsigned)
	}

	panic("unreachable")
}

brn :: proc(cond: Branch_Cond, a: Reg, b: Reg, rel_addr: i16) -> I_Inst {
	codes := [Branch_Cond]I_Inst_Kind {
		.Eq = .Beq,
		.Ne = .Bne,
	}
	return insti(codes[cond], a, rel_addr, b)
}

brnz :: proc(cond: Branch_Cond_Zero, a: Reg, rel_addr: i16) -> Inst {
	i_codes := #partial [Branch_Cond_Zero]I_Inst_Kind {
		.Le = .Blez,
		.Gt = .Bgtz,
	}
	if i_codes[cond] != nil {
		return insti(i_codes[cond], a, rel_addr, .Z)
	}
	ri_codes := #partial [Branch_Cond_Zero]RI_Inst_Kind {
		.Lt = .Bltz,
		.Ge = .Bgez,
	}
	if ri_codes[cond] != nil {
		return instri(ri_codes[cond], a, rel_addr)
	}
	unreachable()
}

Branch_Cond :: enum {
	Eq,
	Ne,
}

Branch_Cond_Zero :: enum {
	Lt,
	Le,
	Gt,
	Ge,
}

I_Inst :: bit_field (u32) {
	imm:  i16    | 16,
	rt:   Reg    | 5,
	rs:   Reg    | 5,
	code: Opcode | 6,
}

I_Inst_Kind :: enum {
	_ILLEGAL,
	Add,
	Slt,
	And,
	Or,
	Xor,
	Lu,
	Beq,
	Bne,
	Blez,
	Bgtz,
	Swl,
	Lwl,
	Ll,
	Lwc1,
	Lwc2,
	Ldc1,
	Ldc2,
	Sc,
	Swc1,
	Swc2,
	Sdc1,
	Sdc2,
	Lwr,
	Swr,
	Cache,
	Pref,
}

insti :: proc(op_type: I_Inst_Kind, a: Reg, imm: i16, dst: Reg, unsigned := false) -> I_Inst {
	signed_codes := [I_Inst_Kind]Opcode {
		._ILLEGAL = nil,
		.Add      = .Addi,
		.Slt      = .Slti,
		.And      = .Andi,
		.Or       = .Ori,
		.Xor      = .Xori,
		.Lu       = .Lui,
		.Beq      = .Beq,
		.Bne      = .Bne,
		.Blez     = .Blez,
		.Bgtz     = .Bgtz,
		.Swl      = .Swl,
		.Lwl      = .Lwl,
		.Ll       = .Ll,
		.Lwc1     = .Lwc1,
		.Lwc2     = .Lwc2,
		.Ldc1     = .Ldc1,
		.Ldc2     = .Ldc2,
		.Sc       = .Sc,
		.Swc1     = .Swc1,
		.Swc2     = .Swc2,
		.Sdc1     = .Sdc1,
		.Sdc2     = .Sdc2,
		.Lwr      = .Lwr,
		.Swr      = .Swr,
		.Cache    = .Cache,
		.Pref     = .Pref,
	}

	unsigned_codes := [I_Inst_Kind]Opcode {
		._ILLEGAL = nil,
		.Add      = .Addiu,
		.Slt      = .Sltiu,
		.And      = .Andi,
		.Or       = .Ori,
		.Xor      = .Xori,
		.Lu       = .Lui,
		.Beq      = .Beq,
		.Bne      = .Bne,
		.Blez     = .Blez,
		.Bgtz     = .Bgtz,
		.Swl      = .Swl,
		.Lwl      = .Lwl,
		.Ll       = .Ll,
		.Lwc1     = .Lwc1,
		.Lwc2     = .Lwc2,
		.Ldc1     = .Ldc1,
		.Ldc2     = .Ldc2,
		.Sc       = .Sc,
		.Swc1     = .Swc1,
		.Swc2     = .Swc2,
		.Sdc1     = .Sdc1,
		.Sdc2     = .Sdc2,
		.Lwr      = .Lwr,
		.Swr      = .Swr,
		.Cache    = .Cache,
		.Pref     = .Pref,
	}

	codes := (unsigned_codes if unsigned else signed_codes)
	return {code = codes[op_type], rs = a, rt = dst, imm = imm}
}

R_Inst :: bit_field (u32) {
	lower:  u8     | 6,
	_extra: u8     | 5,
	rd:     Reg    | 5,
	rt:     Reg    | 5,
	rs:     Reg    | 5,
	code:   Opcode | 6,
}

R_Inst_Kind :: enum {
	_ILLEGAL,
	Sll,
	Srl,
	Sra,
	Sllv,
	Srlv,
	Srav,
	Jr,
	Jalr,
	// Movz,
	// Movn,
	// Syscall,
	// Break,
	// Sync,
	// Mfhi,
	// Mthi,
	// Mflo,
	// Mtlo,
	// Mult,
	// Div,
	Mul,
	Add,
	Sub,
	And,
	Or,
	Xor,
	Nor,
	Slt,
	// Tge,
	// Tlt,
	// Teq,
	// Tne,
}

instr :: proc(op_type: R_Inst_Kind, a: Reg, b: Reg, dst: Reg, unsigned := false) -> R_Inst {
	signed_ops := [R_Inst_Kind]Op {
		._ILLEGAL = Op{},
		.Sll      = op_funct(.Sll),
		.Srl      = op_funct(.Srl),
		.Sra      = op_funct(.Sra),
		.Sllv     = op_funct(.Sllv),
		.Srlv     = op_funct(.Srlv),
		.Srav     = op_funct(.Srav),
		.Jr       = op_funct(.Jr),
		.Jalr     = op_funct(.Jalr),
		// .Movz     = op_funct(.Movz),
		// .Movn     = op_funct(.Movn),
		// .Syscall  = op_funct(.Syscall),
		// .Break    = op_funct(.Break),
		// .Sync     = op_funct(.Sync),
		// .Mfhi     = op_funct(.Mfhi),
		// .Mthi     = op_funct(.Mthi),
		// .Mflo     = op_funct(.Mflo),
		// .Mtlo     = op_funct(.Mtlo),
		// .Mult     = op_funct(.Mult),
		// .Div      = op_funct(.Div),
		.Mul      = op_funct2(.Mul),
		.Add      = op_funct(.Add),
		.Sub      = op_funct(.Sub),
		.And      = op_funct(.And),
		.Or       = op_funct(.Or),
		.Xor      = op_funct(.Xor),
		.Nor      = op_funct(.Nor),
		.Slt      = op_funct(.Slt),
		// .Tge      = op_funct(.Tge),
		// .Tlt      = op_funct(.Tlt),
		// .Teq      = op_funct(.Teq),
		// .Tne      = op_funct(.Tne),
	}

	unsigned_ops := [R_Inst_Kind]Op {
		._ILLEGAL = Op{},
		.Sll      = op_funct(.Sll),
		.Srl      = op_funct(.Srl),
		.Sra      = op_funct(.Sra),
		.Sllv     = op_funct(.Sllv),
		.Srlv     = op_funct(.Srlv),
		.Srav     = op_funct(.Srav),
		.Jr       = op_funct(.Jr),
		.Jalr     = op_funct(.Jalr),
		// .Movz     = op_funct(.Movz),
		// .Movn     = op_funct(.Movn),
		// .Syscall  = op_funct(.Syscall),
		// .Break    = op_funct(.Break),
		// .Sync     = op_funct(.Sync),
		// .Mfhi     = op_funct(.Mfhi),
		// .Mthi     = op_funct(.Mthi),
		// .Mflo     = op_funct(.Mflo),
		// .Mtlo     = op_funct(.Mtlo),
		// .Mult     = op_funct(.Multu),
		// .Div      = op_funct(.Divu),
		.Mul      = op_funct2(.Mul),
		.Add      = op_funct(.Addu),
		.Sub      = op_funct(.Subu),
		.And      = op_funct(.And),
		.Or       = op_funct(.Or),
		.Xor      = op_funct(.Xor),
		.Nor      = op_funct(.Nor),
		.Slt      = op_funct(.Sltu),
		// .Tge      = op_funct(.Tgeu),
		// .Tlt      = op_funct(.Tltu),
		// .Teq      = op_funct(.Teq),
		// .Tne      = op_funct(.Tne),
	}

	op := (unsigned_ops if unsigned else signed_ops)[op_type]
	return R_Inst{code = op.code, rs = a, rt = b, rd = dst, lower = op.lower}
}

RI_Inst :: bit_field (u32) {
	imm:   i16       | 16,
	funct: Op_RegImm | 5,
	rs:    Reg       | 5,
	code:  Opcode    | 6,
}

RI_Inst_Kind :: enum {
	_ILLEGAL,
	Bltz,
	Bgez,
}

instri :: proc(op_type: RI_Inst_Kind, a: Reg, imm: i16) -> RI_Inst {
	ris := [RI_Inst_Kind]Op_RegImm {
		._ILLEGAL = nil,
		.Bltz     = .Bltz,
		.Bgez     = .Bgez,
	}
	return RI_Inst{code = .Use_RegImm, rs = a, funct = ris[op_type], imm = imm}
}

Reg_Addr :: union {
	Reg,
	u32,
}

jmp :: proc(addr: Reg_Addr, link := false) -> Inst {
	switch addr in addr {
	case Reg:
		return instr(.Jalr if link else .Jr, addr, .Z, .Z)
	case u32:
		return J_Inst{code = .Jal if link else .J, addr = addr}
	}
	unreachable()
}

J_Inst :: bit_field (u32) {
	addr: u32    | 26,
	code: Opcode | 6,
}
