`include	"define.v"

module flash_top(

	//wishbone
	wb_clk_i, wb_rst_i, wb_adr_i, wb_dat_o,
	wb_dat_i, wb_sel_i, wb_we_i, wb_stb_i,
	wb_cyc_i, wb_ack_o,
	
	//flash
	flash_adr_o, flash_dat_i, flash_rst,
	flash_oe, flash_ce, flash_we
);


input					wb_clk_i;
input					wb_rst_i;
input		[31:0]		wb_adr_i;
output reg	[31:0]		wb_dat_o;
input		[31:0]		wb_dat_i;
input		[3:0]		wb_sel_i;
input					wb_we_i;
input					wb_stb_i;
input					wb_cyc_i;
output reg				wb_ack_o;

output reg	[31:0]		flash_adr_o;
input		[7:0]		flash_dat_i;
output					flash_rst;
output					flash_oe;
output					flash_ce;
output					flash_we;

reg			[4:0]		waitstate;
wire		[1:0]		adr_low;

wire					wb_acc	= wb_cyc_i & wb_stb_i;
wire					wb_rd	= wb_acc & !wb_we_i;



//#############################################################################
/*
wb_rst_i = 1	==> state = 0;
wb_acc = 0		==> state = 0;

wb_rst_i = 0	and		wb_acc = 0	
==>	waitstate += 4'h1, save to wb_dat_o per 3 second

until waitstate = 4'hc 
==> wb_ack_o = 1

next clk(waitstate = 4'hd)
==> wb_ack_o = 0, waitstate	= 4'h0

*/

/*
assign flash_ce	= !wb_acc;
assign flash_oe	= !wb_rd;

assign flash_we = 1'b1;
assign flash_rst = !wb_rst_i;

always @(posedge wb_clk_i) begin
	if(wb_rst_i == 1'b1) begin //all reset
		waitstate	<= 4'h0;
		wb_ack_o	<= 1'b0; //Respond reset
	end else if(wb_acc == 1'b0) begin //wb_cyc_i and wb_stb_i disable
		waitstate	<= 4'h0;
		wb_ack_o	<= 1'b0;
		wb_dat_o	<= 32'h0000_0000;
		
	end else if(waitstate == 4'h0) begin
		wb_ack_o	<= 1'b0;
		if(wb_acc) //<------can be commented out?
			waitstate	<= waitstate + 4'h1;
		flash_adr_o	<= {10'b00_0000_0000, wb_adr_i[21:2], 2'b00};
	end else begin
		waitstate	<= waitstate + 4'h1;
		if(waitstate == 4'h3) begin
			wb_dat_o[31:24]	<= flash_dat_i;
			flash_adr_o		<= {10'b00_0000_0000, wb_adr_i[21:2], 2'b01};
		end else if(waitstate == 4'h6) begin
			wb_dat_o[23:16]	<= flash_dat_i;
			flash_adr_o		<= {10'b00_0000_0000, wb_adr_i[21:2], 2'b10};
		end else if(waitstate == 4'h9) begin
			wb_dat_o[15:8]	<= flash_dat_i;
			flash_adr_o		<= {10'b00_0000_0000, wb_adr_i[21:2], 2'b11};
		end else if(waitstate == 4'hc) begin
			wb_dat_o[7:0]	<= flash_dat_i;
			wb_ack_o		<= 1'b1; //Respond for wishbone
		end else if(waitstate == 4'hd) begin
			wb_ack_o		<= 1'b0;
			waitstate		<= 4'h0;
		end
	end
end
*/


//#############################################################################
assign flash_ce	= !wb_acc;
assign flash_oe	= !wb_rd;

assign flash_we = 1'b1;
assign flash_rst = !wb_rst_i;

always @(posedge wb_clk_i) begin
	if(wb_rst_i == 1'b1) begin //all reset
		waitstate	<= 5'd0;
		wb_ack_o	<= 1'b0; //Respond reset
	end else if(wb_acc == 1'b0) begin //wb_cyc_i and wb_stb_i disable
		waitstate	<= 5'd0;
		wb_ack_o	<= 1'b0;
		wb_dat_o	<= 32'h0000_0000;
		
	end else if(waitstate == 5'd0) begin
		wb_ack_o	<= 1'b0; //<------can be commented out?
		if(wb_acc) 
			waitstate	<= waitstate + 1'b1;
		flash_adr_o	<= {9'b0_0000_0000, wb_adr_i[22:2], 2'b00};
	end else begin
		waitstate	<= waitstate + 1'b1;
		if(waitstate == 5'd6) begin
			wb_dat_o[31:24]	<= flash_dat_i;
			flash_adr_o		<= {9'b0_0000_0000, wb_adr_i[22:2], 2'b01};
		end else if(waitstate == 5'd12) begin
			wb_dat_o[23:16]	<= flash_dat_i;
			flash_adr_o		<= {9'b0_0000_0000, wb_adr_i[22:2], 2'b10};
		end else if(waitstate == 5'd18) begin
			wb_dat_o[15:8]	<= flash_dat_i;
			flash_adr_o		<= {9'b0_0000_0000, wb_adr_i[22:2], 2'b11};
		end else if(waitstate == 5'd24) begin
			wb_dat_o[7:0]	<= flash_dat_i;
			wb_ack_o		<= 1'b1; //Respond for wishbone
		end else if(waitstate == 5'd25) begin
			wb_ack_o		<= 1'b0;
			waitstate		<= 5'd0;
		end
	end
end


endmodule
					