`timescale 1 ns/1 ns

module testfifo2_5();

//时钟和复位
reg clk_a ;
reg clk_b ;
reg clk_c ;
reg clk_d ;
reg rst_n ;

//uut的输入信号
reg[15:0]  data_a    ;
reg        data_a_vld;
reg[15:0]  data_b    ;
reg        data_b_vld;
reg[15:0]  data_c    ;
reg        data_c_vld;

    //uut的输出信号
    wire        data_d_vld;
    wire [15:0] data_d    ;
    wire [ 1:0] chan_d    ;

        //时钟周期，单位为ns，可在此修改时钟周期。
        parameter CYCLE    = 40;

        //复位时间，此时表示复位3个时钟周期的时间。
        parameter RST_TIME = 3 ;

        //待测试的模块例化
        fifo_p uut(
            .clk_a        (clk_a     ), 
            .rst_n        (rst_n     ),
            .data_a       (data_a    ),
            .data_a_vld   (data_a_vld),
            .clk_b        (clk_b     ),
            .data_b       (data_b    ),
            .data_b_vld   (data_b_vld),
            .clk_c        (clk_c     ),
            .data_c       (data_c    ),
            .data_c_vld   (data_c_vld),
            .clk_d        (clk_d     ),
            .data_d       (data_d    ),
            .data_d_vld   (data_d_vld),
            .chan_d       (chan_d    )
            );


            //生成本地时钟50M
            initial begin
                clk_a = 0;
                forever
                #(CYCLE/2)
                clk_a=~clk_a;
            end
            initial begin
                clk_b = 0;
                forever
                #(CYCLE/4)
                clk_b=~clk_b;
            end
            initial begin
                clk_c = 0;
                forever
                #(CYCLE/5)
                clk_c=~clk_c;
            end
            initial begin
                clk_d = 0;
                forever
                #(CYCLE/10)
                clk_d=~clk_d;
            end
            //产生复位信号
            initial begin
                rst_n = 1;
                #2;
                rst_n = 0;
                #(CYCLE*RST_TIME);
                rst_n = 1;
            end
            integer         i;
            integer         j;
            integer         k;
            //输入信号din0赋值方式
            initial begin
                #1;
                //赋初值
                data_a = 0;
                data_a_vld = 0;
                #(10*CYCLE);
                data_a_vld = 1;
                for(i=0;i<100;i=i+1)begin
                    data_a = data_a + 1;
                    #(CYCLE);
                end
                data_a_vld = 0;
                //开始赋值
            end

            initial begin
                #1;
                //赋初值
                data_b = 0;
                data_b_vld = 0;
                #(10*CYCLE);
                #(CYCLE);
                data_b_vld = 1;
                for(j=0;j<100;j=j+1)begin
                    data_b = data_b + 1;
                    #(CYCLE/2);
                end
                data_b_vld = 0;
                //开始赋值
            end

            initial begin
                #1;
                //赋初值
                data_c = 0;
                #(10*CYCLE);
                #(2*CYCLE);
                data_c_vld = 1;
                for(k=0;k<100;k=k+1)begin
                    data_c = data_c + 1;
                    #(CYCLE*2/5);
                end
                data_c_vld = 0;
                //开始赋值
            end

            endmodule

