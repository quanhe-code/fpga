`timescale 1 ns/1 ns

module testfifo1_9();

reg clk;
reg rst_n;

//uut�������ź�
reg [7:0]   din      ;
reg         din_vld  ;
reg         din_sop  ;
reg         din_eop  ;
reg         b_rty    ;
//uut������ź�
wire[15:0]   dout    ;
wire        dout_vld;
wire        dout_sop;
wire        dout_eop;
//ʱ�����ڣ���λΪns�����ڴ��޸�ʱ�����ڡ�
parameter CYCLE    = 20;

//��λʱ�䣬��ʱ��ʾ��λ3��ʱ�����ڵ�ʱ�䡣
parameter RST_TIME = 3 ;

//�����Ե�ģ������
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

       //���ɱ���ʱ��50M
       initial begin
         clk = 0;
         forever
         #(CYCLE/2)
         clk=~clk;
       end

       //������λ�ź�
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
       //�����ź�din
       initial begin
         #1;
         //����ֵ
         din     =0;
         din_sop =0;
         din_eop =0;
         din_vld =0;
         b_rty   =0;
         #(CYCLE*RST_TIME);
         #(10*CYCLE);
         //��ʼ��ֵ
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

