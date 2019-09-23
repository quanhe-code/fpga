`timescale 1 ns/10 ps

module test_tx_arp();

//参数定义
    parameter      DATA_W =         16;
    parameter      IP_W   =         32;
    parameter      MAC_W  =         48;
    

    defparam        uut.SECOND_CNT = 50;

    //输入信号定义
    reg               clk        ; 
    reg               rst_n      ; 
    reg               ack_en     ; 
    reg[IP_W-1:0]     cfg_sip    ; 
    reg[IP_W-1:0]     cfg_dip    ; 
    reg[MAC_W-1:0]    cfg_mac_s  ; 
    reg[MAC_W-1:0]    ack_mac_d  ; 
    wire[DATA_W-1:0]  tx_arp_data; 
    wire              tx_arp_vld ; 
    wire              tx_arp_sop ; 
    wire              tx_arp_eop ; 
    reg               tx_arp_rdy ; 
    wire              tx_arp_mty ;

        //时钟周期，单位为ns，可在此修改时钟周期。
        parameter CYCLE    = 10;

        //复位时间，此时表示复位3个时钟周期的时间。
        parameter RST_TIME = 3 ;

        //待测试的模块例化
        tx_arp uut(
            .clk         (clk         ),
            .rst_n       (rst_n       ),
            .ack_en      (ack_en      ),
            .cfg_sip     (cfg_sip     ),
            .cfg_dip     (cfg_dip     ),
            .cfg_mac_s   (cfg_mac_s   ),
            .ack_mac_d   (ack_mac_d   ),
            .tx_arp_data (tx_arp_data ),
            .tx_arp_vld  (tx_arp_vld  ),
            .tx_arp_sop  (tx_arp_sop  ),
            .tx_arp_eop  (tx_arp_eop  ),
            .tx_arp_rdy  (tx_arp_rdy  ),
            .tx_arp_mty  (tx_arp_mty  ) 

            );


            //生成本地时钟50M
            initial begin
                clk = 0;
                forever
                #(CYCLE/2)
                clk=~clk;
            end

            //产生复位信号
            initial begin
                rst_n = 1;
                #2;
                rst_n = 0;
                #(CYCLE*RST_TIME);
                rst_n = 1;
            end

            //输入信号din0赋值方式
            initial begin
                #1;
                //赋初值
                cfg_sip  = 32'hc0a8010a;
                cfg_dip  = 32'hc0a80109;
                cfg_mac_s= 48'h2c0203040507;
                ack_mac_d= 48'h010203040506;
                tx_arp_rdy=1;
                ack_en   = 0;
                #(10*CYCLE);
                ack_en  = 1;
                #(1*CYCLE);
                ack_en  = 0;
                #(10*CYCLE);
                tx_arp_rdy=0;
                #(2*CYCLE);
                tx_arp_rdy=1;
                #(66*CYCLE);
                ack_en  = 0;
                #(66*CYCLE);
                ack_en  = 1;
                #(1*CYCLE);
                ack_en  = 0;
            end

            wire[21*16-1:0] exp_pack[1:0] ;


//请求包文   336bit=21*16
            assign exp_pack[1] = {48'hffffffffffff,48'h2c0203040507,16'h0806,16'h0001,16'h0800,8'h06,8'h04,16'h0001,48'h2c0203040507,32'hc0a8010a,48'h000000000000,32'hc0a80109};
//应答包文   336bit=21*16
            assign exp_pack[0] = {48'h010203040506,48'h2c0203040507,16'h0806,16'h0001,16'h0800,8'h06,8'h04,16'h0002,48'h2c0203040507,32'hc0a8010a,48'h010203040506,32'hc0a80109};


       reg[31:0] cnt_data ;
       reg[31:0] cnt_pack ;
       reg  tx_arp_rdy_ff ;

       always  @(posedge clk or negedge rst_n)begin
           if(rst_n==1'b0)begin
               cnt_data <= 0;
               cnt_pack <= 0;
           end
           else if(tx_arp_vld && tx_arp_eop) begin
               cnt_data <= 0;
               cnt_pack <= cnt_pack + 1;
           end
           else if(tx_arp_vld)begin
               cnt_data <= cnt_data + 1;
           end
       end

       always  @(posedge clk)begin
           if(tx_arp_vld && cnt_pack<3)begin
               if(tx_arp_data != exp_pack[cnt_pack][(21-cnt_data)*16-1 -:16])begin
                   $display("Err at %t for tx_arp_data",$time);
               end
               
               if(tx_arp_sop!=1 && cnt_data==0)begin
                   $display("Err at %t for tx_arp_sop",$time);
               end

               if(tx_arp_eop!=1 &&  cnt_data==20)begin
                   $display("Err at %t for tx_arp_eop",$time);
               end
               
               if(tx_arp_eop && tx_arp_mty!=0)begin
                   $display("Err at %t for tx_arp_eop",$time);
               end

               if(tx_arp_rdy_ff==0)begin
                   $display("Err at %t for tx_arp_rdy",$time);
               end

           end
       end

       always  @(posedge clk or negedge rst_n)begin
           if(rst_n==1'b0)begin
               tx_arp_rdy_ff <= 1;
           end
           else begin
               tx_arp_rdy_ff <= tx_arp_rdy;
           end
       end

            endmodule


