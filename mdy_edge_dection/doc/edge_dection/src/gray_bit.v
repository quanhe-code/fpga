module gray_bit(
    clk         ,
    rst_n       ,
    value       ,
    din         ,
    din_vld     ,
    din_sop     ,
    din_eop     ,
    dout        ,
    dout_vld    ,
    dout_sop    ,
    dout_eop        
);

    //输入信号定义
    input         clk     ;
    input         rst_n   ;
    input  [7:0]  value   ;
    input  [7:0]  din     ;
    input         din_vld ;
    input         din_sop ;
    input         din_eop ;

    //输出信号定义
    output        dout    ;
    output        dout_vld;
    output        dout_sop;
    output        dout_eop;

    //输出信号reg定义
    reg           dout    ;
    reg           dout_vld;
    reg           dout_sop;
    reg           dout_eop;

    always @ (posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            dout <= 0;
        end
        else if(din >= value)begin
            dout <= 1;
        end
        else begin
            dout <= 0;
        end
    end

    always @ (posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            dout_vld <= 0;
        end
        else begin
            dout_vld <= din_vld;
        end
    end

    always @ (posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            dout_sop <= 0;
        end
        else begin
            dout_sop <= din_sop;
        end
    end

    always @ (posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            dout_eop <= 0;
        end
        else begin
            dout_eop <= din_eop;
        end
    end


endmodule

