`timescale 1 ns/1 ns

module test_rx_filter();


    parameter      DATA_IN_W =         32;
    parameter      DATA_OUT_W =        16;

    
    
   reg             clk    ;
   reg             rst_n  ;
   reg[DATA_IN_W-1:0]             din ;    
   reg             din_sop ;
   reg             din_eop ;
   reg             din_vld ;
   reg[1:0]        din_mod ;
   reg             din_err ;
   wire[DATA_OUT_W-1:0]            dout ;   
   wire            dout_vld;
   wire            dout_sop;
   wire            dout_eop;
   wire            dout_mod;


        //ʱ�����ڣ���λΪns�����ڴ��޸�ʱ�����ڡ�
        parameter CYCLE    = 20;

        //��λʱ�䣬��ʱ��ʾ��λ3��ʱ�����ڵ�ʱ�䡣
        parameter RST_TIME = 3 ;

        //�����Ե�ģ������
        rx_filter uut(
            .clk     (clk     ),
            .rst_n   (rst_n   ),            
            .din     (din     ),
            .din_sop (din_sop ),
            .din_eop (din_eop ),
            .din_vld (din_vld ),
            .din_mod (din_mod ),
            .din_err (din_err ),
            .dout    (dout    ),
            .dout_vld(dout_vld),
            .dout_sop(dout_sop),
            .dout_eop(dout_eop),
            .dout_mod(dout_mod)  

            );


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
                //����ֵ
                din    = 0;
                din_sop= 0;
                din_eop= 0;
                din_vld= 0;
                din_mod= 0;
                din_err= 0;
                #(10*CYCLE);
                //��ʼ��ֵ
                din    = 32'hffff0000;
                din_sop= 1;
                din_eop= 0;
                din_vld= 1;
                din_mod= 0;
                din_err= 0;
                #(1*CYCLE);
                din    = 32'hffff0000;
                din_sop= 0;
                din_eop= 0;
                din_vld= 1;
                din_mod= 0;
                din_err= 0;
                #(1*CYCLE);
                din    = 32'hffff0000;
                din_sop= 0;
                din_eop= 0;
                din_vld= 1;
                din_mod= 0;
                din_err= 0;
                #(1*CYCLE);
                din    = 32'hffff0000;
                din_sop= 0;
                din_eop= 0;
                din_vld= 1;
                din_mod= 0;
                din_err= 0;
                #(1*CYCLE);
                din    = 32'hffff0000;
                din_sop= 0;
                din_eop= 1;
                din_vld= 1;
                din_mod= 2;
                din_err= 0;
                #(1*CYCLE);
                din    = 32'hffff0000;
                din_sop= 0;
                din_eop= 0;
                din_vld= 0;
                din_mod= 0;
                din_err= 0;
                #(10*CYCLE);



                //�������
                
                din    = 32'h00000001;
                din_sop= 1;
                din_eop= 0;
                din_vld= 1;
                din_mod= 0;
                din_err= 0;
                #(1*CYCLE);
                din    = 32'h00000001;
                din_sop= 0;
                din_eop= 0;
                din_vld= 1;
                din_mod= 0;
                din_err= 0;
                #(1*CYCLE);
                din    = 32'h00000001;
                din_sop= 0;
                din_eop= 0;
                din_vld= 1;
                din_mod= 0;
                din_err= 0;
                #(1*CYCLE);
                din    = 32'h00000001;
                din_sop= 0;
                din_eop= 0;
                din_vld= 1;
                din_mod= 0;
                din_err= 0;
                #(1*CYCLE);
                din    = 32'h00000001;
                din_sop= 0;
                din_eop= 0;
                din_vld= 1;
                din_mod= 0;
                din_err= 0;
                #(1*CYCLE);
                din    = 32'h00000001;
                din_sop= 0;
                din_eop= 0;
                din_vld= 1;
                din_mod= 0;
                din_err= 0;
                #(1*CYCLE);
                din    = 32'h00000002;
                din_sop= 0;
                din_eop= 1;
                din_vld= 1;
                din_mod= 0;
                din_err= 1;
                #(1*CYCLE);
                din    = 32'h00000002;
                din_sop= 0;
                din_eop= 0;
                din_vld= 0;
                din_mod= 0;
                din_err= 0;
                #(1*CYCLE);

            end

           reg[31:0]    cnt      ;

       always  @(posedge clk or negedge rst_n)begin
           if(rst_n==1'b0)begin
               cnt <= 0 ;
           end
           else begin
                if(cnt>=14 && cnt<23 && dout_vld!=1)
                    $display("Err at %t for dout_vld",$time);
                else if(cnt==14 && dout_sop!=1)
                    $display("Err at %t for dout_sop",$time);
                else if(cnt==22 && dout_eop!=1)
                    $display("Err at %t for dout_eop",$time);
                else if(dout_eop && dout_mod!=0)
                    $display("Err at %t for dout_mod",$time);


                cnt <= cnt +1;
           end
       end            


       wire[16*9-1 :0]  exp_pack  = {16'hffff,16'h0000,16'hffff,
                                     16'h0000,16'hffff,16'h0000,
                                     16'hffff,16'h0000,16'hffff};

       reg[31:0] cnt_data ;

       always  @(posedge clk or negedge rst_n)begin
           if(rst_n==1'b0)begin
               cnt_data <= 0;
           end
           else if(dout_vld && dout_eop) begin
               cnt_data <= 0;
           end
           else if(dout_vld)begin
               cnt_data <= cnt_data + 1;
           end
       end

       always  @(posedge clk)begin
           if(dout_vld )begin
               if(dout!= exp_pack[(9-cnt_data)*16-1 -:16])begin
                   $display("Err at %t for dout",$time);
               end
       end
   end


            endmodule

