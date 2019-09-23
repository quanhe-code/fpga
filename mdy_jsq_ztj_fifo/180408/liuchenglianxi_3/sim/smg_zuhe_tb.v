`timescale		1ns/1ps
`define	clk_period		40

module smg_zuhe_tb();

reg 			clk;
reg				rst_n;
reg				smg_mul_update;
wire			ds_data;
wire			ds_shcp;
wire			ds_stcp;

defparam smg_zuhe_1.MAX_CNT = 50;

smg_zuhe smg_zuhe_1(
				.clk(clk),
				.rst_n(rst_n),
				.smg_mul_data(16'h1362),
				.smg_mul_update(smg_mul_update),
				.ds_data(ds_data),
				.ds_shcp(ds_shcp),
				.ds_stcp(ds_stcp)
);

initial begin
	clk = 1'b1;
	forever #(`clk_period/2) clk = ~clk;
end

initial begin
	rst_n = 0;
	smg_mul_update = 0;
	
	#(`clk_period * 5)
	rst_n = 1;
	
	#(`clk_period * 5)
	smg_mul_update = 1;
	
	#(`clk_period)
	smg_mul_update = 0;
end



endmodule