`timescale 1ns / 1ps

module InstructionMemory(
        input[31:0] Address,
        output[31:0] Instruction
    );
    
    reg[31:0] memory[0:1023];

    assign Instruction = memory[Address >> 2];
    
    integer i;
    initial begin
        for (i = 0; i < 1024; i = i + 1) begin
            memory[i] = 0;
        end
        $readmemh("instruction_memory.mem", memory);
    end
endmodule
