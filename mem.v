`include	"define.v"

module mem(
	//input						rst,

	input		[`RegAddrBus]	wd_i,
	input						wreg_i,
	input		[`RegBus]		wdata_i,
	
	input		[`RegBus]		hi_i,
	input		[`RegBus]		lo_i,
	input						whilo_i,
	
	input		[`AluOpBus]		aluop_i,
	input		[`RegBus]		mem_addr_i,
	input		[`RegBus]		reg2_i,
	
	input		[`RegBus]		mem_data_i,
	
	input						LLbit_i,
	input						wb_LLbit_we_i,
	input						wb_LLbit_value_i,
	
	input						wb_cp0_reg_we_i,
	input		[4:0]			wb_cp0_reg_wr_addr_i,
	input		[`RegBus]		wb_cp0_reg_data_i,
	
	input		[`RegBus]		cp0_status_i,
	input		[`RegBus]		cp0_cause_i,
	input		[`RegBus]		cp0_epc_i,
	
	input						cp0_reg_we_i,
	input		[4:0]			cp0_reg_wr_addr_i,
	input		[`RegBus]		cp0_reg_data_i,
	
	input						dlyslot_now_i,
	input		[`RegBus]		current_inst_addr_i,
	input		[`RegBus]		excepttype_i,
	
	//========================================
	output reg	[`RegAddrBus]	wd_o,
	output reg					wreg_o,
	output reg	[`RegBus]		wdata_o,
	
	output reg	[`RegBus]		hi_o,
	output reg	[`RegBus]		lo_o,
	output reg					whilo_o,
	
	output reg	[`RegBus]		mem_addr_o,
	output 						mem_we_o,
	output reg	[3:0]			mem_sel_o,
	output reg	[`RegBus]		mem_data_o,
	output reg					mem_ce_o,
	
	output reg					LLbit_we_o,
	output reg					LLbit_value_o,
	
	output reg					cp0_reg_we_o,
	output reg	[4:0]			cp0_reg_wr_addr_o,
	output reg	[`RegBus]		cp0_reg_data_o,
	
	output 						dlyslot_now_o,
	output reg	[`RegBus]		excepttype_o,
	output 		[`RegBus]		current_inst_addr_o,
	
	output reg	[`RegBus]		cp0_epc_o
	);
	
	
	wire		[`RegBus]		zero32;
	reg							mem_we;
	
	reg							LLbit;
	
	
	reg			[`RegBus]		cp0_status;
	reg			[`RegBus]		cp0_cause;
	//reg			[`RegBus]		cp0_epc;
	
	
	
