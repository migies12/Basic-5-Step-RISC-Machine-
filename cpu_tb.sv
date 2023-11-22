
module cpu_tb();

  // Inputs

 reg  sim_clk, sim_reset, sim_s, sim_load;
 reg  [15:0] sim_in;
 reg err;
 
  
    // Outputs
 wire [15:0] sim_out;
 wire sim_N, sim_V, sim_Z, sim_w;
    
cpu cpu(.clk(sim_clk), .reset(sim_reset), .s(sim_s), .load(sim_load), .in(sim_in), .out(sim_out),.N(sim_N), .V(sim_V), .Z(sim_Z), .w(sim_w));
initial begin
    sim_clk = 0; #5;
    forever begin
      sim_clk = 1; #3;
      sim_clk = 0; #3;
    end
  end
initial begin
err = 0;
sim_clk = 0; #5;
    
//SETUP//

 sim_reset = 1;
 sim_s = 0;
 sim_load = 0;
 sim_in = 0;
#15

//TEST 1: MOV R0,#7;    =>    in = 16'b1101000000000111

sim_reset = 0;
sim_in = 16'b1101000000000111;
sim_load = 1;
sim_s = 1;
sim_clk = 1;
#15
sim_clk = 0;
sim_load = 0;
sim_s = 0;
sim_load = 0;
#15

