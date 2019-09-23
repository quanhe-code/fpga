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

    input         clk     ;
    input         rst_n   ;
    input  [15:0] din     ;
    input         din_vld ;
    input         din_sop ;
    input         din_eop ;

    output wire  [7:0]  dout     ;
    output reg         dout_vld ;
    output reg         dout_sop ;
    output reg         dout_eop ;

    reg  [31:0]     dout_reg;
    wire [7:0]      r_8;
    wire [7:0]      g_8;
    wire [7:0]      b_8;
    

    assign r_8 = {din[15:11], 3'b000};
    assign g_8 = {din[10:5], 2'b00};
    assign b_8 = {din[4:0], 3'b000};

    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            dout_reg <= 32'h00;
        end
        else if(din_vld)begin
            dout_reg <= ((r_8 * 32'd299) + (g_8 * 32'd587) + (b_8 * 32'd114)) / 1000; 
        end
        else begin
            dout_reg <= 32'h00;
        end
    end

    assign dout = dout_reg[7:0];

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

