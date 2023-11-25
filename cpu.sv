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
 reg [3:0] ns;
 reg loada, loadb, loadc, write, loads,asel,bsel, reset_pc, load_pc, addr_sel, s, w, load_addr;
 reg [8:0] PC, next_PC, addr_out;

 vDFF #(16) instructionRegister (.clk(clk&load_ir), .D(read_data), .Q(regOut));
 vDFF #(9) dataAdress (.clk(clk&load_addr), .D(write_data[8:0]), .Q(addr_out));

 assign next_PC = reset_pc ? 9'b0 : PC + 1'b1;
 assign mem_addr = addr_sel ? PC : addr_out;

 vDFF #(9) programCounter (.clk(clk&load_pc), .D(next_PC), .Q(PC));


instructionDecoder INSTRUCTIONS (.in(regOut), .opcode(opcode), .op(ALUop),
								.sximm5(sximm5), .sximm8(sximm8), .shift(shift), .Rn(Rn), .Rd(Rd), .Rm(Rm));


datapath DP (.write(write), .vsel(vsel), .loada(loada), .loadb(loadb), .asel(asel), .bsel(bsel), .loadc(loadc), .loads(loads), .PC(PC),
	 .clk(clk), .readnum(readNum), .writenum(writeNum), .shift(shift), .ALUop(ALUop), .Z_out(Z), .C(write_data), .sximm8(sximm8), .sximm5(sximm5), .m_data(read_data),
	 .N_out(N), .V_out(V));


//State Machine Block 
always_ff@(posedge clk) begin

if (reset) begin
	ns = `RST;
end else  begin
  case(ns)

	`RST: ns <= `IF1;

	`IF1: ns <= `IF2;

	`UpdatePC: ns <= `DECODE;

	`DECODE: if (load_pc == 1) begin

		if (opcode[1] == 1) begin 
			if (ALUop == 2'b10) ns <= `SMOV_0_WRITE;
			else if (ALUop == 2'b00) ns <= `SMOV_1_LOADB;
			else ns <= `SERR;
		end else ns <= `SLOADB_Rm;

	    end else ns <= `IF1;

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
	//if(ns != `SW) w <= 1'b0;    // no more s or SW
	//else w <= 1'b1;
	case(ns)

		`RST: begin 
			write <= 0;
			loada <= 0;
			loadb <= 0;
			loadc <= 0;
			loads <= 0;
			asel <= 0;
			bsel <= 0;
			vsel <= 2'b00;
			reset_pc <= 1;
			load_pc <= 1;
			addr_sel <= 0;
			mem_cmd <= 0;
			load_ir <= 0;
			load_pc <= 0;

		end

		`IF1: begin 
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
			mem_cmd <= `MREAD;
			load_ir <= 0;
			load_pc <= 0;
		end

		`IF2: begin 
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
			mem_cmd <= `MREAD;
			load_ir <= 1;
			load_pc <= 0;
		end

		`UpdatePC: begin 
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
			mem_cmd <= 0;
			load_ir <= 0;
			load_pc <= 1;
		end

		////// MOV 0 Changes
		`SMOV_0_WRITE: begin 
			//set all loads to 0
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
			addr_sel <= 0;
			mem_cmd <= 0;
			load_ir <= 0;
			load_pc <= 0;
		end 

		//LDR:
		//load Rn
		//Load Rn + sximm5 into C
		//set mem_addr to out val
		//Read From Memory
		//Write to Rd using m_data

		//STR:
		//load Rn
		//Load Rn + sximm5 into C
		//set mem_addr to out val
		// Load Rd into C
		// Use Store into State vvv
	

		//ADD STATE Store INTO:
		//load_addr = 1;
		//addr_select = 0;
		//mem_command = `MWRITE
		

		//ADD STATE READ FROM MEMORY
		//load_addr = 1;
		//addr_select = 0;
		//mem_command = `MREAD
		
		

		default: write <= 0;
	
	endcase

end

endmodule


