





`timescale      1ns/1ps


module          testfifo3_2();
    reg                        clk         ;
    reg                        rst_n       ; 
    reg                        din_vld     ;
    reg                        din_sop     ;
    reg              [15:0]    din         ;
    reg                        din_eop     ;
 
    wire                       dout_vld    ;
    wire                       dout_sop    ;
    wire             [15:0]    dout        ;
    wire                       dout_eop    ;      




    parameter   PERIOD    = 20;   // 时钟周期，单位为ns;
    parameter   RST_TIME  = 3 ;   // 复位时间，此时表示复位3个时钟周期的时间。
    
    integer     i;
    integer     j;

    
    // 待测试模块的例化
    fifo_p uut_FIFO_exac_1632(
                                .clk         (   clk          ),  
                                .rst_n       (   rst_n        ), 
                                .din_vld     (   din_vld      ), 
                                .din_sop     (   din_sop      ), 
                                .din         (   din          ), 
                                .din_eop     (   din_eop      ),           
                                .dout_vld    (   dout_vld     ), 
                                .dout_sop    (   dout_sop     ), 
                                .dout        (   dout         ), 
                                .dout_eop    (   dout_eop     )    
                                );  


    //生成本地时钟50M：也可用 always 语句(同样要先对 clk 做 initial 初始化赋值)：  always  #10  clk = ~clk;
    initial  begin
        clk = 1;
        forever   #(PERIOD/2)    clk=~clk;
    end



    // 产生复位信号
    initial  begin
        rst_n = 1;
        #2;
        rst_n = 0;
        repeat(3)@(negedge clk);   // 本方法产生 rst_n 复位信号时，最好将 clk 的初始化值赋为 clk==1；
        rst_n = 1;
    end






    // 输入信号din1赋值方式
    initial  begin
        #1;              // 赋初值
        din_vld = 0;
        din_sop = 0;
        din     = 16'h0; 
        din_eop = 0;        
        #(10*PERIOD);    // 开始赋值

        for(j=0; j<4; j=j+1) begin

            for(i=0; i<60; i=i+1) begin
                din_vld =  1;
                din_sop = (i==0)?1:0;
                din     =((i==19 && j==0) || (i==19 && j==2))?16'h01:i+1;
                din_eop = (i==59)?1:0;
                #(1*PERIOD);
            end

            din_vld = 0;
            din_sop = 0;
            din     = 16'h0;
            din_eop = 0; 
            #(10*PERIOD);
        end

        din_vld = 0;
        din_sop = 0;
        din     = 16'h0;
        din_eop = 0; 
    end



endmodule
















