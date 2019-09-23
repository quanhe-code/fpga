/*
 * fifo练习阶段1练习5
 */
module fifo_p(
        clk_in,
        rst_n,
        data_in,
        data_in_vld,
        clk_out,
        data_out,
        data_out_vld,
        b_rdy
);

input               clk_in;
input               rst_n;
input  [7:0]        data_in;
input               data_in_vld;
input               clk_out;
output [31:0]       data_out;
output              data_out_vld;
input               b_rdy;

reg  [31:0]         reg_data_out;
reg                 reg_data_out_vld;

reg  [31:0]         wrdata;
wire                wrreq;
wire [31:0]         q;
wire [5:0]          wrusedw;
wire                rdempty;

reg                 wrdata_vld;
wire                clk;
reg  [2:0]          cnt;
wire                add_cnt;
wire                end_cnt;

assign clk = clk_in;
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

assign add_cnt = (data_in_vld == 1'b1);       
assign end_cnt = add_cnt && cnt== (4 - 1);   

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        wrdata <= 32'h00000000;
    end
    else if(data_in_vld) begin
        wrdata <= {data_in, wrdata[31:8]};
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        wrdata_vld <= 1'b0;
    end
    else begin
        wrdata_vld <= end_cnt;
    end
end

assign wrreq = (wrdata_vld && wrusedw < 61);

myfifo myfifo_inst0(
	.data(wrdata),
	.rdclk(clk_out),
	.rdreq(rdreq),
	.wrclk(clk_in),
	.wrreq(wrreq),
	.q(q),
	.rdempty(rdempty),
	.wrfull(),
	.wrusedw(wrusedw)
);

// 
assign rdreq = (rdempty == 1'b0 && b_rdy == 1'b1);

always  @(posedge clk_out or negedge rst_n)begin
    if(rst_n==1'b0)begin
        reg_data_out <= 32'h00000000;
    end
    else begin
        reg_data_out<= q;
    end
end
assign data_out = reg_data_out;

always  @(posedge clk_out or negedge rst_n)begin
    if(rst_n==1'b0)begin
        reg_data_out_vld <= 1'b0;
    end
    else begin
        reg_data_out_vld <= rdreq;
    end
end
assign data_out_vld = reg_data_out_vld;

endmodule
