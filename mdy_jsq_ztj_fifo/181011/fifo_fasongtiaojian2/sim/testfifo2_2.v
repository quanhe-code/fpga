`timescale 1 ns/1 ns// 时间单位/时间精度（例如RST_N=3.1,只能取到3；如果时间精度为1ps,则可以取到3.1

module testfifo2_2();

    //时钟和复位
    reg clk  ;
    reg rst_n;
    
    //uut(被测模块例化之后的模块)的输入信号(注意：被测模块输入信号定义成reg)
    reg[7:0]        din        ;
    reg             din_vld    ;
    reg[9:0]        cfg_thd_0  ;
    reg[9:0]        cfg_thd_1  ;
        
    //uut(被测模块例化之后的模块)的输出信号(注意：被测模块输出信号定义成 wire)
    wire[7:0]      dout     ;
    wire           dout_vld ;
    
    
    //时钟周期，单位为ns，可在此修改时钟周期。
    parameter CYCLE    = 20;
    
    //复位时间，此时表示复位3个时钟周期的时间。
    parameter RST_TIME = 3 ;

     integer     i ;
    
    //待测试的模块例化(.clk为模块信号，clk为测试文件定义的信号)
    fifo_p uut(
    .clk          ( clk       ), 
    .rst_n        ( rst_n     ),
    .cfg_thd_0    ( cfg_thd_0 ),
    .cfg_thd_1    ( cfg_thd_1 ),
    .din          ( din       ),
    .din_vld      ( din_vld   ),
    .dout         ( dout      ),
    .dout_vld     (dout_vld   )    
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
    //输入模块驱动写法需要根据具体情况来写
    //输入信号din0赋值方式
    initial begin
    #1;
    din_vld       =  0;
    din           =  0;
    cfg_thd_0     =  0; 
    cfg_thd_0     =  0;  
    #(4*CYCLE);
     din     = 8'h00;
    #(2*CYCLE);
    for(i=0;i<50;i=i+1) begin
        din=(i==0)? 00:din+1;
        din_vld     =  1 ;      
        cfg_thd_0   =  5 ;
        cfg_thd_1   =  25 ;
        #(1*CYCLE)  ;
    end
    din         = 0;
    din_vld     = 0;       
    end
    endmodule
    
