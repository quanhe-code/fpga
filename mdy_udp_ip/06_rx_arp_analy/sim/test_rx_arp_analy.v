`timescale 1 ns/1 ns

module test_rx_arp_analy();

    parameter      DATA_W =         32;
    parameter       MAC_W =         48;
    parameter       IP_W  =         32;

    reg           clk            ; 
    reg           rst_n          ; 
     
    reg[MAC_W-1:0]          cfg_mac_local  ; 
    reg[IP_W-1:0]           cfg_ip_local   ; 
    reg[IP_W-1:0]           cfg_ip_pc      ; 
    wire[MAC_W-1:0]         get_mac_pc     ; 
    reg[DATA_W-1:0]         arp_data       ; 
    reg           arp_vld        ; 
    reg           arp_sop        ; 
    reg           arp_eop        ; 
    reg[1:0]      arp_mod        ; 
    wire          get_en         ; 
    wire          ack_en         ; 
    wire          flag_type_err  ; 
    wire          flag_len_err   ; 
    wire          flag_pc_ip_err ; 
    wire          flag_local_ip_err;

        //时钟周期，单位为ns，可在此修改时钟周期。
        parameter CYCLE    = 20;

        //复位时间，此时表示复位3个时钟周期的时间。
        parameter RST_TIME = 3 ;

        //待测试的模块例化
        rx_arp_analy uut(
            .clk            (clk     ), 
            .rst_n          (rst_n   ),
            .cfg_mac_local  (cfg_mac_local  ), 
            .cfg_ip_local   (cfg_ip_local   ), 
            .cfg_ip_pc      (cfg_ip_pc      ), 
            .get_mac_pc     (get_mac_pc     ), 
            .arp_data       (arp_data       ), 
            .arp_vld        (arp_vld        ), 
            .arp_sop        (arp_sop        ), 
            .arp_eop        (arp_eop        ), 
            .arp_mod        (arp_mod        ), 
            .get_en         (get_en         ), 
            .ack_en         (ack_en         ), 
            .flag_type_err  (flag_type_err  ), 
            .flag_len_err   (flag_len_err   ), 
            .flag_pc_ip_err (flag_pc_ip_err ), 
            .flag_local_ip_err  (flag_local_ip_err)

            );

            integer ii,jj;
            wire[32*7-1 :0] send_pack[5:0];

            //生成本地时钟50M
            initial begin
                clk = 1;
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
                cfg_mac_local =48'h2c0203040507; 
                cfg_ip_local  =32'hc0a8010a;
                cfg_ip_pc     =32'hc0a80109;
                arp_data      =0;
                arp_vld       =0;
                arp_sop       =0;
                arp_eop       =0;
                arp_mod       =0;

                #(10*CYCLE);
                //开始赋值
                for(ii=0;ii<6;ii=ii+1)begin
                    for(jj=0;jj<7;jj=jj+1)begin
                        arp_data= send_pack[ii][32*(7-jj)-1 -:32];
                        arp_vld = 1 ;
                        arp_sop = jj==0?1:0;
                        arp_eop = jj==6?1:0;
                        arp_mod = 0 ;
                        #(1*CYCLE);
                    end
                end

                arp_data      =0;
                arp_vld       =0;
                arp_sop       =0;
                arp_eop       =0;
                arp_mod       =0;


            end


            
           //ack_en信号
           assign send_pack[0]={32'h00010800,32'h06040001,32'h01020304,
                                32'h0506c0a8,32'h01092c02,32'h03040507,
                                32'hc0a8010a
                                }; 

           //get_en信号
           assign send_pack[1]={32'h00010800,32'h06040002,32'h01020304,
                                32'h0506c0a8,32'h01092c02,32'h03040507,
                                32'hc0a8010a
                                };

           //类型错误 0x00020800（正确00010800）
           assign send_pack[2]={32'h00020800,32'h06040001,32'h01020304,
                                32'h0506c0a8,32'h01092c02,32'h03040507,
                                32'hc0a8010a
                                };


           //长度错误 0x0504（正确0604）
           assign send_pack[3]={32'h00010800,32'h05040001,32'h01020304,
                                32'h0506c0a8,32'h01092c02,32'h03040507,
                                32'hc0a8010a
                                };


           //PC端的ip错误  0xc0a80108（正确c0a80109）
           assign send_pack[4]={32'h00010800,32'h06040001,32'h01020304,
                                32'h0506c0a8,32'h01082c02,32'h03040507,
                                32'hc0a8010a
                                };


           //本地ip地址错误  0xc0a80107（正确c0a8010a）
           assign send_pack[5]={32'h00010800,32'h06040001,32'h01020304,
                                32'h0506c0a8,32'h01092c02,32'h03040507,
                                32'hc0a8010b
                                }; 


       wire[16*3-1 :0]  mac_pc;
       assign mac_pc={16'h0102,16'h0304,16'h0506};


       reg[31:0]    cnt      ;

       always  @(posedge clk or negedge rst_n)begin
           if(rst_n==1'b0)begin
               cnt <= 0 ;
           end
           else begin
               if((cnt<10 && get_mac_pc!=0) ||(cnt>=11 && get_mac_pc!=mac_pc) || (cnt==10 && get_mac_pc!={mac_pc[47:16],16'h0}))
                    $display("Err at %t for get_mac_pc",$time);
                else if(cnt==21 && get_en!=1)
                    $display("Err at %t for get_en",$time);
                else if((cnt==14 || cnt==49) && ack_en!=1)
                    $display("Err at %t for ack_en",$time);

                else if(cnt>=22 && cnt<29 && flag_type_err!=1)
                    $display("Err at %t for flag_type_err",$time);
                else if(cnt>=30 && cnt<37 && flag_len_err!=1)
                    $display("Err at %t for flag_len_err",$time);
                else if(cnt>=40 && cnt<47 && flag_pc_ip_err!=1)
                    $display("Err at %t for flag_pc_ip_err",$time);
                else if(cnt>=49 && flag_local_ip_err!=1)
                    $display("Err at %t for flag_local_ip_err",$time);


                cnt <= cnt +1;
           end

                
       end




            endmodule

