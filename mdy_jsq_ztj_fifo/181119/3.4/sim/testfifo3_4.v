`timescale 1 ns/1 ns// ʱ�䵥λ/ʱ�侫�ȣ�����RST_N=3.1,ֻ��ȡ��3�����ʱ�侫��Ϊ1ps,�����ȡ��3.1

module testfifo3_4();

    //ʱ�Ӻ͸�λ
reg clk  ;
reg rst_n;

//uut(����ģ������֮���ģ��)�������ź�(ע�⣺����ģ�������źŶ����reg)
reg    din_vld  ;
reg    din_sop  ;
reg    din_eop  ;
reg    din_err  ;
reg[15:0]  din   ;



//uut(����ģ������֮���ģ��)������ź�(ע�⣺����ģ������źŶ����wire)
wire      dout_vld;
wire      dout_sop;
wire      dout_eop;
wire[15:0]    dout;

//ʱ�����ڣ���λΪns�����ڴ��޸�ʱ�����ڡ�
parameter CYCLE    = 20;

//��λʱ�䣬��ʱ��ʾ��λ3��ʱ�����ڵ�ʱ�䡣
parameter RST_TIME = 3 ;

integer i;

//�����Ե�ģ������(.clkΪģ���źţ�clkΪ�����ļ�������ź�)
fifo_p uut(
         .clk             (clk      ), 
         .rst_n           (rst_n    ),
         .din_vld         (din_vld  ),
         .din_sop         (din_sop  ),
         .din_eop         (din_eop  ),
         .din_err         (din_err  ),
         .din             (din      ),
         .dout_vld        (dout_vld ),
         .dout_sop        (dout_sop ),
         .dout_eop        (dout_eop ),
         .dout            (dout     )
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

//�����źŸ�ֵ��ʽ
initial begin
#1;
din_vld=0;
din_sop=0;
din_eop=0;
din_err=0;
din =0;
//����ʱ��0
#(4*CYCLE);
for(i=0;i<12;i=i+1) begin
   din=(i==0)? 0001:din+1;
   din_sop=(i==0)? 1:0;
   din_eop=(i==11)? 1:0;
   din_err=0;
   din_vld=1;
   #(1*CYCLE);
end

din_vld=0;
din_sop=0;
din_eop=0;
din_err=0;
din =0;

//����ʱ��1
#(6*CYCLE);
for(i=0;i<100;i=i+1) begin
   din=(i==0)? 0000:din+1;
   din_sop=(i==0)? 1:0;
   din_eop=(i==99)? 1:0;
   din_err=(i==99)? 1:0;
   din_vld=1;
   #(1*CYCLE);
end

din_vld=0;
din_sop=0;
din_eop=0;
din_err=0;
din =0;
//����ʱ��2
#(6*CYCLE);
for(i=0;i<90;i=i+1) begin
   din=0;
   din_sop=(i==0)? 1:0;
   din_eop=(i==89)? 1:0;
   din_err=0;
   din_vld=1;
   #(1*CYCLE);
end

din_vld=0;
din_sop=0;
din_eop=0;
din_err=0;
din =0;
//����ʱ��3
#(6*CYCLE);
   din=16'b0000_0000_0000_1111;
   din_sop=1;  
   din_eop=0;
   din_err=0;
   din_vld=1;
   #(1*CYCLE);

   din=16'b0000_0000_1111_0000;
   din_sop=0;  
   din_eop=0;
   din_err=0;
   din_vld=1;
   #(1*CYCLE);

   din=16'b0000_1111_0000_0000;
   din_sop=0;  
   din_eop=0;
   din_err=0;
   din_vld=1;
   #(1*CYCLE);

   din=16'b1111_0000_0000_0001;
   din_sop=0;  
   din_eop=1;
   din_err=0;
   din_vld=1;
   #(1*CYCLE);

din_vld=0;
din_sop=0;
din_eop=0;
din_err=0;
din =0;
//����ʱ��4
#(6*CYCLE);
#(6*CYCLE);
   din=16'b0000_0000_0000_0001;
   din_sop=1;  
   din_eop=0;
   din_err=0;
   din_vld=1;
   #(1*CYCLE);

   din=16'b0000_0000_1001_1110;
   din_sop=0;  
   din_eop=0;
   din_err=0;
   din_vld=1;
   #(1*CYCLE);

   din=16'b0000_1111_0110_0000;
   din_sop=0;  
   din_eop=0;
   din_err=0;
   din_vld=0;
   #(1*CYCLE);

   din=16'b0111_0000_0000_0000;
   din_sop=0;  
   din_eop=1;
   din_err=0;
   din_vld=1;
   #(1*CYCLE);

   din=16'b1000_0000_0000_0001;
   din_sop=0;  
   din_eop=1;
   din_err=0;
   din_vld=1;
   #(1*CYCLE);

din_vld=0;
din_sop=0;
din_eop=0;
din_err=0;
din =0;
end
endmodule

