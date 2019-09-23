`timescale 1 ns/1 ns// ʱ�䵥λ/ʱ�侫�ȣ�����RST_N=3.1,ֻ��ȡ��3������ʱ�侫��Ϊ1ps,������ȡ��3.1

module testfifo1_5();

    //ʱ�Ӻ͸�λ
    reg             clk_in         ;
    reg             rst_n          ;
    reg             clk_out        ;
    
    //uut(����ģ������֮����ģ��)�������ź�(ע�⣺����ģ�������źŶ�����reg)
    reg[7:0]       data_in      ;
    reg             data_in_vld  ;
    reg             b_rdy        ;
    
    wire[31:0] data_out;
	wire data_out_vld;
    
    //ʱ�����ڣ���λΪns�����ڴ��޸�ʱ�����ڡ�
    parameter CYCLE      = 20 ;
    parameter CYCLE_W    = 10 ;
    integer     i  ;
    
    //��λʱ�䣬��ʱ��ʾ��λ3��ʱ�����ڵ�ʱ�䡣
    parameter RST_TIME = 3 ;
    
    //�����Ե�ģ������(.clkΪģ���źţ�clkΪ�����ļ��������ź�)
    fifo_p uut(
                .clk_in          ( clk_in      ), 
                .rst_n           ( rst_n       ),
                .data_in         ( data_in     ),
                .data_in_vld     ( data_in_vld ),
                .b_rdy           ( b_rdy       ),
                .clk_out         ( clk_out     ),
                .data_out        ( data_out    ),
                .data_out_vld    ( data_out_vld)
    );
    

    
    //ʱ�Ӻ͸�λģ��������д����Ϊ�̶�д��
    //���ɱ���ʱ��50M
    initial begin
		clk_in = 0;
		forever #(CYCLE/2) clk_in=~clk_in;
    end

    initial begin
		clk_out = 0;
		forever #(CYCLE_W/2) clk_out=~clk_out;
    end
    
    //������λ�ź�
    initial begin
						  rst_n = 1;
		#2                rst_n = 0;
		#(CYCLE*RST_TIME) rst_n = 1;
    end

    //�����źŸ�ֵ��ʽ
    initial begin
		#1;
			data_in     = 0;
			data_in_vld = 0;
			b_rdy       = 0;
		#(CYCLE*RST_TIME);
		for(i=0;i<65;i=i+1) begin
			data_in= data_in + 1;
			data_in_vld =  1 ;
			b_rdy       = 0 ;
			#(1*CYCLE);    
		end

		data_in      = 0;
		data_in_vld  = 0;
		b_rdy        = 0;
		#(5*CYCLE);  
		b_rdy      = 1;
		#(70*CYCLE);
		
		for(i=0;i<65;i=i+1) begin
			data_in= data_in + 1;
			data_in_vld =  1 ;
			b_rdy       = 1 ;
			#(1*CYCLE);    
		end
		
		data_in      = 0;
		data_in_vld  = 0;
		b_rdy        = 0;
		#(10*CYCLE);  
		b_rdy      = 1;
		#(70*CYCLE);
		b_rdy      = 0;
    end
endmodule
    
