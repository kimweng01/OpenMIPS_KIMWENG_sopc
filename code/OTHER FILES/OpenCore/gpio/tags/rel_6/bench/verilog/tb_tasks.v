//////////////////////////////////////////////////////////////////////
////                                                              ////
////  GPIO Testbench Tasks                                        ////
////                                                              ////
////  This file is part of the GPIO project                       ////
////  http://www.opencores.org/cores/gpio/                        ////
////                                                              ////
////  Description                                                 ////
////  Testbench tasks.                                            ////
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
// Revision 1.6  2001/12/25 17:21:06  lampret
// Fixed two typos.
//
// Revision 1.5  2001/12/25 17:12:28  lampret
// Added RGPIO_INTS.
//
// Revision 1.4  2001/11/15 02:26:32  lampret
// Updated timing and fixed some typing errors.
//
// Revision 1.3  2001/09/18 16:37:55  lampret
// Changed VCD output location.
//
// Revision 1.2  2001/09/18 15:43:27  lampret
// Changed gpio top level into gpio_top. Changed defines.v into gpio_defines.v.
//
// Revision 1.1  2001/08/21 21:39:27  lampret
// Changed directory structure, port names and drfines.
//
// Revision 1.2  2001/07/14 20:37:23  lampret
// Test bench improvements.
//
// Revision 1.1  2001/06/05 07:45:22  lampret
// Added initial RTL and test benches. There are still some issues with these files.
//
//

`include "timescale.v"
`include "gpio_defines.v"
`include "tb_defines.v"

module tb_tasks;

integer nr_failed;
integer ints_disabled;
integer ints_working;
integer local_errs;

parameter sh_addr = `GPIO_ADDRLH+1;
parameter gw = `GPIO_IOS ;
//
// Count/report failed tests
//
task failed;
begin
	$display("FAILED !!!");
	nr_failed = nr_failed + 1;
end
endtask

//
// Set RGPIO_OUT register
//
task setout;
input	[31:0] val;

reg  [ 31:0 ] addr ;
begin
  addr = `GPIO_RGPIO_OUT <<sh_addr ;
	#100 tb_top.wb_master.wr(`GPIO_RGPIO_OUT<<sh_addr, val, 4'b1111);
/*  $display ( " addr : %h %h", addr, val ) ;
  $display ( "             out_pad : %h ", tb_top.gpio_top.out_pad ) ;
  $display ( "           rgpio_aux : %h ", tb_top.gpio_top.rgpio_aux) ;
  $display ( "               aux_i : %h ", tb_top.gpio_top.aux_i ) ;
  $display ( "           rgpio_out : %h ", tb_top.gpio_top.rgpio_out ) ;
*/
end

endtask

//
// Set RGPIO_OE register
//
task setoe;
input	[31:0] val;

begin
	#100 tb_top.wb_master.wr(`GPIO_RGPIO_OE<<sh_addr, val, 4'b1111);
end

endtask

//
// Set RGPIO_INTE register
//
task setinte;
input	[31:0] val;

begin
	#100 tb_top.wb_master.wr(`GPIO_RGPIO_INTE<<sh_addr, val, 4'b1111);
end

endtask

//
// Set RGPIO_PTRIG register
//
task setptrig;
input	[31:0] val;

begin
	#100 tb_top.wb_master.wr(`GPIO_RGPIO_PTRIG<<sh_addr, val, 4'b1111);
end

endtask

//
// Set RGPIO_AUX register
//
task setaux;
input	[31:0] val;

begin
	#100 tb_top.wb_master.wr(`GPIO_RGPIO_AUX<<sh_addr, val, 4'b1111);
end

endtask

//
// Set RGPIO_CTRL register
//
task setctrl;
input	[31:0] val;

begin
	#100 tb_top.wb_master.wr(`GPIO_RGPIO_CTRL<<sh_addr, val, 4'b1111);
end

