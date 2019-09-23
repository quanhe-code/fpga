`timescale 1ns/1ns

module sccb_tb();

localparam      clk_period = 40;
defparam    sccb_inst0.SIO_C = 10;

reg               clk      ;//25m
reg               rst_n    ;
reg               ren      ;
reg               wen      ;
reg [7:0]         sub_addr ;
reg [7:0]         wdata    ;
wire [7:0]         rdata    ;
wire               rdata_vld;
wire               sio_c    ;//208kHz
wire               rdy      ;
reg              sio_d_r   ;
wire             en_sio_d_w;
wire             sio_d_w   ;

sccb sccb_inst0(
            .clk       (clk),
            .rst_n     (rst_n),
            .ren       (ren),
            .wen       (wen),
            .sub_addr  (sub_addr),
            .rdata     (rdata),
            .rdata_vld (rdata_vld),
            .wdata     (wdata),
            .rdy       (rdy),
            .sio_c     (sio_c),
            .sio_d_r   (sio_d_r),
            .en_sio_d_w(en_sio_d_w),
            .sio_d_w   (sio_d_w)      
);

initial begin
    clk = 1'b1;

    forever #(clk_period / 2) clk = ~clk;
end

initial begin
    rst_n = 1'b0;
    wen = 1'b0;
    ren = 1'b0;
    wdata = 8'h00;
    sub_addr = 8'hff;
    sio_d_r = 8'b0;

    #(5);
    #(clk_period * 5);
    rst_n = 1'b1;


    #(clk_period * 5);
    wdata = 8'h4c;
    sub_addr = 8'h5a;
    wen = 1'b1;
    #(clk_period);
    wen = 1'b0;

    #(clk_period * 500)
    sub_addr = 8'h7d;
    ren = 1'b1;
    #(clk_period);
    ren = 1'b0;

    #(clk_period * 10000);
    $stop;
end
    
endmodule
