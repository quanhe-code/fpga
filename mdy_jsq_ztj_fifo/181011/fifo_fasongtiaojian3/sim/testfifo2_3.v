`timescale 1 ns/1 ns// 时间单位/时间精度（例如RST_N=3.1,只能取到3；如果时间精度为1ps,则可以取到3.1

module testfifo2_3();

    //时钟和复位
    reg clk  ;
    reg rst_n   ;
    
    //uut(被测模块例化之后的模块)的输入信号(注意：被测模块输入信号定义成reg)
    reg[7:0]        din      ;
    reg             din_vld  ;
    reg             din_sop  ;
    reg             din_eop  ;

    
    //uut(被测模块例化之后的模块)的输出信号(注意：被测模块输出信号定义成 wire)
    wire[7:0]            dout        ;
    wire                 dout_vld    ;
    wire                 dout_sop    ;
    wire                 dout_eop    ;
  
    
    //时钟周期，单位为ns，可在此修改时钟周期。
    parameter CYCLE      = 20;
    
    //复位时间，此时表示复位3个时钟周期的时间。
    parameter RST_TIME = 3 ;

    integer     i ;
    
    //待测试的模块例化(.clk为模块信号，clk为测试文件定义的信号)
    fifo_p uut(
    .clk             ( clk        ), 
    .rst_n           ( rst_n      ),
    .din             ( din        ),
    .din_vld         ( din_vld    ),
    .din_sop         ( din_sop    ),
    .din_eop         ( din_eop    ),
    .dout            ( dout       ),
    .dout_vld        ( dout_vld   ),
    .dout_sop        ( dout_sop   ),
    .dout_eop        ( dout_eop   )  
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
    //输入信号din0赋值方式
    initial begin
    #1;   
    din     =  0;
    din_vld =  0; 
    din_sop =  0;
    din_eop =  0;
    #(3*CYCLE);
    din     = 8'h00;
    #(2*CYCLE);
    for(i=0;i<290;i=i+1) begin
        din=(i==0)? 00:din+1;
        din_vld   = 1;
        din_sop=(i==0)?  1:0 ;
        din_eop=(i==256)? 1:0 ;       
        #(1*CYCLE)  ;
    end

    din         = 0;
    din_vld     = 0;
    din_sop     = 0;
    din_eop     = 0;
    end
    endmodule
    
