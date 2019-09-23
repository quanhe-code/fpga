`timescale 1ns/100ps
module testfifo5_1;
reg 		 clk;
reg 		 rst_n;
reg [31:0]   din;
reg 		 din_vld;
reg 		 din_eop;
reg 		 din_sop;
reg [1:0]    din_mty;

wire[7:0] dout;
wire      dout_vld;
wire      dout_sop;
wire      dout_eop;

reg[1:0] a,b,c;
integer i;
parameter cyclk=10;
   
initial
	begin
		#1 clk  =0;
	end
		always #cyclk clk=~clk;//50MHZ

   
	
initial
	begin
		#2 rst_n=1;
        a={$random}%4;
        b={$random}%4;
        c={$random}%4;
		#(cyclk*2+50) rst_n=0;
		#(cyclk*3) 	  rst_n=1;
	end 
		
initial
	begin
	#(cyclk*10)
		din    =0;
		din_vld=0;
		din_sop=0;
		din_eop=0;
        din_mty=0;
		#(cyclk*6.3)
      	repeat(5)
   begin
		din=0;
		din_vld=1;
		din_sop=1;
		#(cyclk*2)
		din=1;
		din_sop=0;
		for(i=2;i<=800;i=i+1)
		begin
			#(cyclk*2)
			din=i;
		end
		din_vld=1;
		din_eop=1;
        din_mty=a;
		#(cyclk*2)
		din_vld=0;
		din_eop=0;
		din    =0;
		#(cyclk*500)
		din_vld=0;
		din_eop=0;
		din    =0;
	end 
		#(cyclk*1000) $stop;
	end

fifo_p  fifo5_1(
    .clk 		(clk 	 ),
    .rst_n		(rst_n 	 ),
    .din   		(din 	 ),
    .din_vld	(din_vld ),
    .din_sop 	(din_sop ),
    .din_eop  	(din_eop ),
    .din_mty    (din_mty ),
    .dout  		(dout 	 ),
    .dout_vld	(dout_vld),
    .dout_sop 	(dout_sop),
    .dout_eop 	(dout_eop)
);	

endmodule
