





`timescale      1ns/1ps


module          testfifo3_2();
    reg                        clk         ;
    reg                        rst_n       ; 
    reg                        din_vld     ;
    reg                        din_sop     ;
    reg              [15:0]    din         ;
    reg                        din_eop     ;
 
    wire                       dout_vld    ;
    wire                       dout_sop    ;
    wire             [15:0]    dout        ;
    wire                       dout_eop    ;      




    parameter   PERIOD    = 20;   // ʱ�����ڣ���λΪns;
    parameter   RST_TIME  = 3 ;   // ��λʱ�䣬��ʱ��ʾ��λ3��ʱ�����ڵ�ʱ�䡣
    
    integer     i;
    integer     j;

    
    // ������ģ�������
    fifo_p uut_FIFO_exac_1632(
                                .clk         (   clk          ),  
                                .rst_n       (   rst_n        ), 
                                .din_vld     (   din_vld      ), 
                                .din_sop     (   din_sop      ), 
                                .din         (   din          ), 
                                .din_eop     (   din_eop      ),           
                                .dout_vld    (   dout_vld     ), 
                                .dout_sop    (   dout_sop     ), 
                                .dout        (   dout         ), 
                                .dout_eop    (   dout_eop     )    
                                );  


    //���ɱ���ʱ��50M��Ҳ���� always ���(ͬ��Ҫ�ȶ� clk �� initial ��ʼ����ֵ)��  always  #10  clk = ~clk;
    initial  begin
        clk = 1;
        forever   #(PERIOD/2)    clk=~clk;
    end



    // ������λ�ź�
    initial  begin
        rst_n = 1;
        #2;
        rst_n = 0;
        repeat(3)@(negedge clk);   // ���������� rst_n ��λ�ź�ʱ����ý� clk �ĳ�ʼ��ֵ��Ϊ clk==1��
        rst_n = 1;
    end






    // �����ź�din1��ֵ��ʽ
    initial  begin
        #1;              // ����ֵ
        din_vld = 0;
        din_sop = 0;
        din     = 16'h0; 
        din_eop = 0;        
        #(10*PERIOD);    // ��ʼ��ֵ

        for(j=0; j<4; j=j+1) begin

            for(i=0; i<60; i=i+1) begin
                din_vld =  1;
                din_sop = (i==0)?1:0;
                din     =((i==19 && j==0) || (i==19 && j==2))?16'h01:i+1;
                din_eop = (i==59)?1:0;
                #(1*PERIOD);
            end

            din_vld = 0;
            din_sop = 0;
            din     = 16'h0;
            din_eop = 0; 
            #(10*PERIOD);
        end

        din_vld = 0;
        din_sop = 0;
        din     = 16'h0;
        din_eop = 0; 
    end



endmodule
















