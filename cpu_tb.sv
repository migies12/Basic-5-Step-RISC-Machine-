
module cpu_tb();

  // Inputs

 reg  sim_clk, sim_reset;
 reg  [15:0] sim_read_data;
 reg err;
 
  
    // Outputs
 wire [15:0] sim_write_data;
 wire [1:0] sim_mem_cmd;
 wire [8:0] sim_mem_addr;

CPU cpu(.clk(sim_clk), .reset(sim_reset), .read_data(sim_read_data), .mem_cmd(sim_mem_cmd), .mem_addr(sim_mem_addr), .write_data(sim_write_data));
initial begin
    sim_clk = 0; #5;
    forever begin
      sim_clk = 1; #2;
      sim_clk = 0; #2;
    end
  end
initial begin
err = 0;

    
//SETUP//

 sim_reset = 1;
#15

//TEST 1: MOV R0,#7;    =>    in = 16'b1101000000000111

sim_reset = 0;
sim_read_data = 16'b1101000000000111;

#30

$display("Test 1 - Attempt ot run command %b - MOV R0, #7; -OUTPUT: %b  -Expected: %b", sim_read_data, sim_write_data, 16'b0);
	
	if(~(sim_write_data == 16'b0)) err = 1;

//TEST 2: MOV R1,#2;    =>    in = 16'b1101000100000010


sim_read_data = 16'b1101000100000010;

#15


$display("Test 2 - Attempt ot run command %b - MOV R1,#2; -OUTPUT: %b  -Expected: %b", sim_read_data, sim_write_data, 16'b0);
	
	if(~(sim_write_data == 16'b0)) err = 1;

//TEST 3: ADD R2, R1, R0, LSL#1;    =>    in = 16'b1010000101001000

sim_read_data= 16'b1010000101001000;

#15


$display("Test 3 - Attempt ot run command %b - TEST 3: ADD R2, R1, R0, LSL#1; -OUTPUT: %b  -Expected: %b", sim_read_data, sim_write_data, 16'b0);
	
	if(~(sim_write_data == 16'b0)) err = 1;


$stop;
end

endmodule