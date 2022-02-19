//////////////////////////////////////////////////////////////////////
////                                                              ////
////  WISHBONE General-Purpose I/O                                ////
////                                                              ////
////  This file is part of the GPIO project                       ////
////  http://www.opencores.org/cores/gpio/                        ////
////                                                              ////
////  Description                                                 ////
////  Implementation of GPIO IP core according to                 ////
////  GPIO IP core specification document.                        ////
////                                                              ////
////  To Do:                                                      ////
////   Nothing                                                    ////
////                                                              ////
////  Author(s):                                                  ////
////      - Damjan Lampret, lampret@opencores.org                 ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2000 Authors and OPENCORES.ORG                 ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 2.1 of the License, or (at your option) any   ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE.  See the GNU Lesser General Public License for more ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from http://www.opencores.org/lgpl.shtml                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
//
// CVS Revision History
//
// $Log: not supported by cvs2svn $
// Revision 1.11  2002/03/13 20:56:28  lampret
// Removed zero padding as per Avi Shamli suggestion.
//
// Revision 1.10  2002/03/13 20:47:57  lampret
// Ports changed per Ran Aviram suggestions.
//
// Revision 1.9  2002/03/09 03:43:27  lampret
// Interrupt is asserted only when an input changes (code patch by Jacob Gorban)
//
// Revision 1.8  2002/01/14 19:06:28  lampret
// Changed registered WISHBONE outputs wb_ack_o/wb_err_o to follow WB specification.
//
// Revision 1.7  2001/12/25 17:21:21  lampret
// Fixed two typos.
//
// Revision 1.6  2001/12/25 17:12:35  lampret
// Added RGPIO_INTS.
//
// Revision 1.5  2001/12/12 20:35:53  lampret
// Fixing style.
//
// Revision 1.4  2001/12/12 07:12:58  lampret
// Fixed bug when wb_inta_o is registered (GPIO_WB_REGISTERED_OUTPUTS)
//
// Revision 1.3  2001/11/15 02:24:37  lampret
// Added GPIO_REGISTERED_WB_OUTPUTS, GPIO_REGISTERED_IO_OUTPUTS and GPIO_NO_NEGEDGE_FLOPS.
//
// Revision 1.2  2001/10/31 02:26:51  lampret
// Fixed wb_err_o.
//
// Revision 1.1  2001/09/18 18:49:07  lampret
// Changed top level ptc into gpio_top. Changed defines.v into gpio_defines.v.
//
// Revision 1.1  2001/08/21 21:39:28  lampret
// Changed directory structure, port names and drfines.
//
// Revision 1.2  2001/07/14 20:39:26  lampret
// Better configurability.
//
// Revision 1.1  2001/06/05 07:45:26  lampret
// Added initial RTL and test benches. There are still some issues with these files.
//
//

// synopsys translate_off
`include "timescale.v"
// synopsys translate_on
`include "gpio_defines.v"

module gpio_top(
	// WISHBONE Interface
	wb_clk_i, wb_rst_i, wb_cyc_i, wb_adr_i, wb_dat_i, wb_sel_i, wb_we_i, wb_stb_i,
	wb_dat_o, wb_ack_o, wb_err_o, wb_inta_o,

	// Auxiliary inputs interface
	aux_i,

	// External GPIO Interface
	ext_pad_i, clk_pad_i, ext_pad_o, ext_padoen_o
);

parameter dw = 32;
parameter aw = `GPIO_ADDRHH+1;
parameter gw = `GPIO_IOS;

//
// WISHBONE Interface
//
input			wb_clk_i;	// Clock
input			wb_rst_i;	// Reset
input			wb_cyc_i;	// cycle valid input
input 	[aw-1:0]	wb_adr_i;	// address bus inputs
input	[dw-1:0]	wb_dat_i;	// input data bus
input	[3:0]		wb_sel_i;	// byte select inputs
input			wb_we_i;	// indicates write transfer
input			wb_stb_i;	// strobe input
output	[dw-1:0]	wb_dat_o;	// output data bus
output			wb_ack_o;	// normal termination
output			wb_err_o;	// termination w/ error
output			wb_inta_o;	// Interrupt request output

// Auxiliary Inputs Interface
input	[gw-1:0]	aux_i;		// Auxiliary inputs

//
// External GPIO Interface
//
input	[gw-1:0]	ext_pad_i;	// GPIO Inputs
input			clk_pad_i;	// GPIO Eclk
output	[gw-1:0]	ext_pad_o;	// GPIO Outputs
output	[gw-1:0]	ext_padoen_o;	// GPIO output drivers enables

