`timescale 1ns / 1ps

module DataMemory(
    input CLK,
    input Reset,
    input[31:0] Address,
    input[31:0] WriteData,
    input MemRead,
    input MemWrite,
    input[1:0] MemWidth,
    output[31:0] ReadData
    );

    reg[31:0] memory[0:8191];

    integer i;
    initial begin
        for (i = 0; i < 8192; i = i + 1) begin
            memory[i] = 0;
        end
        $readmemh("data_memory.mem", memory);
    end

    always @(posedge CLK) begin
        if (MemWrite) begin
            memory[Address >> 2] <= (WriteData & ~(32'hffffff00 << {MemWidth, 3'd0})) | (memory[Address >> 2] & (32'hffffff00 << {MemWidth, 3'd0}));
        end
    end

    assign ReadData = MemRead ? (memory[Address >> 2] & ~(32'hffffff00 << {MemWidth, 3'd0})) : 0;
endmodule
