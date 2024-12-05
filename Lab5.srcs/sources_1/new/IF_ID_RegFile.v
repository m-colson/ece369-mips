`timescale 1ns / 1ps

module IF_ID_RegFile(
    input CLK,
    input Reset,
    input Stall,
    input[31:0] Instruction,
    input[31:0] PCOutPlus4,
    input[31:0] PCOut,
    output reg[31:0] InstructionFromIF_ID,
    output reg[31:0] PCOutPlus4FromIF_ID,
    output reg[31:0] PCOutFromIF_ID
    );

    always @(posedge CLK) begin
        if (Reset) begin
            InstructionFromIF_ID <= 0;
            PCOutPlus4FromIF_ID <= 0;
            PCOutFromIF_ID <= 0;
        end else if (~Stall) begin
            InstructionFromIF_ID <= Instruction;
            PCOutPlus4FromIF_ID <= PCOutPlus4;
            PCOutFromIF_ID <= PCOut;
        end
    end
endmodule
