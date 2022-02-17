`include	"define.v"

`timescale 1ns/1ps

module OpenMIPS_KIMWENG_sopc_tb();
	reg				CLOCK_50;
	reg				rst;
	
	reg				uart_in;	
	wire			uart_out;    
	            
	            
	reg		[15:0]	gpio_i;      
	wire	[31:0]	gpio_o;      
	            
	            
	reg		[7:0]	flash_data_i;
	wire	[31:0]	flash_addr_o;
	wire			flash_we_o; 
	wire			flash_rst_o;
	wire			flash_oe_o; 
	wire			flash_ce_o;  
	            
	            
	wire			sdr_clk_o;  
	wire			sdr_cs_n_o;  
	wire			sdr_cke_o;  
	wire			sdr_ras_n_o;
	wire			sdr_cas_n_o; 
	wire			sdr_we_n_o;  
	wire	[3:0]	sdr_dqm_o;   
	wire	[1:0]	sdr_ba_o;    
	wire	[12:0]	sdr_addr_o;  
	wire	[31:0]	sdr_dq_io;  
	
	
	
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
	.rst			(rst),
	
	.uart_in		(uart_in),
	.uart_out       (uart_out),
	                
	                
	.gpio_i         (gpio_i),
	.gpio_o         (gpio_o),
	                
	                
	.flash_data_i   (flash_data_i),
	.flash_addr_o   (flash_addr_o),
	.flash_we_o     (flash_we_o),
	.flash_rst_o    (flash_rst_o),
	.flash_oe_o     (flash_oe_o),
	.flash_ce_o     (flash_ce_o),
	                
	                
	.sdr_clk_o      (sdr_clk_o),
	.sdr_cs_n_o     (sdr_cs_n_o),
	.sdr_cke_o      (sdr_cke_o),
	.sdr_ras_n_o    (sdr_ras_n_o),
	.sdr_cas_n_o    (sdr_cas_n_o),
	.sdr_we_n_o     (sdr_we_n_o),
	.sdr_dqm_o      (sdr_dqm_o),
	.sdr_ba_o       (sdr_ba_o),
	.sdr_addr_o     (sdr_addr_o),
	.sdr_dq_io      (sdr_dq_io)
	);
	
endmodule