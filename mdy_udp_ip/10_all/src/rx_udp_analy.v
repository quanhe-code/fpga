module  rx_udp_analy(
             clk            ,
             rst_n          ,
             cfg_port_local ,
             cfg_ip_local   ,
             cfg_ip_pc      ,
             din            ,
             din_vld        ,
             din_sop        ,
             din_eop        ,
             din_mty        , 
             din_err        ,
             dout           ,
             dout_vld       ,
             dout_sop       ,
             dout_eop       ,
             dout_err       ,
             dout_mty       ,
             flag_port_local_err,
             flag_sum_err      
);

parameter      IP_ADDR_W         =  32;
parameter      DATA_W            =  32;


//输入信号定义
input                       clk    ;
input                       rst_n  ;              
input  [DATA_W-1:0]         din    ;
input                       din_vld;
input                       din_sop;
input                       din_eop;
input  [1:0]                din_mty;
input                       din_err;

input   [IP_ADDR_W -1:0]    cfg_ip_local ;
input   [15          :0]    cfg_port_local ;
input   [IP_ADDR_W -1:0]    cfg_ip_pc    ;
output  [DATA_W-1:0]        dout         ;
output                      dout_vld     ;
output                      dout_sop     ;
output                      dout_eop     ;
output                      dout_err     ;
output  [1:0]               dout_mty     ;
output                      flag_port_local_err;
output                      flag_sum_err;

reg     [DATA_W-1:0]        dout         ;
reg                         dout_vld     ;
reg                         dout_sop     ;
reg                         dout_eop     ;
reg                         dout_err     ;
reg     [1:0]               dout_mty     ;
reg                         flag_port_local_err;
reg                         flag_sum_err;

reg                     work_flag;
reg                     data_flag;

reg     [1:0]           cnt_head;
wire                    add_cnt_head;
wire                    end_cnt_head;

wire    [36:0]          udp_data;
wire                    udp_rdreq;
wire                    udp_wrreq;
wire                    udp_empty;
wire    [36:0]          udp_q;

reg     [63:0]          udp_head;
wire    [63:0]          udp_head_tmp;
wire    [95:0]          udp_fake_head;

wire    [16:0]          udp_head_sum_0;
wire    [16:0]          udp_head_sum_1;
wire    [16:0]          udp_head_sum_2;
wire    [16:0]          udp_head_sum_3;
wire    [16:0]          udp_head_sum_4;
wire    [16:0]          udp_head_sum_5;
wire    [16:0]          udp_head_sum_6;
wire    [16:0]          udp_head_sum_7;
wire    [16:0]          udp_head_sum_8;


reg     [15:0]          udp_sum;
wire    [16:0]          udp_sum_tmp_0;
wire    [16:0]          udp_sum_tmp_1;

reg    [16:0]           end_sum_0;
reg    [16:0]           end_sum_1;

rx_udp_analy_fifo rx_udp_analy_fifo_inst0(
	.clock(clk),
	.data(udp_data),
	.rdreq(udp_rdreq),
	.wrreq(udp_wrreq),
	.empty(udp_empty),
	.q(udp_q)
);

assign udp_data = {din_err, din_mty, din_eop, din_sop, din};
assign udp_wrreq = din_vld;
assign udp_rdreq = (work_flag == 1'b1 && udp_empty == 1'b0);

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        work_flag <= 1'b0;
    end
    else if(udp_q[32])begin
        work_flag <= 1'b1;
    end
    else if(udp_rdreq && udp_q[33])begin
        work_flag <= 1'b0;
    end
end

