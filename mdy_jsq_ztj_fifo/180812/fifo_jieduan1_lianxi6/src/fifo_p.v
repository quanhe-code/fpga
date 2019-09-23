/*
 * fifo练习阶段1练习6
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
        dout_eop,
        b_rdy
);

input                   clk;
input                   rst_n;
input       [7:0]       din;
input                   din_vld;
input                   din_sop;
input                   din_eop;
output  reg [7:0]       dout;   
output  reg             dout_vld;    
output  reg             dout_sop;
output  reg             dout_eop;
input                   b_rdy;


wire[9:0]               wrdata;
wire                    wrreq;
wire[9:0]               q;
wire                    empty;
wire                    b_rdy;

assign wrdata = {din_sop, din_eop, din};
assign wrreq = din_vld;

assign rdreq = (empty == 1'b0 && b_rdy == 1'b1);

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        dout <= 8'h00;
    end
    else begin
        dout <= q[7:0];
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

myfifo myfifo_inst0(
	.clock(clk),
	.data(wrdata),
	.rdreq(rdreq),
	.wrreq(wrreq),
	.empty(empty),
	.full(),
	.q(q),
	.usedw()
);


endmodule
