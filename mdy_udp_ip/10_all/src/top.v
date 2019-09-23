module top(
    clk             ,
    rst_n           ,

    key_sw          ,

    gm_tx_clk       ,    
    gm_tx_d         , 
    gm_tx_en        , 
    gm_tx_err       ,  

    gm_rx_clk       , 
    gm_rx_d         , 
    gm_rx_dv        , 
    gm_rx_err       , 

    mdc             ,
    mdio            ,

    phy_reset       
);

input                   clk            ; 
input                   rst_n          ; 
input                   key_sw         ;
output                  gm_tx_clk      ;     
output  [7:0]           gm_tx_d        ;  
output                  gm_tx_en       ;  
output                  gm_tx_err      ;   
input                   gm_rx_clk      ;  
input   [7:0]           gm_rx_d        ;  
input                   gm_rx_dv       ;  
input                   gm_rx_err      ;  
output                  mdc            ; 
output                  mdio           ; 
output                  phy_reset      ; 

wire                    clk_100m;
wire                    clk_125m;
wire                    clk_125m_90;
wire                    locked;
wire    [15:0]          cfg_port_local;
wire    [15:0]          cfg_port_pc;
wire    [31:0]          cfg_ip_local;
wire    [31:0]          cfg_ip_pc;
wire    [47:0]          cfg_mac_local;

wire                    key_int;
wire    [15:0]          tx_data;
wire                    tx_vld;
wire                    tx_sop;
wire                    tx_eop;
wire                    tx_mty;
wire                    tx_rdy;
wire                    data_gen_rdy;

assign cfg_port_local = 16'h1388;
assign cfg_port_pc    = 16'h0bb8;
assign cfg_ip_local   = 32'hc0a8010a; //192 168 1 10
assign cfg_ip_pc      = 32'hc0a80109; //192 168 1 9
assign cfg_mac_local  = 48'h2c0203040507;

my_pll my_pll_inst0(
	.inclk0(clk),
	.c0(clk_100m),
	.c1(clk_125m),
    .c2(clk_125m_90),
	.locked(locked)
);

key key_inst0(
    .clk            (clk_100m & locked),
    .rst_n          (rst_n),
    .key_sw         (key_sw),
    .key_down_int   (key_int)
);

data_gen data_gen(
    .clk         (clk_100m & locked),
    .rst_n       (rst_n),
    .en          (key_int & (data_gen_rdy == 1'b0)),
    .busy         (data_gen_rdy),
    .dout        (tx_data),
    .dout_vld    (tx_vld),
    .dout_sop    (tx_sop),
    .dout_eop    (tx_eop),
    .dout_mty    (tx_mty),
    .rdy         (tx_rdy) 
);

//assign gm_tx_clk = clk_125m_90 & locked;
mdy_udp_ip mdy_udp_ip_inst0(
    .clk             (clk_100m & locked), 
    .rst_n           (rst_n),

    .cfg_port_local  (cfg_port_local),
    .cfg_port_pc     (cfg_port_pc),
    .cfg_ip_local    (cfg_ip_local),
    .cfg_ip_pc       (cfg_ip_pc),
    .cfg_mac_local   (cfg_mac_local),

    .tx_data         (tx_data),
    .tx_sop          (tx_sop),
    .tx_eop          (tx_eop),
    .tx_vld          (tx_vld),
    .tx_mty          (tx_mty),
    .tx_rdy          (tx_rdy),

    .rx_data         (),
    .rx_sop          (),
    .rx_eop          (),
    .rx_vld          (),
    .rx_mty          (),
   
    .tx_ip_clk       (clk_125m & locked),
    .gm_rx_clk       (gm_rx_clk),
    .gm_rx_d         (gm_rx_d),
    .gm_rx_dv        (gm_rx_dv),
    .gm_rx_err       (gm_rx_err),

    .gm_tx_clk       (gm_tx_clk),
    .gm_tx_d         (gm_tx_d),
    .gm_tx_en        (gm_tx_en),
    .gm_tx_err       (gm_tx_err),

    .phy_reset       (phy_reset),

    .mdc             (mdc),
    .mdio            (mdio)
);


endmodule
