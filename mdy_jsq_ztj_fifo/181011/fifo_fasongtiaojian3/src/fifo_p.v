/*
 * fifo 阶段2练习3
 */
module fifo_p(
        clk,
        rst_n,
        din,
        din_sop,
        din_eop,
        din_vld,
        dout,
        dout_sop,
        dout_eop,
        dout_vld
);

input                       clk;
input                       rst_n;

input   [7:0]               din;
input                       din_sop;
input                       din_eop;
input                       din_vld;

output  reg[7:0]            dout;
output  reg                 dout_sop;
output  reg                 dout_eop;
output  reg                 dout_vld;

wire    [7:0]               usedw;
wire                        empty;
wire    [9:0]               q;
reg                         send_state;
wire    [9:0]               wrdata;

dfifo dfifo_inst0 (
	.clock(clk),
	.data(wrdata),
	.rdreq(rdreq),
	.wrreq(wrreq),
	.empty(empty),
	.full(),
	.q(q),
	.usedw(usedw)
);

ififo ififo_inst0(
	.clock(clk),
	.data(),
	.rdreq(irdreq),
	.wrreq(iwrreq),
	.empty(iempty),
	.full(),
	.q(),
	.usedw()
);

assign iwrreq=din_vld && din_eop;
assign irdreq= (iempty == 0) && rdreq && q[8];

assign wrdata = {din_sop, din_eop, din};
assign wrreq = din_vld;

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        send_state <= 1'b0;
    end
    else if(send_state == 1'b0 && (usedw > 250 || iempty == 0))begin
        send_state <= 1'b1;
    end
    else if(send_state == 1'b1 && irdreq)begin  // 数据读到EOP就停止
        send_state <= 1'b0;
    end
end

assign rdreq = (empty == 0) && send_state;

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        dout <= 8'h0;
    end
    else begin
        dout <= q[7:0];
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        dout_sop <= 1'b0;
    end
    else if(rdreq)begin
        dout_sop <= q[9];
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
        dout_eop <= q[8];
    end
    else begin
        dout_eop <= 1'b0;
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        dout_vld <= 1'b0;
    end
    else begin
        dout_vld <= rdreq;
    end
end


endmodule
