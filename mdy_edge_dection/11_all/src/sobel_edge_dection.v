module sobel_edge_dection(
    clk         ,
    rst_n       ,

    key_in     ,

    xclk        ,
    pclk        ,
    vsync       ,
    href        ,
    din         ,
    sio_c       ,
    sio_d       , 

    vga_clk     ,
    vga_hys     ,
    vga_vys     ,
    vga_rgb     , 
    vga_blank_n
);


    input         clk     ;
    input         rst_n   ;
	
    // ∞¥º¸ƒ£øÈ
	input         key_in  ;
	
    // cmos…„œÒÕ∑ƒ£øÈ
    output        xclk    ;
    input         pclk    ;
    input         vsync   ;
    input         href    ;
    input  [7:0]  din     ;
    output        sio_c     ;
    inout         sio_d     ;

    // VGAƒ£øÈ
    output          vga_clk;
    output          vga_hys ;
    output          vga_vys ;
    output [15:0]   vga_rgb ;
    output          vga_blank_n;
 
    wire          en_sio_d_w;
    wire          sio_d_w   ;
    wire          sio_d_r   ;
    assign sio_d = en_sio_d_w ? sio_d_w : 1'dz;
    assign sio_d_r = sio_d;

    //‰∏≠Èó¥‰ø°Âè∑ÂÆö‰πâ
    wire           clk_25m       ;
    wire           locked        ;
    wire   [3:0]   key_num       ;
    wire           en_coms       ;
    wire   [7:0]   value_gray    ;
    wire           rdy           ;
    wire           wen           ;
    wire           ren           ;
    wire   [7:0]   addr      ;
    wire   [7:0]   wdata         ;
    wire           capture_en    ;
    wire   [7:0]   rdata         ;
    wire           rdata_vld     ;
    wire   [15:0]  cmos_dout     ;
    wire           cmos_dout_vld ;
    wire           cmos_dout_sop ;
    wire           cmos_dout_eop ;
    wire   [7:0]   gray_dout     ;
    wire           gray_dout_vld ;
    wire           gray_dout_sop ;
    wire           gray_dout_eop ;
    wire   [7:0]   gs_dout       ;
    wire           gs_dout_vld   ;
    wire           gs_dout_sop   ;
    wire           gs_dout_eop   ;
    wire           bit_dout      ;
    wire           bit_dout_vld  ;
    wire           bit_dout_sop  ;
    wire           bit_dout_eop  ;
    wire           sobel_dout    ;
    wire           sobel_dout_vld;
    wire           sobel_dout_sop;
    wire           sobel_dout_eop;
    wire   [15:0]  rd_addr       ;
    wire           rd_en         ;
    wire           vga_data      ;
    wire           rd_end        ;
    wire           wr_end        ;
    wire           rd_addr_sel   ;
    wire[3:0]      key_vld       ;

    wire  [15:0]      cfg_port_local;
    wire  [15:0]      cfg_port_pc   ;
    wire  [31:0]      cfg_ip_local  ;
    wire  [31:0]      cfg_ip_pc     ;
    wire  [47:0]      cfg_mac_local ;

    wire  [15:0]        imag_dout    ;
    wire                imag_dout_sop;
    wire                imag_dout_eop;
    wire                imag_dout_vld;
    wire                imag_dout_mty;
    wire                imag_dout_rdy;
	 wire [7:0]               sub_addr;//gai
	 wire [7:0]               add_5;


    wire  [15:0]        rx_data;
    wire                rx_sop;
    wire                rx_eop;
    wire                rx_vld;
    wire                rx_mty;
    wire                rx_rdy;
    wire                config_en;
    wire                sys_clk;

assign xclk = clk;
pll_ipcore pll_ipcore_inst0(
	.inclk0(pclk),
	.c0(sys_clk),
	.c1(),
	.c2(),
    .locked(locked)
);

key key_inst0(
    .clk(clk),
    .rst_n(rst_n),
    .key_sw(key_in),
    .key_down_int(config_en)
);

