`include	"define.v"

module cp0_reg(
	input					clk,
	input					rst,
	
	input					we_i,
	input		[4:0]		waddr_i,
	input		[4:0]		raddr_i,
	input		[`RegBus]	data_i,
	
	input		[5:0]		int_i,
	
	input					dlyslot_now_i,
	input		[`RegBus]	current_inst_addr_i,
	input		[`RegBus]	excepttype_i,
	
	//========================================================================
	output reg	[`RegBus] 	data_o,
	//output reg	[`RegBus]	count_o,
	//output reg	[`RegBus]	compare_o,
	output reg	[`RegBus]	status_o,
	output reg	[`RegBus]	cause_o,
	output reg	[`RegBus]	epc_o,
	//output reg	[`RegBus]	config_o,
	//output reg	[`RegBus]	prid_o,
	
	output reg				timer_int_o
	);
	
	
	reg			[`RegBus]	count_o;
	reg			[`RegBus]	compare_o;
	reg			[`RegBus]	config_o;
	reg			[`RegBus]	prid_o;
	


//##############################################################################################
always @(posedge clk) begin //WR
	if(rst == `RstEnable) begin
		count_o 	<= `ZeroWord;
		compare_o	<= `ZeroWord;
		status_o 	<= 32'b0001_0000_0000_0000_0000_0000_0000_0000;
		cause_o 	<= `ZeroWord;
		epc_o 		<= `ZeroWord;
		config_o 	<= 32'b0000_0000_0000_0000_1000_0000_0000_0000;
		prid_o 		<= 32'b00000000_01001011_0000000100_000010; //K
		
		timer_int_o <= `InterruptNotAssert;
	
	end else begin
		count_o			<= count_o + 1'b1;
		cause_o[15:10]	<= int_i;
		
		if(compare_o != `ZeroWord  &&  count_o == compare_o)
			timer_int_o <= `InterruptAssert;
		
		if(we_i == `WriteEnable) begin
			case(waddr_i)
				`CP0_REG_COUNT: 	
					count_o		<= data_i;
				`CP0_REG_COMPARE: begin
					compare_o	<= data_i;
					timer_int_o <= `InterruptNotAssert;
				end 
				`CP0_REG_STATUS:	
					status_o	<= data_i;
				`CP0_REG_EPC: 		
					epc_o		<= data_i;
				`CP0_REG_CAUSE: begin
					cause_o[9:8]<= data_i[9:8];
					cause_o[23]	<= data_i[23];
					cause_o[22]	<= data_i[22];
				end 
			endcase
		end
		
		case(excepttype_i)
			32'h00000001: begin //interrupt
				status_o[1]		<= 1'b1;				
				cause_o[6:2]	<= 5'b00000;
				//if(status_o[1] == 1'b0) begin 
					if(dlyslot_now_i == `InDelaySlot) begin
						epc_o		<= current_inst_addr_i - 4'h4;
						cause_o[31]	<= 1'b1; //BD
					end else begin
						epc_o		<= current_inst_addr_i;
						cause_o[31]	<= 0; //BD
					end
				//end 
				/*	interrupt can't always be used when status_o[1] == 1'b1,
					so you need not to write: if(status_o[1] == 1'b0)	*/
			end 
			32'h00000008: begin //syscall
				status_o[1]		<= 1'b1;				
				cause_o[6:2]	<= 5'b01000;
				if(status_o[1] == 1'b0) begin 
					if(dlyslot_now_i == `InDelaySlot) begin
						epc_o		<= current_inst_addr_i - 4'h4;
						cause_o[31]	<= 1'b1; //BD
					end else begin
						epc_o		<= current_inst_addr_i;
						cause_o[31]	<= 0; //BD
					end
				end 
			end 
			32'h0000000a: begin //inst_invalid
				status_o[1]		<= 1'b1;				
				cause_o[6:2]	<= 5'b01010;
				if(status_o[1] == 1'b0) begin 
					if(dlyslot_now_i == `InDelaySlot) begin
						epc_o		<= current_inst_addr_i - 4'h4;
						cause_o[31]	<= 1'b1; //BD
					end else begin
						epc_o		<= current_inst_addr_i;
						cause_o[31]	<= 0; //BD
					end
				end 
			end
			32'h0000000d: begin //trap
				status_o[1]		<= 1'b1;				
				cause_o[6:2]	<= 5'b01101;
				if(status_o[1] == 1'b0) begin 
					if(dlyslot_now_i == `InDelaySlot) begin
						epc_o		<= current_inst_addr_i - 4'h4;
						cause_o[31]	<= 1'b1; //BD
					end else begin
						epc_o		<= current_inst_addr_i;
						cause_o[31]	<= 0; //BD
					end
				end 
			end 
			32'h0000000c: begin //ov
				status_o[1]		<= 1'b1;				
				cause_o[6:2]	<= 5'b01100;
				if(status_o[1] == 1'b0) begin 
					if(dlyslot_now_i == `InDelaySlot) begin
						epc_o		<= current_inst_addr_i - 4'h4;
						cause_o[31]	<= 1'b1; //BD
					end else begin
						epc_o		<= current_inst_addr_i;
						cause_o[31]	<= 0; //BD
					end
				end 
			end 
			
			32'h0000000e: 		//eret
				status_o[1]		<= 0;
			
			default: begin
			end 

		endcase
	end 
end 


//=====================================================================
always @(*) begin //RD
	case(raddr_i)
		`CP0_REG_COUNT: 	
			data_o		= count_o;
		`CP0_REG_COMPARE:
			data_o		= compare_o;
		`CP0_REG_STATUS:	
			data_o		= status_o;
		`CP0_REG_EPC: 		
			data_o		= epc_o;
		`CP0_REG_CAUSE:
			data_o		= cause_o;
		`CP0_REG_PRId:
			data_o		= prid_o;
		`CP0_REG_CONFIG:  
			data_o		= config_o;
		default: 
			data_o		= `ZeroWord;
	endcase
end 


endmodule