//defining two bit binary numbers
`define TWO_BIT_ZERO 2'b00
`define TWO_BIT_ONE  2'b01
`define TWO_BIT_TWO  2'b10
`define TWO_BIT_THREE  2'b11

//Calculates the operation specified by ALUop with the two inputs of Ain and Bin
module ALU(Ain,Bin,ALUop,out,Z, N, V);
input [15:0] Ain, Bin;
input [1:0] ALUop;
output reg [15:0] out;
output reg Z, N, V;

//when the input for a, b or operation changes, the calculator calculates a new value 
always @(Ain or Bin or ALUop) begin
	case(ALUop) 
		`TWO_BIT_ZERO: out = Ain + Bin;
		`TWO_BIT_ONE: out = Ain - Bin;
		`TWO_BIT_TWO: out = Ain & Bin;
		`TWO_BIT_THREE: out = ~Bin;
		default: out = 16'bx;
	endcase

	if (out == 0) Z = 1;
	else Z = 0;

	if (out[15] == 1) N = 1;
	else N = 0;
	
	if((Ain[15] && Bin[15] && ALUop == `TWO_BIT_ZERO && out [15] == 0) || (~Ain[15] && ~Bin[15] && ALUop == `TWO_BIT_ZERO && out [15] == 1) 
	|| (~Ain[15] && Bin[15] && ALUop == `TWO_BIT_ONE && out [15] == 1) || (Ain[15] && ~Bin[15] && ALUop == `TWO_BIT_ONE && out [15] == 0))
		V = 1;
	else
		V = 0;
end 

endmodule