`ifdef GPIO_IMPLEMENTED

//
// GPIO Input Register (or no register)
//
`ifdef GPIO_RGPIO_IN
reg	[gw-1:0]	rgpio_in;	// RGPIO_IN register
`else
wire	[gw-1:0]	rgpio_in;	// No register
`endif

//
// GPIO Output Register (or no register)
//
`ifdef GPIO_RGPIO_OUT
reg	[gw-1:0]	rgpio_out;	// RGPIO_OUT register
`else
wire	[gw-1:0]	rgpio_out;	// No register
`endif

//
// GPIO Output Driver Enable Register (or no register)
//
`ifdef GPIO_RGPIO_OE
reg	[gw-1:0]	rgpio_oe;	// RGPIO_OE register
`else
wire	[gw-1:0]	rgpio_oe;	// No register
`endif

//
// GPIO Interrupt Enable Register (or no register)
//
`ifdef GPIO_RGPIO_INTE
reg	[gw-1:0]	rgpio_inte;	// RGPIO_INTE register
`else
wire	[gw-1:0]	rgpio_inte;	// No register
`endif

//
// GPIO Positive edge Triggered Register (or no register)
//
`ifdef GPIO_RGPIO_PTRIG
reg	[gw-1:0]	rgpio_ptrig;	// RGPIO_PTRIG register
`else
wire	[gw-1:0]	rgpio_ptrig;	// No register
`endif

//
// GPIO Auxiliary select Register (or no register)
//
`ifdef GPIO_RGPIO_AUX
reg	[gw-1:0]	rgpio_aux;	// RGPIO_AUX register
`else
wire	[gw-1:0]	rgpio_aux;	// No register
`endif

//
// GPIO Control Register (or no register)
//
`ifdef GPIO_RGPIO_CTRL
reg	[3:0]		rgpio_ctrl;	// RGPIO_CTRL register
`else
wire	[3:0]		rgpio_ctrl;	// No register
`endif

//
// GPIO Interrupt Status Register (or no register)
//
`ifdef GPIO_RGPIO_INTS
reg	[gw-1:0]	rgpio_ints;	// RGPIO_INTS register
`else
wire	[gw-1:0]	rgpio_ints;	// No register
`endif

//
// Internal wires & regs
//
wire			rgpio_out_sel;	// RGPIO_OUT select
wire			rgpio_oe_sel;	// RGPIO_OE select
wire			rgpio_inte_sel;	// RGPIO_INTE select
wire			rgpio_ptrig_sel;// RGPIO_PTRIG select
wire			rgpio_aux_sel;	// RGPIO_AUX select
wire			rgpio_ctrl_sel;	// RGPIO_CTRL select
wire			rgpio_ints_sel;	// RGPIO_INTS select
wire			latch_clk;	// Latch clock
wire			full_decoding;	// Full address decoding qualification
wire	[gw-1:0]	in_muxed;	// Muxed inputs
wire			wb_ack;		// WB Acknowledge
wire			wb_err;		// WB Error
wire			wb_inta;	// WB Interrupt
reg	[dw-1:0]	wb_dat;		// WB Data out
`ifdef GPIO_REGISTERED_WB_OUTPUTS
reg			wb_ack_o;	// WB Acknowledge
reg			wb_err_o;	// WB Error
reg			wb_inta_o;	// WB Interrupt
reg	[dw-1:0]	wb_dat_o;	// WB Data out
`endif
wire	[gw-1:0]	out_pad;	// GPIO Outputs
`ifdef GPIO_REGISTERED_IO_OUTPUTS
reg	[gw-1:0]	ext_pad_o;	// GPIO Outputs
`endif
wire	[gw-1:0]	extc_in;	// Muxed inputs sampled by external clock
wire			pext_clk;	// External clock for posedge flops
reg	[gw-1:0]	pextc_sampled;	// Posedge external clock sampled inputs
`ifdef GPIO_NO_NEGEDGE_FLOPS
`else
reg	[gw-1:0]	nextc_sampled;	// Negedge external clock sampled inputs
`endif

//
// All WISHBONE transfer terminations are successful except when:
// a) full address decoding is enabled and address doesn't match
//    any of the GPIO registers
// b) wb_sel_i evaluation is enabled and one of the wb_sel_i inputs is zero
//

