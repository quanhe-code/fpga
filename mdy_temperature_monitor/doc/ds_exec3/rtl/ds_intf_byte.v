module  ds_intf_byte(
         clk          ,
         rst_n        ,
         rst_en       ,
         wr_en        ,
         wdata        ,
         rd_en        ,
         rdata        ,
         rdata_vld    ,
         rdy          ,
         wr_en_bit    ,
         wdata_bit    ,
         rst_en_bit   ,
         rd_en_bit    ,
         rdata_bit    ,
         rdata_vld_bit,
         rdy_bit                         
        );

parameter  IDLE = 0 ;
parameter  RS_S = 1 ;
parameter  WR_S = 2 ;
parameter  RD_S = 3 ;

input         clk       ;
input         rst_n     ;
input         rst_en    ;
input         wr_en     ;
input [7:0]   wdata     ;
input         rd_en     ;

output[7:0]   rdata     ;
output        rdata_vld ;
output        rdy       ; 

output        rst_en_bit   ; 
output        wr_en_bit    ; 
output        wdata_bit    ; 
output        rd_en_bit    ; 
input         rdata_bit    ; 
input         rdata_vld_bit;
input         rdy_bit      ; 


reg   [7:0]   rdata     ;
reg           rdata_vld ;
reg           rdy       ; 

reg[ 3:0]     cnt       ;
wire          add_cnt   ;
wire          end_cnt   ;
reg[ 1:0]     state_c   ;
reg[ 1:0]     state_n   ;
wire          rst_finish;
wire          wr_finish ;
wire          rd_finish ;

reg           rst_en_bit   ; 
reg           wr_en_bit    ; 
reg           wdata_bit    ; 
reg           rd_en_bit    ; 

reg [7:0]     wdata_ff0    ;

wire          idle2rs_s_start ;
wire          idle2wr_s_start ;
wire          idle2rd_s_start ;
wire          rs_s2idle_start ;
wire          wr_s2idle_start ;
wire          rd_s2idle_start ;


always @(posedge clk or negedge rst_n) begin 
    if (rst_n==0) begin
        state_c <= IDLE ;
    end
    else begin
        state_c <= state_n;
   end
end

always @(*) begin 
    case(state_c)  
        IDLE :begin
            if(idle2rs_s_start) 
                state_n = RS_S ;
            else if(idle2wr_s_start) 
                state_n = WR_S ;
            else if(idle2rd_s_start) 
                state_n = RD_S ;
            else 
                state_n = state_c ;
        end
        RS_S :begin
            if(rs_s2idle_start) 
                state_n = IDLE ;
            else 
                state_n = state_c ;
        end
        WR_S :begin
            if(wr_s2idle_start) 
                state_n = IDLE ;
            else 
                state_n = state_c ;
        end
        RD_S :begin
            if(rd_s2idle_start) 
                state_n = IDLE ;
            else 
                state_n = state_c ;
        end
        default : state_n = IDLE ;
    endcase
end

assign idle2rs_s_start = state_c==IDLE && (rst_en==1 && rd_en==0 && wr_en==0);
assign idle2wr_s_start = state_c==IDLE && (rst_en==0 && rd_en==0 && wr_en==1);
assign idle2rd_s_start = state_c==IDLE && (rst_en==0 && rd_en==1 && wr_en==0);
assign rs_s2idle_start = state_c==RS_S && (rdy_bit==1                       );
assign wr_s2idle_start = state_c==WR_S && (end_cnt                          );
assign rd_s2idle_start = state_c==RD_S && (end_cnt                          );

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

assign add_cnt = (state_c==WR_S && rdy_bit) || (state_c==RD_S && rdata_vld_bit);       
assign end_cnt = add_cnt && cnt==8 - 1 ;


always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        rst_en_bit <= 1'b0;
    end
    else if(state_c==RS_S && rdy_bit) begin
        rst_en_bit <= 1'b1;
    end
    else begin
        rst_en_bit <= 1'b0;
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        wr_en_bit <= 1'b0;
    end
    else if(state_c==WR_S && add_cnt) begin
        wr_en_bit <= 1'b1;
    end
    else begin
        wr_en_bit <= 1'b0;
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        wdata_ff0 <= 0;
    end
    else if(idle2wr_s_start)begin
        wdata_ff0 <= wdata;
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        wdata_bit <= 1'b0;
    end
    else if(state_c==WR_S && add_cnt) begin
        wdata_bit <= wdata_ff0[cnt];
    end
end


always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        rd_en_bit <= 1'b0;
    end
    else if(state_c==RD_S && rdy_bit) begin
        rd_en_bit <= 1'b1;
    end
    else begin
        rd_en_bit <= 1'b0;
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        rdata <= 0;
    end
    else if(state_c==RD_S && add_cnt) begin
        rdata[cnt] <= rdata_bit;
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        rdata_vld <= 1'b0;
    end
    else begin
        rdata_vld <= rd_s2idle_start;
    end
end


always  @(*)begin
    if(rst_en || wr_en || rd_en)
        rdy = 1'b0;
    else if(state_c!=IDLE)
        rdy = 1'b0;
    else
        rdy = 1'b1;
end

endmodule
