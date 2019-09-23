`timescale 1ns/1ns

module sdram_test();

reg                       clk;
reg                       rst_n;           
reg                       wr_req;          
reg     [21:0]            waddr;           
reg     [15:0]            wdata;           
wire                      wr_ack;          
reg                       rd_req;         
reg   [21:0]              raddr;         
wire                      rd_ack;          
wire  [15:0]              rdata;           
wire                      rdata_vld;
wire                      cke;             
wire                      cs_n;            
wire                      ras_n;           
wire                      cas_n;           
wire                      we_n;            
wire                      dqm;             
wire  [11:0]              addr;            
wire  [1:0]               bank;            
wire  [15:0]              dq;

mdy_sdram mdy_sdram_inst0(
    .clk             (clk),
    .rst_n           (rst_n),
    .wr_req          (wr_req),
    .waddr           (waddr),
    .wdata           (wdata),
    .wr_ack          (wr_ack),
    .rd_req          (rd_req),
    .raddr          (raddr),
    .rd_ack          (rd_ack),
    .rdata           (rdata),
    .rdata_vld       (rdata_vld),
    .cke             (cke),
    .cs_n            (cs_n),
    .ras_n           (ras_n),
    .cas_n           (cas_n),
    .we_n            (we_n),
    .dqm             (dqm),
    .addr            (addr),
    .bank            (bank),
    .dq              (dq)
);

defparam   mdy_sdram_inst0.SDRAM_TIMING_STABLE     = 16'd200;
defparam   mdy_sdram_inst0.SDRAM_TIMING_TRP        = 16'd200;
defparam   mdy_sdram_inst0.SDRAM_TIMING_TRC        = 16'd1;
defparam   mdy_sdram_inst0.SDRAM_TIMING_TMRD       = 16'd200;
defparam   mdy_sdram_inst0.SDRAM_REFRESH_PERIOD    = 16'd60;

parameter   clk_period = 10;

initial begin
    clk = 1'b1;
    forever #(clk_period / 2) clk = ~clk;
end

initial begin
    rst_n = 1'b0;
    wr_req = 1'b0;
    waddr = 22'd0;
    wdata = 16'd0;

    rd_req = 1'b0;
    raddr = 22'd0;
    
    #(5);
    #(5*clk_period);
    rst_n = 1'b1;

    #(2000*clk_period);
    wr_req = 1'b1;
    #(clk_period);
    wr_req = 1'b0;

    #(2000*clk_period);
    raddr = 22'h155555;
    rd_req = 1'b1;
    #(clk_period);
    rd_req = 1'b0;
end

endmodule
