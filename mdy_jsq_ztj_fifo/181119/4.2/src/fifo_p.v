/*
 * 加头数据 练习2
 */
module fifo_p(
    clk,
    rst_n,
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
input       [15:0]          din;
input                       din_vld;
input                       din_sop;
input                       din_eop;

output      reg[15:0]       dout;
output      reg             dout_vld;
output      reg             dout_sop;
output      reg             dout_eop;

wire        [17:0]          q;
wire        [17:0]          wrdata;

wire        [23:0]                msg_wrdata;
wire        [23:0]                msg_q;

reg         [7:0]               cnt;
wire                            add_cnt;
wire                            end_cnt;

reg         [1:0]               cnt1;
wire                            add_cnt1;
wire                            end_cnt1;

reg                             data_flag;

wire                            msg_empty;
wire                            rdreq;

wire        [16:0]              tmp_data;
reg         [15:0]              check_data;

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

assign add_cnt = din_vld;       
assign end_cnt = add_cnt && din_eop;   

assign tmp_data = check_data + din;

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        check_data <= 16'd0;
    end
    else if(din_vld && din_eop)begin
        check_data <= 16'd0;
    end
    else if(din_vld)begin
        check_data <= tmp_data[16:1] + tmp_data[15:0];
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

assign wrdata = {din_sop , din_eop, din};
assign wrreq = din_vld;
assign rdreq = empty == 0 && msg_empty == 0 && data_flag;

assign msg_wrdata[7:0] = (cnt + 1);
assign msg_wrdata[23:8] = ~(tmp_data[16:1] + tmp_data[15:0]);
assign msg_wrreq = end_cnt;
assign msg_rdreq = msg_empty == 0 && (rdreq && q[16]);

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

assign add_cnt1 = (msg_empty == 0 && data_flag == 0);       
assign end_cnt1 = add_cnt1 && cnt1== (2 - 1);   

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        data_flag <= 1'b0;
    end
    else if(end_cnt1)begin
        data_flag <= 1'b1;
    end
    else if(rdreq && q[16])begin
        data_flag <= 1'b0;
    end
end


always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        dout <= 16'd0;
    end
    else if(add_cnt1 && cnt1 == (1 - 1))begin
        dout <= msg_q[7:0];
    end
    else if(add_cnt1 && cnt1 == (2 - 1))begin
        dout <= msg_q[23:8];
    end
    else begin
        dout <= q;
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        dout_vld <= 1'b0;
    end
    else begin
        dout_vld <= ((msg_empty == 0 && data_flag ==0) || rdreq);
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        dout_sop <= 1'b0;
    end
    else if(add_cnt1 && cnt1 == (1 - 1))begin
        dout_sop <= 1;
    end
    else begin
        dout_sop <= 1'b0;
    end
end


always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        dout_eop <= 1'b0;
    end
    else if(rdreq)begin
        dout_eop <= q[16];
    end
    else begin
        dout_eop <= 1'b0;
    end
end

endmodule
