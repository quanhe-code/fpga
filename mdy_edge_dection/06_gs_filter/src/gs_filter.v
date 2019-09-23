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

    input         clk     ;
    input         rst_n   ;
    input  [7:0]  din     ;
    input         din_vld ;
    input         din_sop ;
    input         din_eop ;

    output reg  [7:0]  dout    ;
    output reg         dout_vld;
    output reg         dout_sop;
    output reg         dout_eop;

    reg  [7:0]      s00;
    reg  [7:0]      s01;
    wire [7:0]      s02;

    reg  [7:0]      s10;
    reg  [7:0]      s11;
    wire [7:0]      s12;

    reg  [7:0]      s20;
    reg  [7:0]      s21;
    reg  [7:0]      s22;

    shift_ipcore u1(
	    .clken      (din_vld    ),
	    .clock      (clk        ),
	    .shiftin    (din        ),
//	    .shiftout   (shiftout   ),
	    .taps0x     (taps0      ),
	    .taps1x     (taps1      ),
	    .taps2x     (taps2      ) 
    );

    assign s02 = taps1;
    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            s01 <= 8'h00;
        end
        else if(dout_vld)begin
            s01 <= s02;
        end
    end

    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            s00 <= 8'h00;
        end
        else if(dout_vld)begin
            s00 <= s01;
        end
    end

    assign s12 = taps2;
    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            s11 <= 8'h00;
        end
        else if(dout_vld)begin
            s11 <= s12;
        end
    end

    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            s10 <= 8'h00;
        end
        else if(dout_vld)begin
            s10 <= s11;
        end
    end


    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            s22 <= 1'b0;
        end
        else if(din_vld)begin
            s22 <= din;
        end
    end

    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            s21 <= 8'h00;
        end
        else if(dout_vld)begin
            s21 <= s22;
        end
    end

    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            s20 <= 8'h00;
        end
        else if(dout_vld)begin
            s20 <= s11;
        end
    end

    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            dout <= 8'h00;
        end
        else if(din_vld)begin
            dout <= (s00 + (s01 * 2) + s02 + (2 * s10) + (4 * s11) + (2 * s12) + s20 + (2 * s21) + s22) / 16;
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

