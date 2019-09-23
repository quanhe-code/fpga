module smg_shizhong(
    input clk,
    input rst_n,
    output ds_data,
    output ds_shcp,
    output ds_stcp
);

parameter MAX_CNT = 25000000;

wire [15:0]         smg_mul_data;
reg                 smg_mul_update;

reg [24:0]          cnt0;
wire                add_cnt0;
wire                end_cnt0;

reg [3:0]           cnt1;
wire                add_cnt1;
wire                end_cnt1;

reg [3:0]           cnt2;
wire                add_cnt2;
wire                end_cnt2;

reg [3:0]           cnt3;
wire                add_cnt3;
wire                end_cnt3;

reg [3:0]           cnt4;
wire                add_cnt4;
wire                end_cnt4;

smg_zuhe smg_zuhe_1 (
				.clk(clk),
				.rst_n(rst_n),
				.smg_mul_data(smg_mul_data),
				.smg_mul_update(smg_mul_update),
				.ds_data(ds_data),
				.ds_shcp(ds_shcp),
				.ds_stcp(ds_stcp)
);


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
assign end_cnt0 = add_cnt0 && cnt0 == (MAX_CNT - 1);   

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
assign end_cnt2 = add_cnt2 && cnt2== (6 - 1);   

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
assign end_cnt3 = add_cnt3 && cnt3== (10 - 1);   

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
assign end_cnt4 = add_cnt4 && cnt4== (6 - 1);   

assign smg_mul_data[3:0] = cnt1;
assign smg_mul_data[7:4] = cnt2;
assign smg_mul_data[11:8]  = cnt3;
assign smg_mul_data[15:12]  = cnt4;

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        smg_mul_update <= 0;
    end
    else if(end_cnt0)begin
        smg_mul_update <= 1;
    end
    else begin
        smg_mul_update <= 0;
    end
end


endmodule
