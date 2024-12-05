module ClkDiv(
        input Clk,
        output reg ClkOut = 0
    );
    
   parameter DivVal = 10000;
   reg [25:0] DivCnt = 0;
	
   always @(posedge Clk) begin
        if( DivCnt >= DivVal ) begin
            ClkOut <= ~ClkOut;
            DivCnt <= 0;
        end
        else begin
            ClkOut <= ClkOut;
            DivCnt <= DivCnt + 1;
        end
   end
endmodule
