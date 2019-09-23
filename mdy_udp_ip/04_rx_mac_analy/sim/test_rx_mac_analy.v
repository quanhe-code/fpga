`timescale 1 ns/1 ns

module test_rx_mac_analy();

        parameter      DATA_W =         32;
        parameter      MAC_W  =         48;



   reg                clk         ; 
   reg                rst_n       ; 
   reg [MAC_W-1:0]    cfg_mac_local; 
   reg [DATA_W-1:0]   rx_data     ; 
   reg                rx_vld      ; 
   reg                rx_sop      ; 
   reg                rx_eop      ; 
   reg [1:0]          rx_mod      ; 
   wire [DATA_W-1:0]  ip_data     ; 
   wire               ip_vld      ; 
   wire               ip_sop      ; 
   wire               ip_eop      ; 
   wire [1:0]         ip_mod      ; 
   wire [MAC_W-1:0]   get_mac_pc  ; 
   wire [DATA_W-1:0]  arp_data    ; 
   wire               arp_vld     ; 
   wire               arp_sop     ; 
   wire               arp_eop     ; 
   wire [1:0]         arp_mod     ; 
   wire               flag_mac_err; 
   wire [1:0]         flag_type   ;
        //时钟周期，单位为ns，可在此修改时钟周期。
        parameter CYCLE    = 20;

        //复位时间，此时表示复位3个时钟周期的时间。
        parameter RST_TIME = 3 ;



        //待测试的模块例化
        rx_mac_analy uut(
           .clk          (clk          ),
           .rst_n        (rst_n        ),
           .cfg_mac_local(cfg_mac_local),
           .rx_data      (rx_data      ),
           .rx_vld       (rx_vld       ),
           .rx_sop       (rx_sop       ),
           .rx_eop       (rx_eop       ),
           .rx_mod       (rx_mod       ),
           .ip_data      (ip_data      ),
           .ip_vld       (ip_vld       ),
           .ip_sop       (ip_sop       ),
           .ip_eop       (ip_eop       ),
           .ip_mod       (ip_mod       ),
           .get_mac_pc   (get_mac_pc   ),
           .arp_data     (arp_data     ),
           .arp_vld      (arp_vld      ),
           .arp_sop      (arp_sop      ),
           .arp_eop      (arp_eop      ),
           .arp_mod      (arp_mod      ),
           .flag_mac_err (flag_mac_err ),
           .flag_type    (flag_type    )  
            );

            integer ii,jj;
            wire[8*20-1 :0] send_pack[4:0];

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
                cfg_mac_local=48'h2c0203040507;
                rx_data      =0;
                rx_vld       =0;
                rx_sop       =0;
                rx_eop       =0;
                rx_mod       =0;
                #(10*CYCLE);
                //开始赋值
                //MAC头和类型数据
                for(ii=0;ii<5;ii=ii+1)begin
                    for(jj=0;jj<5;jj=jj+1)begin
                        rx_data = send_pack[ii][32*(5-jj)-1 -:32];
                        rx_sop  = jj==0?1:0;
                        rx_eop  = jj==4?1:0;
                        rx_vld  = 1;
                        rx_mod  = (jj==4 && ii>=3)?ii:0;
                        #(1*CYCLE);
                    end
                end

                rx_data      =0;
                rx_vld       =0;
                rx_sop       =0;
                rx_eop       =0;
                rx_mod       =0;

            end
   

       //20字节包文，目的MAC不正确，类型是0806：arp包
       assign   send_pack[0] = {
                                         32'h00001c02,32'h03040507,
                                         32'h08090a0b,32'h0c0d0806,
                                         32'h12131415};
       
       //20字节包文，目的MAC不正确，类型是0800：ip包
       assign   send_pack[1] = {
                                         32'h00001c02,32'h03040507,
                                         32'h08090a0b,32'h0c0d0800,
                                         32'h10111213};

       //20字节包文，目的MAC正确，类型是0801：错误类型
       assign   send_pack[2] = {
                                         32'h00002c02,32'h03040507,
                                         32'h08090a0b,32'h0c0d0801,
                                         32'h10111213};

       //20字节包文，目的MAC正确，类型是0806：arp包
       assign   send_pack[3] = {
                                         32'h00002c02,32'h03040507,
                                         32'h08090a0b,32'h0c0d0806,
                                         32'h10111213};
       
       //20字节包文，目的MAC正确，类型是0800：ip包
       assign   send_pack[4] = {
                                         32'h00002c02,32'h03040507,
                                         32'h08090a0b,32'h0c0d0800,
                                         32'h10111213};


       wire[8*4-1 :0]  exp_arp_pack0  = {32'h10};
       wire[8*4-1 :0]  exp_ip_pack0   = {32'h10111213};
       
       
       wire[16*3-1 :0]  mac_pc;
       assign mac_pc={16'h0809,16'h0a0b,16'h0c0d};


       reg[31:0]    cnt      ;

       always  @(posedge clk or negedge rst_n)begin
           if(rst_n==1'b0)begin
               cnt <= 0 ;
           end
           else begin
               if(ip_eop && ip_data!=exp_ip_pack0)
                    $display("Err at %t for ip_data",$time);
                else if(cnt==32 && ip_vld!=1)
                    $display("Err at %t for ip_vld",$time);
                else if(cnt==32 && ip_sop!=1)
                    $display("Err at %t for ip_sop",$time);
                else if(cnt==32 && ip_eop!=1)
                    $display("Err at %t for ip_eop",$time);
                else if(ip_eop &&ip_mod!=0)
                    $display("Err at %t for ip_mod",$time);
                else if(arp_eop && arp_data==exp_arp_pack0)
                    $display("Err at %t for arp_data",$time);
                else if(cnt==27 && arp_vld!=1)
                    $display("Err at %t for arp_vld",$time);
                else if(cnt==27 && arp_sop!=1)
                    $display("Err at %t for arp_sop",$time);
                else if(cnt==27 && arp_eop!=1)
                    $display("Err at %t for arp_eop",$time);
                else if(arp_eop && arp_mod!=3)
                    $display("Err at %t for arp_mod",$time);
                else if((cnt<10 && get_mac_pc!=0) ||(cnt>=11 && get_mac_pc!=mac_pc) || (cnt==10 && get_mac_pc!={mac_pc[47:16],16'h0}))
                    $display("Err at %t for get_mac_pc",$time);
                else if(cnt>=9 && cnt<19 && flag_mac_err!=1 )
                    $display("Err at %t for flag_mac_err",$time);
                else if((cnt>=11 && cnt<16 && cnt>=26 &&cnt<31 && flag_type!=1)||(cnt>=21 &&cnt<26 && flag_type!=2))begin
                    if(flag_type!=0)begin
                    $display("Err at %t for flag_type",$time);
                end
                    
            end
                cnt <= cnt +1;
           end

                
       end








endmodule

