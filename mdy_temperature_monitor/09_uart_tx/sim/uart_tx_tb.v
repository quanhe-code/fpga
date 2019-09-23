`timescale 1ns/1ns

module uart_tx_tb();

localparam      clk_period = 40;
defparam        uart_tx_inst0.CNT_MAX = 50;

reg               clk;			
reg               rst_n;		
reg  [7:0] din;
reg               din_vld;	
wire            rdy;
wire            dout;



uart_tx uart_tx_inst0(
                 .clk(clk),
                 .rst_n(rst_n),
                 .din(din),
                 .din_vld(din_vld),
                 .rdy(rdy),
                 .dout(dout)
             );

initial begin
    clk = 1'b1;
    forever #(clk_period / 2) clk = ~clk;
end

initial begin
    rst_n = 1'b0;
    din = 8'h00;
    din_vld = 1'b0;

    #(clk_period*5);
    #(10);

    rst_n = 1'b1;
    
    #(clk_period*5);
    din = 8'ha5;
    din_vld = 1'b1;
    #(clk_period)
    din_vld = 1'b0;


    #(clk_period * 1000);
    $stop;
end
endmodule
