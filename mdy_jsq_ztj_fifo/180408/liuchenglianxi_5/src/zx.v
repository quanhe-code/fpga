//
module zx (
        input clk,
        input rst_n,
        output reg      cs,
        output reg      wr,
        output [7:0] dout
);

parameter MAX_CNT = 97;

reg     [7:0]       cnt0;
wire                add_cnt0;
wire                end_cnt0;

reg     [5:0]       cnt1;
wire                add_cnt1;
wire                end_cnt1;

reg     [7:0]       cnt2;
wire                add_cnt2;
wire                end_cnt2;

reg     [5:0]       cnt3;
wire                add_cnt3;
wire                end_cnt3;


reg     [4:0]       cnt4;
wire                add_cnt4;
wire                end_cnt4;

wire [7:0]          addr;
reg  [5:0]          x;

reg     [3:0]       cnt5;
wire                add_cnt5;
wire                end_cnt5;
reg                 flag_add;

sin_rom inst_sin_rom_1(
	.address(addr),
	.clock(clk),
	.q(dout)
);
assign addr = cnt2;

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
assign end_cnt0 = add_cnt0 && cnt0== (MAX_CNT - 1); // 3900ns 

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
assign end_cnt1 = add_cnt1 && cnt1== (x - 1); // 多少个3900ns开始变化

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

assign add_cnt2 = end_cnt1;
assign end_cnt2 = add_cnt2 && cnt2== (128 - 1);  //   需要多少次把MF文件传输完成
 
always @(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        cnt3 <= 0;
    end
    else if(add_cnt3)begin
        if(end_cnt3)
            cnt3 <= 0;
        else
            cnt3 <= cnt3 + 1;
    end
end

assign add_cnt3 = end_cnt2;       
assign end_cnt3 = add_cnt3 && cnt3== (20 - 1);// 重复20次   

always @(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        cnt4 <= 0;
    end
    else if(add_cnt4)begin
        if(end_cnt4)
            cnt4 <= 0;
        else
            cnt4 <= cnt4 + 1;
    end
end

assign add_cnt4 = end_cnt3;       
assign end_cnt4 = add_cnt4 && cnt4== (3 - 1); // 分为三个阶段  

always @(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        cnt5 <= 0;
    end
    else if(add_cnt5)begin
        if(end_cnt5)
            cnt5 <= 0;
        else
            cnt5 <= cnt5 + 1;
    end
end

assign add_cnt5 = flag_add;       
assign end_cnt5 = add_cnt5 && cnt5== (5 - 1);   

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        flag_add <= 0;
    end
    else if(end_cnt1)begin
        flag_add <= 1;
    end
    else if(end_cnt5)begin
        flag_add <= 0;
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        wr <= 1;
    end
    else if(add_cnt5 && cnt5==(2 - 1))begin
        wr <= 0;
    end
    else if(end_cnt5)begin
        wr <= 1;
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        cs <= 1;
    end
    else begin
        cs <= 0;
    end
end

always  @(*)begin
    if(cnt4 == (1 - 1))
        x = 4;
    else if(cnt4 == (2 - 1))
        x = 1;
    else
        x = 20;
end

endmodule
