`timescale 1ns / 1ps

module ALU(
    input [31:0] A,
    input [31:0] B,
    input [31:0] PCOutPlus4,
    input [3:0] F,
    output reg [31:0] Q
    );
    
    always @(A, B, PCOutPlus4, F) begin
        case (F)
            0: begin
                Q <= A + B;
            end
            1: begin
                Q <= A - B;
            end
            2: begin
                Q <= A * B;
            end
            3: begin
                Q <= A / B;
            end
            4: begin
                Q <= A & B;
            end
            5: begin
                Q <= A | B;
            end
            6: begin
                Q <= ~(A | B);
            end
            7: begin
                Q <= A ^ B;
            end
            8: begin
                Q <= A << B;
            end
            9: begin
                Q <= A >> B;
            end
            10: begin
                Q <= (A < B) ? 1 : 0;
            end
            15: begin
                Q <= PCOutPlus4 + 4;
            end
            default: begin
                Q <= 0; 
            end
        endcase
    end
   
endmodule