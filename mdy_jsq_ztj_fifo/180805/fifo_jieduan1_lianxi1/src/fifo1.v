module fifo_p(
    clk_in              ,
    rst_n               ,
    data_in             ,
    data_in_vld         ,
    clk_out             ,
    data_out            ,
    data_out_vld        ,
    b_rdy               ,
);      

input   wire            clk_in             ; 
input   wire            rst_n              ; 
input   wire [15:0]     data_in            ; 
input   wire            data_in_vld        ; 
input   wire            clk_out            ; 
output  reg  [15:0]     data_out           ; 
output  reg             data_out_vld       ; 
input   wire            b_rdy;

wire            wrreq;
wire [15:0]     q;
wire [5:0]      wrusedw;
wire            rdempty;
wire            rdreq;

myfifo myfifo_inst0(
	.data(data_in),
	.rdclk(clk_out),
	.rdreq(rdreq),
	.wrclk(clk_in),
	.wrreq(wrreq),
	.q(q),
	.rdempty(rdempty),
	.wrfull(),
    .wrusedw(wrusedw)
);

// 当输入数据有效且FIFO数据未写满时，发送写请求
assign wrreq = data_in_vld && (wrusedw < 61);

// 当FIFO有数据存在且下游模块准备好接收数据，发送读请求给FIFO
assign rdreq = (rdempty == 1'b0) && b_rdy;

// 模块输出等于FIFO输出
always  @(posedge clk_out or negedge rst_n)begin
    if(rst_n==1'b0)begin
        data_out <= 16'd0;
    end
    else begin
        data_out <= q; 
    end
end


// 当FIFO读请求有效果，模块输出数据有效
always  @(posedge clk_out or negedge rst_n)begin
    if(rst_n==1'b0)begin
        data_out_vld <= 16'd0;
    end
    else if(rdreq)begin
        data_out_vld <= 1'b1;
    end
    else begin
        data_out_vld <= 1'b0;
    end
end

endmodule       
