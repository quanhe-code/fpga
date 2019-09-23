/*
 * fifo 阶段2练习7
 */
module fifo_p(
        rst_n,

        clk_a,
        data_a,
        data_a_sop,
        data_a_eop,
        data_a_vld,

        clk_b,
        data_b,
        data_b_sop,
        data_b_eop,
        data_b_mty,
        data_b_vld,

        clk_c,
        data_c,
        data_c_sop,
        data_c_eop,
        data_c_mty,
        data_c_vld,

        clk_d,
        data_d,
        data_d_sop,
        data_d_eop,
        data_d_mty,
        data_d_vld,
        chan_d
);

input                       rst_n;

input                       clk_a;
input       [7:0]           data_a;
input                       data_a_sop;
input                       data_a_eop;
input                       data_a_vld;

input                       clk_b;
input       [15:0]          data_b;
input                       data_b_sop;
input                       data_b_eop;
input                       data_b_mty;
input                       data_b_vld;

input                       clk_c;
input       [31:0]          data_c;
input                       data_c_sop;
input                       data_c_eop;
input       [1:0]           data_c_mty;
input                       data_c_vld;

input                       clk_d;
output      reg[15:0]       data_d;
output      reg             data_d_sop;
output      reg             data_d_eop;
output      reg             data_d_mty;
output      reg             data_d_vld;
output      reg[1:0]        chan_d;

wire                        rdreq_a;
wire                        rdreq_b;
wire                        rdreq_c;

wire        [17:0]          wrdata_a;
wire        [18:0]          wrdata_b;
wire        [35:0]          wrdata_c;

wire        [17:0]          q_a;
wire        [18:0]          q_b;
wire        [35:0]          q_c;

reg                         work_state;
reg         [1:0]           work_sel;
    
reg         [15:0]          data_a_tmp;
reg                         data_a_tmp_sop;
reg                         data_a_tmp_eop;
reg                         data_a_tmp_mty;
reg                         data_a_tmp_vld;


reg                         cnt;
wire                        add_cnt;
wire                        end_cnt;


reg                         cnt1;
wire                        add_cnt1;
wire                        end_cnt1;

reg         [2:0]           x;

wire                        rdempty_a;
wire                        rdempty_b;
wire                        rdempty_c;



fifo0 fifo0_inst(
	.data(wrdata_a),
	.rdclk(clk_d),
	.rdreq(rdreq_a),
	.wrclk(clk_a),
	.wrreq(wrreq_a),
	.q(q_a),
	.rdempty(rdempty_a),
	.wrfull()
);


fifo1 fifo1_inst(
.data(wrdata_b),
	.rdclk(clk_d),
	.rdreq(rdreq_b),
	.wrclk(clk_b),
	.wrreq(wrreq_b),
	.q(q_b),
	.rdempty(rdempty_b),
	.wrfull()
);


fifo2 fifo2_inst(
	.data(wrdata_c),
	.rdclk(clk_d),
	.rdreq(rdreq_c),
	.wrclk(clk_c),
	.wrreq(wrreq_c),
	.q(q_c),
	.rdempty(rdempty_c),
	.wrfull()
);

always @(posedge clk_a or negedge rst_n)begin
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

assign add_cnt = data_a_vld;       
assign end_cnt = add_cnt && ((cnt== (2 - 1)) || data_a_eop);   


