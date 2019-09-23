`timescale 1 ns/1 ns// ʱ�䵥λ/ʱ�侫�ȣ�����RST_N=3.1,ֻ��ȡ��3�����ʱ�侫��Ϊ1ps,�����ȡ��3.1

module testfifo2_3();

    //ʱ�Ӻ͸�λ
    reg clk  ;
    reg rst_n   ;
    
    //uut(����ģ������֮���ģ��)�������ź�(ע�⣺����ģ�������źŶ����reg)
    reg[7:0]        din      ;
    reg             din_vld  ;
    reg             din_sop  ;
    reg             din_eop  ;

    
    //uut(����ģ������֮���ģ��)������ź�(ע�⣺����ģ������źŶ���� wire)
    wire[7:0]            dout        ;
    wire                 dout_vld    ;
    wire                 dout_sop    ;
    wire                 dout_eop    ;
  
    
    //ʱ�����ڣ���λΪns�����ڴ��޸�ʱ�����ڡ�
    parameter CYCLE      = 20;
    
    //��λʱ�䣬��ʱ��ʾ��λ3��ʱ�����ڵ�ʱ�䡣
    parameter RST_TIME = 3 ;

    integer     i ;
    
    //�����Ե�ģ������(.clkΪģ���źţ�clkΪ�����ļ�������ź�)
    fifo_p uut(
    .clk             ( clk        ), 
    .rst_n           ( rst_n      ),
    .din             ( din        ),
    .din_vld         ( din_vld    ),
    .din_sop         ( din_sop    ),
    .din_eop         ( din_eop    ),
    .dout            ( dout       ),
    .dout_vld        ( dout_vld   ),
    .dout_sop        ( dout_sop   ),
    .dout_eop        ( dout_eop   )  
    );
    
    //ʱ�Ӻ͸�λģ��������д����Ϊ�̶�д��
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
    //�����ź�din0��ֵ��ʽ
    initial begin
    #1;   
    din     =  0;
    din_vld =  0; 
    din_sop =  0;
    din_eop =  0;
    #(3*CYCLE);
    din     = 8'h00;
    #(2*CYCLE);
    for(i=0;i<290;i=i+1) begin
        din=(i==0)? 00:din+1;
        din_vld   = 1;
        din_sop=(i==0)?  1:0 ;
        din_eop=(i==256)? 1:0 ;       
        #(1*CYCLE)  ;
    end

    din         = 0;
    din_vld     = 0;
    din_sop     = 0;
    din_eop     = 0;
    end
    endmodule
    