ov7670_config ov7670_config_inst0(
    .clk        (clk),
    .rst_n      (rst_n),
    .config_en  (config_en),

    .rdy        (rdy),
    .rdata      (rdata),
    .rdata_vld  (rdata_vld),
    .wdata      (wdata),
    .addr       (addr),
    .wr_en	    (wen),
	.rd_en      (ren),

    .cmos_en    (capture_en) 
);

sccb sccb_inst0(
    .clk       (clk),
    .rst_n     (rst_n),

    .ren       (ren),
    .wen       (wen),
    .sub_addr  (addr),
    .rdata     (rdata),
    .rdata_vld (rdata_vld),
    .wdata     (wdata),
    .rdy       (rdy),

    .sio_c     (sio_c),
    .sio_d_r   (sio_d_r),
    .en_sio_d_w(en_sio_d_w),
    .sio_d_w   (sio_d_w)      
);

cmos_capture cmos_capture_inst0(
    .clk         (sys_clk),
    .rst_n       (rst_n),
    .en_capture  (capture_en),

    .vsync       (vsync),
    .href        (href),

    .din         (din),
    .dout        (cmos_dout),
    .dout_vld    (cmos_dout_vld),
    .dout_sop    (cmos_dout_sop),
    .dout_eop    (cmos_dout_eop) 
);

rgb565_gray rgb565_gray_inst0(
    .clk         (sys_clk),
    .rst_n       (rst_n),
    .din         (cmos_dout),
    .din_vld     (cmos_dout_vld),
    .din_sop     (cmos_dout_sop),
    .din_eop     (cmos_dout_eop),
    .dout        (gray_dout),
    .dout_vld    (gray_dout_vld),
    .dout_sop    (gray_dout_sop),
    .dout_eop    (gray_dout_eop) 
);

gs_filter gs_filter_inst0(
    .clk         (sys_clk),
    .rst_n       (rst_n),
    .din         (gray_dout),
    .din_vld     (gray_dout_vld),
    .din_sop     (gray_dout_sop),
    .din_eop     (gray_dout_eop),
    .dout        (gs_dout),
    .dout_vld    (gs_dout_vld),
    .dout_sop    (gs_dout_sop),
    .dout_eop    (gs_dout_eop) 
);

assign value_gray = 8'd150;
gray_bit gray_bit_inst0(
    .clk         (sys_clk),
    .rst_n       (rst_n),
    .value       (value_gray),
    .din         (gs_dout),
    .din_vld     (gs_dout_vld),
    .din_sop     (gs_dout_sop),
    .din_eop     (gs_dout_eop),
    .dout        (bit_dout),
    .dout_vld    (bit_dout_vld),
    .dout_sop    (bit_dout_sop),
    .dout_eop    (bit_dout_eop)    
);

sobel sobel_inst0(
    .clk         (sys_clk),
    .rst_n       (rst_n),
    .din         (bit_dout),
    .din_vld     (bit_dout_vld),
    .din_sop     (bit_dout_sop),
    .din_eop     (bit_dout_eop),
    .dout        (sobel_dout),
    .dout_vld    (sobel_dout_vld),
    .dout_sop    (sobel_dout_sop),
    .dout_eop    (sobel_dout_eop)     
);

vga_config vga_config_inst0(
    .clk         (sys_clk),
    .rst_n       (rst_n),
    .din         (sobel_dout),
    .din_vld     (sobel_dout_vld),
    .din_sop     (sobel_dout_sop),
    .din_eop     (sobel_dout_eop),
    .rd_addr     (rd_addr),
    .rd_en       (rd_en),
    .rd_end      (rd_end),
    .rd_addr_sel (rd_addr_sel),
    .dout        (vga_data),
    .wr_end      (wr_end)     
);

vga_driver vga_driver_inst0(
    .clk         (sys_clk),
    .rst_n       (rst_n),
   
    .vga_clk     (vga_clk), 
    .vga_hys     (vga_hys),
    .vga_vys     (vga_vys),
    .vga_rgb     (vga_rgb),
    .vga_blank_n (vga_blank_n),
    
    .din         (vga_data),
    .rd_addr     (rd_addr),
    .rd_en       (rd_en),

    .wr_end      (wr_end),
    .rd_end      (rd_end),
    .rd_addr_sel (rd_addr_sel) 
);

endmodule

