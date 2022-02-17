`include	"define.v"

module wishbone_buf_if(
	input					clk,
	input					rst,
	
	input			[5:0]	stall_i,
	input					flush_i,
	
	input					cpu_ce_i,
	input		[`RegBus]	cpu_data_i,
	input		[`RegBus]	cpu_addr_i,
	input					cpu_we_i,
	input			[3:0]	cpu_sel_i,
	output reg	[`RegBus]	cpu_data_o,
	
	//--------------------------------------
	input		[`RegBus]	wishbone_data_i,
	input					wishbone_ack_i,
	output reg	[`RegBus]	wishbone_addr_o,
	output reg	[`RegBus]	wishbone_data_o,
	output reg				wishbone_we_o,
	output reg		[3:0]	wishbone_sel_o,
	output reg				wishbone_stb_o,
	output reg				wishbone_cyc_o,
	
	output reg				stallreq
	);
	
	reg				[1:0]	cuerrent_state;
	reg				[1:0]	next_state;
	reg			[`RegBus]	rd_buf;



//####################################################################################
always @(posedge clk) begin
	if(rst == `RstEnable)
		cuerrent_state <= `WB_IDLE;
	else
		cuerrent_state <= next_state;
end

always @(*) begin
	case(cuerrent_state)
		`WB_IDLE: begin
			if(cpu_ce_i == 1'b1  &&  flush_i == `False_v)
				next_state = `WB_BUSY;
			else
				next_state = `WB_IDLE;
		end 
		`WB_BUSY: begin
			if(wishbone_ack_i == 1'b1) begin
				if(stall_i != 6'b000000)
					next_state = `WB_WAIT_FOR_STALL;
				else
					next_state = `WB_IDLE;
			end else if(flush_i == `True_v)
				next_state = `WB_IDLE;
			else
				next_state = `WB_BUSY;
		end 
		default: begin //`WB_WAIT_FOR_STALL
			if(stall_i == 6'b000000)
				next_state = `WB_IDLE;
			else
				next_state = `WB_WAIT_FOR_STALL;
		end 
	endcase
end 


always @(posedge clk) begin
	if(rst == `RstEnable) begin
		wishbone_stb_o	<= 0;
		wishbone_cyc_o	<= 0;
		wishbone_addr_o	<= `ZeroWord;
		wishbone_data_o	<= `ZeroWord;
		wishbone_we_o	<= `WriteDisable;
		wishbone_sel_o	<= 4'b0000;
		
		rd_buf			<= `ZeroWord;
	end else begin
		case(cuerrent_state)
			`WB_IDLE: begin
				if(cpu_ce_i == 1'b1  &&  flush_i == `False_v) begin
					wishbone_stb_o	<= 1'b1;
					wishbone_cyc_o	<= 1'b1;
					wishbone_addr_o	<= cpu_addr_i;
					wishbone_data_o	<= cpu_data_i;
					wishbone_we_o	<= cpu_we_i;
					wishbone_sel_o	<= cpu_sel_i;
					
					rd_buf			<= `ZeroWord;
				end
			end
			`WB_BUSY: begin
				if(wishbone_ack_i == 1'b1) begin
					wishbone_stb_o	<= 0;
					wishbone_cyc_o	<= 0;
					wishbone_addr_o	<= `ZeroWord;
					wishbone_data_o	<= `ZeroWord;
					wishbone_we_o	<= `WriteDisable;
					wishbone_sel_o	<= 4'b0000;
					
					if(cpu_we_i == `WriteDisable)
						rd_buf		<= wishbone_data_i;
				end else if(flush_i == `True_v) begin
					wishbone_stb_o	<= 0;
					wishbone_cyc_o	<= 0;
					wishbone_addr_o	<= `ZeroWord;
					wishbone_data_o	<= `ZeroWord;
					wishbone_we_o	<= `WriteDisable;
					wishbone_sel_o	<= 4'b0000;
					
					rd_buf			<= `ZeroWord;
				end
			end
			/*default: begin //`WB_WAIT_FOR_STALL
			
				end	*/
		endcase
	end 
end


//==============================================================
always @(*) begin
	case(cuerrent_state)
		`WB_IDLE: begin
			cpu_data_o	= `ZeroWord;
			if(cpu_ce_i == 1'b1  &&  flush_i == `False_v)
				stallreq	= `Stop;
			else
				stallreq	= `NoStop;
		end
		`WB_BUSY: begin
			if(wishbone_ack_i == 1'b1) begin
				stallreq	= `NoStop;
				if(wishbone_we_o == `WriteDisable) //rd to id.v
					cpu_data_o	= wishbone_data_i;
				else //wr to data_ram.v
					cpu_data_o	= `ZeroWord;
			end else begin
				stallreq	= `Stop; //before receive wishbone_ack_i, still stall!
				cpu_data_o	= `ZeroWord;
			end
		end
		default: begin //`WB_WAIT_FOR_STALL
			stallreq	= `NoStop;
			cpu_data_o	= rd_buf;
		end 
	endcase
end 
		
		
endmodule
			
/*
此為Moore狀態機，輸入會影響輸出
一段式改三段式的方法為:
把state提出
if(XXX)的內容保持一樣複製一份跟提出的state融合，然後always@(posedge clk)改成always@(*)
第三段就是CS <= NS

而二段式就是output用always@(*)，再加一段CS <= NS
但是因為output用組合邏輯，相當於:
			 ---------
	input----|	AND	 |---output
	state----|	 閘  |
			 ---------
假如state和input都是由前面的clk敲出來的訊號，input從1變成0，input從0變成1，
output就會有毛刺，所以不推薦使用
*/		