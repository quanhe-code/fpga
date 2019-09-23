`timescale 1ns/1ns

module ds_intf_byte_tb();

localparam      clk_period = 40;

reg         clk       ;
reg         rst_n     ;
reg         rst_en    ;
reg         wr_en     ;
reg [7:0]   wdata     ;
reg         rd_en     ;
wire        rst_en_bit;
wire        wr_en_bit ;
wire        wdata_bit ;
wire        rd_en_bit ;
reg         rdata_bit ;      
reg         rdata_vld_bit;
reg         rdy_bit   ;      
wire [7:0]   rdata     ;
wire         rdata_vld ;
wire         rdy       ;

ds_intf_byte ds_intf_byte_inst_1(
         .clk       (clk),
         .rst_n     (rst_n),
         .rst_en    (rst_en),
         .wr_en     (wr_en),
         .wdata     (wdata),
         .rd_en     (rd_en),
         .rdata     (rdata),
         .rdata_vld (rdata_vld),
         .rdy       (rdy),         
         .rst_en_bit(rst_en_bit),
         .wr_en_bit (wr_en_bit),
         .wdata_bit (wdata_bit),
         .rd_en_bit (rd_en_bit),
         .rdata_bit (rdata_bit),      
         .rdata_vld_bit(rdata_vld_bit),
         .rdy_bit   (rdy_bit)      
);

initial begin
   clk = 1'b1;
   forever #(clk_period / 2) clk = ~clk; 
end

initial begin
    rst_n = 1'b0;
    rdy_bit = 1'b0;
    rst_en = 1'b0;

    wr_en = 1'b0;
    wdata = 8'h00;

    rd_en = 1'b0;
    rdata_vld_bit = 1'b0;

    rd_en = 1'b0;

    #(clk_period * 2)
    rst_n = 1'b1;

    #((clk_period * 5) - 10)
    rst_en = 1'b1;
    #(clk_period)
    rst_en = 1'b0;
    
    #(clk_period * 3)
    rdy_bit = 1'b1;
    

    #(clk_period * 5)
    wdata = 8'h75;
    wr_en = 1'b1;
    #(clk_period)
    wr_en = 1'b0;

    #(clk_period * 15)
    rd_en = 1'b1;
    #(clk_period)
    rd_en = 1'b0;
    
    #(clk_period * 5)
    rdata_bit = 1'b1;
    rdata_vld_bit = 1'b1;

    #(clk_period)
    rdata_bit = 1'b0;

    #(clk_period)
    rdata_bit = 1'b1;

    #(clk_period)
    rdata_bit = 1'b1;

    #(clk_period)
    rdata_bit = 1'b0;

    #(clk_period)
    rdata_bit = 1'b1;

    #(clk_period)
    rdata_bit = 1'b1;

    #(clk_period)
    rdata_bit = 1'b1;
    
    #(clk_period)
    rdata_vld_bit = 1'b0;
    #(clk_period * 20)
    $stop;

end
endmodule
