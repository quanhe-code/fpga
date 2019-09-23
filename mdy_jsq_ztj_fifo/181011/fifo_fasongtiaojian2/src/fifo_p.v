/*
 * fifo 阶段2练习2
 */
module fifo_p(
        clk,
        rst_n,
        cfg_thd_0,
        cfg_thd_1,
        din,
        din_vld,
        dout,
        dout_vld
);

input                       clk;
input                       rst_n;
input   [9:0]               cfg_thd_0;
input   [9:0]               cfg_thd_1;

input   [7:0]               din;
input                       din_vld;
output  reg[7:0]            dout;
output  reg                 dout_vld;

wire    [7:0]               usedw;
wire                        empty;
wire    [7:0]               q;
reg                         send_state;
wire    [7:0]               wrdata;

myfifo myfifo_inst0 (
	.clock(clk),
	.data(wrdata),
	.rdreq(rdreq),
	.wrreq(wrreq),
	.empty(empty),
	.full(),
	.q(q),
	.usedw(usedw)
);

assign wrdata = din;
assign wrreq = din_vld;

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        send_state <= 1'b0;
    end
    else if(usedw > cfg_thd_1)begin
        send_state <= 1'b1;
    end
    else if(usedw < cfg_thd_0)begin
        send_state <= 1'b0;
    end
end


assign rdreq = (empty == 0) && send_state == 1;

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        dout <= 8'h0;
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
        dout_vld <= rdreq;
    end
end


endmodule
