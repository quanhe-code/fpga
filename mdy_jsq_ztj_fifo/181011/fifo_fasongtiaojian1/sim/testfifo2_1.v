`timescale 1 ns/1 ns

module testfifo2_1();

reg clk;
reg rst_n;

//uut�������ź�
reg [8-1:0]  din        ;
reg          din_vld    ;
reg [10-1:0] cfg_thd    ;
reg [2-1:0]  baowen_slot;

    //uut������ź�
wire[8-1:0]  dout       ;
wire         dout_vld   ;
        //ʱ�����ڣ���λΪns�����ڴ��޸�ʱ�����ڡ�
        parameter CYCLE    = 20;

        //��λʱ�䣬��ʱ��ʾ��λ3��ʱ�����ڵ�ʱ�䡣
        parameter RST_TIME = 3 ;

        //�����Ե�ģ������
        fifo_p uut(        
                    .clk     (clk)    ,
                    .rst_n   (rst_n)  ,
                    .din     (din)    ,
                    .din_vld (din_vld),
                    .cfg_thd (cfg_thd),
                    .dout    (dout)   ,
                    .dout_vld(dout_vld));

            //���ɱ���ʱ��50M
            initial begin
                clk = 0  ;
                forever
                #(CYCLE/2)
                clk =~clk;
            end
            //������λ�ź�
            initial begin
                rst_n = 1;
                #2;
                rst_n = 0;
                #(CYCLE*RST_TIME);
                rst_n = 1;
            end

            //�����ź�din0��ֵ��ʽ
            initial begin
                #1;
                //����ֵ
                din     =0;
                din_vld =0;
                cfg_thd =0;
                #(CYCLE*RST_TIME);
                #(10*CYCLE);

                //��ʼ��ֵ
                baowen_slot = 2;
                cfg_thd = 10;
                forever begin
                din     = $random;
                din_vld = $random;
                #(baowen_slot*CYCLE);
                end        
            end

endmodule

