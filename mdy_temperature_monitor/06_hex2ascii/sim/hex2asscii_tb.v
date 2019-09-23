`timescale 1ns/1ns

module hex2asscii_tb();

reg                clk     ;
reg                rst_n   ;
reg                rdy     ;
reg   [7:0]        din     ;
reg                h2a_en  ;
reg                din_vld ;
wire  [7:0]        dout    ;
wire               dout_vld;

localparam      clk_period = 40;

hex2asscii hex2asscii_inst1(
               .clk      (clk),
               .rst_n    (rst_n),
               .rdy      (rdy),
               .h2a_en   (h2a_en),
               .din      (din),
               .din_vld  (din_vld),
               .dout     (dout),
               .dout_vld (dout_vld) 
);

initial begin
    clk = 1'b1;
    forever #(clk_period / 2) clk = ~clk;
end

initial begin
    rst_n = 1'b0;
    rdy = 1'b0;
    din = 8'h00;
    din_vld = 1'b0;
    h2a_en = 1'b0;


    #(clk_period * 3)
    rst_n = 1'b1;


    #(clk_period * 3)
    din = 8'h4a;
    din_vld = 1'b1;
    #(clk_period)
    din_vld = 1'b0;


    #((clk_period * 5) - 10)
    rdy = 1'b1;

    #((clk_period * 20) + 10)
    rdy = 1'b0;
    
    #(clk_period * 3)
    din = 8'h4a;
    h2a_en = 1'b1;
    din_vld = 1'b1;
    #(clk_period)
    h2a_en = 1'b0;
    din_vld = 1'b0;

    #((clk_period * 5) - 10)
    rdy = 1'b1;
    #(clk_period)
    rdy = 1'b0;

    #((clk_period * 5) - 10)
    rdy = 1'b1;
    #(clk_period)
    rdy = 1'b0;

    #(clk_period * 100)
    $stop;


end
endmodule
