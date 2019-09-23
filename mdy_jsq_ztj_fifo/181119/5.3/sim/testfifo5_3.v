`timescale 1 ns/1 ns

module testfifo5_3();

//时钟和复位
reg clk  ;
reg rst_n;

//uut的输入信号
reg     din_sop       ;
reg     din_eop       ;
reg     din_vld       ;
reg  [7:0]   din     ;


    //uut的输出信号
wire        dout_vld    ;
wire [7:0]  dout        ;
wire        dout_eop    ;
wire        dout_sop    ;

//待测试的模块例化
fifo_p uut(
    .clk        (clk            ),      
    .rst_n      (rst_n          ),                  
    .din        (din            ),               
    .din_sop    (din_sop        ),              
    .din_eop    (din_eop        ),               
    .din_vld    (din_vld        ),         
    .dout       (dout           ),                
    .dout_vld   (dout_vld       ),               
    .dout_sop   (dout_sop       ),                 
    .dout_eop   (dout_eop       )             
 );


    //时钟周期，单位为ns，可在此修改时钟周期。
parameter CYCLE    = 20;

//复位时间，此时表示复位3个时钟周期的时间。
parameter RST_TIME = 3 ;
integer     i ; 


//生成本地时钟50M
initial begin
    clk = 1;
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
    //赋初值
    din    =0   ;
    din_sop=0   ;
    din_eop=0   ;
    din_vld=0   ;
    #(10*CYCLE);

    for (i=1 ; i<1533 ;i=i+1)begin
        din     =  i;
        din_vld =  1           ;
        din_sop =  (i==1 )?1:0 ;
        din_eop =  (i==1532)?1:0 ;
        #(CYCLE);
    end
    din    =0   ;
    din_sop=0   ;
    din_eop=0   ;
    din_vld=0   ;
    #(20*CYCLE);

    for (i=1 ; i<1560 ;i=i+1)begin
        din     =  i;
        din_vld =  1           ;
        din_sop =  (i==1 )?1:0 ;
        din_eop =  (i==1559)?1:0 ;
        #(CYCLE);
    end
    din    =0   ;
    din_sop=0   ;
    din_eop=0   ;
    din_vld=0   ;
    #(20*CYCLE);
   
end

endmodule

