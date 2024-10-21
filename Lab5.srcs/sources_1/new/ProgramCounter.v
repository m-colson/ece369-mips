`timescale 1ns / 1ps

module ProgramCounter(
    input CLK,
    input Reset,
    input [31:0] D,
    output reg[31:0] Q
    );
    
    always @(posedge CLK, posedge Reset) begin
        if (Reset) begin
            Q <= 0;    
        end else begin
            Q <= D;
        end
    end
endmodule
