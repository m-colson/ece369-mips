// Percent Effort: mcolson 100%

`timescale 1ns / 1ps

module Top(
    input Clk,
    input Reset,
    output [7:0] en_out,
    output [6:0] out7
    );
    
    wire ClkSlow;
    ClkDiv topCD(
        .Clk(Clk),
        .Rst(Reset),
        .ClkOut(ClkSlow)
    );
    
    wire[31:0] DisplayedWriteData;
    wire[31:0] DisplayedProgramCounter;
    Datapath topDP(
        .CLK(ClkSlow),
        .Reset(Reset),
        .DisplayedWriteData(DisplayedWriteData),
        .DisplayedProgramCounter(DisplayedProgramCounter)
    );

    Two4DigitDisplay topT4DD(
        .Clk(Clk),
        .NumberA(DisplayedWriteData[15:0]),
        .NumberB(DisplayedProgramCounter[15:0]),
        .out7(out7),
        .en_out(en_out)
    );
    
endmodule
