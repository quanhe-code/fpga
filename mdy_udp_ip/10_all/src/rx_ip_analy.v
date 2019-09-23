module  rx_ip_analy(
             clk            ,
             rst_n          ,
             cfg_ip_local   ,
             cfg_ip_pc      ,
             din            ,
             din_vld        ,
             din_sop        ,
             din_eop        ,
             din_mty        , 
             dout           ,
             dout_vld       ,
             dout_sop       ,
             dout_eop       ,
             dout_err       ,
             dout_mty       ,        
             flag_type_err ,
             flag_len_err  ,
             flag_sum_err  ,
             flag_ip_local_err  ,
             flag_ip_pc_err
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

input   [IP_ADDR_W -1:0]    cfg_ip_local ;
input   [IP_ADDR_W -1:0]    cfg_ip_pc    ;
output  [DATA_W-1:0]        dout         ;
output                      dout_vld     ;
output                      dout_sop     ;
output                      dout_eop     ;
output                      dout_err     ;
output  [1:0]               dout_mty     ;

output                      flag_type_err ;
output                      flag_len_err  ; // FIFO里的包读取完成在做处理
output                      flag_sum_err  ;
output                      flag_ip_local_err  ;
output                      flag_ip_pc_err;

reg     [DATA_W-1:0]        dout         ;
reg                         dout_vld     ;
reg                         dout_sop     ;
reg                         dout_eop     ;
reg                         dout_err     ;
reg     [1:0]               dout_mty     ;

reg                      flag_type_err ;
reg                      flag_len_err  ; // FIFO里的包读取完成在做处理
reg                      flag_sum_err  ;
reg                      flag_ip_local_err  ;
reg                      flag_ip_pc_err;

reg                     work_flag;
reg                     data_flag;

reg     [2:0]           cnt_head;
wire                    add_cnt_head;
wire                    end_cnt_head;

reg     [15:0]          cnt_len;
wire                    add_cnt_len;
wire                    end_cnt_len;

reg     [159:0]         ip_head;
wire    [159:0]         ip_head_tmp;

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

wire    [35:0]          ip_data;
wire                    ip_rdreq;
wire                    ip_wrreq;
wire                    ip_empty;
wire    [35:0]          ip_q;
wire    [15:0]          data_len;
wire                    flag_no_error;

rx_ip_analy_fifo rx_ip_analy_fifo_inst0(
	.clock(clk),
	.data(ip_data),
	.rdreq(ip_rdreq),
	.wrreq(ip_wrreq),
	.empty(ip_empty),
	.q(ip_q)
);

assign ip_data = {din_mty, din_eop, din_sop, din};
assign ip_wrreq = din_vld;
assign ip_rdreq = (work_flag == 1'b1 && ip_empty == 1'b0);

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        work_flag <= 1'b0;
    end
    else if(ip_q[32])begin
        work_flag <= 1'b1;
    end
    else if(ip_rdreq && ip_q[33])begin
        work_flag <= 1'b0;
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        data_flag <= 1'b0;
    end
    else if(end_cnt_head)begin
        data_flag <= 1'b1;
    end
    else if(ip_rdreq && ip_q[33])begin
        data_flag <= 1'b0;
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
            cnt_head <= cnt_head + 1'b1;
    end
end

assign add_cnt_head = (work_flag && data_flag == 1'd0 && ip_rdreq);       
assign end_cnt_head = add_cnt_head && cnt_head== (5 - 1);   

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        ip_head <= 160'd0;
    end
    else if(add_cnt_head)begin
        ip_head <= {ip_head[127:0], ip_q[31:0]};
    end
end

assign ip_head_tmp = {ip_head[127:0], ip_q[31:0]}; // end_cnt_head 时有效

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        flag_type_err <= 1'b0;
    end
    else if(end_cnt_head && (ip_head_tmp[159:156] != 4'd4 || ip_head_tmp[155:152] != 4'd5))begin
        flag_type_err <= 1'b1;
    end
    else if(ip_rdreq && ip_q[33]) begin
        flag_type_err <= 1'b0;
    end
end

assign ip_head_sum_0 = ip_head_tmp[(9 * 16) +: 16] + ip_head_tmp[(8 * 16) +: 16];
assign ip_head_sum_1 = ip_head_sum_0[16] + ip_head_sum_0[15:0] + ip_head_tmp[(7 * 16) +: 16];
assign ip_head_sum_2 = ip_head_sum_1[16] + ip_head_sum_1[15:0] + ip_head_tmp[(6 * 16) +: 16];
assign ip_head_sum_3 = ip_head_sum_2[16] + ip_head_sum_2[15:0] + ip_head_tmp[(5 * 16) +: 16];
assign ip_head_sum_4 = ip_head_sum_3[16] + ip_head_sum_3[15:0] + ip_head_tmp[(4 * 16) +: 16];
assign ip_head_sum_5 = ip_head_sum_4[16] + ip_head_sum_4[15:0] + ip_head_tmp[(3 * 16) +: 16];
assign ip_head_sum_6 = ip_head_sum_5[16] + ip_head_sum_5[15:0] + ip_head_tmp[(2 * 16) +: 16];
assign ip_head_sum_7 = ip_head_sum_6[16] + ip_head_sum_6[15:0] + ip_head_tmp[(1 * 16) +: 16];
assign ip_head_sum_8 = ip_head_sum_7[16] + ip_head_sum_7[15:0] + ip_head_tmp[(0 * 16) +: 16];
assign ip_head_chk = (ip_head_sum_8[16] + ip_head_sum_8[15:0]);
always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        flag_sum_err <= 1'b0;
    end
    else if(end_cnt_head && ip_head_chk != 16'hFFFF)begin
        flag_sum_err <= 1'b1;
    end
    else if(ip_rdreq && ip_q[33]) begin
        flag_sum_err <= 1'b0;
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        flag_ip_local_err <= 1'b0;
    end
    else if(end_cnt_head && ip_head_tmp[31:0] != cfg_ip_local)begin
        flag_ip_local_err <= 1'b1;
    end
    else if(ip_rdreq && ip_q[33]) begin
        flag_ip_local_err <= 1'b0;
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        flag_ip_pc_err <= 1'b0;
    end
    else if(end_cnt_head && ip_head_tmp[63:32] != cfg_ip_pc)begin
        flag_ip_pc_err <= 1'b1;
    end
    else if(ip_rdreq && ip_q[33]) begin
        flag_ip_pc_err <= 1'b0;
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
            cnt_len <= cnt_len + 1'b1;
    end
end

assign add_cnt_len = (work_flag == 1'b1 && data_flag == 1'b1 && ip_rdreq);       
assign end_cnt_len = add_cnt_len && (ip_rdreq && ip_q[33]); 

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        flag_len_err <= 1'b0;
    end
    else if(end_cnt_len && data_len < ip_head[143:128])begin
        flag_len_err <= 1'b1;
    end
    else begin
        flag_len_err <= 1'b0;
    end
end


assign flag_no_error = (flag_type_err == 1'b0 
                        && flag_sum_err == 1'b0
                        && flag_ip_local_err == 1'b0
                        && flag_ip_pc_err == 1'b0);

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        dout <= 32'd0;
    end
    else if(work_flag == 1'b1 && data_flag == 1'b1 && flag_no_error && ip_rdreq)begin
        dout <= ip_q[31:0];
    end
    else begin
        dout <= 32'd0;
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        dout_vld <= 1'b0;
    end
    else if(work_flag == 1'b1 && data_flag == 1'b1 && flag_no_error && ip_rdreq)begin
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
    else if(end_cnt_head 
                && ip_head_tmp[159:156] == 4'd4 && ip_head_tmp[155:152] == 4'd5
                && ip_head_chk == 16'hFFFF
                && ip_head_tmp[31:0] == cfg_ip_local
                && ip_head_tmp[63:32] == cfg_ip_pc)begin
        dout_sop <= 1'b1;
    end
    else if(dout_sop == 1'b1 && dout_vld)begin
        dout_sop <= 1'b0;
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        dout_eop <= 1'b0;
    end
    else if(ip_rdreq && ip_q[33])begin
        dout_eop <= 1'b1;
    end
    else begin
        dout_eop <= 1'b0;
    end
end


always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        dout_mty <= 2'd0;
    end
    else if(ip_rdreq && ip_q[33])begin
        dout_mty <= ip_q[35:34];
    end
    else begin
        dout_mty <= 2'd0;
    end
end


assign data_len = ((cnt_len + 1'd1)*3'd4) - ip_q[35:34] + 16'd20;
always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        dout_err <= 1'b0;
    end
    else if(end_cnt_len && data_len < ip_head[143:128])begin
        dout_err <= 1'b1;
    end
    else begin
        dout_err <= 1'b0;
    end
end

endmodule

