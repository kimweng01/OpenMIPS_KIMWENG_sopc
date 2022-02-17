`include	"define.v"

module ex_mem(
	input						clk,
	input						rst,
	
	input 		[`RegAddrBus]	ex_wd,
	input 						ex_wreg,
	input		[`RegBus]		ex_wdata,
	
	input		[`RegBus]		ex_hi,
	input		[`RegBus]		ex_lo,
	input						ex_whilo,
	
	input		[5:0]			stall,
	
	input		[`DoubleRegBus]	maddsub_temp_i,
	input		[`DoubleRegBus]	div_temp_i,
	
	input						cnt_mult_i,
	input		[4:0]			cnt_div_i,
	
	input		[`AluOpBus]		ex_aluop,
	input		[`RegBus]		ex_mem_addr,
	input		[`RegBus]		ex_reg2,
	
	input						ex_cp0_reg_we,
	input		[4:0]			ex_cp0_reg_wr_addr,
	input		[`RegBus]		ex_cp0_reg_data,
	
	input						flush,
	input						ex_dlyslot_now,
	
	input		[`RegBus]		ex_current_inst_addr,
	input		[`RegBus]		ex_excepttype,
	
	//========================================
	output reg	[`RegAddrBus]	mem_wd,
	output reg					mem_wreg,
	output reg	[`RegBus]		mem_wdata,
	
	output reg	[`RegBus]		mem_hi,
	output reg	[`RegBus]		mem_lo,
	output reg					mem_whilo,
	
	output reg	[`DoubleRegBus]	maddsub_temp_o,
	output reg	[`DoubleRegBus]	div_temp_o,
	
	output reg					cnt_mult_o,
	output reg	[4:0]			cnt_div_o,
	
	output reg	[`AluOpBus]		mem_aluop,
	output reg	[`RegBus]		mem_mem_addr,
	output reg	[`RegBus]		mem_reg2,
	
	output reg					mem_cp0_reg_we,
	output reg	[4:0]			mem_cp0_reg_wr_addr,
	output reg	[`RegBus]		mem_cp0_reg_data,
	
	output reg					mem_dlyslot_now,
	output reg	[`RegBus]		mem_current_inst_addr,
	output reg	[`RegBus]		mem_excepttype
	);
	
	
always @(posedge clk) begin
	if(rst == `RstEnable) begin
		mem_wd					<= `NOPRegAddr;
        mem_wreg				<= `WriteDisable;
        mem_wdata				<= `ZeroWord;

		mem_hi					<= `ZeroWord;
		mem_lo					<= `ZeroWord;
		mem_whilo				<= `WriteDisable;
		
		maddsub_temp_o			<= {`ZeroWord, `ZeroWord};
		div_temp_o  			<= {`ZeroWord, `ZeroWord};

		cnt_mult_o				<= 0;
		cnt_div_o				<= 0;
 
		mem_aluop				<= `EXE_NOP_OP;
		mem_mem_addr			<= `ZeroWord;
		mem_reg2				<= `ZeroWord;
		
		mem_cp0_reg_we			<= `WriteDisable;
		mem_cp0_reg_wr_addr		<= 5'b0;
		mem_cp0_reg_data		<= `ZeroWord;
		
		mem_dlyslot_now			<= `NotInDelaySlot;
		mem_current_inst_addr	<= `ZeroWord;
		mem_excepttype			<= `ZeroWord;
		
	end else if(flush == 1'b1) begin
		mem_wd					<= `NOPRegAddr;
        mem_wreg				<= `WriteDisable;
        mem_wdata				<= `ZeroWord;
    
		mem_hi					<= `ZeroWord;
		mem_lo					<= `ZeroWord;
		mem_whilo				<= `WriteDisable;
		
		maddsub_temp_o			<= {`ZeroWord, `ZeroWord};
		div_temp_o  			<= {`ZeroWord, `ZeroWord};
		
		cnt_mult_o				<= 0;
		cnt_div_o				<= 0;
		
		mem_aluop				<= `EXE_NOP_OP;
		mem_mem_addr			<= `ZeroWord;
		mem_reg2				<= `ZeroWord;

		mem_cp0_reg_we			<= `WriteDisable;
		mem_cp0_reg_wr_addr		<= 5'b0;
		mem_cp0_reg_data		<= `ZeroWord;
		
		mem_dlyslot_now			<= `NotInDelaySlot;
		mem_current_inst_addr	<= `ZeroWord;
		mem_excepttype			<= `ZeroWord;

	end else if(stall[3] == `Stop && stall[4] == `NoStop) begin
		mem_wd					<= `NOPRegAddr;
        mem_wreg				<= `WriteDisable;
        mem_wdata				<= `ZeroWord;

		mem_hi					<= `ZeroWord;
		mem_lo					<= `ZeroWord;
		mem_whilo				<= `WriteDisable;

		maddsub_temp_o			<= maddsub_temp_i;
		div_temp_o  			<= div_temp_i;

		cnt_mult_o				<= cnt_mult_i;
		cnt_div_o				<= cnt_div_i;

		mem_aluop				<= `EXE_NOP_OP;
		mem_mem_addr			<= `ZeroWord;
		mem_reg2				<= `ZeroWord;	
		
		mem_cp0_reg_we			<= `WriteDisable;
		mem_cp0_reg_wr_addr		<= 5'b0;
		mem_cp0_reg_data		<= `ZeroWord;
		
		mem_dlyslot_now			<= `NotInDelaySlot;
		mem_current_inst_addr	<= `ZeroWord;
		mem_excepttype			<= `ZeroWord;
		
	end else if(stall[3] == `NoStop) begin
		mem_wd					<= ex_wd;
        mem_wreg				<= ex_wreg;
        mem_wdata				<= ex_wdata;

		mem_hi					<= ex_hi;
		mem_lo					<= ex_lo;
		mem_whilo				<= ex_whilo;
				
		maddsub_temp_o			<= maddsub_temp_i; /* Use for last one, send `Zeroword from ex.v ,
													you can also write `ZeroWord directly here	*/
		div_temp_o  			<= div_temp_i;  //Use for last one

		cnt_mult_o				<= 0;
		cnt_div_o				<= 0;
  
		mem_aluop				<= ex_aluop;
		mem_mem_addr			<= ex_mem_addr;
		mem_reg2				<= ex_reg2;
		
		mem_cp0_reg_we			<= ex_cp0_reg_we;
		mem_cp0_reg_wr_addr		<= ex_cp0_reg_wr_addr;
		mem_cp0_reg_data		<= ex_cp0_reg_data;
		
		mem_dlyslot_now			<= ex_dlyslot_now;
		mem_current_inst_addr	<= ex_current_inst_addr;
		mem_excepttype			<= ex_excepttype;
		
	end
end

endmodule