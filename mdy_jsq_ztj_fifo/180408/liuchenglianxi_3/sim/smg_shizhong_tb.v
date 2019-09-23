`timescale		1ns/1ps

module smg_shizhong_tb();

localparam	clk_period = 40;
defparam	smg_shizhong_1.MAX_CNT = 50; 

reg clk;
reg rst_n;
wire ds_data;
wire ds_shcp;
wire ds_stcp;


smg_shizhong smg_shizhong_1(
    .clk(clk),
    .rst_n(rst_n),
    .ds_data(ds_data),
    .ds_shcp(ds_shcp),
    .ds_stcp(ds_stcp)
);

initial begin
	clk = 1'b1;
	forever #(clk_period/2) clk = ~clk;
end

initial begin
	rst_n = 0;
	
	#(clk_period *5);
	rst_n = 1;
	
end






endmodule