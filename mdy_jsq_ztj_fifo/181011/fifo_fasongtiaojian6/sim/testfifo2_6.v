`timescale 1 ns/1 ns// 时间单位/时间精度（例如RST_N=3.1,只能取到3；如果时间精度为1ps,则可以取到3.1

module testfifo2_6();

    //时钟和复位
reg clk_a  ;
reg clk_b  ;
reg clk_c  ;
reg clk_d  ;
reg rst_n;

//uut(被测模块例化之后的模块)的输入信号(注意：被测模块输入信号定义成reg)
reg         data_a_vld  ;
reg         data_a_sop  ;
reg         data_a_eop  ;
reg[7:0]    data_a      ;

reg         data_b_vld  ;
reg         data_b_sop  ;
reg         data_b_eop  ;
reg[7:0]    data_b      ;

reg         data_c_vld  ;
reg         data_c_sop  ;
reg         data_c_eop  ;
reg[7:0]    data_c      ;


//uut(被测模块例化之后的模块)的输出信号(注意：被测模块输出信号定义成wire)
wire         data_vld;
wire         data_sop;
wire         data_eop;
wire[7:0]    data    ;
wire[1:0]    chan_d  ;

//时钟周期，单位为ns，可在此修改时钟周期。
parameter CYCLE_A    = 50;
parameter CYCLE_B    = 25;
parameter CYCLE_C    = 100;
parameter CYCLE_D    = 12.5;

//复位时间，此时表示复位3个时钟周期的时间。
parameter RST_TIME = 3 ;

integer i,j,k;

//待测试的模块例化(.clk为模块信号，clk为测试文件定义的信号)
fifo_p uut(
    .clk_a             ( clk_a      ), 
    .clk_b             ( clk_b      ), 
    .clk_c             ( clk_c      ), 
    .clk_d             ( clk_d      ), 
    .rst_n             ( rst_n      ),
    .data_a_vld         ( data_a_vld  ),
    .data_a_sop         ( data_a_sop  ),
    .data_a_eop         ( data_a_eop  ),
    .data_a             ( data_a      ),
    .data_b_vld         ( data_b_vld  ),
    .data_b_sop         ( data_b_sop  ),
    .data_b_eop         ( data_b_eop  ),
    .data_b             ( data_b      ),
    .data_c_vld         ( data_c_vld  ),
    .data_c_sop         ( data_c_sop  ),
    .data_c_eop         ( data_c_eop  ),
    .data_c             ( data_c      ),
    .data_d_vld        ( data_vld ),
    .data_d_sop        ( data_sop ),
    .data_d_eop        ( data_eop ),
    .data_d            ( data     ),
    .chan_d            ( chan_d     )
    );

//时钟和复位模块驱动的写法均为固定写法
//生成本地时钟50M
initial begin
clk_a = 0;
forever
#(CYCLE_A/2)
clk_a=~clk_a;
end

initial begin
clk_b = 0;
forever
#(CYCLE_B/2)
clk_b=~clk_b;
end

initial begin
clk_c = 0;
forever
#(CYCLE_C/2)
clk_c=~clk_c;
end

initial begin
clk_d = 0;
forever
#(CYCLE_D/2)
clk_d=~clk_d;
end

//产生复位信号
initial begin
rst_n = 1;
#2;
rst_n = 0;
#(CYCLE_C*RST_TIME);
rst_n = 1;
end

initial begin
//报文A初始化
 #1;
data_a_vld=0;
data_a_sop=0;
data_a_eop=0;
data_a =0;
//报文A输入
#(4*CYCLE_C);
for(i=0;i<16;i=i+1) begin
   data_a=(i==0)? 0:data_a+1;
   data_a_sop=(i==0)? 1:0;
   data_a_eop=(i==15)? 1:0;
   data_a_vld=1;
   #(1*CYCLE_A);
end
data_a_vld=0;
data_a_sop=0;
data_a_eop=0;
data_a =0;
end

initial begin
//报文B初始化
 #1;    
data_b_vld=0;
data_b_sop=0;
data_b_eop=0;
data_b =0;
//报文B输入
#(10*CYCLE_C);
for(j=0;j<21;j=j+1) begin
   data_b=(j==0)? 20:data_b+1;
   data_b_sop=(j==0)? 1:0;
   data_b_eop=(j==20)? 1:0;
   data_b_vld=1;
   #(1*CYCLE_B);
end
data_b_vld=0;
data_b_sop=0;
data_b_eop=0;
data_b =0;
end

initial begin
//报文C初始化
 #1;
data_c_vld=0;
data_c_sop=0;
data_c_eop=0;
data_c =0;
//报文C输入
#(15*CYCLE_C);
for(k=0;k<31;k=k+1) begin
   data_c=(k==0)? 50:data_c+1;
   data_c_sop=(k==0)? 1:0;
   data_c_eop=(k==30)? 1:0;
   data_c_vld=1;
   #(1*CYCLE_C);
end
data_c_vld=0;
data_c_sop=0;
data_c_eop=0;
data_c =0;
end

endmodule

