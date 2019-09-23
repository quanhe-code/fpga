module da_sj(
        input       clk,
        input       rst_n,
        output reg          cs,
        output reg          wr,
        output reg [7:0]    dout
);


parameter   MAX_CNT = 7313; //T = 40ns

reg [12:0]          cnt0;
wire                add_cnt0;
wire                end_cnt0;
reg [7:0]           cnt1;
wire                add_cnt1;
wire                end_cnt1;

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        cs <= 1;
    end
    else begin
        cs <= 0;
    end
end

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

assign add_cnt0 = (rst_n == 1);
assign end_cnt0 = add_cnt0 && cnt0== (MAX_CNT - 1);

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
assign end_cnt1 = add_cnt1 && cnt1== (256 - 1);

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        cs <= 1;
    end
    else begin
        cs <= 0;
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        wr <= 1;
    end
    else if(end_cnt0)begin
        wr <= 0;
    end
    else if(add_cnt0 && cnt0 == (3 - 1))begin
        wr <= 1;
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        dout <= 0;
    end
    else if(end_cnt0)begin
        dout <= cnt1;
    end
end



endmodule
