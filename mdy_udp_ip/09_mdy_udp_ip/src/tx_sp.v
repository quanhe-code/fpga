module tx_sp(
    clk              ,
    rst_n            ,
    arp              ,
    arp_vld          ,
    arp_sop          ,
    arp_eop          ,
    arp_rdy          ,
    arp_mod          ,  
    din              ,
    din_sop          ,
    din_eop          , 
    din_vld          ,
    din_rdy          ,
    din_mod          ,  
    tx_data          ,
    tx_sop           ,
    tx_eop           , 
    tx_vld           ,
    tx_rdy           ,
    tx_mod              
        
    );

    //`include "clogb2.v"

    input               clk           ;
    input               rst_n         ;

    input [15:0]        din           ;
    input               din_vld       ;
    input               din_sop       ;
    input               din_eop       ;
    input               din_mod       ;
    output              din_rdy       ;

    input [15:0]        arp           ;
    input               arp_vld       ;
    input               arp_sop       ;
    input               arp_eop       ;
    input               arp_mod       ;
    output              arp_rdy       ;
    output[31:0]        tx_data       ;
    output              tx_sop        ;
    output              tx_eop        ; 
    output              tx_vld        ;
    input               tx_rdy        ;
    output[1:0]         tx_mod        ;  
    
    reg   [31:0]        tx_data       ;
    reg                 tx_sop        ;
    reg                 tx_eop        ; 
    reg                 tx_vld        ;
    reg   [1:0]         tx_mod        ;  
    reg                 din_rdy       ;
    reg                 arp_rdy       ;

reg                     work_state;
reg                     work_sel;
reg     [1:0]           cnt_width;
wire                    add_cnt_width;
wire                    end_cnt_width;

wire    [18:0]          mac_fifo_data;
wire                    mac_fifo_rdreq;
wire                    mac_fifo_wrreq;
wire                    mac_fifo_empty;
wire                    mac_fifo_full;
wire    [18:0]          mac_fifo_q;

wire    [18:0]          arp_fifo_data;
wire                    arp_fifo_rdreq;
wire                    arp_fifo_wrreq;
wire                    arp_fifo_empty;
wire                    arp_fifo_full;
wire    [18:0]          arp_fifo_q;

tx_sp_mac_fifo tx_sp_mac_fifo_inst0(
	.clock(clk),
	.data(mac_fifo_data),
	.rdreq(mac_fifo_rdreq),
	.wrreq(mac_fifo_wrreq),
	.empty(mac_fifo_empty),
    .full(mac_fifo_full),
	.q(mac_fifo_q)
);

tx_sp_arp_fifo tx_sp_arp_fifo_inst0(
	.clock(clk),
	.data(arp_fifo_data),
	.rdreq(arp_fifo_rdreq),
	.wrreq(arp_fifo_wrreq),
	.empty(arp_fifo_empty),
    .full(arp_fifo_full),
	.q(arp_fifo_q)
);

assign mac_fifo_data = {din_sop, din_eop, din_mod, din};
assign mac_fifo_wrreq = din_vld;
assign mac_fifo_rdreq = (mac_fifo_empty  == 1'b0 && tx_rdy && work_state && work_sel == 1'b0);

assign arp_fifo_data = {arp_sop, arp_eop, arp_mod, arp};
assign arp_fifo_wrreq = arp_vld;
assign arp_fifo_rdreq = (arp_fifo_empty == 1'b0 && tx_rdy && work_state && work_sel == 1'b1);

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        work_state <= 1'b0;
    end
    else if(work_state == 1'b0 && (mac_fifo_empty == 1'b0 || arp_fifo_empty == 1'b0))begin
        work_state <= 1'b1;
    end
    else if(work_state == 1'b1 
            && ((mac_fifo_rdreq && mac_fifo_q[17]) || (arp_fifo_rdreq && arp_fifo_q[17])))begin
        work_state <= 1'b0;
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        work_sel <= 1'b0;
    end
    else if(work_state == 1'b0 && (mac_fifo_empty == 1'b0 || arp_fifo_empty == 1'b0))begin
        if(arp_fifo_empty == 1'b0)begin
            work_sel <= 1'b1;
        end
        else begin
            work_sel <= 1'b0;
        end
    end
end

/*
 * 计数器进行位宽转换
 */
always @(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        cnt_width <= 0;
    end
    else if(add_cnt_width)begin
        if(end_cnt_width)
            cnt_width <= 0;
        else
            cnt_width <= cnt_width + 1;
    end
end

assign add_cnt_width = (mac_fifo_rdreq || arp_fifo_rdreq);       
assign end_cnt_width = add_cnt_width && (cnt_width== (2 - 1) ||
    ((arp_fifo_rdreq && arp_fifo_q[17]) || (mac_fifo_rdreq && mac_fifo_q[17])));   

always  @(*)begin
    din_rdy = (mac_fifo_full == 1'b0);
    arp_rdy = (arp_fifo_full == 1'b0);
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        tx_data <= 32'd0;
    end
    else if(arp_fifo_rdreq)begin
        tx_data <= {tx_data[15:0], arp_fifo_q[15:0]};
    end
    else if(mac_fifo_rdreq)begin
        tx_data <= {tx_data[15:0], mac_fifo_q[15:0]};
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        tx_vld <= 1'b0;
    end
    else if(end_cnt_width)begin
        tx_vld <= 1'b1;
    end
    else begin
        tx_vld <= 1'b0;
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        tx_sop <= 1'b0;
    end
    else if((arp_fifo_rdreq && arp_fifo_q[18]) || (mac_fifo_rdreq && mac_fifo_q[18]))begin
        tx_sop <= 1'b1;
    end
    else if(tx_sop <= 1'b1 && tx_vld)begin
        tx_sop <= 1'b0;
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        tx_eop <= 1'b0;
    end
    else if((arp_fifo_rdreq && arp_fifo_q[17]) || (mac_fifo_rdreq && mac_fifo_q[17]))begin
        tx_eop <= 1'b1;
    end
    else begin
        tx_eop <= 1'b0;
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        tx_mod <= 2'd0;
    end
    else if(arp_fifo_rdreq && arp_fifo_q[17])begin
        tx_mod <= arp_mod + ((1 - cnt_width) * 2);
    end
    else if(mac_fifo_rdreq && mac_fifo_q[17])begin
        tx_mod <= din_mod + ((1 - cnt_width) * 2);
    end
    else begin
        tx_mod <= 2'd0;
    end
end

endmodule

