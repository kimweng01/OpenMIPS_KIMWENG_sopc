`include	"define.v"

module regfile(
	input 						clk,
	input 						rst,
	
	input	 					we,
	input		[`RegAddrBus]	waddr, //要送到的地址
	input		[`RegBus]		wdata, //要送到的數據
	
	input 						re1,
	input		[`RegAddrBus]	raddr1, //要送出的地址
	output reg	[`RegBus]		rdata1, //要送出的數據
	
	input						re2,
	input		[`RegAddrBus]	raddr2, //要送出的地址
	output reg	[`RegBus]		rdata2  //要送出的數據
	);
	
	reg 		[`RegBus]		regs [0:`RegNum-1];
	
	
always @(posedge clk) begin
	if(rst == `RstDisable)
		if((we == `WriteEnable) && (waddr!=`RegNumLog2'h0)) //被告知要送到$0就拒絕不送
			regs[waddr] <= wdata;
end	


always @(*) begin
	if(raddr1 == `RegNumLog2'h0) //來源地址是$0的話就不拿 直接去拿0
		rdata1 = `ZeroWord;
	else if((raddr1 == waddr) && (we == `WriteEnable) && (re1 == `ReadEnable))
		rdata1 = wdata; //跳過第二階段
	else if(re1 == `ReadEnable)
		rdata1 = regs[raddr1];
	else
		rdata1 = `ZeroWord;
end

always @(*) begin
	if(raddr2 == `RegNumLog2'h0) //來源地址是$0的話就不拿 直接去拿0
		rdata2=`ZeroWord;
	else if((raddr2 == waddr) && (we == `WriteEnable) && (re2 == `ReadEnable))
		rdata2 = wdata; //跳過第二階段
	else if(re2 == `ReadEnable)
		rdata2 = regs[raddr2];
	else
		rdata2 = `ZeroWord;
end

endmodule