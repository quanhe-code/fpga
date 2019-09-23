/*
 * 溢出丢弃 练习4
 */
module fifo_p(
    clk,
    rst_n,
    din,
    din_vld,
    din_sop,
    din_eop,
    din_err,
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
input                       din_err;

output      reg[15:0]       dout;
output      reg             dout_vld;
output      reg             dout_sop;
output      reg             dout_eop;

wire        [17:0]          q;
wire        [17:0]          wrdata;

wire                        msg_wrdata;
wire                        msg_q;

reg         [15:0]          sum;

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        sum <= 16'd0;
    end
    else if(din_vld && din_sop)begin
        sum <= din;
    end
    else if(din_vld)begin
        sum <= sum + din;
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

assign msg_wrdata = (din_vld && din_eop && (din_err || (sum + din) != 0));
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
