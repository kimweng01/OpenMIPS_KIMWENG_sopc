`include	"define.v"

module id(
	//input						rst,
	
	input		[`InstAddrBus]	pc_i,
	input		[`InstBus]		inst_i,
	
	input		[`RegBus]		reg1_data_i,
	input		[`RegBus]		reg2_data_i,
	
	input						ex_wreg_i,
	input 		[`RegBus]		ex_wdata_i,
	input 		[`RegAddrBus]	ex_wd_i,
	input		[`AluOpBus]		ex_aluop_i, //load dep
	
	input 						mem_wreg_i,
	input		[`RegBus]		mem_wdata_i,
	input		[`RegAddrBus]	mem_wd_i,
	
	input						dlyslot_now_i,
	
	//input						stallreq_from_id,
	//input						stallreq_from_ex,
	//===================================================
	output		[`RegBus]		inst_o,
	
	output reg					reg1_read_o,
	output reg					reg2_read_o,
	output reg	[`RegAddrBus]	reg1_addr_o,
	output reg	[`RegAddrBus]	reg2_addr_o,
	
	output reg	[`AluOpBus]		aluop_o,
	output reg	[`AluSelBus]	alusel_o,
	
	output reg	[`RegBus]		reg1_o,
	output reg	[`RegBus]		reg2_o,
	output reg	[`RegAddrBus]	wd_o,
	output reg					wreg_o,
	
	output reg	[`RegBus]		link_addr_o,		
	output reg	[`RegBus]		branch_target_address_o,
	output reg					branch_flag_o,		
	output reg					next_dlyslot_o, //Next is in delayslot.
	output 						dlyslot_now_o,  //Is now in delayslot?

	//output reg	[5:0]			stall
	output 						stallreq,
	
	output 		[`RegBus]		excepttype_o,
	output		[`RegBus]		current_inst_addr_o
	);
	
	
	reg			[`RegBus]		imm;
	
	wire 		[5:0]			op  = inst_i[31:26];
	wire 		[4:0]			op2 = inst_i[10:6];
	wire 		[5:0]			op3 = inst_i[5:0];
	wire 		[4:0]			op4 = inst_i[20:16];
	wire 		[4:0]			op5 = inst_i[25:21];
	
	wire		[`RegBus]		pc_plus_4;
	wire		[`RegBus]		pc_plus_8;
	wire		[`RegBus]		imm_sll2_signedext;
	
	//--------------------------------------
	//wire						stallreq;
	wire						load_dep;
		
	reg							stallreq_from_id1;
	reg							stallreq_from_id2;
	wire						stallreq_from_id;
	
	reg							eret;
	reg							syscall;
	reg							instvalid;


//#################################################################################
assign inst_o = inst_i;

//-----------------------------------
assign pc_plus_8 = pc_i + 4'h8; //you need to ignore delayslot
assign pc_plus_4 = pc_i + 3'h4;