always  @(posedge clk_a or negedge rst_n)begin
    if(rst_n==1'b0)begin
        data_a_tmp <= 16'd0;
    end
    else if(data_a_vld)begin
        data_a_tmp <= {data_a, data_a_tmp[15:8]};
    end
end

always  @(posedge clk_a or negedge rst_n)begin
    if(rst_n==1'b0)begin
        data_a_tmp_sop <= 1'b0;
    end
    else if(data_a_sop)begin
        data_a_tmp_sop <= 1'b1;
    end
    else if(data_a_tmp_sop == 1'b1 && data_a_tmp_vld == 1'b1)begin
        data_a_tmp_sop <= 1'b0;
    end
end

always  @(posedge clk_a or negedge rst_n)begin
    if(rst_n==1'b0)begin
        data_a_tmp_eop <= 1'b0;
    end
    else if(data_a_eop)begin
        data_a_tmp_eop <= 1'b1;
    end
    else begin
        data_a_tmp_eop <= 1'b0;
    end
end

 always  @(posedge clk_a or negedge rst_n)begin
     if(rst_n==1'b0)begin
         data_a_tmp_mty <= 1'b0;
     end
     else if(data_a_vld && data_a_eop)begin
         data_a_tmp_mty <= (1 - cnt);
     end
     else begin
         data_a_tmp_mty <= 1'b0;
     end
 end

 always  @(posedge clk_a or negedge rst_n)begin
     if(rst_n==1'b0)begin
         data_a_tmp_vld <= 1'b0;
     end
     else if(end_cnt)begin
         data_a_tmp_vld <= 1'b1;
     end
     else begin
         data_a_tmp_vld <= 1'b0;
     end
 end

assign wrdata_a = {data_a_tmp_sop, data_a_tmp_eop, data_a_tmp};
assign wrreq_a = data_a_tmp_vld;
assign rdreq_a = rdempty_a==0 && (work_state && work_sel == 2'd0);

assign wrdata_b = {data_b_sop, data_b_eop, data_b_mty, data_b};
assign wrreq_b = data_b_vld;
assign rdreq_b = rdempty_b==0 && (work_state && work_sel == 2'd1);

assign wrdata_c = {data_c_sop, data_c_eop, data_c_mty, data_c};
assign wrreq_c = data_c_vld;

always @(posedge clk_d or negedge rst_n)begin
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

assign add_cnt1 = (rdempty_c==0 && (work_state && work_sel == 2'd2));       
assign end_cnt1 = add_cnt1 && (cnt1== (x - 1));   

always  @(*)begin
    if(q_c[34] == 1'b0) begin
        x = 2;
    end
    else begin
        x = (4 - q_c[33:32] + 1) / 2;
    end
end

assign rdreq_c = end_cnt1;

always  @(posedge clk_d or negedge rst_n)begin
    if(rst_n==1'b0)begin
        work_state <= 1'b0;
    end
    else if(work_state == 1'b0 && (rdempty_a == 0 || rdempty_b==0 || rdempty_c==0))begin
        work_state <= 1'b1;
    end
    else if(work_state == 1'b1 && ((rdreq_a && q_a[16]) || (rdreq_b && q_b[17]) || (rdreq_c && q_c[34])))begin
        work_state <= 1'b0;
    end
end

always  @(posedge clk_d or negedge rst_n)begin
    if(rst_n==1'b0)begin
        work_sel <= 2'd0;
    end
    else if(work_state == 0 && (rdempty_a == 0 || rdempty_b==0 || rdempty_c==0))begin
        if(rdempty_a == 0)begin
            work_sel <= 2'd0;
        end
        else if(rdempty_b == 0)begin
            work_sel <= 2'd1;
        end
        else begin
            work_sel <= 2'd2;
        end
    end
end

always  @(posedge clk_d or negedge rst_n)begin
    if(rst_n==1'b0)begin
        data_d <= 15'd0;
    end
    else begin
        if(rdreq_a)begin
            data_d <= q_a[15:0];
        end
        else if(rdreq_b)begin
            data_d <= q_b[15:0];
        end
        else if(add_cnt1)begin
            data_d <= q_c[(16*cnt1) +: 16];
        end
    end
end

always  @(posedge clk_d or negedge rst_n)begin
    if(rst_n==1'b0)begin
        data_d_sop <= 1'b0;
    end
    else begin
        if(rdreq_a)begin
            data_d_sop <= q_a[17];
        end
        else if(rdreq_b)begin
            data_d_sop <= q_b[18];
        end
        else if(add_cnt1 && cnt1 == (1 -1))begin
            data_d_sop <= q_c[35];
        end
        else begin
            data_d_sop <= 1'b0;
        end
    end
end

always  @(posedge clk_d or negedge rst_n)begin
    if(rst_n==1'b0)begin
        data_d_eop <= 1'b0;
    end
    else begin
        if(rdreq_a)begin
            data_d_eop <= q_a[16];
        end
        else if(rdreq_b)begin
            data_d_eop <= q_b[17];
        end
        else if(end_cnt1 && q_c[34])begin
            data_d_eop <= 1'b1;
        end
        else begin
            data_d_eop <= 1'b0;
        end
    end
end

always  @(posedge clk_d or negedge rst_n)begin
    if(rst_n==1'b0)begin
        data_d_vld <= 1'b0;
    end
    else begin
        data_d_vld <= rdreq_a || rdreq_b || add_cnt1;
    end
end

always  @(posedge clk_d or negedge rst_n)begin
    if(rst_n==1'b0)begin
        data_d_mty <= 1'b0;
    end
    else if(rdreq_b) begin
        data_d_mty <= q_b[16];
    end
    else if(end_cnt1 && q_c[34])begin
        data_d_mty <= (2 * x) - (4 - q_c[33:32]);  
    end
    else begin
        data_d_mty <= 1'b0;
    end
end

always  @(posedge clk_d or negedge rst_n)begin
    if(rst_n==1'b0)begin
        chan_d <= 2'd0;
    end
    else if(rdreq_a)begin
        chan_d <= 2'd0;
    end
    else if(rdreq_b)begin
        chan_d <= 2'd1;
    end
    else if(add_cnt1)begin
        chan_d <= 2'd2;
    end
end


endmodule
