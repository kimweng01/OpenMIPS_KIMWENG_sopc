`include	"define.v"

module hazard(
	input					stallreq_from_if,
	input					stallreq_from_id,
	input					stallreq_from_ex,
	input					stallreq_from_mem,
	
	input		[`RegBus]	excepttype_i,
	input		[`RegBus]	cp0_epc_i,
	
	output reg	[5:0]		stall,
	output reg				flush,
	
	output reg	[`RegBus]	new_pc		
	);
	
	

always @(*) begin
	if(excepttype_i != `ZeroWord) begin
		flush = 1'b1;
		stall = 6'b000000;
		case(excepttype_i)
			32'h00000001:
				new_pc = 32'h00000020;
			32'h00000008:
				new_pc = 32'h00000040;
			32'h0000000a:
				new_pc = 32'h00000040;
			32'h0000000d:
				new_pc = 32'h00000040;
			32'h0000000c:
				new_pc = 32'h00000040;
			32'h0000000e:
				new_pc = cp0_epc_i;
			default: begin
				new_pc = `ZeroWord;
			end
		endcase
	
	end else if(stallreq_from_mem == `Stop) begin
		stall = 6'b011111; //1=stop, continue from next of mem
		flush = 0;
	
		new_pc = `ZeroWord;
	end else if(stallreq_from_ex == `Stop) begin
		stall = 6'b001111; //1=stop, continue from next of ex
		flush = 0;
		
		new_pc = `ZeroWord;
	end else if(stallreq_from_id == `Stop) begin
		stall = 6'b000111; //1=stop, continue from next of id
		flush = 0;
		
		new_pc = `ZeroWord;
	end else if(stallreq_from_if == `Stop) begin
		stall = 6'b000111; //1=stop, see textbook p.12-20!
		flush = 0;
	
		new_pc = `ZeroWord;
	end else begin
		stall = 6'b000000;
		flush = 0;
		
		new_pc = `ZeroWord;
	end 
end 


endmodule