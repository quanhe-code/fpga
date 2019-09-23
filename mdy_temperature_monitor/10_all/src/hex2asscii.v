module hex2asscii(
               clk      ,
               rst_n    ,
               rdy      ,
               h2a_en   ,
               din      ,
               din_vld  ,
               dout     ,
               dout_vld  
           );

input              clk     ;
input              rst_n   ;
input              rdy     ;
input [7:0]        din     ;
input              h2a_en  ;
input              din_vld ;
output reg  [7:0]        dout    ;
output reg              dout_vld;

reg  [9:0]          data;
reg                 wrreq;
reg                 rdreq;
wire                rdempty;
wire [4:0]          q;

reg                 dout_vld_t;

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        data <= 10'd0;
    end
    else if(din_vld == 1'b1)begin
        data <= {h2a_en, din[3:0], h2a_en, din[7:4]};
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        wrreq <= 1'b0;
    end
    else if(din_vld == 1'b1)begin
        wrreq <= 1'b1;
    end
    else begin
        wrreq <= 1'b0;
    end
end

always  @(*)begin
    if(rdempty == 1'b0 && rdy == 1'b1)begin
        rdreq = 1'b1;
    end
    else begin
        rdreq = 1'b0;
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        dout <= 8'h00;
    end
    else if(rdreq == 1'b1)begin
        //  ¶ÁFIFOÊı¾İ
        if(q[4] == 1'b1) begin
            if(q[3:0] < 10) begin
                dout <= (8'h30 + q[3:0]);
            end
            else if(q[3:0] > 9 && q[3:0] < 16) begin
                dout <= (8'h41 + (q[3:0] - 8'd10));
            end
            else begin
                dout <= 8'h00;
            end
        end 
        else begin 
            dout <= {dout[3:0], q[3:0]};
        end
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        dout_vld_t <= 1'b0;
    end
    else if(rdreq == 1'b1 && q[4] == 0)begin
        dout_vld_t <= ~dout_vld_t;
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        dout_vld <= 1'b0;
    end
    else if(rdreq == 1'b1 && q[4] == 1)begin
        dout_vld <= 1'b1;
    end
    else if(rdreq == 1'b1 && q[4] == 1'b0 && dout_vld_t == 1'b1) begin
        dout_vld <= 1'b1;
    end
    else begin
        dout_vld <= 1'b0;
    end
end

 com_fifo com_fifo_inst1(
    .data(data),
    .rdclk(clk),
    .rdreq(rdreq),
    .wrclk(clk),
    .wrreq(wrreq),
    .q(q),
    .rdempty(rdempty)
);


endmodule 
