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
        .ClkOut(ClkSlow)
    );
   
//    wire[31:0] DisplayedWriteData;
//    wire[31:0] DisplayedProgramCounter;
    wire[31:0] RegV0;
    wire[31:0] RegV1;
    (* keep_hierarchy = "yes" *) Datapath topDP(
        .CLK(ClkSlow),
        .Reset(Reset),
//        .DisplayedWriteData(DisplayedWriteData),
//        .DisplayedProgramCounter(DisplayedProgramCounter)
        .RegV0(RegV0),
        .RegV1(RegV1)
    );

    Two4DigitDisplay topT4DD(
        .Clk(Clk),
//        .NumberA(DisplayedWriteData[15:0]),
//        .NumberB(DisplayedProgramCounter[15:0]),
        .NumberA(RegV1[15:0]),
        .NumberB(RegV0[15:0]),
        .out7(out7),
        .en_out(en_out)
    );
    
endmodule
