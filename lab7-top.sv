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

    reg clk, reset, msel, msel_a, msel_b, ssel_a, ssel_b, ssel;
    reg write;
    reg [15:0] read_data, write_data, mdata;

    cpu CPU(.clk(clk), .reset(reset), .read_data(read_data), .mem_cmd(mem_cmd), .mem_addr(mem_addr), .write_data(write_data));
<<<<<<< HEAD
    RAM MEM (.clk(clk), .read_adress(mem_addr[7:0]), .write_adress(mem_addr[7:0]) , .write(write), .din(write_data), .dout(dout));

    switchReceiver switches(.SW(SW[7:0]), .mem_cmd(mem_cmd), .mem_addr(mem_addr), .read_data(read_data));
    LEDout LEDs(.LEDR(LEDR), .mem_cmd(mem_cmd), .mem_addr(mem_addr), .write_data(write_data));

=======
    RAM MEM(.clk(clk), .read_adress(mem_addr[7:0]), .write_adress(mem_addr[7:0]) , .write(write), .din(write_data), .dout(dout));
 
>>>>>>> 6a22b9d12ee457cec807aa586ab90fd99b8c9a3a
    assign clk = ~KEY[0];
    assign reset = ~KEY[1];
    assign msel_a = mem_cmd == `MREAD;
    assign msel_b = mem_addr[8] == 1'b0;
    assign msel = msel_a && msel_b;
    assign write = ((mem_cmd == `MWRITE) && msel_b);

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

module vDFFenable(clk,enable, D,Q);
  parameter n=1;
  input clk;
  input [n-1:0] D;
  output [n-1:0] Q;
  input enable;
  reg [n-1:0] Q;
  always @(posedge clk)
    if (enable == 1)
      Q <= D;
endmodule

module switchReceiver(SW, mem_cmd, mem_addr, read_data);
input [2:0] mem_cmd;
input [9:0] mem_addr;
input [7:0] SW;
output reg [15:0] read_data;

assign read_data = (mem_addr == 9'h140 && mem_cmd == `MREAD) ? SW : 8'bz;

endmodule

module LEDout(LEDR, mem_cmd, mem_addr, write_data);
input [1:0] mem_cmd;
input [8:0] mem_addr;
output reg [7:0] LEDR;
input [15:0] write_data;


reg write;

assign write = mem_addr == 9'h100 && mem_cmd == `MWRITE;

vDFFenable LED_V(.clk(clk), .enable(write), .Q(write_data), .D(LEDR));




endmodule