$display("Test 1 - Attempt ot run command %b - MOV R0, #7; -OUTPUT: %b  -Expected: %b, w = %b", sim_in, sim_out, 16'b0, sim_w);
	
	if(~(sim_out == 16'b0) && sim_w != 1) err = 1;

//TEST 2: MOV R1,#2    =>    in = 16'b1101000100000010 
sim_reset = 0;
sim_in = 16'b1101000100000010;
sim_load = 1;
sim_s = 1;
sim_clk = 1;
#15
sim_clk = 0;
sim_load = 0;
sim_s = 0;
sim_load = 0;
#15

$display("Test 2 -  - MOV R1, #2: Attempt ot run command %b -OUTPUT: %b  -Expected: %b, w =%b", sim_in, sim_out, 16'b0, sim_w);
	
	if(~(sim_out == 16'b0) || sim_w != 1) err = 1;


//TEST3: ADD R2, R1, R0;    =>    in = 16'n1010000101001000 
//CURRENT REG VALS:
//R0: 7
//R1: 2
//R2: 16
//R3: -
//R4: -
//R5: -
//R6: -
//R7: -

sim_reset = 0;
sim_in = 16'b1010000101001000;
sim_load = 1;
sim_s = 1;
#15
sim_load = 0;
sim_s = 0;
sim_load = 0;
#15

$display("Test 3 - ADD R2, R1, R0 LSL#1: Attempt ot run command %b ; -OUTPUT: %b  -Expected: %b, w =%b", sim_in, sim_out, 16'd16, sim_w);
	
	if(~(sim_out == 16'd16) || sim_w != 1) err = 1;

//TEST4: MOV R3, R2;    =>   in = 16'b1100000001100010 
//CURRENT REG VALS:
//R0: 7
//R1: 2
//R2: 16
//R3: 16
//R4: -
//R5: -
//R6: -
//R7: -

sim_reset = 0;
sim_in = 16'b1100000001100010;
sim_load = 1;
sim_s = 1;

#15
sim_load = 0;
sim_s = 0;
sim_load = 0;
#15


$display("Test 4- MOV R3, R2 : Attempt ot run command %b  - OUTPUT: %b  -Expected: %b, w =%b", sim_in, sim_out, 16'd16, sim_w);
	
	if(~(sim_out == 16'd16) || sim_w != 1) err = 1;
	
	
//TEST5: CMP R3, R2;    =>  in = 16'b1010101100000010 (flag Z)
//CURRENT REG VALS:
//R0: 7
//R1: 2
//R2: 16
//R3: 16
//R4: 
//R5: -
//R6: -
//R7: -

sim_reset = 0;
sim_in = 16'b1010101100000010;
sim_load = 1;
sim_s = 1;

#15

sim_load = 0;
sim_s = 0;
sim_load = 0;
#15

//Out should be the same as before since there is no change in the ALU module.
$display("Test 5 - CMP R3, R2: Attempt ot run command %b -OUTPUT: Z: %b V %b: N: %b   -Expected: Z: %b V %b: N: %b,   w = %b", sim_in, sim_Z, sim_V, sim_N, 1'b1, 1'b0, 1'b0, sim_w);
	
	if(~(sim_Z == 1) || ~(sim_V == 0) || ~(sim_N == 0)  || sim_w != 1) err = 1;
	
//TEST6: CMP R3, R1;    =>   in = 16'b1010101100000001 (flag N)
//CURRENT REG VALS:
//R0: 7
//R1: 2
//R2: 16
//R3: 16
//R4: 
//R5: -
//R6: -
//R7: -

sim_reset = 0;
sim_in = 16'b1010101100000001;
sim_load = 1;
sim_s = 1;

#15

sim_load = 0;
sim_s = 0;
sim_load = 0;
#15


$display("Test 6: CMP R3, R1: Attempt ot run command %b - OUTPUT: Z: %b V %b: N: %b   -Expected: Z: %b V %b: N: %b, w = %b", sim_in, sim_Z, sim_V, sim_N, 1'b0, 1'b0, 1'b0, sim_w);
	
	if(~(sim_Z == 0) || ~(sim_V == 0) || ~(sim_N == 0) || sim_w != 1) err = 1;

//TEST 7: MOV R4, #-120;    =>   in = 16'b1101010010001000
//CURRENT REG VALS:
//R0: 7
//R1: 2
//R2: 16
//R3: 16
//R4: -120
//R5: -
//R6: -
//R7: -

sim_reset = 0;
sim_in = 16'b1101010010001000;
sim_load = 1;
sim_s = 1;

#15

sim_load = 0;
sim_s = 0;
sim_load = 0;
#15


$display("TEST 7 : MOV R4, #-120;");


//TEST 8: CMP R4, R3;   =>   in = 16'b1010110000000011 (flag V) (-120-16 will overflow)
//CURRENT REG VALS:
//R0: 7
//R1: 2
//R2: 16
//R3: 16
//R4: -120
//R5: -
//R6: -
//R7: -

sim_reset = 0;
sim_in = 16'b1010110000000011;
sim_load = 1;
sim_s = 1;

#15

sim_load = 0;
sim_s = 0;
sim_load = 0;
#15


$display("Test 8: CMP R4, R3; Attempt ot run command %b; -OUTPUT: Z: %b V %b: N: %b   -Expected: Z: %b V %b: N: %b, w = %b", sim_in, sim_Z, sim_V, sim_N, 1'b0, 1'b0, 1'b1, sim_w);
	
	if(~(sim_Z == 0) || ~(sim_V ==0) || ~(sim_N == 1) || sim_w != 1) err = 1;

//TEST 9: AND R5, R2, R3;    =>   in = 16'b1011001010100011 
//CURRENT REG VALS:
//R0: 7
//R1: 2
//R2: 16
//R3: 16
//R4: -120
//R5: 16
//R6: -
//R7: -

sim_reset = 0;
sim_in = 16'b1011001011000011;
sim_load = 1;
sim_s = 1;

#15

sim_load = 0;
sim_s = 0;
sim_load = 0;
#15


$display("TEST 9: AND R5, R2, R3 - Attempt ot run command %b; -OUTPUT: %b  -Expected: %b, w = %b", sim_in, sim_out, 16'd16, sim_w);

	
	if(~(sim_out == 16'd16) || sim_w != 1) err = 1;



//TEST 10: MVN R5, R5;    =>   in = 16'b1011100010100101 
//CURRENT REG VALS:
//R0: 7
//R1: 2
//R2: 16
//R3: 16
//R4: -120
//R5: -16
//R6: -
//R7: -

sim_reset = 0;
sim_in = 16'b1011101010100110;
sim_load = 1;
sim_s = 1;

#15

sim_load = 0;
sim_s = 0;
sim_load = 0;
#15


$display("TEST 10: MVN R5, R5 - Attempt ot run command %b ; -OUTPUT: %b  -Expected: %b, w = %b", sim_in, sim_out, ~16'd16, sim_w);

	
	if(~(sim_out == ~16'd16) || sim_w != 1) err = 1;


////////TEST 11 OVERFLOW: Alternate between storing: MOV R6, R7[LS] where R7 is 127 to start then MOV R7, R6[LS]


//first MOV R7, #127, LS#1  - 01111111
sim_reset = 0;
sim_in = 16'b1101011101111111;
sim_load = 1;
sim_s = 1;

#15

sim_load = 0;
sim_s = 0;
sim_load = 0;
#15

//MOV R6, R7, LS#1   --- 011111110
sim_reset = 0;
sim_in = 16'b1100000011001111;
sim_load = 1;
sim_s = 1;

#15

sim_load = 0;
sim_s = 0;
sim_load = 0;
#15

//MOV R7, R6, LS#1  -- 0111111100
sim_reset = 0;
sim_in = 16'b1100000011101110;
sim_load = 1;
sim_s = 1;

#15

sim_load = 0;
sim_s = 0;
sim_load = 0;
#15

//MOV R6, R7, LS#1 - 01111111000
sim_reset = 0;
sim_in = 16'b1100000011001111;
sim_load = 1;
sim_s = 1;

#15

sim_load = 0;
sim_s = 0;
sim_load = 0;
#15

//MOV R7, R6, LS#1 --- 011111110000
sim_reset = 0;
sim_in = 16'b1100000011101110;
sim_load = 1;
sim_s = 1;

#15

sim_load = 0;
sim_s = 0;
sim_load = 0;
#15

//MOV R6, R7, LS#1  --- 0111111100000
sim_reset = 0;
sim_in = 16'b1100000011001111;
sim_load = 1;
sim_s = 1;

#15

sim_load = 0;
sim_s = 0;
sim_load = 0;
#15

//MOV R7, R6, LS#1 --- 01111111000000
sim_reset = 0;
sim_in = 16'b1100000011101110;
sim_load = 1;
sim_s = 1;

#15

sim_load = 0;
sim_s = 0;
sim_load = 0;
#15

//MOV R6, R7, LS#1  --- 011111110000000
sim_reset = 0;
sim_in = 16'b1100000011001111;
sim_load = 1;
sim_s = 1;

#15

sim_load = 0;
sim_s = 0;
sim_load = 0;
#15
 
//MOV R7, R6, LS#1 --- 111111110000000  (NOW OVERFLOW)
sim_reset = 0;
sim_in = 16'b1100000011101110;
sim_load = 1;
sim_s = 1;

#15

sim_load = 0;
sim_s = 0;
sim_load = 0;
#15

//MOV R6, R7, LS#1  --- 011111110000000
sim_reset = 0;
sim_in = 16'b1100000011001111;
sim_load = 1;
sim_s = 1;

#15

sim_load = 0;
sim_s = 0;
sim_load = 0;
#15

//now compare R6 and R7
sim_reset = 0;
sim_in = 16'b1010111000000111;
sim_load = 1;
sim_s = 1;

#15

sim_load = 0;
sim_s = 0;
sim_load = 0;
#15

$display("Test 11: Left Shift Until Overflow; -OUTPUT: Z: %b V %b: N: %b   -Expected: Z: %b V %b: N: %b, w = %b", sim_Z, sim_V, sim_N, 1'b0, 1'b1, 1'b0, sim_w);
	
	if(~(sim_Z == 0) || ~(sim_V ==1) || ~(sim_N == 0) || sim_w != 1) err = 1;

/////////////////////////////////////////////////////////////////////////
//Test #12:  Testing add with a sign extension shift with negative numbers
//load R6 with imm 11111100  (-3)
sim_reset = 0;
sim_in = 16'b1101011011111100;
sim_load = 1;
sim_s = 1;

#15

sim_load = 0;
sim_s = 0;
sim_load = 0;
#15

//load R4 with imm 11111000 (-7)
sim_reset = 0;
sim_in = 16'b1101010011111000;
sim_load = 1;
sim_s = 1;

#15

sim_load = 0;
sim_s = 0;
sim_load = 0;
#15

//Add to R7, R6, R4 (shifted right (sign extended)) 11111100+11111100
sim_reset = 0;
sim_in = 16'b1010011011111100;
sim_load = 1;
sim_s = 1;

#15

sim_load = 0;
sim_s = 0;
sim_load = 0;
#15

$display("TEST 12: add with a sign extension shift with negative numbers - Attempt ot run command %b; -OUTPUT: %b  -Expected: %b, w = %b", sim_in, 
sim_out, 16'b1111111111111000, sim_w);
	
	if(~(sim_out == 16'b1111111111111000) || sim_w != 1) err = 1;
#10


/////////////////////////////////////////////////////////////////////////
//Test #13:  Testing MVN with left shift
//MVN R3, R6, LSL#1
sim_reset = 0;
sim_in = 16'b1011100001101110;
sim_load = 1;
sim_s = 1;

#15

sim_load = 0;
sim_s = 0;
sim_load = 0;
#15

$display("Test 13:  Testing MVN with left shift s- Attempt ot run command %b; -OUTPUT: %b  -Expected: %b, w = %b", sim_in, 
sim_out, 16'b0000000000000111, sim_w);
	
	if(~(sim_out == 16'b0000000000000111) || sim_w != 1) err = 1;
#10

/////////////////////////////////////////////////////////////////////////
//Test #14:  Testing MVN with arithmetic right shift
//MVN R7,R6, ARS #1 
sim_reset = 0;
sim_in = 16'b1011100011111110;
sim_load = 1;
sim_s = 1;

#15

sim_load = 0;
sim_s = 0;
sim_load = 0;
#15

$display("Test 14:  Testing MVN with arithmetic right shift - Attempt ot run command %b; -OUTPUT: %b  -Expected: %b, w = %b", sim_in, 
sim_out, 16'b0000000000000001, sim_w);
	
	if(~(sim_out == 16'b0000000000000001) || sim_w != 1) err = 1;
#10
/////////////////////////////////////////////////////////////////////////
//Test #15:  Testing AND with logical right shift (1111111111101111)AND(1111111111111100)>> #1
//AND R7,R5, R6, LRS #1 
sim_reset = 0;
sim_in = 16'b1011010111110110;
sim_load = 1;
sim_s = 1;

#15

sim_load = 0;
sim_s = 0;
sim_load = 0;
#15

$display("TEST 15:  Testing MVN with big positive number with left shift s- Attempt ot run command %b; -OUTPUT: %b  -Expected: %b, w = %b", sim_in, 
sim_out, 16'b0111111111101110, sim_w);

	
	if(~(sim_out == 16'b0111111111101110) || sim_w != 1) err = 1;
#10
/////////////////////////////////////////////////////////////////////////
//Test #16:  Testing AND with ARS on positive (0000000000000111) AND (0111111111101110)>>> #1 
//AND R2,R3, R7, ARS #1 
sim_reset = 0;
sim_in = 16'b1011001101011111;
sim_load = 1;
sim_s = 1;

#20

sim_load = 0;
sim_s = 0;
sim_load = 0;
#20

$display("Test #16:  Testing AND with ARS on positive s- Attempt ot run command %b; -OUTPUT: %b  -Expected: %b, w = %b", sim_in, 
sim_out, 16'b0000000000000111, sim_w);
	
	if(~(sim_out == 16'b0000000000000111) || sim_w != 1) err = 1;
#10




$stop;
end

endmodule