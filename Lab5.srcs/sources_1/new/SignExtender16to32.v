`timescale 1ns / 1ps

module SignExtender16to32(
    input[15:0] D,
    output wire[31:0] Q
    );
    
    assign Q = {D[15] ? 16'hffff : 16'h0000, D};
endmodule
