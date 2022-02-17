`include	"define.v"

module hilo_reg(
	input 						clk,
	input						rst,
	
	input						we,
	input			[`RegBus]	hi_i,
	input			[`RegBus]	lo_i,
	
	output reg		[`RegBus]	hi_o,
	output reg		[`RegBus]	lo_o
	);
	

always @(posedge clk) begin
	if(rst == `RstEnable) begin
		hi_o <= `ZeroWord;
		lo_o <= `ZeroWord;
	end else if((we == `WriteEnable)) begin
		hi_o <= hi_i;
		lo_o <= lo_i;
	/*end else begin //remain
		hi_o <= hi_o;
		lo_o <= lo_o;	*/
	end
end

endmodule