`timescale 1ns / 1ps

module HazardDetector(
        input [4:0] RS,
        input [4:0] RT,
        input AluSrc,
        input MemWrite,
        input [4:0] WriteAddrFromID_EX,
        input [4:0] WriteAddrFromEX_MEM,
        input [4:0] WriteAddrFromMEM_WB,
        output wire Stall
    );

    assign Stall = 
        (RS != 0
            && (RS == WriteAddrFromID_EX 
                || RS == WriteAddrFromEX_MEM
                || RS == WriteAddrFromMEM_WB))
        || ((!AluSrc || MemWrite)
            && RT != 0
            && (RT == WriteAddrFromID_EX 
                || RT == WriteAddrFromEX_MEM
                || RT == WriteAddrFromMEM_WB));
    
endmodule
