
module smg_zuhe (
				input			clk,
				input			rst_n,
				input [15:0]	smg_mul_data,
				input			smg_mul_update,
				output			ds_data,
				output			ds_shcp,
				output			ds_stcp
);

parameter   MAX_CNT = 25000;

reg [1:0]		smg_no;
reg [3:0]		smg_data;
reg				smg_update;

reg [24:0]      cnt0;
wire            add_cnt0;
wire            end_cnt0;

reg             cnt1;
wire            add_cnt1;
wire            end_cnt1;

reg [1:0]       cnt2;
wire            add_cnt2;
wire            end_cnt2;

reg             flag_add;
reg [3:0]       x;

smg_interface smg_interface_1(
    .clk(clk),
    .rst_n(rst_n),
	.smg_no(smg_no),
	.smg_data(smg_data),
    .smg_update(smg_update),
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
assign end_cnt1 = add_cnt1 && cnt1== (2 - 1);

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
assign end_cnt2 = add_cnt2 && cnt2== (4 - 1);

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        smg_no <= 0;
    end
    else if(add_cnt1 && cnt1 == (1 - 1))begin
        smg_no <= cnt2;
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        smg_data <= 0;
    end
    else if(add_cnt1 && cnt1 == (1 - 1))begin
        smg_data <= x;
    end
end

always  @(*)begin
    if(cnt2 == 0)
        x = smg_mul_data[3:0];
    else if(cnt2 == 1)
        x = smg_mul_data[7:4];
    else if(cnt2 == 2)
        x = smg_mul_data[11:8];
    else
        x = smg_mul_data[15:12];
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        smg_update <= 0;
    end
    else if(add_cnt1 && cnt1 == (1 -1))begin
        smg_update <= 1;
    end
    else begin
        smg_update <= 0;
    end
end

endmodule
