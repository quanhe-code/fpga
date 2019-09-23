`timescale 1ns/1ns

module cmos_capture_tb();

localparam      clk_period = 40;

reg          clk          ; 
reg          rst_n        ;
reg          en_capture   ;
reg          vsync        ;
reg          href         ;
reg  [7:0]   din          ;

wire [15:0]  dout         ;
wire         dout_vld     ;
wire         dout_sop     ;
wire         dout_eop     ;

integer      i;

cmos_capture cmos_capture_inst0(
                .clk         (clk),
                .rst_n       (rst_n),
                .en_capture  (en_capture),
                .vsync       (vsync),
                .href        (href),
                .din         (din),
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
    en_capture = 1'b0;
    vsync = 1'b1;
    href = 1'b0;
    din = 8'h5a;

    #(5);
    #(clk_period * 5);
    rst_n = 1'b1;

    #(clk_period * 5);
    en_capture = 1'b1;

    vsync = 1'b0;
    for(i = 0; i< 3; i = i + 1)begin
        #(clk_period * 740);
    end
    vsync = 1'b1;

    for(i = 0; i< 17; i = i + 1)begin
        #(clk_period * 740);
    end
    for(i = 0; i < 480; i = i + 1) begin
        href = 1'b1;
        #(clk_period * 640 * 2);
        href = 1'b0;
        #(clk_period * 100 *2);
    end

    for(i = 0; i< 10; i = i + 1)begin
        #(clk_period * 740);
    end
    

    #(clk_period * 100000);
    $stop;
end

endmodule
