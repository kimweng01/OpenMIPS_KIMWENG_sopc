`include	"define.v"

`timescale 1ns/1ps

module OpenMIPS_sopc_tb();
	reg				CLOCK_50;
	reg				rst;
	
	reg		[5:0]	int_i;
	wire			timer_int_o;
	
	
initial begin
	CLOCK_50 = 0;
	forever #10 CLOCK_50 = ~CLOCK_50;
end

initial begin
	rst = `RstEnable;
	#195 rst = `RstDisable;
	#50000 $stop;
end

OpenMIPS_KIMWENG_sopc OpenMIPS_KIMWENG_sopc0(
	.clk			(CLOCK_50),
	.rst			(rst)
	
	.uart_in
	.uart_out
	
	.gpio_i
	.gpio_o
	
	.flash_data_i
	.flash_addr_o
	.flash_we_o
	.flash_rst_o
	.flash_oe_o
	.flash_ce_o
	
	.sdr_clk_o
	.sdr_cs_n_o
	.sdr_cke_o
	.sdr_ras_n_o
	.sdr_cas_n_o
	.sdr_we_n_o
	.sdr_dqm_o
	.sdr_ba_o
	.sdr_addr_o
	.sdr_dq_io
	);
	
endmodule