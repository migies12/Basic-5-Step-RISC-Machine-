
module cpu_tb();

  // Inputs

 reg  sim_clk, sim_reset;
 reg  [15:0] sim_read_data;
 reg err;
 
  
    // Outputs
 wire [15:0] sim_write_data;
 wire [1:0] sim_mem_cmd;
 wire [8:0] sim_mem_addr;
    
cpu cpu(.clk(sim_clk), .reset(sim_reset), .read_data(sim_read_data), .mem_cmd(sim_mem_cmd), .mem_addr(sim_mem_addr), .write_data(sim_write_data));
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
 
#15;
sim_reset = 0;
end
endmodule