module  ds_intf_byte(
         clk       ,
         rst_n     ,
         rst_en    ,
         wr_en     ,
         wdata     ,
         rd_en     ,
         rdata     ,
         rdata_vld ,
         rdy       ,         
         rst_en_bit,
         wr_en_bit ,
         wdata_bit ,
         rd_en_bit ,
         rdata_bit ,      
         rdata_vld_bit,
         rdy_bit         
        );

input         clk       ;
input         rst_n     ;
input         rst_en    ;
input         wr_en     ;
input [7:0]   wdata     ;
input         rd_en     ;
output reg        rst_en_bit;
output reg       wr_en_bit ;
output reg       wdata_bit ;
output reg       rd_en_bit ;
input         rdata_bit ;      
input         rdata_vld_bit;
input         rdy_bit   ;      
output reg [7:0]   rdata     ;
output reg       rdata_vld ;
output        rdy       ; 


reg           flag_rst_en;
reg           flag_rdy;
wire          rdy1;

reg           flag_wr_en;
reg  [3:0]    cnt;
wire          add_cnt;
wire          end_cnt;

wire          rdy2;
reg           flag_wr_rdy;

reg           flag_rd_en;
reg  [3:0]    cnt1;
wire          add_cnt1;
wire          end_cnt1;
reg           flag_rd_rdy;

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        flag_rst_en <= 0;
    end
    else if(rst_en == 1) begin
        flag_rst_en <= 1'b1;
    end
    else if(rdy_bit == 1'b1)begin
        flag_rst_en <= 1'b0;
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        rst_en_bit <= 1'b0;
    end
    else if(flag_rst_en == 1'b1 && rdy_bit == 1'b1) begin
        rst_en_bit <= 1'b1;
    end
    else begin
        rst_en_bit <= 1'b0;
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        flag_rdy <= 1'b0;
    end
    else if(rst_en == 1'b1)begin
        flag_rdy <= 1'b1;
    end
    else if(flag_rst_en == 1'b1 && rdy_bit == 1'b1)begin
        flag_rdy <= 1'b0;
    end
end

assign rdy1 = ~(rst_en | flag_rdy);

// 写一个字节
always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        flag_wr_en <= 1'b0;
    end
    else if(wr_en == 1'b1)begin
        flag_wr_en <= 1'b1;
    end
    else if(end_cnt)begin
        flag_wr_en <= 1'b0;
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
            cnt <= cnt + 1;
    end
end

assign add_cnt = (flag_wr_en == 1'b1 && rdy_bit == 1'b1);       
assign end_cnt = add_cnt && cnt== (8 - 1);   

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        wr_en_bit <= 1'b0;
    end
    else if(add_cnt)begin
        wr_en_bit <= 1'b1;
    end
    else begin
        wr_en_bit <= 1'b0;
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        wdata_bit <= 1'b0;
    end
    else if(add_cnt)begin
        wdata_bit <= wdata[cnt];
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        flag_wr_rdy <= 1'b0;
    end
    else if(wr_en)begin
        flag_wr_rdy <= 1'b1;
    end
    else if(end_cnt)begin
        flag_wr_rdy <= 1'b0;
    end
end

assign rdy2 = ~(wr_en | flag_wr_rdy);

// 读一个字节
always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        flag_rd_en <= 1'b0;
    end
    else if(rd_en == 1'b1)begin
        flag_rd_en <= 1'b1;
    end
    else if(end_cnt1)begin
        flag_rd_en <= 1'b0;
    end
end

always @(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        cnt1 <= 0;
    end
    else if(add_cnt1)begin
        if(end_cnt1)
            cnt1 <= 0;
        else
            cnt1 <= cnt1 + 1;
    end
end

assign add_cnt1 = (flag_rd_en == 1'b1 && rdata_vld_bit == 1'b1);     
assign end_cnt1 = add_cnt1 && cnt1== (8 - 1);   

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        rd_en_bit <= 1'b0;
    end
    else if(flag_rd_en == 1'b1 && rdy_bit == 1'b1)begin
        rd_en_bit <= 1'b1;
    end
    else begin
        rd_en_bit <= 1'b0;
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        rdata <= 8'h00;
    end
    else if(add_cnt1)begin
        rdata[cnt1] <= rdata_bit;
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        rdata_vld <= 1'b0;
    end
    else if(end_cnt1)begin
        rdata_vld <= 1'b1;
    end
    else begin
        rdata_vld <= 1'b0;
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        flag_rd_rdy <= 1'b0;
    end
    else if(rd_en == 1'b1)begin
        flag_rd_rdy <= 1'b1;
    end
    else if(end_cnt1)begin
        flag_rd_rdy <= 1'b0;
    end
end

assign rdy3 = ~(rd_en | flag_rd_rdy);

assign rdy = (rdy1 & rdy2 & rdy3);

endmodule
