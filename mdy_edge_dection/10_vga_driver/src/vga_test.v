module vga_test(
        clk,
        rst_n,
        vga_clk     ,
        vga_hys     ,
        vga_vys     ,
        vga_rgb     ,
        vga_blank_n
        );

input           clk;
input           rst_n;
output          vga_clk;
output          vga_hys;
output          vga_vys;
output  [15:0]  vga_rgb;
output          vga_blank_n;

wire    vga_ctl_clk;

mypll mypll_inst0(
    .areset(~rst_n),
	.inclk0(clk),
	.c0(vga_ctl_clk),
    .locked()
);

vga_driver vga_driver_inst0(
    .clk         (vga_ctl_clk),
    .rst_n       (rst_n),
   
    .vga_clk     (vga_clk), 
    .vga_hys     (vga_hys),
    .vga_vys     (vga_vys),
    .vga_rgb     (vga_rgb),
    .vga_blank_n (vga_blank_n),

    .wr_end      (),
    .din         (),
    .rd_addr     (),
    .rd_en       (),
    .rd_end      (),
    .rd_addr_sel () 
);

endmodule
