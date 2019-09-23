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

    input         clk     ;
    input         rst_n   ;
    input  [7:0]  value   ;
    input  [7:0]  din     ;
    input         din_vld ;
    input         din_sop ;
    input         din_eop ;

    output reg       dout    ;
    output reg       dout_vld;
    output reg       dout_sop;
    output reg       dout_eop;

    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            dout <= 1'b0;
        end
        else if(din_vld)begin
            if(din >= value)
                dout <= 1'b1;
            else
                dout <= 1'b0;
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

