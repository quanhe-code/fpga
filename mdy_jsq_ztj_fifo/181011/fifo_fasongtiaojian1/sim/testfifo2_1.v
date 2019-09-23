`timescale 1 ns/1 ns

module testfifo2_1();

reg clk;
reg rst_n;

//uut的输入信号
reg [8-1:0]  din        ;
reg          din_vld    ;
reg [10-1:0] cfg_thd    ;
reg [2-1:0]  baowen_slot;

    //uut的输出信号
wire[8-1:0]  dout       ;
wire         dout_vld   ;
        //时钟周期，单位为ns，可在此修改时钟周期。
        parameter CYCLE    = 20;

        //复位时间，此时表示复位3个时钟周期的时间。
        parameter RST_TIME = 3 ;

        //待测试的模块例化
        fifo_p uut(        
                    .clk     (clk)    ,
                    .rst_n   (rst_n)  ,
                    .din     (din)    ,
                    .din_vld (din_vld),
                    .cfg_thd (cfg_thd),
                    .dout    (dout)   ,
                    .dout_vld(dout_vld));

            //生成本地时钟50M
            initial begin
                clk = 0  ;
                forever
                #(CYCLE/2)
                clk =~clk;
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
                din     =0;
                din_vld =0;
                cfg_thd =0;
                #(CYCLE*RST_TIME);
                #(10*CYCLE);

                //开始赋值
                baowen_slot = 2;
                cfg_thd = 10;
                forever begin
                din     = $random;
                din_vld = $random;
                #(baowen_slot*CYCLE);
                end        
            end

endmodule

