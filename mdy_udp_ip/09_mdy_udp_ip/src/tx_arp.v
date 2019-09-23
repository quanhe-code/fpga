module tx_arp(
    clk           ,
    rst_n         ,

    ack_en        ,
    ack_mac_d     ,

    cfg_mac_s     ,
    cfg_sip       ,
    cfg_dip       ,

    tx_arp_data   ,
    tx_arp_vld    ,
    tx_arp_sop    ,
    tx_arp_eop    ,
    tx_arp_rdy    ,
    tx_arp_mty    
    );

  
  parameter     SECOND_CNT    = 100000000;
  parameter     DATA_W        = 16      ;
  parameter     MAC_ADDR_W    = 48      ;
  parameter     IP_ADDR_W     = 32      ;
  
  input                    clk      ;
  input                    rst_n    ;

  input  [MAC_ADDR_W-1:0]  cfg_mac_s;
  input  [MAC_ADDR_W-1:0]  ack_mac_d;
  input  [IP_ADDR_W-1:0]   cfg_sip  ;
  input  [IP_ADDR_W-1:0]   cfg_dip  ;
  input                    ack_en   ;
  
  output [DATA_W-1:0]      tx_arp_data;
  output                   tx_arp_vld ;
  output                   tx_arp_sop ;
  output                   tx_arp_eop ;
  input                    tx_arp_rdy ;
  output                   tx_arp_mty ;

  reg    [DATA_W-1:0]      tx_arp_data;
  reg                      tx_arp_vld ;
  reg                      tx_arp_sop ;
  reg                      tx_arp_eop ;
  reg                      tx_arp_mty;


reg     [31:0]          cnt_sec;
wire                    add_cnt_sec;
wire                    end_cnt_sec;

reg     [47:0]          arp_mac_d;
reg     [15:0]          arp_op;

reg     [4:0]           cnt_out;
wire                    add_cnt_out;
wire                    end_cnt_out;

reg     [1:0]           state_flag;

wire    [(42*8-1):0]    arp_pack;

always @(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        cnt_sec <= 0;
    end
    else if(add_cnt_sec)begin
        if(end_cnt_sec)
            cnt_sec <= 0;
        else
            cnt_sec <= cnt_sec + 1;
    end
end

assign add_cnt_sec = (rst_n == 1'b1);       
assign end_cnt_sec = add_cnt_sec && cnt_sec== (SECOND_CNT - 1);    

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        state_flag <= 2'd0;
    end
    else if(state_flag == 2'd0 && end_cnt_sec == 1'b1 && ack_en == 1'b0)begin
        state_flag <= 2'd1;
    end
    else if(state_flag == 2'd0 && end_cnt_sec == 1'b0 && ack_en == 1'b1)begin
        state_flag <= 2'd2;
    end
    else if(state_flag == 2'd0 && end_cnt_sec == 1'b1 && ack_en == 1'b1) begin
        state_flag <= 2'd3;
    end
    else if(state_flag != 2'd0 && end_cnt_out) begin
        state_flag <= 2'd0;
    end
end


assign arp_pack = {
    arp_mac_d, cfg_mac_s, 16'h0806, 
    16'h0001, 16'h0800, 8'h06, 8'h04,arp_op, cfg_mac_s, cfg_sip, arp_mac_d, cfg_dip
};

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        tx_arp_data <= 16'd0;
    end
    else if(add_cnt_out)begin
        tx_arp_data <= arp_pack[((20 - cnt_out)*16) +: 16];
    end
end

always  @(*)begin
    if(state_flag == 2'd2 || state_flag == 2'd3) begin
        // 发送应答包文
        arp_mac_d <= ack_mac_d;
        arp_op <= 16'd2;
    end
    else begin
        // 发送请求包文
        arp_mac_d <= 48'hFFFFFFFFFFFF;
        arp_op <= 16'd1;
    end
end

always @(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        cnt_out <= 0;
    end
    else if(add_cnt_out)begin
        if(end_cnt_out)
            cnt_out <= 0;
        else
            cnt_out <= cnt_out + 1;
    end
end

assign add_cnt_out = (state_flag != 2'd0 && tx_arp_rdy == 1'b1);       
assign end_cnt_out = add_cnt_out && cnt_out== (21 - 1);   

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        tx_arp_vld <= 1'b0;
    end
    else if(add_cnt_out)begin
        tx_arp_vld <= 1'b1;
    end
    else begin
        tx_arp_vld <= 1'b0;
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        tx_arp_sop <= 1'b0;
    end
    else if(add_cnt_out && cnt_out == (1 - 1))begin
        tx_arp_sop <= 1'b1;
    end
    else begin
        tx_arp_sop <= 1'b0;
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        tx_arp_eop <= 1'b0;
    end
    else if(end_cnt_out)begin
        tx_arp_eop <= 1'b1;
    end
    else begin
        tx_arp_eop <= 1'b0;
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        tx_arp_mty <= 1'b0;
    end
end

endmodule

