`timescale 1ns/1ns

module seg_disp_tb();


localparam      clk_period = 40;
defparam    seg_disp_inst0.SECOND_CNT = 100;
defparam    seg_disp_inst0.HC595_CLK_CNT = 5;
reg                             clk;
reg                             rst_n;
reg                             disp_en;
reg  [15:0]                     din;
reg  [3:0]                      din_vld;

wire                 ds_data;
wire                 ds_shcp;
wire                 ds_stcp;


seg_disp seg_disp_inst0(
                 .rst_n(rst_n)       ,
                 .clk(clk)         ,
                 .disp_en(disp_en)     ,
                 .din(din)         ,
                 .din_vld(din_vld)     ,
                 .ds_data(ds_data),
                 .ds_shcp(ds_shcp),
                 .ds_stcp(ds_stcp)
             );
initial begin
    clk = 1'b1;
    forever #(clk_period / 2) clk = ~clk;
end    

initial begin
    rst_n = 0;
    din_vld = 9'h00;
    disp_en = 1'b1;

    #((clk_period * 5) - 10);
    rst_n = 1;

    #(clk_period * 5);
    din = 16'hadec;
    din_vld = 8'hff;
    #(clk_period);
    din_vld = 8'h00;

    #(clk_period * 1000)
    $stop;
end



endmodule
