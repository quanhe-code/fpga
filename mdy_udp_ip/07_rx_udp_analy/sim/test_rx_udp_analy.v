`timescale 1 ns/1 ns

module test_rx_udp_analy();

    parameter      DATA_W =        32;
    parameter      IP_W   =        32;
    parameter      PORT_W =        16;



    reg                clk            ; 
    reg                rst_n          ;     
    reg [IP_W-1:0]     cfg_ip_local   ; 
    reg [IP_W-1:0]     cfg_ip_pc      ; 
    reg [PORT_W-1:0]   cfg_port_local ; 
    reg [DATA_W-1:0]   din            ; 
    reg                din_vld        ; 
    reg                din_sop        ; 
    reg                din_eop        ; 
    reg [1:0]          din_mty        ; 
    reg                din_err        ; 
    wire[DATA_W-1:0]  dout           ; 
    wire              dout_vld       ; 
    wire              dout_sop       ; 
    wire              dout_eop       ; 
    wire[1:0]         dout_mty       ; 
    wire              dout_err       ; 
    wire              flag_port_local_err;
    wire              flag_sum_err   ;      

        //时钟周期，单位为ns，可在此修改时钟周期。
        parameter CYCLE    = 20;

        //复位时间，此时表示复位3个时钟周期的时间。
        parameter RST_TIME = 3 ;

        //待测试的模块例化
        rx_udp_analy uut(
           .clk             (clk             ),
           .rst_n           (rst_n           ),           
           .cfg_ip_local    (cfg_ip_local    ),
           .cfg_ip_pc       (cfg_ip_pc       ),
           .cfg_port_local  (cfg_port_local  ),
           .din             (din             ),
           .din_vld         (din_vld         ),
           .din_sop         (din_sop         ),
           .din_eop         (din_eop         ),
           .din_mty         (din_mty         ),
           .din_err         (din_err         ),
           .dout            (dout            ),
           .dout_vld        (dout_vld        ),
           .dout_sop        (dout_sop        ),
           .dout_eop        (dout_eop        ),
           .dout_mty        (dout_mty        ),
           .dout_err        (dout_err        ),
           .flag_port_local_err (flag_port_local_err),
           .flag_sum_err        (flag_sum_err) 

            );

            integer ii,jj;
            wire[32*9-1 :0] send_pack[2:0];

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
                cfg_ip_local    = 32'hc0a8010a;
                cfg_ip_pc       = 32'hc0a80109;
                cfg_port_local  = 16'h1388;
                din             = 0;
                din_vld         = 0;
                din_sop         = 0;
                din_eop         = 0;
                din_mty         = 0;
                din_err         = 0;
                #(10*CYCLE);
                //开始赋值
                
                for(ii=0;ii<3;ii=ii+1)begin
                    for(jj=0;jj<9;jj=jj+1)begin
                        din     = send_pack[ii][32*(9-jj)-1 -:32];
                        din_vld = 1 ;
                        din_sop = jj==0?1:0;
                        din_eop = jj==8?1:0;
                        din_mty = (jj==8 && ii==0)?2:0 ;
                        din_err = 0 ;
                        #(1*CYCLE);
                    end
                end

                din             = 0;
                din_vld         = 0;
                din_sop         = 0;
                din_eop         = 0;
                din_mty         = 0;
                din_err         = 0;


            end

            //正确接收
           assign send_pack[0]={32'h0bb81388,32'h00245cfc,32'h00000001,
                                32'h00000001,32'h00000001,32'h00000001,
                                32'h00000001,32'h00000001,32'h00000002
                                }; 

           //目的端口号错误
           assign send_pack[1]={32'h0bb81389,32'h00245cf9,32'h00000001,
                                32'h00000001,32'h00000001,32'h00000001,
                                32'h00000001,32'h00000001,32'h00000002
                                };

           //校验和错误 
           assign send_pack[2]={32'h0bb81388,32'h00245cfb,32'h00000001,
                                32'h00000001,32'h00000001,32'h00000001,
                                32'h00000001,32'h00000001,32'h00000002
                                };


       reg[31:0]    cnt      ;

       always  @(posedge clk or negedge rst_n)begin
           if(rst_n==1'b0)begin
               cnt <= 0 ;
           end
           else begin
                if(((cnt>=13 && cnt<20) || (cnt>=31 && cnt<38)) && dout_vld!=1)
                    $display("Err at %t for dout_vld",$time);
                else if((cnt==13 || cnt==22 || cnt==31) && dout_sop!=1)
                    $display("Err at %t for dout_sop",$time);
                else if((cnt==19 || cnt==28 || cnt==37) && dout_eop!=1)
                    $display("Err at %t for dout_eop",$time);
                else if(cnt==19 && dout_eop && dout_mty!=2)
                    $display("Err at %t for dout_mty",$time);
                else if(dout_eop && flag_sum_err && dout_err!=1)
                    $display("Err at %t for dout_err",$time);
                else if(cnt>=20 && cnt<29 && flag_port_local_err!=1)
                    $display("Err at %t for flag_port_local_err",$time);
                else if(cnt>=18 && cnt<36 && flag_sum_err!=0)
                    $display("Err at %t for flag_sum_err",$time);

                cnt <= cnt +1;
           end
       end            


       wire[32*7-1 :0]  exp_pack  = {32'h00000001,32'h00000001,32'h00000001,
                                     32'h00000001,32'h00000001,32'h00000001,
                                     32'h00000002};

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
               if(dout!= exp_pack[(7-cnt_data)*32-1 -:32])begin
                   $display("Err at %t for dout",$time);
               end
       end
   end


            endmodule

