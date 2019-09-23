/*
 * fifo 阶段2练习1
 */
module fifo_p(
        clk,
        rst_n,
        din,
        din_vld,
        dout,
        dout_vld,
        cfg_thd
);

input                       clk;
input                       rst_n;
input   [9:0]               cfg_thd;
input   [7:0]               din;
input                       din_vld;
output  reg[7:0]               dout;
output  reg                 dout_vld;

wire    [7:0]                        usedw;
wire                                 empty;

myfifo myfifo_inst0 (
	.clock(clk),
	.data(data),
	.rdreq(rdreq),
	.wrreq(wrreq),
	.empty(empty),
	.full(),
	.q(q),
	.usedw(usedw)
);

assign data = din;
assign wrreq = din_vld;

assign rdreq = (usedw >= cfg_thd) && empty == 0;

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
