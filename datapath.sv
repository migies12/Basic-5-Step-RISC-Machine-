

//Datapath links modules: regfile, shifter, alu, snd vDFF's so they all work together to create one bigger module that acts as a RISC machien
module datapath(write, vsel, loada, loadb, asel, bsel, loadc, loads, PC,
		 clk, readnum, writenum, shift, ALUop, Z_out, C, sximm8, sximm5, m_data, N_out, V_out);

  input [15:0] sximm8, m_data, sximm5;
  input [7:0] PC;
  input clk, write, loada, loadb, asel, bsel, loadc, loads;
  input [2:0] writenum, readnum;
  input [1:0] shift, ALUop, vsel;
 
  output [15:0] C;
  output reg Z_out, N_out, V_out;

  reg [15:0] Ain, Bin,data_out, A_out, B_out, ALU_out, B_shift, data_in, sout;
  reg Z, N, V;
  
  assign data_in  = vsel[1:0] == 2'b00 ? C: 
                    vsel[1:0] == 2'b01 ? {8'b0, PC}:
                    vsel[1:0] == 2'b10 ? sximm8: 
                    m_data;

  //Assign a new module called REGFILE, which is a regfile module with 8 registers that you can load an read data from.
  regfile REGFILE (.data_in(data_in), .writenum(writenum),
			 .write(write), .readnum(readnum), .clk(clk), .data_out(data_out));

  //vDFF A represents flip flop A, that you can load a register value to.
  vDFF #(16) A_flip (.clk(clk & loada), .D(data_out), .Q(A_out));

  //vDFF B represents flip flop B, that you can load a register value to.
  vDFF #(16) B_flip (.clk(clk & loadb), .D(data_out), .Q(B_out));

  //vDFF C represents flip flop C, that you can load the value computer by the ALU module to.
  vDFF #(16) C_flip (.clk(clk & loadc), .D(ALU_out), .Q(C));

  //vDFF status loads one bit connected to reg Z into flipflip status when loads is high.
  vDFF Z_flip (.clk(clk & loads), .D(Z), .Q(Z_out));
  vDFF V_flip (.clk(clk & loads), .D(N), .Q(N_out));
  vDFF N_flip (.clk(clk & loads), .D(V), .Q(V_out));

  //Shifter module takes output of vDFF B and otuputs to sout depending on what functionality (shift) was inputed
  shifter shifter (.in(B_out), .shift(shift), .sout(sout));

  //Ain is the reg that is used as an input to A terminal of ALU. There is a mux select option that lets you overide
  //the A flip flop with val 16'b0 if necessary
  assign Ain = (asel == 1) ? 16'b0 : A_out;

   //Bin is the reg that is used as an input to B terminal of ALU. There is a mux select option that lets you overide
  //the B flip flop with the last 5 bits of PC if necessary.
  assign Bin = (bsel == 1) ? sximm5 : sout;

  //Define ALU module, takes previously assigned Bin and AIN as inputs, outputting ALU out depending on ALUop operation selected. Z = 1 when ALU_out == 0;
  ALU calculator (.Ain(Ain), .Bin(Bin), .ALUop(ALUop), .out(ALU_out) , .Z(Z), .V(V), .N(N));


endmodule