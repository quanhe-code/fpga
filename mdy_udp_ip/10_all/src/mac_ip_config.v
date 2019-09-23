module mac_ip_config(
    clk        ,
    rst_n      ,
    cfg_mac_local,
    wr_en	   ,
	rd_en      ,
    rdy        ,
    addr       ,
    wdata      ,
    phy_reset  ,
    rdata      ,
    rdata_vld  ,
    cfg_done      
    );

    parameter      DATA_W  =        32; 
    parameter      ADDR_W  =         8;
    parameter      RW_NUM  =         3; 
    parameter      REG_NUM =        21; 

    input               clk      ;   
    input               rst_n    ;
    input [47:0]        cfg_mac_local;
    input               rdy      ;
    input [DATA_W-1:0]  rdata    ;
    input               rdata_vld;

    output[DATA_W-1:0]  wdata    ;
    output[ADDR_W-1:0]  addr     ;
    output              phy_reset;
    output              cfg_done;
    
    output              wr_en    ;
    output              rd_en    ;
    reg                 phy_reset;
    reg   [DATA_W-1:0]  wdata    ;
    reg   [ADDR_W-1:0]  addr     ;
    reg                 wr_en    ;
    reg                 rd_en    ;

    reg   [8 :0]        reg_cnt  ;
    wire                add_reg_cnt/*synthesis keep*/;
    wire                end_reg_cnt/*synthesis keep*/;
    reg [1:0]          flag     ;
    reg   [DATA_W+ADDR_W+RW_NUM-1:0]        add_wdata/*synthesis keep*/;

    reg   [ 1:0]        rw_cnt     ; //0-3
    wire                add_rw_cnt /*synthesis keep*/;
    wire                end_rw_cnt /*synthesis keep*/; //我：原本为end_reg_cnt
    reg   [DATA_W-1:0]  wait_cnt   /*synthesis keep*/;
    wire                add_wait_cnt;
    wire                end_wait_cnt;
    reg   [DATA_W-1:0]  wait_time  /*synthesis keep*/;
    reg                 wait_flag  /*synthesis keep*/;

    reg [27:0]          cnt  ;
    wire                add_cnt;
    wire                end_cnt;


    always@(*) begin
	    case(reg_cnt)           //读，写，等待
		    0   : add_wdata = {3'b110,8'h02,32'h00800020};//common 32'h00800220      
		    1   : add_wdata = {3'b110,8'h09,32'd496    };//tx_section_emty  自己设置的为2048-16     
		    2   : add_wdata = {3'b110,8'h0e,32'd08     };//tx_almost_full      
		    3   : add_wdata = {3'b110,8'h0d,32'd08     };//tx_almost_empty      
		    4   : add_wdata = {3'b110,8'h07,32'd496    };//rx_section_empty      
		    5   : add_wdata = {3'b110,8'h0c,32'd08     };//rx_almost_full      
		    6   : add_wdata = {3'b110,8'h0b,32'd08      };//rx_almost_emty      
		    7   : add_wdata = {3'b110,8'h0a,32'd16      };//tx_section_full      
		    8   : add_wdata = {3'b110,8'h08,32'd16      };//rx_section_full      
		    9   : add_wdata = {3'b110,8'h3a,32'd00      }; //tx_commond_reg    老师说不用管 
		   10   : add_wdata = {3'b110,8'h3b,32'h02000000}; //tx_commond_reg    老师说不用管
		   11   : add_wdata = {3'b110,8'h04,{16'h0,cfg_mac_local[7:0],cfg_mac_local[15:8]}};//MAC1      
		   12   : add_wdata = {3'b110,8'h03,{cfg_mac_local[23:16],cfg_mac_local[31:24],cfg_mac_local[39:32],cfg_mac_local[47:40]}};//MAC0      
		   13   : add_wdata = {3'b110,8'h05,32'd1518    };//MAX FRAME LENGTH      
		   14   : add_wdata = {3'b110,8'h17,32'd12      };//TX IPG LEGNTH      
		   15   : add_wdata = {3'b110,8'h06,32'hffffffff};//pause_quant
		   16   : add_wdata = {3'b110,8'h02,32'h00802020};//common,rst      
		   17   : add_wdata = {3'b001,8'h00,32'h10000   };//wait               自己设置
           18   : add_wdata = {3'b100,8'h02,32'h88888888};  //自己加的，测试用
		   19   : add_wdata = {3'b110,8'h02,32'h00800023};//common,enable tx and rx      
		   20   : add_wdata = {3'b110,8'h02,32'h00800023};//common,enable tx and rx      
	    default : add_wdata = 0;
	    endcase
	end 
		

    always @(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            cnt <= 0;
        end
        else if(add_cnt)begin
            if(end_cnt)
                cnt <= 0;
            else
                cnt <= cnt + 1'b1;
        end
    end

    assign add_cnt = flag == 0 ;       
    assign end_cnt = add_cnt && cnt== 100_000_000-1;

    
    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            phy_reset <= 1;
        end
        else if(add_cnt && cnt==10_000_000-1) begin
            phy_reset <= 0;
        end
        else if(add_cnt && cnt==10_020_000-1)begin
            phy_reset <= 1;
        end
    end

    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            flag <= 0;
        end
        else if(end_cnt)begin
            flag <= 1;
        end
        else if(end_reg_cnt)begin
            flag <= 2;
        end
    end

    assign cfg_done = flag==2;




    always  @(posedge clk or negedge rst_n)begin    //计算模式里3bit
        if(rst_n==1'b0)begin
            rw_cnt <= 0;
        end
        else if(add_rw_cnt) begin
            if(end_rw_cnt)
                rw_cnt <= 0;
            else
                rw_cnt <= rw_cnt + 1'b1;
        end
    end

    assign  add_rw_cnt = flag==1 && rdy && wait_flag==0;
    assign  end_rw_cnt = add_rw_cnt && rw_cnt==RW_NUM-1;
		
    always  @(posedge clk or negedge rst_n)begin    //计算配置表里0-18个寄存器
        if(rst_n==1'b0)begin
            reg_cnt <= 0;
        end
        else if(add_reg_cnt)begin
            if(end_reg_cnt)
                reg_cnt <= 0;
            else
                reg_cnt <= reg_cnt + 1'b1;
        end
    end

    assign add_reg_cnt = end_rw_cnt;   
    assign end_reg_cnt = add_reg_cnt && reg_cnt==REG_NUM-1;

    

    always  @(posedge clk or negedge rst_n)begin    //计数等待时间
        if(rst_n==1'b0)begin
            wait_cnt <= 0;
        end
        else if(add_wait_cnt) begin
            if(end_wait_cnt)
                wait_cnt <= 0;
            else
                wait_cnt <= wait_cnt + 1;
        end
    end
    assign add_wait_cnt = wait_flag;
    assign end_wait_cnt = add_wait_cnt && wait_cnt==wait_time-1;


    //add_wdata
   
    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            wdata <= 0;   
        end
        else begin
            wdata <= add_wdata[DATA_W-1:0];
        end
    end

    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            addr <= 8'b0;
        end
        else begin
            addr <= add_wdata[DATA_W+ADDR_W-1 -:ADDR_W];
        end
    end

    always  @(posedge clk or negedge rst_n)begin //MAC_ip核里第18个寄存器为等待模式，到此寄存器时，拉高wait_flag
        if(rst_n==1'b0)begin
            wait_flag <= 0;
        end
        else if(add_rw_cnt && rw_cnt==0 && add_wdata[DATA_W+ADDR_W+0])begin
            wait_flag <= 1;
        end
        else if(end_wait_cnt)begin
            wait_flag <= 0;
        end
    end

    always  @(posedge clk or negedge rst_n)begin 
        if(rst_n==1'b0)begin
            wait_time <= 0;
        end
        else if(add_rw_cnt && rw_cnt==0 && add_wdata[DATA_W+ADDR_W+0])begin
            wait_time <= add_wdata[DATA_W-1:0];
        end
    end


    //wr_en
    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            wr_en <= 1'b0;
        end
        else if(add_rw_cnt && rw_cnt==1 && add_wdata[DATA_W+ADDR_W+1])begin
            wr_en <= 1'b1;
        end
        else begin
            wr_en <= 1'b0;
        end
    end


    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            rd_en <= 1'b0;
        end
        else if(add_rw_cnt && rw_cnt==2 && add_wdata[DATA_W+ADDR_W+2])begin
            rd_en <= 1'b1;
        end
        else begin
            rd_en <= 1'b0;
        end
    end
	

endmodule

