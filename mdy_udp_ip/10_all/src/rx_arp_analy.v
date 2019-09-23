module  rx_arp_analy(
             clk            ,
             rst_n          ,
             cfg_mac_local  ,
             cfg_ip_local   ,
             cfg_ip_pc      ,
             get_mac_pc     ,
             arp_mod        , 
             arp_data       ,
             arp_vld        ,
             arp_sop        ,
             arp_eop        ,
             ack_en         ,
             get_en,          
             flag_type_err  , 
             flag_len_err   , 
             flag_pc_ip_err , 
             flag_local_ip_err
);

parameter      MAC_ADDR_W        =  48;
parameter      IP_ADDR_W         =  32;
parameter      DATA_W            =  32;


//输入信号定义
input                       clk    ;
input                       rst_n  ;              
input  [DATA_W-1:0]         arp_data;
input                       arp_vld;
input                       arp_sop;
input                       arp_eop;
input  [1:0]                arp_mod;

input   [MAC_ADDR_W-1:0]    cfg_mac_local;
input   [IP_ADDR_W -1:0]    cfg_ip_local ;
output  [MAC_ADDR_W-1:0]    get_mac_pc   ;
input   [IP_ADDR_W -1:0]    cfg_ip_pc    ;
output                      get_en       ;
output                      ack_en       ;
output             flag_type_err  ; 
output             flag_len_err   ; 
output             flag_pc_ip_err ; 
output             flag_local_ip_err;

reg             flag_type_err  ; 
reg             flag_len_err   ; 
reg             flag_pc_ip_err ; 
reg             flag_local_ip_err;

reg     [MAC_ADDR_W-1:0]    get_mac_pc   ;
reg                         get_en       ;
reg                         ack_en       ;

reg                     work_flag;

reg     [16:0]          cnt_len;
wire                    add_cnt_len;
wire                    end_cnt_len;

reg     [223:0]         arp_pack;
wire    [223:0]         arp_pack_tmp;

wire    [35:0]          mac_data;
wire                    mac_rdreq;
wire                    mac_wrreq;
wire                    mac_empty;
wire    [35:0]          mac_q;
wire                    flag_no_error;

rx_arp_analy_fifo rx_arp_analy_fifo_inst0(
	.clock(clk),
	.data(mac_data),
	.rdreq(mac_rdreq),
	.wrreq(mac_wrreq),
	.empty(mac_empty),
	.q(mac_q)
);

assign mac_data = {arp_mod, arp_eop, arp_sop, arp_data};
assign mac_wrreq = arp_vld;
assign mac_rdreq = work_flag == 1'b1 && mac_empty == 1'b0;

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        work_flag <= 1'b0;
    end
    else if(mac_q[32])begin
        work_flag <= 1'b1;
    end
    else if(mac_rdreq && mac_q[33]) begin
        work_flag <= 1'b0;
    end
end

always @(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        cnt_len <= 0;
    end
    else if(add_cnt_len)begin
        if(end_cnt_len)
            cnt_len <= 0;
        else
            cnt_len <= cnt_len + 1'd1;
    end
end

assign add_cnt_len = mac_rdreq;       
assign end_cnt_len = add_cnt_len && (mac_rdreq && mac_q[33]);   

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        arp_pack <= 224'd0;
    end
    else if(add_cnt_len && cnt_len < 7)begin
        arp_pack[((6 - cnt_len) * 32) +: 32] <= mac_q[31:0];
    end
end

assign arp_pack_tmp = {arp_pack[223:32], mac_q[31:0]};

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        flag_type_err <= 1'b0;
    end
    else if(end_cnt_len && arp_pack_tmp[223:192] != 32'h00010800)begin
        flag_type_err <= 1'b1;
    end
    else begin
        flag_type_err <= 1'b0;
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        flag_len_err <= 1'b0;
    end
    else if(end_cnt_len && arp_pack_tmp[191:176] != 16'h0604)begin
        flag_len_err <= 1'b1;
    end
    else begin
        flag_len_err <= 1'b0;
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        ack_en <= 1'b0;
    end
    else if(end_cnt_len && arp_pack_tmp[175:160] == 16'h0001 && flag_no_error)begin
        ack_en <= 1'b1;
    end
    else begin
        ack_en <= 1'b0;
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        get_en <= 1'b0;
    end
    else if(end_cnt_len && arp_pack_tmp[175:160] == 16'h0002 && flag_no_error)begin
        get_en <= 1'b1;
    end
    else begin
        get_en <= 1'b0;
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        get_mac_pc <= 48'd0;
    end
    else if(end_cnt_len)begin
        get_mac_pc <= arp_pack_tmp[159:112];
    end
    else begin
        get_mac_pc <= 48'd0;
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        flag_pc_ip_err <= 1'b0;
    end
    else if(end_cnt_len && arp_pack_tmp[111:80] != cfg_ip_pc)begin
        flag_pc_ip_err <= 1'b1;
    end
    else begin
        flag_pc_ip_err <= 1'b0;
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        flag_local_ip_err <= 1'b0;
    end
    else if(end_cnt_len && arp_pack_tmp[31:0] != cfg_ip_local)begin
        flag_local_ip_err <= 1'b1;
    end
    else begin
        flag_local_ip_err <= 1'b0;
    end
end

assign flag_no_error = (arp_pack_tmp[223:192] == 32'h00010800 && arp_pack_tmp[191:176] == 16'h0604 
                && arp_pack_tmp[111:80] == cfg_ip_pc 
                && arp_pack_tmp[31:0] == cfg_ip_local);

endmodule

