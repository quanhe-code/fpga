module top(
    clk         ,
    rst_n       ,
    
    key         ,

    sdram_clk   ,
    cke         ,
    cs_n        ,
    ras_n       ,
    cas_n       ,
    we_n        ,
 
    addr        ,
    bank        ,
    dq          
);

input                       clk;         
input                       rst_n;       
input                       key;
output                      sdram_clk;         
output                      cke;         
output                      cs_n;        
output                      ras_n;       
output                      cas_n;       
output                      we_n;        
output  [11:0]              addr;        
output  [1:0]               bank;        
inout   [15:0]              dq;          

wire                        clk0;
wire                        clk1;
wire                        locked;

wire                        wr_req;
wire    [21:0]              waddr;
wire    [15:0]              wdata;
wire                        wr_ack;

wire                        rd_req;
wire    [21:0]              raddr;
wire                        rd_ack;
wire                        key_down_int;

my_pll my_pll_inst0(
	.inclk0(clk),
	.c0(clk0),
	.c1(clk1),
	.locked(locked)
);

assign sdram_clk = clk0 & locked;

key key_inst0(
    .clk(clk1 & locked),
    .rst_n(rst_n),
    .key_sw(key),
    .key_down_int(key_down_int)
);
sdram_test sdram_test_inst0(
    .clk             (clk1 & locked),
    .rst_n           (rst_n),
    .start           (key_down_int),

    .wr_req          (wr_req),
    .waddr           (waddr),
    .wdata           (wdata),
    .wr_ack          (wr_ack),

    .rd_req          (rd_req),
    .raddr           (raddr),
    .rd_ack          (rd_ack)
);

mdy_sdram mdy_sdram_inst0(
    .clk             (clk1 & locked),
    .rst_n           (rst_n),

    .wr_req          (wr_req),
    .waddr           (waddr),
    .wdata           (wdata),
    .wr_ack          (wr_ack),

    .rd_req          (rd_req),
    .raddr           (raddr),
    .rd_ack          (rd_ack),
    .rdata           (),
    .rdata_vld       (),

    .cke             (cke),
    .cs_n            (cs_n),
    .ras_n           (ras_n),
    .cas_n           (cas_n),
    .we_n            (we_n),
    .dqm             (),
    .addr            (addr),
    .bank            (bank),
    .dq              (dq)
);
endmodule
