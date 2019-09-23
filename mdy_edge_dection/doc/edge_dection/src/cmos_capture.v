module cmos_capture(
    clk         ,
    rst_n       ,
    en_capture  ,
    vsync       ,
    href        ,
    din         ,
    dout        ,
    dout_vld    ,
    dout_sop    ,
    dout_eop     
);

    //参数定义
    parameter     COL    = 640;
    parameter     ROW    = 480;

    //输入信号定义
    input          clk          ; 
    input          rst_n        ;
    input          en_capture   ;
    input          vsync        ;
    input          href         ;
    input  [7:0]   din          ;

    //输出信号定义
    output [15:0]  dout         ;
    output         dout_vld     ;
    output         dout_sop     ;
    output         dout_eop     ;

    //输出信号reg定义
    reg    [15:0]  dout         ;
    reg            dout_vld     ;
    reg            dout_sop     ;
    reg            dout_eop     ;

    //中间信号定义
    reg    [10:0]  count_x      ;
    reg    [9:0]   count_y      ;
    reg            flag_capture ;
    reg            vsync_ff0;

    wire           add_count_x  ;
    wire           end_count_x  ;
    wire           add_count_y  ;
    wire           end_count_y  ;
    wire           vsync_l2h;
    wire           din_vld      ;
    wire           flag_dout_vld;

    always @ (posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            count_x <= 0;
        end
        else if(add_count_x)begin
            if(end_count_x)begin
                count_x <= 0;
            end
            else begin
                count_x <= count_x + 1;
            end
        end
    end

    assign add_count_x = flag_capture && din_vld;
    assign end_count_x = add_count_x && count_x == COL*2-1;

    always @ (posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            count_y <= 0;
        end
        else if(add_count_y)begin
            if(end_count_y)begin
                count_y <= 0;
            end
            else begin
                count_y <= count_y + 1;
            end
        end
    end

    assign add_count_y = end_count_x;
    assign end_count_y = add_count_y && count_y == ROW-1;

    always @ (posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            flag_capture <= 0;
        end
        else if(flag_capture == 0 && vsync_l2h && en_capture)begin
            flag_capture <= 1;
        end
        else if(end_count_y)begin
            flag_capture <= 0;
        end
    end

    assign vsync_l2h = vsync_ff0 == 0 && vsync == 1;

    always @ (posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            vsync_ff0 <= 0;
        end
        else begin
            vsync_ff0 <= vsync;
        end
    end

    always @ (posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            dout <= 0;
        end
        else if(din_vld)begin
            dout <= {dout[7:0],din};
        end
    end

    assign din_vld = flag_capture && href;

    always @ (posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            dout_vld <= 0;
        end
        else if(flag_dout_vld)begin
            dout_vld <= 1;
        end
        else begin
            dout_vld <= 0;
        end
    end

    assign flag_dout_vld = add_count_x && count_x[0] == 1;

    always @ (posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            dout_sop <= 0;
        end
        else if(flag_dout_vld && count_x[10:1] == 0 && count_y == 0)begin
            dout_sop <= 1;
        end
        else begin
            dout_sop <= 0;
        end
    end

    always @ (posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            dout_eop <= 0;
        end
        else if(flag_dout_vld && count_x[10:1] == COL-1 && count_y == ROW-1)begin
            dout_eop <= 1;
        end
        else begin
            dout_eop <= 0;
        end
    end

endmodule

