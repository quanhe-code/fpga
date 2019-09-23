`timescale 1 ns/1 ns

module test_rx_ip_analy();

parameter      DATA_W =        32;

    //输入信号定义
   reg            clk          ; 
   reg            rst_n        ; 
   reg [DATA_W-1:0]           cfg_ip_local ; 
   reg [DATA_W-1:0]           cfg_ip_pc    ; 
   reg [DATA_W-1:0]           din          ; 
   reg            din_vld      ; 
   reg            din_sop      ; 
   reg            din_eop      ; 
   reg [1:0]      din_mty      ; 
    wire[DATA_W-1:0]          dout         ; 
    wire          dout_vld     ; 
    wire          dout_sop     ; 
    wire          dout_eop     ; 
    wire[1:0]     dout_mty     ; 
    wire          flag_type_err; 
    wire          flag_len_err ; 
    wire          flag_sum_err ; 
    wire          flag_ip_local_err;
    wire          flag_ip_pc_err;

    wire[32*14-1 :0] send_pack[5:0];
    integer ii,jj;

        //时钟周期，单位为ns，可在此修改时钟周期。
        parameter CYCLE    = 20;

        //复位时间，此时表示复位3个时钟周期的时间。
        parameter RST_TIME = 3 ;

        //待测试的模块例化
        rx_ip_analy uut(
             .clk           (clk     ), 
             .rst_n         (rst_n   ),
             .cfg_ip_local  (cfg_ip_local ),
             .cfg_ip_pc     (cfg_ip_pc    ),
             .din           (din          ),
             .din_vld       (din_vld      ),
             .din_sop       (din_sop      ),
             .din_eop       (din_eop      ),
             .din_mty       (din_mty      ),
             .dout          (dout         ),
             .dout_vld      (dout_vld     ),
             .dout_sop      (dout_sop     ),
             .dout_eop      (dout_eop     ),
             .dout_mty      (dout_mty     ),
             .flag_type_err (flag_type_err),
             .flag_len_err  (flag_len_err ),
             .flag_sum_err  (flag_sum_err ),
             .flag_ip_local_err  (flag_ip_local_err),
             .flag_ip_pc_err     (flag_ip_pc_err)


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
                cfg_ip_local = 32'hc0a8010a; 
                cfg_ip_pc    = 32'hc0a80109; 
                din          =0; 
                din_vld      =0; 
                din_sop      =0; 
                din_eop      =0; 
                din_mty      =0;
                #(5*CYCLE);
                //开始赋值
                for(ii=0;ii<6;ii=ii+1)begin
                    for(jj=0;jj<14;jj=jj+1)begin
                        din     = send_pack[ii][32*(14-jj)-1 -:32];
                        din_vld = 1 ;
                        din_sop = jj==0?1:0;
                        din_eop = jj==13?1:0;
                        din_mty = (jj==13 && ii<2)?(ii+2):0;
                        #(1*CYCLE);
                    end
                end

                din          =0; 
                din_vld      =0; 
                din_sop      =0; 
                din_eop      =0; 
                din_mty      =0;
            end
           

           //正确接收
           assign send_pack[0]={32'h45000036,32'h00004000,32'hff11f852,
                                32'hc0a80109,32'hc0a8010a,32'h0bb81388,
                                32'h00245cfa,32'h00000001,32'h00000001,
                                32'h00000001,32'h00000001,32'h00000001,
                                32'h00000001,32'h00000002
                                }; 

           //总长度错误 0x39
           assign send_pack[1]={32'h45000039,32'h00004000,32'hff11f84f,
                                32'hc0a80109,32'hc0a8010a,32'h0bb81388,
                                32'h00245cfa,32'h00000001,32'h00000001,
                                32'h00000001,32'h00000001,32'h00000001,
                                32'h00000001,32'h00000002};

           //类型错误 0x35
           assign send_pack[2]={32'h35000038,32'h00004000,32'hff11f851,
                                32'hc0a80109,32'hc0a8010a,32'h0bb81388,
                                32'h00245cfa,32'h00000001,32'h00000001,
                                32'h00000001,32'h00000001,32'h00000001,
                                32'h00000001,32'h00000002};


           //校验和错误 不为0xffff
           assign send_pack[3]={32'h45000038,32'h00004000,32'hff11f851,
                                32'hc0a80109,32'hc0a8010a,32'h0bb81388,
                                32'h00245cfa,32'h00000001,32'h00000001,
                                32'h00000001,32'h00000001,32'h00000001,
                                32'h00000001,32'h00000002}; 

           //本地ip地址错误  0xc0a80108
           assign send_pack[4]={32'h45000038,32'h00004000,32'hff11f852,
                                32'hc0a80109,32'hc0a80108,32'h0bb81388,
                                32'h00245cfa,32'h00000001,32'h00000001,
                                32'h00000001,32'h00000001,32'h00000001,
                                32'h00000001,32'h00000002};

           //PC端ip地址错误  0xc0a80107
           assign send_pack[5]={32'h45000038,32'h00004000,32'hff11f852,
                                32'hc0a80107,32'hc0a8010a,32'h0bb81388,
                                32'h00245cfa,32'h00000001,32'h00000001,
                                32'h00000001,32'h00000001,32'h00000001,
                                32'h00000001,32'h00000002};



           wire[8*4-1 :0]  exp_pack  = {32'h00000002};
       
       


       reg[31:0]    cnt      ;

       always  @(posedge clk or negedge rst_n)begin
           if(rst_n==1'b0)begin
               cnt <= 0 ;
           end
           else begin
               if(dout_eop && dout!=exp_pack)
                    $display("Err at %t for dout",$time);
                else if(((cnt>=8 && cnt<17) ||(cnt>=22 && cnt<31)) && dout_vld!=1)
                    $display("Err at %t for dout_vld",$time);
                else if((cnt==8 || cnt==22) && dout_sop!=1)
                    $display("Err at %t for dout_sop",$time);
                else if((cnt==16 || cnt==30) && dout_eop!=1)
                    $display("Err at %t for dout_eop",$time);
                else if(cnt==16 &&(dout_eop && dout_mty!=2) )
                    $display("Err at %t for dout_mty",$time);
                else if(cnt==30 &&(dout_eop && dout_mty!=3) )
                    $display("Err at %t for dout_mty",$time);
                else if((cnt>=31 && cnt<45) && flag_type_err!=1)
                    $display("Err at %t for flag_type_err",$time);
                else if(dout_mty==3 && flag_len_err!=1)
                    $display("Err at %t for flag_len_err",$time);
                else if((cnt>=35 && cnt<63) && flag_sum_err!=1)
                    $display("Err at %t for flag_sum_err",$time);
                else if((cnt>=63 && cnt<77) && flag_ip_local_err!=1 )
                    $display("Err at %t for flag_ip_local_err",$time);
                else if(cnt>=76 && flag_ip_pc_err!=1 )
                    $display("Err at %t for flag_ip_pc_err",$time);
                    cnt <= cnt +1;

                cnt <= cnt +1;
            end
       end
      



            endmodule

