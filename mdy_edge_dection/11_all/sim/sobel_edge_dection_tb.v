`timescale 1ns/1ns

module sobel_edge_dection_tb();

localparam      clk_period = 40;

reg                 clk     ;
reg                 rst_n   ;

// 按键模块
reg                 key_in  ;

// cmos摄像头模块
wire                xclk    ;
reg                 vsync   ;
reg                 href    ;
reg  [7:0]          din     ;
wire                sio_c     ;
wire                sio_d     ;

// VGA模块
wire                vga_hys ;
wire                vga_vys ;
wire [15:0]         vga_rgb ;

sobel_edge_dection sobel_edge_dection_inst0(
    .clk         (clk),
    .rst_n       (rst_n),

    .key_in      (key_in),

    .vsync       (vsync),
    .href        (href),
    .din         (din),

    .xclk        (xclk),
    .sio_c       (sio_c),
    .sio_d       (sio_d), 

    .vga_hys     (),
    .vga_vys     (),
    .vga_rgb     () 
);
defparam sobel_edge_dection_inst0.key_inst0.PARA_MAX_CNT = 100;

initial begin
    clk = 1'b1;
    forever #(clk_period / 2) clk=~clk;
end

initial begin
    rst_n = 0;
    key_in = 1'b1;

    #(10);
    #(clk_period * 5);

    rst_n = 1'b1;

    #(clk_period * 5);
    key_in = 1'b0;

    #(clk_period * 10000);
    $stop;
end

endmodule