assign imm_sll2_signedext = { {14{inst_i[15]}}, inst_i[15:0], 2'b00};


assign dlyslot_now_o = dlyslot_now_i;

//-------------------------------------
assign current_inst_addr_o = pc_i;
assign excepttype_o		   = {19'b0, eret, 2'b0, instvalid, syscall, 8'b00000000};


//================================================================
always @(*)	begin
	/*PARAM	
	wd_o				write address
	wreg_o				write enable?
	`InstValid			Instruction valid?
	
	reg?_read_o = 1'b1;	read address
	reg?_read_o = 0; 	read imm
	
	lui; load upper imm
	
	s: shift
	r: right	l: left
	l: logic	a: arithmetic
	(imm)		v: variable
	
	s: set
	l: less
	t: than...
	
	c: count
	l: leading
	z: zeros	o: ones
	
	b: branch
	eq:equal	nq:not equal
	
	j: jump
	r: register 	al: and link
	
	link_addr_o: 				return address
	branch_target_address_o:	target address
	
	*/

	
	reg1_addr_o = inst_i[25:21]; //rs
	reg2_addr_o = inst_i[20:16]; //rt
	
	syscall		= `False_v;
	eret		= `False_v;
	
	
	if(inst_i[31:21] == 11'b01000000000  &&  
		inst_i[10:0] == 11'b00000000000) begin //cp0
		wd_o						=	inst_i[20:16];
		wreg_o						=	`WriteEnable;
		aluop_o						=	`EXE_MFC0_OP;
		alusel_o					=	`EXE_RES_MOVE;
		reg1_read_o					= 	1'b0;
		reg2_read_o					=	1'b0;
		imm							=	`ZeroWord;
		link_addr_o					=	`ZeroWord;
		branch_target_address_o		=	`ZeroWord;
		branch_flag_o				=	`NotBranch;
		next_dlyslot_o				=	`NotInDelaySlot;
		instvalid 					=	`InstValid;
		
	end else if(inst_i[31:21] == 11'b01000000100  &&  
				inst_i[10:0] == 11'b00000000000) begin //cp0
		wd_o						=	`NOPRegAddr;
		wreg_o						=	`WriteDisable;
		aluop_o						=	`EXE_MTC0_OP;
		alusel_o					=	`EXE_RES_MOVE;
		reg1_read_o					= 	1'b0;
		reg2_read_o					=	1'b1; //read inst_i[20:16], diff from text_book!
		imm							=	`ZeroWord;
		link_addr_o					=	`ZeroWord;
		branch_target_address_o		=	`ZeroWord;
		branch_flag_o				=	`NotBranch;
		next_dlyslot_o				=	`NotInDelaySlot;
		instvalid 					=	`InstValid;
	
	end else if(inst_i == `EXE_ERET) begin
		wd_o						=	`NOPRegAddr;
		wreg_o						=	`WriteDisable;
		aluop_o						=	`EXE_ERET_OP;
		alusel_o					=	`EXE_RES_NOP;
		reg1_read_o					= 	1'b0;
		reg2_read_o					=	1'b0;
		imm							=	`ZeroWord;
		link_addr_o					=	`ZeroWord;
		branch_target_address_o		=	`ZeroWord;
		branch_flag_o				=	`NotBranch;
		next_dlyslot_o				=	`NotInDelaySlot;
		instvalid 					=	`InstValid;
		
		eret						=	`True_v;
		
	end else if(op == `EXE_SPECIAL_INST) begin //inst_i[31:26] == 0
		wd_o = inst_i[15:11]; //rd
		imm  = `ZeroWord; //imm useless
		
		case(op3)
			`EXE_TEQ: begin
				wreg_o						=	`WriteDisable;
				aluop_o						=	`EXE_TEQ_OP;
				alusel_o					=	`EXE_RES_NOP;
				reg1_read_o					= 	1'b1;
				reg2_read_o					=	1'b1;
				link_addr_o					=	`ZeroWord;
				branch_target_address_o		=	`ZeroWord;
				branch_flag_o				=	`NotBranch;
				next_dlyslot_o				=	`NotInDelaySlot;
				instvalid 					=	`InstValid;
			end 
			`EXE_TGE: begin
				wreg_o						=	`WriteDisable;
				aluop_o						=	`EXE_TGE_OP;
				alusel_o					=	`EXE_RES_NOP;
				reg1_read_o					= 	1'b1;
				reg2_read_o					=	1'b1;
				link_addr_o					=	`ZeroWord;
				branch_target_address_o		=	`ZeroWord;
				branch_flag_o				=	`NotBranch;
				next_dlyslot_o				=	`NotInDelaySlot;
				instvalid 					=	`InstValid;
			end
			`EXE_TGEU: begin
				wreg_o						=	`WriteDisable;
				aluop_o						=	`EXE_TGEU_OP;
				alusel_o					=	`EXE_RES_NOP;
				reg1_read_o					= 	1'b1;
				reg2_read_o					=	1'b1;
				link_addr_o					=	`ZeroWord;
				branch_target_address_o		=	`ZeroWord;
				branch_flag_o				=	`NotBranch;
				next_dlyslot_o				=	`NotInDelaySlot;
				instvalid 					=	`InstValid;
			end
			`EXE_TLT: begin
				wreg_o						=	`WriteDisable;
				aluop_o						=	`EXE_TLT_OP;
				alusel_o					=	`EXE_RES_NOP;
				reg1_read_o					= 	1'b1;
				reg2_read_o					=	1'b1;
				link_addr_o					=	`ZeroWord;
				branch_target_address_o		=	`ZeroWord;
				branch_flag_o				=	`NotBranch;
				next_dlyslot_o				=	`NotInDelaySlot;
				instvalid 					=	`InstValid;
			end
			`EXE_TLTU: begin
				wreg_o						=	`WriteDisable;
				aluop_o						=	`EXE_TLTU_OP;
				alusel_o					=	`EXE_RES_NOP;
				reg1_read_o					= 	1'b1;
				reg2_read_o					=	1'b1;
				link_addr_o					=	`ZeroWord;
				branch_target_address_o		=	`ZeroWord;
				branch_flag_o				=	`NotBranch;
				next_dlyslot_o				=	`NotInDelaySlot;
				instvalid 					=	`InstValid;
			end
			`EXE_TNE: begin
				wreg_o						=	`WriteDisable;
				aluop_o						=	`EXE_TNE_OP;
				alusel_o					=	`EXE_RES_NOP;
				reg1_read_o					= 	1'b1;
				reg2_read_o					=	1'b1;
				link_addr_o					=	`ZeroWord;
				branch_target_address_o		=	`ZeroWord;
				branch_flag_o				=	`NotBranch;
				next_dlyslot_o				=	`NotInDelaySlot;
				instvalid 					=	`InstValid;
			end
			`EXE_SYSCALL: begin
				wreg_o						=	`WriteDisable;
				aluop_o						=	`EXE_SYSCALL_OP;
				alusel_o					=	`EXE_RES_NOP;
				reg1_read_o					= 	1'b0;
				reg2_read_o					=	1'b0;
				link_addr_o					=	`ZeroWord;
				branch_target_address_o		=	`ZeroWord;
				branch_flag_o				=	`NotBranch;
				next_dlyslot_o				=	`NotInDelaySlot;
				instvalid 					=	`InstValid;
				
				syscall						=	`True_v;
			//---------------------------------------
			end
			`EXE_OR: begin
				wreg_o						=	`WriteEnable;
				aluop_o						=	`EXE_OR_OP;
				alusel_o					=	`EXE_RES_LOGIC;
				reg1_read_o					= 	1'b1;
				reg2_read_o					=	1'b1;
				link_addr_o					=	`ZeroWord;
				branch_target_address_o		=	`ZeroWord;
				branch_flag_o				=	`NotBranch;
				next_dlyslot_o				=	`NotInDelaySlot;
				instvalid 					=	`InstValid;
			end				
			`EXE_AND: begin				
				wreg_o						=	`WriteEnable;
				aluop_o						=	`EXE_AND_OP;
				alusel_o					=	`EXE_RES_LOGIC;
				reg1_read_o					= 	1'b1;
				reg2_read_o					=	1'b1;
				link_addr_o					=	`ZeroWord;
				branch_target_address_o		=	`ZeroWord;
				branch_flag_o				=	`NotBranch;
				next_dlyslot_o				=	`NotInDelaySlot;
				instvalid 					=	`InstValid;
			end				
			`EXE_XOR: begin				
				wreg_o						=	`WriteEnable;
				aluop_o						=	`EXE_XOR_OP;	
				alusel_o					=	`EXE_RES_LOGIC;	
				reg1_read_o					= 	1'b1;
				reg2_read_o					=	1'b1;
				link_addr_o					=	`ZeroWord;
				branch_target_address_o		=	`ZeroWord;
				branch_flag_o				=	`NotBranch;
				next_dlyslot_o				=	`NotInDelaySlot;
				instvalid 					=	`InstValid;	
			end					
			`EXE_NOR: begin				
				wreg_o						=	`WriteEnable;	
				aluop_o						=	`EXE_NOR_OP;	
				alusel_o					=	`EXE_RES_LOGIC;	
				reg1_read_o					= 	1'b1;
				reg2_read_o					=	1'b1;
				link_addr_o					=	`ZeroWord;
				branch_target_address_o		=	`ZeroWord;
				branch_flag_o				=	`NotBranch;
				next_dlyslot_o				=	`NotInDelaySlot;
				instvalid 					=	`InstValid;	
			end				
			//------------------------------------
			`EXE_SLLV: begin				
				wreg_o						=	`WriteEnable;	
				aluop_o						=	`EXE_SLL_OP;	
				alusel_o					=	`EXE_RES_SHIFT;	
				reg1_read_o					= 	1'b1;
				reg2_read_o					=	1'b1;
				link_addr_o					=	`ZeroWord;
				branch_target_address_o		=	`ZeroWord;
				branch_flag_o				=	`NotBranch;
				next_dlyslot_o				=	`NotInDelaySlot;
				instvalid 					=	`InstValid;	
			end					
			`EXE_SRLV: begin				
				wreg_o						=	`WriteEnable;
				aluop_o						=	`EXE_SRL_OP;	
				alusel_o					=	`EXE_RES_SHIFT;	
				reg1_read_o					= 	1'b1;
				reg2_read_o					=	1'b1;
				link_addr_o					=	`ZeroWord;
				branch_target_address_o		=	`ZeroWord;
				branch_flag_o				=	`NotBranch;
				next_dlyslot_o				=	`NotInDelaySlot;
				instvalid 					=	`InstValid;	
			end				
			`EXE_SRAV: begin				
				wreg_o						=	`WriteEnable;
				aluop_o						=	`EXE_SRA_OP;	
				alusel_o					=	`EXE_RES_SHIFT;
				reg1_read_o					= 	1'b1;
				reg2_read_o					=	1'b1;
				link_addr_o					=	`ZeroWord;
				branch_target_address_o		=	`ZeroWord;
				branch_flag_o				=	`NotBranch;
				next_dlyslot_o				=	`NotInDelaySlot;
				instvalid 					=	`InstValid;	
			end				
			`EXE_SYNC: begin				
				wreg_o						=	`WriteDisable;
				aluop_o						=	`EXE_NOP_OP;	
				alusel_o					=	`EXE_RES_NOP;
				reg1_read_o					= 	0;
				reg2_read_o					=	1'b1;
				link_addr_o					=	`ZeroWord;
				branch_target_address_o		=	`ZeroWord;
				branch_flag_o				=	`NotBranch;
				next_dlyslot_o				=	`NotInDelaySlot;
				instvalid 					=	`InstValid;	
			end				
			//------------------------------------
			`EXE_MFHI: begin				
				wreg_o						=	`WriteEnable;
				aluop_o						=	`EXE_MFHI_OP;	
				alusel_o					=	`EXE_RES_MOVE;
				reg1_read_o					= 	0;	//need not to read
				reg2_read_o					=	0;
				link_addr_o					=	`ZeroWord;
				branch_target_address_o		=	`ZeroWord;
				branch_flag_o				=	`NotBranch;
				next_dlyslot_o				=	`NotInDelaySlot;
				instvalid 					=	`InstValid;	
			end				
			`EXE_MFLO: begin				
				wreg_o						=	`WriteEnable;
				aluop_o						=	`EXE_MFLO_OP;	
				alusel_o					=	`EXE_RES_MOVE;
				reg1_read_o					= 	0;	//need not to read
				reg2_read_o					=	0;
				link_addr_o					=	`ZeroWord;
				branch_target_address_o		=	`ZeroWord;
				branch_flag_o				=	`NotBranch;
				next_dlyslot_o				=	`NotInDelaySlot;
				instvalid 					=	`InstValid;	
			end				
			`EXE_MTHI: begin				 //rd must == 0
				wreg_o						=	`WriteDisable;
				aluop_o						=	`EXE_MTHI_OP;	
				alusel_o					=	`EXE_RES_NOP; //neet not to write regefile, useless
				reg1_read_o					= 	1'b1;	
				reg2_read_o					=	0;
				link_addr_o					=	`ZeroWord;
				branch_target_address_o		=	`ZeroWord;
				branch_flag_o				=	`NotBranch;
				next_dlyslot_o				=	`NotInDelaySlot;
				instvalid 					=	`InstValid;	
			end				
			`EXE_MTLO: begin				 //rd must == 0
				wreg_o						=	`WriteDisable;
				aluop_o						=	`EXE_MTLO_OP;	
				alusel_o					=	`EXE_RES_NOP; //neet not to write regefile, useless
				reg1_read_o					= 	1'b1;
				reg2_read_o					=	0;
				link_addr_o					=	`ZeroWord;
				branch_target_address_o		=	`ZeroWord;
				branch_flag_o				=	`NotBranch;
				next_dlyslot_o				=	`NotInDelaySlot;
				instvalid 					=	`InstValid;	
			end				
			`EXE_MOVN: begin							
				aluop_o						=	`EXE_MOVN_OP;	
				alusel_o					=	`EXE_RES_MOVE;
				reg1_read_o					= 	1'b1;	
				reg2_read_o					=	1'b1;
				link_addr_o					=	`ZeroWord;
				branch_target_address_o		=	`ZeroWord;
				branch_flag_o				=	`NotBranch;
				next_dlyslot_o				=	`NotInDelaySlot;
				instvalid 					=	`InstValid;	
				if(reg2_o != `ZeroWord) 
					wreg_o					=	`WriteEnable;
				else				
					wreg_o					= 	`WriteDisable;
			end				
			`EXE_MOVZ: begin								
				aluop_o						=	`EXE_MOVZ_OP;	
				alusel_o					=	`EXE_RES_MOVE;
				reg1_read_o					= 	1'b1;
				reg2_read_o					=	1'b1;
				link_addr_o					=	`ZeroWord;
				branch_target_address_o		=	`ZeroWord;
				branch_flag_o				=	`NotBranch;
				next_dlyslot_o				=	`NotInDelaySlot;
				instvalid 					=	`InstValid;	
				if(reg2_o == `ZeroWord) 
					wreg_o 					= 	`WriteEnable;
				else					
					wreg_o 					= 	`WriteDisable;
			end				
			//------------------------------------
			`EXE_SLT: begin				
				wreg_o 						=	 `WriteEnable;
				aluop_o						=	`EXE_SLT_OP;	
				alusel_o					=	`EXE_RES_ARITHMETIC;
				reg1_read_o					= 	1'b1;
				reg2_read_o					=	1'b1;
				link_addr_o					=	`ZeroWord;
				branch_target_address_o		=	`ZeroWord;
				branch_flag_o				=	`NotBranch;
				next_dlyslot_o				=	`NotInDelaySlot;
				instvalid 					=	`InstValid;	
			end				
			`EXE_SLTU: begin				
				wreg_o 						= 	`WriteEnable;				
				aluop_o						=	`EXE_SLTU_OP;	
				alusel_o					=	`EXE_RES_ARITHMETIC;
				reg1_read_o					= 	1'b1;
				reg2_read_o					=	1'b1;
				link_addr_o					=	`ZeroWord;
				branch_target_address_o		=	`ZeroWord;
				branch_flag_o				=	`NotBranch;
				next_dlyslot_o				=	`NotInDelaySlot;
				instvalid 					=	`InstValid;	
			//------------------------------------
			end				
			`EXE_ADD: begin				
				wreg_o 						= 	`WriteEnable;				
				aluop_o						=	`EXE_ADD_OP;	
				alusel_o					=	`EXE_RES_ARITHMETIC;
				reg1_read_o					= 	1'b1;
				reg2_read_o					=	1'b1;
				link_addr_o					=	`ZeroWord;
				branch_target_address_o		=	`ZeroWord;
				branch_flag_o				=	`NotBranch;
				next_dlyslot_o				=	`NotInDelaySlot;
				instvalid 					=	`InstValid;	
			end				
			`EXE_ADDU: begin				
				wreg_o 						= 	`WriteEnable;				
				aluop_o						=	`EXE_ADDU_OP;	
				alusel_o					=	`EXE_RES_ARITHMETIC;
				reg1_read_o					= 	1'b1;
				reg2_read_o					=	1'b1;
				link_addr_o					=	`ZeroWord;
				branch_target_address_o		=	`ZeroWord;
				branch_flag_o				=	`NotBranch;
				next_dlyslot_o				=	`NotInDelaySlot;
				instvalid 					=	`InstValid;	
			end				
			`EXE_SUB: begin				
				wreg_o 						= 	`WriteEnable;				
				aluop_o						=	`EXE_SUB_OP;	
				alusel_o					=	`EXE_RES_ARITHMETIC;
				reg1_read_o					= 	1'b1;
				reg2_read_o					=	1'b1;
				link_addr_o					=	`ZeroWord;
				branch_target_address_o		=	`ZeroWord;
				branch_flag_o				=	`NotBranch;
				next_dlyslot_o				=	`NotInDelaySlot;
				instvalid 					=	`InstValid;	
			end				
			`EXE_SUBU: begin				
				wreg_o 						= 	`WriteEnable;				
				aluop_o						=	`EXE_SUBU_OP;	
				alusel_o					=	`EXE_RES_ARITHMETIC;
				reg1_read_o					= 	1'b1;
				reg2_read_o					=	1'b1;
				link_addr_o					=	`ZeroWord;
				branch_target_address_o		=	`ZeroWord;
				branch_flag_o				=	`NotBranch;
				next_dlyslot_o				=	`NotInDelaySlot;
				instvalid 					=	`InstValid;	
			end				
			`EXE_MULT: begin				
				wreg_o 						= 	`WriteDisable;				
				aluop_o						=	`EXE_MULT_OP;	
				alusel_o					=	`EXE_RES_ARITHMETIC;
				reg1_read_o					= 	1'b1;
				reg2_read_o					=	1'b1;
				link_addr_o					=	`ZeroWord;
				branch_target_address_o		=	`ZeroWord;
				branch_flag_o				=	`NotBranch;
				next_dlyslot_o				=	`NotInDelaySlot;
				instvalid 					=	`InstValid;	
			end				
			`EXE_MULTU: begin
				wreg_o 						= 	`WriteDisable;				
				aluop_o						=	`EXE_MULTU_OP;	
				alusel_o					=	`EXE_RES_ARITHMETIC;
				reg1_read_o					= 	1'b1;
				reg2_read_o					=	1'b1;
				link_addr_o					=	`ZeroWord;
				branch_target_address_o		=	`ZeroWord;
				branch_flag_o				=	`NotBranch;
				next_dlyslot_o				=	`NotInDelaySlot;
				instvalid 					=	`InstValid;	
			end
			`EXE_DIV: begin
				wreg_o						= 	`WriteDisable;				
				aluop_o						=	`EXE_DIV_OP;	
				alusel_o					=	`EXE_RES_NOP;
				reg1_read_o					= 	1'b1;
				reg2_read_o					=	1'b1;
				link_addr_o					=	`ZeroWord;
				branch_target_address_o		=	`ZeroWord;
				branch_flag_o				=	`NotBranch;
				next_dlyslot_o				=	`NotInDelaySlot;
				instvalid 					=	`InstValid;
			end
			`EXE_DIVU: begin
				wreg_o 						= 	`WriteDisable;				
				aluop_o						=	`EXE_DIVU_OP;	
				alusel_o					=	`EXE_RES_NOP;
				reg1_read_o					= 	1'b1;
				reg2_read_o					=	1'b1;
				link_addr_o					=	`ZeroWord;
				branch_target_address_o		=	`ZeroWord;
				branch_flag_o				=	`NotBranch;
				next_dlyslot_o				=	`NotInDelaySlot;
				instvalid 					=	`InstValid;
			end				
			//--------------------------------------
			`EXE_JR: begin
				wreg_o 						= 	`WriteDisable;				
				aluop_o						=	`EXE_NOP_OP;	
				alusel_o					=	`EXE_RES_NOP;
				reg1_read_o					= 	1'b1;
				reg2_read_o					=	0;
				link_addr_o					=	`ZeroWord;
				branch_target_address_o		=	reg1_o;
				branch_flag_o				=	`Branch;
				next_dlyslot_o				=	`InDelaySlot;
				instvalid 					=	`InstValid;
			end
			`EXE_JALR: begin
				wreg_o 						= 	`WriteEnable;				
				aluop_o						=	`EXE_BRANCH_JUMP_OP;	
				alusel_o					=	`EXE_RES_JUMP_BRANCH;
				reg1_read_o					= 	1'b1;
				reg2_read_o					=	0;
				link_addr_o					=	pc_plus_8;
				branch_target_address_o		=	reg1_o;
				branch_flag_o				=	`Branch;
				next_dlyslot_o				=	`InDelaySlot;
				instvalid 					=	`InstValid;
			end			
			//--------------------------------------
			`EXE_SLL: begin
				wreg_o						=	`WriteEnable;
				aluop_o						=	`EXE_SLL_OP;
				alusel_o					=	`EXE_RES_SHIFT;
				reg1_read_o					= 	0;
				reg2_read_o					=	1'b1;
				imm 						= 	{27'h0, inst_i[10:6]};
				link_addr_o					=	`ZeroWord;
				branch_target_address_o		=	`ZeroWord;
				branch_flag_o				=	`NotBranch;
				next_dlyslot_o				=	`NotInDelaySlot;
				instvalid 					=	`InstValid;
			end				
			`EXE_SRL: begin				
				wreg_o						=	`WriteEnable;
				aluop_o						=	`EXE_SRL_OP;
				alusel_o					=	`EXE_RES_SHIFT;
				reg1_read_o					= 	0;
				reg2_read_o					=	1'b1;
				imm 						= 	{27'h0, inst_i[10:6]};
				link_addr_o					=	`ZeroWord;
				branch_target_address_o		=	`ZeroWord;
				branch_flag_o				=	`NotBranch;
				next_dlyslot_o				=	`NotInDelaySlot;
				instvalid 					=	`InstValid;
			end				
			`EXE_SRA: begin				
				wreg_o						=	`WriteEnable;
				aluop_o						=	`EXE_SRA_OP;
				alusel_o					=	`EXE_RES_SHIFT;
				reg1_read_o					= 	0;
				reg2_read_o					=	1'b1;
				imm 						= 	{27'h0, inst_i[10:6]};
				link_addr_o					=	`ZeroWord;
				branch_target_address_o		=	`ZeroWord;
				branch_flag_o				=	`NotBranch;
				next_dlyslot_o				=	`NotInDelaySlot;
				instvalid 					=	`InstValid;
			end				
			//------------------------------------
			default: begin				
				wreg_o						=	`WriteDisable;
				aluop_o						=	`EXE_NOP_OP;	
				alusel_o					=	`EXE_RES_NOP;
				reg1_read_o					= 	0;	
				reg2_read_o					=	0;
				imm 						= 	`ZeroWord;
				link_addr_o					=	`ZeroWord;
				branch_target_address_o		=	`ZeroWord;
				branch_flag_o				=	`NotBranch;
				next_dlyslot_o				=	`NotInDelaySlot;
				instvalid 					=	`InstInvalid;	
			end
		endcase
			
	//==============================================
	end else if(op == `EXE_SPECIAL2_INST) begin	
		wd_o = inst_i[15:11]; //rd
		imm  = `ZeroWord; //imm useless
		case(op3)
			`EXE_CLZ: begin
				wreg_o						= 	`WriteEnable;				
				aluop_o						=	`EXE_CLZ_OP;	
				alusel_o					=	`EXE_RES_ARITHMETIC;
				reg1_read_o					= 	1'b1;	
				reg2_read_o					=	0;
				link_addr_o					=	`ZeroWord;
				branch_target_address_o		=	`ZeroWord;
				branch_flag_o				=	`NotBranch;
				next_dlyslot_o				=	`NotInDelaySlot;
				instvalid 					=	`InstValid;	
			end				
			`EXE_CLO: begin				
				wreg_o						= 	`WriteEnable;				
				aluop_o						=	`EXE_CLO_OP;	
				alusel_o					=	`EXE_RES_ARITHMETIC;
				reg1_read_o					= 	1'b1;	
				reg2_read_o					=	0;
				link_addr_o					=	`ZeroWord;
				branch_target_address_o		=	`ZeroWord;
				branch_flag_o				=	`NotBranch;
				next_dlyslot_o				=	`NotInDelaySlot;
				instvalid 					=	`InstValid;	
			end					
			`EXE_MUL: begin					
				wreg_o 						= 	`WriteEnable;				
				aluop_o						=	`EXE_MUL_OP;	
				alusel_o					=	`EXE_RES_MUL;
				reg1_read_o					= 	1'b1;	
				reg2_read_o					=	1'b1;
				link_addr_o					=	`ZeroWord;
				branch_target_address_o		=	`ZeroWord;
				branch_flag_o				=	`NotBranch;
				next_dlyslot_o				=	`NotInDelaySlot;
				instvalid 					=	`InstValid;	
			end				
			//---------------------------------------
			`EXE_MADD: begin				
				wreg_o						=	`WriteDisable;
				aluop_o						=	`EXE_MADD_OP;	
				alusel_o					=	`EXE_RES_NOP; //write in HILO
				reg1_read_o					= 	1'b1;	
				reg2_read_o					=	1'b1;
				link_addr_o					=	`ZeroWord;
				branch_target_address_o		=	`ZeroWord;
				branch_flag_o				=	`NotBranch;
				next_dlyslot_o				=	`NotInDelaySlot;
				instvalid 					=	`InstValid;	
			end					
			`EXE_MADDU: begin	
				wreg_o						=	`WriteDisable;
				aluop_o						=	`EXE_MADDU_OP;
				alusel_o					=	`EXE_RES_NOP; //write in HILO	
				reg1_read_o					= 	1'b1;	
				reg2_read_o					=	1'b1;
				link_addr_o					=	`ZeroWord;
				branch_target_address_o		=	`ZeroWord;
				branch_flag_o				=	`NotBranch;
				next_dlyslot_o				=	`NotInDelaySlot;
				instvalid 					=	`InstValid;	
			end					
			`EXE_MSUB: begin				
				wreg_o						=	`WriteDisable;
				aluop_o						=	`EXE_MSUB_OP;	
				alusel_o					=	`EXE_RES_NOP; //write in HILO	
				reg1_read_o					= 	1'b1;	
				reg2_read_o					=	1'b1;
				link_addr_o					=	`ZeroWord;
				branch_target_address_o		=	`ZeroWord;
				branch_flag_o				=	`NotBranch;
				next_dlyslot_o				=	`NotInDelaySlot;
				instvalid 					=	`InstValid;	
			end					
			`EXE_MSUBU: begin	
				wreg_o						=	`WriteDisable;
				aluop_o						=	`EXE_MSUBU_OP;	
				alusel_o					=	`EXE_RES_NOP; //write in HILO	
				reg1_read_o					= 	1'b1;	
				reg2_read_o					=	1'b1;
				link_addr_o					=	`ZeroWord;
				branch_target_address_o		=	`ZeroWord;
				branch_flag_o				=	`NotBranch;
				next_dlyslot_o				=	`NotInDelaySlot;
				instvalid 					=	`InstValid;	
			end					
			//-----------------------------------
			default: begin					
				wreg_o						=	`WriteDisable;
				aluop_o						=	`EXE_NOP_OP;	
				alusel_o					=	`EXE_RES_NOP;
				reg1_read_o					= 	0;	
				reg2_read_o					=	0;
				link_addr_o					=	`ZeroWord;
				branch_target_address_o		=	`ZeroWord;
				branch_flag_o				=	`NotBranch;
				next_dlyslot_o				=	`NotInDelaySlot;
				instvalid 					=	`InstInvalid;
			end
		endcase
		
	//======================================================
	end else if(op == `EXE_REGIMM_INST) begin
		case(op4)
			`EXE_TEQI: begin
				wd_o						=	`NOPRegAddr;
				wreg_o						=	`WriteDisable;
				aluop_o						=	`EXE_TEQI_OP;	
				alusel_o					=	`EXE_RES_NOP;
				reg1_read_o					= 	1'b1;	
				reg2_read_o					=	0;
				imm 						=	{ {16{inst_i[15]}}, inst_i[15:0] };
				link_addr_o					=	`ZeroWord;
				branch_target_address_o		=	`ZeroWord;
				branch_flag_o				=	`NotBranch;
				next_dlyslot_o				=	`NotInDelaySlot;
				instvalid 					=	`InstValid;
			end
			`EXE_TGEI: begin
				wd_o						=	`NOPRegAddr;
				wreg_o						=	`WriteDisable;
				aluop_o						=	`EXE_TGEI_OP;	
				alusel_o					=	`EXE_RES_NOP;
				reg1_read_o					= 	1'b1;	
				reg2_read_o					=	0;
				imm 						=	{ {16{inst_i[15]}}, inst_i[15:0] };
				link_addr_o					=	`ZeroWord;
				branch_target_address_o		=	`ZeroWord;
				branch_flag_o				=	`NotBranch;
				next_dlyslot_o				=	`NotInDelaySlot;
				instvalid 					=	`InstValid;
			end 
			`EXE_TGEIU: begin
				wd_o						=	`NOPRegAddr;
				wreg_o						=	`WriteDisable;
				aluop_o						=	`EXE_TGEIU_OP;	
				alusel_o					=	`EXE_RES_NOP;
				reg1_read_o					= 	1'b1;	
				reg2_read_o					=	0;
				imm 						=	{ {16{inst_i[15]}}, inst_i[15:0] };
				link_addr_o					=	`ZeroWord;
				branch_target_address_o		=	`ZeroWord;
				branch_flag_o				=	`NotBranch;
				next_dlyslot_o				=	`NotInDelaySlot;
				instvalid 					=	`InstValid;
			end 
			`EXE_TLTI: begin
				wd_o						=	`NOPRegAddr;
				wreg_o						=	`WriteDisable;
				aluop_o						=	`EXE_TLTI_OP;	
				alusel_o					=	`EXE_RES_NOP;
				reg1_read_o					= 	1'b1;	
				reg2_read_o					=	0;
				imm 						=	{ {16{inst_i[15]}}, inst_i[15:0] };
				link_addr_o					=	`ZeroWord;
				branch_target_address_o		=	`ZeroWord;
				branch_flag_o				=	`NotBranch;
				next_dlyslot_o				=	`NotInDelaySlot;
				instvalid 					=	`InstValid;
			end 
			`EXE_TLTIU: begin
				wd_o						=	`NOPRegAddr;
				wreg_o						=	`WriteDisable;
				aluop_o						=	`EXE_TLTIU_OP;	
				alusel_o					=	`EXE_RES_NOP;
				reg1_read_o					= 	1'b1;	
				reg2_read_o					=	0;
				imm 						=	{ {16{inst_i[15]}}, inst_i[15:0] };
				link_addr_o					=	`ZeroWord;
				branch_target_address_o		=	`ZeroWord;
				branch_flag_o				=	`NotBranch;
				next_dlyslot_o				=	`NotInDelaySlot;
				instvalid 					=	`InstValid;
			end 
			`EXE_TNEI: begin
				wd_o						=	`NOPRegAddr;
				wreg_o						=	`WriteDisable;
				aluop_o						=	`EXE_TNEI_OP;	
				alusel_o					=	`EXE_RES_NOP;
				reg1_read_o					= 	1'b1;	
				reg2_read_o					=	0;
				imm 						=	{ {16{inst_i[15]}}, inst_i[15:0] };
				link_addr_o					=	`ZeroWord;
				branch_target_address_o		=	`ZeroWord;
				branch_flag_o				=	`NotBranch;
				next_dlyslot_o				=	`NotInDelaySlot;
				instvalid 					=	`InstValid;
			end 
			
			//----------------------------------
			`EXE_BGEZ: begin
				wd_o						=	`NOPRegAddr;
				wreg_o						=	`WriteDisable;
				aluop_o						=	`EXE_NOP_OP;	
				alusel_o					=	`EXE_RES_NOP;	
				reg1_read_o					= 	1'b1;	
				reg2_read_o					=	0;	
				imm 						=	`ZeroWord;
				link_addr_o					=	`ZeroWord;
				instvalid 					=	`InstValid;
				if(reg1_o[31] == 0) begin
					branch_target_address_o		=	pc_plus_4 + imm_sll2_signedext;
					branch_flag_o				=	`Branch;
					next_dlyslot_o				=	`InDelaySlot;
				end else begin
					branch_target_address_o		=	`ZeroWord;
					branch_flag_o				=	`NotBranch;
					next_dlyslot_o				=	`NotInDelaySlot;
				end
			end
			`EXE_BGEZAL: begin
				wd_o						=	5'b11111;
				wreg_o						=	`WriteEnable;
				aluop_o						=	`EXE_BRANCH_JUMP_OP;	
				alusel_o					=	`EXE_RES_JUMP_BRANCH;	
				reg1_read_o					= 	1'b1;	
				reg2_read_o					=	0;	
				imm 						=	`ZeroWord;
				link_addr_o					=	pc_plus_8;
				instvalid 					=	`InstValid;
				if(reg1_o[31] == 0) begin
					branch_target_address_o		=	pc_plus_4 + imm_sll2_signedext;
					branch_flag_o				=	`Branch;
					next_dlyslot_o				=	`InDelaySlot;
				end else begin
					branch_target_address_o		=	`ZeroWord;
					branch_flag_o				=	`NotBranch;
					next_dlyslot_o				=	`NotInDelaySlot;
				end
			end
			`EXE_BLTZ: begin
				wd_o						=	`NOPRegAddr;
				wreg_o						=	`WriteDisable;
				aluop_o						=	`EXE_NOP_OP;
				alusel_o					=	`EXE_RES_NOP;	
				reg1_read_o					= 	1'b1;	
				reg2_read_o					=	0;	
				imm 						=	`ZeroWord;
				link_addr_o					=	`ZeroWord;
				instvalid 					=	`InstValid;
				if(reg1_o[31] == 1'b1) begin
					branch_target_address_o		=	pc_plus_4 + imm_sll2_signedext;
					branch_flag_o				=	`Branch;
					next_dlyslot_o				=	`InDelaySlot;
				end else begin
					branch_target_address_o		=	`ZeroWord;
					branch_flag_o				=	`NotBranch;
					next_dlyslot_o				=	`NotInDelaySlot;
				end
			end
			`EXE_BLTZAL: begin
				wd_o						=	5'b11111; //ra
				wreg_o						=	`WriteEnable;
				aluop_o						=	`EXE_BRANCH_JUMP_OP;	
				alusel_o					=	`EXE_RES_JUMP_BRANCH;	
				reg1_read_o					= 	1'b1;	
				reg2_read_o					=	0;	
				imm 						=	`ZeroWord;
				link_addr_o					=	pc_plus_8;
				instvalid 					=	`InstValid;
				if(reg1_o[31] == 1'b1) begin
					branch_target_address_o		=	pc_plus_4 + imm_sll2_signedext;
					branch_flag_o				=	`Branch;
					next_dlyslot_o				=	`InDelaySlot;
				end else begin
					branch_target_address_o		=	`ZeroWord;
					branch_flag_o				=	`NotBranch;
					next_dlyslot_o				=	`NotInDelaySlot;
				end
			end
			//--------------------------------------------
			default: begin
				wd_o						=	`NOPRegAddr;
				wreg_o						=	`WriteDisable;
				aluop_o						=	`EXE_NOP_OP;	
				alusel_o					=	`EXE_RES_NOP;
				reg1_read_o					= 	0;	
				reg2_read_o					=	0;
				imm 						=	`ZeroWord;
				link_addr_o					=	`ZeroWord;
				branch_target_address_o		=	`ZeroWord;
				branch_flag_o				=	`NotBranch;
				next_dlyslot_o				=	`NotInDelaySlot;
				instvalid 					=	`InstInvalid;
			end
		endcase
		
	//===================================================================
	end else begin //op != SPECIAL, SPECIAL2 or REG
		case(op) //I type
			`EXE_ORI: begin
				wd_o 						= 	inst_i[20:16];
				wreg_o						=	`WriteEnable;	
				aluop_o						=	`EXE_OR_OP;	
				alusel_o					=	`EXE_RES_LOGIC;	
				reg1_read_o					= 	1'b1;	
				reg2_read_o					=	0;	
				imm 						= 	{16'h0, inst_i[15:0]};
				link_addr_o					=	`ZeroWord;
				branch_target_address_o		=	`ZeroWord;
				branch_flag_o				=	`NotBranch;
				next_dlyslot_o				=	`NotInDelaySlot;
				instvalid 					=	`InstValid;	
			end					
			`EXE_ANDI: begin
				wd_o						=	 inst_i[20:16];
				wreg_o						=	`WriteEnable;	
				aluop_o						=	`EXE_AND_OP;	
				alusel_o					=	`EXE_RES_LOGIC;	
				reg1_read_o					= 	1'b1;	
				reg2_read_o					=	0;	
				imm 						= 	{16'h0, inst_i[15:0]};
				link_addr_o					=	`ZeroWord;
				branch_target_address_o		=	`ZeroWord;
				branch_flag_o				=	`NotBranch;
				next_dlyslot_o				=	`NotInDelaySlot;
				instvalid 					=	`InstValid;	
			end						
			`EXE_XORI: begin
				wd_o						=	 inst_i[20:16];
				wreg_o						=	`WriteEnable;
				aluop_o						=	`EXE_XOR_OP;	
				alusel_o					=	`EXE_RES_LOGIC;	
				reg1_read_o					= 	1'b1;	
				reg2_read_o					=	0;	
				imm 						=	 {16'h0, inst_i[15:0]};
				link_addr_o					=	`ZeroWord;
				branch_target_address_o		=	`ZeroWord;
				branch_flag_o				=	`NotBranch;
				next_dlyslot_o				=	`NotInDelaySlot;
				instvalid 					=	`InstValid;	
			end					
			//-----------------------------------
			`EXE_LUI: begin
				wd_o						=	 inst_i[20:16];
				wreg_o						=	`WriteEnable;
				aluop_o						=	`EXE_OR_OP;	
				alusel_o					=	`EXE_RES_LOGIC;
				reg1_read_o					= 	1'b1;	
				reg2_read_o					=	0;
				imm 						= 	{inst_i[15:0], 16'h0};
				link_addr_o					=	`ZeroWord;
				branch_target_address_o		=	`ZeroWord;
				branch_flag_o				=	`NotBranch;
				next_dlyslot_o				=	`NotInDelaySlot;
				instvalid 					=	`InstValid;	
			end					
			//-----------------------------------
			`EXE_PREF: begin
				wd_o						=	`NOPRegAddr;
				wreg_o						=	`WriteDisable;
				aluop_o						=	`EXE_NOP_OP;	
				alusel_o					=	`EXE_RES_NOP;
				reg1_read_o					= 	0;	
				reg2_read_o					=	0;
				imm 						= 	`ZeroWord;
				link_addr_o					=	`ZeroWord;
				branch_target_address_o		=	`ZeroWord;
				branch_flag_o				=	`NotBranch;
				next_dlyslot_o				=	`NotInDelaySlot;
				instvalid 					=	`InstValid;
			end				
			//---------------------------------------
			//For overflow check, you should use "sign expansion" anyway!
			`EXE_SLTI: begin
				wd_o						=	 inst_i[20:16];
				wreg_o						=	`WriteEnable;
				aluop_o						=	`EXE_SLT_OP;	
				alusel_o					=	`EXE_RES_ARITHMETIC;
				reg1_read_o					= 	1'b1;	
				reg2_read_o					=	0;	
				imm 						=	 { {16{inst_i[15]}}, inst_i[15:0] }; //sign
				link_addr_o					=	`ZeroWord;
				branch_target_address_o		=	`ZeroWord;
				branch_flag_o				=	`NotBranch;
				next_dlyslot_o				=	`NotInDelaySlot;
				instvalid 					=	`InstValid;	
			end				
			`EXE_SLTIU: begin
				wd_o						=	 inst_i[20:16];
				wreg_o						=	`WriteEnable;
				aluop_o						=	`EXE_SLTU_OP;	
				alusel_o					=	`EXE_RES_ARITHMETIC;
				reg1_read_o					= 	1'b1;	
				reg2_read_o					=	0;	
				imm 						= 	{ {16{inst_i[15]}}, inst_i[15:0] }; //sign
				link_addr_o					=	`ZeroWord;
				branch_target_address_o		=	`ZeroWord;
				branch_flag_o				=	`NotBranch;
				next_dlyslot_o				=	`NotInDelaySlot;
				instvalid 					=	`InstValid;	
			end				
			`EXE_ADDI: begin
				wd_o						=	 inst_i[20:16];
				wreg_o						=	`WriteEnable;
				aluop_o						=	`EXE_ADDI_OP;	
				alusel_o					=	`EXE_RES_ARITHMETIC;	
				reg1_read_o					= 	1'b1;	
				reg2_read_o					=	0;	
				imm 						= 	{ {16{inst_i[15]}}, inst_i[15:0] }; //sign
				link_addr_o					=	`ZeroWord;
				branch_target_address_o		=	`ZeroWord;
				branch_flag_o				=	`NotBranch;
				next_dlyslot_o				=	`NotInDelaySlot;
				instvalid 					=	`InstValid;
			end				
			`EXE_ADDIU: begin
				wd_o						=	 inst_i[20:16];
				wreg_o						=	`WriteEnable;
				aluop_o						=	`EXE_ADDIU_OP;	
				alusel_o					=	`EXE_RES_ARITHMETIC;	
				reg1_read_o					= 	1'b1;	
				reg2_read_o					=	0;	
				imm 						= 	{ {16{inst_i[15]}}, inst_i[15:0] }; //sign
				link_addr_o					=	`ZeroWord;
				branch_target_address_o		=	`ZeroWord;
				branch_flag_o				=	`NotBranch;
				next_dlyslot_o				=	`NotInDelaySlot;
				instvalid 					=	`InstValid;	
			//---------------------------------------
			end				
			`EXE_J: begin
				wd_o						=	`NOPRegAddr;
				wreg_o						=	`WriteDisable;
				aluop_o						=	`EXE_NOP_OP;
				alusel_o					=	`EXE_RES_NOP;	
				reg1_read_o					= 	0;	
				reg2_read_o					=	0;	
				imm							= 	`ZeroWord;
				link_addr_o					=	`ZeroWord;
				branch_target_address_o		=	{pc_plus_4[31:28], inst_i[25:0], 2'b00}; //pc_plus_4[31:28] usally = pc=[31:28]
				branch_flag_o				=	`Branch;
				next_dlyslot_o				=	`InDelaySlot;
				instvalid 					=	`InstValid;	
			end				
			`EXE_JAL: begin
				wd_o						=	5'b11111;
				wreg_o						=	`WriteEnable;
				aluop_o						=	`EXE_BRANCH_JUMP_OP;	
				alusel_o					=	`EXE_RES_JUMP_BRANCH;	
				reg1_read_o					= 	0;	
				reg2_read_o					=	0;	
				imm 						=	`ZeroWord;
				link_addr_o					=	pc_plus_8;
				branch_target_address_o		=	{pc_plus_4[31:28], inst_i[25:0], 2'b00}; //pc_plus_4[31:28] usally = pc=[31:28]
				branch_flag_o				=	`Branch;
				next_dlyslot_o				=	`InDelaySlot;
				instvalid 					=	`InstValid;	
			end				
			//---------------------------------------
			`EXE_BEQ: begin
				wd_o						=	`NOPRegAddr;
				wreg_o						=	`WriteDisable;
				aluop_o						=	`EXE_NOP_OP;	
				alusel_o					=	`EXE_RES_NOP;	
				reg1_read_o					= 	1'b1;	
				reg2_read_o					=	1'b1;	
				imm 						=	`ZeroWord;
				link_addr_o					=	`ZeroWord;
				instvalid 					=	`InstValid;
				if(reg1_o == reg2_o) begin
					branch_target_address_o		=	pc_plus_4 + imm_sll2_signedext;
					branch_flag_o				=	`Branch;
					next_dlyslot_o				=	`InDelaySlot;
				end else begin
					branch_target_address_o		=	`ZeroWord;
					branch_flag_o				=	`NotBranch;
					next_dlyslot_o				=	`NotInDelaySlot;
				end
			end
			`EXE_BGTZ: begin
				wd_o						=	`NOPRegAddr;
				wreg_o						=	`WriteDisable;
				aluop_o						=	`EXE_NOP_OP;	
				alusel_o					=	`EXE_RES_NOP;	
				reg1_read_o					= 	1'b1;	
				reg2_read_o					=	0;	
				imm 						=	`ZeroWord;
				link_addr_o					=	`ZeroWord;
				instvalid 					=	`InstValid;
				if(reg1_o[31] == 0 && reg1_o != `ZeroWord) begin  // >0 ?
					branch_target_address_o		=	pc_plus_4 + imm_sll2_signedext;
					branch_flag_o				=	`Branch;
					next_dlyslot_o				=	`InDelaySlot;
				end else begin
					branch_target_address_o		=	`ZeroWord;
					branch_flag_o				=	`NotBranch;
					next_dlyslot_o				=	`NotInDelaySlot;
				end
			end
			`EXE_BLEZ: begin
				wd_o						=	`NOPRegAddr;
				wreg_o						=	`WriteDisable;
				aluop_o						=	`EXE_NOP_OP;	
				alusel_o					=	`EXE_RES_JUMP_BRANCH;	
				reg1_read_o					= 	1'b1;	
				reg2_read_o					=	0;	
				imm 						=	`ZeroWord;
				link_addr_o					=	`ZeroWord;
				instvalid 					=	`InstValid;
				if(reg1_o[31] == 1'b1 || reg1_o == `ZeroWord) begin
					branch_target_address_o		=	pc_plus_4 + imm_sll2_signedext;
					branch_flag_o				=	`Branch;
					next_dlyslot_o				=	`InDelaySlot;
				end else begin
					branch_target_address_o		=	`ZeroWord;
					branch_flag_o				=	`NotBranch;
					next_dlyslot_o				=	`NotInDelaySlot;
				end
			end
			`EXE_BNE: begin
				wd_o						=	`NOPRegAddr;
				wreg_o						=	`WriteDisable;
				aluop_o						=	`EXE_NOP_OP;	
				alusel_o					=	`EXE_RES_JUMP_BRANCH;	
				reg1_read_o					= 	1'b1;	
				reg2_read_o					=	1'b1;	
				imm 						=	`ZeroWord;
				link_addr_o					=	`ZeroWord;
				instvalid 					=	`InstValid;
				if(reg1_o != reg2_o) begin
					branch_target_address_o		=	pc_plus_4 + imm_sll2_signedext;
					branch_flag_o				=	`Branch;
					next_dlyslot_o				=	`InDelaySlot;
				end else begin
					branch_target_address_o		=	`ZeroWord;
					branch_flag_o				=	`NotBranch;
					next_dlyslot_o				=	`NotInDelaySlot;
				end
			end
			//---------------------------------------
			`EXE_LB: begin
				wd_o						=	 inst_i[20:16];
				wreg_o						=	`WriteEnable;
				aluop_o						=	`EXE_LB_OP;	
				alusel_o					=	`EXE_RES_LOAD_STORE; //becomes mark
				reg1_read_o					= 	1'b1;	
				reg2_read_o					=	0;	
				imm 						= 	`ZeroWord;
				link_addr_o					=	`ZeroWord;
				branch_target_address_o		=	`ZeroWord;
				branch_flag_o				=	`NotBranch;
				next_dlyslot_o				=	`NotInDelaySlot;
				instvalid 					=	`InstValid;
			end
			`EXE_LBU: begin
				wd_o						=	 inst_i[20:16];
				wreg_o						=	`WriteEnable;
				aluop_o						=	`EXE_LBU_OP;	
				alusel_o					=	`EXE_RES_LOAD_STORE;	
				reg1_read_o					= 	1'b1;	
				reg2_read_o					=	0;	
				imm 						= 	`ZeroWord;
				link_addr_o					=	`ZeroWord;
				branch_target_address_o		=	`ZeroWord;
				branch_flag_o				=	`NotBranch;
				next_dlyslot_o				=	`NotInDelaySlot;
				instvalid 					=	`InstValid;
			end
			`EXE_LH: begin
				wd_o						=	 inst_i[20:16];
				wreg_o						=	`WriteEnable;
				aluop_o						=	`EXE_LH_OP;	
				alusel_o					=	`EXE_RES_LOAD_STORE;	
				reg1_read_o					= 	1'b1;	
				reg2_read_o					=	0;	//not need to read
				imm 						= 	`ZeroWord;
				link_addr_o					=	`ZeroWord;
				branch_target_address_o		=	`ZeroWord;
				branch_flag_o				=	`NotBranch;
				next_dlyslot_o				=	`NotInDelaySlot;
				instvalid 					=	`InstValid;
			end
			`EXE_LHU: begin
				wd_o						=	 inst_i[20:16];
				wreg_o						=	`WriteEnable;
				aluop_o						=	`EXE_LHU_OP;	
				alusel_o					=	`EXE_RES_LOAD_STORE;	
				reg1_read_o					= 	1'b1;	
				reg2_read_o					=	0;	
				imm 						= 	`ZeroWord;
				link_addr_o					=	`ZeroWord;
				branch_target_address_o		=	`ZeroWord;
				branch_flag_o				=	`NotBranch;
				next_dlyslot_o				=	`NotInDelaySlot;
				instvalid 					=	`InstValid;
			end
			`EXE_LW: begin
				wd_o						=	 inst_i[20:16];
				wreg_o						=	`WriteEnable;
				aluop_o						=	`EXE_LW_OP;	
				alusel_o					=	`EXE_RES_LOAD_STORE;	
				reg1_read_o					= 	1'b1;	
				reg2_read_o					=	0;	
				imm 						= 	`ZeroWord;
				link_addr_o					=	`ZeroWord;
				branch_target_address_o		=	`ZeroWord;
				branch_flag_o				=	`NotBranch;
				next_dlyslot_o				=	`NotInDelaySlot;
				instvalid 					=	`InstValid;
			end
			`EXE_LWL: begin
				wd_o						=	 inst_i[20:16];
				wreg_o						=	`WriteEnable;
				aluop_o						=	`EXE_LWL_OP;	
				alusel_o					=	`EXE_RES_LOAD_STORE;	
				reg1_read_o					= 	1'b1;	
				reg2_read_o					=	1'b1; //you need part of reg2's "initial" value! see datamem_mux!
				imm 						= 	`ZeroWord;
				link_addr_o					=	`ZeroWord;
				branch_target_address_o		=	`ZeroWord;
				branch_flag_o				=	`NotBranch;
				next_dlyslot_o				=	`NotInDelaySlot;
				instvalid 					=	`InstValid;
			end
			`EXE_LWR: begin
				wd_o						=	 inst_i[20:16];
				wreg_o						=	`WriteEnable;
				aluop_o						=	`EXE_LWR_OP;	
				alusel_o					=	`EXE_RES_LOAD_STORE;	
				reg1_read_o					= 	1'b1;	
				reg2_read_o					=	1'b1; //you need part of reg2's "initial" value! see datamem_mux!
				imm 						= 	`ZeroWord;
				link_addr_o					=	`ZeroWord;
				branch_target_address_o		=	`ZeroWord;
				branch_flag_o				=	`NotBranch;
				next_dlyslot_o				=	`NotInDelaySlot;
				instvalid 					=	`InstValid;
			end
			`EXE_SB: begin
				wd_o						=	`NOPRegAddr; //not need to write
				wreg_o						=	`WriteDisable;
				aluop_o						=	`EXE_SB_OP;	
				alusel_o					=	`EXE_RES_NOP;	
				reg1_read_o					= 	1'b1;	
				reg2_read_o					=	1'b1;	
				imm 						= 	`ZeroWord;
				link_addr_o					=	`ZeroWord;
				branch_target_address_o		=	`ZeroWord;
				branch_flag_o				=	`NotBranch;
				next_dlyslot_o				=	`NotInDelaySlot;
				instvalid 					=	`InstValid;
			end
			`EXE_SH: begin
				wd_o						=	`NOPRegAddr;
				wreg_o						=	`WriteDisable;
				aluop_o						=	`EXE_SH_OP;	
				alusel_o					=	`EXE_RES_NOP;	
				reg1_read_o					= 	1'b1;	
				reg2_read_o					=	1'b1;	
				imm 						= 	`ZeroWord;
				link_addr_o					=	`ZeroWord;
				branch_target_address_o		=	`ZeroWord;
				branch_flag_o				=	`NotBranch;
				next_dlyslot_o				=	`NotInDelaySlot;
				instvalid 					=	`InstValid;
			end
			`EXE_SW: begin
				wd_o						=	`NOPRegAddr;
				wreg_o						=	`WriteDisable;
				aluop_o						=	`EXE_SW_OP;	
				alusel_o					=	`EXE_RES_NOP;	
				reg1_read_o					= 	1'b1;	
				reg2_read_o					=	1'b1;	
				imm 						= 	`ZeroWord;
				link_addr_o					=	`ZeroWord;
				branch_target_address_o		=	`ZeroWord;
				branch_flag_o				=	`NotBranch;
				next_dlyslot_o				=	`NotInDelaySlot;
				instvalid 					=	`InstValid;
			end
			`EXE_SWL: begin
				wd_o						=	`NOPRegAddr;
				wreg_o						=	`WriteDisable;
				aluop_o						=	`EXE_SWL_OP;	
				alusel_o					=	`EXE_RES_NOP;	
				reg1_read_o					= 	1'b1;	
				reg2_read_o					=	1'b1;	
				imm 						= 	`ZeroWord;
				link_addr_o					=	`ZeroWord;
				branch_target_address_o		=	`ZeroWord;
				branch_flag_o				=	`NotBranch;
				next_dlyslot_o				=	`NotInDelaySlot;
				instvalid 					=	`InstValid;
			end
			`EXE_SWR: begin
				wd_o						=	`NOPRegAddr;
				wreg_o						=	`WriteDisable;
				aluop_o						=	`EXE_SWR_OP;	
				alusel_o					=	`EXE_RES_NOP;	
				reg1_read_o					= 	1'b1;	
				reg2_read_o					=	1'b1;	
				imm 						= 	`ZeroWord;
				link_addr_o					=	`ZeroWord;
				branch_target_address_o		=	`ZeroWord;
				branch_flag_o				=	`NotBranch;
				next_dlyslot_o				=	`NotInDelaySlot;
				instvalid 					=	`InstValid;
			end
			`EXE_LL: begin
				wd_o						=	inst_i[20:16];
				wreg_o						=	`WriteEnable;
				aluop_o						=	`EXE_LL_OP;	
				alusel_o					=	`EXE_RES_LOAD_STORE;	
				reg1_read_o					= 	1'b1;	//讀取base
				reg2_read_o					=	0;	
				imm 						= 	`ZeroWord;
				link_addr_o					=	`ZeroWord;
				branch_target_address_o		=	`ZeroWord;
				branch_flag_o				=	`NotBranch;
				next_dlyslot_o				=	`NotInDelaySlot;
				instvalid 					=	`InstValid;
			end
			`EXE_SC: begin
				wd_o						=	inst_i[20:16];
				wreg_o						=	`WriteEnable;
				aluop_o						=	`EXE_SC_OP;	
				alusel_o					=	`EXE_RES_LOAD_STORE;	
				reg1_read_o					= 	1'b1;	
				reg2_read_o					=	1'b1;	
				imm 						= 	`ZeroWord;
				link_addr_o					=	`ZeroWord;
				branch_target_address_o		=	`ZeroWord;
				branch_flag_o				=	`NotBranch;
				next_dlyslot_o				=	`NotInDelaySlot;
				instvalid 					=	`InstValid;
			end
			//----------------------------------------
			default: begin
				wd_o						=	`NOPRegAddr;
				wreg_o						=	`WriteDisable;
				aluop_o						=	`EXE_NOP_OP;	
				alusel_o					=	`EXE_RES_NOP;
				reg1_read_o					= 	0;	
				reg2_read_o					=	0;	
				imm 						= 	`ZeroWord;
				link_addr_o					=	`ZeroWord;
				branch_target_address_o		=	`ZeroWord;
				branch_flag_o				=	`NotBranch;
				next_dlyslot_o				=	`NotInDelaySlot;
				instvalid 					=	`InstInvalid;	
			end
		endcase
	end			
end


//=======================================================================
always @(*) begin //data dep
	if((reg1_read_o == 1'b1) && (ex_wreg_i == 1'b1) && (ex_wd_i == reg1_addr_o))
		reg1_o = ex_wdata_i;
	else if((reg1_read_o == 1'b1) && (mem_wreg_i == 1'b1) && (mem_wd_i == reg1_addr_o))
		reg1_o = mem_wdata_i;
	else if(reg1_read_o == 1'b1) 
		reg1_o = reg1_data_i; 
	else
		reg1_o = imm; // if reg1_read_o == 0, read imm
end

always @(*) begin
	if((reg2_read_o == 1'b1) && (ex_wreg_i == 1'b1) && (ex_wd_i == reg2_addr_o))
		reg2_o = ex_wdata_i;
	else if((reg2_read_o == 1'b1) && (mem_wreg_i == 1'b1) && (mem_wd_i == reg2_addr_o))
		reg2_o = mem_wdata_i;
	else if(reg2_read_o == 1'b1) 
		reg2_o = reg2_data_i;
	else
		reg2_o = imm; // if reg2_read_o == 0, read imm
end

//----------------------------------------------------
assign load_dep = (ex_aluop_i == `EXE_LB_OP		||
					ex_aluop_i == `EXE_LBU_OP	||
					ex_aluop_i == `EXE_LH_OP	||
					ex_aluop_i == `EXE_LHU_OP	||
					ex_aluop_i == `EXE_LW_OP	||
					ex_aluop_i == `EXE_LWR_OP	||
					ex_aluop_i == `EXE_LWL_OP	||
					ex_aluop_i == `EXE_LL_OP	||
					ex_aluop_i == `EXE_SC_OP	
					) ? 1'b1 : 1'b0 ;

always @(*) begin //load dep
	if((reg1_read_o == 1'b1) && (load_dep == 1'b1) && (ex_wd_i == reg1_addr_o))
		stallreq_from_id1 = `Stop;
	else
		stallreq_from_id1 = `NoStop;
end

always @(*) begin
	if((reg2_read_o == 1'b1) && (load_dep == 1'b1) && (ex_wd_i == reg2_addr_o))
		stallreq_from_id2 = `Stop;
	else                   
		stallreq_from_id2 = `NoStop;
end

assign stallreq = stallreq_from_id1 | stallreq_from_id2;

//##################################################################################################
/*always @(*) begin
	if(stallreq_from_ex == `Stop)
		stall = 6'b001111; //1=stop, continue from next of ex
	else if(stallreq_from_id == `Stop)
		stall = 6'b000111; //1=stop, continue from next of id
	else
		stall = 0;
end */


endmodule