module mdy_udp_ip (
    clk             , 
    rst_n           ,

    cfg_port_local  ,
    cfg_port_pc     ,
    cfg_ip_local    ,
    cfg_ip_pc       ,
    cfg_mac_local   ,

    // 发送数据
    tx_data         ,
    tx_sop          ,
    tx_eop          ,
    tx_vld          ,
    tx_mty          ,
    tx_rdy          ,

    // 接收数据
    rx_data         ,
    rx_sop          ,
    rx_eop          ,
    rx_vld          ,
    rx_mty          ,
   
    // 千兆网卡IP核接口 
    tx_ip_clk       ,
    gm_rx_clk       ,
    gm_rx_d         ,
    gm_rx_dv        ,
    gm_rx_err       ,

    gm_tx_d         ,
    gm_tx_en        ,
    gm_tx_err       ,
    gm_tx_clk       ,
    phy_reset       ,

    mdc             ,
    mdio            
);

input              clk           ;
input              rst_n         ;

input  [15:0]      cfg_port_local;
input  [15:0]      cfg_port_pc   ;
input  [31:0]      cfg_ip_local  ;
input  [31:0]      cfg_ip_pc     ;
input  [47:0]      cfg_mac_local ;

input  [15:0]      tx_data       ;
input              tx_sop        ;
input              tx_eop        ;
input              tx_vld        ;
input              tx_mty        ;
input              tx_ip_clk     ; 
input              gm_rx_clk     ; 
input  [7:0]       gm_rx_d       ; 
input              gm_rx_dv      ; 
input              gm_rx_err     ; 

output wire            tx_rdy        ;
output wire[15:0]      rx_data       ;
output wire            rx_sop        ;
output wire            rx_eop        ;
output wire            rx_vld        ;
output wire            rx_mty        ;
output wire            phy_reset     ;
output wire[7:0]       gm_tx_d       ; 
output wire            gm_tx_en      ; 
output wire            gm_tx_err     ; 
output wire            gm_tx_clk     ;
output wire            mdc           ;
inout wire             mdio          ; 


wire                    mac_cfg_if_wr;
wire                    mac_cfg_if_rd;
wire                    mac_cfg_if_rdy;
wire    [7:0]           mac_cfg_if_addr;
wire    [31:0]          mac_cfg_if_wdata;
wire                    cfg_done;


wire     [ 7:0]    mac_addr  ; 
wire               mac_rd    ; 
wire     [31:0]    mac_wdata ; 
wire               mac_wr    ; 
wire     [31:0]    mac_rdata ; 
wire               mac_wait  ;

// 配置IP核
mac_ip_config mac_ip_config_inst0(
    .clk        (clk),
    .rst_n      (rst_n),
    .cfg_mac_local(cfg_mac_local),
    .wr_en	   (mac_cfg_if_wr),
	.rd_en      (mac_cfg_if_rd),
    .rdy        (mac_cfg_if_rdy),
    .addr       (mac_cfg_if_addr),
    .wdata      (mac_cfg_if_wdata),
    .phy_reset(phy_reset),
    .rdata      (rdata),
    .rdata_vld  (rdata_vld),
    .cfg_done   (cfg_done)   
);

mac_cfg_if mac_cfg_if_inst0(
    .clk       (clk),
    .rst_n     (rst_n),
    .wr        (mac_cfg_if_wr),
    .rd        (mac_cfg_if_rd),
    .rdy       (mac_cfg_if_rdy),
    .addr      (mac_cfg_if_addr),
    .wdata     (mac_cfg_if_wdata),
    .rdata     (rdata),
    .rdata_vld (rdata_vld),    

    .mac_addr  (mac_adrr),
    .mac_rd    (mac_rd),
    .mac_wdata (mac_wdata),
    .mac_wr    (mac_wr),
    .mac_rdata (mac_rdata),
    .mac_wait  (mac_wait)   
);

// 发送数据通路
tx_pack tx_pack_inst0(
    .clk          (clk),
    .rst_n        (rst_n),
    .cfg_sport    (cfg_port_local),
    .cfg_dport    (cfg_port_ip),
    .cfg_sip      (cfg_ip_local),
    .cfg_dip      (cfg_ip_pc),
    .cfg_mac_d    (get_mac_pc),
    .cfg_mac_s    (cfg_mac_local),
    .tx_data      (tx_data),
    .tx_sop       (tx_sop),
    .tx_eop       (tx_eop),
    .tx_vld       (tx_vld),
    .tx_rdy       (tx_rdy),
    .tx_mty       (tx_mty),
    .dout         (tx_pack_dout),
    .dout_sop     (tx_pack_dout_sop),
    .dout_eop     (tx_pack_dout_eop),
    .dout_vld     (tx_pack_dout_vld),
    .dout_rdy     (tx_pack_dout_rdy),
    .dout_mty     (tx_pack_dout_mty)  
);

