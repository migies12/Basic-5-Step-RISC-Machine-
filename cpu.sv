`define SW 0
`define SLOADA_Rn 1
`define SLOADB_Rm 2
`define SLOADC 3
`define SMOV_0_WRITE 4
`define SMOV_1_LOADB 5
`define SMOV_1_LOADC 6
`define SMOV_1_WRITE 7
`define SWRITE_Rd 8
`define SLOADS 9

`define SERR 10

module cpu(clk, reset, s, load, in, out, N, V, Z, w);

 input  clk, reset, s, load;
 input  [15:0] in;
 output reg [15:0] out;
 output reg N, V, Z, w;

 reg [15:0] regOut, sximm5, sximm8;  
 reg [1:0] ALUop, shift, vsel;
 reg [2:0] readNum, writeNum, opcode, Rn, Rd, Rm;
 reg [3:0] ns;
 reg loada, loadb, loadc, write, loads,asel,bsel;
 wire [7:0] PC;
 wire [15:0] m_data;

 vDFF #(16) instructionRegister (.clk(clk&load), .D(in), .Q(regOut));


instructionDecoder INSTRUCTIONS (.in(regOut), .opcode(opcode), .op(ALUop),
								.sximm5(sximm5), .sximm8(sximm8), .shift(shift), .Rn(Rn), .Rd(Rd), .Rm(Rm));

assign PC = 0;
assign m_data = 0;

datapath DP (.write(write), .vsel(vsel), .loada(loada), .loadb(loadb), .asel(asel), .bsel(bsel), .loadc(loadc), .loads(loads), .PC(PC),
	 .clk(clk), .readnum(readNum), .writenum(writeNum), .shift(shift), .ALUop(ALUop), .Z_out(Z), .C(out), .sximm8(sximm8), .sximm5(sximm5), .m_data(m_data),
	 .N_out(N), .V_out(V));


//State Machine Block 
always_ff@(posedge clk) begin

if (reset) begin
	ns = `SW;
end else  begin
  case(ns)
	`SW: if (s == 1) begin

		if (opcode[1] == 1) begin 
			if (ALUop == 2'b10) ns <= `SMOV_0_WRITE;
			else if (ALUop == 2'b00) ns <= `SMOV_1_LOADB;
			else ns <= `SERR;
		end else ns <= `SLOADB_Rm;

	    end else ns <= `SW;

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

	`SLOADS: ns <= `SW;

	`SLOADC: begin 
		case(ALUop) 
			2'b00: ns <= `SWRITE_Rd;
			2'b01: ns <= `SW;
			2'b10: ns <= `SWRITE_Rd;
			2'b11: ns <= `SWRITE_Rd;
			default: ns <= `SERR;
		endcase
	end

	`SWRITE_Rd: ns <= `SW;

	//special cases for the move statements
	`SMOV_0_WRITE: ns <= `SW;
	`SMOV_1_LOADB: ns <= `SMOV_1_LOADC;
	`SMOV_1_LOADC: ns <= `SMOV_1_WRITE;
	`SMOV_1_WRITE: ns <= `SW;

	default: ns <= ns;
   endcase 
end //else

end //end always_ff

//conditional always block for sending info to datapath 
always@(ns) begin 
	if(ns != `SW) w <= 1'b0;
	else w <= 1'b1;
	case(ns)
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
		
		`SW: begin 
			write <= 0;
			loada <= 0;
			loadb <= 0;
			loadc <= 0;
			loads <= 0;
			asel <= 0;
			bsel <= 0;
			vsel <= 2'b00;
		end

		default: write <= 0;
	
	endcase

end

endmodule


