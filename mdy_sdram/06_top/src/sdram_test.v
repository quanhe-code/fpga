module sdram_test(
    clk             ,
    rst_n           ,

    start           ,

    wr_req          ,
    waddr           ,
    wdata           ,
    wr_ack          ,

    rd_req          ,
    raddr           ,
    rd_ack          
);

input                   clk;             
input                   rst_n;           

input                   start;

output                  wr_req;          
output  [21:0]          waddr;           
output  [15:0]          wdata;           
input                   wr_ack;          

output                  rd_req;          
output  [21:0]          raddr;           
input                   rd_ack;          

reg                     wr_req;          
reg     [21:0]          waddr;           
reg     [15:0]          wdata;

reg                     rd_req;          
reg     [21:0]          raddr; 


reg     [8:0]           cnt_write;
wire                    add_cnt_write;
wire                    end_cnt_write;

reg                     flag_write;




always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        flag_write <= 1'b0;
    end
    else if(wr_ack == 1'b1)begin
        flag_write <= 1'b1;
    end
    else if(end_cnt_write)begin
        flag_write <= 1'b0;
    end
end

always @(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        cnt_write <= 0;
    end
    else if(add_cnt_write)begin
        if(end_cnt_write)
            cnt_write <= 0;
        else
            cnt_write <= cnt_write + 1'b1;
    end
end

assign add_cnt_write = (flag_write == 1'b1);       
assign end_cnt_write = add_cnt_write && cnt_write== (255 - 1);   

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        wr_req <= 1'b0;
    end
    else if(start) begin
        wr_req <= 1'b1;
    end
    else if(wr_ack == 1'b1)begin
        wr_req <= 1'b0;
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        waddr <= 1'b0;
    end
    else if(start)begin
        waddr <= {2'd1, 12'd5, 8'd0};
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        wdata <= 16'd0;
    end
    else if(start) begin
        wdata <= 16'd0;
    end
    else if(wr_ack || add_cnt_write)begin
        wdata <= wdata + 1'b1;
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        rd_req <= 1'b0;
    end
    else if(end_cnt_write)begin
        rd_req <= 1'b1;
    end
    else if(rd_ack)begin
        rd_req <= 1'b0;
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        raddr <= 22'd0;
    end
    else if(end_cnt_write)begin
        raddr <= {2'd1, 12'd5, 8'd0};
    end
end


endmodule
