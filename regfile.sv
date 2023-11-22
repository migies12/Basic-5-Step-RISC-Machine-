
module regfile(data_in,writenum,write,readnum,clk,data_out);

localparam IV0 = 8'b00000001;
localparam IV1 = 8'b00000010;
localparam IV2 = 8'b00000100;
localparam IV3 = 8'b00001000;
localparam IV4 = 8'b00010000;
localparam IV5 = 8'b00100000;
localparam IV6 = 8'b01000000;
localparam IV7 = 8'b10000000;

reg[15:0] R0, R1, R2, R3, R4, R5, R6, R7;


input [15:0] data_in;
input [2:0] writenum, readnum;
input write, clk;
output [15:0] data_out;
reg registerOut;
reg regSel[2:0];

//Whenever posedge clk we want to run all the regfile flip flops
always_ff @(posedge clk) begin



if (write) begin
case(writenum)

	//Depending on which register the user wants to read from (writenum) write to that register ONLY and assign all other registers their previously stored val
	0:begin
	   R0 <= data_in;
	   R1 <= R1;
	   R2 <= R2;
	   R3 <= R3;
	   R4 <= R4;
	   R5 <= R5;
	   R6 <= R6;
	   R7 <= R7;
	   end

	1: begin
	   R0 <= R0;
	   R1 <= data_in;
	   R2 <= R2;
	   R3 <= R3;
	   R4 <= R4;
	   R5 <= R5;
	   R6 <= R6;
	   R7 <= R7;
	   end

	2: begin
 	   R0 <= R0;
	   R1 <= R1;
	   R2 <= data_in;
	   R3 <= R3;
	   R4 <= R4;
	   R5 <= R5;
	   R6 <= R6;
	   R7 <= R7;
	   end

	3: begin 
	   R0 <= R0;
	   R1 <= R1;
	   R2 <= R2;
	   R3 <= data_in;
	   R4 <= R4;
	   R5 <= R5;
	   R6 <= R6;
	   R7 <= R7;
	   end

	4: begin
	   R0 <= R0;
	   R1 <= R1;
	   R2 <= R2;
	   R3 <= R3;
	   R4 <= data_in;
	   R5 <= R5;
	   R6 <= R6;
	   R7 <= R7;
	   end

	5: begin
	   R0 <= R0;
	   R1 <= R1;
	   R2 <= R2;
	   R3 <= R3;
	   R4 <= R4;
	   R5 <= data_in;
	   R6 <= R6;
	   R7 <= R7;
	   end

	6: begin 
	   R0 <= R0;
	   R1 <= R1;
	   R2 <= R2;
	   R3 <= R3;
	   R4 <= R4;
	   R5 <= R5;
	   R6 <= data_in;
	   R7 <= R7;
	   end

	7: begin
	   R0 <= R0;
	   R1 <= R1;
	   R2 <= R2;
	   R3 <= R3;
	   R4 <= R4;
	   R5 <= R5;
	   R6 <= R6;
	   R7 <= data_in;
	   end

	//default will take all previous values of the stored registers as failsafe but should not happen
	default: begin
	   R0 <= R0;
	   R1 <= R1;
	   R2 <= R2;
	   R3 <= R3;
	   R4 <= R4;
	   R5 <= R5;
	   R6 <= R6;
	   R7 <= R7;
	   end

endcase

end 

end //always

//Assign data_out of the regfile module to be the value of readnum
//This assign is NOT in an always block since we do not want this to execute periodically, but instead it must always be true. 
//Hence readnum will take a mux to determine its value based on the readnum select number

assign data_out = (readnum == 3'b000) ? R0 :
              (readnum == 3'b001) ? R1 :
              (readnum == 3'b010) ? R2 :
              (readnum == 3'b011) ? R3 :
              (readnum == 3'b100) ? R4 :
              (readnum == 3'b101) ? R5 :
              (readnum == 3'b110) ? R6 :
              (readnum == 3'b111) ? R7 :
              1'b0; // Default case if none of the select lines match (should be impossible due to all cases of 3'b are filled)





endmodule