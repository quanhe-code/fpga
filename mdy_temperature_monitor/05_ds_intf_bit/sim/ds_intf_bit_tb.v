`timescale 1ns/1ns

module ds_intf_bit_tb();

localparam      clk_period = 40;

    reg               clk       ;
    reg               rst_n     ;
    reg               rst_en    ;
    reg               wr_en     ;
    reg               wdata     ;
    reg               rd_en     ;
    reg               dq_in     ;

    wire              rdata     ;
    wire              rdata_vld ;
    wire              dq_out    ;
    wire              dq_out_en ;
    wire              rdy       ;

    defparam        ds_intf_bit_inst1.CNT_1000US = 25;
    defparam        ds_intf_bit_inst1.CNT_750US = 18;
    defparam        ds_intf_bit_inst1.CNT_15US = 3;
    defparam        ds_intf_bit_inst1.CNT_60US = 12;
    defparam        ds_intf_bit_inst1.CNT_62US = 15;
    defparam        ds_intf_bit_inst1.CNT_1US  = 2;
    defparam        ds_intf_bit_inst1.CNT_14US = 4;

ds_intf_bit ds_intf_bit_inst1(
    .clk      (clk),
    .rst_n    (rst_n),
    .rst_en   (rst_en),
    .wr_en    (wr_en),
    .wdata    (wdata),
    .rd_en    (rd_en),
    .rdata    (rdata),
    .rdata_vld(rdata_vld),
    .dq_out   (dq_out),
    .dq_out_en(dq_out_en),
    .dq_in    (dq_in), 
    .rdy      (rdy) 
    );

    initial begin
        clk = 1'b1;
        forever #(clk_period / 2) clk = ~clk;
    end

    initial begin
        rst_n = 1'b0;
        rst_en = 1'b0;
        wr_en = 1'b0;
        wdata = 1'b0;

        rd_en = 1'b0;
        dq_in = 1'b1;

        #(clk_period * 3)
        rst_n = 1'b1;


        #((clk_period * 5) - 10)
        rst_en = 1'b1;
        #(clk_period)
        rst_en = 1'b0;

        #(clk_period * 100)

        #(clk_period)
        wdata = 1'b1;
        wr_en = 1'b1;
        #(clk_period)
        wr_en = 1'b0;

        #(clk_period * 100)

        #(clk_period)
        dq_in = 1'b1;
        rd_en = 1'b1;
        #(clk_period)
        rd_en = 1'b0;
        
        #(clk_period * 100)

        $stop;

    end

endmodule