endtask

//
// Set RGPIO_INTS register
//
task setints;
input	[31:0] val;

begin
	#100 tb_top.wb_master.wr(`GPIO_RGPIO_INTS<<sh_addr, val, 4'b1111);
end

endtask

//
// Display RGPIO_IN register
//
task showin;

reg	[31:0] tmp;
begin
	#100 tb_top.wb_master.rd(`GPIO_RGPIO_IN<<sh_addr, tmp);
	$write(" RGPIO_IN: %h", tmp);
end

endtask

//
// Display RGPIO_OUT register
//
task showout;

reg	[31:0] tmp;
begin
	#100 tb_top.wb_master.rd(`GPIO_RGPIO_OUT<<sh_addr, tmp);
	$write(" RGPIO_OUT: %h", tmp);
end

endtask


//
// Display RGPIO_OE register
//
task showoe;

reg	[31:0] tmp;
begin
	#100 tb_top.wb_master.rd(`GPIO_RGPIO_OE<<sh_addr, tmp);
	$write(" RGPIO_OE:%h", tmp);
end

endtask

//
// Display RGPIO_INTE register
//
task showinte;

reg	[31:0] tmp;
begin
	#100 tb_top.wb_master.rd(`GPIO_RGPIO_INTE<<sh_addr, tmp);
	$write(" RGPIO_INTE:%h", tmp);
end

endtask

//
// Display RGPIO_PTRIG register
//
task showptrig;

reg	[31:0] tmp;
begin
	#100 tb_top.wb_master.rd(`GPIO_RGPIO_PTRIG<<sh_addr, tmp);
	$write(" RGPIO_PTRIG:%h", tmp);
end

endtask

//
// Display RGPIO_AUX register
//
task showaux;

reg	[31:0] tmp;
begin
	#100 tb_top.wb_master.rd(`GPIO_RGPIO_AUX<<sh_addr, tmp);
	$write(" RGPIO_AUX:%h", tmp);
end

endtask

//
// Display RGPIO_CTRL register
//
task showctrl;

reg	[31:0] tmp;
begin
	#100 tb_top.wb_master.rd(`GPIO_RGPIO_CTRL<<sh_addr, tmp);
	$write(" RGPIO_CTRL: %h", tmp);
end

endtask

//
// Display RGPIO_INTS register
//
task showints;

reg	[31:0] tmp;
begin
	#100 tb_top.wb_master.rd(`GPIO_RGPIO_INTS<<sh_addr, tmp);
	$write(" RGPIO_INTS:%h", tmp);
end

endtask

//
// Compare parameter with RGPIO_IN register
//
task comp_in;
input	[31:0] 	val;
output		ret;

reg	[31:0]	tmp;
reg		ret;
begin
	#100 tb_top.wb_master.rd(`GPIO_RGPIO_IN<<sh_addr, tmp);

	if (tmp == val)
		ret = 1;
	else
		ret = 0;
end

endtask

//
// Get RGPIO_IN register
//
task getin;
output	[31:0]	tmp;

begin
	#100 tb_top.wb_master.rd(`GPIO_RGPIO_IN<<sh_addr, tmp);
end

endtask

//
// Get RGPIO_OUT register
//
task getout;
output	[31:0]	tmp;

begin
	#100 tb_top.wb_master.rd(`GPIO_RGPIO_OUT<<sh_addr, tmp);
end

endtask

//
// Get RGPIO_OE register
//
task getoe;
output	[31:0]	tmp;

begin
	#100 tb_top.wb_master.rd(`GPIO_RGPIO_OE<<sh_addr, tmp);
end

endtask

//
// Get RGPIO_INTE register
//
task getinte;
output	[31:0]	tmp;

begin
	#100 tb_top.wb_master.rd(`GPIO_RGPIO_INTE<<sh_addr, tmp);
end

endtask

