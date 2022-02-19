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
// Revision 1.16  2003/12/17 13:00:52  gorand
// added ECLK and NEC registers, all tests passed.
//
// Revision 1.15  2003/11/10 23:21:22  gorand
// bug fixed. all tests passed.
//
// Revision 1.14  2003/11/06 13:59:07  gorand
// added support for 8-bit access to registers.
//
// Revision 1.13  2002/11/18 22:35:18  lampret
// Bug fix. Interrupts were also asserted when condition was not met.
//
// Revision 1.12  2002/11/11 21:36:28  lampret
// Added ifdef to remove mux from clk_pad_i if mux is not allowed. This also removes RGPIO_CTRL[NEC].
//
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
	ext_pad_i, clk_pad_i, ext_pad_o, ext_padoe_o
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
output	[gw-1:0]	ext_padoe_o;	// GPIO output drivers enables

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
reg	[1:0]		rgpio_ctrl;	// RGPIO_CTRL register
`else
wire	[1:0]		rgpio_ctrl;	// No register
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
// GPIO Enable Clock  Register (or no register)
//
`ifdef GPIO_RGPIO_ECLK
reg	[gw-1:0]	rgpio_eclk;	// RGPIO_ECLK register
`else
wire	[gw-1:0]	rgpio_eclk;	// No register
`endif