//
// WB Acknowledge
//
assign wb_ack = wb_cyc_i & wb_stb_i & !wb_err_o;

//
// Optional registration of WB Ack
//
`ifdef GPIO_REGISTERED_WB_OUTPUTS
always @(posedge wb_clk_i or posedge wb_rst_i)
	if (wb_rst_i)
		wb_ack_o <= #1 1'b0;
	else
		wb_ack_o <= #1 wb_ack & ~wb_ack_o;
`else
assign wb_ack_o = wb_ack;
`endif

//
// WB Error
//
`ifdef GPIO_FULL_DECODE
`ifdef GPIO_STRICT_32BIT_ACCESS
assign wb_err = wb_cyc_i & wb_stb_i & (!full_decoding | (wb_sel_i != 4'b1111));
`else
assign wb_err = wb_cyc_i & wb_stb_i & !full_decoding;
`endif
`else
`ifdef GPIO_STRICT_32BIT_ACCESS
assign wb_err = wb_cyc_i & wb_stb_i & (wb_sel_i != 4'b1111);
`else
assign wb_err = 1'b0;
`endif
`endif

//
// Optional registration of WB error
//
`ifdef GPIO_REGISTERED_WB_OUTPUTS
always @(posedge wb_clk_i or posedge wb_rst_i)
	if (wb_rst_i)
		wb_err_o <= #1 1'b0;
	else
		wb_err_o <= #1 wb_err & ~wb_err_o;
`else
assign wb_err_o = wb_err;
`endif

//
// Full address decoder
//
`ifdef GPIO_FULL_DECODE
assign full_decoding = (wb_adr_i[`GPIO_ADDRHH:`GPIO_ADDRHL] == {`GPIO_ADDRHH-`GPIO_ADDRHL+1{1'b0}}) &
			(wb_adr_i[`GPIO_ADDRLH:`GPIO_ADDRLL] == {`GPIO_ADDRLH-`GPIO_ADDRLL+1{1'b0}});
`else
assign full_decoding = 1'b1;
`endif

//
// GPIO registers address decoder
//
assign rgpio_out_sel = wb_cyc_i & wb_stb_i & (wb_adr_i[`GPIO_OFS_BITS] == `GPIO_RGPIO_OUT) & full_decoding;
assign rgpio_oe_sel = wb_cyc_i & wb_stb_i & (wb_adr_i[`GPIO_OFS_BITS] == `GPIO_RGPIO_OE) & full_decoding;
assign rgpio_inte_sel = wb_cyc_i & wb_stb_i & (wb_adr_i[`GPIO_OFS_BITS] == `GPIO_RGPIO_INTE) & full_decoding;
assign rgpio_ptrig_sel = wb_cyc_i & wb_stb_i & (wb_adr_i[`GPIO_OFS_BITS] == `GPIO_RGPIO_PTRIG) & full_decoding;
assign rgpio_aux_sel = wb_cyc_i & wb_stb_i & (wb_adr_i[`GPIO_OFS_BITS] == `GPIO_RGPIO_AUX) & full_decoding;
assign rgpio_ctrl_sel = wb_cyc_i & wb_stb_i & (wb_adr_i[`GPIO_OFS_BITS] == `GPIO_RGPIO_CTRL) & full_decoding;
assign rgpio_ints_sel = wb_cyc_i & wb_stb_i & (wb_adr_i[`GPIO_OFS_BITS] == `GPIO_RGPIO_INTS) & full_decoding;

//
// Write to RGPIO_CTRL or update of RGPIO_CTRL[INT] bit
//
`ifdef GPIO_RGPIO_CTRL
always @(posedge wb_clk_i or posedge wb_rst_i)
	if (wb_rst_i)
		rgpio_ctrl <= #1 4'b0;
	else if (rgpio_ctrl_sel && wb_we_i)
		rgpio_ctrl <= #1 wb_dat_i[3:0];
	else if (rgpio_ctrl[`GPIO_RGPIO_CTRL_INTE])
		rgpio_ctrl[`GPIO_RGPIO_CTRL_INTS] <= #1 rgpio_ctrl[`GPIO_RGPIO_CTRL_INTS] | wb_inta_o;
`else
assign rgpio_ctrl = 4'h01;	// RGPIO_CTRL[EN] = 1
`endif

//
// Write to RGPIO_OUT
//
`ifdef GPIO_RGPIO_OUT
always @(posedge wb_clk_i or posedge wb_rst_i)
	if (wb_rst_i)
		rgpio_out <= #1 {gw{1'b0}};
	else if (rgpio_out_sel && wb_we_i)
		rgpio_out <= #1 wb_dat_i[gw-1:0];
`else
assign rgpio_out = `GPIO_DEF_RGPIO_OUT;	// RGPIO_OUT = 0x0
`endif

//
// Write to RGPIO_OE. Bits in RGPIO_OE are stored inverted.
//
`ifdef GPIO_RGPIO_OE
always @(posedge wb_clk_i or posedge wb_rst_i)
	if (wb_rst_i)
		rgpio_oe <= #1 {gw{1'b0}};
	else if (rgpio_oe_sel && wb_we_i)
		rgpio_oe <= #1 ~wb_dat_i[gw-1:0];
`else
assign rgpio_oe = `GPIO_DEF_RPGIO_OE;	// RGPIO_OE = 0x0
`endif

//
// Write to RGPIO_INTE
//
`ifdef GPIO_RGPIO_INTE
always @(posedge wb_clk_i or posedge wb_rst_i)
	if (wb_rst_i)
		rgpio_inte <= #1 {gw{1'b0}};
	else if (rgpio_inte_sel && wb_we_i)
		rgpio_inte <= #1 wb_dat_i[gw-1:0];
`else
assign rgpio_inte = `GPIO_DEF_RPGIO_INTE;	// RGPIO_INTE = 0x0
`endif

//
// Write to RGPIO_PTRIG
//
`ifdef GPIO_RGPIO_PTRIG
always @(posedge wb_clk_i or posedge wb_rst_i)
	if (wb_rst_i)
		rgpio_ptrig <= #1 {gw{1'b0}};
	else if (rgpio_ptrig_sel && wb_we_i)
		rgpio_ptrig <= #1 wb_dat_i[gw-1:0];
`else
assign rgpio_ptrig = `GPIO_DEF_RPGIO_PTRIG;	// RGPIO_PTRIG = 0x0
`endif

//
// Write to RGPIO_AUX
//
`ifdef GPIO_RGPIO_AUX
always @(posedge wb_clk_i or posedge wb_rst_i)
	if (wb_rst_i)
		rgpio_aux <= #1 {gw{1'b0}};
	else if (rgpio_aux_sel && wb_we_i)
		rgpio_aux <= #1 wb_dat_i[gw-1:0];
`else
assign rgpio_aux = `GPIO_DEF_RPGIO_AUX;	// RGPIO_AUX = 0x0
`endif

//
// Latch into RGPIO_IN
//
`ifdef GPIO_RGPIO_IN
always @(posedge wb_clk_i or posedge wb_rst_i)
	if (wb_rst_i)
		rgpio_in <= #1 {gw{1'b0}};
	else
		rgpio_in <= #1 in_muxed;
`else
assign rgpio_in = in_muxed;
`endif

//
// Mux inputs directly from input pads with inputs sampled by external clock
//
assign in_muxed = rgpio_ctrl[`GPIO_RGPIO_CTRL_ECLK] ? extc_in : ext_pad_i;

//
// Posedge pext_clk is inverted by NEC bit if negedge flops are not allowed.
// If negedge flops are allowed, pext_clk only clocks posedge flops.
//
`ifdef GPIO_NO_NEGEDGE_FLOPS
`ifdef GPIO_NO_CLKPAD_LOGIC
assign pext_clk = clk_pad_i;
`else
assign pext_clk = rgpio_ctrl[`GPIO_RGPIO_CTRL_NEC] ? ~clk_pad_i : clk_pad_i;
`endif
`else
assign pext_clk = clk_pad_i;
`endif

//
// If negedge flops are allowed, ext_in is mux of negedge and posedge external clocked flops.
//
`ifdef GPIO_NO_NEGEDGE_FLOPS
assign extc_in = pextc_sampled;
`else
assign extc_in = rgpio_ctrl[`GPIO_RGPIO_CTRL_NEC] ? nextc_sampled : pextc_sampled;
`endif

//
// Latch using posedge external clock
//
always @(posedge pext_clk or posedge wb_rst_i)
	if (wb_rst_i)
		pextc_sampled <= #1 {gw{1'b0}};
	else
		pextc_sampled <= #1 ext_pad_i;

//
// Latch using negedge external clock
//
`ifdef GPIO_NO_NEGEDGE_FLOPS
`else
always @(negedge clk_pad_i or posedge wb_rst_i)
	if (wb_rst_i)
		nextc_sampled <= #1 {gw{1'b0}};
	else
		nextc_sampled <= #1 ext_pad_i;
`endif

//
// Mux all registers when doing a read of GPIO registers
//
always @(wb_adr_i or rgpio_in or rgpio_out or rgpio_oe or rgpio_inte or
		rgpio_ptrig or rgpio_aux or rgpio_ctrl or rgpio_ints)
	case (wb_adr_i[`GPIO_OFS_BITS])	// synopsys full_case parallel_case
`ifdef GPIO_READREGS
		`GPIO_RGPIO_OUT: begin
			wb_dat[dw-1:0] = rgpio_out;
		end
		`GPIO_RGPIO_OE: begin
			wb_dat[dw-1:0] = ~rgpio_oe;
		end
		`GPIO_RGPIO_INTE: begin
			wb_dat[dw-1:0] = rgpio_inte;
		end
		`GPIO_RGPIO_PTRIG: begin
			wb_dat[dw-1:0] = rgpio_ptrig;
		end
		`GPIO_RGPIO_AUX: begin
			wb_dat[dw-1:0] = rgpio_aux;
		end
		`GPIO_RGPIO_CTRL: begin
			wb_dat[3:0] = rgpio_ctrl;
			wb_dat[dw-1:4] = {dw-4{1'b0}};
		end
`endif
		`GPIO_RGPIO_INTS: begin
			wb_dat[dw-1:0] = rgpio_ints;
		end
		default: begin
			wb_dat[dw-1:0] = rgpio_in;
		end
	endcase

//
// WB data output
//
`ifdef GPIO_REGISTERED_WB_OUTPUTS
always @(posedge wb_clk_i or posedge wb_rst_i)
	if (wb_rst_i)
		wb_dat_o <= #1 {dw{1'b0}};
	else
		wb_dat_o <= #1 wb_dat;
`else
assign wb_dat_o = wb_dat;
`endif

//
// RGPIO_INTS
//
`ifdef GPIO_RGPIO_INTS
always @(posedge wb_clk_i or posedge wb_rst_i)
	if (wb_rst_i)
		rgpio_ints <= #1 {gw{1'b0}};
	else if (rgpio_ints_sel && wb_we_i)
		rgpio_ints <= #1 wb_dat_i[gw-1:0];
	else if (rgpio_ctrl[`GPIO_RGPIO_CTRL_INTE] && rgpio_in != ext_pad_i)
		rgpio_ints <= #1 (rgpio_ints | (ext_pad_i ^ ~rgpio_ptrig) & rgpio_inte);
`else
assign rgpio_ints = (ext_pad_i ^ ~rgpio_ptrig) & rgpio_inte;
`endif

//
// Generate interrupt request
//
assign wb_inta = |rgpio_ints ? rgpio_ctrl[`GPIO_RGPIO_CTRL_INTE] : 1'b0;

//
// Optional registration of WB interrupt
//
`ifdef GPIO_REGISTERED_WB_OUTPUTS
always @(posedge wb_clk_i or posedge wb_rst_i)
	if (wb_rst_i)
		wb_inta_o <= #1 1'b0;
	else
		wb_inta_o <= #1 wb_inta;
`else
assign wb_inta_o = wb_inta;
`endif

//
// Output enables are RGPIO_OE bits
//
assign ext_padoen_o = rgpio_oe;

//
// Generate GPIO outputs
//
assign out_pad = rgpio_out & ~rgpio_aux | aux_i & rgpio_aux;

//
// Optional registration of GPIO outputs
//
`ifdef GPIO_REGISTERED_IO_OUTPUTS
always @(posedge wb_clk_i or posedge wb_rst_i)
	if (wb_rst_i)
		ext_pad_o <= #1 {gw{1'b0}};
	else
		ext_pad_o <= #1 out_pad;
`else
assign ext_pad_o = out_pad;
`endif

`else

//
// When GPIO is not implemented, drive all outputs as would when RGPIO_CTRL
// is cleared and WISHBONE transfers complete with errors
//
assign wb_inta_o = 1'b0;
assign wb_ack_o = 1'b0;
assign wb_err_o = wb_cyc_i & wb_stb_i;
assign ext_padoen_o = {gw{1'b1}};
assign ext_pad_o = {gw{1'b0}};

//
// Read GPIO registers
//
assign wb_dat_o = {dw{1'b0}};

`endif

endmodule
