`timescale 1 ns/1 ns

module testfifo1_8(); 

//时钟和复位
reg     clk     ;
reg     rst_n   ;
reg [31:0] din  ;
reg     din_vld ;
reg     din_sop ;
reg     din_eop ;
reg [1:0]    din_mty ;
reg     rdy     ;
    //其他信号,举例dout
wire [7:0] dout ;
wire    dout_vld;
wire    dout_sop;
wire    dout_eop;
          
        //时钟周期，单位为ns，可在此修改时钟周期。
        parameter CYCLE    = 20;

        //复位时间，此时表示复位3个时钟周期的时间。
        parameter RST_TIME = 3 ;
         integer        i      ;
        //待测试的模块例化
         fifo_p uut (
            .clk       (clk     ),
            .rst_n     (rst_n   ), 
            .din       (din     ),
            .din_vld   (din_vld ),
            .din_sop   (din_sop ),
            .din_eop   (din_eop ),
            .din_mty   (din_mty ),
            .dout      (dout    ),
            .dout_vld  (dout_vld),
            .dout_sop  (dout_sop),
            .dout_eop  (dout_eop), 
            .b_rdy      (rdy)
            );

            //生成本地时钟50M
            initial begin  //时钟复位信号固定不变。
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

            //输入信号赋值方式
         initial begin
                #1        ;
                //赋初值
                din     = 0;
                rdy     = 0;
                din_vld = 0;
                din_sop = 0;
                din_eop = 0;
                din_mty = 2;
            #(CYCLE*RST_TIME); 

            for(i=0;i<40;i=i+1) begin
                din = i;
                din_vld = 1;
                rdy     = 1;
                din_sop = (i==0)?1:0  ;
                din_eop = (i==39)?1:0;
                #CYCLE; 
            end
                din     = 0;
                din_vld = 0;
                din_sop = 0;
                din_eop = 0;
            end
endmodule







