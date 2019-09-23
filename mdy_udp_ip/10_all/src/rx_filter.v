module rx_filter(
    clk              ,
    rst_n            ,
    din              ,
    din_sop          ,
    din_eop          , 
    din_vld          ,
    din_mod          ,  
    din_err          ,  
    dout             ,
    dout_sop         ,
    dout_eop         , 
    dout_vld         ,
    dout_mod              
        
    );

    //`include "clogb2.v"
    
    input               clk           ;
    input               rst_n         ;

    input [31:0]        din           ;
    input               din_vld       ;
    input               din_sop       ;
    input               din_eop       ;
    input               din_err       ;
    input [ 1:0]        din_mod       ;

    output[15:0]        dout          ;
    output              dout_sop      ;
    output              dout_eop      ; 
    output              dout_vld      ;
    output              dout_mod      ;  
    
    reg   [15:0]        dout          ;
    reg                 dout_sop      ;
    reg                 dout_eop      ; 
    reg                 dout_vld      ;
    reg                 dout_mod      ;

reg     [1:0]           cnt_read;
wire                    add_cnt_read;
wire                    end_cnt_read;

reg     [1:0]            x;

wire    [35:0]          udp_dfifo_data;
wire                    udp_dfifo_rdreq;
wire                    udp_dfifo_wrreq;
wire                    udp_dfifo_empty;
wire    [35:0]          udp_dfifo_q;

wire                    udp_mfifo_data;
wire                    udp_mfifo_rdreq;
wire                    udp_mfifo_wrreq;
wire                    udp_mfifo_empty;
wire                    udp_mfifo_q;

rx_filter_dfifo rx_filter_dfifo_inst0(
	.clock(clk),
	.data(udp_dfifo_data),
	.rdreq(udp_dfifo_rdreq),
	.wrreq(udp_dfifo_wrreq),
	.empty(udp_dfifo_empty),
	.q(udp_dfifo_q)
);

rx_filter_mfifo rx_filter_mfifo_inst0(
	.clock(clk),
	.data(udp_mfifo_data),
	.rdreq(udp_mfifo_rdreq),
	.wrreq(udp_mfifo_wrreq),
	.empty(udp_mfifo_empty),
	.q(udp_mfifo_q)
);

assign udp_dfifo_data = {din_mod, din_eop, din_sop, din};
assign udp_dfifo_wrreq = din_vld;
assign udp_dfifo_rdreq = end_cnt_read;

assign udp_mfifo_data = din_err;
assign udp_mfifo_wrreq = din_vld && din_eop;
assign udp_mfifo_rdreq = end_cnt_read && udp_dfifo_q[33] == 1'b1;

always @(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        cnt_read <= 0;
    end
    else if(add_cnt_read)begin
        if(end_cnt_read)
            cnt_read <= 0;
        else
            cnt_read <= cnt_read + 1'b1;
    end
end

assign add_cnt_read = (udp_mfifo_empty == 1'b0 && udp_dfifo_empty == 1'b0);       
assign end_cnt_read = add_cnt_read && (cnt_read==(x - 1) );   

always  @(*)begin
    if(udp_dfifo_q[33] == 1'b1) begin
        if(udp_dfifo_q[35] == 1'b0) begin
            x = 2;
        end
        else begin
            x = 1;
        end
    end
    else begin
        x = 2;
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        dout <= 16'd0;
    end
    else if(add_cnt_read)begin
        dout <= udp_dfifo_q[((1 - cnt_read) * 16) +: 16]; 
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        dout_vld <= 1'b0;
    end
    else if(udp_mfifo_q == 1'b1)begin
        dout_vld <= 1'b0;
    end
    else if(add_cnt_read)begin
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
    else if(add_cnt_read && udp_dfifo_q[32] && cnt_read == (1 - 1))begin
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
    else if(end_cnt_read && udp_dfifo_q[33])begin
        dout_eop <= 1'b1;
    end
    else begin
        dout_eop <= 1'b0;
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        dout_mod <= 1'b0;
    end
    else if(end_cnt_read && udp_dfifo_q[33] && udp_dfifo_q[34] == 1'b1)begin
        dout_mod <= 1'b1;
    end
    else begin
        dout_mod <= 1'b0;
    end
end

endmodule

