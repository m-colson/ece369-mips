`timescale 1ns / 1ps

module Registers(
    input CLK,
    input Reset,
    input [4:0] ReadAddr1,
    input [4:0] ReadAddr2,
    input [4:0] WriteAddr,
    input [31:0] WriteData,
    output [31:0] ReadData1,
    output [31:0] ReadData2
    );

    reg [31:0] RegFile [0:31];

    integer i;
    always @(posedge CLK, posedge Reset) begin
        if (Reset) begin
            for (i = 0; i < 32; i = i + 1) begin
                RegFile[i] <= 0;
            end
        end else begin
            if (WriteAddr != 0) begin
                RegFile[WriteAddr] <= WriteData;
            end
        end
    end

    assign ReadData1 = (ReadAddr1 == 0) ? 0 : RegFile[ReadAddr1];
    assign ReadData2 = (ReadAddr2 == 0) ? 0 : RegFile[ReadAddr2];
endmodule
