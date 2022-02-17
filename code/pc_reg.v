`include	"define.v"

module pc_reg(
	input				clk,
	input				rst,
	
	input	[5:0]		stall,
	
	input				branch_flag_i,
	input	[`RegBus]	branch_target_address_i,
	
	input				flush,
	input	[`RegBus]	new_pc,
	
	//=========================================
	output reg						ce,
	output reg		[`InstAddrBus]	pc
	);
	
	
always @(posedge clk) begin
	if(rst == `RstEnable)
		ce <= `ChipDisable;
	else
		ce <= `ChipEnable;
end 

always @(posedge clk) begin
	if(ce == `ChipDisable)
		pc <= 32'h3000_0000;
	else begin
		if(flush == 1'b1)
			pc <= new_pc;
		else if(stall[0] == `NoStop) begin
			if(branch_flag_i == `Branch)
				pc <= branch_target_address_i;
			else
				pc <= pc + 4'h4;
		end
	end 
end
		
		
endmodule