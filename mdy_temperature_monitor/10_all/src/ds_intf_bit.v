// 潘老师这个模块利用计数器的加18b20 复位、读、写时序的共性
// 将dq_out信号和rdy信号整合在一个always里，相当到位。

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

    parameter        CNT_1000US = 15'd25000; // 1000us
    parameter        CNT_750US = 15'd18750;
    parameter        CNT_15US = 15'd375;
    parameter        CNT_60US = 15'd1500;
    parameter        CNT_62US = 15'd1550;
    parameter        CNT_1US  = 15'd25;
    parameter        CNT_14US = 15'd350;

    input               clk       ;
    input               rst_n     ;
    input               rst_en    ;
    input               wr_en     ;
    input               wdata     ;
    input               rd_en     ;
    input               dq_in     ;

    output reg             rdata     ;
    output reg             rdata_vld ;
    output reg             dq_out    ;
    output reg             dq_out_en ;
    output              rdy       ;

    

    reg  [14:0]         x;
    reg  [14:0]         cnt;
    wire                add_cnt;
    wire                end_cnt;
    reg                 flag_rst;
    reg                 dq_out1;
    reg                 dq_out_en1;
  
    reg                 flag_wr;
    reg                 dq_out2;
    reg                 dq_out_en2;

    reg                 flag_rd;
    reg                 dq_out3;
    reg                 dq_out_en3;

    wire                rdy1;
    wire                rdy2;
    wire                rdy3;

    // 复位请求
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

    assign add_cnt = (flag_rst == 1'b1 || flag_wr == 1'b1 || flag_rd == 1'b1);       
    assign end_cnt = add_cnt && cnt== (x - 1);   

    always  @(*)begin
        if(flag_rst) begin
            x = CNT_1000US;
        end
        else if(flag_wr)begin
            x = CNT_62US;
        end
        else if(flag_rd)begin
            x = CNT_62US;
        end
        else begin
            x = 1;
        end
    end

    
    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            flag_rst <= 1'b0;
        end
        else if(rst_en == 1'b1)begin
            flag_rst <= 1'b1;
        end
        else if(end_cnt)begin
            flag_rst <= 1'b0;
        end
    end

    

    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            dq_out1 <= 1'b1;
        end
        else if(rst_en == 1'b1)begin
            dq_out1 <= 1'b0;
        end
        else if(add_cnt && cnt == (CNT_750US - 1))begin
            dq_out1 <= 1'b1;
        end
    end


    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            dq_out_en1 <= 1'b0;
        end
        else if(rst_en == 1'b1)begin
            dq_out_en1 <= 1'b1;
        end
        else if(add_cnt && cnt == (CNT_750US - 1))begin
            dq_out_en1 <= 1'b0;
        end
    end

    assign rdy1 = ~(rst_en | flag_rst);

    // 写数据
    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            flag_wr <= 1'b0;
        end
        else if(wr_en == 1'b1)begin
            flag_wr <= 1'b1;
        end
        else if(end_cnt)begin
            flag_wr <= 1'b0;
        end
    end

    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            dq_out2 <= 1'b1;
        end
        else if(wr_en == 1'b1)begin
            dq_out2 <= 1'b0;
        end
        else if(add_cnt && cnt == (CNT_15US - 1))begin
            dq_out2 <= wdata;
        end
        else if(add_cnt && cnt == (CNT_60US - 1)) begin
            dq_out2 <= 1'b1;
        end
    end

    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            dq_out_en2 <= 1'b0;
        end
        else if(wr_en == 1'b1)begin
            dq_out_en2 <= 1'b1;
        end
        else if(add_cnt && cnt == (CNT_60US - 1))begin
            dq_out_en2 <= 1'b0;
        end
    end

    assign rdy2 = ~(wr_en | flag_wr);

    //  读数据
    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            flag_rd <= 1'b0;
        end
        else if(rd_en == 1'b1)begin
            flag_rd <= 1'b1;
        end
        else if(end_cnt)begin
            flag_rd <= 1'b0;
        end
    end
    
    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            dq_out3 <= 1'b1;
        end
        else if(rd_en == 1'b1)begin
            dq_out3 <= 1'b0;
        end
        else if(add_cnt && cnt == (CNT_1US - 1))begin
            dq_out3 <= 1'b1;
        end
    end

    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            dq_out_en3 <= 1'b0;
        end
        else if(rd_en == 1'b1)begin
            dq_out_en3 <= 1'b1;
        end
        else if(add_cnt && cnt == (CNT_1US - 1))begin
            dq_out_en3 <= 1'b0;
        end
    end

    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            rdata <= 1'b0;
        end
        else if(flag_rd == 1'b1 && add_cnt && cnt == (CNT_14US - 1))begin
            rdata <= dq_in;
        end
    end

    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            rdata_vld <= 1'b0;
        end
        else if(flag_rd == 1'b1 && add_cnt && cnt == (CNT_14US - 1))begin
            rdata_vld <= 1'b1;
        end
        else begin
            rdata_vld <= 1'b0;
        end
    end

    assign rdy3 = ~(rd_en | flag_rd);

    always  @(*)begin
        if(flag_rst) begin
            dq_out = dq_out1;
            dq_out_en = dq_out_en1;
        end
        else if(flag_wr) begin
            dq_out = dq_out2;
            dq_out_en = dq_out_en2;
        end
        else if(flag_rd) begin
            dq_out = dq_out3;
            dq_out_en = dq_out_en3;
        end
        else begin
            dq_out = 1'b1;
            dq_out_en = 1'b0;
        end
    end

    assign rdy = (rdy1 && rdy2 && rdy3);

endmodule

