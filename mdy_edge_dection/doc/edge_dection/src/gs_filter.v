module gs_filter(
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
    input  [7:0]  din     ;
    input         din_vld ;
    input         din_sop ;
    input         din_eop ;

    //输出信号定义
    output [7:0]  dout    ;
    output        dout_vld;
    output        dout_sop;
    output        dout_eop;

    //输出信号reg定义
    reg    [7:0]  dout    ;
    reg           dout_vld;
    reg           dout_sop;
    reg           dout_eop;

    //中间信号定义
    reg           din_vld_ff0 ;
    reg           din_vld_ff1 ;
    reg           din_vld_ff2 ;
    reg           din_sop_ff0 ;
    reg           din_sop_ff1 ;
    reg           din_sop_ff2 ;
    reg           din_eop_ff0 ;
    reg           din_eop_ff1 ;
    reg           din_eop_ff2 ;
    reg    [7:0]  taps0_ff0   ;
    reg    [7:0]  taps0_ff1   ;
    reg    [7:0]  taps1_ff0   ;
    reg    [7:0]  taps1_ff1   ;
    reg    [7:0]  taps2_ff0   ;
    reg    [7:0]  taps2_ff1   ;
    reg    [15:0] gs_0        ;
    reg    [15:0] gs_1        ;
    reg    [15:0] gs_2        ;

    wire   [7:0]  taps0   ;
    wire   [7:0]  taps1   ;
    wire   [7:0]  taps2   ;

//对应关系
// f(x-1,y-1) f(x,y-1),f(x+1,y-1)  = line2_ff[1] line2_ff[0] Line2 
// f(x-1,y+0) f(x,y+0),f(x+1,y+0)  = line1_ff[1] line1_ff[0] Line1 
// f(x-1,y+1) f(x,y+1),f(x+1,y+1)  = line0_ff[1] line0_ff[0] Line0 

//高斯滤波公式
//g(x,y)={f(x-1,y-1)+f(x-1,y+1)+f(x+1,y-1)+f(x+1,y+1)+[f(x-1,y)+f(x,y-1)+f(x+1,y)+f(x,y+1)]*2+f(x,y)*4}/16
//      = (gs_0+gs_1+gs_2)/16

    shift_ipcore u1(
	    .clken      (din_vld    ),
	    .clock      (clk        ),
	    .shiftin    (din        ),
//	    .shiftout   (shiftout   ),
	    .taps0x     (taps0      ),
	    .taps1x     (taps1      ),
	    .taps2x     (taps2      ) 
    );

    always @ (posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            din_vld_ff0 <= 0;
            din_vld_ff1 <= 0;
            din_vld_ff2 <= 0;
            din_sop_ff0 <= 0;
            din_sop_ff1 <= 0;
            din_sop_ff2 <= 0;
            din_eop_ff0 <= 0;
            din_eop_ff1 <= 0;
            din_eop_ff2 <= 0;
        end
        else begin
            din_vld_ff0 <= din_vld;
            din_vld_ff1 <= din_vld_ff0;
            din_vld_ff2 <= din_vld_ff1;
            din_sop_ff0 <= din_sop;
            din_sop_ff1 <= din_sop_ff0;
            din_sop_ff2 <= din_sop_ff1;
            din_eop_ff0 <= din_eop;
            din_eop_ff1 <= din_eop_ff0;
            din_eop_ff2 <= din_eop_ff1;
        end
    end

    always @ (posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            taps0_ff0 <= 0;
            taps0_ff1 <= 0;
            taps1_ff0 <= 0;
            taps1_ff1 <= 0;
            taps2_ff0 <= 0;
            taps2_ff1 <= 0;
        end
        else if(din_vld_ff0)begin
            taps0_ff0 <= taps0;
            taps0_ff1 <= taps0_ff0;
            taps1_ff0 <= taps1;
            taps1_ff1 <= taps1_ff0;
            taps2_ff0 <= taps2;
            taps2_ff1 <= taps2_ff0;
        end
    end

    always @ (posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            gs_0 <= 0;
        end
        else if(din_vld_ff1)begin
            gs_0 <= taps0_ff1 + 2*taps1_ff1 + taps2_ff1;
        end
    end

    always @ (posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            gs_1 <= 0;
        end
        else if(din_vld_ff1)begin
            gs_1 <= 2*taps0_ff0 + 4*taps1_ff0 + 2*taps2_ff0;
        end
    end

    always @ (posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            gs_2 <= 0;
        end
        else if(din_vld_ff1)begin
            gs_2 <= taps0 + 2*taps1 + taps2;
        end
    end

    always @ (posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            dout <= 0;
        end
        else if(din_vld_ff2)begin
            dout <= (gs_0 + gs_1 + gs_2) >> 4;
        end
    end

    always @ (posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            dout_vld <= 0;
        end
        else if(din_vld_ff2)begin
            dout_vld <= 1;
        end
        else begin
            dout_vld <= 0;
        end
    end

    always @ (posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            dout_sop <= 0;
        end
        else if(din_sop_ff2)begin
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
        else if(din_eop_ff2)begin
            dout_eop <= 1;
        end
        else begin
            dout_eop <= 0;
        end
    end

endmodule

