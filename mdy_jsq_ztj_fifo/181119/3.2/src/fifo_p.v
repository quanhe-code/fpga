/*
 * 溢出丢弃 练习2
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

reg                         drop_flag;
wire        [17:0]          q;
wire        [17:0]          wrdata;

wire                        msg_wrdata;
wire                        msg_q;

reg         [4:0]           cnt;
wire                        add_cnt;
wire                        end_cnt;
reg                         flag_add;

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        flag_add <= 1'b0;
    end
    else if(end_cnt)begin
        flag_add <= 1'b1;
    end
    else if(din_vld && din_eop)begin
        flag_add <= 1'b0;
    end
end

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

assign add_cnt = din_vld && (flag_add == 0);       
assign end_cnt = add_cnt && cnt== (20 - 1);   

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
       drop_flag <= 1'b0; 
    end
    else if(end_cnt && din != 16'd1)begin
        drop_flag <= 1'b1;
    end
    else if(din_vld && din_eop)begin
        drop_flag <= 1'b0;
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
assign rdreq = empty == 0 && msg_empty == 0;

assign msg_wrdata = drop_flag;
assign msg_wrreq = (din_vld && din_eop);
assign msg_rdreq = msg_empty == 0 && (rdreq && q[16]);

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        dout <= 16'd0;
    end
    else begin
        dout <= q[15:0];
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        dout_vld <= 1'b0;
    end
    else if(rdreq)begin
        dout_vld <= ~msg_q;
    end
    else begin
        dout_vld <= 1'b0;
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        dout_sop <= 1'b0;
    end
    else if(rdreq)begin
        dout_sop <= q[17];
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
