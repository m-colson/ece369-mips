`timescale 1ns / 1ps

module MEM_WB_RegFile(
    input CLK,
    input Reset,
    input[31:0] AluResult,
    input[31:0] ReadData,
    input[4:0] WriteAddr,
    input MemToReg,
    input[31:0] PCOut,
    output reg[31:0] AluResultFromMEM_WB,
    output reg[31:0] ReadDataFromMEM_WB,
    output reg[4:0] WriteAddrFromMEM_WB,
    output reg MemToRegFromMEM_WB,
    output reg[31:0] PCOutFromMEM_WB
    );

    always @(posedge CLK) begin
        if (Reset) begin
            AluResultFromMEM_WB <= 0;
            ReadDataFromMEM_WB <= 0;
            WriteAddrFromMEM_WB <= 0;
            MemToRegFromMEM_WB <= 0;
            PCOutFromMEM_WB <= 0;
        end else begin
            AluResultFromMEM_WB <= AluResult;
            ReadDataFromMEM_WB <= ReadData;
            WriteAddrFromMEM_WB <= WriteAddr;
            MemToRegFromMEM_WB <= MemToReg;
            PCOutFromMEM_WB <= PCOut;
        end
    end
endmodule
