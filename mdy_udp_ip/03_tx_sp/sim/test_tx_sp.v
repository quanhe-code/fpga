
`timescale 1 ns/1 ns

module test_tx_sp();

    //时钟和复位
    reg               	 clk    	;
    reg               	 rst_n  	;
    
    //uut的输入信号



    reg [   15: 0]         din 			;
    reg                    din_vld		;
    reg                    din_sop		;
    reg                    din_eop		;
    reg                    din_mod		;
    reg [   15: 0]         arp 			;   
	reg                    arp_vld		;
	reg                    arp_sop		;
	reg                    arp_eop		;
	reg                    arp_mod		;
	reg                    tx_rdy		;

    //uut的输出信号


    wire[   31: 0]         tx_data		;
    wire                   tx_vld		;
    wire                   tx_sop		;
    wire                   tx_eop		;
    wire[    1: 0]         tx_mod		;
    wire                   din_rdy		;
    wire                   arp_rdy		;

    //时钟周期，单位为ns，可在此修改时钟周期。
    parameter CYCLE    = 20;

    //复位时间，此时表示复位3个时钟周期的时间。
    parameter RST_TIME = 3 ;

    integer     i,ii; 

    //待测试的模块例化
    tx_sp uut(
    	.clk    		(clk    	),
    	.rst_n  		(rst_n  	),
 		.din 			(din 		),
 		.din_vld		(din_vld	),
 		.din_sop		(din_sop	),
 		.din_eop		(din_eop	),
 		.din_mod		(din_mod	),
 		.din_rdy		(din_rdy	),
 		.arp 			(arp 		),
 		.arp_vld		(arp_vld	),
 		.arp_sop		(arp_sop	),
 		.arp_eop		(arp_eop	),
 		.arp_mod		(arp_mod	),
 		.arp_rdy		(arp_rdy	),
 		.tx_data		(tx_data	),
 		.tx_vld			(tx_vld		), 
 		.tx_sop			(tx_sop		),
 		.tx_eop			(tx_eop		),
 		.tx_mod			(tx_mod		),
 		.tx_rdy			(tx_rdy		)

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

        //ip包文
        initial begin
            #1;
            //赋初值

            din_vld = 0;
            din_sop = 0;
            din_eop = 0;            
            din_mod = 0;
            din = 0;

            tx_rdy = 0;

            #(10*CYCLE);
            ip_send(1);

            din_vld = 0;
            din_sop = 0;
            din_eop = 0;            
            din_mod = 0;
            din = 0;
        end

        //arp包文
        initial begin
            #1;
            //赋初值
            arp_vld = 0;
            arp_sop = 0;
            arp_eop = 0;            
            arp_mod = 0;
            arp = 0;
            tx_rdy = 0;

            #(10*CYCLE);

            arp_send(1);
            arp_vld = 0;
            arp_sop = 0;
            arp_eop = 0;            
            arp_mod = 0;
            arp = 0;
        end


        initial begin
            #1;
            forever begin
                tx_rdy = $random;
                #CYCLE;
            end
        end



        task ip_send;
            input  ip_code;
            
            begin
                ii = 0 ;
                while(ii!=24)begin
                    if(din_rdy==1)begin
                        din[15:8] = ii*2 + 0 ;
                        din[ 7:0] = ii*2 + 1 ;
                        din_vld        = 1;
                        din_sop        = (ii==0)?1:0;
                        din_eop        = (ii==24-1)?1:0;
                        din_mod        = 0 ;
                        ii = ii + 1 ;
                    end
                    else begin
                        din[15:8] = 0 ;
                        din[ 7:0] = 0 ;
                        din_vld        = 0 ;
                        din_sop        = 0 ;
                        din_eop        = 0 ;
                        din_mod        = 0 ;
                    end
                    #(CYCLE);
                end
            end
        endtask

        wire[335:0]  arp_data;
        assign       arp_data={16'hffff,16'hffff,16'hffff,16'h2c02,
                               16'h0304,16'h0507,16'h0806,16'h0001,
                               16'h0800,16'h0604,16'h0001,16'h2c02,
                               16'h0304,16'h0507,16'hc0a8,16'h010a,
                               16'h0000,16'h0000,16'h0000,16'hc0a8,
                               16'h010a};     

        task arp_send;
            input  arp_code;     
            
            begin
                i = 0 ;
                   while(i!=21)begin
                    if(arp_rdy==1)begin
                        arp[15:0] = arp_data[(21-i)*16-1 -:16] ;
                        arp_vld        = 1;
                        arp_sop        = (i==0)?1:0;
                        arp_eop        = (i==21-1)?1:0;
                        arp_mod        = 0 ;
                        i = i + 1 ;
                    end
                    else begin
                        arp[15:0] = 0 ;
                        arp_vld        = 0 ;
                        arp_sop        = 0 ;
                        arp_eop        = 0 ;
                        arp_mod        = 0 ;
                    end
                    #(CYCLE);
                end
            end
        endtask

        wire[12*32-1 :0] exp_pack[1:0];

        assign exp_pack[0] = {32'hffffffff,32'hffff2c02,32'h03040507,32'h08060001,
                              32'h08000604,32'h00012c02,32'h03040507,32'hc0a8010a,
                              32'h00000000,32'h0000c0a8,32'h010ac0a8,32'h0};

        assign exp_pack[1] =  {32'h00010203,32'h04050607,32'h08090a0b,32'h0c0d0e0f,
                              32'h10111213,32'h14151617,32'h18191a1b,32'h1c1d1e1f,
                              32'h20212223,32'h24252627,32'h28292a2b,32'h2c2d2e2f};


       reg[31:0] cnt_data ;
       reg[31:0] cnt_pack ;
       reg  tx_rdy_ff ;

       always  @(posedge clk or negedge rst_n)begin
           if(rst_n==1'b0)begin
               cnt_data <= 0;
               cnt_pack <= 0;
           end
           else if(tx_vld && tx_eop) begin
               cnt_data <= 0;
               cnt_pack <= cnt_pack + 1;
           end
           else if(tx_vld)begin
               cnt_data <= cnt_data + 1;
           end
       end

       always  @(posedge clk)begin
           if(tx_vld )begin
               if(tx_data != exp_pack[cnt_pack][(12-cnt_data)*32-1 -:32])begin
                   $display("Err at %t for tx_data",$time);
               end
               
               if(tx_sop!=1 && cnt_data==0)begin
                   $display("Err at %t for tx_sop",$time);
               end

               if(tx_eop!=1 && ((cnt_pack==0 && cnt_data==10) || (cnt_pack==1 && cnt_data==11)))begin
                   $display("Err at %t for tx_eop",$time);
               end
               
               if(tx_eop && ((cnt_pack==0 && tx_mod!=2) || (cnt_pack==1 && tx_mod!=0)))begin
                   $display("Err at %t for tx_mod",$time);
               end

               if(tx_rdy_ff==0)begin
                   $display("Err at %t for tx_vld",$time);
               end

           end
       end

       always  @(posedge clk or negedge rst_n)begin
           if(rst_n==1'b0)begin
               tx_rdy_ff <= 1;
           end
           else begin
               tx_rdy_ff <= tx_rdy;
           end
       end

endmodule