assign zero32 = `ZeroWord;

always @(*) begin
	if(wb_LLbit_we_i)
		LLbit = wb_LLbit_value_i; //dependent
	else
		LLbit = LLbit_i;
end


always @(*) begin
	wd_o				= wd_i;
	wreg_o				= wreg_i;
	//wdata_o			= wdata_i;
	
	hi_o				= hi_i;
	lo_o 				= lo_i;
	whilo_o				= whilo_i;
	
	cp0_reg_we_o		= cp0_reg_we_i;		
	cp0_reg_wr_addr_o   = cp0_reg_wr_addr_i;
	cp0_reg_data_o      = cp0_reg_data_i;
end


always @(*) begin
/*	wd_o	= wd_i;
	wreg_o	= wreg_i;
	wdata_o = wdata_i;
	
	hi_o	= hi_i;
	lo_o 	= lo_i;
	whilo_o	= whilo_i;	*/
	
	case(aluop_i) //segment read, maintain write
		`EXE_LB_OP: begin
			mem_addr_o	= mem_addr_i;
			mem_we  	= `WriteDisable;
			mem_ce_o	= `ChipEnable;
			
			LLbit_we_o		= 0;
			LLbit_value_o	= 0;
			
			mem_data_o	= `ZeroWord;
			case(mem_addr_i[1:0])
				2'b00: begin
					wdata_o		= { {24{mem_data_i[31]}}, mem_data_i[31:24] }; //sign extend
					mem_sel_o	= 4'b1000; //useless, just mark
				end
				2'b01: begin
					wdata_o		= { {24{mem_data_i[23]}}, mem_data_i[23:16] };
					mem_sel_o	= 4'b0100;
				end
				2'b10: begin
					wdata_o		= { {24{mem_data_i[15]}}, mem_data_i[15:8] };
					mem_sel_o	= 4'b0010;
				end
				default: begin //2'b11
					wdata_o		= { {24{mem_data_i[7]}}, mem_data_i[7:0] };
					mem_sel_o	= 4'b0001;
				end
			endcase
		end
		`EXE_LBU_OP: begin
			mem_addr_o	= mem_addr_i;
			mem_we  	= `WriteDisable;
			mem_ce_o	= `ChipEnable;
			
			LLbit_we_o		= 0;
			LLbit_value_o	= 0;
			
			mem_data_o	= `ZeroWord;
			case(mem_addr_i[1:0])
				2'b00: begin
					wdata_o		= { {24{1'b0}}, mem_data_i[31:24] }; //unsign extend
					mem_sel_o	= 4'b1000;
				end
				2'b01: begin
					wdata_o		= { {24{1'b0}}, mem_data_i[23:16] };
					mem_sel_o	= 4'b0100;
				end
				2'b10: begin
					wdata_o		= { {24{1'b0}}, mem_data_i[15:8] };
					mem_sel_o	= 4'b0010;
				end
				default: begin //2'b11
					wdata_o		= { {24{1'b0}}, mem_data_i[7:0] };
					mem_sel_o	= 4'b0001;
				end
			endcase
		end
		`EXE_LH_OP: begin
			mem_addr_o	= mem_addr_i;
			mem_we  	= `WriteDisable;
			mem_ce_o	= `ChipEnable;
			
			LLbit_we_o		= 0;
			LLbit_value_o	= 0;
			
			mem_data_o	= `ZeroWord;
			case(mem_addr_i[1:0])
				2'b00: begin
					wdata_o		= { {16{mem_data_i[31]}}, mem_data_i[31:16] };
					mem_sel_o	= 4'b1100;
				end
				2'b10: begin
					wdata_o		= { {16{mem_data_i[15]}}, mem_data_i[15:0] };
					mem_sel_o	= 4'b0011;
				end
				default: begin
					wdata_o		= `ZeroWord;
					mem_sel_o	= 4'b0000;
				end
			endcase
		end
		`EXE_LHU_OP: begin
			mem_addr_o	= mem_addr_i;
			mem_we  	= `WriteDisable;
			mem_ce_o	= `ChipEnable;
			
			LLbit_we_o		= 0;
			LLbit_value_o	= 0;
			
			mem_data_o	= `ZeroWord;
			case(mem_addr_i[1:0])
				2'b00: begin
					wdata_o		= { {16{1'b0}}, mem_data_i[31:16] };
					mem_sel_o	= 4'b1100;
				end
				2'b10: begin
					wdata_o		= { {16{1'b0}}, mem_data_i[15:0] };
					mem_sel_o	= 4'b0011;
				end
				default: begin
					wdata_o		= `ZeroWord;
					mem_sel_o	= 4'b0000;
				end
			endcase
		end
		`EXE_LW_OP: begin
			mem_addr_o	= mem_addr_i;
			mem_we  	= `WriteDisable;
			mem_ce_o	= `ChipEnable;
			mem_sel_o	= 4'b1111;
			
			LLbit_we_o		= 0;
			LLbit_value_o	= 0;
			
			mem_data_o	= `ZeroWord;
			case(mem_addr_i[1:0])
				2'b00: begin
					wdata_o		= mem_data_i;
					mem_sel_o	= 4'b1111;
				end
				default: begin //2'b11
					wdata_o		= `ZeroWord;
					mem_sel_o 	= 4'b0000;
				end
			endcase
		end
		`EXE_LWL_OP: begin
			mem_addr_o	= {mem_addr_i[31:2], 2'b00}; //not requires alignment, need to load two zeros.
			mem_we  	= `WriteDisable;
			mem_ce_o	= `ChipEnable;
			mem_sel_o	= 4'b1111;
			
			LLbit_we_o		= 0;
			LLbit_value_o	= 0;
			
			mem_data_o	= `ZeroWord;
			case(mem_addr_i[1:0])
				2'b00:	wdata_o = mem_data_i;
				2'b01: 	wdata_o = {mem_data_i[23:0], reg2_i[7:0]};
				2'b10:	wdata_o = {mem_data_i[15:0], reg2_i[15:0]};
				default:wdata_o = {mem_data_i[7:0], reg2_i[23:0]};
			endcase
		end
		`EXE_LWR_OP: begin
			mem_addr_o	= mem_addr_i;
			mem_we  	= `WriteDisable;
			mem_ce_o	= `ChipEnable;
			mem_sel_o	= 4'b1111;
			
			LLbit_we_o		= 0;
			LLbit_value_o	= 0;
			
			mem_data_o	= `ZeroWord;
			case(mem_addr_i[1:0])
				2'b00:	wdata_o = {reg2_i[31:8], mem_data_i[31:24]};
				2'b01: 	wdata_o = {reg2_i[31:16], mem_data_i[31:16]};
				2'b10:	wdata_o = {reg2_i[31:24], mem_data_i[31:8]}; 
				default:wdata_o = mem_data_i;
			endcase
		end
		`EXE_SB_OP: begin
			mem_addr_o	= mem_addr_i;
			mem_we  	= `WriteEnable;
			mem_ce_o	= `ChipEnable;
			
			LLbit_we_o		= 0;
			LLbit_value_o	= 0;
			
			mem_data_o	= {reg2_i[7:0], reg2_i[7:0], reg2_i[7:0], reg2_i[7:0]};
			wdata_o		= `ZeroWord;
			case(mem_addr_i[1:0])
				2'b00: mem_sel_o	= 4'b1000;
				2'b01: mem_sel_o	= 4'b0100;
				2'b10: mem_sel_o	= 4'b0010;
				default: mem_sel_o	= 4'b0001;
			endcase
		end
		`EXE_SH_OP: begin
			mem_addr_o	= mem_addr_i;
			mem_we  	= `WriteEnable;
			mem_ce_o	= `ChipEnable;
			
			LLbit_we_o		= 0;
			LLbit_value_o	= 0;
			
			mem_data_o	= {reg2_i[15:0], reg2_i[15:0]};
			wdata_o		= `ZeroWord;
			case(mem_addr_i[1:0])
				2'b00: mem_sel_o	= 4'b1100;
				2'b10: mem_sel_o	= 4'b0011;
				default: mem_sel_o	= 4'b0000;
			endcase
		end
		`EXE_SW_OP: begin
			mem_addr_o	= mem_addr_i;
			mem_we  	= `WriteEnable;
			mem_ce_o	= `ChipEnable;
			
			LLbit_we_o		= 0;
			LLbit_value_o	= 0;
			
			mem_data_o	= reg2_i;
			wdata_o		= `ZeroWord;
			case(mem_addr_i[1:0])
				2'b00: mem_sel_o	= 4'b1111;
				default: mem_sel_o	= 4'b0000;
			endcase
		end
		`EXE_SWL_OP: begin
			mem_addr_o	= mem_addr_i;
			mem_we  	= `WriteEnable;
			mem_ce_o	= `ChipEnable;
			
			LLbit_we_o		= 0;
			LLbit_value_o	= 0;	
			
			wdata_o		= `ZeroWord;
			case(mem_addr_i[1:0])
				2'b00: begin
					mem_data_o	= reg2_i;
					mem_sel_o	= 4'b1111;
				end
				2'b01: begin
					mem_data_o	= {zero32[7:0], reg2_i[31:8]}; //zero32 useless
					mem_sel_o	= 4'b0111;
				end
				2'b10: begin
					mem_data_o	= {zero32[15:0], reg2_i[31:16]};
					mem_sel_o	= 4'b0011;
				end
				default: begin //2'b11
					mem_data_o	= {zero32[23:0], reg2_i[31:24]};
					mem_sel_o	= 4'b0001;
				end
			endcase
		end
		`EXE_SWR_OP: begin
			mem_addr_o	= mem_addr_i;
			mem_we  	= `WriteEnable;
			mem_ce_o	= `ChipEnable;
			
			LLbit_we_o		= 0;
			LLbit_value_o	= 0;	
			
			wdata_o		= `ZeroWord;
			case(mem_addr_i[1:0])
				2'b00: begin
					mem_data_o	= {reg2_i[7:0], zero32[23:0]};
					mem_sel_o	= 4'b1000;
				end
				2'b01: begin
					mem_data_o	= {reg2_i[15:0], zero32[15:0]};
					mem_sel_o	= 4'b1100;
				end
				2'b10: begin
					mem_data_o	= {reg2_i[23:0], zero32[7:0]};
					mem_sel_o	= 4'b1110;
				end
				default: begin //2'b11
					mem_data_o	= reg2_i;
					mem_sel_o	= 4'b1111;
				end
			endcase
		end
		`EXE_LL_OP: begin
			mem_addr_o	= mem_addr_i;
			mem_we  	= `WriteDisable;
			mem_ce_o	= `ChipEnable;
			
			LLbit_we_o		= 1'b1;
			LLbit_value_o	= 1'b1;
			
			wdata_o		= mem_data_i;
			mem_data_o	= `ZeroWord;
			mem_sel_o	= 4'b1111;
		end
		`EXE_SC_OP: begin
			if(LLbit) begin
				mem_addr_o	= mem_addr_i;
				mem_we  	= `WriteEnable;
				mem_ce_o	= `ChipEnable;
				
				LLbit_we_o		= 1'b1;
				LLbit_value_o	= 0;
				
				wdata_o		= 32'b1;
				mem_data_o	= reg2_i;
				mem_sel_o	= 4'b1111;
			end else begin
				mem_addr_o	= mem_addr_i;
				mem_we  	= `WriteDisable;
				mem_ce_o	= `ChipDisable;
				
				LLbit_we_o		= 0;
				LLbit_value_o	= 0;
				
				wdata_o		= `ZeroWord;
				mem_data_o	= `ZeroWord;
				mem_sel_o	= 4'b0000;
			end
		end
		default: begin //other inst
			mem_addr_o	= mem_addr_i;
			mem_we  	= `WriteDisable;
			mem_ce_o	= `ChipDisable;
			
			LLbit_we_o		= 0;
			LLbit_value_o	= 0;
			
			wdata_o		= wdata_i;
			mem_data_o	= `ZeroWord;
			mem_sel_o	= 4'b0000;
		end
	endcase
end


//===========================================================================
assign dlyslot_now_o 		= dlyslot_now_i;
assign current_inst_addr_o 	= current_inst_addr_i;

//-----------------------------------------------
always @(*) begin
	if(wb_cp0_reg_we_i == `WriteEnable  &&  wb_cp0_reg_wr_addr_i == `CP0_REG_STATUS)
		cp0_status = wb_cp0_reg_data_i;
	else  
		cp0_status = cp0_status_i;
end

always @(*) begin
	if(wb_cp0_reg_we_i == `WriteEnable  &&  wb_cp0_reg_wr_addr_i == `CP0_REG_CAUSE) begin
		cp0_cause[7:0]		= cp0_cause_i[7:0];
		cp0_cause[9:8]		= wb_cp0_reg_data_i[9:8];
		cp0_cause[21:10]	= cp0_cause_i[21:10];
		cp0_cause[22] 		= wb_cp0_reg_data_i[22];
		cp0_cause[23] 		= wb_cp0_reg_data_i[23];
		cp0_cause[31:24]	= cp0_cause_i[31:24];
	end else  
		cp0_cause = cp0_cause_i;
end 

//++++++++++++++++++++++
always @(*) begin
	if(wb_cp0_reg_we_i == `WriteEnable  &&  wb_cp0_reg_wr_addr_i == `CP0_REG_EPC)
		cp0_epc_o = wb_cp0_reg_data_i;
	else  
		cp0_epc_o = cp0_epc_i;
end 

//------------------------------------------------------
always @(*) begin
	excepttype_o = `ZeroWord;
	if(current_inst_addr_i != `ZeroWord) begin //wait for new first inst, see textbook 11-40(2)!
		if( (cp0_cause[15:8] & cp0_status[15:8]) != 0  &&
			cp0_status[1] == 1'b0  &&
			cp0_status[0] == 1'b1 ) 
			excepttype_o = 32'h00000001;
		else if(excepttype_i[8])
			excepttype_o = 32'h00000008;
		else if(excepttype_i[9])
			excepttype_o = 32'h0000000a;
		else if(excepttype_i[10])
			excepttype_o = 32'h0000000d;
		else if(excepttype_i[11])
			excepttype_o = 32'h0000000c;
		else if(excepttype_i[12])
			excepttype_o = 32'h0000000e;
	end 
end 
	
assign mem_we_o = mem_we & ( ~(|excepttype_o) ); //if excepttype_i has a "one", cancel the mem_we

	
endmodule