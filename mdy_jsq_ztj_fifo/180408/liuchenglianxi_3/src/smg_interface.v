module smg_interface(
    input clk,
    input rst_n,
	input [1:0] smg_no,
	input [3:0] smg_data,
    input smg_update,
	output reg ds_data,
	output reg ds_shcp,
	output reg ds_stcp
);

parameter clk_cnt = 24;

reg [15:0] shift_data;


reg [14:0]  cnt0;
wire add_cnt0;
wire end_cnt0;
reg         flag_add;

reg [5:0]   cnt1;
wire add_cnt1;
wire end_cnt1;

wire [3:0] smg_select;

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
    end
    else begin
    end
end

assign smg_select = (4'hf & (~(1 << (3 - smg_no))));

always  @(posedge clk or negedge rst_n)begin
    if(rst_n == 1'b0)begin
        shift_data <= 0;
    end
    else begin
		case (smg_data)
			4'h0: shift_data <= (7'h3f<<8) | smg_select;
			4'h1: shift_data <= (7'h06<<8) | smg_select;
			4'h2: shift_data <= (7'h5b<<8) | smg_select;
			4'h3: shift_data <= (7'h4f<<8) | smg_select;
			4'h4: shift_data <= (7'h66<<8) | smg_select;
			4'h5: shift_data <= (7'h6d<<8) | smg_select;
			4'h6: shift_data <= (7'h7d<<8) | smg_select;
			4'h7: shift_data <= (7'h07<<8) | smg_select;
			4'h8: shift_data <= (7'h7f<<8) | smg_select;
			4'h9: shift_data <= (7'h6f<<8) | smg_select;
			4'ha: shift_data <= (7'h77<<8) | smg_select;
			4'hb: shift_data <= (7'h7c<<8) | smg_select;
			4'hc: shift_data <= (7'h39<<8) | smg_select;
			4'hd: shift_data <= (7'h5e<<8) | smg_select;
			4'he: shift_data <= (7'h79<<8) | smg_select;
			4'hf: shift_data <= (7'h71<<8) | smg_select;
			default:;
		endcase
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

assign add_cnt0 = (flag_add == 1);
assign end_cnt0 = add_cnt0 && cnt0== (clk_cnt - 1);

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
assign end_cnt1 = add_cnt1 && cnt1== (16 - 1);

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        flag_add <= 0;
    end
    else if(smg_update == 1)begin
        flag_add <= 1;
    end
    else if(end_cnt1)begin
        flag_add <= 0;
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        ds_shcp <= 1'b0;
    end
    else if(add_cnt0 && cnt0 == (clk_cnt/2))begin
        ds_shcp <=  1'b1;
    end
    else if(end_cnt0)begin
        ds_shcp <= 1'b0;   
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        ds_data <= 0;
    end
    else if(add_cnt0 && cnt0 == (clk_cnt/4))begin
        ds_data <= shift_data[15 - cnt1];
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        ds_stcp <= 0;
    end
    else if(end_cnt1)begin
        ds_stcp <= 1;
    end
    else if(end_cnt0 && cnt1 == (1 - 1))begin
        ds_stcp <= 0;
    end
end

endmodule
