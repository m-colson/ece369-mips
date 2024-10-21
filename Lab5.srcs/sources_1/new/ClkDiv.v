module ClkDiv(
        input Clk,
        input Rst,
        output reg ClkOut
    );
    
   //to create 1 Hz clock from 100-MHz on the board
   parameter DivVal = 49999999;
   reg [25:0] DivCnt;
	
   always @(posedge Clk) begin
      if( Rst == 1 )begin
         DivCnt <= 0;
         ClkOut <= 0;
      end
      else begin
         if( DivCnt >= DivVal ) begin
            	ClkOut <= ~ClkOut;
            	DivCnt <= 0;
         end
         else begin
            	ClkOut <= ClkOut;
            	DivCnt <= DivCnt + 1;
         end
      end
   end
endmodule
