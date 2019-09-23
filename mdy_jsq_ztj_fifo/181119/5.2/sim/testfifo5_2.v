`timescale 1 ns/1 ns

module testfifo5_2();

//ʱ�Ӻ͸�λ
reg clk  ;
reg rst_n;

//uut�������ź�
reg     din_sop       ;
reg     din_eop       ;
reg     din_vld       ;
reg  [7:0]   din     ;


    //uut������ź�
wire        dout_vld    ;
wire [7:0]  dout        ;
wire        dout_eop    ;
wire        dout_sop    ;


        //ʱ�����ڣ���λΪns�����ڴ��޸�ʱ�����ڡ�
        parameter CYCLE    = 20;

        //��λʱ�䣬��ʱ��ʾ��λ3��ʱ�����ڵ�ʱ�䡣
        parameter RST_TIME = 3 ;
        integer     i ; 

        //�����Ե�ģ������
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


            //���ɱ���ʱ��50M
            initial begin
                clk = 1;
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

            //�����ź�din0��ֵ��ʽ
            initial begin
                #1;
                //����ֵ
                din    =0   ;
                din_sop=0   ;
                din_eop=0   ;
                din_vld=0   ;
                #(10*CYCLE);
                repeat (10)begin
                    for (i=1 ; i<1000 ;i=i+1)begin
                        din     =  (i==999)?1:i ;
                        din_vld =  1           ;
                        din_sop =  (i==1 )?1:0 ;
                        din_eop =  (i==999)?1:0 ;
                        #(CYCLE);
                    end
                    din    =0   ;
                    din_sop=0   ;
                    din_eop=0   ;
                    din_vld=0   ;
                    #(20*CYCLE);
                end
                din    =0   ;
                din_sop=0   ;
                din_eop=0   ;
                din_vld=0   ;
            end
            endmodule

