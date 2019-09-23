module sccb(
    clk       ,
    rst_n     ,
    ren       ,
    wen       ,
    sub_addr  ,
    rdata     ,
    rdata_vld ,
    wdata     ,
    rdy       ,
    sio_c     ,
    sio_d_r   ,
    en_sio_d_w,
    sio_d_w         
);

    //参数定义
    parameter      SIO_C  = 120; 
    parameter      I2C_ADDR = 7'h21;

    //输入信号定义
    input               clk      ;//25m
    input               rst_n    ;
    input               ren      ;
    input               wen      ;
    input [7:0]         sub_addr ;
    input [7:0]         wdata    ;

    //输出信号定义
    output reg  [7:0]         rdata    ;
    output reg                rdata_vld;
    output reg               sio_c    ;//208kHz
    output                 rdy      ;

    input                   sio_d_r   ;
    output reg             en_sio_d_w;
    output reg             sio_d_w   ;

    reg  [7:0]         cnt0;
    wire                add_cnt0;
    wire                end_cnt0;

    reg  [4:0]         cnt1;
    wire                add_cnt1;
    wire                end_cnt1;

    reg  [4:0]         cnt2;
    wire                add_cnt2;
    wire                end_cnt2;

    reg                 flag_add;
    reg  [5:0]         x;
    reg  [5:0]         y;
    reg                 flag_sel;

    reg  [26:0]         data;
    


    always @(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            cnt0 <= 0;
        end
        else if(add_cnt0)begin
            if(end_cnt0)
                cnt0 <= 0;
            else
                cnt0 <= cnt0 + 1;
        end
    end

    assign add_cnt0 = (flag_add == 1'b1);
    assign end_cnt0 = add_cnt0 && cnt0== (SIO_C - 1);

    always @(posedge clk or negedge rst_n)begin 
        if(!rst_n)begin
            cnt1 <= 0;
        end
        else if(add_cnt1)begin
            if(end_cnt1)
                cnt1 <= 0;
            else
                cnt1 <= cnt1 + 1;
        end
    end

    assign add_cnt1 = end_cnt0;
    assign end_cnt1 = add_cnt1 && cnt1== (x - 1);

    always @(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            cnt2 <= 0;
        end
        else if(add_cnt2)begin
            if(end_cnt2)
                cnt2 <= 0;
            else
                cnt2 <= cnt2 + 1;
        end
    end

    assign add_cnt2 = end_cnt1;
    assign end_cnt2 = add_cnt2 && cnt2== (y - 1);
     

    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            flag_add <= 1'b0;
        end
        else if(wen || ren)begin
            flag_add <= 1'b1;
        end
        else if(end_cnt2)begin
            flag_add <= 1'b0;
        end
    end


    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            flag_sel <= 1'b0;
        end
        else if(wen)begin
            flag_sel <= 1'b0;
        end
        else if(ren)begin
            flag_sel <= 1'b1;
        end
    end


    always  @(*)begin
        if(flag_sel == 1'b0) begin
            x = 32;
            y = 1;
        end
        else begin
            x = 23;
            y = 2;
        end
    end

    always  @(*)begin
        if(flag_sel == 1'b0) begin
            data = {7'h21, 
                    1'b0, 
                    1'b1, 
                    sub_addr,
                    1'b1,
                    wdata,
                    1'b1};
        end
        else begin
            if(cnt2 == 0) begin
                 data = {7'h21, 
                         1'b0, 
                         1'b1, 
                         sub_addr,
                         1'b1};
            end
            else begin
                 data = {7'h21, 
                         1'b1, 
                         1'b1, 
                         8'h00,
                         1'b0};
            end
        end
    end


    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            sio_c <= 1'b1;
        end
        else if(add_cnt0 && cnt0 == (SIO_C / 4) && cnt1 > 0 && cnt1 <= (x - 1 - 3))begin
            sio_c <= 1'b1;
        end
        else if(add_cnt0 && cnt0 == (SIO_C * 3 / 4) && cnt1 < (x - 1 - 3))begin
            sio_c <= 1'b0;
        end
    end

    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            sio_d_w <= 1'b1;
        end
        else if(cnt1 == 0 || cnt1 == (x - 1 - 3))begin
            sio_d_w <= 1'b0;
        end
       // else if(add_cnt0 && cnt0 == (1 - 1) && cnt1 == (x - 1 - 2))begin
       //     sio_d_w <= 1'b0;
       // end
        else if(cnt1 > (x - 1 - 3)) begin
            sio_d_w <= 1'b1;
        end
        else if(add_cnt0 && cnt0 == (1 - 1) && cnt1 > (1 - 1) && cnt1 < (x - 1 - 3)) begin
            sio_d_w <= data[x - 2 - 3 - cnt1];
        end
    end

    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            en_sio_d_w <= 1'b1;
        end
        else if(add_cnt0 && cnt0 == (1 -1) && cnt1 == (11 - 1) && cnt2 == (2 - 1))begin
            en_sio_d_w <= 1'b0;
        end
        else if(add_cnt0 && cnt0 == (1 - 1) && cnt1 == (19 - 1) && cnt2 == (2 - 1))begin
            en_sio_d_w <= 1'b1;
        end
    end

    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            rdata <= 8'hff;
        end
        else if(add_cnt0 && (cnt0 == (SIO_C / 2) && cnt1 > 9 && cnt1 < 18) && cnt2 == (2 - 1))begin
            rdata <= {rdata[6:0], sio_d_r};
        end
    end

    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            rdata_vld <= 1'b0;
        end
        else if(add_cnt0 && cnt0 == (SIO_C / 2) && cnt1 == (18 - 1) && cnt2 == (2 - 1))begin
            rdata_vld <= 1'b1;
        end
        else begin
            rdata_vld <= 1'b0;
        end
    end

    assign rdy = ~(wen | ren | flag_add);

endmodule





