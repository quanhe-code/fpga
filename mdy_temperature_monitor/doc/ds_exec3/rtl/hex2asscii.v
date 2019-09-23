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
output[7:0]        dout    ;
output             dout_vld;
reg   [7:0]        dout    ;
reg                dout_vld;
reg                rdreq   ;
wire               wrreq   ;
wire               empty   ;
wire               f_h2a_en;
wire[3:0]          f_din   ;
reg [1:0]          cnt     ;
wire               add_cnt ;
wire               end_cnt ;

com_fifo u_com_fifo (
	         .data   ({h2a_en,din[3:0],h2a_en,din[7:4]}),
	         .rdclk  (clk         ),
	         .rdreq  (rdreq       ),
	         .wrclk  (clk         ),
	         .wrreq  (wrreq       ),
	         .rdempty(empty       ),
	         .q      ({f_h2a_en,f_din})  
           );

assign  wrreq  = din_vld;

always  @(*)begin
    if(rdy && empty==1'b0)
        rdreq = 1'b1;
    else
        rdreq = 1'b0;
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        dout <= 0;
    end
    else if(rdreq) begin
        if(f_h2a_en)begin
            if(f_din<4'ha)
                dout <= f_din + 48;
            else
                dout <= f_din + 55;
        end
        else begin
            dout <= {dout[3:0],f_din};
        end
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

assign add_cnt = rdreq && f_h2a_en==0;       
assign end_cnt = add_cnt && cnt==2-1 ;   


always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        dout_vld <= 1'b0;
    end
    else if(rdreq && f_h2a_en) begin
        dout_vld <= 1'b1;
    end
    else if(end_cnt)begin
        dout_vld <= 1'b1;
    end
    else begin
        dout_vld <= 1'b0;
    end
end

endmodule 
