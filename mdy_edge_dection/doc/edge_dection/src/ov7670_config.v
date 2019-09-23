module ov7670_config(
    clk        ,
    rst_n      ,
    config_en  ,
    rdy        ,
    rdata      ,
    rdata_vld  ,
    wdata      ,
    addr       ,
    wr_en	   ,
	rd_en      ,
    cmos_en    , 
    pwdn         
    );

    //参数定义
    parameter      DATA_W  =         8;
    parameter      RW_NUM  =         2;
    

    //输入信号定义
    input               clk      ;   //50Mhz
    input               rst_n    ;
    input               config_en;
    input               rdy      ;
    input [DATA_W-1:0]  rdata    ;
    input               rdata_vld;

    //输出信号定义
    output[DATA_W-1:0]  wdata    ;
    output[DATA_W-1:0]  addr     ;
    
    output              cmos_en  ;
    output              wr_en    ;
    output              rd_en    ;
    output              pwdn     ;
    //输出信号reg定义
    reg   [DATA_W-1:0]  wdata    ;
    reg   [DATA_W-1:0]  addr     ;
    reg                 cmos_en  ;
    reg                 wr_en    ;
    reg                 rd_en    ;

    //中间信号定义
    reg   [8 :0]        reg_cnt  ;
    wire                add_reg_cnt/*synthesis keep*/;
    wire                end_reg_cnt/*synthesis keep*/;
    reg                 flag     ;
    reg   [17:0]        add_wdata/*synthesis keep*/;

    reg   [ 1:0]        rw_cnt     ;
    wire                add_rw_cnt ;

    assign              pwdn = 0;


    `include "ov7670_para.v"
		
		
    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            reg_cnt <= 0;
        end
        else if(add_reg_cnt)begin
            if(end_reg_cnt)
                reg_cnt <= 0;
            else
                reg_cnt <= reg_cnt + 1;
        end
    end

    assign add_reg_cnt = end_rw_cnt;   
    assign end_reg_cnt = add_reg_cnt && reg_cnt==REG_NUM-1;

    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            rw_cnt <= 0;
        end
        else if(add_rw_cnt) begin
            if(end_rw_cnt)
                rw_cnt <= 0;
            else
                rw_cnt <= rw_cnt + 1;
        end
    end

    assign  add_rw_cnt = flag && rdy;
    assign  end_rw_cnt = add_rw_cnt && rw_cnt==RW_NUM-1;


    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            flag <= 1'b0;
        end
        else if(config_en)begin
            flag <= 1'b1;
        end
        else if(end_reg_cnt)begin
            flag <= 1'b0;
        end
    end

    //cmos_en
    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            cmos_en <= 1'b0;
        end
        else if(end_reg_cnt)begin
            cmos_en <= 1'b1;
        end
    end


    //add_wdata
   
    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            wdata <= 8'b0;
        end
        else begin
            wdata <= add_wdata[7:0];
        end
    end

    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            addr <= 8'b0;
        end
        else begin
            addr <= add_wdata[15:8];
        end
    end


    //wr_en
    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            wr_en <= 1'b0;
        end
        else if(add_rw_cnt && rw_cnt==0 && add_wdata[16])begin
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
        else if(add_rw_cnt && rw_cnt==1 && add_wdata[17])begin
            rd_en <= 1'b1;
        end
        else begin
            rd_en <= 1'b0;
        end
    end
	

endmodule

