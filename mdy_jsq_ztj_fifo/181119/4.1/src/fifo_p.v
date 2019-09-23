/*
 * 加头数据 练习1
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
input       [7:0]          din;
input                       din_vld;
input                       din_sop;
input                       din_eop;

output      reg[7:0]       dout;
output      reg             dout_vld;
output      reg             dout_sop;
output      reg             dout_eop;

wire        [9:0]          q;
wire        [9:0]          wrdata;

wire        [7:0]                msg_wrdata;
wire        [7:0]                msg_q;

reg         [7:0]               cnt;
wire                            add_cnt;
wire                            end_cnt;

reg                             sop_flag;
wire                            msg_empty;
wire                            rdreq;

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

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        sop_flag <= 1'b0;
    end
    else if(msg_empty == 0 && sop_flag == 0)begin
        sop_flag <= 1'b1;
    end
    else if(rdreq && q[8])begin
        sop_flag <= 1'b0;
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
assign rdreq = empty == 0 && msg_empty == 0 && sop_flag;

assign msg_wrdata = (cnt + 1);
assign msg_wrreq = end_cnt;
assign msg_rdreq = msg_empty == 0 && (rdreq && q[8]);

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        dout <= 16'd0;
    end
    else if(sop_flag == 1'b0)begin
        dout <= msg_q;
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
        dout_vld <= ((msg_empty == 0 && sop_flag ==0) || rdreq);
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        dout_sop <= 1'b0;
    end
    else if(msg_empty == 0 && sop_flag == 0)begin
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
        dout_eop <= q[8];
    end
    else begin
        dout_eop <= 1'b0;
    end
end

endmodule
