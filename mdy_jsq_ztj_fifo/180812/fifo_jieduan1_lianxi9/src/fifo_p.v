/*
 * fifo练习阶段1练习9
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
        dout_mty,
        b_rdy
);

input                   clk;
input                   rst_n;
input   [7:0]           din;
input                   din_vld;
input                   din_sop;
input                   din_eop;
output  reg [15:0]      dout;
output  reg             dout_vld;
output  reg             dout_sop;
output  reg             dout_eop;
output  reg             dout_mty;
input                   b_rdy;

reg [1:0]               cnt;
wire                    add_cnt;
wire                    end_cnt;

reg [15:0]              tmp_data;
reg                     tmp_data_vld;
reg                     tmp_data_sop;
reg                     tmp_data_eop;
reg                     tmp_data_mty;

wire                    empty;
wire[18:0]              q;
wire[18:0]              wrdata;


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
assign end_cnt = add_cnt && (cnt== (2 - 1) || din_eop);   

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        tmp_data <= 16'h00;
    end
    else if(add_cnt)begin
        tmp_data <= {din, tmp_data[15:8]};
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        tmp_data_sop <= 1'b0;
    end
    else if(din_sop)begin
        tmp_data_sop <= 1'b1;
    end
    else if(tmp_data_sop && tmp_data_vld)begin
        tmp_data_sop <= 1'b0;
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        tmp_data_eop <= 1'b0;
    end
    else if(end_cnt && din_eop)begin
        tmp_data_eop <= 1'b1;
    end
    else begin
        tmp_data_eop <= 1'b0;
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        tmp_data_mty <= 1'b0;
    end
    else if(end_cnt && din_eop)begin
        tmp_data_mty <= (2 - cnt);
    end
    else begin
        tmp_data_mty <= 1'b0;
    end
end

assign  wrdata = {tmp_data_sop, tmp_data_eop, tmp_data_mty, tmp_data};

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        tmp_data_vld <= 1'b0;
    end
    else if(end_cnt)begin
        tmp_data_vld <= 1'b1;
    end
    else begin
        tmp_data_vld <= 1'b0;
    end
end
assign  wrreq = tmp_data_vld;

assign rdreq = (empty == 1'b0 && b_rdy == 1'b1);

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        dout <= 16'h0000;
    end
    else begin
        dout <= q[15:0];
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
        dout_sop <= q[18];
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
        dout_eop <= q[17];
    end
    else begin
        dout_eop <= 1'b0;
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        dout_mty <= 1'b0;
    end
    else if(rdreq)begin
        dout_mty <= q[16];
    end
    else begin
        dout_mty <= 1'b0;
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
