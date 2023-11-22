//defining two bit binary numbers
`define TWO_BIT_ZERO 2'b00
`define TWO_BIT_ONE  2'b01
`define TWO_BIT_TWO  2'b10
`define TWO_BIT_THREE  2'b11

module shifter(in,shift,sout);
input [15:0] in;
input [1:0] shift;
output reg [15:0] sout;

//anytime shift or in (both input regs) is changed we want to redefine the output sout
//THis is due to the fact that we want the ALU op to be synchronous on input changes loaded into the A and B vDFF's

always @(shift or in) begin 
    
    //assign sout to be one of these 4 cases given in Lab5 handout
    case(shift)
        `TWO_BIT_ZERO: sout = in;
        `TWO_BIT_ONE: sout = in << 1;
        `TWO_BIT_TWO: sout = in >> 1;
        `TWO_BIT_THREE: sout = $signed(in) >>> 1;
        default: sout = 16'bx;
    endcase
end

endmodule

