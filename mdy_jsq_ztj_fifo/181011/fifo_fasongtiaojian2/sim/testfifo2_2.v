`timescale 1 ns/1 ns// ʱ�䵥λ/ʱ�侫�ȣ�����RST_N=3.1,ֻ��ȡ��3�����ʱ�侫��Ϊ1ps,�����ȡ��3.1

module testfifo2_2();

    //ʱ�Ӻ͸�λ
    reg clk  ;
    reg rst_n;
    
    //uut(����ģ������֮���ģ��)�������ź�(ע�⣺����ģ�������źŶ����reg)
    reg[7:0]        din        ;
    reg             din_vld    ;
    reg[9:0]        cfg_thd_0  ;
    reg[9:0]        cfg_thd_1  ;
        
    //uut(����ģ������֮���ģ��)������ź�(ע�⣺����ģ������źŶ���� wire)
    wire[7:0]      dout     ;
    wire           dout_vld ;
    
    
    //ʱ�����ڣ���λΪns�����ڴ��޸�ʱ�����ڡ�
    parameter CYCLE    = 20;
    
    //��λʱ�䣬��ʱ��ʾ��λ3��ʱ�����ڵ�ʱ�䡣
    parameter RST_TIME = 3 ;

     integer     i ;
    
    //�����Ե�ģ������(.clkΪģ���źţ�clkΪ�����ļ�������ź�)
    fifo_p uut(
    .clk          ( clk       ), 
    .rst_n        ( rst_n     ),
    .cfg_thd_0    ( cfg_thd_0 ),
    .cfg_thd_1    ( cfg_thd_1 ),
    .din          ( din       ),
    .din_vld      ( din_vld   ),
    .dout         ( dout      ),
    .dout_vld     (dout_vld   )    
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
    //����ģ������д����Ҫ���ݾ��������д
    //�����ź�din0��ֵ��ʽ
    initial begin
    #1;
    din_vld       =  0;
    din           =  0;
    cfg_thd_0     =  0; 
    cfg_thd_0     =  0;  
    #(4*CYCLE);
     din     = 8'h00;
    #(2*CYCLE);
    for(i=0;i<50;i=i+1) begin
        din=(i==0)? 00:din+1;
        din_vld     =  1 ;      
        cfg_thd_0   =  5 ;
        cfg_thd_1   =  25 ;
        #(1*CYCLE)  ;
    end
    din         = 0;
    din_vld     = 0;       
    end
    endmodule
    