//
// GPIO Active Negative Edge  Register (or no register)
//
`ifdef GPIO_RGPIO_NEC
reg	[gw-1:0]	rgpio_nec;	// RGPIO_NEC register
`else
wire	[gw-1:0]	rgpio_nec;	// No register
`endif

//
// Internal wires & regs
//
wire      rgpio_out_sel;  // RGPIO_OUT select
wire      rgpio_oe_sel; // RGPIO_OE select
wire      rgpio_inte_sel; // RGPIO_INTE select
wire      rgpio_ptrig_sel;// RGPIO_PTRIG select
wire      rgpio_aux_sel;  // RGPIO_AUX select
wire      rgpio_ctrl_sel; // RGPIO_CTRL select
wire      rgpio_ints_sel; // RGPIO_INTS select
wire      rgpio_eclk_sel ;
wire      rgpio_nec_sel ;
wire      full_decoding;  // Full address decoding qualification
wire  [gw-1:0]  in_muxed; // Muxed inputs
wire      wb_ack;   // WB Acknowledge
wire      wb_err;   // WB Error
wire      wb_inta;  // WB Interrupt
reg [dw-1:0]  wb_dat;   // WB Data out
`ifdef GPIO_REGISTERED_WB_OUTPUTS
reg     wb_ack_o; // WB Acknowledge
reg     wb_err_o; // WB Error
reg     wb_inta_o;  // WB Interrupt
reg [dw-1:0]  wb_dat_o; // WB Data out
`endif
wire  [gw-1:0]  out_pad;  // GPIO Outputs
`ifdef GPIO_REGISTERED_IO_OUTPUTS
reg [gw-1:0]  ext_pad_o;  // GPIO Outputs
`endif
wire  [gw-1:0]  extc_in;  // Muxed inputs sampled by external clock
wire  [gw-1:0]  pext_clk; // External clock for posedge flops
reg [gw-1:0]  pextc_sampled;  // Posedge external clock sampled inputs
`ifdef GPIO_NO_NEGEDGE_FLOPS
`else
reg [gw-1:0]  nextc_sampled;  // Negedge external clock sampled inputs
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
		wb_ack_o <= #1 wb_ack & ~wb_ack_o & (!wb_err) ;
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
`ifdef GPIO_RGPIO_OUT
assign rgpio_out_sel = wb_cyc_i & wb_stb_i & (wb_adr_i[`GPIO_OFS_BITS] == `GPIO_RGPIO_OUT) & full_decoding;
`endif
`ifdef GPIO_RGPIO_OE
assign rgpio_oe_sel = wb_cyc_i & wb_stb_i & (wb_adr_i[`GPIO_OFS_BITS] == `GPIO_RGPIO_OE) & full_decoding;
`endif
`ifdef GPIO_RGPIO_INTE
assign rgpio_inte_sel = wb_cyc_i & wb_stb_i & (wb_adr_i[`GPIO_OFS_BITS] == `GPIO_RGPIO_INTE) & full_decoding;
`endif
`ifdef GPIO_RGPIO_PTRIG
assign rgpio_ptrig_sel = wb_cyc_i & wb_stb_i & (wb_adr_i[`GPIO_OFS_BITS] == `GPIO_RGPIO_PTRIG) & full_decoding;
`endif
`ifdef GPIO_RGPIO_AUX
assign rgpio_aux_sel = wb_cyc_i & wb_stb_i & (wb_adr_i[`GPIO_OFS_BITS] == `GPIO_RGPIO_AUX) & full_decoding;
`endif
`ifdef GPIO_RGPIO_CTRL
assign rgpio_ctrl_sel = wb_cyc_i & wb_stb_i & (wb_adr_i[`GPIO_OFS_BITS] == `GPIO_RGPIO_CTRL) & full_decoding;
`endif
`ifdef GPIO_RGPIO_INTS
assign rgpio_ints_sel = wb_cyc_i & wb_stb_i & (wb_adr_i[`GPIO_OFS_BITS] == `GPIO_RGPIO_INTS) & full_decoding;
`endif
`ifdef GPIO_RGPIO_ECLK
assign rgpio_eclk_sel = wb_cyc_i & wb_stb_i & (wb_adr_i[`GPIO_OFS_BITS] == `GPIO_RGPIO_ECLK) & full_decoding;
`endif
`ifdef GPIO_RGPIO_NEC
assign rgpio_nec_sel = wb_cyc_i & wb_stb_i & (wb_adr_i[`GPIO_OFS_BITS] == `GPIO_RGPIO_NEC) & full_decoding;
`endif


//
// Write to RGPIO_CTRL or update of RGPIO_CTRL[INT] bit
//
`ifdef GPIO_RGPIO_CTRL
always @(posedge wb_clk_i or posedge wb_rst_i)
	if (wb_rst_i)
		rgpio_ctrl <= #1 2'b0;
	else if (rgpio_ctrl_sel && wb_we_i)
		rgpio_ctrl <= #1 wb_dat_i[1:0];
	else if (rgpio_ctrl[`GPIO_RGPIO_CTRL_INTE])
		rgpio_ctrl[`GPIO_RGPIO_CTRL_INTS] <= #1 rgpio_ctrl[`GPIO_RGPIO_CTRL_INTS] | wb_inta_o;
`else
assign rgpio_ctrl = 2'h01;	// RGPIO_CTRL[EN] = 1
`endif

//
// Write to RGPIO_OUT
//
`ifdef GPIO_RGPIO_OUT
always @(posedge wb_clk_i or posedge wb_rst_i)
	if (wb_rst_i)
		rgpio_out <= #1 {gw{1'b0}};
	else if (rgpio_out_sel && wb_we_i)
    begin
`ifdef GPIO_STRICT_32BIT_ACCESS
		rgpio_out <= #1 wb_dat_i[gw-1:0];
`endif

`ifdef GPIO_WB_BYTES4
     if ( wb_sel_i [3] == 1'b1 )
       rgpio_out [gw-1:24] <= #1 wb_dat_i [gw-1:24] ;
     if ( wb_sel_i [2] == 1'b1 )
       rgpio_out [23:16] <= #1 wb_dat_i [23:16] ;
     if ( wb_sel_i [1] == 1'b1 )
       rgpio_out [15:8] <= #1 wb_dat_i [15:8] ;
     if ( wb_sel_i [0] == 1'b1 )
       rgpio_out [7:0] <= #1 wb_dat_i [7:0] ;
`endif
`ifdef GPIO_WB_BYTES3
     if ( wb_sel_i [2] == 1'b1 )
       rgpio_out [gw-1:16] <= #1 wb_dat_i [gw-1:16] ;
     if ( wb_sel_i [1] == 1'b1 )
       rgpio_out [15:8] <= #1 wb_dat_i [15:8] ;
     if ( wb_sel_i [0] == 1'b1 )
       rgpio_out [7:0] <= #1 wb_dat_i [7:0] ;
`endif
`ifdef GPIO_WB_BYTES2
     if ( wb_sel_i [1] == 1'b1 )
       rgpio_out [gw-1:8] <= #1 wb_dat_i [gw-1:8] ;
     if ( wb_sel_i [0] == 1'b1 )
       rgpio_out [7:0] <= #1 wb_dat_i [7:0] ;
`endif
`ifdef GPIO_WB_BYTES1
     if ( wb_sel_i [0] == 1'b1 )
       rgpio_out [gw-1:0] <= #1 wb_dat_i [gw-1:0] ;
`endif
   end

`else
assign rgpio_out = `GPIO_DEF_RGPIO_OUT;	// RGPIO_OUT = 0x0
`endif

//
// Write to RGPIO_OE.
//
`ifdef GPIO_RGPIO_OE
always @(posedge wb_clk_i or posedge wb_rst_i)
	if (wb_rst_i)
		rgpio_oe <= #1 {gw{1'b0}};
	else if (rgpio_oe_sel && wb_we_i)
  begin
`ifdef GPIO_STRICT_32BIT_ACCESS
		rgpio_oe <= #1 wb_dat_i[gw-1:0];
`endif

`ifdef GPIO_WB_BYTES4
     if ( wb_sel_i [3] == 1'b1 )
       rgpio_oe [gw-1:24] <= #1 wb_dat_i [gw-1:24] ;
     if ( wb_sel_i [2] == 1'b1 )
       rgpio_oe [23:16] <= #1 wb_dat_i [23:16] ;
     if ( wb_sel_i [1] == 1'b1 )
       rgpio_oe [15:8] <= #1 wb_dat_i [15:8] ;
     if ( wb_sel_i [0] == 1'b1 )
       rgpio_oe [7:0] <= #1 wb_dat_i [7:0] ;
`endif
`ifdef GPIO_WB_BYTES3
     if ( wb_sel_i [2] == 1'b1 )
       rgpio_oe [gw-1:16] <= #1 wb_dat_i [gw-1:16] ;
     if ( wb_sel_i [1] == 1'b1 )
       rgpio_oe [15:8] <= #1 wb_dat_i [15:8] ;
     if ( wb_sel_i [0] == 1'b1 )
       rgpio_oe [7:0] <= #1 wb_dat_i [7:0] ;
`endif
`ifdef GPIO_WB_BYTES2
     if ( wb_sel_i [1] == 1'b1 )
       rgpio_oe [gw-1:8] <= #1 wb_dat_i [gw-1:8] ;
     if ( wb_sel_i [0] == 1'b1 )
       rgpio_oe [7:0] <= #1 wb_dat_i [7:0] ;
`endif
`ifdef GPIO_WB_BYTES1
     if ( wb_sel_i [0] == 1'b1 )
       rgpio_oe [gw-1:0] <= #1 wb_dat_i [gw-1:0] ;
`endif
   end

`else
assign rgpio_oe = `GPIO_DEF_RGPIO_OE;	// RGPIO_OE = 0x0
`endif

//
// Write to RGPIO_INTE
//
`ifdef GPIO_RGPIO_INTE
always @(posedge wb_clk_i or posedge wb_rst_i)
	if (wb_rst_i)
		rgpio_inte <= #1 {gw{1'b0}};
	else if (rgpio_inte_sel && wb_we_i)
  begin
`ifdef GPIO_STRICT_32BIT_ACCESS
		rgpio_inte <= #1 wb_dat_i[gw-1:0];
`endif

`ifdef GPIO_WB_BYTES4
     if ( wb_sel_i [3] == 1'b1 )
       rgpio_inte [gw-1:24] <= #1 wb_dat_i [gw-1:24] ;
     if ( wb_sel_i [2] == 1'b1 )
       rgpio_inte [23:16] <= #1 wb_dat_i [23:16] ;
     if ( wb_sel_i [1] == 1'b1 )
       rgpio_inte [15:8] <= #1 wb_dat_i [15:8] ;
     if ( wb_sel_i [0] == 1'b1 )
       rgpio_inte [7:0] <= #1 wb_dat_i [7:0] ;
`endif
`ifdef GPIO_WB_BYTES3
     if ( wb_sel_i [2] == 1'b1 )
       rgpio_inte [gw-1:16] <= #1 wb_dat_i [gw-1:16] ;
     if ( wb_sel_i [1] == 1'b1 )
       rgpio_inte [15:8] <= #1 wb_dat_i [15:8] ;
     if ( wb_sel_i [0] == 1'b1 )
       rgpio_inte [7:0] <= #1 wb_dat_i [7:0] ;
`endif
`ifdef GPIO_WB_BYTES2
     if ( wb_sel_i [1] == 1'b1 )
       rgpio_inte [gw-1:8] <= #1 wb_dat_i [gw-1:8] ;
     if ( wb_sel_i [0] == 1'b1 )
       rgpio_inte [7:0] <= #1 wb_dat_i [7:0] ;
`endif
`ifdef GPIO_WB_BYTES1
     if ( wb_sel_i [0] == 1'b1 )
       rgpio_inte [gw-1:0] <= #1 wb_dat_i [gw-1:0] ;
`endif
   end


`else
assign rgpio_inte = `GPIO_DEF_RGPIO_INTE;	// RGPIO_INTE = 0x0
`endif

//
// Write to RGPIO_PTRIG
//
`ifdef GPIO_RGPIO_PTRIG
always @(posedge wb_clk_i or posedge wb_rst_i)
	if (wb_rst_i)
		rgpio_ptrig <= #1 {gw{1'b0}};
	else if (rgpio_ptrig_sel && wb_we_i)
  begin
`ifdef GPIO_STRICT_32BIT_ACCESS
		rgpio_ptrig <= #1 wb_dat_i[gw-1:0];
`endif

`ifdef GPIO_WB_BYTES4
     if ( wb_sel_i [3] == 1'b1 )
       rgpio_ptrig [gw-1:24] <= #1 wb_dat_i [gw-1:24] ;
     if ( wb_sel_i [2] == 1'b1 )
       rgpio_ptrig [23:16] <= #1 wb_dat_i [23:16] ;
     if ( wb_sel_i [1] == 1'b1 )
       rgpio_ptrig [15:8] <= #1 wb_dat_i [15:8] ;
     if ( wb_sel_i [0] == 1'b1 )
       rgpio_ptrig [7:0] <= #1 wb_dat_i [7:0] ;
`endif
`ifdef GPIO_WB_BYTES3
     if ( wb_sel_i [2] == 1'b1 )
       rgpio_ptrig [gw-1:16] <= #1 wb_dat_i [gw-1:16] ;
     if ( wb_sel_i [1] == 1'b1 )
       rgpio_ptrig [15:8] <= #1 wb_dat_i [15:8] ;
     if ( wb_sel_i [0] == 1'b1 )
       rgpio_ptrig [7:0] <= #1 wb_dat_i [7:0] ;
`endif
`ifdef GPIO_WB_BYTES2
     if ( wb_sel_i [1] == 1'b1 )
       rgpio_ptrig [gw-1:8] <= #1 wb_dat_i [gw-1:8] ;
     if ( wb_sel_i [0] == 1'b1 )
       rgpio_ptrig [7:0] <= #1 wb_dat_i [7:0] ;
`endif
`ifdef GPIO_WB_BYTES1
     if ( wb_sel_i [0] == 1'b1 )
       rgpio_ptrig [gw-1:0] <= #1 wb_dat_i [gw-1:0] ;
`endif
   end
    
`else
assign rgpio_ptrig = `GPIO_DEF_RGPIO_PTRIG;	// RGPIO_PTRIG = 0x0
`endif

//
// Write to RGPIO_AUX
//
`ifdef GPIO_RGPIO_AUX
always @(posedge wb_clk_i or posedge wb_rst_i)
	if (wb_rst_i)
		rgpio_aux <= #1 {gw{1'b0}};
	else if (rgpio_aux_sel && wb_we_i)
  begin
`ifdef GPIO_STRICT_32BIT_ACCESS
		rgpio_aux <= #1 wb_dat_i[gw-1:0];
`endif

`ifdef GPIO_WB_BYTES4
     if ( wb_sel_i [3] == 1'b1 )
       rgpio_aux [gw-1:24] <= #1 wb_dat_i [gw-1:24] ;
     if ( wb_sel_i [2] == 1'b1 )
       rgpio_aux [23:16] <= #1 wb_dat_i [23:16] ;
     if ( wb_sel_i [1] == 1'b1 )
       rgpio_aux [15:8] <= #1 wb_dat_i [15:8] ;
     if ( wb_sel_i [0] == 1'b1 )
       rgpio_aux [7:0] <= #1 wb_dat_i [7:0] ;
`endif
`ifdef GPIO_WB_BYTES3
     if ( wb_sel_i [2] == 1'b1 )
       rgpio_aux [gw-1:16] <= #1 wb_dat_i [gw-1:16] ;
     if ( wb_sel_i [1] == 1'b1 )
       rgpio_aux [15:8] <= #1 wb_dat_i [15:8] ;
     if ( wb_sel_i [0] == 1'b1 )
       rgpio_aux [7:0] <= #1 wb_dat_i [7:0] ;
`endif
`ifdef GPIO_WB_BYTES2
     if ( wb_sel_i [1] == 1'b1 )
       rgpio_aux [gw-1:8] <= #1 wb_dat_i [gw-1:8] ;
     if ( wb_sel_i [0] == 1'b1 )
       rgpio_aux [7:0] <= #1 wb_dat_i [7:0] ;
`endif
`ifdef GPIO_WB_BYTES1
     if ( wb_sel_i [0] == 1'b1 )
       rgpio_aux [gw-1:0] <= #1 wb_dat_i [gw-1:0] ;
`endif
   end

`else
assign rgpio_aux = `GPIO_DEF_RGPIO_AUX;	// RGPIO_AUX = 0x0
`endif


//
// Write to RGPIO_ECLK
//
`ifdef GPIO_RGPIO_ECLK
always @(posedge wb_clk_i or posedge wb_rst_i)
	if (wb_rst_i)
		rgpio_eclk <= #1 {gw{1'b0}};
	else if (rgpio_eclk_sel && wb_we_i)
  begin
`ifdef GPIO_STRICT_32BIT_ACCESS
		rgpio_eclk <= #1 wb_dat_i[gw-1:0];
`endif

`ifdef GPIO_WB_BYTES4
     if ( wb_sel_i [3] == 1'b1 )
       rgpio_eclk [gw-1:24] <= #1 wb_dat_i [gw-1:24] ;
     if ( wb_sel_i [2] == 1'b1 )
       rgpio_eclk [23:16] <= #1 wb_dat_i [23:16] ;
     if ( wb_sel_i [1] == 1'b1 )
       rgpio_eclk [15:8] <= #1 wb_dat_i [15:8] ;
     if ( wb_sel_i [0] == 1'b1 )
       rgpio_eclk [7:0] <= #1 wb_dat_i [7:0] ;
`endif
`ifdef GPIO_WB_BYTES3
     if ( wb_sel_i [2] == 1'b1 )
       rgpio_eclk [gw-1:16] <= #1 wb_dat_i [gw-1:16] ;
     if ( wb_sel_i [1] == 1'b1 )
       rgpio_eclk [15:8] <= #1 wb_dat_i [15:8] ;
     if ( wb_sel_i [0] == 1'b1 )
       rgpio_eclk [7:0] <= #1 wb_dat_i [7:0] ;
`endif
`ifdef GPIO_WB_BYTES2
     if ( wb_sel_i [1] == 1'b1 )
       rgpio_eclk [gw-1:8] <= #1 wb_dat_i [gw-1:8] ;
     if ( wb_sel_i [0] == 1'b1 )
       rgpio_eclk [7:0] <= #1 wb_dat_i [7:0] ;
`endif
`ifdef GPIO_WB_BYTES1
     if ( wb_sel_i [0] == 1'b1 )
       rgpio_eclk [gw-1:0] <= #1 wb_dat_i [gw-1:0] ;
`endif
   end


`else
assign rgpio_eclk = `GPIO_DEF_RGPIO_ECLK;	// RGPIO_ECLK = 0x0
`endif



//
// Write to RGPIO_NEC
//
`ifdef GPIO_RGPIO_NEC
always @(posedge wb_clk_i or posedge wb_rst_i)
	if (wb_rst_i)
		rgpio_nec <= #1 {gw{1'b0}};
	else if (rgpio_nec_sel && wb_we_i)
  begin
`ifdef GPIO_STRICT_32BIT_ACCESS
		rgpio_nec <= #1 wb_dat_i[gw-1:0];
`endif

`ifdef GPIO_WB_BYTES4
     if ( wb_sel_i [3] == 1'b1 )
       rgpio_nec [gw-1:24] <= #1 wb_dat_i [gw-1:24] ;
     if ( wb_sel_i [2] == 1'b1 )
       rgpio_nec [23:16] <= #1 wb_dat_i [23:16] ;
     if ( wb_sel_i [1] == 1'b1 )
       rgpio_nec [15:8] <= #1 wb_dat_i [15:8] ;
     if ( wb_sel_i [0] == 1'b1 )
       rgpio_nec [7:0] <= #1 wb_dat_i [7:0] ;
`endif
`ifdef GPIO_WB_BYTES3
     if ( wb_sel_i [2] == 1'b1 )
       rgpio_nec [gw-1:16] <= #1 wb_dat_i [gw-1:16] ;
     if ( wb_sel_i [1] == 1'b1 )
       rgpio_nec [15:8] <= #1 wb_dat_i [15:8] ;
     if ( wb_sel_i [0] == 1'b1 )
       rgpio_nec [7:0] <= #1 wb_dat_i [7:0] ;
`endif
`ifdef GPIO_WB_BYTES2
     if ( wb_sel_i [1] == 1'b1 )
       rgpio_nec [gw-1:8] <= #1 wb_dat_i [gw-1:8] ;
     if ( wb_sel_i [0] == 1'b1 )
       rgpio_nec [7:0] <= #1 wb_dat_i [7:0] ;
`endif
`ifdef GPIO_WB_BYTES1
     if ( wb_sel_i [0] == 1'b1 )
       rgpio_nec [gw-1:0] <= #1 wb_dat_i [gw-1:0] ;
`endif
   end


`else
assign rgpio_nec = `GPIO_DEF_RGPIO_NEC;	// RGPIO_NEC = 0x0
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
//assign in_muxed = rgpio_ctrl[`GPIO_RGPIO_CTRL_ECLK] ? extc_in : ext_pad_i;


`ifdef GPIO_LINES32
assign  in_muxed [31] = rgpio_eclk [31] ? extc_in[31] : ext_pad_i[31] ;
`endif

`ifdef GPIO_LINES31
assign  in_muxed [30] = rgpio_eclk [30] ? extc_in[30] : ext_pad_i[30] ;
`endif

`ifdef GPIO_LINES30
assign  in_muxed [29] = rgpio_eclk [29] ? extc_in[29] : ext_pad_i[29] ;
`endif

`ifdef GPIO_LINES29
assign  in_muxed [28] = rgpio_eclk [28] ? extc_in[28] : ext_pad_i[28] ;
`endif

`ifdef GPIO_LINES28
assign  in_muxed [27] = rgpio_eclk [27] ? extc_in[27] : ext_pad_i[27] ;
`endif

`ifdef GPIO_LINES27
assign  in_muxed [26] = rgpio_eclk [26] ? extc_in[26] : ext_pad_i[26] ;
`endif

`ifdef GPIO_LINES26
assign  in_muxed [25] = rgpio_eclk [25] ? extc_in[25] : ext_pad_i[25] ;
`endif

`ifdef GPIO_LINES25
assign  in_muxed [24] = rgpio_eclk [24] ? extc_in[24] : ext_pad_i[24] ;
`endif

`ifdef GPIO_LINES24
assign  in_muxed [23] = rgpio_eclk [23] ? extc_in[23] : ext_pad_i[23] ;
`endif

`ifdef GPIO_LINES23
assign  in_muxed [22] = rgpio_eclk [22] ? extc_in[22] : ext_pad_i[22] ;
`endif

`ifdef GPIO_LINES22
assign  in_muxed [21] = rgpio_eclk [21] ? extc_in[21] : ext_pad_i[21] ;
`endif

`ifdef GPIO_LINES21
assign  in_muxed [20] = rgpio_eclk [20] ? extc_in[20] : ext_pad_i[20] ;
`endif

`ifdef GPIO_LINES20
assign  in_muxed [19] = rgpio_eclk [19] ? extc_in[19] : ext_pad_i[19] ;
`endif

`ifdef GPIO_LINES19
assign  in_muxed [18] = rgpio_eclk [18] ? extc_in[18] : ext_pad_i[18] ;
`endif

`ifdef GPIO_LINES18
assign  in_muxed [17] = rgpio_eclk [17] ? extc_in[17] : ext_pad_i[17] ;
`endif

`ifdef GPIO_LINES17
assign  in_muxed [16] = rgpio_eclk [16] ? extc_in[16] : ext_pad_i[16] ;
`endif

`ifdef GPIO_LINES16
assign  in_muxed [15] = rgpio_eclk [15] ? extc_in[15] : ext_pad_i[15] ;
`endif

`ifdef GPIO_LINES15
assign  in_muxed [14] = rgpio_eclk [14] ? extc_in[14] : ext_pad_i[14] ;
`endif

`ifdef GPIO_LINES14
assign  in_muxed [13] = rgpio_eclk [13] ? extc_in[13] : ext_pad_i[13] ;
`endif

`ifdef GPIO_LINES13
assign  in_muxed [12] = rgpio_eclk [12] ? extc_in[12] : ext_pad_i[12] ;
`endif

`ifdef GPIO_LINES12
assign  in_muxed [11] = rgpio_eclk [11] ? extc_in[11] : ext_pad_i[11] ;
`endif

`ifdef GPIO_LINES11
assign  in_muxed [10] = rgpio_eclk [10] ? extc_in[10] : ext_pad_i[10] ;
`endif

`ifdef GPIO_LINES10
assign  in_muxed [9] = rgpio_eclk [9] ? extc_in[9] : ext_pad_i[9] ;
`endif

`ifdef GPIO_LINES9
assign  in_muxed [8] = rgpio_eclk [8] ? extc_in[8] : ext_pad_i[8] ;
`endif

`ifdef GPIO_LINES8
assign  in_muxed [7] = rgpio_eclk [7] ? extc_in[7] : ext_pad_i[7] ;
`endif

`ifdef GPIO_LINES7
assign  in_muxed [6] = rgpio_eclk [6] ? extc_in[6] : ext_pad_i[6] ;
`endif

`ifdef GPIO_LINES6
assign  in_muxed [5] = rgpio_eclk [5] ? extc_in[5] : ext_pad_i[5] ;
`endif

`ifdef GPIO_LINES5
assign  in_muxed [4] = rgpio_eclk [4] ? extc_in[4] : ext_pad_i[4] ;
`endif

`ifdef GPIO_LINES4
assign  in_muxed [3] = rgpio_eclk [3] ? extc_in[3] : ext_pad_i[3] ;
`endif

`ifdef GPIO_LINES3
assign  in_muxed [2] = rgpio_eclk [2] ? extc_in[2] : ext_pad_i[2] ;
`endif

`ifdef GPIO_LINES2
assign  in_muxed [1] = rgpio_eclk [1] ? extc_in[1] : ext_pad_i[1] ;
`endif

`ifdef GPIO_LINES1
assign  in_muxed [0] = rgpio_eclk [0] ? extc_in[0] : ext_pad_i[0] ;
`endif


//
// Posedge pext_clk is inverted by NEC bit if negedge flops are not allowed.
// If negedge flops are allowed, pext_clk only clocks posedge flops.
//
`ifdef GPIO_NO_NEGEDGE_FLOPS
`ifdef GPIO_NO_CLKPAD_LOGIC
assign pext_clk = {gw{clk_pad_i}};
`else

//assign pext_clk = rgpio_ctrl[`GPIO_RGPIO_CTRL_NEC] ? ~clk_pad_i : clk_pad_i;


`ifdef GPIO_LINES32
assign  pext_clk [31] = rgpio_nec [31] ? ~clk_pad_i : clk_pad_i ;
`endif

`ifdef GPIO_LINES31
assign  pext_clk [30] = rgpio_nec [30] ? ~clk_pad_i : clk_pad_i ;
`endif

`ifdef GPIO_LINES30
assign  pext_clk [29] = rgpio_nec [29] ? ~clk_pad_i : clk_pad_i ;
`endif

`ifdef GPIO_LINES29
assign  pext_clk [28] = rgpio_nec [28] ? ~clk_pad_i : clk_pad_i ;
`endif

`ifdef GPIO_LINES28
assign  pext_clk [27] = rgpio_nec [27] ? ~clk_pad_i : clk_pad_i ;
`endif

`ifdef GPIO_LINES27
assign  pext_clk [26] = rgpio_nec [26] ? ~clk_pad_i : clk_pad_i ;
`endif

`ifdef GPIO_LINES26
assign  pext_clk [25] = rgpio_nec [25] ? ~clk_pad_i : clk_pad_i ;
`endif

`ifdef GPIO_LINES25
assign  pext_clk [24] = rgpio_nec [24] ? ~clk_pad_i : clk_pad_i ;
`endif

`ifdef GPIO_LINES24
assign  pext_clk [23] = rgpio_nec [23] ? ~clk_pad_i : clk_pad_i ;
`endif

`ifdef GPIO_LINES23
assign  pext_clk [22] = rgpio_nec [22] ? ~clk_pad_i : clk_pad_i ;
`endif

`ifdef GPIO_LINES22
assign  pext_clk [21] = rgpio_nec [21] ? ~clk_pad_i : clk_pad_i ;
`endif

`ifdef GPIO_LINES21
assign  pext_clk [20] = rgpio_nec [20] ? ~clk_pad_i : clk_pad_i ;
`endif

`ifdef GPIO_LINES20
assign  pext_clk [19] = rgpio_nec [19] ? ~clk_pad_i : clk_pad_i ;
`endif

`ifdef GPIO_LINES19
assign  pext_clk [18] = rgpio_nec [18] ? ~clk_pad_i : clk_pad_i ;
`endif

`ifdef GPIO_LINES18
assign  pext_clk [17] = rgpio_nec [17] ? ~clk_pad_i : clk_pad_i ;
`endif

`ifdef GPIO_LINES17
assign  pext_clk [16] = rgpio_nec [16] ? ~clk_pad_i : clk_pad_i ;
`endif

`ifdef GPIO_LINES16
assign  pext_clk [15] = rgpio_nec [15] ? ~clk_pad_i : clk_pad_i ;
`endif

`ifdef GPIO_LINES15
assign  pext_clk [14] = rgpio_nec [14] ? ~clk_pad_i : clk_pad_i ;
`endif

`ifdef GPIO_LINES14
assign  pext_clk [13] = rgpio_nec [13] ? ~clk_pad_i : clk_pad_i ;
`endif

`ifdef GPIO_LINES13
assign  pext_clk [12] = rgpio_nec [12] ? ~clk_pad_i : clk_pad_i ;
`endif

`ifdef GPIO_LINES12
assign  pext_clk [11] = rgpio_nec [11] ? ~clk_pad_i : clk_pad_i ;
`endif

`ifdef GPIO_LINES11
assign  pext_clk [10] = rgpio_nec [10] ? ~clk_pad_i : clk_pad_i ;
`endif

`ifdef GPIO_LINES10
assign  pext_clk [9] = rgpio_nec [9] ? ~clk_pad_i : clk_pad_i ;
`endif

`ifdef GPIO_LINES9
assign  pext_clk [8] = rgpio_nec [8] ? ~clk_pad_i : clk_pad_i ;
`endif

`ifdef GPIO_LINES8
assign  pext_clk [7] = rgpio_nec [7] ? ~clk_pad_i : clk_pad_i ;
`endif

`ifdef GPIO_LINES7
assign  pext_clk [6] = rgpio_nec [6] ? ~clk_pad_i : clk_pad_i ;
`endif

`ifdef GPIO_LINES6
assign  pext_clk [5] = rgpio_nec [5] ? ~clk_pad_i : clk_pad_i ;
`endif

`ifdef GPIO_LINES5
assign  pext_clk [4] = rgpio_nec [4] ? ~clk_pad_i : clk_pad_i ;
`endif

`ifdef GPIO_LINES4
assign  pext_clk [3] = rgpio_nec [3] ? ~clk_pad_i : clk_pad_i ;
`endif

`ifdef GPIO_LINES3
assign  pext_clk [2] = rgpio_nec [2] ? ~clk_pad_i : clk_pad_i ;
`endif

`ifdef GPIO_LINES2
assign  pext_clk [1] = rgpio_nec [1] ? ~clk_pad_i : clk_pad_i ;
`endif

`ifdef GPIO_LINES1
assign  pext_clk [0] = rgpio_nec [0] ? ~clk_pad_i : clk_pad_i ;
`endif

`endif
`else
assign pext_clk = {gw{clk_pad_i}};
`endif


//
// If negedge flops are allowed, ext_in is mux of negedge and posedge external clocked flops.
//
`ifdef GPIO_NO_NEGEDGE_FLOPS
assign extc_in = pextc_sampled;
`else
//assign extc_in = rgpio_ctrl[`GPIO_RGPIO_CTRL_NEC] ? nextc_sampled : pextc_sampled;


`ifdef GPIO_LINES32
assign  extc_in [31] = rgpio_nec [31] ? nextc_sampled[31] : pextc_sampled[31] ;
`endif

`ifdef GPIO_LINES31
assign  extc_in [30] = rgpio_nec [30] ? nextc_sampled[30] : pextc_sampled[30] ;
`endif

`ifdef GPIO_LINES30
assign  extc_in [29] = rgpio_nec [29] ? nextc_sampled[29] : pextc_sampled[29] ;
`endif

`ifdef GPIO_LINES29
assign  extc_in [28] = rgpio_nec [28] ? nextc_sampled[28] : pextc_sampled[28] ;
`endif

`ifdef GPIO_LINES28
assign  extc_in [27] = rgpio_nec [27] ? nextc_sampled[27] : pextc_sampled[27] ;
`endif

`ifdef GPIO_LINES27
assign  extc_in [26] = rgpio_nec [26] ? nextc_sampled[26] : pextc_sampled[26] ;
`endif

`ifdef GPIO_LINES26
assign  extc_in [25] = rgpio_nec [25] ? nextc_sampled[25] : pextc_sampled[25] ;
`endif

`ifdef GPIO_LINES25
assign  extc_in [24] = rgpio_nec [24] ? nextc_sampled[24] : pextc_sampled[24] ;
`endif

`ifdef GPIO_LINES24
assign  extc_in [23] = rgpio_nec [23] ? nextc_sampled[23] : pextc_sampled[23] ;
`endif

`ifdef GPIO_LINES23
assign  extc_in [22] = rgpio_nec [22] ? nextc_sampled[22] : pextc_sampled[22] ;
`endif

`ifdef GPIO_LINES22
assign  extc_in [21] = rgpio_nec [21] ? nextc_sampled[21] : pextc_sampled[21] ;
`endif

`ifdef GPIO_LINES21
assign  extc_in [20] = rgpio_nec [20] ? nextc_sampled[20] : pextc_sampled[20] ;
`endif

`ifdef GPIO_LINES20
assign  extc_in [19] = rgpio_nec [19] ? nextc_sampled[19] : pextc_sampled[19] ;
`endif

`ifdef GPIO_LINES19
assign  extc_in [18] = rgpio_nec [18] ? nextc_sampled[18] : pextc_sampled[18] ;
`endif

`ifdef GPIO_LINES18
assign  extc_in [17] = rgpio_nec [17] ? nextc_sampled[17] : pextc_sampled[17] ;
`endif

`ifdef GPIO_LINES17
assign  extc_in [16] = rgpio_nec [16] ? nextc_sampled[16] : pextc_sampled[16] ;
`endif

`ifdef GPIO_LINES16
assign  extc_in [15] = rgpio_nec [15] ? nextc_sampled[15] : pextc_sampled[15] ;
`endif

`ifdef GPIO_LINES15
assign  extc_in [14] = rgpio_nec [14] ? nextc_sampled[14] : pextc_sampled[14] ;
`endif

`ifdef GPIO_LINES14
assign  extc_in [13] = rgpio_nec [13] ? nextc_sampled[13] : pextc_sampled[13] ;
`endif

`ifdef GPIO_LINES13
assign  extc_in [12] = rgpio_nec [12] ? nextc_sampled[12] : pextc_sampled[12] ;
`endif

`ifdef GPIO_LINES12
assign  extc_in [11] = rgpio_nec [11] ? nextc_sampled[11] : pextc_sampled[11] ;
`endif

`ifdef GPIO_LINES11
assign  extc_in [10] = rgpio_nec [10] ? nextc_sampled[10] : pextc_sampled[10] ;
`endif

`ifdef GPIO_LINES10
assign  extc_in [9] = rgpio_nec [9] ? nextc_sampled[9] : pextc_sampled[9] ;
`endif

`ifdef GPIO_LINES9
assign  extc_in [8] = rgpio_nec [8] ? nextc_sampled[8] : pextc_sampled[8] ;
`endif

`ifdef GPIO_LINES8
assign  extc_in [7] = rgpio_nec [7] ? nextc_sampled[7] : pextc_sampled[7] ;
`endif

`ifdef GPIO_LINES7
assign  extc_in [6] = rgpio_nec [6] ? nextc_sampled[6] : pextc_sampled[6] ;
`endif

`ifdef GPIO_LINES6
assign  extc_in [5] = rgpio_nec [5] ? nextc_sampled[5] : pextc_sampled[5] ;
`endif

`ifdef GPIO_LINES5
assign  extc_in [4] = rgpio_nec [4] ? nextc_sampled[4] : pextc_sampled[4] ;
`endif

`ifdef GPIO_LINES4
assign  extc_in [3] = rgpio_nec [3] ? nextc_sampled[3] : pextc_sampled[3] ;
`endif

`ifdef GPIO_LINES3
assign  extc_in [2] = rgpio_nec [2] ? nextc_sampled[2] : pextc_sampled[2] ;
`endif

`ifdef GPIO_LINES2
assign  extc_in [1] = rgpio_nec [1] ? nextc_sampled[1] : pextc_sampled[1] ;
`endif

`ifdef GPIO_LINES1
assign  extc_in [0] = rgpio_nec [0] ? nextc_sampled[0] : pextc_sampled[0] ;
`endif

`endif

//
// Latch using posedge external clock
//

`ifdef GPIO_LINES32
always @(posedge pext_clk[31] or posedge wb_rst_i)
	if (wb_rst_i)
		pextc_sampled[31] <= #1 1'b0;
	else
		pextc_sampled[31] <= #1 ext_pad_i[31];
`endif

`ifdef GPIO_LINES31
always @(posedge pext_clk[30] or posedge wb_rst_i)
  if (wb_rst_i)
    pextc_sampled[30] <= #1 1'b0;
  else
    pextc_sampled[30] <= #1 ext_pad_i[30];
`endif

`ifdef GPIO_LINES30
always @(posedge pext_clk[29] or posedge wb_rst_i)
  if (wb_rst_i)
    pextc_sampled[29] <= #1 1'b0;
  else
    pextc_sampled[29] <= #1 ext_pad_i[29];
`endif

`ifdef GPIO_LINES29
always @(posedge pext_clk[28] or posedge wb_rst_i)
  if (wb_rst_i)
    pextc_sampled[28] <= #1 1'b0;
  else
    pextc_sampled[28] <= #1 ext_pad_i[28];
`endif

`ifdef GPIO_LINES28
always @(posedge pext_clk[27] or posedge wb_rst_i)
  if (wb_rst_i)
    pextc_sampled[27] <= #1 1'b0;
  else
    pextc_sampled[27] <= #1 ext_pad_i[27];
`endif

`ifdef GPIO_LINES27
always @(posedge pext_clk[26] or posedge wb_rst_i)
  if (wb_rst_i)
    pextc_sampled[26] <= #1 1'b0;
  else
    pextc_sampled[26] <= #1 ext_pad_i[26];
`endif

`ifdef GPIO_LINES26
always @(posedge pext_clk[25] or posedge wb_rst_i)
  if (wb_rst_i)
    pextc_sampled[25] <= #1 1'b0;
  else
    pextc_sampled[25] <= #1 ext_pad_i[25];
`endif

`ifdef GPIO_LINES25
always @(posedge pext_clk[24] or posedge wb_rst_i)
  if (wb_rst_i)
    pextc_sampled[24] <= #1 1'b0;
  else
    pextc_sampled[24] <= #1 ext_pad_i[24];
`endif

`ifdef GPIO_LINES24
always @(posedge pext_clk[23] or posedge wb_rst_i)
  if (wb_rst_i)
    pextc_sampled[23] <= #1 1'b0;
  else
    pextc_sampled[23] <= #1 ext_pad_i[23];
`endif

`ifdef GPIO_LINES23
always @(posedge pext_clk[22] or posedge wb_rst_i)
  if (wb_rst_i)
    pextc_sampled[22] <= #1 1'b0;
  else
    pextc_sampled[22] <= #1 ext_pad_i[22];
`endif

`ifdef GPIO_LINES22
always @(posedge pext_clk[21] or posedge wb_rst_i)
  if (wb_rst_i)
    pextc_sampled[21] <= #1 1'b0;
  else
    pextc_sampled[21] <= #1 ext_pad_i[21];
`endif

`ifdef GPIO_LINES21
always @(posedge pext_clk[20] or posedge wb_rst_i)
  if (wb_rst_i)
    pextc_sampled[20] <= #1 1'b0;
  else
    pextc_sampled[20] <= #1 ext_pad_i[20];
`endif

`ifdef GPIO_LINES20
always @(posedge pext_clk[19] or posedge wb_rst_i)
  if (wb_rst_i)
    pextc_sampled[19] <= #1 1'b0;
  else
    pextc_sampled[19] <= #1 ext_pad_i[19];
`endif

`ifdef GPIO_LINES19
always @(posedge pext_clk[18] or posedge wb_rst_i)
  if (wb_rst_i)
    pextc_sampled[18] <= #1 1'b0;
  else
    pextc_sampled[18] <= #1 ext_pad_i[18];
`endif

`ifdef GPIO_LINES18
always @(posedge pext_clk[17] or posedge wb_rst_i)
  if (wb_rst_i)
    pextc_sampled[17] <= #1 1'b0;
  else
    pextc_sampled[17] <= #1 ext_pad_i[17];
`endif

`ifdef GPIO_LINES17
always @(posedge pext_clk[16] or posedge wb_rst_i)
  if (wb_rst_i)
    pextc_sampled[16] <= #1 1'b0;
  else
    pextc_sampled[16] <= #1 ext_pad_i[16];
`endif

`ifdef GPIO_LINES16
always @(posedge pext_clk[15] or posedge wb_rst_i)
  if (wb_rst_i)
    pextc_sampled[15] <= #1 1'b0;
  else
    pextc_sampled[15] <= #1 ext_pad_i[15];
`endif

`ifdef GPIO_LINES15
always @(posedge pext_clk[14] or posedge wb_rst_i)
  if (wb_rst_i)
    pextc_sampled[14] <= #1 1'b0;
  else
    pextc_sampled[14] <= #1 ext_pad_i[14];
`endif

`ifdef GPIO_LINES14
always @(posedge pext_clk[13] or posedge wb_rst_i)
  if (wb_rst_i)
    pextc_sampled[13] <= #1 1'b0;
  else
    pextc_sampled[13] <= #1 ext_pad_i[13];
`endif

`ifdef GPIO_LINES13
always @(posedge pext_clk[12] or posedge wb_rst_i)
  if (wb_rst_i)
    pextc_sampled[12] <= #1 1'b0;
  else
    pextc_sampled[12] <= #1 ext_pad_i[12];
`endif

`ifdef GPIO_LINES12
always @(posedge pext_clk[11] or posedge wb_rst_i)
  if (wb_rst_i)
    pextc_sampled[11] <= #1 1'b0;
  else
    pextc_sampled[11] <= #1 ext_pad_i[11];
`endif

`ifdef GPIO_LINES11
always @(posedge pext_clk[10] or posedge wb_rst_i)
  if (wb_rst_i)
    pextc_sampled[10] <= #1 1'b0;
  else
    pextc_sampled[10] <= #1 ext_pad_i[10];
`endif

`ifdef GPIO_LINES10
always @(posedge pext_clk[9] or posedge wb_rst_i)
  if (wb_rst_i)
    pextc_sampled[9] <= #1 1'b0;
  else
    pextc_sampled[9] <= #1 ext_pad_i[9];
`endif

`ifdef GPIO_LINES9
always @(posedge pext_clk[8] or posedge wb_rst_i)
  if (wb_rst_i)
    pextc_sampled[8] <= #1 1'b0;
  else
    pextc_sampled[8] <= #1 ext_pad_i[8];
`endif

`ifdef GPIO_LINES8
always @(posedge pext_clk[7] or posedge wb_rst_i)
  if (wb_rst_i)
    pextc_sampled[7] <= #1 1'b0;
  else
    pextc_sampled[7] <= #1 ext_pad_i[7];
`endif

`ifdef GPIO_LINES7
always @(posedge pext_clk[6] or posedge wb_rst_i)
  if (wb_rst_i)
    pextc_sampled[6] <= #1 1'b0;
  else
    pextc_sampled[6] <= #1 ext_pad_i[6];
`endif

`ifdef GPIO_LINES6
always @(posedge pext_clk[5] or posedge wb_rst_i)
  if (wb_rst_i)
    pextc_sampled[5] <= #1 1'b0;
  else
    pextc_sampled[5] <= #1 ext_pad_i[5];
`endif

`ifdef GPIO_LINES5
always @(posedge pext_clk[4] or posedge wb_rst_i)
  if (wb_rst_i)
    pextc_sampled[4] <= #1 1'b0;
  else
    pextc_sampled[4] <= #1 ext_pad_i[4];
`endif

`ifdef GPIO_LINES4
always @(posedge pext_clk[3] or posedge wb_rst_i)
  if (wb_rst_i)
    pextc_sampled[3] <= #1 1'b0;
  else
    pextc_sampled[3] <= #1 ext_pad_i[3];
`endif

`ifdef GPIO_LINES3
always @(posedge pext_clk[2] or posedge wb_rst_i)
  if (wb_rst_i)
    pextc_sampled[2] <= #1 1'b0;
  else
    pextc_sampled[2] <= #1 ext_pad_i[2];
`endif

`ifdef GPIO_LINES2
always @(posedge pext_clk[1] or posedge wb_rst_i)
  if (wb_rst_i)
    pextc_sampled[1] <= #1 1'b0;
  else
    pextc_sampled[1] <= #1 ext_pad_i[1];
`endif

`ifdef GPIO_LINES1
always @(posedge pext_clk[0] or posedge wb_rst_i)
  if (wb_rst_i)
    pextc_sampled[0] <= #1 1'b0;
  else
    pextc_sampled[0] <= #1 ext_pad_i[0];
`endif

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
		rgpio_ptrig or rgpio_aux or rgpio_ctrl or rgpio_ints or rgpio_eclk or rgpio_nec)
	case (wb_adr_i[`GPIO_OFS_BITS])	// synopsys full_case parallel_case
`ifdef GPIO_READREGS
  `ifdef GPIO_RGPIO_OUT
  	`GPIO_RGPIO_OUT: begin
			wb_dat[dw-1:0] = rgpio_out;
		end
  `endif
  `ifdef GPIO_RGPIO_OE
		`GPIO_RGPIO_OE: begin
			wb_dat[dw-1:0] = rgpio_oe;
		end
  `endif
  `ifdef GPIO_RGPIO_INTE
		`GPIO_RGPIO_INTE: begin
			wb_dat[dw-1:0] = rgpio_inte;
		end
  `endif
  `ifdef GPIO_RGPIO_PTRIG
		`GPIO_RGPIO_PTRIG: begin
			wb_dat[dw-1:0] = rgpio_ptrig;
		end
  `endif
  `ifdef GPIO_RGPIO_NEC
		`GPIO_RGPIO_NEC: begin
			wb_dat[dw-1:0] = rgpio_nec;
		end
  `endif
  `ifdef GPIO_RGPIO_ECLK
		`GPIO_RGPIO_ECLK: begin
			wb_dat[dw-1:0] = rgpio_eclk;
		end
  `endif
  `ifdef GPIO_RGPIO_AUX
		`GPIO_RGPIO_AUX: begin
			wb_dat[dw-1:0] = rgpio_aux;
		end
  `endif
  `ifdef GPIO_RGPIO_CTRL
		`GPIO_RGPIO_CTRL: begin
			wb_dat[1:0] = rgpio_ctrl;
			wb_dat[dw-1:2] = {dw-2{1'b0}};
		end
  `endif
`endif
  `ifdef GPIO_RGPIO_INTS
		`GPIO_RGPIO_INTS: begin
			wb_dat[dw-1:0] = rgpio_ints;
		end
  `endif
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
	else if (rgpio_ctrl[`GPIO_RGPIO_CTRL_INTE])
		rgpio_ints <= #1 (rgpio_ints | ((ext_pad_i ^ rgpio_in) & ~(ext_pad_i ^ rgpio_ptrig)) & rgpio_inte);
`else
assign rgpio_ints = (rgpio_ints | ((ext_pad_i ^ rgpio_in) & ~(ext_pad_i ^ rgpio_ptrig)) & rgpio_inte);
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
assign ext_padoe_o = rgpio_oe;

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
assign ext_padoe_o = {gw{1'b1}};
assign ext_pad_o = {gw{1'b0}};

//
// Read GPIO registers
//
assign wb_dat_o = {dw{1'b0}};

`endif

endmodule

