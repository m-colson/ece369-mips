`timescale 1ns / 1ps

module BranchUnit(
    input[2:0] BranchType,
    input[1:0] JumpType,
    input[31:0] PCOutPlus4,
    input[31:0] Address,
    input[31:0] A,
    input[31:0] B,
    output wire[31:0] PCIn,
    output wire TakeBranch
    );
    
    wire IsLt = A >> 31;
    // NOTE: this doesn't necessarily work
    // however the way the instruction set is used, the b**z instructions always have 0 for B
    // except for BGEZ which doesn't use IsEq anyway.
    wire IsEq = (A ^ B) == 0;
    
    // JumpType[1] = { 0 = Relative, 1 = Absolute }
    // JumpType[0] = { 0 = Immediate, 1 = Register }
    assign PCIn = (JumpType[1] ? PCOutPlus4 : 0) + (JumpType[0] ? A : (Address << 2));

    // BranchType[2] = Invert Condition (Never => Always, Eq => Ne, Lt => Ge, Le => Gt)
    // BranchType[1] = Include Lt
    // BranchType[0] = Include Eq
    assign TakeBranch = BranchType[2] ^ ((BranchType[1] && IsLt) || (BranchType[0] && IsEq));
    
endmodule
