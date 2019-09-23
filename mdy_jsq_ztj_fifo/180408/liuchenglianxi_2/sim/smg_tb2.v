`timescale 1ns/1ps
`define clk_period		40

module smg_tb2();

reg clk;
reg rst_n;
wire ds_data;
wire ds_shcp;
wire ds_stcp;

defparam smg_1.SECOND_CNT = 100;
defparam smg_1.smg_interface_1.clk_cnt = 20;

smg smg_1(
			.clk(clk),
            .rst_n(rst_n),
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
	
	
	#(`clk_period * 20);
	rst_n = 1;

end




endmodule