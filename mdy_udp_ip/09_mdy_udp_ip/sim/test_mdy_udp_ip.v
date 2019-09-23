`timescale 1 ns/1 ns

module test_mdy_udp_ip();


reg             clk           ;
reg             rst_n         ;
reg [15:0]      cfg_port_local;
reg [15:0]      cfg_port_pc   ;
reg [31:0]      cfg_ip_local  ;
reg [31:0]      cfg_ip_pc     ;
reg [47:0]      cfg_mac_local ;
reg [15:0]      tx_data       ;
reg             tx_sop        ;
reg             tx_eop        ;
reg             tx_vld        ;
reg             tx_mty        ;
reg             tx_ip_clk     ; 
reg             gm_rx_clk     ; 
reg [7:0]       gm_rx_d       ; 
reg             gm_rx_dv      ; 
reg             gm_rx_err     ; 
wire            tx_rdy        ;
wire[15:0]      rx_data       ;
wire            rx_sop        ;
wire            rx_eop        ;
wire            rx_vld        ;
wire            rx_mty        ;
wire            phy_reset     ;
wire[7:0]       gm_tx_d       ; 
wire            gm_tx_en      ; 
wire            gm_tx_err     ; 
wire            gm_tx_clk     ;
wire            mdc           ;
wire            mdio          ;  


//时钟周期，单位为ns，可在此修改时钟周期。
parameter CYCLE    = 8;

//复位时间，此时表示复位3个时钟周期的时间。
parameter RST_TIME = 3 ;

//待测试的模块例化
mdy_udp_ip          uut(
    .clk             (clk               ), 
    .rst_n           (rst_n             ),
    .cfg_port_local  (cfg_port_local    ),
    .cfg_port_pc     (cfg_port_pc       ),
    .cfg_ip_local    (cfg_ip_local      ),
    .cfg_ip_pc       (cfg_ip_pc         ),
    .cfg_mac_local   (cfg_mac_local     ),
    .tx_data         (tx_data           ),
    .tx_sop          (tx_sop            ),
    .tx_eop          (tx_eop            ),
    .tx_vld          (tx_vld            ),
    .tx_mty          (tx_mty            ),
    .tx_ip_clk       (tx_ip_clk         ),
    .gm_rx_clk       (gm_rx_clk         ),
    .gm_rx_d         (gm_rx_d           ),
    .gm_rx_dv        (gm_rx_dv          ),
    .gm_rx_err       (gm_rx_err         ),
    .tx_rdy          (tx_rdy            ),
    .rx_data         (rx_data           ),
    .rx_sop          (rx_sop            ),
    .rx_eop          (rx_eop            ),
    .rx_vld          (rx_vld            ),
    .rx_mty          (rx_mty            ),
    .phy_reset       (phy_reset         ),
    .gm_tx_d         (gm_tx_d           ),
    .gm_tx_en        (gm_tx_en          ),
    .gm_tx_err       (gm_tx_err         ),
    .gm_tx_clk       (gm_tx_clk         ),
    .mdc             (mdc               ),
    .mdio            (mdio              )
);

initial begin
    clk = 0;
    forever
    #(CYCLE/2)
    clk=~clk;
end

initial begin
    tx_ip_clk = 0;
    forever
    #(CYCLE/2)
    tx_ip_clk=~tx_ip_clk;
end

initial begin
    gm_rx_clk = 0;
    forever
    #(CYCLE/2)
    gm_rx_clk=~gm_rx_clk;
end

integer i;

initial begin
    rst_n = 1;
    #2;
    rst_n = 0;
    #(CYCLE*RST_TIME);
    rst_n = 1;
end

initial begin
    #1;
    //赋初值
    cfg_port_local = 16'h1388;
    cfg_port_pc    = 16'h0bb8;
    cfg_ip_local   = 32'hc0a8010a; //192 168 1 10
    cfg_ip_pc      = 32'hc0a80109; //192 168 1 9
    cfg_mac_local  = 48'h2c0203040507;
    tx_data        = 0 ;
    tx_sop         = 0 ;
    tx_eop         = 0 ;
    tx_vld         = 0 ;
    tx_mty         = 0 ;
    gm_rx_d        = 0 ;
    gm_rx_dv       = 0 ;
    gm_rx_err      = 0 ;
    #(10*CYCLE);

   for(i=0;i<255;i=i+1)begin
     tx_data = i+1 ;
     tx_sop  = (i==0  ) ? 1 :0 ;
     tx_eop  = (i==248) ? 1 :0 ;
     tx_vld         = 1 ;
     tx_mty         = 0 ;
     #(CYCLE);
   end

    tx_data        = 0 ;
    tx_sop         = 0 ;
    tx_eop         = 0 ;
    tx_vld         = 0 ;
    tx_mty         = 0 ;
    
end

always  @(*)begin
 #1   gm_rx_d        = gm_tx_d ;
end

always  @(*)begin
#1    gm_rx_dv       = gm_tx_en ;
end

always  @(*)begin
#1    gm_rx_err      = gm_tx_err ;
end



endmodule

