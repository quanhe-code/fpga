module  rx_mac_analy(
             clk            ,
             rst_n          ,
             cfg_mac_local  ,
             rx_data        ,
             rx_vld         ,
             rx_sop         ,
             rx_eop         ,
             rx_mod         ,
             ip_data        ,
             ip_vld         ,
             ip_sop         ,
             ip_eop         ,
             ip_mod         ,
             get_mac_pc     ,
             arp_mod        , 
             arp_data       ,
             arp_vld        ,
             arp_sop        ,
             arp_eop        ,
             flag_mac_err ,
             flag_type        
);

parameter      MAC_ADDR_W        =  48;
parameter      IP_ADDR_W         =  32;
parameter      DATA_W            =  32;


//输入信号定义
input                       clk    ;
input                       rst_n  ;              
input   [DATA_W-1:0]        rx_data;
input                       rx_vld ;
input                       rx_sop ;
input                       rx_eop ;
input   [1:0]               rx_mod ;
/*ip报文解析模块数据接口*/
output  [DATA_W-1:0]        ip_data;
output                      ip_vld ;
output                      ip_sop ;
output                      ip_eop ;
output  [1:0]               ip_mod ;
output  [MAC_ADDR_W-1:0]    get_mac_pc;
/*ip报文与arp报文解析模块共用接口*/
/*arp报文解析模块*/
output  [DATA_W-1:0]        arp_data;
output                      arp_vld;
output                      arp_sop;
output                      arp_eop;
output  [1:0]               arp_mod;

input   [MAC_ADDR_W-1:0]    cfg_mac_local;

output                      flag_mac_err;
output  [1:0]               flag_type; 

/*ip报文解析模块数据接口*/
reg                           ip_vld ;
reg                           ip_sop ;
reg                           ip_eop ;
reg       [DATA_W-1:0]        ip_data;
reg       [1:0]               ip_mod ;
/*ip报文与arp报文解析模块共用接口*/
reg                           arp_vld;
reg                           arp_sop;
reg                           arp_eop;
reg       [DATA_W-1:0]        arp_data;
reg       [1:0]               arp_mod;

reg     [MAC_ADDR_W-1:0]      get_mac_pc;
reg                     data_flag;

reg     [1:0]           cnt_head;
wire                    add_cnt_head;
wire                    end_cnt_head;

reg     [127:0]         mac_head;
wire    [127:0]         mac_head_tmp;
reg                     flag_mac_err;
wire                    flag_mac_err_tmp;
reg     [1:0]           flag_type;
reg     [1:0]           flag_type_tmp;

wire    [35:0]          mac_data;
wire                    mac_rdreq;
wire                    mac_wrreq;
wire                    mac_empty;
wire    [35:0]          mac_q;

wire    [47:0]          rx_mac_add_dst;
wire    [15:0]          rx_pack_type;

rx_mac_analy_fifo rx_mac_analy_fifo_inst0(
	.clock(clk),
	.data(mac_data),
	.rdreq(mac_rdreq),
	.wrreq(mac_wrreq),
	.empty(mac_empty),
	.q(mac_q)
);

