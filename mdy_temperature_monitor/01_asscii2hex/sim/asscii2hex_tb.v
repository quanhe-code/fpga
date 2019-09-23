`timescale 1ns/1ns

module asscii2hex_tb();

localparam      clk_period = 40;

reg             clk;
reg             rst_n;
reg     [7:0]   din;
reg             din_vld;
wire    [3:0]   dout;
wire            dout_vld;

asscii2hex inst_asscii2hex_1(
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

    #(clk_period * 2);
    din = 8'h31;
    din_vld = 1;
    #(clk_period);
    din_vld = 0;

    #(clk_period * 3)
    din = 8'h39;
    din_vld = 1;
    #(clk_period)
    din = 8'h38;

    #(clk_period * 3)
    din = 8'h64;
    din_vld = 1;
    #(clk_period)
    din = 8'h45;
    #(clk_period)
    din_vld = 0;

    #(clk_period*5)
    $stop;
end

endmodule
