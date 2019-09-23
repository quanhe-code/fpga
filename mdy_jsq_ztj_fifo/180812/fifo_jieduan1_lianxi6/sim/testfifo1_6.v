`timescale 1 ns/1 ns

module testfifo1_6(); 

//ʱ�Ӻ͸�λ
reg     clk     ;
reg     rst_n   ;
reg [7:0] din   ;
reg     din_vld ;
reg     din_sop ;
reg     din_eop ;
reg     rdy     ;
    //�����ź�,����dout
wire [7:0] dout ;
wire    dout_vld;
wire    dout_sop;
wire    dout_eop;
          
        //ʱ�����ڣ���λΪns�����ڴ��޸�ʱ�����ڡ�
        parameter CYCLE    = 20;

        //��λʱ�䣬��ʱ��ʾ��λ3��ʱ�����ڵ�ʱ�䡣
        parameter RST_TIME = 3 ;
         integer        i      ;
        //�����Ե�ģ������
         fifo_p uut (
            .clk       (clk     ),
            .rst_n     (rst_n   ), 
            .din       (din     ),
            .din_vld   (din_vld ),
            .din_sop   (din_sop ),
            .din_eop   (din_eop ),
            .dout      (dout    ),
            .dout_vld  (dout_vld),
            .dout_sop  (dout_sop),
            .dout_eop  (dout_eop),
            .b_rdy       (rdy     )
            );

            //���ɱ���ʱ��50M
            initial begin  //ʱ�Ӹ�λ�źŹ̶����䡣
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

            //�����źŸ�ֵ��ʽ
         initial begin
                #1        ;
                //����ֵ
                din     = 0;
                din_vld = 0;
                din_sop = 0;
                din_eop = 0;
                rdy     = 0;
            #(CYCLE*RST_TIME); 

            for(i=0;i<150;i=i+1) begin
                din = i;
                rdy     = 1;
                din_vld = 1;
                din_sop = (i==0)?1:0  ;
                din_eop = (i==149)?1:0;
                #CYCLE; 
            end 
                din     = 0;
                din_vld = 0;
                din_sop = 0;
                din_eop = 0;
                #(CYCLE * 2);
                rdy     = 0;
           end
endmodule





