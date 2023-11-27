`define MREAD 1
`define MNONE 2
`define MWRITE 3


module lab7_top(KEY,SW,LEDR,HEX0,HEX1,HEX2,HEX3,HEX4,HEX5);
   input [3:0] KEY;
   input [9:0] SW;
   output [9:0] LEDR;
   output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;

    reg [15:0] dout;
    reg [1:0] mem_cmd;
    reg [8:0] mem_addr;
    reg [7:0] write_adress, read_adress;
    //reg N, V, Z, w;

    reg clk, reset, msel, msel_a, msel_b;
    reg write;
    reg [15:0] read_data, write_data, mdata;

    cpu CPU(.clk(clk), .reset(reset), .read_data(read_data), .mem_cmd(mem_cmd), .mem_addr(mem_addr), .write_data(write_data));
    RAM MEM (.clk(clk), .read_adress(mem_addr[7:0]), .write_adress(mem_addr[7:0]) , .write(write), .din(write_data), .dout(dout));
 
    assign clk = KEY[0];
    assign msel_a = mem_cmd == `MREAD;
    assign msel_b = mem_addr[8] == 1'b0;
    assign msel = msel_a && msel_b;
    assign write = ((mem_cmd == `MWRITE) && msel);

    assign read_data = msel ? dout : {16{1'bz}};
    
endmodule

module vDFF(clk,D,Q);
  parameter n=1;
  input clk;
  input [n-1:0] D;
  output [n-1:0] Q;
  reg [n-1:0] Q;
  always @(posedge clk)
    Q <= D;
endmodule