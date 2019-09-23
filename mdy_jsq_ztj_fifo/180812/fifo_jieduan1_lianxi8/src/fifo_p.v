/*
 * fifo练习阶段1练习8
 */
module fifo_p(
        clk,
        rst_n,
        din,
        din_vld,
        din_sop,
        din_eop,
        din_mty,
        dout,
        dout_vld,
        dout_sop,
        dout_eop,
        b_rdy
);

input                   clk;
input                   rst_n;
input   [31:0]          din;
input                   din_vld;
input                   din_sop;
input                   din_eop;
input   [1:0]           din_mty;
output  reg [7:0]       dout;
output  reg             dout_vld;
output  reg             dout_sop;
output  reg             dout_eop;
input                   b_rdy;

wire[35:0]              wrdata;
reg [1:0]               cnt;
wire                    add_cnt;
wire                    end_cnt;
wire                    empty;
reg [2:0]               x;
wire[35:0]              q;



assign  wrdata = {din_sop, din_eop, din_mty, din};

assign  wrreq = din_vld;

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

assign add_cnt = (empty == 1'b0 && b_rdy == 1'b1);       
assign end_cnt = add_cnt && cnt== (x - 1);   

always  @(*)begin
    if(q[34] == 1'b1) begin
        x = 4 - q[33:32];
    end
    else begin
        x = 4;
    end
end

assign rdreq = end_cnt;

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        dout <= 8'h00;
    end
    else begin
        dout <= q[(8*cnt) +: 8];
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
       dout_vld <= 1'b0;
    end
    else begin
       dout_vld <=  add_cnt;
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        dout_sop <= 1'b0;
    end
    else if(q[35] == 1'b1 && add_cnt && cnt == (1 - 1))begin
        dout_sop <= 1'b1;
    end
    else begin
        dout_sop <= 1'b0;
    end
end


always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        dout_eop <= 1'b0;
    end
    else if(q[34] == 1'b1 && end_cnt)begin
        dout_eop <= 1'b1;
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
