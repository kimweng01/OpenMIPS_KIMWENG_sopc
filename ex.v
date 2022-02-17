`include	"define.v"

module ex(
	//input						rst,
	input		[`RegBus]		inst_i,
	
	input		[`AluOpBus]		aluop_i,
	input		[`AluSelBus]	alusel_i,
	
	input 		[`RegBus]		reg1_i,
	input		[`RegBus]		reg2_i,
	
	input		[`RegAddrBus]	wd_i,
	input						wreg_i,
	
	//----------------------------------
	input		[`RegBus]		hi_i,
	input		[`RegBus]		lo_i,
	
	input		[`RegBus]		wb_hi_i, //dep
	input		[`RegBus]		wb_lo_i,
	input						wb_whilo_i,
	
	input		[`RegBus]		mem_hi_i, //dep
	input		[`RegBus]		mem_lo_i,
	input						mem_whilo_i,
	
	//----------------------------------
	input						annul_i,
	
	input		[`DoubleRegBus]	maddsub_temp_i,
	input		[`DoubleRegBus] div_temp_i,
	
	input						cnt_mult_i,
	input		[4:0]			cnt_div_i,
	
	input		[`RegBus]		link_addr_i,
	input						dlyslot_now_i,
	
	//**********************************
	input						mem_cp0_reg_we,
	input		[4:0]			mem_cp0_reg_wr_addr,
	input		[`RegBus]		mem_cp0_reg_data,
	
	input						wb_cp0_reg_we,
	input		[4:0]			wb_cp0_reg_wr_addr,
	input		[`RegBus]		wb_cp0_reg_data,
	
	input		[`RegBus]		cp0_reg_data_i, //conect to cp0 directly, rd data from cp0
	
	//++++++++++++++++++++++++++++++++++
	input		[`RegBus]		current_inst_addr_i,
	input		[`RegBus]		excepttype_i,	
	
	//=========================================	
	output reg	[`RegAddrBus]	wd_o,
	output reg					wreg_o,
	output reg	[`RegBus]		wdata_o,
	
	//------------------------------------
	output reg	[`RegBus]		hi_o,
	output reg	[`RegBus]		lo_o,
	output reg					whilo_o,
	
	//-----------------------------------	
	output reg	[`DoubleRegBus]	maddsub_temp_o,
	output reg	[`DoubleRegBus]	div_temp_o,
	
	output reg					cnt_mult_o,	
	output reg	[4:0]			cnt_div_o,

	//-----------------------------------
	output		[`AluOpBus]		aluop_o,
	output		[`RegBus]		mem_addr_o,
	output		[`RegBus]		reg2_o,
	
	//***********************************
	output reg					cp0_reg_we_o,
	output reg	[4:0]			cp0_reg_wr_addr_o,
	output reg	[`RegBus]		cp0_reg_data_o,
	
	output reg	[4:0]			cp0_reg_rd_addr_o, //conect to cp0 directly, rd addr into cp0
	
	//++++++++++++++++++++++++++++++++++++
	output 						stallreq,
	
	output						dlyslot_now_o,
	output 		[`RegBus]		excepttype_o,
	output 		[`RegBus]		current_inst_addr_o
	);
	
	
	reg			[`RegBus]		logicout;
	
	reg			[`RegBus]		shiftres;
	
	reg			[`RegBus]		moveres;
	reg			[`RegBus]		HI;
	reg			[`RegBus]		LO;	

	wire						ov_sum; //over flow ?
	
	wire						reg1_eq_reg2; //Is reg1_i == reg2_i ?
	wire						reg1_lt_reg2; //Is reg1_i < reg2_i ?
	
	reg			[`RegBus]		arithmeticres; //result of arithmetic operation
	wire		[`RegBus]		reg2_i_mux; //save (~reg2_i)+1 or reg2_i
	wire		[`RegBus]		reg1_i_not; //save (~reg1_i)
	wire		[`RegBus]		result_sum; //add result
	
	wire		[`RegBus]		opdata1_mult; //Multiplicand
	wire		[`RegBus]		opdata2_mult; //Multiplier

	wire		[`DoubleRegBus]	mul_temp;
	wire		[`DoubleRegBus]	mulres; //mult real result
	
	wire 		[`RegBus]		opdata1_div; //Dividend
	wire 		[`RegBus]		opdata2_div; //Divisor
	wire		[`DoubleRegBus]	div_temp;
	wire		[`RegBus]		q_temp; //quotient temp result
	wire		[`RegBus]		r_temp; //remainder temp result
	wire		[`RegBus]		q_temp1; //quotient real result
	wire		[`RegBus]		r_temp1; //remainder real result
	wire		[`DoubleRegBus]	divres; //div real result
	
	reg			[`DoubleRegBus]	maddsubres;
	reg							stallreq_for_madd_msub;
	reg							stallreq_for_div;
	
	reg							ovassert;
	reg 						trapassert;
	
	

//###########################################################################################
assign aluop_o = aluop_i;
assign mem_addr_o = reg1_i + { {16{inst_i[15]}}, inst_i[15:0] }; //base + (signed)offset
assign reg2_o = reg2_i;


//===========================================================
assign excepttype_o 		= {excepttype_i[31:12], ovassert, trapassert, excepttype_i[9:8], 8'h0};
assign dlyslot_now_o 		= dlyslot_now_i;
assign current_inst_addr_o	= current_inst_addr_i;



//###########################################################################################
always @(*) begin
	case(aluop_i)
		`EXE_OR_OP:		logicout = reg1_i | reg2_i;
		`EXE_AND_OP:	logicout = reg1_i & reg2_i;
		`EXE_NOR_OP:	logicout = ~(reg1_i | reg2_i);
		`EXE_XOR_OP:	logicout = reg1_i ^ reg2_i;
		default:		logicout = `ZeroWord;
	endcase
end

//-------------------------------------------------------
always @(*) begin
	case(aluop_i)
		`EXE_SLL_OP:	shiftres = reg2_i << reg1_i;
		`EXE_SRL_OP:	shiftres = reg2_i >> reg1_i;
		`EXE_SRA_OP:	shiftres = ( {32{reg2_i[31]}} << (6'd32 - {1'b0, reg1_i}) ) | reg2_i >> reg1_i[4:0];
														//maby can write: 6'd32 - reg1_i
/*Arithmetic right shift must be set to a signed number, 
	which affects addition and subtraction operations, 
	so use unsigned numbers to calculate
	Assuming there are 32 digits, 
	shifting to the left by 7 must first fill the 32 grids with the highest bit, 
	and then shift to the left by 32-7=25 grids to fill the hole with "or"			*/
	
		default: 		shiftres = `ZeroWord;
	endcase
end


//==========================================================================
assign reg2_i_mux = (aluop_i == `EXE_SUB_OP ||
					aluop_i == `EXE_SUBU_OP||
					aluop_i == `EXE_SLT_OP || //use minus to judge LT
					aluop_i == `EXE_TLT_OP ||
					aluop_i == `EXE_TLTI_OP||
					aluop_i == `EXE_TGE_OP ||
					aluop_i == `EXE_TGEI_OP) ?
					(~reg2_i+1'b1) : reg2_i;

assign result_sum = reg1_i + reg2_i_mux;
assign ov_sum = ( (!reg1_i[31] && !reg2_i_mux[31]) &&  result_sum[31] ) ||
				( ( reg1_i[31] &&  reg2_i_mux[31]) && !result_sum[31] );
/* reg1: +, reg2: +, but result: -, ==> over flow!
   reg1: -, reg2: -, but result: +, ==> over flow! */

assign reg1_lt_reg2 = (aluop_i == `EXE_SLT_OP ||
						aluop_i == `EXE_SUB_OP ||
						aluop_i == `EXE_SUBU_OP||
						aluop_i == `EXE_SLT_OP ||
						aluop_i == `EXE_TLT_OP ||
						aluop_i == `EXE_TLTI_OP||
						aluop_i == `EXE_TGE_OP ||
						aluop_i == `EXE_TGEI_OP) ? //Is sign?
					( ( reg1_i[31] && !reg2_i[31]) ||
					  (!reg1_i[31] && !reg2_i[31] && result_sum[31]) ||
					  ( reg1_i[31] &&  reg2_i[31] && result_sum[31]) )	//OP is signed			  
					: (reg1_i < reg2_i); //OP is unsigned
/* aluop_i != `EXE_xLT_OP ==> Directly judge!

   aluop_i == `EXE_SLT_OP, then...
   reg1_i: -, reg2_i: +, ==> reg1_i must < reg2_i !
   reg1_i: +, reg2_i: +, reg1_i-reg2_i=minus ==> reg1_i < reg2_i
   reg1_i: -, reg2_i: -, reg1_i-reg2_i=minus ==> reg1_i < reg2_i		*/
   

//-------------------------------------------------------
assign opdata1_mult = (aluop_i == `EXE_MUL_OP || aluop_i == `EXE_MULT_OP || aluop_i == `EXE_MADD_OP || aluop_i == `EXE_MSUB_OP) 
					&& (reg1_i[31] == 1'b1) ? 
						(~reg1_i+1'b1) : reg1_i;
assign opdata2_mult = (aluop_i == `EXE_MUL_OP || aluop_i == `EXE_MULT_OP || aluop_i == `EXE_MADD_OP || aluop_i == `EXE_MSUB_OP) 
					&& (reg2_i[31] == 1'b1) ? 
						(~reg2_i+1'b1) : reg2_i;						

assign mul_temp = opdata1_mult * opdata2_mult;

assign mulres = (aluop_i == `EXE_MULT_OP || aluop_i == `EXE_MUL_OP || aluop_i == `EXE_MADD_OP || aluop_i == `EXE_MSUB_OP) 
					&& (reg1_i[31] ^ reg2_i[31]) ?
					(~mul_temp+1'b1) : mul_temp;
/* Signed number multiplication: 
	as long as it is negative, first turn it all into positive, 
	after multiplication, if it is positive and negative, 
	then turn back to negative		*/

//======================================================================
assign opdata1_div = (aluop_i == `EXE_DIV_OP) && (reg1_i[31] == 1'b1) ? 
						(~reg1_i+1'b1) : reg1_i;						
assign opdata2_div = (aluop_i == `EXE_DIV_OP) && (reg2_i[31] == 1'b1) ? 
						(~reg2_i+1'b1) : reg2_i;

/*(always @(*) begin
	if(annul_i == 1'b1 || opdata2_div == 0) begin
		q_temp = `ZeroWord;
		r_temp = `ZeroWord;
		cn = 0; //avoid latches
	end else begin
		q_temp = `ZeroWord;
		r_temp = `ZeroWord;
		for(cn = `RegWidth; cn > 0; cn = cn - 1) begin
			r_temp = {r_temp[`RegWidth-2 : 0], opdata1_div[cn-1]}; //left shift
			q_temp = q_temp << 1;
			if(r_temp >= opdata2_div) begin
				q_temp = q_temp + 1'b1;
				r_temp = r_temp - opdata2_div;
			end
		end
	end
end		*/


assign div_temp = {`ZeroWord, opdata1_div};

always @(*) begin
	case(aluop_i)
		`EXE_DIV_OP, `EXE_DIVU_OP: begin
			if(annul_i == 1'b1 || opdata2_div == 0) begin
				div_temp_o = {`ZeroWord, `ZeroWord};
				
				stallreq_for_div = `NoStop;
				cnt_div_o = 0;
			end else begin
				if(cnt_div_i == 0) begin
					stallreq_for_div = `Stop;
					cnt_div_o = cnt_div_i + 1'b1;
				
					if(div_temp[62:31] >= opdata2_div)
						div_temp_o = {(div_temp[62:31] - opdata2_div), div_temp[30:0], 1'b1};
					else
						div_temp_o = div_temp << 1;
				end else if(cnt_div_i < 31) begin
					stallreq_for_div = `Stop;
					cnt_div_o = cnt_div_i + 1'b1;
					
					if(div_temp_i[62:31] >= opdata2_div)
						div_temp_o = {(div_temp_i[62:31] - opdata2_div), div_temp_i[30:0], 1'b1};
					else
						div_temp_o = div_temp_i << 1;
				end else begin //cnt_div_i == 31
					stallreq_for_div = `NoStop;
					cnt_div_o = 0;
					
					if(div_temp_i[62:31] > opdata2_div)
						div_temp_o = {(div_temp_i[62:31] - opdata2_div), div_temp_i[30:0], 1'b1};
					else
						div_temp_o = div_temp_i << 1;
				end 
			end 
		end 
		
		default: begin
			div_temp_o = {`ZeroWord, `ZeroWord};
				
			stallreq_for_div = `NoStop;
			cnt_div_o = 0;
		end 
	endcase
end

assign q_temp = div_temp_o[31:0];
assign r_temp = div_temp_o[63:32];


assign q_temp1 = (aluop_i == `EXE_DIV_OP) && (reg1_i[31] ^ reg2_i[31]) ?
					(~q_temp+1'b1) : q_temp;
assign r_temp1 = (aluop_i == `EXE_DIV_OP) && reg1_i[31] ?
					(~r_temp+1'b1) : r_temp;
					
assign divres = {r_temp1, q_temp1};


//======================================================================
always @(*) begin
	cp0_reg_rd_addr_o = inst_i[15:11]; //rd
	
	case(aluop_i)
		`EXE_MFHI_OP:	moveres = HI;
		`EXE_MFLO_OP:	moveres = LO;
		`EXE_MOVZ_OP:	moveres = reg1_i;
		`EXE_MOVN_OP:	moveres = reg1_i;
		
		`EXE_MFC0_OP: begin //will write into cp0
			
			if(mem_cp0_reg_we == `WriteEnable  &&  mem_cp0_reg_wr_addr == inst_i[15:11])
				moveres = mem_cp0_reg_data;
			else if(wb_cp0_reg_we == `WriteEnable  &&  wb_cp0_reg_wr_addr == inst_i[15:11])
				moveres = wb_cp0_reg_data;
			else
				moveres = cp0_reg_data_i;
		end

		default:	moveres = `ZeroWord;
	endcase
end


//======================================================================
assign reg1_i_not = ~reg1_i;

always @(*) begin
	case(aluop_i)
		`EXE_SLT_OP, `EXE_SLTU_OP: 
			arithmeticres = reg1_lt_reg2;
		
		`EXE_ADD_OP, `EXE_ADDU_OP, `EXE_ADDI_OP, `EXE_ADDIU_OP, 
		`EXE_SUB_OP, `EXE_SUBU_OP: 
			arithmeticres = result_sum;
			
		`EXE_CLO_OP: 
			arithmeticres = ( reg1_i_not[31] ?  0 : 
							  reg1_i_not[30] ?  1 :
							  reg1_i_not[29] ?  2 :
							  reg1_i_not[28] ?  3 :
							  reg1_i_not[27] ?  4 :
							  reg1_i_not[26] ?  5 :
							  reg1_i_not[25] ?  6 :
							  reg1_i_not[24] ?  7 :
							  reg1_i_not[23] ?  8 :
							  reg1_i_not[22] ?  9 :
							  reg1_i_not[21] ? 10 :
							  reg1_i_not[20] ? 11 :
							  reg1_i_not[19] ? 12 :
							  reg1_i_not[18] ? 13 :
							  reg1_i_not[17] ? 14 :
							  reg1_i_not[16] ? 15 :
							  reg1_i_not[15] ? 16 :
							  reg1_i_not[14] ? 17 :
							  reg1_i_not[12] ? 18 :
							  reg1_i_not[13] ? 19 :
							  reg1_i_not[11] ? 20 :
							  reg1_i_not[10] ? 21 :
							  reg1_i_not [9] ? 22 :
							  reg1_i_not [8] ? 23 :
							  reg1_i_not [7] ? 24 :
							  reg1_i_not [6] ? 25 :
							  reg1_i_not [5] ? 26 :
							  reg1_i_not [4] ? 27 :
							  reg1_i_not [3] ? 28 :
							  reg1_i_not [2] ? 29 :
							  reg1_i_not [1] ? 30 :
							  reg1_i_not [0] ? 31 :
										  32 );										  
		`EXE_CLZ_OP: 
			arithmeticres = ( reg1_i[31] ?  0 : 
							  reg1_i[30] ?  1 :
							  reg1_i[29] ?  2 :
							  reg1_i[28] ?  3 :
							  reg1_i[27] ?  4 :
							  reg1_i[26] ?  5 :
							  reg1_i[25] ?  6 :
							  reg1_i[24] ?  7 :
							  reg1_i[23] ?  8 :
							  reg1_i[22] ?  9 :
							  reg1_i[21] ? 10 :
							  reg1_i[20] ? 11 :
							  reg1_i[19] ? 12 :
							  reg1_i[18] ? 13 :
							  reg1_i[17] ? 14 :
							  reg1_i[16] ? 15 :
							  reg1_i[15] ? 16 :
							  reg1_i[14] ? 17 :
							  reg1_i[13] ? 18 :
							  reg1_i[12] ? 19 :
							  reg1_i[11] ? 20 :
							  reg1_i[10] ? 21 :
							  reg1_i [9] ? 22 :
							  reg1_i [8] ? 23 :
							  reg1_i [7] ? 24 :
							  reg1_i [6] ? 25 :
							  reg1_i [5] ? 26 :
							  reg1_i [4] ? 27 :
							  reg1_i [3] ? 28 :
							  reg1_i [2] ? 29 :
							  reg1_i [1] ? 30 :
							  reg1_i [0] ? 31 :
									  32 );
		//If the ratio reaches 1, it ends, otherwise the program continues
										  
		default: arithmeticres = `ZeroWord;
	endcase
end



//#######################################################################################
always @(*) begin
	wd_o = wd_i; //if MTHI or MTLO => rd must == 0 => wd_o == 0
	
	if(	( aluop_i == `EXE_ADD_OP || aluop_i == `EXE_ADDI_OP || aluop_i == `EXE_SUB_OP )
	 && ov_sum == 1'b1 ) begin //over flow ?
		wreg_o	= `WriteDisable;
	end else begin 
		wreg_o	= wreg_i;
	end
	
	case(alusel_i)
		`EXE_RES_LOGIC:			wdata_o = logicout;
		`EXE_RES_SHIFT:			wdata_o = shiftres;
		`EXE_RES_MOVE:			wdata_o = moveres;
		`EXE_RES_ARITHMETIC:	wdata_o = arithmeticres;
		`EXE_RES_MUL:			wdata_o = mulres[31:0];
		`EXE_RES_JUMP_BRANCH:	wdata_o = link_addr_i;
		
		default:				wdata_o = `ZeroWord;
	endcase
end


//======================================================================
always @(*) begin
	case(aluop_i) //hilo_temp_o is OUTPUT, hilo_temp_i is INPUT, hilo_temp_o transfer to hilo_temp_i. 
		/*`EXE_MADD_OP, `EXE_MADDU_OP: begin
			if(cnt_i == 0) begin
				hilo_temp_o = mulres; //store first result
				cnt_o		= 2'b01;
				hilo_temp1	= {`ZeroWord, `ZeroWord}; //useless now
				stallreq_for_madd_msub = `Stop; //detect MADD or MADDU, STOP NOW!!!
			end else if(cnt_i == 2'b01) begin
				hilo_temp_o = {`ZeroWord, `ZeroWord}; //already used up
				cnt_o		= 2'b10;
				hilo_temp1	= hilo_temp_i + {HI, LO}; //real result
				stallreq_for_madd_msub = `NoStop;
			end else begin
				hilo_temp_o = {`ZeroWord, `ZeroWord};
				cnt_o 		= 0;
				hilo_temp1	= {`ZeroWord, `ZeroWord};
				stallreq_for_madd_msub = `NoStop;
			end
		end
		`EXE_MSUB_OP, `EXE_MSUBU_OP: begin
			if(cnt_i == 0) begin
				hilo_temp_o = (~mulres+1'b1); //store first negetive result
				cnt_o		= 2'b01;
				hilo_temp1	= {`ZeroWord, `ZeroWord}; //useless now
				stallreq_for_madd_msub = `Stop; //detect MSUB or MSUBU, STOP NOW!!!
			end else if(cnt_i == 2'b01) begin
				hilo_temp_o = {`ZeroWord, `ZeroWord}; //already used up
				cnt_o		= 2'b10;
				hilo_temp1	= hilo_temp_i + {HI, LO}; //real result
				stallreq_for_madd_msub = `NoStop;
			end else begin
				hilo_temp_o = {`ZeroWord, `ZeroWord};
				cnt_o 		= 0;
				hilo_temp1	= {`ZeroWord, `ZeroWord};
				stallreq_for_madd_msub = `NoStop;
			end
		end	*/
		`EXE_MADD_OP, `EXE_MADDU_OP: begin
			if(cnt_mult_i == 0) begin
				maddsub_temp_o = mulres; //store first result
				cnt_mult_o	= cnt_mult_i + 1'b1;
				maddsubres	= {`ZeroWord, `ZeroWord}; //useless now
				stallreq_for_madd_msub = `Stop; //detect MADD or MADDU, STOP NOW!!!
			end else begin //cnt_i == 1'b1
				maddsub_temp_o = {`ZeroWord, `ZeroWord}; //already used up
				cnt_mult_o	= 0;
				maddsubres	= maddsub_temp_i + {HI, LO}; //real result
				stallreq_for_madd_msub = `NoStop;
			end 
		end 
		`EXE_MSUB_OP, `EXE_MSUBU_OP: begin
			if(cnt_mult_i == 0) begin
				maddsub_temp_o = (~mulres+1'b1); //store first negetive result
				cnt_mult_o	= cnt_mult_i + 1'b1;
				maddsubres	= {`ZeroWord, `ZeroWord}; //useless now
				stallreq_for_madd_msub = `Stop; //detect MSUB or MSUBU, STOP NOW!!!
			end else begin //cnt_i == 1'b1
				maddsub_temp_o = {`ZeroWord, `ZeroWord}; //already used up
				cnt_mult_o	= 0;
				maddsubres	= maddsub_temp_i + {HI, LO}; //real result
				stallreq_for_madd_msub = `NoStop;
			end 
		end
		
		default: begin
			maddsub_temp_o = {`ZeroWord, `ZeroWord};
			cnt_mult_o 	= 0;
			maddsubres	= {`ZeroWord, `ZeroWord};
			stallreq_for_madd_msub = `NoStop;
		end
	endcase
end

assign stallreq = stallreq_for_madd_msub | stallreq_for_div;

//-----------------------------------------
always @(*) begin
	if(mem_whilo_i == `WriteEnable) //dep
		{HI,LO} = {mem_hi_i, mem_lo_i};
	else if(wb_whilo_i == `WriteEnable) //dep
		{HI,LO} = {wb_hi_i, wb_lo_i};
	else
		{HI,LO} = {hi_i, lo_i};
end

always @(*) begin
	if( (aluop_i == `EXE_MULT_OP) || (aluop_i == `EXE_MULTU_OP) ) begin
		whilo_o = `WriteEnable;
		hi_o 	= mulres[63:32];
		lo_o 	= mulres[31:0];
	end else if(aluop_i == `EXE_MSUB_OP || aluop_i == `EXE_MSUBU_OP
					|| aluop_i == `EXE_MADD_OP || aluop_i == `EXE_MADDU_OP) begin
		whilo_o = `WriteEnable;
		hi_o 	= maddsubres[63:32];
		lo_o 	= maddsubres[31:0];
	end else if(aluop_i == `EXE_DIV_OP || aluop_i == `EXE_DIVU_OP) begin
		whilo_o = `WriteEnable;
		hi_o	= divres[63:32];
		lo_o	= divres[31:0];
	//_______________________
	end else if(aluop_i == `EXE_MTHI_OP) begin
		whilo_o = `WriteEnable;
		hi_o 	= reg1_i;
		lo_o 	= LO; //because you're writting hi_i, you need not to change lo_o.
	end else if(aluop_i == `EXE_MTLO_OP) begin
		whilo_o = `WriteEnable;
		hi_o 	= HI; //because you're writting lo_o, you need not to change hi_o.
		lo_o 	= reg1_i;		
	//________________________	
	end else begin
		whilo_o = `WriteDisable;
		hi_o 	= `ZeroWord;
		lo_o 	= `ZeroWord;
	end
end 


//#############################################################################################
always @(*) begin
	if(aluop_i == `EXE_MTC0_OP) begin
		cp0_reg_wr_addr_o	= inst_i[15:11];
		cp0_reg_we_o		= `WriteEnable;
		cp0_reg_data_o		= reg2_i; //read from rd
	end else begin
		cp0_reg_wr_addr_o	= 5'b0;
		cp0_reg_we_o		= `WriteDisable;
		cp0_reg_data_o		= `ZeroWord;
	end
end

//==========================================================================
always @(*) begin
	case(aluop_i)
		`EXE_TEQ_OP, `EXE_TEQI_OP:
			trapassert = (reg1_i == reg2_i) ? `TrapAssert : `TrapNotAssert;
		`EXE_TGE_OP, `EXE_TGEI_OP, `EXE_TGEIU_OP, `EXE_TGEU_OP:
			trapassert = (~reg1_lt_reg2) ? `TrapAssert : `TrapNotAssert;
		`EXE_TLT_OP, `EXE_TLTI_OP, `EXE_TLTIU_OP, `EXE_TLTU_OP:
			trapassert = (reg1_lt_reg2) ? `TrapAssert : `TrapNotAssert;
		`EXE_TNE_OP, `EXE_TNEI_OP:
			trapassert = (reg1_i != reg2_i) ? `TrapAssert : `TrapNotAssert;
		default:
			trapassert = `TrapNotAssert;
	endcase
end 


//=========================================================================
always @(*) begin
	if( (aluop_i == `EXE_ADD_OP  ||  aluop_i == `EXE_ADDI_OP  ||  aluop_i == `EXE_SUB_OP)
		&& ov_sum == 1'b1)
		ovassert = 1'b1;
	else
		ovassert = 0;
end 


endmodule