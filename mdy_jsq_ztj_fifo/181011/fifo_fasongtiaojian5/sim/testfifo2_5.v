`timescale 1 ns/1 ns

module testfifo2_5();

//ʱ�Ӻ͸�λ
reg clk_a ;
reg clk_b ;
reg clk_c ;
reg clk_d ;
reg rst_n ;

//uut�������ź�
reg[15:0]  data_a    ;
reg        data_a_vld;
reg[15:0]  data_b    ;
reg        data_b_vld;
reg[15:0]  data_c    ;
reg        data_c_vld;

    //uut������ź�
    wire        data_d_vld;
    wire [15:0] data_d    ;
    wire [ 1:0] chan_d    ;

        //ʱ�����ڣ���λΪns�����ڴ��޸�ʱ�����ڡ�
        parameter CYCLE    = 40;

        //��λʱ�䣬��ʱ��ʾ��λ3��ʱ�����ڵ�ʱ�䡣
        parameter RST_TIME = 3 ;

        //�����Ե�ģ������
        fifo_p uut(
            .clk_a        (clk_a     ), 
            .rst_n        (rst_n     ),
            .data_a       (data_a    ),
            .data_a_vld   (data_a_vld),
            .clk_b        (clk_b     ),
            .data_b       (data_b    ),
            .data_b_vld   (data_b_vld),
            .clk_c        (clk_c     ),
            .data_c       (data_c    ),
            .data_c_vld   (data_c_vld),
            .clk_d        (clk_d     ),
            .data_d       (data_d    ),
            .data_d_vld   (data_d_vld),
            .chan_d       (chan_d    )
            );


            //���ɱ���ʱ��50M
            initial begin
                clk_a = 0;
                forever
                #(CYCLE/2)
                clk_a=~clk_a;
            end
            initial begin
                clk_b = 0;
                forever
                #(CYCLE/4)
                clk_b=~clk_b;
            end
            initial begin
                clk_c = 0;
                forever
                #(CYCLE/5)
                clk_c=~clk_c;
            end
            initial begin
                clk_d = 0;
                forever
                #(CYCLE/10)
                clk_d=~clk_d;
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
            integer         j;
            integer         k;
            //�����ź�din0��ֵ��ʽ
            initial begin
                #1;
                //����ֵ
                data_a = 0;
                data_a_vld = 0;
                #(10*CYCLE);
                data_a_vld = 1;
                for(i=0;i<100;i=i+1)begin
                    data_a = data_a + 1;
                    #(CYCLE);
                end
                data_a_vld = 0;
                //��ʼ��ֵ
            end

            initial begin
                #1;
                //����ֵ
                data_b = 0;
                data_b_vld = 0;
                #(10*CYCLE);
                #(CYCLE);
                data_b_vld = 1;
                for(j=0;j<100;j=j+1)begin
                    data_b = data_b + 1;
                    #(CYCLE/2);
                end
                data_b_vld = 0;
                //��ʼ��ֵ
            end

            initial begin
                #1;
                //����ֵ
                data_c = 0;
                #(10*CYCLE);
                #(2*CYCLE);
                data_c_vld = 1;
                for(k=0;k<100;k=k+1)begin
                    data_c = data_c + 1;
                    #(CYCLE*2/5);
                end
                data_c_vld = 0;
                //��ʼ��ֵ
            end

            endmodule

