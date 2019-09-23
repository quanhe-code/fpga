`timescale 1ns/1ps
`define clk_period	40

module test_huxiled4_2 (       
);



reg			clk;
reg			rst_n;
wire[3:0] 	led; 

huxiled4
		#(
		.SECOND_CNT(1000)
		)
		huxiled4_tb(
		.clk(clk)    ,
		.rst_n(rst_n)  ,
		.led(led)				
);

initial begin
	clk = 1'b1;
end

always begin
	#(`clk_period / 2) 
	clk = ~clk;
end


initial begin
	rst_n = 1'b0;
	
	#(23);

	rst_n = 1'b1;
	
	#(`clk_period*25000000);
	
	#(`clk_period*25000000);
	
	#(`clk_period*25000000);
	
	#(`clk_period*25000000);
	
	#(`clk_period*25000000);
	
	$stop;	
end	
endmodule
