module data_gen (
    clk         ,
    rst_n       ,
    en          ,
    busy        ,
    dout        ,
    dout_vld    ,
    dout_sop    ,
    dout_eop    ,
    dout_mty    ,
    rdy
);

input                   clk; 
input                   rst_n; 
input                   en; 
output                  busy;
output  [15:0]          dout; 
output                  dout_vld; 
output                  dout_sop; 
output                  dout_eop; 
output                  dout_mty; 
input                   rdy;

reg     [15:0]          dout;
reg                     dout_vld;
reg                     dout_sop;
reg                     dout_eop;
reg                     dout_mty;
reg                     flag;

reg     [4:0]           cnt;
wire                    add_cnt;
wire                    end_cnt;

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        flag <= 1'b0;
    end
    else if(en)begin
        flag <= 1'b1;
    end
    else if(end_cnt)begin
        flag <= 1'b0;
    end
end

always @(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        cnt <= 0;
    end
    else if(add_cnt)begin
        if(end_cnt)
            cnt <= 0;
        else
            cnt <= cnt + 1'b1;
    end
end

assign add_cnt = (flag == 1'b1 && rdy == 1'b1);       
assign end_cnt = add_cnt && cnt== (26 - 1);   


always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        dout <= 16'd0;;
    end
    else if(add_cnt && (cnt == (1 - 1)))begin
        dout <= 16'h0041;
    end
    else if(add_cnt) begin
        dout <= {dout[7:0],dout[7:0] + 1'b1};
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        dout_vld <= 1'b0;
    end
    else if(add_cnt)begin
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
    else if(add_cnt && (cnt == (1 - 1)))begin
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
    else if(end_cnt)begin
        dout_eop <= 1'b1;
    end
    else begin
        dout_eop <= 1'b0;
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        dout_mty <= 1'b0;
    end
    else begin
        dout_mty <= 1'b0;
    end
end

assign busy = flag;


endmodule
