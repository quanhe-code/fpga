module uart_tx(
                 clk,
                 rst_n,
                 din,
                 din_vld,
                 rdy,
                 dout
             );

parameter         DATA_W = 8;
parameter       CNT_MAX = 2604;

input             clk;			
input             rst_n;		
input[DATA_W-1:0] din;
input             din_vld;	
output             rdy;
output            dout;

reg                 rdy_t;
reg  [11:0]         cnt0;
wire                add_cnt0;
wire                end_cnt0;

reg  [3:0]          cnt1;
wire                add_cnt1;
wire                end_cnt1;

reg                 flag_add;
reg  [9:0]          tx_data;

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

assign add_cnt0 = (flag_add == 1'b1);
assign end_cnt0 = add_cnt0 && cnt0== (CNT_MAX - 1);

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
assign end_cnt1 = add_cnt1 && cnt1== (10 - 1);

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        flag_add <= 1'b0;
    end
    else if(din_vld == 1'b1)begin
        flag_add <= 1'b1;
    end
    else if(end_cnt1)begin
        flag_add <= 1'b0;
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        tx_data <= 0;
    end
    else if(din_vld)begin
        tx_data <= {1'b1, din[7:0], 1'b0};
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        rdy_t <= 1'b0;
    end
    else if(din_vld)begin
        rdy_t <= 1'b1;
    end
    else if(end_cnt1)begin
        rdy_t <= 1'b0;
    end
end

assign rdy = ~(rdy_t | din_vld);

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        dout <= 1'b1;
    end
    else if(add_cnt0 && (cnt0 == 1))begin
        dout <= tx_data[cnt1];
    end
end



endmodule