//
// Get RGPIO_PTRIG register
//
task getptrig;
output	[31:0]	tmp;

begin
	#100 tb_top.wb_master.rd(`GPIO_RGPIO_PTRIG<<sh_addr, tmp);
end

endtask

//
// Get RGPIO_AUX register
//
task getaux;
output	[31:0]	tmp;

begin
	#100 tb_top.wb_master.rd(`GPIO_RGPIO_AUX<<sh_addr, tmp);
end

endtask

//
// Get RGPIO_CTRL register
//
task getctrl;
output	[31:0]	tmp;

begin
	#100 tb_top.wb_master.rd(`GPIO_RGPIO_CTRL<<sh_addr, tmp);
end

endtask

//
// Get RGPIO_INTS register
//
task getints;
output	[31:0]	tmp;

begin
	#100 tb_top.wb_master.rd(`GPIO_RGPIO_INTS<<sh_addr, tmp);
end

endtask

//
// Calculate a random and make it narrow to fit on GPIO I/O pins
//
task random_gpio;
output	[31:0]	tmp;

begin
	tmp = $random & ((1<<`GPIO_IOS)-1);
end

endtask

//
// Test operation of control bit RGPIO_CTRL[ECLK]
//
task test_eclk;
reg [gw-1:0 ]		l1, l2, l3;
reg [gw-1:0 ]		r1, r2, r3;
begin

	// Set external clock to low state
	tb_top.gpio_mon.set_gpioeclk(0);
	@(posedge tb_top.clk);
	@(posedge tb_top.clk);

	//
	// Phase 1
	//
	// GPIO uses WISHBONE clock to latch gpio_in
	//

	// Put something on gpio_in pins
	random_gpio(r1);
	tb_top.gpio_mon.set_gpioin(r1);

	// Reset GPIO_CTRL
	setctrl(0);

	// Wait for time to advance
	@(posedge tb_top.clk);
	@(posedge tb_top.clk);

	// Read GPIO_RGPIO_IN
	getin(l1);

	//
	// Phase 2
	//
	// GPIO uses external clock to latch gpio_in
	//

	// Set GPIO to use external clock, NEC bit cleared
	setctrl(1 << `GPIO_RGPIO_CTRL_ECLK);

	// Put something else on gpio_in pins
	random_gpio(r2);
	tb_top.gpio_mon.set_gpioin(r2);

	// Make an external posedge clock pulse
	tb_top.gpio_mon.set_gpioeclk(0);
	@(posedge tb_top.clk);
	@(posedge tb_top.clk);
	tb_top.gpio_mon.set_gpioeclk(1);
	@(posedge tb_top.clk);
	@(posedge tb_top.clk);

	// Read RGPIO_IN
	getin(l2);

	//
	// Phase 3
	//
	// Change GPIO inputs and WB clock but not external clock.
	// RGPIO_IN should not change.
	//

	// Put something else on gpio_in pins
	random_gpio(r3);
	tb_top.gpio_mon.set_gpioin(r3);

	// Wait for WB clock
	@(posedge tb_top.clk);
	@(posedge tb_top.clk);

	// Read RGPIO_IN
	getin(l3);

	//
	// Phase 4
	//
	// Compare phases
	//
	if (l1 == r1 && l2 == r2 && l2 == l3)
		$write(".");
	else
		local_errs = local_errs + 1;
end
endtask

//
// Test operation of control bit RGPIO_CTRL[NEC]
//
task test_nec;
integer		l1, l2;
integer		r1, r2;
begin
	//
	// Phase 1
	//
	// Compare RGPIO_IN before and after negative edge
	//

	// Set external clock to low state
	tb_top.gpio_mon.set_gpioeclk(0);
	@(posedge tb_top.clk);
	@(posedge tb_top.clk);

	// Set GPIO to use external clock and set RGPIO_CTRL[NEC]
	setctrl(1 << `GPIO_RGPIO_CTRL_ECLK | 1 << `GPIO_RGPIO_CTRL_NEC);

	// Put random on gpio inputs
	random_gpio(r1);
	tb_top.gpio_mon.set_gpioin(r1);

	// Advance time by making an external negedge clock pulse
	tb_top.gpio_mon.set_gpioeclk(1);
	@(posedge tb_top.clk);
	@(posedge tb_top.clk);
	tb_top.gpio_mon.set_gpioeclk(0);
	@(posedge tb_top.clk);
	@(posedge tb_top.clk);

	// Put something on gpio_in pins
	random_gpio(r2);
	tb_top.gpio_mon.set_gpioin(r2);

	// Make an external posedge clock pulse
	tb_top.gpio_mon.set_gpioeclk(0);
	@(posedge tb_top.clk);
	@(posedge tb_top.clk);
	tb_top.gpio_mon.set_gpioeclk(1);
	@(posedge tb_top.clk);
	@(posedge tb_top.clk);

	// Read RGPIO_IN (should be the same as r1)
	getin(l1);

	// Make an external negedge clock pulse
	tb_top.gpio_mon.set_gpioeclk(1);
	@(posedge tb_top.clk);
	@(posedge tb_top.clk);
	tb_top.gpio_mon.set_gpioeclk(0);
	@(posedge tb_top.clk);
	@(posedge tb_top.clk);

	// Read RGPIO_IN (should be the same as r2)
	getin(l2);

	//
	// Phase 2
	//
	// Compare phases
	//
//	$display("l1 %h  l2 %h  r1 %h  r2 %h", l1, l2, r1, r2);
	if (l1 == r1 && l2 == r2)
		$write(".");
	else
		local_errs = local_errs + 1;
end
endtask

//
// Test input polled mode, output mode and bidirectional
//
task test_simple;
reg [gw-1:0]		l1, l2, l3, l4;
integer		i, err;
begin
	$write("  Testing input mode ...");

	//
	// Phase 1
	//
	// Compare RGPIO_IN and gpio_in
	//

	// Set GPIO to use WB clock
	setctrl(0);

	err = 0;
	for (i = 0; i < 10 * `GPIO_VERIF_INTENSITY; i = i +1) begin
		// Put something on gpio_in pins
		random_gpio(l1);
		tb_top.gpio_mon.set_gpioin(l1);

		// Advance time
		@(posedge tb_top.clk);
		@(posedge tb_top.clk);

		// Read GPIO_RGPIO_IN
		getin(l2);

		// Compare gpio_in and RGPIO_IN. Should be equal.
		if (l1 != l2)
			err = err + 1;
	end

	// Phase 2
	//
	// Output result for previous test
	//
	if (!err)
		$display(" OK");
	else
		failed;

	$write("  Testing output mode ...");

	//
	// Phase 3
	//
	// Compare RGPIO_OUT and gpio_out
	//

	err = 0;
	for (i = 0; i < 10 * `GPIO_VERIF_INTENSITY; i = i +1) begin
		// Put something in RGPIO_OUT pins
		l1 = $random;
		setout(l1);

		// Advance time
		@(posedge tb_top.clk);
		@(posedge tb_top.clk);

		// Read gpio_out
		tb_top.gpio_mon.get_gpioout(l2);

		// Compare gpio_out and RGPIO_OUT. Should be equal.
		if (l1 != l2)
			err = err + 1;
	end

	// Phase 4
	//
	// Output result for previous test
	//
	if (!err)
		$display(" OK");
	else
		failed;

	$write("  Testing bidirectional I/O ...");

	//
	// Phase 5
	//
	// Compare RGPIO_OE and gpio_oen
	//

	err = 0;
	for (i = 0; i < 10 * `GPIO_VERIF_INTENSITY; i = i +1) begin
		// Put something in RGPIO_OE pins
		l1 = $random;
		setoe(l1);

		// Advance time
		@(posedge tb_top.clk);
		@(posedge tb_top.clk);

		// Read gpio_oen
		tb_top.gpio_mon.get_gpiooen(l2);

		// Compare gpio_oen and RGPIO_OE. Should be exactly opposite.
		if (l1 != ~l2)
			err = err + 1;
	end

	// Phase 6
	//
	// Output result for previous test
	//
	if (!err)
		$display(" OK");
	else
		failed;

	$write("  Testing auxiliary feature ...");

	//
	// Phase 7
	//
	// Compare RGPIO_OUT, gpio_out, RGPIO_AUX and gpio_aux
	//

	err = 0;
	for (i = 0; i < 10 * `GPIO_VERIF_INTENSITY; i = i +1) begin
		// Put something on gpio_aux pins
		l1 = $random;
		tb_top.gpio_mon.set_gpioaux(l1);

		// Put something in RGPIO_AUX pins
		l2 = $random;
		setaux(l2);

		// Put something in RGPIO_OUT pins
		l3 = $random;
		setout(l3);

		// Advance time
		@(posedge tb_top.clk);
		@(posedge tb_top.clk);

		// Read gpio_out
		tb_top.gpio_mon.get_gpioout(l4);

		// Compare gpio_out, RGPIO_OUT, RGPIO_AUX and gpio_aux.
		// RGPIO_AUX specifies which gpio_aux bits and RGPIO_OUT 
		// bits are present on gpio_out and where
		if ((l1 & l2 | l3 & ~l2) != l4)
			err = err + 1;
	end

	// Phase 8
	//
	// Output result for previous test
	//
	if (!err)
		$display(" OK");
	else
		failed;

end
endtask

//
// Test interrupts
//
task test_ints;
integer		l1, l2, l3, l4;
integer		i, rnd, err;
integer		r1;
begin

	$write("  Testing control bit RGPIO_CTRL[INTE] and RGPIO_CTRL[INT] ...");

	//
	// Phase 1
	//
	// Generate patterns on inputs in interrupt mode
	//

	// Disable spurious interrupt monitor
	ints_disabled = 0;

	err = 0;
	for( i = 0; i < 10 * `GPIO_VERIF_INTENSITY; i = i + 1) begin

		// Set gpio_in pins
		r1 = ((1<<`GPIO_IOS)-1) & 'hffffffff;
		tb_top.gpio_mon.set_gpioin(r1);

		// Low level triggering
		setptrig(0);
		
		// Clear RGPIO_INTS
		setints(0);

		// Enable interrupts in RGPIO_CTRL
		setctrl(1 << `GPIO_RGPIO_CTRL_INTE);

		// Enable interrupts in RGPIO_INTE
		setinte(r1);

		// Advance time
		@(posedge tb_top.clk);
		@(posedge tb_top.clk);

		// Sample interrupt request. Should be zero.
		l1 = tb_top.gpio_top.wb_inta_o;

		// Clear gpio_in pins
		tb_top.gpio_mon.set_gpioin(0);

		// Advance time
		@(posedge tb_top.clk);
		@(posedge tb_top.clk);
		@(posedge tb_top.clk);

		// Sample interrupt request. Should be one.
		l2 = tb_top.gpio_top.wb_inta_o;

		// Clear interrupt request
		setctrl(0);

		// Advance time
		@(posedge tb_top.clk);
		@(posedge tb_top.clk);

		// Sample interrupt request. Should be zero.
		l3 = tb_top.gpio_top.wb_inta_o;

		// Get RGPIO_INTS. Should be nonzero.
		getints(l4);

		// Check for errors
		if (l1 || !l2 || l3 || (l4 != r1)) begin
			err = err +1;
		end
	end
		
	// Enable spurious interrupt monitor
	ints_disabled = 1;

	// Phase 2
	//
	// Check results
	//
	if (!err)
		$display(" OK");
	else
		failed;
end
endtask

//
// Test ptrig
//
task test_ptrig;
integer		l1, l2, l3;
integer		i, rnd, err;
integer		r1;
begin
	$write("  Testing ptrig features ...");

	//
	// Phase 1
	//
	// Generate patterns on inputs in interrupt mode
	//

	// Disable spurious interrupt monitor
	ints_disabled = 0;

	err = 0;
	for( i = 0; i < 10 * `GPIO_VERIF_INTENSITY; i = i + 1) begin

		// Set bits to one
		r1 = ((1<<`GPIO_IOS)-1) & 'hffffffff;

		// Set gpio_in pins
		tb_top.gpio_mon.set_gpioin('h00000000);

		// Clear old interrupts
		setints(0);

		// High level triggering
		setptrig('hffffffff);

		// Enable interrupts in RGPIO_CTRL
		setctrl(1 << `GPIO_RGPIO_CTRL_INTE);

		// Enable interrupts in RGPIO_INTE
		setinte(r1);

		// Advance time
		@(posedge tb_top.clk);
		@(posedge tb_top.clk);

		// Sample interrupt request. Should be zero.
		l1 = tb_top.gpio_top.wb_inta_o;

		// Clear gpio_in pins
		tb_top.gpio_mon.set_gpioin('hffffffff);

		// Advance time
		@(posedge tb_top.clk);
		@(posedge tb_top.clk);
		@(posedge tb_top.clk);

		// Sample interrupt request. Should be one.
		l2 = tb_top.gpio_top.wb_inta_o;

		// Clear interrupt request
		setctrl(0);
		setints(0);

		// Advance time
		@(posedge tb_top.clk);
		@(posedge tb_top.clk);

		// Sample interrupt request. Should be zero.
		l3 = tb_top.gpio_top.wb_inta_o;

		// Check for errors
		if (l1 || !l2 || l3)
			err = err +1;
	end
		
	// Enable spurious interrupt monitor
	ints_disabled = 1;

	// Phase 2
	//
	// Check results
	//
	if (!err)
		$display(" OK");
	else
		failed;
end
endtask

//
// Do continues check for interrupts
//
always @(posedge tb_top.gpio_top.wb_inta_o)
	if (ints_disabled) begin
		$display("Spurious interrupt detected. ");
		failed;
		ints_working = 9876;
		$display;
	end

//
// Start of testbench test tasks
//
integer 	i;
initial begin
`ifdef GPIO_DUMP_VCD
	$dumpfile("../out/tb_top.vcd");
	$dumpvars(0);
`endif
	nr_failed = 0;
	ints_disabled = 1;
	ints_working = 0;
	tb_top.gpio_mon.set_gpioin(0);
	tb_top.gpio_mon.set_gpioaux(0);
	tb_top.gpio_mon.set_gpioeclk(0);
	$display;
	$display("###");
	$display("### GPIO IP Core Verification ###");
	$display("###");
	$display;
	$display("I. Testing correct operation of RGPIO_CTRL control bits");
	$display;


	$write("  Testing control bit RGPIO_CTRL[ECLK] ...");
	local_errs = 0;
	for (i = 0; i < 10 * `GPIO_VERIF_INTENSITY; i = i + 1)
		test_eclk;
	if (local_errs == 0)
		$display(" OK");
	else
		failed;


	$write("  Testing control bit RGPIO_CTRL[NEC] ...");
	local_errs = 0;
	for (i = 0; i < 10 * `GPIO_VERIF_INTENSITY; i = i + 1)
		test_nec;
	if (local_errs == 0)
		$display(" OK");
	else
		failed;

	test_ints;

	$display;
	$display("II. Testing modes of operation ...");
	$display;

	test_simple;
	test_ptrig;

	$display;
	$display("###");
	$display("### FAILED TESTS: %d ###", nr_failed);
	$display("###");
	$display;
	$finish;
end

endmodule
