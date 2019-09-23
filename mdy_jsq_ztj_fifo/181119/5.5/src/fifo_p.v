/*
 * 加包文 练习5
 * UDP打包
 */
module fifo_p(
    clk,
    rst_n,
    dest_port,
    sour_port,
    dest_ip,
    sour_ip,
    din,
    din_vld,
    din_sop,
    din_eop,
    dout,
    dout_vld,
    dout_sop,
    dout_eop
);

input                       clk;
input                       rst_n;
input       [15:0]          dest_port;
input       [15:0]          sour_port;
input       [31:0]          dest_ip;
input       [31:0]          sour_ip;
input       [7:0]           din;
input                       din_vld;
input                       din_sop;
input                       din_eop;

output      reg[7:0]        dout;
output      reg             dout_vld;
output      reg             dout_sop;
output      reg             dout_eop;

reg         [7:0]           tmp_din;
reg         [31:0]          data_sum1;
wire        [31:0]          data_sum;

reg         [3:0]           cnt0;
wire                        add_cnt0;
wire                        end_cnt0;

reg         [1:0]          cnt1;
wire                        add_cnt1;
wire                        end_cnt1;

reg         [15:0]          cnt;
wire                        add_cnt;
wire                        end_cnt;


wire        [9:0]           wrdata;
wire        [9:0]           q;

wire        [47:0]          msg_wrdata;
wire        [47:0]          msg_q;
wire                        msg_rdreq;
wire                        msg_empty;

wire        [95:0]          fake_udp_head;
wire        [63:0]          udp_head;

always @(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        cnt <= 0;
    end
    else if(add_cnt)begin
        if(end_cnt)
            cnt <= 0;
        else
            cnt <= cnt + 1;
    end
end

assign add_cnt = (din_vld);       
assign end_cnt = add_cnt && (din_vld && din_eop);

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        tmp_din <= 8'd0;
    end
    else if(din_vld)begin
        tmp_din <= din;
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        data_sum1 <= 32'd0;
    end
    else if(add_cnt && cnt[0] == 1)begin
        data_sum1 <= data_sum1 + {tmp_din, din}; 
    end
end

myfifo myfifo_inst0(
	.clock(clk),
	.data(wrdata),
	.rdreq(rdreq),
	.wrreq(wrreq),
	.empty(empty),
	.q(q)
);

msgfifo msgfifo_inst0(
	.clock(clk),
	.data(msg_wrdata),
	.rdreq(msg_rdreq),
	.wrreq(msg_wrreq),
	.empty(msg_empty),
	.q(msg_q)
);

assign wrdata = din;
assign wrreq = din_vld;
assign rdreq = (empty == 0 && msg_empty == 0 && cnt1 == 1);

assign msg_wrdata = {data_sum1, cnt + 1'b1};
assign msg_wrreq = din_vld && din_eop;
assign msg_rdreq = end_cnt1;

// 求UDP首部
assign fake_udp_head = {sour_ip, dest_ip, 8'd0, 8'd17, msg_q[15:0] + 16'd8};
assign data_sum = msg_q[47:16] 
                + fake_udp_head[0 +: 16] + fake_udp_head[8 +: 8] 
                + fake_udp_head[16 +: 8] + fake_udp_head[24 +: 8]
                + fake_udp_head[32 +: 8] + fake_udp_head[40 +: 8]
                + sour_port + dest_port + (msg_q[15:0] + 16'd8);
assign udp_head = {sour_port, dest_port, (msg_q[15:0] + 16'd8), ~(data_sum[31:16] + data_sum[15:0])};                
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

assign add_cnt0 = (msg_empty == 0 && cnt1 == 0);       
assign end_cnt0 = add_cnt0 && cnt0== (8 - 1);   

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

assign add_cnt1 = (end_cnt0 || q[8]);       
assign end_cnt1 = add_cnt1 && cnt1 == (2 - 1);   

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        dout <= 8'd0;
    end
    else if(cnt1 == 0 && add_cnt0)begin
        dout <= udp_head[(8*cnt0) +: 8];
    end
    else if(cnt1 == 1)begin
        dout <= q[7:0];
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        dout_vld <= 1'd0;
    end
    else if(cnt1 == 0)begin
        dout_vld <= add_cnt0;
    end
    else if(cnt1 == 1) begin
        dout_vld <= rdreq;
    end
    else begin
        dout_vld <= 1'b0;
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        dout_sop <= 1'b1;
    end
    else if(add_cnt0 && cnt0 == (1 - 1))begin
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
    else if(rdreq && q[8])begin
        dout_eop <= 1'b1;
    end
    else begin
        dout_eop <= 1'b0;
    end
end


 

endmodule
