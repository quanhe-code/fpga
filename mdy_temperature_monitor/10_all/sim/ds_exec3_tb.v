`timescale 1ns/1ns

module ds_exec3_tb();

localparam      clk_period = 20;
localparam      BPS = 52;
defparam        ds_exec3_tb.ds_intf_bit_inst0.CNT_1000US = 25;
defparam        ds_exec3_tb.ds_intf_bit_inst0.CNT_750US = 18;
defparam        ds_exec3_tb.ds_intf_bit_inst0.CNT_15US = 3;
defparam        ds_exec3_tb.ds_intf_bit_inst0.CNT_60US = 12;
defparam        ds_exec3_tb.ds_intf_bit_inst0.CNT_62US = 15;
defparam        ds_exec3_tb.ds_intf_bit_inst0.CNT_1US  = 2;
defparam        ds_exec3_tb.ds_intf_bit_inst0.CNT_14US = 4;

defparam        ds_exec3_tb.seg_disp_inst0.SECOND_CNT = 100;


reg              rst_n  ;
reg              clk    ;
reg              rx_uart;
wire             tx_uart;
wire             dq     ;

wire [2:0]        seg_sel;
wire [7:0]        segment;
wire                beep   ;
reg [31:0]                command;


ds_exec3 #(BPS) ds_exec3_tb(
                .rst_n  (rst_n),
                .clk    (clk),
                .rx_uart(rx_uart),
                .tx_uart(tx_uart),
                .dq     (dq),
                .seg_sel(seg_sel),
                .segment(segment),
                .beep   (beep) 
);

initial begin
    clk = 1'b1;
    forever #(clk_period / 2) clk = ~clk;
end

initial begin
    rst_n = 1'b0;
    rx_uart = 1'b1;

    #(10);
    #(clk_period * 5);
    rst_n = 1'b1;

    #(clk_period * 5);
    command[7:0] = "0";
    command[15:8] = "1";
    command[23:16] = "0";
    command[31:24] = "1";
    uart_send_command(command);

    #(clk_period * 5);
    command[7:0] = "8";
    command[15:8] = "0";
    command[23:16] = "0";
    command[31:24] = "0";
    uart_send_command(command);

    command[7:0] = "8";
    command[15:8] = "1";
    command[23:16] = "c";
    command[31:24] = "c";
    uart_send_command(command);

     command[7:0] = "0";
    command[15:8] = "d";
    command[23:16] = "0";
    command[31:24] = "0";
    uart_send_command(command);

    #(clk_period * 100000);
    $stop;
end

task uart_send_byte;
input       [7:0] data;
reg         [9:0] tmp;
integer           i;

begin
    tmp = {1'b1, data[7:0], 1'b0};

    for(i = 0; i < 10; i = i + 1) begin
        rx_uart = tmp[i];
        #(BPS * clk_period);
    end
end
endtask

task uart_send_command;
input [31:0] command;

begin
uart_send_byte("5");
uart_send_byte("5");
uart_send_byte("d");
uart_send_byte("5");
uart_send_byte(command[7:0]);
uart_send_byte(command[15:8]);
uart_send_byte(command[23:16]);
uart_send_byte(command[31:24]);
end

endtask
endmodule
