module mac_cfg_if(
    clk       ,
    rst_n     ,
    wr        ,
    rd        ,
    rdy       ,
    addr      ,
    wdata     ,
    rdata     ,
    rdata_vld ,    
    mac_addr  ,
    mac_rd    ,
    mac_wdata ,
    mac_wr    ,
    mac_rdata ,
    mac_wait     

    );

    //参数定义
    parameter      DATA_W =         32;

    input            clk      ;
    input            rst_n    ;
    input            wr       ;
    input            rd       ;
    input  [ 7:0]    addr     ; 
    input  [31:0]    wdata    ;
    output           rdy      ;
    output [31:0]    rdata    ;
    output           rdata_vld  /*synthesis keep*/;


    output [ 7:0]    mac_addr  ; 
    output           mac_rd    ; 
    output [31:0]    mac_wdata ; 
    output           mac_wr    ; 
    input  [31:0]    mac_rdata ; 
    input            mac_wait  ;   
  
    reg              rdy       ; //我：增加的
    reg              mac_rd    ;
    reg              mac_wr    ;
    reg   [ 7:0]     mac_addr  ;
    reg   [31:0]     mac_wdata ;
    wire  [31:0]     mac_rdata ;
    wire             mac_wait  /*synthesis keep*/; 
    reg    [31:0]    rdata    ;
    reg              rdata_vld;
    reg              mac_wait_ff0   /*synthesis keep*/;
    wire             finish    ;

    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            mac_wait_ff0 <= 1'b0;
        end
        else begin
            mac_wait_ff0 <= mac_wait ;
        end
    end

    assign finish = mac_wait_ff0 && mac_wait==1'b0; //我：看到mac_wait时钟下降沿 finish有效

    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            mac_wr <= 1'b0;
        end
        else if(wr) begin
            mac_wr <= 1'b1;
        end
        else if(finish)begin
            mac_wr <= 1'b0;
        end
    end

    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            mac_rd <= 1'b0;
        end
        else if(rd) begin
            mac_rd <= 1'b1;
        end
        else if(finish)begin
            mac_rd <= 1'b0;
        end
    end

    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            mac_wdata <= 0;
        end
        else if(wr) begin
            mac_wdata <= wdata;
        end
    end

    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            mac_addr <= 0;
        end
        else if(wr ||rd)begin
            mac_addr <= addr;
        end
    end

    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            rdata <= 0;
        end
        else if(finish && mac_rd) begin  
            rdata <= mac_rdata;
        end
    end

    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            rdata_vld <= 0;
        end
        else if(finish && mac_rd) begin  
            rdata_vld <= 1'b1;
        end
        else begin
            rdata_vld <= 1'b0;
        end
    end

    always  @(*)begin
        if(wr || rd || mac_wr || mac_rd)
            rdy = 0;
        else
            rdy = 1;
    end



endmodule

