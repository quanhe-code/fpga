module ds_exec3(
                rst_n  ,
                clk    ,
                rx_uart,
                tx_uart,
                dq     ,
                seg_sel,
                segment,
                beep    
);
parameter    	   BPS	  =	5208;

input               rst_n  ;
input               clk    ;
input               rx_uart;
output              tx_uart;
inout wire          dq     ;
output              beep   ;
output [2:0]        seg_sel;
output [7:0]        segment;

wire  [7:0]         uart_in   ;
wire                uart_in_vld;
wire  [7:0]         uart_out    ;
wire                uart_out_vld;
wire                uart_tx_rdy ;

wire  [7:0]         intf_rdata     ;
wire                intf_rdata_vld ;
wire                intf_rst_en    ;
wire                intf_wr_en     ;
wire  [7:0]         intf_wdata     ;
wire                intf_rd_en     ;
wire  [31:0]        temp_uns       ;
wire                temp_valid_en  ;

wire                intf_dq_out    ; 
wire                intf_dq_out_en ; 
wire                intf_dq_in     ; 
wire                intf_rdy       ; 
wire[3:0]           a2h_dout    ;
wire                a2h_dout_vld;
wire[7:0]           op_det_dout    ;
wire                op_det_dout_vld;
wire[7:0]           ctrl_uart_out;
wire                ctrl_uart_out_vld;
wire                ctrl_h2a_en      ;
wire                rst_en_bit;
wire                wr_en_bit;
wire                wdata_bit;
wire                rd_en_bit;
wire                rdata_bit;
wire                rdata_vld_bit;
wire                rdy_bit;

uart_rx #(BPS) uart_rx_inst0(
                 .clk(clk),
                 .rst_n(rst_n),
                 .din(rx_uart),
                 .dout(uart_out),
                 .dout_vld(uart_out_vld)
);

asscii2hex asscii2hex_inst0(
               .clk      (clk),
               .rst_n    (rst_n),
               .din      (uart_out),
               .din_vld  (uart_out_vld),
               .dout     (a2h_dout),
               .dout_vld (a2h_dout_vld) 
 );

opcode_detect opcode_detect_inst0(
               .clk      (clk),
               .rst_n    (rst_n),
               .din      (a2h_dout),
               .din_vld  (a2h_dout_vld),
               .dout     (op_det_dout),
               .dout_vld (op_det_dout_vld)  
);

control control_inst0(
               .clk            (clk),
               .rst_n          (rst_n),
               .uart_in        (op_det_dout),
               .uart_in_vld    (op_det_dout_vld),
               .uart_out       (ctrl_uart_out),
               .uart_out_vld   (ctrl_uart_out_vld),
               .h2a_en         (ctrl_h2a_en),
               .intf_rst_en    (intf_rst_en),
               .intf_wr_en     (intf_wr_en),
               .intf_wdata     (intf_wdata),
               .intf_rd_en     (intf_rd_en),
               .intf_rdata     (intf_rdata),
               .intf_rdata_vld (intf_rdata_vld),
               .intf_rdy       (intf_rdy),
               .beep           (beep),
               .temp_uns       (temp_uns),
               .temp_valid_en  (temp_valid_en)       
);

// 开始驱动ds18b20
ds_intf_byte ds_intf_byte_inst0(
               .clk       (clk),
               .rst_n     (rst_n),
               .rst_en    (intf_rst_en),
               .wr_en     (intf_wr_en),
               .wdata     (intf_wdata),
               .rd_en     (intf_rd_en),
               .rdata     (intf_rdata),
               .rdata_vld (intf_rdata_vld),
               .rdy       (intf_rdy),         
               .rst_en_bit(rst_en_bit),
               .wr_en_bit (wr_en_bit),
               .wdata_bit (wdata_bit),
               .rd_en_bit (rd_en_bit),
               .rdata_bit (rdata_bit),      
               .rdata_vld_bit(rdata_vld_bit),
               .rdy_bit   (rdy_bit)     
);

ds_intf_bit ds_intf_bit_inst0(
               .clk      (clk),
               .rst_n    (rst_n),
               .rst_en   (rst_en_bit),
               .wr_en    (wr_en_bit),
               .wdata    (wdata_bit),
               .rd_en    (rd_en_bit),
               .rdata    (rdata_bit),
               .rdata_vld(rdata_vld_bit),
               .dq_out   (intf_dq_out),
               .dq_out_en(intf_dq_out_en),
               .dq_in    (intf_dq_in), 
               .rdy      (rdy_bit) 
);

//三态门   可参考《三态门.exe》
assign  dq         = (intf_dq_out_en)?intf_dq_out:1'bz;
assign  intf_dq_in = dq;

// smg
seg_disp seg_disp_inst0(
                 .rst_n       (rst_n),
                 .clk         (clk),
                 .disp_en     (temp_valid_en),
                 .din         (temp_uns[23:0]),
                 .din_vld     (8'hff),
                 .seg_sel     (seg_sel),
                 .segment     (segment)
);

// 控制模块到串口模块
hex2asscii hex2asscii_inst0(
               .clk      (clk),
               .rst_n    (rst_n),
               .rdy      (uart_tx_rdy),
               .h2a_en   (ctrl_h2a_en),
               .din      (ctrl_uart_out),
               .din_vld  (ctrl_uart_out_vld),
               .dout     (uart_in),
               .dout_vld (uart_in_vld) 
);

uart_tx #(BPS) uart_tx_inst0(
                 .clk(clk),
                 .rst_n(rst_n),
                 .din(uart_in),
                 .din_vld(uart_in_vld),
                 .rdy(uart_tx_rdy),
                 .dout(tx_uart)
);

endmodule         
