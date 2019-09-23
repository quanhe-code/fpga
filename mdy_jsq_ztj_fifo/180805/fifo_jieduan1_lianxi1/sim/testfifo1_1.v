`timescale 1 ns/1 ns// ʱ�䵥λ/ʱ�侫�ȣ�����RST_N=3.1,ֻ��ȡ��3�����ʱ�侫��Ϊ1ps,�����ȡ��3.1

module testfifo1_1();

    //ʱ�Ӻ͸�λ
    reg clk_in  ;
    reg rst_n   ;
    reg clk_out ;
    
    //uut(����ģ������֮���ģ��)�������ź�(ע�⣺����ģ�������źŶ����reg)
    reg[15:0]   data_in  ;
    reg         data_in_vld  ;
    reg         b_rdy        ;
    
    
    //uut(����ģ������֮���ģ��)������ź�(ע�⣺����ģ������źŶ����wire);
    wire        data_out_vld ;
    wire[15:0]  data_out   ;
    
    
    //ʱ�����ڣ���λΪns�����ڴ��޸�ʱ�����ڡ�
    parameter CYCLE    = 12.5;
    parameter CYCLE_W  = 10;
    integer     i ;
    //��λʱ�䣬��ʱ��ʾ��λ3��ʱ�����ڵ�ʱ�䡣
    parameter RST_TIME = 3 ;
    
    //�����Ե�ģ������(.clkΪģ���źţ�clkΪ�����ļ�������ź�)
    fifo_p uut(
    .clk_in          (clk_in     ), 
    .rst_n           (rst_n      ),
    .data_in         (data_in    ),
    .data_in_vld     (data_in_vld),
    .clk_out         (clk_out    ),
    .data_out        (data_out   ),
    .data_out_vld    (data_out_vld),
    .b_rdy           (b_rdy       )    
    );
    
    //ʱ�Ӻ͸�λģ��������д����Ϊ�̶�д��
    //���ɱ���ʱ��50M
    initial begin
    clk_in = 0;
    forever
    #(CYCLE/2)
    clk_in=~clk_in;
    end
     initial begin
    clk_out = 0;
    forever
    #(CYCLE_W/2)
    clk_out=~clk_out;
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
    #1;
    data_in_vld = 0;
    data_in     =0 ;
    b_rdy       =0 ;
    //����ʱ��1
    #(4*CYCLE);
    for(i=0;i<80;i=i+1) begin
        data_in_vld=1;
        data_in=$random;
        b_rdy  =0;
        #(1*CYCLE);
    end
    
    data_in_vld=0;
    data_in    =0 ;
    b_rdy      =0;
    
    #(10*CYCLE);
    b_rdy      =1;
    #(61*CYCLE);
    b_rdy      =0;
   /* 

     //����ʱ��2
    #(3*CYCLE);
    for(i=0;i<70;i=i+1) begin
        data_in_vld=1;
        data_in=$random;
        b_rdy  =1;
        #(1*CYCLE);
    end
    data_in_vld=0;
    data_in    =0 ;
    b_rdy      =0;
    */
    end
    
    endmodule
    
