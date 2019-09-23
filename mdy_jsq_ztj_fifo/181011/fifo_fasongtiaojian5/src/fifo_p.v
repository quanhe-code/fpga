/*
 * fifo 阶段2练习5
 */
module fifo_p(
        rst_n,

        clk_a,
        data_a,
        data_a_vld,

        clk_b,
        data_b,
        data_b_vld,

        clk_c,
        data_c,
        data_c_vld,

        clk_d,
        data_d,
        data_d_vld,
        chan_d
);

input                       rst_n;

input                       clk_a;
input       [15:0]          data_a;
input                       data_a_vld;

input                       clk_b;
input       [15:0]          data_b;
input                       data_b_vld;

input                       clk_c;
input       [15:0]          data_c;
input                       data_c_vld;

input                       clk_d;
output      reg[15:0]       data_d;
output      reg             data_d_vld;
output      reg[1:0]        chan_d;


reg                        rdreq_a;
reg                        rdreq_b;
reg                        rdreq_c;

wire        [15:0]          wrdata_a;
wire        [15:0]          wrdata_b;
wire        [15:0]          wrdata_c;

wire        [15:0]          q_a;
wire        [15:0]          q_b;
wire        [15:0]          q_c;

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

assign wrdata_a = data_a;
assign wrreq_a = data_a_vld;

assign wrdata_b = data_b;
assign wrreq_b = data_b_vld;

assign wrdata_c = data_c;
assign wrreq_c = data_c_vld;


always  @(*)begin
    if(rdempty_a == 0) begin
        rdreq_a  = 1'b1;
    end
    else if(rdempty_a == 1 && rdempty_b == 0)begin
        rdreq_b = 1'b1;
    end
    else if(rdempty_a == 1 && rdempty_b == 1 && rdempty_c == 0)begin
        rdreq_c = 1'b1;
    end
    else begin
        rdreq_a = 1'b0;
        rdreq_b = 1'b0;
        rdreq_c = 1'b0;
    end
end

always  @(posedge clk_d or negedge rst_n)begin
    if(rst_n==1'b0)begin
        data_d <= 16'd0;
    end
    else begin
        if(rdreq_a)begin
            data_d <= q_a;
        end
        else if(rdreq_b)begin
            data_d <= q_b;
        end
        else if(rdreq_c)begin
            data_d <= q_c;
        end
        else begin
            data_d <= 16'd0;
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
