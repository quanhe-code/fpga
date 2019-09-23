module tx_pack(
    clk          ,
    rst_n        ,
    cfg_sport    ,
    cfg_dport    ,
    cfg_sip      ,
    cfg_dip      ,
    cfg_mac_d    ,
    cfg_mac_s    ,
    tx_data      ,
    tx_sop       ,
    tx_eop       ,
    tx_vld       ,
    tx_rdy       ,
    tx_mty       ,
    dout         ,
    dout_sop     ,
    dout_eop     ,
    dout_vld     ,
    dout_rdy     ,
    dout_mty       

);
 `include "clogb2.v"

    input          clk          ;
    input          rst_n        ;
    input[15:0]    cfg_sport    ;
    input[15:0]    cfg_dport    ;
    input[31:0]    cfg_sip      ;
    input[31:0]    cfg_dip      ;
    input[47:0]    cfg_mac_d    ;
    input[47:0]    cfg_mac_s    ;
    input[15:0]    tx_data      ;
    input          tx_sop       ;
    input          tx_eop       ;
    input          tx_vld       ;
    output         tx_rdy       ;
    input          tx_mty       ;
    output[15:0]   dout         ;
    output         dout_sop     ;
    output         dout_eop     ;
    output         dout_vld     ;
    input          dout_rdy     ;
    output         dout_mty     ; 


    reg            tx_rdy       ;
    reg   [15:0]   dout         ;
    reg            dout_sop     ;
    reg            dout_eop     ;
    reg            dout_vld     ;
    reg            dout_mty     ; 

reg                     data_flag;
reg                     work_flag;

reg     [15:0]          data_sum_0;
wire    [16:0]          data_sum_0_tmp;

reg     [31:0]          cnt0;
wire                    add_cnt0;
wire                    end_cnt0;

reg     [3:0]           cnt1;
wire                    add_cnt1;
wire                    end_cnt1;

reg     [3:0]           cnt2;
wire                    add_cnt2;
wire                    end_cnt2;
reg     [3:0]           x;

reg     [15:0]          ip_packet_id;

wire    [159:0]         ip_head;

wire    [95:0]          udp_fake_head;
wire    [63:0]          udp_head;

wire    [18:0]          dfifo_data;
wire                    dfifo_wrreq;
wire                    dfifo_rdreq;
wire    [18:0]          dfifo_q;
wire                    dfifo_empty;

wire    [31:0]          mfifo_data;
wire                    mfifo_wrreq;
wire                    mfifo_rdreq;
wire    [31:0]          mfifo_q;
wire                    mfifo_empty;

wire    [16:0]          ip_head_sum_0;
wire    [16:0]          ip_head_sum_1;
wire    [16:0]          ip_head_sum_2;
wire    [16:0]          ip_head_sum_3;
wire    [16:0]          ip_head_sum_4;
wire    [16:0]          ip_head_sum_5;
wire    [16:0]          ip_head_sum_6;
wire    [16:0]          ip_head_sum_7;
wire    [16:0]          ip_head_sum_8;
wire    [15:0]          ip_head_chk;
wire    [15:0]          ip_len;

wire    [16:0]          udp_sum_00;
wire    [16:0]          udp_sum_01;
wire    [16:0]          udp_sum_02;
wire    [16:0]          udp_sum_03;
wire    [16:0]          udp_sum_04;
wire    [16:0]          udp_sum_05;
wire    [16:0]          udp_sum_06;
wire    [16:0]          udp_sum_07;
wire    [16:0]          udp_sum_08;
wire    [16:0]          udp_sum_09;
wire    [15:0]          udp_len;
wire    [15:0]          udp_chk;

wire    [111:0]         mac_head;

tx_pack_data_fifo tx_pack_data_fifo_inst0(
	.clock(clk),
	.data(dfifo_data),
	.rdreq(dfifo_rdreq),
	.wrreq(dfifo_wrreq),
	.empty(dfifo_empty),
    .full(dfifo_full),
	.q(dfifo_q)
);

tx_pack_msg_fifo tx_pack_msg_fifo_inst0(
	.clock(clk),
	.data(mfifo_data),
	.rdreq(mfifo_rdreq),
	.wrreq(mfifo_wrreq),
	.empty(mfifo_empty),
	.q(mfifo_q)
);

assign dfifo_data = {tx_sop, tx_eop, tx_mty, tx_data};
assign dfifo_wrreq = tx_vld;
assign dfifo_rdreq = (data_flag == 1'b1 && dfifo_empty == 1'b0 && dout_rdy == 1'b1);

assign mfifo_data = {data_sum_0, cnt0 + 1};
assign mfifo_wrreq = end_cnt0;
assign mfifo_rdreq = (dfifo_rdreq == 1'b1 && dfifo_q[17] == 1'b1);
/*
 * 这个tx_rdy信号不知道怎么生成
 * 暂时先用fifo的full信号去生成
 */
always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        tx_rdy <= 1'b0;
    end
    else if(dfifo_full == 1'b1)begin
        tx_rdy <= 1'b0;
    end
    else if(dfifo_full == 1'b0)begin
        tx_rdy <= 1'b1;
    end
end


/*
 * 使用计数器计算包文长度
 */
always @(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        cnt0 <= 0;
    end
    else if(add_cnt0)begin
        if(end_cnt0)
            cnt0 <= 0;
        else
            cnt0 <= cnt0 + 1;
    end
end

assign add_cnt0 = tx_vld;       
assign end_cnt0 = add_cnt0 && cnt0== tx_eop;   

/*
 * 计算原始数据校验和
 */
assign data_sum_0_tmp = data_sum_0 + tx_data;
always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        data_sum_0 <= 16'd0;
    end
    else if(tx_vld)begin
        data_sum_0 <= data_sum_0_tmp[16] + data_sum_0_tmp[15:0];
    end
end


/*
 * 使用计数器分4个阶段输出数据
 */
always @(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        cnt1 <= 0;
    end
    else if(add_cnt1)begin
        if(end_cnt1)
            cnt1 <= 0;
        else
            cnt1 <= cnt1 + 1;
    end
end

assign add_cnt1 = (data_flag == 1'b0 && mfifo_empty == 1'b0 && dout_rdy == 1'b1);       
assign end_cnt1 = add_cnt1 && cnt1 == (x - 1);   

always @(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        cnt2 <= 0;
    end
    else if(add_cnt2)begin
        if(end_cnt2)
            cnt2 <= 0;
        else
            cnt2 <= cnt2 + 1;
    end
end

assign add_cnt2 = end_cnt1;       
assign end_cnt2 = add_cnt2 && cnt2 == (3 - 1);   

always  @(*)begin
    if(cnt2 == 0) begin
        x = 7;
    end
    else if(cnt2 == 1) begin
        x = 10;
    end
    else begin
        x = 4;
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        work_flag <= 1'b0;
    end
    else if(mfifo_empty == 1'b0 && dout_rdy == 1'b1)begin
        work_flag <= 1'b1;
    end
    else if(dfifo_rdreq == 1'b1 && dfifo_q[17] == 1'b1)begin
        work_flag <= 1'b0;
    end
end


always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        data_flag <= 1'b0;
    end
    else if(end_cnt2)begin
        data_flag <= 1'b1;
    end
    else if(dfifo_rdreq == 1'b1 && dfifo_q[17] == 1'b1)begin
        // 读到最后一个数据时，把标记位清零
        data_flag <= 1'b0;
    end
end

/*
 * 组织MAC头
 */
assign mac_head = {cfg_mac_d, cfg_mac_s, 16'h0800};


/*
 * 组织IP头部
 */
// 计算IP长度,首部 + 数据长度
assign ip_len = 16'd20 + mfifo_q[15:0] + 16'd8;

/*
 * 生成IP数据包标识
 */
always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        ip_packet_id <= 16'd0;
    end
    else if(dfifo_rdreq == 1'b1 && dfifo_q[17] == 1'b1)begin
        ip_packet_id <= ip_packet_id + 1;
    end
end

/*
 * 计算IP首部检验和
 */
assign ip_head_sum_0 = ip_head[(0 * 16) +: 16] + ip_head[(1 * 16) +: 16];
assign ip_head_sum_1 = ip_head_sum_0[16] + ip_head_sum_0[15:0] + ip_head[(2 * 16) +: 16];
assign ip_head_sum_2 = ip_head_sum_1[16] + ip_head_sum_1[15:0] + ip_head[(3 * 16) +: 16]; 
assign ip_head_sum_3 = ip_head_sum_2[16] + ip_head_sum_2[15:0] + 16'd0;// 校验码当作0计算
assign ip_head_sum_4 = ip_head_sum_3[16] + ip_head_sum_3[15:0] + ip_head[(5 * 16) +: 16];
assign ip_head_sum_5 = ip_head_sum_4[16] + ip_head_sum_4[15:0] + ip_head[(6 * 16) +: 16];
assign ip_head_sum_6 = ip_head_sum_5[16] + ip_head_sum_5[15:0] + ip_head[(7 * 16) +: 16];
assign ip_head_sum_7 = ip_head_sum_6[16] + ip_head_sum_6[15:0] + ip_head[(8 * 16) +: 16];
assign ip_head_sum_8 = ip_head_sum_7[16] + ip_head_sum_7[15:0] + ip_head[(9 * 16) +: 16];
assign ip_head_chk = ~(ip_head_sum_8[16] + ip_head_sum_8[15:0]);

assign ip_head = {
    4'd4, 4'd5, 8'd0, ip_len,
    ip_packet_id, 3'd0, 13'd0,
    8'd255, 8'd17, ip_head_chk,
    cfg_sip,
    cfg_dip
};

/*
 * 组织UDP伪首部和首部
 */
assign udp_sum_00 = mfifo_q[31:16] + udp_fake_head[(5 * 16) +: 16];
assign udp_sum_01 = udp_sum_00[16] + udp_sum_00[15:0] + udp_fake_head[(4*16) +: 16];
assign udp_sum_02 = udp_sum_01[16] + udp_sum_01[15:0] + udp_fake_head[(3*16) +: 16];
assign udp_sum_03 = udp_sum_02[16] + udp_sum_02[15:0] + udp_fake_head[(2*16) +: 16];
assign udp_sum_04 = udp_sum_03[16] + udp_sum_03[15:0] + udp_fake_head[(1*16) +: 16];
assign udp_sum_05 = udp_sum_04[16] + udp_sum_04[15:0] + udp_fake_head[(0*16) +: 16];

assign udp_sum_06 = udp_sum_05[16] + udp_sum_05[15:0] + udp_head[(3*16) +: 16];
assign udp_sum_07 = udp_sum_06[16] + udp_sum_06[15:0] + udp_head[(2*16) +: 16];
assign udp_sum_08 = udp_sum_07[16] + udp_sum_07[15:0] + udp_head[(1*16) +: 16];
assign udp_sum_09 = udp_sum_08[16] + udp_sum_08[15:0] + 16'd0;// 检验码作0处理
assign udp_chk = ~(udp_sum_09[16] + udp_sum_09[15:0]);

assign udp_len = mfifo_q[15:0] + 8;
assign udp_fake_head = {cfg_sip, cfg_dip, 8'd0, 8'd17, udp_len};
assign udp_head = {cfg_mac_s, cfg_mac_d, udp_len, udp_chk};


always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        dout <= 16'd0;
    end
    else if(data_flag == 1'b0 && cnt2 == 0 && add_cnt1)begin
        dout <= mac_head[(6 - cnt1)*16 +: 16];
    end
    else if(data_flag == 1'b0 && cnt2 == 1 && add_cnt1)begin
        dout <= ip_head[(9 - cnt1)*16 +: 16];
    end
    else if(data_flag == 1'b0 && cnt2 == 2 && add_cnt1) begin
        dout <= udp_head[(3 - cnt1)*16 +: 16];
    end
    else if(data_flag == 1'b1 && dfifo_rdreq == 1'b1) begin
        dout <= dfifo_q[15:0];
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        dout_vld <= 1'b0;
    end
    else if(data_flag == 1'b0 && add_cnt1)begin
        dout_vld <= 1'b1;
    end
    else if(data_flag == 1'b1 && dfifo_rdreq == 1'b1)begin
        dout_vld <= 1'b1;
    end
    else begin
        dout_vld <= 1'b0;
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        dout_sop <= 1'b0;
    end
    else if(cnt2 == 0 && add_cnt1 && cnt1 == (1 - 1))begin
        dout_sop <= 1'b1;
    end
    else begin
        dout_sop <= 1'b0;
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        dout_eop <= 1'b0;
    end
    else if(dfifo_rdreq == 1'b1 && dfifo_q[17] == 1'b1)begin
        dout_eop <= 1'b1;
    end
    else begin
        dout_eop <= 1'b0;
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        dout_mty <= 1'b0;
    end
    else if(dfifo_rdreq == 1'b1 && dfifo_q[17] == 1'b1)begin
        dout_mty <= dfifo_q[16];
    end
    else begin
        dout_mty <= 1'b0;
    end
end




endmodule


 

