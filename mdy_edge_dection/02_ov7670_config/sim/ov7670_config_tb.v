`timescale 1ns/1ns

module ov7670_config_tb();

localparam      clk_period = 20;

reg                 clk      ;   //50Mhz
reg                 rst_n    ;
reg                 config_en;
reg                 rdy      ;
reg   [7:0]         rdata    ;
reg                 rdata_vld;

//输出信号定义
wire [7:0]          wdata    ;
wire [7:0]          addr     ;
wire               cmos_en  ;
wire               wr_en    ;
wire               rd_en    ;
wire               pwdn     ;


ov7670_config ov7670_config_inst0(
        .clk        (clk),
        .rst_n      (rst_n),
        .config_en  (config_en),
        .rdy        (rdy),
        .rdata      (rdata),
        .rdata_vld  (rdata_vld),
        .wdata      (wdata),
        .addr       (addr),
        .wr_en	    (wr_en),
	    .rd_en      (rd_en),
        .cmos_en    (cmos_en), 
        .pwdn       (pwdn)  
);

initial begin
    clk = 1'b0;
    forever #(clk_period / 2) clk = ~clk;
end

initial begin
    rst_n = 1'b0;
    rdy = 1'b0;
    config_en = 1'b0;

    #(5);
    #(clk_period * 5);

    rst_n = 1'b1;

    #(clk_period * 5);
    rdy = 1'b1;

    #(clk_period * 5);
    config_en = 1'b1;
    #(clk_period);
    config_en = 1'b0;

    #(clk_period * 50000);
    $stop;

end

endmodule
