`timescale 1ns / 1ps

module ID_EX_RegFile(
    input CLK,
    input Reset,
    input[31:0] ReadData1,
    input[31:0] ReadData2,
    input[31:0] SignExtendedImmediate,
    input[4:0] RT,
    input[4:0] RD,
    input[31:0] PCOutPlus4,
    input[31:0] PCOut,
    input MemRead,
    input MemWrite,
    input AluSrc,
    input MemToReg,
    input[1:0] RegDest,
    input[2:0] BranchType,
    input[1:0] JumpType,
    input[1:0] MemWidth,
    input[3:0] AluFunc,
    output reg[31:0] ReadData1FromID_EX,
    output reg[31:0] ReadData2FromID_EX,
    output reg[31:0] SignExtendedImmediateFromID_EX,
    output reg[4:0] RTFromID_EX,
    output reg[4:0] RDFromID_EX,
    output reg[31:0] PCOutPlus4FromID_EX,
    output reg[31:0] PCOutFromID_EX,
    output reg MemReadFromID_EX,
    output reg MemWriteFromID_EX,
    output reg AluSrcFromID_EX,
    output reg[1:0] RegDestFromID_EX,
    output reg[2:0] BranchTypeFromID_EX,
    output reg[1:0] JumpTypeFromID_EX,
    output reg[1:0] MemWidthFromID_EX,
    output reg[3:0] AluFuncFromID_EX,
    output reg MemToRegFromID_EX
    );

    always @(posedge CLK, posedge Reset) begin
        if (Reset) begin
            ReadData1FromID_EX <= 0;
            ReadData2FromID_EX <= 0;
            SignExtendedImmediateFromID_EX <= 0;
            RTFromID_EX <= 0;
            RDFromID_EX <= 0;
            PCOutPlus4FromID_EX <= 0;
            PCOutFromID_EX <= 0;
            MemReadFromID_EX <= 0;
            MemWriteFromID_EX <= 0;
            AluSrcFromID_EX <= 0;
            BranchTypeFromID_EX <= 0;
            JumpTypeFromID_EX <= 0;
            MemWidthFromID_EX <= 0;
            AluFuncFromID_EX <= 0;
            RegDestFromID_EX <= 0;
            MemToRegFromID_EX <= 0;
        end else begin
            ReadData1FromID_EX <= ReadData1;
            ReadData2FromID_EX <= ReadData2;
            SignExtendedImmediateFromID_EX <= SignExtendedImmediate;
            RTFromID_EX <= RT;
            RDFromID_EX <= RD;
            PCOutPlus4FromID_EX <= PCOutPlus4;
            PCOutFromID_EX <= PCOut;
            MemReadFromID_EX <= MemRead;
            MemWriteFromID_EX <= MemWrite;
            AluSrcFromID_EX <= AluSrc;
            BranchTypeFromID_EX <= BranchType;
            JumpTypeFromID_EX <= JumpType;
            MemWidthFromID_EX <= MemWidth;
            AluFuncFromID_EX <= AluFunc;
            RegDestFromID_EX <= RegDest;
            MemToRegFromID_EX <= MemToReg;
        end
    end
endmodule