assign mac_data = {rx_mod, rx_eop, rx_sop, rx_data};
assign mac_wrreq = rx_vld;
assign mac_rdreq = (mac_empty == 1'b0);

always @(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        cnt_head <= 0;
    end
    else if(add_cnt_head)begin
        if(end_cnt_head)
            cnt_head <= 0;
        else
            cnt_head <= cnt_head + 1'b1;
    end
end

assign add_cnt_head = (data_flag == 1'b0 && mac_rdreq);       
assign end_cnt_head = add_cnt_head && cnt_head== (4 - 1);   

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        data_flag <= 1'b0;
    end
    else if(end_cnt_head)begin
        data_flag <= 1'b1;
    end
    else if(mac_rdreq && mac_q[33])begin
        data_flag <= 1'b0;
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        mac_head <= 128'd0;
    end
    else if(add_cnt_head)begin
        mac_head <= {mac_head[95:0], mac_q[31:0]};
    end
end

assign rx_mac_add_dst = mac_head_tmp[111:64];
assign rx_pack_type = mac_head_tmp[15:0];

assign mac_head_tmp = {mac_head[95:0], mac_q[31:0]};
assign flag_mac_err_tmp = (rx_mac_add_dst != cfg_mac_local);
always  @(*)begin
    if(rx_pack_type == 16'h0800) begin
        flag_type_tmp = 2'd0;
    end
    else if(rx_pack_type == 16'h0806)begin
        flag_type_tmp = 2'd1;
    end
    else begin
        flag_type_tmp = 2'd2;
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        flag_mac_err <= 1'b0;
    end
    else if(end_cnt_head)begin
        flag_mac_err <= flag_mac_err_tmp;
    end
    else if(mac_rdreq && mac_q[33])begin
        flag_mac_err <= 1'b0;
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        flag_type <= 2'd0;
    end
    else if(end_cnt_head)begin
        flag_type <= flag_type_tmp;
    end
    else if(mac_rdreq && mac_q[33])begin
        flag_type <= 2'd0;
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        get_mac_pc <= 48'd0;
    end
    else if(end_cnt_head)begin
        get_mac_pc <= mac_head_tmp[63:16];
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        ip_data <= 32'd0;
    end
    else if(data_flag && flag_mac_err == 1'b0 && flag_type == 2'd0 && mac_rdreq)begin
        ip_data <= mac_q[31:0];
    end
    else begin
        ip_data <= 32'd0;
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        ip_vld <= 1'b0; 
    end
    else if(data_flag && flag_mac_err == 1'b0 && flag_type == 2'd0 && mac_rdreq)begin
        ip_vld <= 1'b1;
    end
    else begin
        ip_vld <= 1'b0;
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        ip_sop <= 1'b0;
    end
    else if(end_cnt_head && flag_mac_err_tmp == 1'b0 && flag_type_tmp == 2'd0)begin
        ip_sop <= 1'b1;
    end
    else if(ip_sop && ip_vld) begin
        ip_sop <= 1'b0;
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        ip_eop <= 1'b0;
    end
    else if(data_flag && flag_mac_err == 1'b0 && flag_type == 2'd0 && mac_rdreq && mac_q[33])begin
        ip_eop <= 1'b1;
    end
    else begin
        ip_eop <= 1'b0;
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        ip_mod <= 2'd0;
    end
    else if(data_flag && flag_mac_err == 1'b0 && flag_type == 2'd0 && mac_rdreq && mac_q[33])begin
        ip_mod <= mac_q[35:34];
    end
    else begin
        ip_mod <= 2'd0;
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        arp_data <= 32'd0;
    end
    else if(data_flag && flag_mac_err == 1'b0 && flag_type == 2'd1 && mac_rdreq)begin
        arp_data <= mac_q[31:0];
    end
    else begin
        arp_data <= 32'd0;
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        arp_vld <= 1'b0; 
    end
    else if(data_flag && flag_mac_err == 1'b0 && flag_type == 2'd1 && mac_rdreq)begin
        arp_vld <= 1'b1;
    end
    else begin
        arp_vld <= 1'b0;
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        arp_sop <= 1'b0;
    end
    else if(end_cnt_head && flag_mac_err_tmp == 1'b0 && flag_type_tmp == 2'd1)begin
        arp_sop <= 1'b1;
    end
    else if(arp_sop && arp_vld) begin
        arp_sop <= 1'b0;
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        arp_eop <= 1'b0;
    end
    else if(data_flag && flag_mac_err == 1'b0 && flag_type == 2'd1 && mac_rdreq && mac_q[33])begin
        arp_eop <= 1'b1;
    end
    else begin
        arp_eop <= 1'b0;
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        arp_mod <= 2'd0;
    end
    else if(data_flag && flag_mac_err == 1'b0 && flag_type == 2'd1 && mac_rdreq && mac_q[33])begin
        arp_mod <= mac_q[35:34];
    end
    else begin
        arp_mod <= 2'd0;
    end
end


endmodule