tx_arp tx_arp_inst0(
    .clk           (clk),
    .rst_n         (rst_n),

    .ack_en        (ack_en),
    .ack_mac_d     (get_mac_pc),

    .cfg_mac_s     (cfg_mac_local),
    .cfg_sip       (cfg_ip_local),
    .cfg_dip       (cfg_ip_pc),

    .tx_arp_data   (tx_arp_data),
    .tx_arp_vld    (tx_arp_vld),
    .tx_arp_sop    (tx_arp_sop),
    .tx_arp_eop    (tx_arp_eop),
    .tx_arp_rdy    (tx_arp_rdy),
    .tx_arp_mty    (tx_arp_mty)
);

tx_sp tx_sp_inst0(
    .clk              (clk),
    .rst_n            (rst_n),
    .arp              (tx_arp_data),
    .arp_vld          (tx_arp_vld),
    .arp_sop          (tx_arp_sop),
    .arp_eop          (tx_arp_eop),
    .arp_rdy          (tx_arp_rdy),
    .arp_mod          (tx_arp_mty),  
    .din              (tx_pack_dout),
    .din_sop          (tx_pack_dout_sop),
    .din_eop          (tx_pack_dout_eop), 
    .din_vld          (tx_pack_dout_vld),
    .din_rdy          (tx_pack_dout_rdy),
    .din_mod          (tx_pack_dout_mty),  
    .tx_data          (mac_tx_data),
    .tx_sop           (mac_tx_sop),
    .tx_eop           (mac_tx_eop), 
    .tx_vld           (mac_tx_vld),
    .tx_rdy           (mac_tx_rdy),
    .tx_mod           (mac_tx_mod)   
);

// 接收数据通路
 rx_filter rx_filter_inst0(
    .clk              (clk),
    .rst_n            (rst_n),
    .din              (udp_data),
    .din_sop          (udp_sop),
    .din_eop          (udp_eop), 
    .din_vld          (udp_vld),
    .din_mod          (udp_mty),  
    .din_err          (udp_err),  
    .dout             (rx_data),
    .dout_sop         (rx_sop),
    .dout_eop         (rx_eop), 
    .dout_vld         (rx_vld),
    .dout_mod         (rx_mty)     
);

rx_ip_analy rx_ip_analy_inst0(
             .clk            (clk),
             .rst_n          (rst_n),
             .cfg_ip_local   (cfg_ip_local),
             .cfg_ip_pc      (cfg_ip_pc),
             .din            (ip_data),
             .din_vld        (ip_vld),
             .din_sop        (ip_sop),
             .din_eop        (ip_eop),
             .din_mty        (ip_mod), 
             .dout           (udp_data),
             .dout_vld       (udp_vld),
             .dout_sop       (udp_sop),
             .dout_eop       (udp_eop),
             .dout_err       (udp_err),
             .dout_mty       (udp_mty),        
             .flag_type_err (),
             .flag_len_err  (),
             .flag_sum_err  (),
             .flag_ip_local_err  (),
             .flag_ip_pc_err ()
);

rx_arp_analy rx_arp_analy_inst0(
             .clk            (clk),
             .rst_n          (rst_n),
             .cfg_mac_local  (cfg_mac_local),
             .cfg_ip_local   (cfg_ip_local),
             .cfg_ip_pc      (cfg_ip_pc),
             .get_mac_pc     (get_mac_pc),
             .arp_mod        (arp_mod), 
             .arp_data       (arp_data),
             .arp_vld        (arp_vld),
             .arp_sop        (arp_sop),
             .arp_eop        (arp_eop),
             .ack_en         (ack_en),
             .get_en         (get_en),  
             .flag_type_err  (), 
             .flag_len_err   (), 
             .flag_pc_ip_err (), 
             .flag_local_ip_err()
);

rx_mac_analy rx_mac_analy_inst0(
             .clk            (clk),
             .rst_n          (rst_n),
             .cfg_mac_local  (cfg_mac_local),
             .rx_data        (mac_rx_data),
             .rx_vld         (mac_rx_vld),
             .rx_sop         (mac_rx_sop),
             .rx_eop         (mac_rx_eop),
             .rx_mod         (mac_rx_mod),
             .ip_data        (ip_data),
             .ip_vld         (ip_vld),
             .ip_sop         (ip_sop),
             .ip_eop         (ip_eop),
             .ip_mod         (ip_mod),
             .get_mac_pc     (),
             .arp_mod        (arp_mod), 
             .arp_data       (arp_data),
             .arp_vld        (arp_vld),
             .arp_sop        (arp_sop),
             .arp_eop        (arp_eop),
             .flag_mac_err   (),
             .flag_type      ()  
);

