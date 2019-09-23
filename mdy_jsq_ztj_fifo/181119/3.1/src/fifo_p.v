/*
 * 溢出丢弃 练习1
 */
module fifo_p(
    clk_in,
    rst_n,
    din,
    din_vld,
    din_sop,
    din_eop,
    clk_out,
    dout,
    dout_vld,
    dout_sop,
    dout_eop,
    b_rdy    
);

input                       clk_in;
input                       rst_n;
input       [7:0]           din;
input                       din_vld;
input                       din_sop;
input                       din_eop;

input                       clk_out;
output      reg[7:0]        dout;
output      reg             dout_vld;
output      reg             dout_sop;
output      reg             dout_eop;
input                       b_rdy;

reg                         drop_flag;
wire        [9:0]           q;
wire        [9:0]           wrdata;
wire        [9:0]           wrusedw;
myfifo myfifo_inst0(
	.data(wrdata),
	.rdclk(clk_out),
	.rdreq(rdreq),
	.wrclk(clk_in),
	.wrreq(wrreq),
	.q(q),
	.rdempty(rdempty),
	.wrusedw(wrusedw)
);


assign drop_con = din_vld && din_sop && (1000 - wrusedw) < 200;
always  @(posedge clk_in or negedge rst_n)begin
    if(rst_n==1'b0)begin
        drop_flag <= 1'b0;
    end
    else if(drop_con)begin
        drop_flag <= 1'b1;
    end
    else if(din_vld && din_eop)begin
        drop_flag <= 1'b0;
    end
end

assign wrreq = din_vld && ~(drop_flag || drop_con);
assign wrdata = {din_sop , din_eop, din};

assign rdreq = rdempty == 0 && b_rdy;

always  @(posedge clk_out or negedge rst_n)begin
    if(rst_n==1'b0)begin
        dout <= 8'd0;
    end
    else begin
        dout <= q[7:0];
    end
end

always  @(posedge clk_out or negedge rst_n)begin
    if(rst_n==1'b0)begin
        dout_vld <= 1'b0;
    end
    else begin
        dout_vld <= rdreq;
    end
end

always  @(posedge clk_out or negedge rst_n)begin
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


always  @(posedge clk_out or negedge rst_n)begin
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

endmodule
