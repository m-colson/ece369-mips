`timescale 1ns / 1ps

module EX_MEM_RegFile(
    input CLK,
    input Reset,
    input[31:0] AluResult,
    input[31:0] ReadData2,
    input[4:0] WriteAddr,
    input MemRead,
    input MemWrite,
    input[1:0] MemWidth,
    input MemToReg,
    input[31:0] PCOut,
    output reg[31:0] AluResultFromEX_MEM,
    output reg[31:0] ReadData2FromEX_MEM,
    output reg[4:0] WriteAddrFromEX_MEM,
    output reg MemReadFromEX_MEM,
    output reg MemWriteFromEX_MEM,
    output reg[1:0] MemWidthFromEX_MEM,
    output reg MemToRegFromEX_MEM,
    output reg[31:0] PCOutFromEX_MEM
    );

    always @(posedge CLK) begin
        if (Reset) begin
            AluResultFromEX_MEM <= 0;
            ReadData2FromEX_MEM <= 0;
            WriteAddrFromEX_MEM <= 0;
            MemReadFromEX_MEM <= 0;
            MemWriteFromEX_MEM <= 0;
            MemWidthFromEX_MEM <= 0;
            MemToRegFromEX_MEM <= 0;
            PCOutFromEX_MEM <= 0;
        end else begin
            AluResultFromEX_MEM <= AluResult;
            ReadData2FromEX_MEM <= ReadData2;
            WriteAddrFromEX_MEM <= WriteAddr;
            MemReadFromEX_MEM <= MemRead;
            MemWriteFromEX_MEM <= MemWrite;
            MemWidthFromEX_MEM <= MemWidth;
            MemToRegFromEX_MEM <= MemToReg;
            PCOutFromEX_MEM <= PCOut;
        end
    end
endmodule
