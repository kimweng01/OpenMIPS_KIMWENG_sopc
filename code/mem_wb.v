`include	"define.v"

module mem_wb(
	input						clk,
	input						rst,
	
	input		[`RegAddrBus]	mem_wd,
	input						mem_wreg,
	input		[`RegBus]		mem_wdata,
	
	input		[`RegBus]		mem_hi,
	input		[`RegBus]		mem_lo,
	input						mem_whilo,
	
	input						mem_LLbit_we,
	input						mem_LLbit_value,
	
	input						mem_cp0_reg_we,
	input		[4:0]			mem_cp0_reg_wr_addr,
	input		[`RegBus]		mem_cp0_reg_data,
	
	input		[5:0]			stall,
	input						flush,
	
	//=====================================
	output reg	[`RegAddrBus]	wb_wd,
	output reg					wb_wreg,
	output reg	[`RegBus]		wb_wdata,
	
	output reg	[`RegBus]		wb_hi,
	output reg	[`RegBus]		wb_lo,
	output reg					wb_whilo,
	
	output reg					wb_LLbit_we,
	output reg					wb_LLbit_value,
	
	output reg					wb_cp0_reg_we,
	output reg	[4:0]			wb_cp0_reg_wr_addr,
	output reg	[`RegBus]		wb_cp0_reg_data
	);
	
	
always @(posedge clk) begin
	if(rst == `RstEnable) begin
		wb_wd				<= `NOPRegAddr;
		wb_wreg				<= `WriteDisable;
		wb_wdata			<= `ZeroWord;
				
		wb_hi				<= `ZeroWord;
		wb_lo				<= `ZeroWord;
		wb_whilo			<= `WriteDisable;
		
		wb_LLbit_we 		<= 0;
		wb_LLbit_value		<= 0;
		
		wb_cp0_reg_we		<= `WriteDisable;
		wb_cp0_reg_wr_addr	<= 5'b0;
		wb_cp0_reg_data		<= `ZeroWord;
		
	end else if(flush == 1'b1) begin
		wb_wd				<= `NOPRegAddr;
		wb_wreg				<= `WriteDisable;
		wb_wdata			<= `ZeroWord;
				
		wb_hi				<= `ZeroWord;
		wb_lo				<= `ZeroWord;
		wb_whilo			<= `WriteDisable;
		
		wb_LLbit_we 		<= 0;
		wb_LLbit_value		<= 0;
		
		wb_cp0_reg_we		<= `WriteDisable;
		wb_cp0_reg_wr_addr	<= 5'b0;
		wb_cp0_reg_data		<= `ZeroWord;
		
	end else if(stall[4] == `Stop && stall[5] == `NoStop) begin
		wb_wd				<= `NOPRegAddr;
		wb_wreg				<= `WriteDisable;
		wb_wdata			<= `ZeroWord;
				
		wb_hi				<= `ZeroWord;
		wb_lo				<= `ZeroWord;
		wb_whilo			<= `WriteDisable;
		
		wb_LLbit_we 		<= 0;
		wb_LLbit_value		<= 0;
			
		wb_cp0_reg_we		<= `WriteDisable;
		wb_cp0_reg_wr_addr	<= 5'b0;
		wb_cp0_reg_data		<= `ZeroWord;
		
	end else if(stall[4] == `NoStop) begin
		wb_wd				<= mem_wd;
		wb_wreg				<= mem_wreg;
		wb_wdata			<= mem_wdata;
				
		wb_hi				<= mem_hi;
		wb_lo				<= mem_lo;
		wb_whilo			<= mem_whilo;
		
		wb_LLbit_we 		<= mem_LLbit_we;
		wb_LLbit_value		<= mem_LLbit_value;
		
		wb_cp0_reg_we		<= mem_cp0_reg_we;
		wb_cp0_reg_wr_addr	<= mem_cp0_reg_wr_addr;
		wb_cp0_reg_data		<= mem_cp0_reg_data;
		
	end
end

endmodule