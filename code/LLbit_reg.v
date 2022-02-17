`include	"define.v"

module LLbit_reg(
	input						clk,
	input						rst,
	
	input						flush,
	
	input						LLbit_i,
	input						we,
	
	//====================================
	output reg					LLbit_o
	);
	
always @(posedge clk) begin
	if(rst == `RstEnable)
		LLbit_o <= 0;
	else if(flush)
		LLbit_o <= 0;
	else if(we == `WriteEnable)
		LLbit_o <= LLbit_i;
end

endmodule