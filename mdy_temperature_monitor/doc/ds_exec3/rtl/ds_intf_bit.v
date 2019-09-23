module ds_intf_bit(
    clk      ,
    rst_n    ,
    rst_en   ,
    wr_en    ,
    wdata    ,
    rd_en    ,
    rdata    ,
    rdata_vld,
    dq_out   ,
    dq_out_en,
    dq_in    , 
    rdy       
    );

    parameter      TIME_RST      =  50_000;//1000us
    parameter      TIME_RST_LOW  =  37_500;//750us
    parameter      TIME_WR       =   3_100;//62us
    parameter      TIME_WR_INSTR =     750;//15us
    parameter      TIME_WR_DATA  =   3_000;//60us
    parameter      TIME_RD       =   3_100;//62us
    parameter      TIME_RD_INSTR =     60;//1us
    parameter      TIME_RD_GET   =    700; //14us
    parameter      TIME_RD_DATA  =   3_000;//60us

    input               clk       ;
    input               rst_n     ;
    input               rst_en    ;
    input               wr_en     ;
    input               wdata     ;
    input               rd_en     ;
    input               dq_in     ;

    output              rdata     ;
    output              rdata_vld ;
    output              dq_out    ;
    output              dq_out_en ;
    output              rdy       ;

    reg                 rdata     ;
    reg                 rdata_vld ;
    reg                 dq_out    ;
    reg                 dq_out_en ;
    reg                 rdy       ;
    reg[15:0]           cnt       ;
    wire                add_cnt   ;
    wire                end_cnt   ;
    reg                 wdata_ff0 ;

    wire                rst_start   ;
    wire                wr_start    ;
    wire                rd_start    ;


    
    reg [16:0]          x         ;
    reg [16:0]          y         ;
    reg [16:0]          uu        ;
    reg                 zz        ;

    reg                 flag_work ;
    reg[1:0]            flag_sel  ;



    always @(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            cnt <= 0;
        end
        else if(add_cnt)begin
            if(end_cnt)
                cnt <= 0;
            else
                cnt <= cnt + 1;
        end
    end

    assign add_cnt = flag_work;       
    assign end_cnt = add_cnt && cnt==x - 1 ; 


    assign rst_start = flag_work==0 && (wr_en==0 && rst_en==1 && rd_en==0);
    assign wr_start  = flag_work==0 && (wr_en==1 && rst_en==0 && rd_en==0);
    assign rd_start  = flag_work==0 && (wr_en==0 && rst_en==0 && rd_en==1);




    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            flag_work <= 0;
        end
        else if(rst_start || wr_start || rd_start)begin
            flag_work <= 1;
        end
        else if(end_cnt)begin
            flag_work <= 0;
        end
    end

    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            flag_sel <= 0;
        end
        else if(rst_start)begin
            flag_sel <= 0;
        end
        else if(wr_start)begin
            flag_sel <= 1;
        end
        else if(rd_start)begin
            flag_sel <= 2;
        end
    end

    

    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            wdata_ff0 <= 1'b0;
        end
        else if(wr_start)begin
            wdata_ff0 <= wdata;
        end
    end


    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            dq_out <= 1;
        end
        else if(rst_start || wr_start || rd_start)begin
            dq_out <= 0;
        end
        else if(add_cnt && cnt==y-1)begin
            dq_out <= zz;
        end
        else if(end_cnt)begin
            dq_out <= 1;
        end
    end


    always  @(*)begin
        if(flag_sel==0)begin
            y  = TIME_RST_LOW;
            zz = 1;
            uu = TIME_RST_LOW ;
            x  = TIME_RST;
        end
        else if(flag_sel==1)begin
            y  = TIME_WR_INSTR;
            zz = wdata_ff0;
            uu = TIME_WR_DATA ;
            x  = TIME_WR ;
        end
        else begin
            y  = TIME_RD_INSTR;
            zz = 1;
            uu = TIME_RD_INSTR ;
            x  = TIME_RD ;
        end
    end


    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            dq_out_en <= 0;
        end
        else if(rst_start || wr_start || rd_start)begin
            dq_out_en <= 1;
        end
        else if(add_cnt && cnt==uu-1)begin
            dq_out_en <= 0;
        end
        else if(end_cnt)begin
            dq_out_en <= 0;
        end
    end


    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            rdata <= 1'b0;
        end
        else if(flag_sel==2 && add_cnt && cnt==TIME_RD_GET-1)begin
            rdata <= dq_in;
        end
    end

    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            rdata_vld <= 1'b0;
        end
        else if(flag_sel==2 && add_cnt && cnt==TIME_RD_GET-1)begin
            rdata_vld <= 1'b1;
        end
        else begin
            rdata_vld <= 1'b0;
        end
    end

    always  @(*)begin
        if(rst_en || wr_en || rd_en || flag_work)
            rdy = 1'b0;
        else
            rdy = 1'b1;
    end


endmodule

