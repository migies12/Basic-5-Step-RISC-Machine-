`define DECODE 0
`define SLOADA_Rn 1
`define SLOADB_Rm 2
`define SLOADC 3
`define SMOV_0_WRITE 4
`define SMOV_1_LOADB 5
`define SMOV_1_LOADC 6
`define SMOV_1_WRITE 7
`define SWRITE_Rd 8
`define SLOADS 9
`define RST 10
`define IF1 11
`define IF2 12
`define UpdatePC 13
`define HALT 14
`define LDR_LOAD_RN_A 15
`define LDR_LOADC 16
`define LDR_LOAD_ADDY 17
`define MEMORY_CLOCK 18
`define STR_LOAD_RN_A 19
`define STR_LOADC 20
`define STR_LOAD_ADDY 21
`define STR_LOADB 22
`define STR_LOADC_2 23

`define MREAD 1
`define MNONE 2
`define MWRITE 3

`define SERR 10

module cpu(clk, reset, read_data, mem_cmd, mem_addr, write_data);    //s and w are no longer inputs

 input  clk, reset;
 reg load_ir;
 input  [15:0] read_data;
 output reg [15:0] write_data;
 output reg [1:0] mem_cmd;
 output reg [8:0] mem_addr;
 //output reg N, V, Z, w;    //I DONT KNOW IF WE NEED FLAGS AT ALL ANYMORE???

 reg [15:0] regOut, sximm5, sximm8;  
 reg [1:0] ALUop, shift, vsel;
 reg [2:0] readNum, writeNum, opcode, Rn, Rd, Rm;
 reg [5:0] ns;
 reg loada, loadb, loadc, write, loads,asel,bsel, reset_pc, load_pc, addr_sel, s, w, load_addr;
 reg [8:0] PC, next_PC, addr_out;

 vDFFenable #(16) instructionRegister (.clk(clk), .enable(load_ir), .D(read_data), .Q(regOut));
 vDFFenable #(9) dataAdress (.clk(clk),.enable(load_addr), .D(write_data[8:0]), .Q(addr_out));
 vDFFenable #(9) programCounter (.clk(clk),.enable(load_pc),.D(next_PC), .Q(PC));

 assign next_PC = reset_pc ? 9'b0 : PC + 1'b1;
 assign mem_addr = addr_sel ? PC : addr_out;

instructionDecoder INSTRUCTIONS (.in(regOut), .opcode(opcode), .op(ALUop),
								.sximm5(sximm5), .sximm8(sximm8), .shift(shift), .Rn(Rn), .Rd(Rd), .Rm(Rm));


datapath DP (.write(write), .vsel(vsel), .loada(loada), .loadb(loadb), .asel(asel), .bsel(bsel), .loadc(loadc), .loads(loads), .PC(PC),
	 .clk(clk), .readnum(readNum), .writenum(writeNum), .shift(shift), .ALUop(ALUop), .Z_out(Z), .C(write_data), .sximm8(sximm8), .sximm5(sximm5), .m_data(read_data),
	 .N_out(N), .V_out(V));


//State Machine Block 
always_ff@(posedge clk) begin

