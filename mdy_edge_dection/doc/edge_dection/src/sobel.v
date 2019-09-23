module sobel(
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
    input         din     ;
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

    //中间信号定义
    reg           din_vld_ff0 ;
    reg           din_vld_ff1 ;
    reg           din_vld_ff2 ;
    reg           din_vld_ff3 ;
    reg           din_sop_ff0 ;
    reg           din_sop_ff1 ;
    reg           din_sop_ff2 ;
    reg           din_sop_ff3 ;
    reg           din_eop_ff0 ;
    reg           din_eop_ff1 ;
    reg           din_eop_ff2 ;
    reg           din_eop_ff3 ;
    reg           taps0_ff0   ;
    reg           taps0_ff1   ;
    reg           taps1_ff0   ;
    reg           taps1_ff1   ;
    reg           taps2_ff0   ;
    reg           taps2_ff1   ;
    reg    [7:0]  gx_0        ;
    reg    [7:0]  gx_2        ;
    reg    [7:0]  gy_0        ;
    reg    [7:0]  gy_2        ;
    reg    [7:0]  gx          ;
    reg    [7:0]  gy          ;
    reg    [7:0]  g           ;

    wire          taps0_tmp   ;
    wire          taps1_tmp   ;
    wire          taps2_tmp   ;
    wire          taps0       ;
    wire          taps1       ;
    wire          taps2       ;

    shift2_ipcore u1(
	    .clken      (din_vld    ),
	    .clock      (clk        ),
	    .shiftin    (din        ),
//	    .shiftout   (shiftout   ),
	    .taps0x     (taps0_tmp  ),
	    .taps1x     (taps1_tmp  ),
	    .taps2x     (taps2_tmp  ) 
    );

    assign taps0 = taps0_tmp;
    assign taps1 = taps1_tmp;
    assign taps2 = taps2_tmp;

    always @ (posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            din_vld_ff0 <= 0;
            din_vld_ff1 <= 0;
            din_vld_ff2 <= 0;
            din_vld_ff3 <= 0;
            din_sop_ff0 <= 0;
            din_sop_ff1 <= 0;
            din_sop_ff2 <= 0;
            din_sop_ff3 <= 0;
            din_eop_ff0 <= 0;
            din_eop_ff1 <= 0;
            din_eop_ff2 <= 0;
            din_eop_ff3 <= 0;
        end
        else begin
            din_vld_ff0 <= din_vld;
            din_vld_ff1 <= din_vld_ff0;
            din_vld_ff2 <= din_vld_ff1;
            din_vld_ff3 <= din_vld_ff2;
            din_sop_ff0 <= din_sop;
            din_sop_ff1 <= din_sop_ff0;
            din_sop_ff2 <= din_sop_ff1;
            din_sop_ff3 <= din_sop_ff2;
            din_eop_ff0 <= din_eop;
            din_eop_ff1 <= din_eop_ff0;
            din_eop_ff2 <= din_eop_ff1;
            din_eop_ff3 <= din_eop_ff2;
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
            gx_0 <= 0;
        end
        else if(din_vld_ff1)begin
            gx_0 <= taps0_ff1 + 2*taps1_ff1 + taps2_ff1;
        end
    end

    always @ (posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            gx_2 <= 0;
        end
        else if(din_vld_ff1)begin
            gx_2 <= taps0 + 2*taps1 + taps2;
        end
    end

    always @ (posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            gy_0 <= 0;
        end
        else if(din_vld_ff1)begin
            gy_0 <= taps0_ff1 + 2*taps0_ff0 + taps0;
        end
    end

    always @ (posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            gy_2 <= 0;
        end
        else if(din_vld_ff1)begin
            gy_2 <= taps2_ff1 + 2*taps2_ff0 + taps2;
        end
    end

    always @ (posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            gx <= 0;
        end
        else if(din_vld_ff2)begin
            gx <= (gx_0>gx_2) ? (gx_0-gx_2) : (gx_2-gx_0);
        end
    end

    always @ (posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            gy <= 0;
        end
        else if(din_vld_ff2)begin
            gy <= (gy_0>gy_2) ? (gy_0-gy_2) : (gy_2-gy_0);
        end
    end

    always @ (posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            g <= 0;
        end
        else if(din_vld_ff3)begin
            g <= gx + gy;
        end
    end

    always @ (*)begin
        dout = (g>=1) ? 1 : 0;
    end

    always @ (posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            dout_vld <= 0;
        end
        else if(din_vld_ff3)begin
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
        else if(din_sop_ff3)begin
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
        else if(din_eop_ff3)begin
            dout_eop <= 1;
        end
        else begin
            dout_eop <= 0;
        end
    end

endmodule

