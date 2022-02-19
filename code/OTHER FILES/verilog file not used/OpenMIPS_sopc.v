`include	"define.v"

module OpenMIPS_sopc(
	input						clk,
	input						rst
	
	//input		[5:0]			int_i,
	);
	
	wire		[`InstAddrBus]	inst_addr;
	wire		[`InstBus]		inst;
	wire						rom_ce;
	
	wire						ram_ce;
	wire						ram_we;
	wire		[`InstAddrBus]	data_addr;
	wire		[3:0]			data_sel;
	wire		[`DataBus]		data_data;
	wire		[`DataBus]		data;
	
	wire						timer_int;
	wire		[5:0]			int_i;
	

//OpenMIPS
assign int_i = {5'b00000, timer_int};

OpenMIPS OpenMIPS0(
	.clk			(clk),
	.rst			(rst),
	
	.rom_data_i		(inst),
	
	.ram_data_i		(data),
	
	//=============================
	.rom_addr_o		(inst_addr),
	.rom_ce_o		(rom_ce),
	
	.ram_addr_o		(data_addr),
	.ram_data_o		(data_data),
	.ram_we_o		(ram_we),
	.ram_sel_o		(data_sel),
	.ram_ce_o		(ram_ce),
	
	//=============================
	.int_i			(int_i),
	
	.timer_int_o	(timer_int)
	);

//Inst_ROM
inst_rom inst_rom0(
	.ce				(rom_ce),
	.addr			(inst_addr),
	
	.inst			(inst)
	);
	
//Data_RAM
data_ram data_ram0(
	.clk			(clk),	
	.ce				(ram_ce),
	.we				(ram_we),
	.addr			(data_addr),
	.sel			(data_sel),
	.data_i			(data_data),
	
	.data_o			(data)
	);
	
endmodule