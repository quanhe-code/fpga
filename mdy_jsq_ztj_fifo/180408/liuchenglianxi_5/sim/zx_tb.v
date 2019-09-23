`timescale 1ns/1ns

module zx_tb();

localparam clk_period = 40;

reg clk;
reg rst_n;

wire cs;
wire wr;
wire [7:0] dout;

zx inst_zx_1(
        .clk(clk),
        .rst_n(rst_n),
        .cs(cs),
        .wr(wr),
        .dout(dout)
);

initial begin
    clk = 1'b1;
	forever #(clk_period/2) clk = ~clk;
end

initial begin
    rst_n = 0;

    #(clk_period * 5) rst_n = 1;
end

endmodule
