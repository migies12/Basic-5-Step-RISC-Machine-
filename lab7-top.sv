`define MREAD 1
`define MNONE 2
`define MWRITE 3

`define H0 7'b1000000
`define H1 7'b1111001
`define H2 7'b0100100
`define H3 7'b0110000
`define H4 7'b0011001
`define H5 7'b0010010
`define H6 7'b0000010
`define H7 7'b1111000
`define H8 7'b0000000
`define H9 7'b0010000
`define HA 7'b0001000
`define HB 7'b0000011
`define HC 7'b1000110
`define HD 7'b0100001
`define HE 7'b0000110
`define HF 7'b0001110
`define OFF 7'b1111111

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

    sseg H0(read_data[3:0],   HEX0);
    sseg H1(read_data[7:4],   HEX1);
    sseg H2(read_data[11:8],  HEX2);
    sseg H3(read_data[15:12], HEX3);

    reg clk, reset, msel, msel_a, msel_b, ssel_a, ssel_b, ssel;
    reg write;
    reg [15:0] read_data, write_data, mdata;

    cpu CPU(.clk(clk), .reset(reset), .read_data(read_data), .mem_cmd(mem_cmd), .mem_addr(mem_addr), .write_data(write_data));
    RAM MEM (.clk(clk), .read_adress(mem_addr[7:0]), .write_adress(mem_addr[7:0]) , .write(write), .din(write_data), .dout(dout));

    // switchReceiver switches(.SW(SW[7:0]), .mem_cmd(mem_cmd), .mem_addr(mem_addr), .read_data(read_data));
    // LEDout LEDs(.LEDR(LEDR), .mem_cmd(mem_cmd), .mem_addr(mem_addr), .write_data(write_data));
 
    assign clk = ~KEY[0];
    assign reset = ~KEY[1];
    assign msel_a = mem_cmd == `MREAD;
    assign msel_b = mem_addr[8] == 1'b0;
    assign msel = msel_a && msel_b;
    assign write = ((mem_cmd == `MWRITE) && msel_b);

    assign read_data = msel ? dout : {16{1'bz}};
    
endmodule

module sseg(in,segs);
  input [3:0] in;
  output reg [6:0] segs;

  // NOTE: The code for sseg below is not complete: You can use your code from
  // Lab4 to fill this in or code from someone else's Lab4.  
  //
  // IMPORTANT:  If you *do* use someone else's Lab4 code for the seven
  // segment display you *need* to state the following three things in
  // a file README.txt that you submit with handin along with this code: 
  //
  //   1.  First and last name of student providing code
  //   2.  Student number of student providing code
  //   3.  Date and time that student provided you their code
  //
  // You must also (obviously!) have the other student's permission to use
  // their code.
  //
  // To do otherwise is considered plagiarism.
  //
  // One bit per segment. On the DE1-SoC a HEX segment is illuminated when
  // the input bit is 0. Bits 6543210 correspond to:
  //
  //    0000
  //   5    1
  //   5    1
  //    6666
  //   4    2
  //   4    2
  //    3333
  //
  // Decimal value | Hexadecimal symbol to render on (one) HEX display
  //             0 | 0
  //             1 | 1
  //             2 | 2
  //             3 | 3
  //             4 | 4
  //             5 | 5
  //             6 | 6
  //             7 | 7
  //             8 | 8
  //             9 | 9
  //            10 | A
  //            11 | b
  //            12 | C
  //            13 | d
  //            14 | E
  //            15 | F

  always @(in) begin
    case(in)
      4'd0: segs = `H0;
      4'd1: segs = `H1;
      4'd2: segs = `H2;
      4'd3: segs = `H3;
      4'd4: segs = `H4;
      4'd5: segs = `H5;
      4'd6: segs = `H6;
      4'd7: segs = `H7;
      4'd8: segs = `H8;
      4'd9: segs = `H9;
      4'd10: segs = `HA;
      4'd11: segs = `HB;
      4'd12: segs = `HC;
      4'd13: segs = `HD;
      4'd14: segs = `HE;
      4'd15: segs = `HF;
      default: segs = `OFF;
    endcase
  end

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

// module switchReceiver(SW, mem_cmd, mem_addr, read_data);
// input [2:0] mem_cmd;
// input [9:0] mem_addr;
// input [7:0] SW;
// output reg [15:0] read_data;

// assign read_data = (mem_addr == 9'h140 && mem_cmd == `MREAD) ? SW : 8'bz;

// endmodule

// module LEDout(LEDR, mem_cmd, mem_addr, write_data);
// input [1:0] mem_cmd;
// input [8:0] mem_addr;
// output reg [7:0] LEDR;
// input [15:0] write_data;

// reg write;

// assign write = mem_addr == 9'h100 && mem_cmd == `MWRITE;

// vDFFenable LED_V(.clk(clk), .enable(write), .Q(write_data), .D(LEDR));

// endmodule