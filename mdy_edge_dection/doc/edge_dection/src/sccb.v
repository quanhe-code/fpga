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
    parameter      SIO_C  = 120 ; 

    //输入信号定义
    input               clk      ;//25m
    input               rst_n    ;
    input               ren      ;
    input               wen      ;
    input [7:0]         sub_addr ;
    input [7:0]         wdata    ;

    //输出信号定义
    output[7:0]         rdata    ;
    output              rdata_vld;
    output              sio_c    ;//208kHz
    output              rdy      ;

    input               sio_d_r   ;
    output              en_sio_d_w;
    output              sio_d_w   ;
    reg                 en_sio_d_w;
    reg                 sio_d_w   ;

    //输出信号reg定义
    reg [7:0]           rdata    ;
    reg                 rdata_vld;
    reg                 sio_c    ;
    reg                 rdy      ;

    //中间信号定义
    reg  [7:0]          count_sck     ;
    reg  [4:0]          count_bit     ;
    reg  [1:0]          count_duan    ;
    reg                 flag_r        ;
    reg                 flag_w        ;
    reg  [4:0]          bit_num       ;
    reg  [1:0]          duan_num      ;
    reg  [29:0]         out_data      ;

    wire                add_count_sck ;
    wire                end_count_sck ;
    wire                add_count_bit ;
    wire                end_count_bit ;
    wire                add_count_duan;
    wire                end_count_duan;
    wire                sio_c_h2l     ;
    wire                sio_c_l2h     ;
    wire                en_sio_d_w_h2l;
    wire                en_sio_d_w_l2h;
    wire                out_data_time ;
    wire                rdata_time    ;
    wire [7:0]          rd_com        ;
    
    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            count_sck <= 0;
        end
        else if(add_count_sck)begin
            if(end_count_sck)begin
                count_sck <= 0;
            end
            else begin
                count_sck <= count_sck + 1;
            end
        end
    end

    assign add_count_sck = flag_r || flag_w;
    assign end_count_sck = add_count_sck && count_sck == SIO_C-1;

    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            count_bit <= 0;
        end
        else if(add_count_bit)begin
            if(end_count_bit)begin
                count_bit <= 0;
            end
            else begin
                count_bit <= count_bit + 1;
            end
        end
    end

    assign add_count_bit = end_count_sck;
    assign end_count_bit = add_count_bit && count_bit == bit_num+2-1;

    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            count_duan <= 0;
        end
        else if(add_count_duan)begin
            if(end_count_duan)begin
                count_duan <= 0;
            end
            else begin
                count_duan <= count_duan + 1;
            end
        end
    end

    assign add_count_duan = end_count_bit;
    assign end_count_duan = add_count_duan && count_duan == duan_num-1;

    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            flag_r <= 0;
        end
        else if(ren)begin
            flag_r <= 1;
        end
        else if(end_count_duan)begin
            flag_r <= 0;
        end
    end

    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            flag_w <= 0;
        end
        else if(wen)begin
            flag_w <= 1;
        end
        else if(end_count_duan)begin 
            flag_w <= 0;
        end
    end

    always  @(*)begin
        if(flag_r)begin
            bit_num = 21;
            duan_num = 2;
        end
        else if(flag_w)begin
            bit_num = 30;
            duan_num = 1;
        end
        else begin
            bit_num = 1;
            duan_num = 1;
        end
    end

    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            sio_c <= 1;
        end
        else if(sio_c_h2l)begin
            sio_c <= 0;
        end
        else if(sio_c_l2h)begin
            sio_c <= 1;
        end
    end

    assign sio_c_h2l = count_bit >= 0 && count_bit < (bit_num-2) && add_count_sck && count_sck == SIO_C-1;
    assign sio_c_l2h = count_bit >= 1 && count_bit < bit_num && add_count_sck && count_sck == SIO_C/2-1;

/*    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            out_data <= 0;
        end
        else if(ren)begin
            out_data <= {1'h0,rd_com,1'h1,sub_addr,1'h1,1'h0,1'h1,9'h0};
        end
        else if(wen)begin
            out_data <= {1'h0,8'h42,1'h1,sub_addr,1'h1,wdata,1'h1,1'h0,1'h1};
        end
    end*/

    always @ (*)begin
        if(flag_r)begin
            out_data <= {1'h0,rd_com,1'h1,sub_addr,1'h1,1'h0,1'h1,9'h0};
        end
        else if(flag_w)begin
            out_data <= {1'h0,8'h42,1'h1,sub_addr,1'h1,wdata,1'h1,1'h0,1'h1};
        end
        else begin
            out_data <= 0;
        end
    end

    assign rd_com = (flag_r && count_duan == 0)? 8'h42 : 8'h43;

    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            en_sio_d_w <= 0;
        end
        else if(ren || wen)begin
            en_sio_d_w <= 1;
        end
        else if(end_count_duan)begin
            en_sio_d_w <= 0;
        end
        else if(en_sio_d_w_h2l)begin
            en_sio_d_w <= 0;
        end
        else if(en_sio_d_w_l2h)begin
            en_sio_d_w <= 1;
        end
    end

    assign en_sio_d_w_h2l = flag_r && count_duan == 1 && count_bit == 10 && add_count_sck && count_sck == 1-1;
    assign en_sio_d_w_l2h = flag_r && count_duan == 1 && count_bit == 18 && add_count_sck && count_sck == 1-1;

    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            sio_d_w <= 1;
        end
        else if(out_data_time)begin
            sio_d_w <= out_data[30-count_bit-1];
        end
    end

    assign out_data_time = count_bit >= 0 && count_bit < bit_num && add_count_sck && count_sck == SIO_C/4-1;

    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            rdata <= 0;
        end
        else if(rdata_time)begin
            rdata[17-count_bit] <= sio_d_r;
        end
    end

    assign rdata_time = flag_r && count_duan==1 && count_bit>=10 && count_bit<18 && add_count_sck && count_sck==SIO_C/4*3-1;

    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            rdata_vld <= 0;
        end
        else if(flag_r && end_count_duan)begin
            rdata_vld <= 1;
        end
        else begin
            rdata_vld <= 0;
        end
    end

    always  @(*)begin
        if(ren || wen || flag_r || flag_w)begin
            rdy = 0;
        end
        else begin
            rdy = 1;
        end
    end

endmodule

