// Percent Effort: mcolson 100%

`timescale 1ns / 1ps

module Datapath_tb();
    reg CLK;
    reg Reset;
    
    initial begin
        CLK = 0;
        Reset = 1;
        #5
        CLK = 1;
        #5
        CLK = 0;
        Reset = 0;

        forever begin
            #5 CLK = ~CLK;
        end
    end

    Datapath dp(CLK, Reset);
endmodule
