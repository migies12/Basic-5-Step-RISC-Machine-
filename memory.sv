module RAM (clk, read_adress, write_adress, write, din, dout);

    parameter data_width = 16;
    parameter addr_width = 8;
    parameter filename = "data.txt";

    input clk;
    input [addr_width-1:0] read_adress, write_adress;
    input write;
    input [data_width-1:0] din;

    output reg [data_width-1:0] dout;

    reg [data_width-1:0] mem [2**addr_width-1:0];

    initial $readmemb(filename, mem);

    always_ff @ (posedge clk) begin
        if (write)
            mem[write_adress] <= din;
        dout <= mem[read_adress];
    end

endmodule