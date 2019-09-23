module key_config(
    clk         ,
    rst_n       ,
    key_num     ,
    key_vld     ,
    en_coms     ,
    value_gray  ,
    reset            
);

    //输入信号定义
    input         clk        ;
    input         rst_n      ;
    input         key_vld    ;
    input  [3:0]  key_num    ;

    //输出信号定义
    output        en_coms    ;
    output [7:0]  value_gray ;
    output        reset      ;

    //输出信号reg定义
    reg           en_coms    ;
    reg    [7:0]  value_gray ;
    reg           reset      ;

    always @ (posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            reset <= 0;
        end
        else if(key_vld && key_num == 0)begin
            reset <= 0;
        end
        else begin
            reset <= 1;
        end
    end

    always @ (posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            en_coms <= 0;
        end
        else if(key_vld && key_num == 1)begin
            en_coms <= 1;
        end
        else begin
            en_coms <= 0;
        end
    end

    always @ (posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            value_gray <= 130;
        end
        else if(key_vld && key_num == 4)begin
            if(value_gray >= 245)
                value_gray <= 255;
            else
                value_gray <= value_gray + 10;
        end
        else if(key_vld && key_num == 5)begin
            if(value_gray >= 254)
                value_gray <= 255;
            else
                value_gray <= value_gray + 1;
        end
        else if(key_vld && key_num == 8)begin
            if(value_gray <= 10)
                value_gray <= 0;
            else
                value_gray <= value_gray - 10;
        end
        else if(key_vld && key_num == 9)begin
            if(value_gray <= 1)
                value_gray <= 0;
            else
                value_gray <= value_gray - 1;
        end
    end

endmodule

