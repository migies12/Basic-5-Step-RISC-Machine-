`define imm_OP 2'b10
`define shift_OP 2'b00
`define MOV 3'b110
`define ALU 3'b101 
`define nsel_Rn 3'b000
`define nsel_Rd 3'b001
`define nsel_Rm 3'b010

module instructionDecoder(in, opcode, op, sximm5, sximm8, shift, Rn, Rd, Rm);

 input  [15:0] in;

 output reg [2:0] opcode;  
 output reg [1:0] op;
 output reg [15:0] sximm5;
 output reg [15:0] sximm8;
 output reg [1:0] shift;
 output reg [2:0] Rn,Rd,Rm;


//change the outputs whenever the inputs change 
always@(*) begin

    //assign the op outcomes
    op = in[12:11];
    opcode = in[15:13];
    shift = in[4:3];

    //assign read and write num 
    Rn = in[10:8];
    Rd = in[7:5];
    Rm = in[2:0];

    //sign extend imm5
    if(in[4] == 1) 
	    sximm5 = {11'b11111111111, in[4:0]};
    else
        sximm5 = {11'b0, in[4:0]};
    
    

    //sign extend imm8
    if(in[7] == 1) 
	    sximm8 = {8'b11111111, in[7:0]};
    else
        sximm8 = {8'b0, in[7:0]};
   

end 

endmodule 