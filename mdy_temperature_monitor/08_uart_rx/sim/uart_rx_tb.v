`timescale 1ns/1ns

module uart_rx_tb();

reg               clk          ;		
reg               rst_n        ;	
reg               din          ;
wire[7:0]         dout         ;		
wire              dout_vld     ;

localparam      clk_period = 40;
defparam  uart_rx_inst1.CNT_MAX = 10;  

uart_rx uart_rx_inst1(
                 .clk(clk),
                 .rst_n(rst_n),
                 .din(din),
                 .dout(dout),
                 .dout_vld(dout_vld)
);

initial begin
    clk = 1'b1;
    forever #(clk_period / 2) clk = ~clk;
end

initial begin
    rst_n = 1'b0;
    din = 1'b1;

    #(clk_period * 3)
    rst_n = 1'b1;

    #(clk_period * 5)
    din = 1'b0;

    // 发送第一个数据
    #(clk_period * 10)
    din = 1'b1;


    #(clk_period * 10)
    din = 1'b0;

    #(clk_period * 10)
    din = 1'b0;


    #(clk_period * 10)
    din = 1'b1;

    #(clk_period * 10)
    din = 1'b0;

    #(clk_period * 10)
    din = 1'b1;

    #(clk_period * 10)
    din = 1'b0;

    #(clk_period * 10)
    din = 1'b1;

    #(clk_period * 10)
    din = 1'b1;

    #(clk_period * 100)
    $stop;

end
endmodule
