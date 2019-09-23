`timescale 1 ns/1 ns

module testfifo1_9();

reg clk;
reg rst_n;

//uut的输入信号
reg [7:0]   din      ;
reg         din_vld  ;
reg         din_sop  ;
reg         din_eop  ;
reg         b_rty    ;
//uut的输出信号
wire[15:0]   dout    ;
wire        dout_vld;
wire        dout_sop;
wire        dout_eop;
//时钟周期，单位为ns，可在此修改时钟周期。
parameter CYCLE    = 20;

//复位时间，此时表示复位3个时钟周期的时间。
parameter RST_TIME = 3 ;

//待测试的模块例化
fifo_p uut(        
            .clk     (clk)     ,
            .rst_n   (rst_n)   ,
            .din     (din)     ,
            .din_vld (din_vld) ,
            .din_sop (din_sop) ,
            .din_eop (din_eop) , 
            .b_rdy   (b_rty)   ,
            .dout    (dout)    ,
            .dout_vld(dout_vld),
            .dout_sop(dout_sop),
            .dout_eop(dout_eop),
            .dout_mty(dout_mty));

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

       integer         i;
       reg     [8-1:0] len ;
       reg     [2-1:0] len1;
       //输入信号din
       initial begin
         #1;
         //赋初值
         din     =0;
         din_sop =0;
         din_eop =0;
         din_vld =0;
         b_rty   =0;
         #(CYCLE*RST_TIME);
         #(10*CYCLE);
         //开始赋值
         //a
            forever begin
                len =   $random;
                len =   len%141;
                for(i=60;i<(len+60);i=i+1)begin
                    din     = $random           ;
                    din_sop = (i==60)?1:0       ;
                    din_eop = (i>=len+60-1)?1:0 ;
                    din_vld = (din_sop || din_eop) ? 1 : $random           ;
                    b_rty   = $random && din_vld;
                    #(1*CYCLE);
                end
                din     =1;
                din_sop =0;
                din_eop =0;
                din_vld =0;
                
                len1    =$random;
                #(len1*CYCLE);
            end
               
        end
endmodule

