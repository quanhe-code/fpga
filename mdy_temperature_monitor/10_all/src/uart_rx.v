module uart_rx(
                 clk,
                 rst_n,
                 din,
                 dout,
                 dout_vld
             );

parameter          CNT_MAX = 2604; 
parameter          DATA_W = 8;

input               clk          ;		
input               rst_n        ;	
input               din          ;
output reg  [DATA_W-1:0]  dout         ;		
output reg             dout_vld     ;


reg                 din0;
reg                 din1;
reg                 din2;

reg  [31:0]         cnt0;
wire                add_cnt0;
wire                end_cnt0;

reg  [3:0]          cnt1;
wire                add_cnt1;
wire                end_cnt1;

reg                 flag_rx;
wire                rx_start;

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        din0 <= 1'b0;
        din1 <= 1'b0;
        din2 <= 1'b0;
    end
    else begin
        din0 <= din;
        din1 <= din0;
        din2 <= din1;
    end
end

assign rx_start = din2 & (~din1);// 检测到起始信号 

always @(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
     cnt0 <= 0;
 end
 else if(add_cnt0)begin
     if(end_cnt0)
        cnt0 <= 0;
   else
      cnt0 <= cnt0 + 1'b1;
 end
end

assign add_cnt0 = (flag_rx == 1'b1);
assign end_cnt0 = add_cnt0 && cnt0== (CNT_MAX - 1);

always @(posedge clk or negedge rst_n)begin 
    if(!rst_n)begin
        cnt1 <= 0;
    end
    else if(add_cnt1)begin
        if(end_cnt1)
            cnt1 <= 0;
        else
            cnt1 <= cnt1 + 1'b1;
    end
end

assign add_cnt1 = end_cnt0;
assign end_cnt1 = add_cnt1 && cnt1== (9 - 1);

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        flag_rx <= 1'b0;
    end
    else if(rx_start == 1'b1)begin
        flag_rx <= 1'b1;
    end
    else if(end_cnt1)begin
        flag_rx <= 1'b0;
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        dout <= 8'h00;
    end
    else if((cnt1 > 0) && add_cnt0 && cnt0 == ((CNT_MAX / 2) - 1))begin
        dout <= {din, dout[7:1]};
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        dout_vld <= 1'b0;
    end
    else if(cnt1 == (9 - 1) && add_cnt0 && cnt0 == ((CNT_MAX / 2) - 1))begin
        dout_vld <= 1'b1;
    end
    else begin
        dout_vld <= 1'b0;
    end
end

endmodule

