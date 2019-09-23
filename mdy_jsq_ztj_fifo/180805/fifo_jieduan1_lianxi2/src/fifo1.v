/*
 * fifo阶段1练习2
 */
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
output  reg  [7:0]     data_out           ; 
output  reg             data_out_vld       ; 
input   wire            b_rdy;

wire            wrreq;
wire [15:0]     q;
wire [5:0]      wrusedw;
wire            rdempty;
wire            rdreq;
wire            clk;
reg  [1:0]      cnt;
wire            add_cnt;
wire            end_cnt;
wire [15:0]     wrdata;

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

assign wrdata = data_in;

// 当输入数据有效且FIFO数据未写满时，发送写请求
assign wrreq = data_in_vld && (wrusedw < 61);


// 分两次读取数据
assign clk = clk_out;
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

assign add_cnt = (rdempty == 1'b0 && b_rdy == 1'b1);       
assign end_cnt = add_cnt && cnt== (2 - 1);   

// 准备读最后一个数据时发送读请求，保证读完最后一个数据的同时FIFO数据输出写更新
assign rdreq = end_cnt;


always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        data_out <= 8'h00;
    end
    else if(add_cnt) begin
        data_out <= q[(8*cnt) +: 8];
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        data_out_vld <= 1'b0;
    end
    else begin
        data_out_vld <= add_cnt;
    end
end


endmodule       
