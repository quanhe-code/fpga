module ds_exec3(
                rst_n  ,
                clk    ,
                rx_uart,
                tx_uart,
                dq     ,
                seg_sel,
                segment,
                led_err,
                beep    
);
parameter    	   BPS	  =	5208;

input               rst_n  ;
input               clk    ;
input               rx_uart;
output              tx_uart;
inout               dq     ;
output[ 7:0]        seg_sel;
output[ 7:0]        segment;
output              beep   ;
output              led_err;


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

wire                dq_out         ; 
wire                dq_out_en      ; 
wire                dq_in          ; 
wire                intf_rdy       ; 

wire                bit_wr_en      ; 
wire                bit_wdata      ; 
wire                bit_rst_en     ; 
wire                bit_rd_en      ; 
wire                bit_rdata      ; 
wire                bit_rdata_vld  ;
wire                bit_rdy        ;


wire[3:0]           a2h_dout    ;
wire                a2h_dout_vld;
wire[7:0]           op_det_dout    ;
wire                op_det_dout_vld;
wire[7:0]           ctrl_uart_out;
wire                ctrl_uart_out_vld;
wire                ctrl_h2a_en      ;

assign  dq    = (dq_out_en)?dq_out:1'bz;
assign  dq_in = dq;

//串口接收模块
uart_rx#(.BPS(BPS))  uart_rx(
                 .clk     (clk        ),
                 .rst_n   (rst_n      ),
                 .din     (rx_uart    ),
                 .dout    (uart_in    ),
                 .dout_vld(uart_in_vld)
             );
//串口发送模块             
uart_tx#(.BPS(BPS))  uart_tx(
                 .clk     (clk         ),
                 .rst_n   (rst_n       ),
                 .din     (uart_out    ),
                 .din_vld (uart_out_vld),
                 .rdy     (uart_tx_rdy ),
                 .dout    (tx_uart     )
             );
asscii2hex u_a2h(
               .clk      (clk        ),
               .rst_n    (rst_n      ),
               .din      (uart_in    ),
               .din_vld  (uart_in_vld),
               .dout     (a2h_dout   ),
               .dout_vld (a2h_dout_vld) 
 );

opcode_detect u_op_det(
               .clk      (clk            ),
               .rst_n    (rst_n          ),
               .din      (a2h_dout       ),
               .din_vld  (a2h_dout_vld   ),
               .dout     (op_det_dout    ),
               .dout_vld (op_det_dout_vld)  
    );


//控制模块
control    ctrl(
             .clk            (clk            ),
             .rst_n          (rst_n          ),
             .uart_in        (op_det_dout    ),
             .uart_in_vld    (op_det_dout_vld),
             .uart_out       (ctrl_uart_out       ),
             .uart_out_vld   (ctrl_uart_out_vld   ),
             .h2a_en         (ctrl_h2a_en    ),
             .intf_rst_en    (intf_rst_en    ),
             .intf_wr_en     (intf_wr_en     ),
             .intf_wdata     (intf_wdata     ),
             .intf_rd_en     (intf_rd_en     ),
             .intf_rdata     (intf_rdata     ),
             .intf_rdata_vld (intf_rdata_vld ),
             .intf_rdy       (intf_rdy       ),
             .beep           (beep           ),
             .temp_uns       (temp_uns       ),
             .temp_valid_en  (temp_valid_en  ),
             .led_err        (led_err        )   
);
hex2asscii u_h2a(
               .clk      (clk                ),
               .rst_n    (rst_n              ),
               .rdy      (uart_tx_rdy        ),
               .h2a_en   (ctrl_h2a_en        ),
               .din      (ctrl_uart_out      ),
               .din_vld  (ctrl_uart_out_vld  ),
               .dout     (uart_out           ),
               .dout_vld (uart_out_vld       ) 
           );

ds_intf_byte u_ds_intf_byte(
                   .clk          (clk            ),
                   .rst_n        (rst_n          ),
                   .rst_en       (intf_rst_en    ),
                   .wr_en        (intf_wr_en     ),
                   .wdata        (intf_wdata     ),
                   .rd_en        (intf_rd_en     ),
                   .rdata        (intf_rdata     ),
                   .rdata_vld    (intf_rdata_vld ),
                   .rdy          (intf_rdy       ),
                   .wr_en_bit    (bit_wr_en      ),
                   .wdata_bit    (bit_wdata      ),
                   .rst_en_bit   (bit_rst_en     ),
                   .rd_en_bit    (bit_rd_en      ),
                   .rdata_bit    (bit_rdata      ),
                   .rdata_vld_bit(bit_rdata_vld  ),
                   .rdy_bit      (bit_rdy        )                   
        );

ds_intf_bit u_ds_intf_bit(
                   .clk          (clk            ),
                   .rst_n        (rst_n          ),
                   .rst_en       (bit_rst_en     ),
                   .wr_en        (bit_wr_en      ),
                   .wdata        (bit_wdata      ),
                   .rd_en        (bit_rd_en      ),
                   .rdata        (bit_rdata      ),
                   .rdata_vld    (bit_rdata_vld  ),
                   .dq_out       (dq_out         ),
                   .dq_out_en    (dq_out_en      ),
                   .dq_in        (dq_in          ), 
                   .rdy          (bit_rdy        ) 
    );
        
//数码管显示模块
seg_disp u_seg_disp(
                 .rst_n       (rst_n      ),
                 .clk         (clk        ),
                 .disp_en     (temp_valid_en),
                 .din         (temp_uns     ),
                 .din_vld     (8'hff        ),
                 .seg_sel     (seg_sel      ),
                 .segment     (segment      ) 
             );
         
endmodule         
