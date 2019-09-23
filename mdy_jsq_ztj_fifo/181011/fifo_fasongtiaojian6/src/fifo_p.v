/*
 * fifo 阶段2练习6
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
input       [7:0]           data_a;
input                       data_a_sop;
input                       data_a_eop;
input                       data_a_vld;

input                       clk_b;
input       [7:0]           data_b;
input                       data_b_sop;
input                       data_b_eop;
input                       data_b_vld;

input                       clk_c;
input       [7:0]           data_c;
input                       data_c_sop;
input                       data_c_eop;
input                       data_c_vld;

input                       clk_d;
output      reg[7:0]        data_d;
output      reg             data_d_sop;
output      reg             data_d_eop;
output      reg             data_d_vld;
output      reg[1:0]        chan_d;


wire                        rdreq_a;
wire                        rdreq_b;
wire                        rdreq_c;

wire        [9:0]          wrdata_a;
wire        [9:0]          wrdata_b;
wire        [9:0]          wrdata_c;

wire        [9:0]          q_a;
wire        [9:0]          q_b;
wire        [9:0]          q_c;

reg                         flag_a;
reg                         flag_b;
reg                         flag_c;
    

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

assign wrdata_a = {data_a_sop, data_a_eop, data_a};
assign wrreq_a = data_a_vld;

assign wrdata_b = {data_b_sop, data_b_eop, data_b};
assign wrreq_b = data_b_vld;

assign wrdata_c = {data_c_sop, data_c_eop, data_c};
assign wrreq_c = data_c_vld;

always  @(posedge clk_d or negedge rst_n)begin
    if(rst_n==1'b0)begin
        flag_a <= 1'b0;
        flag_b <= 1'b0;
        flag_c <= 1'b0;
    end
    else if(flag_a == 1'b0 && flag_b == 1'b0 && flag_c == 1'b0)begin
        if(rdempty_a == 0)begin
            flag_a <= 1'b1;
        end
        else if(rdempty_b == 0)begin
            flag_b <= 1'b1;
        end
        else if(rdempty_c == 0)begin
            flag_c <= 1'b1;
        end
    end
    else if(data_d_eop == 1)begin
        flag_a <= 1'b0;
        flag_b <= 1'b0;
        flag_c <= 1'b0;
    end
end

/*
潘老师方法：
always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        work_state <= 1'b0;
    end
    else if(work_state == 1'b0 && (rdempty_a==0 || rdempty_b==0 || rdempty_c==0))begin
        work_state <= 1'b1;
    end
    else if(work_state == 1'b1 && ((rdreq_a && q_a[8]) || (rdreq_b && q_b[8]) || (rdreq_c && q_c[8])))begin
        work_state <= 1'b0;
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        work_sel <= 2'd0;
    end
    else if(work_state == 1'b0 && (rdempty_a==0 || rdempty_b==0 || rdempty_c==0))begin
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
*/

assign rdreq_a = rdempty_a==0 && flag_a;
assign rdreq_b = rdempty_b==0 && flag_b;
assign rdreq_c = rdempty_c==0 && flag_c;

always  @(posedge clk_d or negedge rst_n)begin
    if(rst_n==1'b0)begin
        data_d <= 8'd0;
    end
    else begin
        if(rdreq_a)begin
            data_d <= q_a[7:0];
        end
        else if(rdreq_b)begin
            data_d <= q_b[7:0];
        end
        else if(rdreq_c)begin
            data_d <= q_c[7:0];
        end
        else begin
            data_d <= 8'd0;
        end
    end
end

always  @(posedge clk_d or negedge rst_n)begin
    if(rst_n==1'b0)begin
        data_d_sop <= 1'b0;
    end
    else begin
        if(rdreq_a)begin
            data_d_sop <= q_a[9];
        end
        else if(rdreq_b)begin
            data_d_sop <= q_b[9];
        end
        else if(rdreq_c)begin
            data_d_sop <= q_c[9];
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
            data_d_eop <= q_a[8];
        end
        else if(rdreq_b)begin
            data_d_eop <= q_b[8];
        end
        else if(rdreq_c)begin
            data_d_eop <= q_c[8];
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
