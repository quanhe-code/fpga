`timescale 1 ns/1 ns// 时间单位/时间精度（例如RST_N=3.1,只能取到3；如果时间精度为1ps,则可以取到3.1

module testfifo1_1();

    //时钟和复位
    reg clk_in  ;
    reg rst_n   ;
    reg clk_out ;
    
    //uut(被测模块例化之后的模块)的输入信号(注意：被测模块输入信号定义成reg)
    reg[15:0]   data_in  ;
    reg         data_in_vld  ;
    reg         b_rdy        ;
    
    
    //uut(被测模块例化之后的模块)的输出信号(注意：被测模块输出信号定义成wire);
    wire        data_out_vld ;
    wire[15:0]  data_out   ;
    
    
    //时钟周期，单位为ns，可在此修改时钟周期。
    parameter CYCLE    = 12.5;
    parameter CYCLE_W  = 10;
    integer     i ;
    //复位时间，此时表示复位3个时钟周期的时间。
    parameter RST_TIME = 3 ;
    
    //待测试的模块例化(.clk为模块信号，clk为测试文件定义的信号)
    fifo_p uut(
    .clk_in          (clk_in     ), 
    .rst_n           (rst_n      ),
    .data_in         (data_in    ),
    .data_in_vld     (data_in_vld),
    .clk_out         (clk_out    ),
    .data_out        (data_out   ),
    .data_out_vld    (data_out_vld),
    .b_rdy           (b_rdy       )    
    );
    
    //时钟和复位模块驱动的写法均为固定写法
    //生成本地时钟50M
    initial begin
    clk_in = 0;
    forever
    #(CYCLE/2)
    clk_in=~clk_in;
    end
     initial begin
    clk_out = 0;
    forever
    #(CYCLE_W/2)
    clk_out=~clk_out;
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
    data_in_vld = 0;
    data_in     =0 ;
    b_rdy       =0 ;
    //传输时段1
    #(4*CYCLE);
    for(i=0;i<80;i=i+1) begin
        data_in_vld=1;
        data_in=$random;
        b_rdy  =0;
        #(1*CYCLE);
    end
    
    data_in_vld=0;
    data_in    =0 ;
    b_rdy      =0;
    
    #(10*CYCLE);
    b_rdy      =1;
    #(61*CYCLE);
    b_rdy      =0;
   /* 

     //传输时段2
    #(3*CYCLE);
    for(i=0;i<70;i=i+1) begin
        data_in_vld=1;
        data_in=$random;
        b_rdy  =1;
        #(1*CYCLE);
    end
    data_in_vld=0;
    data_in    =0 ;
    b_rdy      =0;
    */
    end
    
    endmodule
    