// MAC ip核
mac_ip mdy_mac_inst0(
		.clk(tx_ip_clk),           // control_port_clock_connection.clk
		.reset(rst_n),         //              reset_connection.reset
		.address(mac_addr),       //                  control_port.address
		.readdata(mac_rdata),      //                              .readdata
		.read(mac_rd),          //                              .read
		.writedata(mac_wdata),     //                              .writedata
		.write(mac_wr),         //                              .write
		.waitrequest(mac_wait),   //                              .waitrequest
		.tx_clk(gm_tx_clk),        //   pcs_mac_tx_clock_connection.clk
		.rx_clk(gm_rx_clk),        //   pcs_mac_rx_clock_connection.clk
		.set_10(),        //         mac_status_connection.set_10
		.set_1000(),      //                              .set_1000
		.eth_mode(),      //                              .eth_mode
		.ena_10(),        //                              .ena_10

		.gm_rx_d(gm_rx_d),       //           mac_gmii_connection.gmii_rx_d
		.gm_rx_dv(gm_rx_dv),      //                              .gmii_rx_dv
		.gm_rx_err(gm_rx_err),     //                              .gmii_rx_err
		.gm_tx_d(gm_tx_d),       //                              .gmii_tx_d
		.gm_tx_en(gm_tx_en),      //                              .gmii_tx_en
		.gm_tx_err(gm_tx_err),     //                              .gmii_tx_err

		.m_rx_d(),        //            mac_mii_connection.mii_rx_d
		.m_rx_en(),       //                              .mii_rx_dv
		.m_rx_err(),      //                              .mii_rx_err
		.m_tx_d(),        //                              .mii_tx_d
		.m_tx_en(),       //                              .mii_tx_en
		.m_tx_err(),      //                              .mii_tx_err

		.ff_rx_clk(clk),     //     transmit_clock_connection.clk
		.ff_tx_clk(clk),     //      receive_clock_connection.clk
		.ff_rx_data(mac_rx_data),    //                       receive.data
		.ff_rx_eop(mac_rx_eop),     //                              .endofpacket
		.rx_err(),        //                              .error
		.ff_rx_mod(mac_rx_mod),     //                              .empty
		.ff_rx_rdy(),     //                              .ready
		.ff_rx_sop(mac_rx_sop),     //                              .startofpacket
		.ff_rx_dval(mac_rx_vld),    //                              .valid
		.ff_tx_data(mac_tx_data),    //                      transmit.data
		.ff_tx_eop(mac_tx_eop),     //                              .endofpacket
		.ff_tx_err(),     //                              .error
		.ff_tx_mod(mac_tx_mod),     //                              .empty
		.ff_tx_rdy(mac_tx_rdy),     //                              .ready
		.ff_tx_sop(mac_tx_sop),     //                              .startofpacket
		.ff_tx_wren(mac_tx_vld),    //                              .valid

		.mdc(mdc),           //           mac_mdio_connection.mdc
		.mdio_in(mdio_in),       //                              .mdio_in
		.mdio_out(mdio_out),      //                              .mdio_out
		.mdio_oen(mdio_oen),      //                              .mdio_oen

		.xon_gen(),       //           mac_misc_connection.xon_gen
		.xoff_gen(),      //                              .xoff_gen
		.magic_wakeup(),  //                              .magic_wakeup
		.magic_sleep_n(), //                              .magic_sleep_n

		.ff_tx_crc_fwd(), //                              .ff_tx_crc_fwd
		.ff_tx_septy(),   //                              .ff_tx_septy
		.tx_ff_uflow(),   //                              .tx_ff_uflow
		.ff_tx_a_full(),  //                              .ff_tx_a_full
		.ff_tx_a_empty(), //                              .ff_tx_a_empty
		.rx_err_stat(),   //                              .rx_err_stat
		.rx_frm_type(),   //                              .rx_frm_type
		.ff_rx_dsav(),    //                              .ff_rx_dsav
		.ff_rx_a_full(),  //                              .ff_rx_a_full
		.ff_rx_a_empty()  //                              .ff_rx_a_empty
);

assign mdio = mdio_oen ? mdio_out : 1'bz;
assign mdio_in = mdio;

endmodule