if (reset) begin
	ns <= `RST; //do we need this to be non blocking or do we want it to happen all in one clock cycle?
end else  begin
  case(ns)
	//loop back until reset is hit!!
	`HALT: ns <= `HALT;

	`RST: ns <= `IF1;

	`IF1: ns <= `IF2;

	`IF2: ns <= `UpdatePC;

	`UpdatePC: ns <= `DECODE;

	`DECODE: begin

		if (opcode == 3'b110) begin 
			if (ALUop == 2'b10) ns <= `SMOV_0_WRITE;
			else if (ALUop == 2'b00) ns <= `SMOV_1_LOADB;
			else ns <= `SERR;
		end 
		else if (opcode == 3'b111) ns <= `HALT;
		else if (opcode == 3'b011) ns <= `LDR_LOAD_RN_A;
		else if (opcode == 3'b100) ns <= `STR_LOAD_RN_A;
		else ns <= `SLOADB_Rm;
	end

	`LDR_LOAD_RN_A: ns <= `LDR_LOADC;

	`LDR_LOADC: ns <= `LDR_LOAD_ADDY;

	`LDR_LOAD_ADDY: ns <= `MEMORY_CLOCK;

	`STR_LOAD_RN_A: ns <= `STR_LOADC;

	`STR_LOADC: ns <= `STR_LOAD_ADDY;

	`STR_LOAD_ADDY: ns <= `STR_LOADB;

	`STR_LOADB: ns <= `STR_LOADC_2;

	`STR_LOADC_2: ns <= `MEMORY_CLOCK;

	`MEMORY_CLOCK: ns <= `IF1;

	`SLOADB_Rm: begin 
		case(ALUop) 
			2'b00: ns <= `SLOADA_Rn;
			2'b01: ns <= `SLOADA_Rn;
			2'b10: ns <= `SLOADA_Rn;
			2'b11: ns <= `SLOADC;
			default: ns <= `SERR;
		endcase
	end

	`SLOADA_Rn: begin 
		case(ALUop) 
			2'b00: ns <= `SLOADC;
			2'b01: ns <= `SLOADS;
			2'b10: ns <= `SLOADC;
			default: ns <= `SERR;
		endcase
	end

	`SLOADS: ns <= `IF1;

	`SLOADC: begin 
		case(ALUop) 
			2'b00: ns <= `SWRITE_Rd;
			2'b01: ns <= `IF1;
			2'b10: ns <= `SWRITE_Rd;
			2'b11: ns <= `SWRITE_Rd;
			default: ns <= `SERR;
		endcase
	end

	`SWRITE_Rd: ns <= `IF1;

	//special cases for the move statements
	`SMOV_0_WRITE: ns <= `IF1;
	`SMOV_1_LOADB: ns <= `SMOV_1_LOADC;
	`SMOV_1_LOADC: ns <= `SMOV_1_WRITE;
	`SMOV_1_WRITE: ns <= `IF1;

	default: ns <= ns;
   endcase 

end //else

end //end always_ff

//conditional always block for sending info to datapath 
always@(ns) begin 
	case(ns)
		`RST: begin 
			reset_pc <= 1;
			write <= 0;
			loada <= 0;
			loadb <= 0;
			loadc <= 0;
			loads <= 0;
			asel <= 0;
			bsel <= 0;
			vsel <= 2'b00;
			addr_sel <= 0;
			mem_cmd <= `MREAD;
			load_ir <= 0;
			load_pc <= 1;
		end

		`IF1: begin 
			reset_pc <= 0;
			write <= 0;
			loada <= 0;
			loadb <= 0;
			loadc <= 0;
			loads <= 0;
			asel <= 0;
			bsel <= 0;
			vsel <= 2'b00;
			addr_sel <= 1;
			mem_cmd <= `MREAD;
			load_ir <= 0;
			load_pc <= 0;
		end

		`IF2: begin 
			reset_pc <= 0;
			write <= 0;
			loada <= 0;
			loadb <= 0;
			loadc <= 0;
			loads <= 0;
			asel <= 0;
			bsel <= 0;
			vsel <= 2'b00;
			addr_sel <= 1;
			mem_cmd <= `MREAD;
			load_ir <= 1;
			load_pc <= 0;
		end

		`UpdatePC: begin 
			reset_pc <= 0;
			write <= 0;
			loada <= 0;
			loadb <= 0;
			loadc <= 0;
			loads <= 0;
			asel <= 0;
			bsel <= 0;
			vsel <= 2'b00;
			reset_pc <= 0;
			addr_sel <= 0;
			mem_cmd <= 0;
			load_ir <= 0;
			load_pc = 1;
		end

		////// MOV 0 Changes
		`SMOV_0_WRITE: begin 
			//set all loads to 0
			load_pc <= 0;
			write <= 1;
			writeNum <= Rn;
			readNum <= Rn;
			loada <= 0;
			loadb <= 0;
			loadc <= 0;
			loads <= 0;
			asel <= 0;
			bsel <= 0;
			//choose 8xsimm
			vsel <= 2'b10;
			//write to the right register
			
		end 
		//////////MOV 1 Changes
		//load Rm into b and clk 
		`SMOV_1_LOADB: begin 
			//Read from Rm
			load_pc <= 0;
			write <= 0;
			readNum <= Rm;
			loada <= 0;
			loadb <= 1;
			loadc <= 0;
			loads <= 0;
			vsel <= 2'b10;

			//set add to all zeros
			asel <= 1;
			bsel <= 1;
		end 

		`SMOV_1_LOADC: begin 
			//Read from Rm
			load_pc <= 0;
			write <= 0;
			loada <= 0;
			loadb <= 0;
			loadc <= 1;
			loads <= 0;

			//set add to all zeros
			asel <= 1;
			bsel <= 0;
		end 

		//move the value from Rm_sh to Rd
		`SMOV_1_WRITE: begin
			//set all loads to 0
			//Write into Rd
			load_pc <= 0;
			write <= 1;
			writeNum <= Rd;
			loada <= 0;
			loadb <= 0;
			loadc <= 0;
			loads <= 0;

			asel <= 0;
			bsel <= 0;
			//choose C output
			vsel <= 2'b00;
			//write to the right register
			write <= 1;
		end

		//////ALU 0 Instructions
		`SLOADB_Rm: begin 
			write <= 0;
			load_pc <= 0;
			readNum <= Rm;
			loada <= 0;
			loadb <= 1;
			loadc <= 0;
			loads <= 0;
			asel <= 0;
			bsel <= 0;
		end

		`SLOADA_Rn: begin 
			write <= 0;
			load_pc <= 0;
			readNum <= Rn;
			loada <= 1;
			loadb <= 0;
			loadc <= 0;
			loads <= 0;
			vsel <= 2'b10;
			asel <= 0;
			bsel <= 0;
		end

		`SLOADC: begin 
			write <= 0;
			load_pc <= 0;
			loada <= 0;
			loadb <= 0;
			loadc <= 1;
			loads <= 0;
			asel <= 0;
			bsel <= 0;
		end 

		`SWRITE_Rd: begin 
			//Write into Rd
			write <= 1;
			load_pc <= 0;
			writeNum <= Rd;
			loada <= 0;
			loadb <= 0;
			loadc <= 0;
			loads <= 0;
			asel <= 0;
			bsel <= 0;
			//choose C output
			vsel <= 2'b00;
		end
		
		`SLOADS: begin 
			write <= 0;
			load_pc <= 0;
			loada <= 0;
			loadb <= 0;
			loadc <= 0;
			loads <= 1;
			asel <= 0;
			bsel <= 0;
			vsel <= 2'b00;
		end 

		`DECODE: begin 
			write <= 0;
			loada <= 0;
			loadb <= 0;
			loadc <= 0;
			loads <= 0;
			asel <= 0;
			bsel <= 0;
			vsel <= 2'b00;
			reset_pc <= 0;
			load_pc <= 0;
			addr_sel <= 1;
			mem_cmd <= 0;
			load_ir <= 0;
			load_pc <= 0;
		end 

		`HALT: begin
			write <= 0;
			loada <= 0;
			loadb <= 0;
			loadc <= 0;
			loads <= 0;
			asel <= 0;
			bsel <= 0;
			vsel <= 2'b00;
			reset_pc <= 0;
			load_pc <= 0;
			addr_sel <= 1;
			mem_cmd <= 0;
			load_ir <= 0;
			load_pc <= 0;
		end

		`LDR_LOAD_RN_A: begin 
			readNum <= Rn;
			write <= 0;
			loada <= 1;
			loadb <= 0;
			loadc <= 0;
			loads <= 0;
			asel <= 0;
			bsel <= 1;
			vsel <= 2'b00;
			reset_pc <= 0;
			load_pc <= 0;
			addr_sel <= 1;
			mem_cmd <= 0;
			load_ir <= 0;
			load_pc <= 0;
		end

		`LDR_LOADC: begin 
			readNum <= Rn;
			write <= 0;
			loada <= 0;
			loadb <= 0;
			loadc <= 1;
			loads <= 0;
			asel <= 0;
			bsel <= 1;
			vsel <= 2'b00;
			reset_pc <= 0;
			load_pc <= 0;
			addr_sel <= 1;
			mem_cmd <= 0;
			load_ir <= 0;
			load_pc <= 0;
		end 

		//SHOULD I CHNAGE ADDY SELECT HERE OR IN MEMORY CLK
		`LDR_LOAD_ADDY: begin 
			write <= 0;
			loada <= 0;
			loadb <= 0;
			loadc <= 0;
			loads <= 0;
			asel <= 0;
			bsel <= 1;
			vsel <= 2'b00;
			reset_pc <= 0;
			load_pc <= 0;
			addr_sel <= 1;
			mem_cmd <= `MREAD;
			load_ir <= 0;
			load_pc <= 0;
		end 

		`MEMORY_CLOCK: begin
    		write <= 0;
    		loada <= 0;
    		loadb <= 0;
    		loadc <= 0;
    		loads <= 0;
    		asel <= 0;
    		bsel <= 0;
    		vsel <= 2'b00;
    		reset_pc <= 0;
    		load_pc <= 0;
    		addr_sel <= 0;
    		mem_cmd <= `MREAD;
    		load_ir <= 0;
    		load_pc <= 0;
		end

		`STR_LOAD_RN_A: begin 
			readNum <= Rn;
			write <= 0;
			loada <= 1;
			loadb <= 0;
			loadc <= 0;
			loads <= 0;
			asel <= 0;
			bsel <= 1;
			vsel <= 2'b00;
			reset_pc <= 0;
			load_pc <= 0;
			addr_sel <= 1;
			mem_cmd <= 0;
			load_ir <= 0;
			load_pc <= 0;
		end

	    `STR_LOADC: begin 
			readNum <= Rn;
			write <= 0;
			loada <= 0;
			loadb <= 0;
			loadc <= 1;
			loads <= 0;
			asel <= 0;
			bsel <= 1;
			vsel <= 2'b00;
			reset_pc <= 0;
			load_pc <= 0;
			addr_sel <= 1;
			mem_cmd <= 0;
			load_ir <= 0;
			load_pc <= 0;
		end
		//should we keep program counter counting here
		`STR_LOAD_ADDY: begin 
			write <= 0;
			loada <= 0;
			loadb <= 0;
			loadc <= 0;
			loads <= 0;
			asel <= 0;
			bsel <= 1;
			vsel <= 2'b00;
			reset_pc <= 0;
			load_pc <= 0;
			addr_sel <= 1;
			mem_cmd <= `MWRITE;
			load_ir <= 0;
			load_pc <= 0;
		end

		`STR_LOADB: begin 
			readNum <= Rd;
			write <= 0;
			loada <= 0;
			loadb <= 1;
			loadc <= 0;
			loads <= 0;
			asel <= 0;
			bsel <= 0;
			vsel <= 2'b00;
			reset_pc <= 0;
			load_pc <= 0;
			addr_sel <= 1;
			mem_cmd <= 0;
			load_ir <= 0;
			load_pc <= 0;
		end

		`STR_LOADC_2: begin 
			readNum <= Rn;
			write <= 0;
			loada <= 0;
			loadb <= 0;
			loadc <= 1;
			loads <= 0;
			asel <= 0;
			bsel <= 0;
			vsel <= 2'b00;
			reset_pc <= 0;
			load_pc <= 0;
			addr_sel <= 1;
			mem_cmd <= 0;
			load_ir <= 0;
			load_pc <= 0;
		end		

		default: write <= 0;
	
	endcase

end

endmodule


