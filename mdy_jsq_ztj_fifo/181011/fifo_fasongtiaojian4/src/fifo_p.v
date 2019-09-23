/*
 * fifo 阶段2练习4
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
        dout_mty,
        dout_vld
);

input                       clk;
input                       rst_n;

input   [7:0]               din;
input                       din_sop;
input                       din_eop;
input                       din_vld;

output  reg[31:0]           dout;
output  reg                 dout_sop;
output  reg                 dout_eop;
output  reg[1:0]            dout_mty;
output  reg                 dout_vld;

wire    [7:0]               usedw;
wire                        empty;
wire    [35:0]              q;
reg                         send_state;
wire    [35:0]              wrdata;

reg     [3:0]               cnt;
wire                        add_cnt;
wire                        end_cnt;

reg     [31:0]              tmp_dout;
reg                         tmp_dout_sop;
reg                         tmp_dout_eop;
reg     [1:0]               tmp_dout_mty;
reg                         tmp_dout_vld;


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
assign end_cnt = add_cnt && (cnt== (4 - 1) || din_eop);   


always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        tmp_dout <= 32'h00000000;
    end
    else if(din_vld) begin
        tmp_dout <= {din, tmp_dout[31:8]};
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        tmp_dout_sop <= 1'b0;
    end
    else if(din_vld && din_sop)begin
        tmp_dout_sop <= 1'b1;
    end
    else if(tmp_dout_sop && tmp_dout_vld)begin
        tmp_dout_sop <= 1'b0;
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        tmp_dout_eop <= 1'b0;
    end
    else if(end_cnt && din_eop)begin
        tmp_dout_eop <= 1'b1;
    end
    else begin
        tmp_dout_eop <= 1'b0;
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        tmp_dout_mty <= 2'd0;
    end
    else if(end_cnt && din_eop)begin
        tmp_dout_mty <= (2'd3 - cnt);
    end
    else begin
        tmp_dout_mty <= 2'd0;
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        tmp_dout_vld <= 1'b0;
    end
    else if(end_cnt)begin
        tmp_dout_vld <= 1'b1;
    end
    else begin
        tmp_dout_vld <= 1'b0;
    end
end

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
	.rdreq(msg_rdreq),
	.wrreq(msg_wrreq),
	.empty(msg_empty),
	.full(),
	.q(),
	.usedw()
);

assign msg_wrreq=tmp_dout_vld && tmp_dout_eop;
assign msg_rdreq= (msg_empty == 0) && rdreq && q[34];

assign wrdata = {tmp_dout_sop, tmp_dout_eop, tmp_dout_mty, tmp_dout};
assign wrreq = tmp_dout_vld;

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        send_state <= 1'b0;
    end
    else if(send_state == 1'b0 && (usedw > 240 || msg_empty == 0))begin
        send_state <= 1'b1;
    end
    else if(send_state == 1'b1 && msg_rdreq)begin  // 数据读到EOP就停止
        send_state <= 1'b0;
    end
end

assign rdreq = (empty == 0) && send_state;

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        dout <= 8'h0;
    end
    else begin
        dout <= q[31:0];
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        dout_sop <= 1'b0;
    end
    else if(rdreq)begin
        dout_sop <= q[35];
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
        dout_eop <= q[34];
    end
    else begin
        dout_eop <= 1'b0;
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        dout_mty <= 2'b0;
    end
    else if(rdreq && q[34])begin
        dout_mty <= q[33:32];
    end
    else begin
        dout_mty <= 2'b0;
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
