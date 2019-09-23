`timescale 1 ns/1 ns// 时间单位/时间精度（例如RST_N=3.1,只能取到3；如果时间精度为1ps,则可以取到3.1
module testfifo2_4();    
    //输入信号
    reg             clk     ;
    reg             rst_n   ;
    reg             din_vld ;
    reg[7 : 0]      din     ;
    reg             din_sop ;
    reg             din_eop ;

    //uut的输出信号
    wire[31:0]            dout    ;
    wire            dout_sop;
    wire            dout_eop;
    wire            dout_vld;
    wire[1:0]            dout_mty;
    integer         i       ;
    integer         j       ;
    integer         randlen ;
    //表示产生的clk的周期，单位是ns 
    parameter CYCLE    = 20;

    //复位时间，表示复位3个clk
    parameter RST_TIME = 2 ;

    //待测试的例化模块
    fifo_p uut(
        .clk       (clk     ), 
        .rst_n     (rst_n   ),
        .din_vld   (din_vld ),
        .din       (din     ),
        .din_sop   (din_sop ),
        .din_eop   (din_eop ),
        .dout      (dout    ), 
        .dout_sop  (dout_sop),
        .dout_eop  (dout_eop),
        .dout_vld  (dout_vld),
        .dout_mty  (dout_mty)
        );
        //产生本地时钟
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
            #(RST_TIME * CYCLE);
            rst_n = 1;
        end

        //输入信号din赋值方式
        initial begin
            #1;
            //赋初值
            din_vld = 0;
            din_sop = 0;
            din_eop = 0;
            din     = 0;

            din = 0;
            #(RST_TIME * CYCLE);
            //开始赋值
            //外层循环控制报文个数  
            for(i = 0; i < 10 - 1; i = i + 1) begin//报文个数少的话长度相似的概率很大
               randlen = $random % 100;
               for(j = 1; j < randlen; j = j + 1) begin
                    din_vld = 1;
                    din_sop = (j == 1) ? 1 : 0;
                    din_eop = (j == (randlen - 1)) ? 1 : 0;
                    din     = j;
                    #(CYCLE);//切记要有这一行
                end
                
                din_vld = 0;
                din_sop = 0;
                din_eop = 0;
                din     = 0;
                #(2 * CYCLE); 
            end
        end
/*
               for(j = 1; j < 66; j = j + 1) begin
                    din_vld = 1;
                    din_sop = (j == 1) ? 1 : 0;
                    din_eop = (j == 66 - 1) ? 1 : 0;
                    din     = j;
                    #(CYCLE);//切记要有这一行
                end
                
                din_vld = 0;
                din_sop = 0;
                din_eop = 0;
                din     = 0;
                #(2 * CYCLE);
            end
*/
endmodule







