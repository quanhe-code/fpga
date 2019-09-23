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

    input         clk     ;
    input         rst_n   ;
    input         din     ;
    input         din_vld ;
    input         din_sop ;
    input         din_eop ;

    output reg       dout    ;
    output reg       dout_vld;
    output reg       dout_sop;
    output reg       dout_eop;

    reg        s00;
    reg        s01;
    wire        s02;

    reg        s10;
    reg        s11;
    wire        s12;

    reg        s20;
    reg        s21;
    reg        s22;

    shift2_ipcore u1(
	    .clken      (din_vld    ),
	    .clock      (clk        ),
	    .shiftin    (din        ),
//	    .shiftout   (shiftout   ),
	    .taps0x     (taps0_tmp  ),
	    .taps1x     (taps1_tmp  ),
	    .taps2x     (taps2_tmp  ) 
    );


    assign s02 = taps1_tmp; 

    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            s01 <= 0;
        end
        else if(dout_vld)begin
            s01 <= s00;
        end
    end

    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            s00 <= 0;
        end
        else if(dout_vld)begin
            s00 <= s01;
        end
    end

    assign s12 = taps2_tmp;

    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            s11 <= 0;
        end
        else if(dout_vld)begin
            s11 <= s10;
        end
    end

    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            s10 <= 0;
        end
        else if(dout_vld)begin
            s10 <= s11;
        end
    end

    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            s22 <= 0;
        end
        else if(din_vld)begin
            s22 <= din;
        end
    end

    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            s21 <= 0;
        end
        else if(dout_vld)begin
            s21 <= s22;
        end
    end

    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            s20 <= 0;
        end
        else if(dout_vld)begin
            s20 <= 1;
        end
    end
    
    assign x_temp1 = (s02 + (2 * s12) + s22);
    assign x_temp2 = (s00 + (2 * s10) + s20);
    assign x_res = (x_temp1 > x_temp2) ? (x_temp1 - x_temp2) : (x_temp2 - x_temp1);

    assign y_temp1 = (s00 + (2 * s01) + s02);
    assign y_temp2 = (s20 + (2 * s21) + s22);
    assign y_res = (y_temp1 > y_temp2) ? (y_temp1 - y_temp2) : (y_temp2 - y_temp1);

    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            dout <= 1'b0;
        end
        else if(din_vld)begin
            dout <= ((x_res + y_res) > 3) ? 1'b1 : 1'b0;
        end
    end

    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            dout_vld <= 1'b0;
        end
        else if(din_vld)begin
            dout_vld <= 1'b1;
        end
        else begin
            dout_vld <= 1'b0;
        end
    end

    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            dout_sop <= 1'b0;
        end
        else if(din_sop)begin
            dout_sop <= 1'b1;
        end
        else begin
            dout_sop <= 1'b0;
        end
    end

    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            dout_eop <= 1'b0;
        end
        else if(din_eop)begin
            dout_eop <= 1'b1;
        end
        else begin
            dout_eop <= 1'b0;
        end
    end

endmodule

