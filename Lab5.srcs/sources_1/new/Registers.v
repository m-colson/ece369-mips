`timescale 1ns / 1ps

module Registers(
    input CLK,
    input Reset,
    input [4:0] ReadAddr1,
    input [4:0] ReadAddr2,
    input [4:0] WriteAddr,
    input [31:0] WriteData,
    output [31:0] ReadData1,
    output [31:0] ReadData2,
    output [31:0] RegV0,
    output [31:0] RegV1
    );

    reg [31:0] RegFile [0:31];

    integer i;
    always @(posedge CLK) begin
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

    assign RegV0 = RegFile[2];
    assign RegV1 = RegFile[3];
endmodule
