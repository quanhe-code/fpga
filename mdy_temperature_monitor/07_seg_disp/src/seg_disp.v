module  seg_disp(rst_n       ,
                 clk         ,
                 disp_en     ,
                 din         ,
                 din_vld     ,
                 ds_data,
                 ds_shcp,
                 ds_stcp
             );


parameter SECOND_CNT = 500000; //20 ms
parameter MAX_SMG_NUM = 4;
parameter HC595_CLK_CNT = 25;
input                                   clk;
input                                   rst_n;
input                                   disp_en;
input  [((MAX_SMG_NUM*4) - 1):0]        din;
input  [(MAX_SMG_NUM - 1):0]            din_vld;

output  reg                                ds_data;
output  reg                                ds_shcp;
output  reg                                ds_stcp;

reg  [((MAX_SMG_NUM*4) - 1):0]          din_tmp;
reg  [(MAX_SMG_NUM - 1):0]              din_vld_tmp;
reg  [3:0]                              cnt_vld;
wire                                    add_cnt_vld;
wire                                    end_cnt_vld;
reg                                     flag_add_vld;

reg  [18:0]             cnt0;
wire                    add_cnt0;
wire                    end_cnt0;

reg  [3:0]              cnt1;
wire                    add_cnt1;
wire                    end_cnt1;

reg  [3:0]              smg_no;
reg  [3:0]              smg_data;
reg                     smg_vld;
reg  [3:0]              smg_select;
reg  [15:0]             shift_data;

wire [4:0]           pos;

reg  [5:0]              cnt2;
wire                    add_cnt2;
wire                    end_cnt2;
reg                     flag_add2;

reg  [4:0]              cnt3;
wire                    add_cnt3;
wire                    end_cnt3;

always @(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        cnt_vld <= 0;
    end
    else if(add_cnt_vld)begin
        if(end_cnt_vld)
            cnt_vld <= 0;
        else
            cnt_vld <= cnt_vld + 1;
    end
end

assign add_cnt_vld = (flag_add_vld == 1'b1);       
assign end_cnt_vld = add_cnt_vld && cnt_vld== (MAX_SMG_NUM - 1);  

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        din_vld_tmp <= 8'h0;
    end
    else if(din_vld != 0)begin
        din_vld_tmp <= din_vld;
    end
    else if(end_cnt_vld) begin
        din_vld_tmp <= 8'h00;
    end
end


always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        flag_add_vld <= 1'b0;
    end
    else if(din_vld != 0)begin
        flag_add_vld <= 1'b1;
    end
    else if(end_cnt_vld)begin
        flag_add_vld <= 1'b0;
    end
end

assign pos = (cnt_vld * 4);
always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        din_tmp <= 0;
    end
    else if(add_cnt_vld && din_vld_tmp[cnt_vld] == 1'b1)begin
        din_tmp[pos +: 4] <= din[pos +: 4];
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
assign end_cnt0 = add_cnt0 && cnt0== (SECOND_CNT - 1);

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
assign end_cnt1 = add_cnt1 && cnt1== (MAX_SMG_NUM - 1);


always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        smg_no <= 0;
    end
    else if(end_cnt0)begin
        smg_no <= cnt1;
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        smg_data <= 0;
    end
    else if(end_cnt0)begin
        smg_data <= din_tmp[(cnt1 * 4) +: 4];
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        smg_vld <= 0;
    end
    else if(end_cnt0)begin
        smg_vld <= 1;
    end
    else begin
        smg_vld <= 0;
    end
end

// ��֯��λ����
always  @(*)begin
    if(disp_en == 1'b0) begin
        smg_select = 4'hf;
    end
    else begin
        smg_select = (4'hf & (~(1<<smg_no)));
    end
end

always  @(*)begin
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
        cnt2 <= 0;
    end
    else if(add_cnt2)begin
        if(end_cnt2)
            cnt2 <= 0;
        else
            cnt2 <= cnt2 + 1;
    end
end

assign add_cnt2 = (flag_add2 == 1'b1);       
assign end_cnt2 = add_cnt2 && cnt2== (HC595_CLK_CNT - 1);   

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
assign end_cnt3 = add_cnt3 && cnt3== (16 - 1);   

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        flag_add2 <= 1'b0;
    end
    else if(smg_vld == 1'b1)begin
        flag_add2 <= 1'b1;
    end
    else if(end_cnt3)begin
        flag_add2 <= 1'b0;
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        ds_shcp <= 1'b0;
    end
    else if(add_cnt2 && cnt2 == (HC595_CLK_CNT/2))begin
        ds_shcp <=  1'b1;
    end
    else if(end_cnt2)begin
        ds_shcp <= 1'b0;   
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        ds_data <= 0;
    end
    else if(add_cnt2 && cnt2 == (HC595_CLK_CNT/4))begin
        ds_data <= shift_data[15 - cnt3];
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        ds_stcp <= 0;
    end
    else if(end_cnt3)begin
        ds_stcp <= 1;
    end
    else if(end_cnt2 && cnt3 == (1 - 1))begin
        ds_stcp <= 0;
    end
end

endmodule
