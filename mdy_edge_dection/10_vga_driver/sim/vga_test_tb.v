`timescale 1ns/1ps

module vga_test_tb();

localparam      clk_period = 40;

reg           clk;
reg           rst_n;
wire          vga_clk;
wire          vga_hys;
wire          vga_vys;
wire  [15:0]  vga_rgb;
wire          vga_nblank;

vga_test vga_test_inst0(
        .clk(clk),
        .rst_n(rst_n),
        .vga_clk     (vga_clk),
        .vga_hys     (vga_hys),
        .vga_vys     (vga_vys),
        .vga_rgb     (vga_rgb),
        .vga_nblank(vga_nblank)
        );

initial begin
    clk = 1'b1;
    forever #(clk_period / 2) clk = ~clk;
end

initial begin
    rst_n = 0;

    #(10);
    #(clk_period * 5);

    rst_n = 1'b1;
end
endmodule
