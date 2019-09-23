`timescale 1 ns/1 ns

module testfifo2_11();

//时钟和复位
reg clk_a  ;
reg clk_b  ;
reg clk_c  ;
reg clk_d  ;

reg rst_n;

//uut的输入信号
reg  [ 8-1:0]      data_a    ;
reg                data_a_vld;
reg                data_a_sop;
reg                data_a_eop;

reg  [16-1:0]      data_b    ;
reg                data_b_sop;
reg                data_b_eop;
reg[ 2-1:0]        data_b_mty;
reg                data_b_vld;

reg  [32-1:0]      data_c    ;
reg                data_c_sop;
reg                data_c_eop;
reg [ 2-1:0]       data_c_mty;
reg                data_c_vld;




    //uut的输出信号
wire [16-1:0]      data_d    ;
wire               data_d_vld;
wire               data_d_sop;
wire               data_d_eop;
wire               data_d_mty;
wire [ 2-1:0]      chan_d    ;


        //时钟周期，单位为ns，可在此修改时钟周期。
        parameter CYCLE_A    = 10;
        parameter CYCLE_B    = 14;
        parameter CYCLE_C    = 18;
        parameter CYCLE_D    = 22;

        //复位时间，此时表示复位3个时钟周期的时间。
        parameter RST_TIME = 3 ;

        //待测试的模块例化
        fifo_p uut(
              .rst_n     (rst_n),
              .clk_a     (clk_a),
              .clk_b     (clk_b),
              .clk_c     (clk_c),
              .clk_d     (clk_d),

              .data_a    (data_a    ),
              .data_a_vld(data_a_vld),
              .data_a_sop(data_a_sop),
              .data_a_eop(data_a_eop),

              .data_b_sop(data_b_sop),
              .data_b_eop(data_b_eop),
              .data_b_mty(data_b_mty),
              .data_b    (data_b    ),
              .data_b_vld(data_b_vld),

              .data_c    (data_c    ),
              .data_c_vld(data_c_vld),
              .data_c_sop(data_c_sop),
              .data_c_eop(data_c_eop),
              .data_c_mty(data_c_mty),

              .data_d    (data_d    ),
              .data_d_vld(data_d_vld),
              .data_d_sop(data_d_sop),
              .data_d_eop(data_d_eop),
              .data_d_mty(data_d_mty),
              .chan_d    (chan_d    )           
             
            );

    integer   i;
    integer   j;
    integer   k;
            //生成本地时钟
            initial begin
                clk_a = 0;
                forever
                #(CYCLE_A/2)
                clk_a=~clk_a;
            end

              //生成本地时钟
            initial begin
                clk_b = 0;
                forever
                #(CYCLE_B/2)
                clk_b=~clk_b;
            end

              //生成本地时钟
            initial begin
                clk_c = 0;
                forever
                #(CYCLE_C/2)
                clk_c=~clk_c;
            end

              //生成本地时钟
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
                #(CYCLE_A*RST_TIME);
                rst_n = 1;
            end

            //输入信号data_a赋值方式
            initial begin
                #1;
                //赋初值
                data_a = 0;
                #(10*CYCLE_A);
                //开始赋值
                for(i=0;i < 32; i= i+1)begin
                    data_a = $random;
                    #(1*CYCLE_A);
                end
            end

            initial begin
                #1;
                //赋初值
                data_a_vld = 0;
                #(10*CYCLE_A);
                //开始赋值                   
                data_a_vld = 1;
                #(32*CYCLE_A);
                data_a_vld = 0;
            end

            initial begin
                #1;
                //赋初值
                data_a_sop = 0;
                #(10*CYCLE_A);
                //开始赋值                   
                data_a_sop = 1;
                #(1*CYCLE_A);
                data_a_sop = 0;
            end
            initial begin
                #1;
                //赋初值
                data_a_eop = 0;
                #(10*CYCLE_A);
                //开始赋值                   
                data_a_eop = 0;
                #(31*CYCLE_A);
                data_a_eop = 1;
                #(1*CYCLE_A);
                data_a_eop = 0;
            end



            //输入信号data_b赋值方式
            initial begin
                #1;
                //赋初值
                data_b = 0;
                #(10*CYCLE_B);
                //开始赋值
                for(j=0;j < 32; j= j+1)begin
                    data_b = $random;
                    #(1*CYCLE_B);
                end
            end

              initial begin
                #1;
                //赋初值
                data_b_vld = 0;
                #(10*CYCLE_B);
                //开始赋值                   
                data_b_vld = 1;
                #(32*CYCLE_B);
                data_b_vld = 0;
            end

            initial begin
                #1;
                //赋初值
                data_b_sop = 0;
                #(10*CYCLE_B);
                //开始赋值                   
                data_b_sop = 1;
                #(1*CYCLE_B);
                data_b_sop = 0;
            end

             initial begin
                #1;
                //赋初值
                data_b_eop = 0;
                #(10*CYCLE_B);
                //开始赋值                   
                data_b_eop = 0;
                #(31*CYCLE_B);
                data_b_eop = 1;
                #(1*CYCLE_B);
                data_b_eop = 0;
            end

            initial begin
                #1;
                //赋初值
                data_b_mty = 0;
                #(10*CYCLE_B);
                //开始赋值                   
                data_b_mty = 0;
                #(31*CYCLE_B);
                data_b_mty = 1;
                #(1*CYCLE_B);
                data_b_mty = 0;
            end


            initial begin
                #1;
                //赋初值
                data_c = 0;
                #(10*CYCLE_C);
                //开始赋值
                for(k=0;k < 32; k= k+1)begin
                    data_c = $random;
                    #(1*CYCLE_C);
                end
            end
            initial begin
                #1;
                //赋初值
                data_c_vld = 0;
                #(10*CYCLE_C);
                //开始赋值                   
                data_c_vld = 1;
                #(32*CYCLE_C);
                data_c_vld = 0;
            end

              initial begin
                #1;
                //赋初值
                data_c_sop = 0;
                #(10*CYCLE_C);
                //开始赋值                   
                data_c_sop = 1;
                #(1*CYCLE_C);
                data_c_sop = 0;
            end

             initial begin
                #1;
                //赋初值
                data_c_eop = 0;
                #(10*CYCLE_C);
                //开始赋值                   
                data_c_eop = 0;
                #(31*CYCLE_C);
                data_c_eop = 1;
                #(1*CYCLE_C);
                data_c_eop = 0;
            end

            initial begin
                #1;
                //赋初值
                data_c_mty = 0;
                #(10*CYCLE_C);
                //开始赋值                   
                data_c_mty = 0;
                #(31*CYCLE_C);
                data_c_mty = 2;
                #(1*CYCLE_C);
                data_c_mty = 0;
            end



            endmodule