always @(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        cnt_head <= 0;
    end
    else if(add_cnt_head)begin
        if(end_cnt_head)
            cnt_head <= 0;
        else
            cnt_head <= cnt_head + 1;
    end
end

assign add_cnt_head = (data_flag == 1'b0 && udp_rdreq);       
assign end_cnt_head = add_cnt_head && cnt_head== (2 - 1);   

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        data_flag <= 0;
    end
    else if(end_cnt_head)begin
        data_flag <= 1'b1;
    end
    else if(udp_rdreq && udp_q[33])begin
        data_flag <= 1'b0;
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        udp_head <= 64'd0; 
    end
    else if(add_cnt_head)begin
        udp_head[(1 - cnt_head) * 32 +: 32] = udp_q[31:0];
    end
end

assign udp_head_tmp = {udp_head[63:32], udp_q[31:0]};
assign udp_fake_head = {cfg_ip_pc, cfg_ip_local, 8'd0, 8'd17, udp_head_tmp[31:16]};

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        flag_port_local_err <= 1'b0;
    end
    else if(end_cnt_head && udp_head_tmp[47:32] != cfg_port_local)begin
        flag_port_local_err <= 1'b1;
    end
    else if(udp_rdreq && udp_q[33])begin
        flag_port_local_err <= 1'b0;
    end
end

assign udp_head_sum_0 = udp_fake_head[(5 * 16) +: 16] + udp_fake_head[(4 * 16) +: 16];
assign udp_head_sum_1 = udp_head_sum_0[16] + udp_head_sum_0[15:0] + udp_fake_head[(3 * 16) +: 16]; 
assign udp_head_sum_2 = udp_head_sum_1[16] + udp_head_sum_1[15:0] + udp_fake_head[(2 * 16) +: 16]; 
assign udp_head_sum_3 = udp_head_sum_2[16] + udp_head_sum_2[15:0] + udp_fake_head[(1 * 16) +: 16]; 
assign udp_head_sum_4 = udp_head_sum_3[16] + udp_head_sum_3[15:0] + udp_fake_head[(0 * 16) +: 16]; 

assign udp_head_sum_5 = udp_head_sum_4[16] + udp_head_sum_4[15:0] + udp_head_tmp[(3 * 16) +: 16]; 
assign udp_head_sum_6 = udp_head_sum_5[16] + udp_head_sum_5[15:0] + udp_head_tmp[(2 * 16) +: 16]; 
assign udp_head_sum_7 = udp_head_sum_6[16] + udp_head_sum_6[15:0] + udp_head_tmp[(1 * 16) +: 16]; 
assign udp_head_sum_8 = udp_head_sum_7[16] + udp_head_sum_7[15:0] + udp_head_tmp[(0 * 16) +: 16]; 

assign udp_sum_tmp_0 = udp_sum + udp_q[15:0];
assign udp_sum_tmp_1 = udp_sum_tmp_0[16] + udp_sum_tmp_0[15:0] + udp_q[31:16];
always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        udp_sum <= 16'd0;
    end
    else if(end_cnt_head) begin
        udp_sum <= udp_head_sum_8[16] + udp_head_sum_8[15:0];
    end
    else if(data_flag && udp_rdreq)begin
        udp_sum <= udp_sum_tmp_1[16] + udp_sum_tmp_1[15:0];
    end
end

always  @(*)begin
    if(udp_q[35:34] == 2'd0) begin
        end_sum_1 = udp_sum + udp_q[31:16];
        end_sum_0 = end_sum_1[16] + end_sum_1[15:0] + udp_q[15:0];
    end
    else if(udp_q[35:34] == 2'd1) begin
        end_sum_1 = udp_sum  + udp_q[31:16];
        end_sum_0 = end_sum_1[16] + end_sum_1[15:0] + udp_q[15:8];
    end
    else if (udp_q[35:34] == 2'd2) begin
        end_sum_0 = udp_sum + udp_q[31:16];
    end
    else begin
        end_sum_0 = udp_sum + udp_sum[15:0] + udp_q[31:24];
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        flag_sum_err <= 1'b0;
    end
    else if(data_flag && udp_rdreq && udp_q[33] && (end_sum_0[16] + end_sum_0[15:0]) != 16'hFFFF)begin
        flag_sum_err <= 1'b1;
    end
    else begin
        flag_sum_err <= 1'b0;
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        dout <= 32'd0;
    end
    else if(data_flag && udp_rdreq && flag_port_local_err == 1'b0)begin
        dout <= udp_q[31:0];
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        dout_vld <= 1'b0;
    end
    else if(data_flag && udp_rdreq && flag_port_local_err == 1'b0)begin
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
    else if(end_cnt_head && udp_head_tmp[47:32] == cfg_port_local)begin
        dout_sop <= 1'b1;
    end
    else if(dout_sop == 1'b1 && dout_vld == 1'b1)begin
        dout_sop <= 1'b0;
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        dout_eop <= 1'b0;
    end
    else if(data_flag && udp_rdreq && udp_q[33] == 1'b1 && flag_port_local_err == 1'b0)begin
        dout_eop <= 1'b1;
    end
    else begin
        dout_eop <= 1'b0;
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        dout_err <= 1'b0;
    end
    else if(data_flag && udp_rdreq && udp_q[33] == 1'b1 && flag_port_local_err == 1'b0
         && (udp_q[36] || (end_sum_0[16] + end_sum_0[15:0]) != 16'hFFFF))begin
        dout_err <= 1'b1;
    end
    else begin
        dout_err <= 1'b0;
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        dout_mty <= 2'd0;
    end
    else if(data_flag && udp_rdreq && udp_q[33] == 1'b1 && flag_port_local_err == 1'b0)begin
        dout_mty <= udp_q[35:34];
    end
    else begin
        dout_mty <= 2'd0;
    end
end

endmodule

