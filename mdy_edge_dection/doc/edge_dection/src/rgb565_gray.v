module rgb565_gray(
    clk         ,
    rst_n       ,
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
    input  [15:0] din     ;
    input         din_vld ;
    input         din_sop ;
    input         din_eop ;

    //输出信号定义
    output [7:0]  dout     ;
    output        dout_vld ;
    output        dout_sop ;
    output        dout_eop ;

    //输出信号reg定义
    reg    [7:0]  dout     ;
    reg           dout_vld ;
    reg           dout_sop ;
    reg           dout_eop ;

    //中间信号定义
    wire   [7:0]  red     ;
    wire   [7:0]  green   ;
    wire   [7:0]  blue    ;

    assign red   = {din[15:11],din[13:11]};
    assign green = {din[10:5],din[6:5]};
    assign blue  = {din[4:0],din[2:0]}; 

    always @ (posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            dout <= 0;
        end
        else if(din_vld)begin
            dout <= (red*76 + green*150 + blue*30) >> 8;
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

