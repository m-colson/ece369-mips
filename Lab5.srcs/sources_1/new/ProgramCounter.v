`timescale 1ns / 1ps

module ProgramCounter(
    input CLK,
    input Reset,
    input Stall,
    input [31:0] D,
    output reg[31:0] Q
    );
    
    always @(posedge CLK) begin
        if (Reset) begin
            Q <= 0;    
        end else if (~Stall) begin
            Q <= D;
        end
    end
endmodule
