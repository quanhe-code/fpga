`timescale 1ns/1ns

module control_tb();

reg               clk            ;
reg               rst_n          ;
reg [7:0]         uart_in        ;
reg               uart_in_vld    ;
reg [7:0]         intf_rdata     ;
reg               intf_rdata_vld ;
reg               intf_rdy       ;

wire [7:0]         uart_out       ;
wire               uart_out_vld   ;
wire               h2a_en         ;
wire               intf_rst_en    ;
wire               intf_wr_en     ;
wire [7:0]         intf_wdata     ;
wire               intf_rd_en     ;
wire               beep           ;
wire [31:0]        temp_uns       ;
wire               temp_valid_en  ;

localparam         clk_period = 40;
    
control control_inst_1(
   .clk           (clk) ,
   .rst_n         (rst_n) ,
   .uart_in       (uart_in) ,
   .uart_in_vld   (uart_in_vld) ,
   .uart_out      (uart_out) ,
   .uart_out_vld  (uart_out_vld) ,
   .h2a_en        (h2a_en) ,
   .intf_rst_en   (intf_rst_en) ,
   .intf_wr_en    (intf_wr_en) ,
   .intf_wdata    (intf_wdata) ,
   .intf_rd_en    (intf_rd_en) ,
   .intf_rdata    (intf_rdata) ,
   .intf_rdata_vld(intf_rdata_vld) ,
   .intf_rdy      (intf_rdy) ,
   .beep          (beep) ,
   .temp_uns      (temp_uns) ,
   .temp_valid_en (temp_valid_en)        
);

initial begin
    clk = 1'b1;
    forever #(clk_period / 2) clk = ~clk; 
end

initial begin
    rst_n = 1'b0;
    uart_in = 8'h00;
    uart_in_vld = 1'b0;
    intf_rdy = 1'b0;
    intf_rdata = 8'hA5;
    intf_rdata_vld = 1'b1;

    #(clk_period * 3)
    rst_n = 1'b1;
   
    uart_input(8'h80, 8'h00); 

    #(clk_period * 5)
    intf_rdy = 1'b1;

    uart_input(8'h81, 8'h55);

    uart_input(8'h82, 8'h00);
    uart_input(8'h83, 8'h00);
    uart_input(8'h84, 8'h00);

    uart_input(8'h01, 8'h01);
    uart_input(8'h01, 8'h00);

    uart_input(8'h02, 8'h11);
    uart_input(8'h03, 8'h22);

    uart_input(8'h04, 8'h00);

    uart_input(8'h05, 8'h01);
    //uart_input(8'h05, 8'h00);

    uart_input(8'h06, 8'h00);
    uart_input(8'h07, 8'h00);
    uart_input(8'h08, 8'h00);
    uart_input(8'h09, 8'h00);

    uart_input(8'h0a, 8'h00);
    uart_input(8'h0b, 8'h00);
    uart_input(8'h0c, 8'h00);

    uart_input(8'h0d, 8'h00);

    #(clk_period * 10);

    $stop;
end

task uart_input;
    input    [7:0] code;
    input    [7:0] value;

    begin
        #(clk_period * 3) 
        uart_in = code;
        uart_in_vld = 1'b1;
        #(clk_period) 
        uart_in = value;
        #(clk_period) 
        uart_in_vld = 1'b0;
    end
endtask
endmodule

