`timescale 1 ns/1 ns// 时间单位/时间精度（例如RST_N=3.1,只能取到3；如果时间精度为1ps,则可以取到3.1

module testfifo3_4();

    //时钟和复位
reg clk  ;
reg rst_n;

//uut(被测模块例化之后的模块)的输入信号(注意：被测模块输入信号定义成reg)
reg    din_vld  ;
reg    din_sop  ;
reg    din_eop  ;
reg    din_err  ;
reg[15:0]  din   ;



//uut(被测模块例化之后的模块)的输出信号(注意：被测模块输出信号定义成wire)
wire      dout_vld;
wire      dout_sop;
wire      dout_eop;
wire[15:0]    dout;

//时钟周期，单位为ns，可在此修改时钟周期。
parameter CYCLE    = 20;

//复位时间，此时表示复位3个时钟周期的时间。
parameter RST_TIME = 3 ;

integer i;

//待测试的模块例化(.clk为模块信号，clk为测试文件定义的信号)
fifo_p uut(
         .clk             (clk      ), 
         .rst_n           (rst_n    ),
         .din_vld         (din_vld  ),
         .din_sop         (din_sop  ),
         .din_eop         (din_eop  ),
         .din_err         (din_err  ),
         .din             (din      ),
         .dout_vld        (dout_vld ),
         .dout_sop        (dout_sop ),
         .dout_eop        (dout_eop ),
         .dout            (dout     )
      );

//时钟和复位模块驱动的写法均为固定写法
//生成本地时钟50M
initial begin
clk = 0;
forever
#(CYCLE/2)
clk=~clk;
end

//产生复位信号
initial begin
rst_n = 1;
#2;
rst_n = 0;
#(CYCLE*RST_TIME);
rst_n = 1;
end

//输入信号赋值方式
initial begin
#1;
din_vld=0;
din_sop=0;
din_eop=0;
din_err=0;
din =0;
//传输时段0
#(4*CYCLE);
for(i=0;i<12;i=i+1) begin
   din=(i==0)? 0001:din+1;
   din_sop=(i==0)? 1:0;
   din_eop=(i==11)? 1:0;
   din_err=0;
   din_vld=1;
   #(1*CYCLE);
end

din_vld=0;
din_sop=0;
din_eop=0;
din_err=0;
din =0;

//传输时段1
#(6*CYCLE);
for(i=0;i<100;i=i+1) begin
   din=(i==0)? 0000:din+1;
   din_sop=(i==0)? 1:0;
   din_eop=(i==99)? 1:0;
   din_err=(i==99)? 1:0;
   din_vld=1;
   #(1*CYCLE);
end

din_vld=0;
din_sop=0;
din_eop=0;
din_err=0;
din =0;
//传输时段2
#(6*CYCLE);
for(i=0;i<90;i=i+1) begin
   din=0;
   din_sop=(i==0)? 1:0;
   din_eop=(i==89)? 1:0;
   din_err=0;
   din_vld=1;
   #(1*CYCLE);
end

din_vld=0;
din_sop=0;
din_eop=0;
din_err=0;
din =0;
//传输时段3
#(6*CYCLE);
   din=16'b0000_0000_0000_1111;
   din_sop=1;  
   din_eop=0;
   din_err=0;
   din_vld=1;
   #(1*CYCLE);

   din=16'b0000_0000_1111_0000;
   din_sop=0;  
   din_eop=0;
   din_err=0;
   din_vld=1;
   #(1*CYCLE);

   din=16'b0000_1111_0000_0000;
   din_sop=0;  
   din_eop=0;
   din_err=0;
   din_vld=1;
   #(1*CYCLE);

   din=16'b1111_0000_0000_0001;
   din_sop=0;  
   din_eop=1;
   din_err=0;
   din_vld=1;
   #(1*CYCLE);

din_vld=0;
din_sop=0;
din_eop=0;
din_err=0;
din =0;
//传输时段4
#(6*CYCLE);
#(6*CYCLE);
   din=16'b0000_0000_0000_0001;
   din_sop=1;  
   din_eop=0;
   din_err=0;
   din_vld=1;
   #(1*CYCLE);

   din=16'b0000_0000_1001_1110;
   din_sop=0;  
   din_eop=0;
   din_err=0;
   din_vld=1;
   #(1*CYCLE);

   din=16'b0000_1111_0110_0000;
   din_sop=0;  
   din_eop=0;
   din_err=0;
   din_vld=0;
   #(1*CYCLE);

   din=16'b0111_0000_0000_0000;
   din_sop=0;  
   din_eop=1;
   din_err=0;
   din_vld=1;
   #(1*CYCLE);

   din=16'b1000_0000_0000_0001;
   din_sop=0;  
   din_eop=1;
   din_err=0;
   din_vld=1;
   #(1*CYCLE);

din_vld=0;
din_sop=0;
din_eop=0;
din_err=0;
din =0;
end
endmodule

