`timescale 1ns/1ns

module opcode_detect_tb();

localparam      clk_period = 40;

reg             clk;
reg             rst_n;
reg     [3:0]   din;
reg             din_vld;
wire    [7:0]   dout;
wire            dout_vld;

opcode_detect opcode_detect_inst_1(
   .clk(clk)      ,
   .rst_n(rst_n)    ,
   .din(din)      ,
   .din_vld(din_vld)  ,
   .dout(dout)     ,
   .dout_vld(dout_vld)   
    );

initial begin
    clk = 1'b1;
    forever #(clk_period / 2) clk = ~clk;
end

initial begin
    rst_n = 0;

    #(clk_period * 5);
    rst_n = 1;

    #(clk_period * 2)

    #(clk_period)
    din = 4'd5;
    din_vld = 1;

    #(clk_period)
    din = 4'd5;
    din_vld = 1;

    #(clk_period)
    din = 4'hd;
    din_vld = 0;

    #(clk_period)
    din = 4'hd;
    din_vld = 1;

    #(clk_period)
    din = 4'hc;
    din_vld = 1;

    #(clk_period * 2)

    #(clk_period)
    din = 4'd5;
    din_vld = 1;

    #(clk_period)
    din = 4'd5;
    din_vld = 1;

    #(clk_period)
    din = 4'hd;
    din_vld = 1;

    #(clk_period)
    din = 4'd5;
    din_vld = 1;

    #(clk_period)
    din = 4'd8;
    din_vld = 1;

    #(clk_period)
    din = 4'd1;
    din_vld = 1;

    #(clk_period)
    din = 4'hc;
    din_vld = 1;

    #(clk_period)
    din = 4'hc;
    din_vld = 1;

    #(clk_period * 3);

    $stop;
end

/*
task abcd;
    input[3:0] code;
    input[3:0] data;
    begin
        din = 8'h55;
        din_vld = 1;
        #(clk_period);
        din = 8'hd5;
        din_vld = 1;
        #(clk_period);
        din = code;
        din_vld = 1;
        #(clk_period);
        din = data;
        din_vld = 1;
        #(clk_period);
        din_vld = 0;
    end
endtask
*/



endmodule
