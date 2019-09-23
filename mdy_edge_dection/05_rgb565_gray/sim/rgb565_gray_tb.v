`timescale 1ns/1ns

module rgb565_gray_tb();

localparam      clk_period = 20;

reg          clk     ;
reg          rst_n   ;
reg   [15:0] din     ;
reg          din_vld ;
reg          din_sop ;
reg          din_eop ;

wire [7:0]  dout     ;
wire        dout_vld ;
wire        dout_sop ;
wire        dout_eop ;

rgb565_gray rgb565_gray_inst0(
            .clk         (clk),
            .rst_n       (rst_n),
            .din         (din),
            .din_vld     (din_vld),
            .din_sop     (din_sop),
            .din_eop     (din_eop),
            .dout        (dout),
            .dout_vld    (dout_vld),
            .dout_sop    (dout_sop),
            .dout_eop    (dout_eop) 
);

initial begin
    clk = 1'b1;
    forever #(clk_period / 2) clk = ~clk;
end

initial begin
    rst_n = 1'b0;
    din = 16'h00;
    din_vld = 1'b0;
    din_sop = 1'b0;
    din_eop = 1'b0;

    #(5);
    #(clk_period * 5);
    rst_n = 1'b1;

    #(clk_period *5);

    din = 16'h0001;
    din_vld = 1'b1;
    din_sop = 1'b1;

    #(clk_period);
    din = 16'h0203;
    din_vld = 1;
    din_sop = 0;


    #(clk_period);
    din = 16'h0405;
    din_vld  = 1'b1;
    din_eop = 1'b1;
    #(clk_period);
    din_vld = 1'b0;
    din_eop = 1'b0;

    #(clk_period * 10000);
    $stop;

end

endmodule
