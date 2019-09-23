
`timescale      1ns/1ps


module          testfifo3_1();

    reg                        clk_wr      ; 
    reg                        clk_rd      ;
    reg                        rst_n       ;
    reg                        b_rdy       ;
    reg                        din_vld     ;
    reg                        din_sop     ;
    reg             [7 :0]     din         ;
    reg                        din_eop     ;

    wire                       dout_vld    ;
    wire                       dout_sop    ;
    wire            [7 :0]     dout        ;
    wire                       dout_eop    ;   




    parameter   PERIOD_WR    = 10;         // ʱ�����ڣ���λΪns;
    parameter   PERIOD_RD    = 40;         // ʱ�����ڣ���λΪns;
    parameter   RST_TIME     = 3 ;         // ��λʱ�䣬��ʱ��ʾ��λ3��ʱ�����ڵ�ʱ�䡣


    integer     i;
    integer     j;


    // ������ģ�������
    fifo_p     uut_FIFO_exac_1631(
                                .clk_in     (   clk_wr      ),        
                                .clk_out     (   clk_rd      ),
                                .rst_n      (   rst_n       ),
                                .b_rdy      (   b_rdy       ),
                                .din_vld    (   din_vld     ),
                                .din_sop    (   din_sop     ),
                                .din        (   din         ),
                                .din_eop    (   din_eop     ),
                           
                                .dout_vld   (   dout_vld    ),
                                .dout_sop   (   dout_sop    ),
                                .dout       (   dout        ),
                                .dout_eop   (   dout_eop    )   
                                );




    //���ɱ���ʱ��50M��Ҳ���� always ���(ͬ��Ҫ�ȶ� clk �� initial ��ʼ����ֵ)��  always  #10  clk = ~clk;
    initial  begin
        clk_wr = 1;
        forever   #(PERIOD_WR/2)    clk_wr=~clk_wr;
    end


    initial  begin
        clk_rd = 1;
        forever   #(PERIOD_RD/2)    clk_rd=~clk_rd;
    end



    // ������λ�ź�
    initial  begin
        rst_n = 1;
        #2;
        rst_n = 0;
        repeat(3)@(negedge clk_wr);   // ���������� rst_n ��λ�ź�ʱ����ý� clk �ĳ�ʼ��ֵ��Ϊ clk==1��
        rst_n = 1;
    end



    // �����ź�din1��ֵ��ʽ
    initial  begin
        #1;              // ����ֵ
        b_rdy    = 0;
        din_vld  = 0;
        din_sop  = 0;
        din      = 8'h0;
        din_eop  = 0;
        #(7*PERIOD_WR);    // ��ʼ��ֵ

        b_rdy    = 1;
        din_vld  = 0;
        din_sop  = 0;
        din      = 8'h0;
        din_eop  = 0;
        #(3*PERIOD_WR);    // ��ʼ��ֵ


        b_rdy    = 1;
        for(j=0; j<15; j=j+1) begin

            for(i=0; i<191; i=i+1) begin
                din_vld  = 1;
                din_sop  = (i==0)?1:0;
                din      =  i ;
                din_eop  = (i==190)?1:0;
                #(1*PERIOD_WR);  
            end 
            din_vld  = 0;
            din_sop  = 0;
            din      = 8'h0;
            din_eop  = 0;
            #(5*PERIOD_WR);
        end

        b_rdy    = 1;
        din_vld  = 0;
        din_sop  = 0;
        din      = 8'h0;
        din_eop  = 0;
        
        #(10*PERIOD_WR);
        b_rdy    = 0;
    end


endmodule

















