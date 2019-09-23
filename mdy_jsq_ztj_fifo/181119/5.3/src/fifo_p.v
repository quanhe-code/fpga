/*
 * 加包文 练习3
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
input       [7:0]           din;
input                       din_vld;
input                       din_sop;
input                       din_eop;

output      reg[7:0]        dout;
output      reg             dout_vld;
output      reg             dout_sop;
output      reg             dout_eop;

reg         [15:0]          cnt0;
wire                        add_cnt0;
wire                        end_cnt0;

reg         [15:0]          cnt1;
wire                        add_cnt1;
wire                        end_cnt1;

reg         [15:0]          cnt;
wire                        add_cnt;
wire                        end_cnt;

reg         [7:0]           pack_id;

wire        [7:0]           wrdata;
wire        [7:0]           q;

wire        [15:0]          msg_wrdata;
wire        [15:0]          msg_q;
wire                        msg_rdreq;
wire                        msg_empty;

reg         [15:0]           x;
reg         [15:0]           y;

wire        [15:0]           nn;
wire        [15:0]           mm;

reg                         flag_zero;


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

assign add_cnt = (din_vld);       
assign end_cnt = add_cnt && (din_vld && din_eop);

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

assign wrdata = din;
assign wrreq = din_vld;
assign rdreq = ((empty==0 && msg_empty == 0) && flag_zero == 0);

assign msg_wrdata = (cnt + 1);
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

assign add_cnt0 = (rdreq || flag_zero);       
assign end_cnt0 = add_cnt0 && cnt0== (x - 1);   

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

assign add_cnt1 = end_cnt0;       
assign end_cnt1 = add_cnt1 && cnt1 == (y - 1);   


always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        flag_zero <= 1'b0;
    end
     else if((mm > 0 || mm < (x - 1)) && cnt1 == (y - 1) && add_cnt0 && cnt0 == (mm - 1))begin
        flag_zero <= 1'b1;
    end
    else if(end_cnt0)begin
        flag_zero <= 1'b0;
    end
   
end

assign nn = (msg_q + 1499)/ 1500;
assign mm = (msg_q % 1500);

always  @(*)begin
    y = nn;

    if(mm == 0) begin
        x = 1500;
    end
    else begin
        if(cnt1 < (y - 1)) begin
            x = 1500;
        end
        else begin
            x = mm > 46 ? mm : 46;
        end
    end

end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        dout <= 8'd0;
    end
    else if(flag_zero)begin
        dout <= 8'd0;
    end
    else begin
        dout <= q[7:0];
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        dout_vld <= 8'd0;
    end
    else begin
        dout_vld <= add_cnt0;
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        dout_sop <= 1'b1;
    end
    else if(add_cnt0 && cnt0 == (1 - 1))begin
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
    else if(end_cnt0)begin
        dout_eop <= 1'b1;
    end
    else begin
        dout_eop <= 1'b0;
    end
end

/*
 * 潘老师采用在写侧既切割包文，然后在写入FIFO，然后在读侧作进一步处理
 assign wdata = {din_sop, din_eop, din};
 assign wr_en = din_vld;

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
 assign end_cnt = add_cnt && (cnt==(1500 - 1) || din_eop);   

 assign msg_wdata = (cnt + 1);
 assign msg_wr_en = end_cnt;

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

 assign add_cnt1 = msg_empty==0;       
 assign end_cnt1 = add_cnt1 && cnt1== (x - 1);   

 always  @(*)begin
     if(msg_q < 46)
         x = 46;
     else
         x = msg_q;
 end

 assign zero_n = add_cnt1 && cnt1 < msg_q;
 assign rd_en = add_cnt1 && zero_n == 1;

 assign msg_rd_en = end_cnt1;

 */
 

endmodule
