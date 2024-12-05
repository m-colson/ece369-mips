`timescale 1ns / 1ps

module ID_EX_RegFile(
    input CLK,
    input Reset,
    input Stall,
    input[31:0] ReadData1,
    input[31:0] ReadData2,
    input[31:0] AluBIn,
    input[4:0] AluSA,
    input[4:0] WriteAddr,
    input[31:0] PCOut,
    input MemRead,
    input MemWrite,
    input MemToReg,
    input[1:0] MemWidth,
    input[3:0] AluFunc,
    output reg[31:0] ReadData1FromID_EX,
    output reg[31:0] ReadData2FromID_EX,
    output reg[31:0] AluBInFromID_EX,
    output reg[4:0] AluSAFromID_EX,
    output reg[4:0] WriteAddrFromID_EX,
    output reg[31:0] PCOutFromID_EX,
    output reg MemReadFromID_EX,
    output reg MemWriteFromID_EX,
    output reg[1:0] MemWidthFromID_EX,
    output reg[3:0] AluFuncFromID_EX,
    output reg MemToRegFromID_EX
    );

    always @(posedge CLK) begin
        if (Reset) begin
            ReadData1FromID_EX <= 0;
            ReadData2FromID_EX <= 0;
            AluBInFromID_EX <= 0;
            AluSAFromID_EX <= 0;
            WriteAddrFromID_EX <= 0;
            PCOutFromID_EX <= 0;
            MemReadFromID_EX <= 0;
            MemWriteFromID_EX <= 0;
            MemWidthFromID_EX <= 0;
            AluFuncFromID_EX <= 0;
            MemToRegFromID_EX <= 0;
        end else if (Stall) begin
            ReadData1FromID_EX <= 0;
            ReadData2FromID_EX <= 0;
            AluBInFromID_EX <= 0;
            AluSAFromID_EX <= 0;
            WriteAddrFromID_EX <= 0;
            PCOutFromID_EX <= PCOut;
            MemReadFromID_EX <= 0;
            MemWriteFromID_EX <= 0;
            MemWidthFromID_EX <= 0;
            AluFuncFromID_EX <= 0;
            MemToRegFromID_EX <= 1;
        end else begin
            ReadData1FromID_EX <= ReadData1;
            ReadData2FromID_EX <= ReadData2;
            AluBInFromID_EX <= AluBIn;
            AluSAFromID_EX <= AluSA;
            WriteAddrFromID_EX <= WriteAddr;
            PCOutFromID_EX <= PCOut;
            MemReadFromID_EX <= MemRead;
            MemWriteFromID_EX <= MemWrite;
            MemWidthFromID_EX <= MemWidth;
            AluFuncFromID_EX <= AluFunc;
            MemToRegFromID_EX <= MemToReg;
        end
    end
endmodule
