`include	"define.v"

module inst_rom(
	input						ce,
	input		[`InstAddrBus]	addr,
	
	output	reg	[`InstBus]		inst
	);
	
	reg			[`InstBus]		inst_mem	[0:`InstMemNum-1]; //InstMemNum=13170=128KB
	

initial $readmemh("inst_rom.txt",inst_mem);
	
always @(*)	begin
	if(ce == `ChipDisable)
		inst = `ZeroWord;
	else
		inst = inst_mem[addr[`InstMemNumLog2+1:0]]; // InstMemNumLog2=17
end

endmodule