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

    reg[31:0] memory[0:1023];

    integer i;
    always @(posedge CLK, posedge Reset) begin
        if (Reset) begin
            for (i = 0; i < 1024; i = i + 1) begin
                memory[i] = 0;
            end
            
            $readmemh("data_memory.mem", memory);
        end
        else begin
            if (MemWrite) begin
                memory[Address >> 2] <= WriteData & ~(32'hffffff00 << {MemWidth, 3'd0});
            end
        end
    end

    assign ReadData = MemRead ? (memory[Address >> 2] & ~(32'hffffff00 << {MemWidth, 3'd0})) : 0;
endmodule
