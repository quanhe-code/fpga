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
        data_b_vld,

        clk_c,
        data_c,
        data_c_sop,
        data_c_eop,
        data_c_vld,

        clk_d,
        data_d,
        data_d_sop,
        data_d_eop,
        data_d_vld,
        chan_d
);

input                       rst_n;

input                       clk_a;
input       [15:0]           data_a;
input                       data_a_sop;
input                       data_a_eop;
input                       data_a_vld;

input                       clk_b;
input       [15:0]           data_b;
input                       data_b_sop;
input                       data_b_eop;
input                       data_b_vld;

input                       clk_c;
input       [15:0]           data_c;
input                       data_c_sop;
input                       data_c_eop;
input                       data_c_vld;

input                       clk_d;
output      reg[15:0]        data_d;
output      reg             data_d_sop;
output      reg             data_d_eop;
output      reg             data_d_vld;
output      reg[1:0]             chan_d;


wire                        rdreq_a;
wire                        rdreq_b;
wire                        rdreq_c;

wire        [17:0]          wrdata_a;
wire        [17:0]          wrdata_b;
wire        [17:0]          wrdata_c;

wire        [17:0]          q_a;
wire        [17:0]          q_b;
wire        [17:0]          q_c;

reg                         work_state;
reg         [1:0]           work_sel;
    

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

msg_fifo0 msg_fifo0_inst0(
	.data(),
	.rdclk(clk_d),
	.rdreq(msg_rdreq_a),
	.wrclk(clk_a),
	.wrreq(msg_wrreq_a),
	.q(),
	.rdempty(msg_rdempty_a),
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

msg_fifo1 msg_fifo1_inst0(
	.data(),
	.rdclk(clk_d),
	.rdreq(msg_rdreq_b),
	.wrclk(clk_b),
	.wrreq(msg_wrreq_b),
	.q(),
	.rdempty(msg_rdempty_b),
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

msg_fifo2 msg_fifo2_inst0(
	.data(),
	.rdclk(clk_d),
	.rdreq(msg_rdreq_c),
	.wrclk(clk_c),
	.wrreq(msg_wrreq_c),
	.q(),
	.rdempty(msg_rdempty_c),
	.wrfull()
);


assign wrdata_a = {data_a_sop, data_a_eop, data_a};
assign wrreq_a = data_a_vld;
assign rdreq_a = rdempty_a==0 && (work_state && work_sel == 2'd0);
assign msg_wrreq_a = data_a_vld && data_a_eop;
assign msg_rdreq_a = msg_rdempty_a==0 && (rdreq_a && q_a[16] == 1);

assign wrdata_b = {data_b_sop, data_b_eop, data_b};
assign wrreq_b = data_b_vld;
assign rdreq_b = rdempty_b==0 && (work_state && work_sel == 2'd1);
assign msg_wrreq_b = data_b_vld && data_b_eop;
assign msg_rdreq_b = msg_rdempty_b==0 && (rdreq_b && q_b[16] == 1);


assign wrdata_c = {data_c_sop, data_c_eop, data_c};
assign wrreq_c = data_c_vld;
assign rdreq_c = rdempty_c==0 && (work_state && work_sel == 2'd2);
assign msg_wrreq_c = data_c_vld && data_c_eop;
assign msg_rdreq_c = msg_rdempty_c==0 && (rdreq_c && q_c[16] == 1);

always  @(posedge clk_d or negedge rst_n)begin
    if(rst_n==1'b0)begin
        work_state <= 1'b0;
    end
    else if(work_state == 0 && (msg_rdempty_a == 0 || msg_rdempty_b==0 || msg_rdempty_c==0))begin
        work_state <= 1'b1;
    end
    else if(msg_rdreq_a 
            || msg_rdreq_b
             || msg_rdreq_c)begin
        work_state <= 1'b0;
    end
end

always  @(posedge clk_d or negedge rst_n)begin
    if(rst_n==1'b0)begin
        work_sel <= 2'd0;
    end
    else if(work_state == 0 && (msg_rdempty_a == 0 || msg_rdempty_b==0 || msg_rdempty_c==0))begin
        if(msg_rdempty_a == 0)begin
            work_sel <= 2'd0;
        end
        else if(msg_rdempty_b == 0)begin
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
        else if(rdreq_c)begin
            data_d <= q_c[15:0];
        end
        else begin
            data_d <= 15'd0;
        end
    end
end

/*
 // 潘老师方法
 data_d_sop  <= q_a[17] || q_c[17] || q_c[17];
 */
always  @(posedge clk_d or negedge rst_n)begin
    if(rst_n==1'b0)begin
        data_d_sop <= 1'b0;
    end
    else begin
        if(rdreq_a)begin
            data_d_sop <= ;
        end
        else if(rdreq_b)begin
            data_d_sop <= q_b[17];
        end
        else if(rdreq_c)begin
            data_d_sop <= q_c[17];
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
            data_d_eop <= q_b[16];
        end
        else if(rdreq_c)begin
            data_d_eop <= q_c[16];
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
        data_d_vld <= rdreq_a || rdreq_b || rdreq_c;
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
    else if(rdreq_c)begin
        chan_d <= 2'd2;
    end
end


endmodule
