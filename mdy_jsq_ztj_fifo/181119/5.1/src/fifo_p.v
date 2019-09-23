/*
 * 加包文 练习1
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
    dout_eop
);

input                       clk;
input                       rst_n;
input       [31:0]          din;
input                       din_vld;
input                       din_sop;
input                       din_eop;
input       [1:0]           din_mty;

output      reg[7:0]        dout;
output      reg             dout_vld;
output      reg             dout_sop;
output      reg             dout_eop;

reg         [2:0]           cnt0;
wire                        add_cnt0;
wire                        end_cnt0;

reg         [1:0]           cnt1;
wire                        add_cnt1;
wire                        end_cnt1;

reg         [1:0]           cnt2;
wire                        add_cnt2;
wire                        end_cnt2;

reg         [7:0]           pack_id;

wire        [35:0]          wrdata;
wire        [35:0]          q;

wire        [47:0]          head_packet;
wire        [47:0]          tail_packet;
reg         [2:0]                x;

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
	.data(),
	.rdreq(msg_rdreq),
	.wrreq(msg_wrreq),
	.empty(msg_empty),
	.q()
);

assign wrdata = {din_sop, din_eop, din_mty, din};
assign wrreq = din_vld;
assign rdreq = end_cnt2;

assign msg_wrreq = din_vld && din_eop;
assign msg_rdreq = end_cnt1;

always @(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        cnt0 <= 0;
    end
    else if(add_cnt0)begin
        if(end_cnt0)
            cnt0 <= 0;
        else
            cnt0 <= cnt0 + 1;
    end
end

assign add_cnt0 = (cnt1 == 0 || cnt1 == 2) && msg_empty == 0;       
assign end_cnt0 = add_cnt0 && cnt0== (6 - 1);   

always @(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        cnt1 <= 0;
    end
    else if(add_cnt1)begin
        if(end_cnt1)
            cnt1 <= 0;
        else
            cnt1 <= cnt1 + 1;
    end
end

assign add_cnt1 = (end_cnt0 || (rdreq && q[34]));       
assign end_cnt1 = add_cnt1 && cnt1== (3 - 1);   

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        pack_id <= 8'd0;
    end
    else if(end_cnt1)begin
        pack_id <= pack_id + 1;
    end
end

assign head_packet = {pack_id, 8'hd5, 8'hd5, 8'h55, 8'h55, 8'h55};
assign tail_packet = {pack_id, 8'hfd, 8'hfd, 8'h55, 8'h55, 8'h55};

always @(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        cnt2 <= 0;
    end
    else if(add_cnt2)begin
        if(end_cnt2)
            cnt2 <= 0;
        else
            cnt2 <= cnt2 + 1;
    end
end

assign add_cnt2 = (cnt1 == 1 && empty == 0);       
assign end_cnt2 = add_cnt2 && (cnt2== (x - 1));   
always  @(*)begin
    if(q[34]) begin
        x = (4 - q[33:32]);
    end
    else begin
        x = 4;
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        dout <= 8'd0;
    end
    else if(add_cnt0 && cnt1 == 0)begin
        dout <= head_packet[(cnt0*8) +: 8];
    end
    else if(cnt1 == 1)begin
        dout <= q[(cnt2*8) +: 8];
    end
    else if(add_cnt0 && cnt1 == 2)begin
        dout <= tail_packet[(cnt0*8) +: 8];
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        dout_vld <= 1'b0;
    end
    else if(cnt1 == 0 && add_cnt0)begin
        dout_vld <= 1'b1;
    end
    else if(cnt1 == 1 && add_cnt2)begin
        dout_vld <= 1'b1;
    end
    else if(cnt1 == 2 && add_cnt0)begin
        dout_vld <= 1'b1;
    end
    else begin
        dout_vld <= 1'b0;
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        dout_sop <= 1'b0;
    end
    else if(cnt1 == 0 && add_cnt0 && cnt0 == (1 - 1))begin
        dout_sop <= 1'b1;
    end
    else if(cnt1 == 1 && add_cnt2 && cnt2 == (1 - 1) && q[35])begin
        dout_sop <= 1'b1;
    end
    else if(cnt1 == 2 && add_cnt0 && cnt0 == (1 - 1))begin
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
    else if(cnt1 == 0 && end_cnt0)begin
        dout_eop <= 1'b1;
    end
    else if(cnt1 == 1 && end_cnt2 && q[34])begin
        dout_eop <= 1'b1;
    end
    else if(cnt1 == 2 && end_cnt0)begin
        dout_eop <= 1'b1;
    end
    else begin
        dout_eop <= 1'b0;
    end
end

endmodule
