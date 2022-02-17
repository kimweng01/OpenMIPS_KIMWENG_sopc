`include	"define.v"

module id_ex(
	input						clk,
	input						rst,
	
	input		[`RegBus]		id_inst,
	
	input		[`AluOpBus]		id_aluop,
	input		[`AluSelBus]	id_alusel,
	
	input		[`RegBus]		id_reg1,
	input		[`RegBus]		id_reg2,
	
	input		[`RegAddrBus]	id_wd, //write data
	input						id_wreg, //we
	
	input		[5:0]			stall,
	input						flush,
	
	input		[`RegBus]		id_link_addr,
	input						id_dlyslot_now,
	input						next_dlyslot,
	
	input		[`RegBus]		id_current_inst_addr,
	input		[`RegBus]		id_excepttype,	
	
	//==========================================
	output reg	[`RegBus]		ex_inst,
	
	output reg	[`AluOpBus]		ex_aluop,
	output reg	[`AluSelBus]	ex_alusel,
	
	output reg	[`RegBus]		ex_reg1,
	output reg	[`RegBus]		ex_reg2,
	output reg	[`RegAddrBus]	ex_wd,
	output reg					ex_wreg,
	
	output reg	[`RegBus]		ex_link_addr,
	output reg					ex_dlyslot_now,
	output reg					dlyslot_now,
	
	output reg	[`RegBus]		ex_current_inst_addr,
	output reg	[`RegBus]		ex_excepttype
	);
	

always @(posedge clk) begin
	if(rst == `RstEnable) begin
		ex_inst				<= `ZeroWord;
	
		ex_aluop			<= `EXE_NOP_OP;
		ex_alusel			<= `EXE_RES_NOP;
				
		ex_reg1 			<= `ZeroWord;
		ex_reg2 			<= `ZeroWord;
				
		ex_wd 				<= `NOPRegAddr;
		ex_wreg				<= `WriteDisable;
		
		ex_link_addr		<= `ZeroWord;
		ex_dlyslot_now  	<= `NotInDelaySlot;
		dlyslot_now			<= `NotInDelaySlot;
		
	end else if(flush == 1'b1) begin
		ex_inst				<= `ZeroWord;
		
		ex_aluop			<= `EXE_NOP_OP;
		ex_alusel			<= `EXE_RES_NOP;
				
		ex_reg1 			<= `ZeroWord;
		ex_reg2 			<= `ZeroWord;
				
		ex_wd 				<= `NOPRegAddr;
		ex_wreg				<= `WriteDisable;
		
		ex_link_addr		<= `ZeroWord;
		ex_dlyslot_now  	<= `NotInDelaySlot;
		dlyslot_now			<= `NotInDelaySlot;
		
		ex_current_inst_addr<= `ZeroWord;
		ex_excepttype		<= `ZeroWord;
		
	end else if(stall[2] == `Stop && stall[3] == `NoStop) begin
		ex_inst				<= `ZeroWord;
	
		ex_aluop			<= `EXE_NOP_OP;
		ex_alusel			<= `EXE_RES_NOP;
				
		ex_reg1 			<= `ZeroWord;
		ex_reg2 			<= `ZeroWord;
				
		ex_wd 				<= `NOPRegAddr;
		ex_wreg				<= `WriteDisable; 
		
		ex_link_addr		<= `ZeroWord;
		ex_dlyslot_now  	<= `NotInDelaySlot;
		//dlyslot_now			<= `dlyslot_now;
		
		ex_current_inst_addr<= `ZeroWord;
		ex_excepttype		<= `ZeroWord;
		
	end else if(stall[2] == `NoStop) begin
		ex_inst				<= id_inst;
	
		ex_aluop			<= id_aluop;
        ex_alusel			<= id_alusel;
        
        ex_reg1 			<= id_reg1;
        ex_reg2 			<= id_reg2;
        
        ex_wd 				<= id_wd;
        ex_wreg				<= id_wreg; //id_wreg=wreg_o= 0 or 1
		
		ex_link_addr		<= id_link_addr;
		ex_dlyslot_now  	<= id_dlyslot_now;
		dlyslot_now			<= next_dlyslot;
		
		ex_current_inst_addr<= id_current_inst_addr;
		ex_excepttype		<= id_excepttype;
	end                     
end

endmodule