module control(
    clk            ,
    rst_n          ,
    uart_in        ,
    uart_in_vld    ,
    uart_out       ,
    uart_out_vld   ,
    h2a_en         ,
    intf_rst_en    ,
    intf_wr_en     ,
    intf_wdata     ,
    intf_rd_en     ,
    intf_rdata     ,
    intf_rdata_vld ,
    intf_rdy       ,
    beep           ,
    temp_uns       ,
    temp_valid_en  ,
    led_err           
    );

    parameter   OP_TEMP_VALID     = 8'h01 ; 
    parameter   OP_TEMP_CMP_L     = 8'h02 ; 
    parameter   OP_TEMP_CMP_H     = 8'h03 ; 
    parameter   OP_TEMP_CHANGE_EN = 8'h04 ; 
    parameter   OP_BEEP_EN        = 8'h05 ; 
    parameter   OP_RD_UNS_0       = 8'h06 ; 
    parameter   OP_RD_UNS_1       = 8'h07 ; 
    parameter   OP_RD_UNS_2       = 8'h08 ; 
    parameter   OP_RD_UNS_3       = 8'h09 ; 
    parameter   OP_RD_CMP_L       = 8'h0a ; 
    parameter   OP_RD_CMP_H       = 8'h0b ; 
    parameter   OP_RD_RDATA       = 8'h0c ;
    parameter   OP_RD_UNS_ALL     = 6'h0d ;
    parameter   OP_DS_RST         = 8'h80 ; 
    parameter   OP_DS_WR          = 8'h81 ; 
    parameter   OP_DS_LSB_RD      = 8'h82 ; 
    parameter   OP_DS_MSB_RD      = 8'h83 ; 
    parameter   OP_DS_RD          = 8'h84 ; 
    parameter   RD_UNS_ALL_NUM    = 7     ;
    

    input               clk            ;
    input               rst_n          ;
    input [7:0]         uart_in        ;
    input               uart_in_vld    ;
    input [7:0]         intf_rdata     ;
    input               intf_rdata_vld ;
    input               intf_rdy       ;

    output[7:0]         uart_out       ;
    output              uart_out_vld   ;
    output              h2a_en         ;
    output              intf_rst_en    ;
    output              intf_wr_en     ;
    output[7:0]         intf_wdata     ;
    output              intf_rd_en     ;
    output              beep           ;
    output[31:0]        temp_uns       ;
    output              temp_valid_en  ;
    output              led_err        ;


    reg   [7:0]         uart_out       ;
    reg                 uart_vld       ;
    reg                 intf_rst_en    ;
    reg                 intf_wr_en     ;
    reg   [7:0]         intf_wdata     ;
    reg                 intf_rd_en     ;
    reg                 beep           ;
    wire  [31:0]        temp_uns       ;
    reg                 temp_valid_en  ;
    reg                 led_err        ;
    reg                 uart_out_vld   ;
    reg                 h2a_en         ;

    reg   [ 7:0]        opcode_instr   ;
    reg   [ 7:0]        opcode_data    ;
    reg   [ 1:0]        cnt            ;
    wire                add_cnt        ;
    wire                end_cnt        ;
    reg                 opcode_vld     ;
    reg   [1:0]         rdata_addr     ;
    reg   [7:0]         ds_temp_msb_reg;
    reg   [7:0]         ds_temp_lsb_reg;
    reg   [7:0]         ds_temp_rdata_reg;
    reg   [7:0]         temp_cmp_l       ;
    reg   [7:0]         temp_cmp_h       ;
    reg   [13:0]        temp_hex_dot     ;
    reg   [6:0]         temp_hex_int     ;
    reg   [3:0]         temp_uns_0dot1   ;
    reg   [3:0]         temp_uns_0dot01  ;
    reg   [3:0]         temp_uns_0dot001 ;
    reg   [3:0]         temp_uns_0dot0001;
    reg   [3:0]         temp_uns_1       ;
    reg   [3:0]         temp_uns_10      ;
    reg   [3:0]         temp_uns_100     ;
    reg                 beep_en          ;
    reg                 temp_cmp_h_err   ;
    reg                 temp_cmp_l_err   ;
    reg                 temp_uns_sign    ;

    wire[ 7:0]          temp_uns_sign_ascii ;
    wire[ 7:0]          ascii_dot           ;
    wire[ 7:0]          ascii_enter         ;
    wire[55:0]          temp_uns_for_send   ;
    wire[7:0]           ds_temp_lsb_reg_rev ;
    wire[7:0]           ds_temp_msb_reg_rev ;
    reg                 rd_uns_all_flag     ;
    reg[3:0]            rd_uns_all_cnt      ;

    always @(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            cnt <= 0;
        end
        else if(add_cnt)begin
            if(end_cnt)
                cnt <= 0;
            else
                cnt <= cnt + 1;
        end
    end

    assign add_cnt = uart_in_vld;       
    assign end_cnt = add_cnt && cnt==2-1 ;   


    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            opcode_instr <= 0;
        end
        else if(add_cnt && cnt==1-1) begin
            opcode_instr <= uart_in;
        end
    end

    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            opcode_data <= 0;
        end
        else if(add_cnt && cnt==2-1) begin
            opcode_data <= uart_in;
        end
    end


    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            opcode_vld <= 1'b0;
        end
        else if(end_cnt) begin
            opcode_vld <= 1'b1;
        end
        else begin
            opcode_vld <= 1'b0;
        end
    end

    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            intf_rst_en <= 1'b0;
        end
        else if(opcode_vld && opcode_instr==OP_DS_RST) begin
            intf_rst_en <= 1'b1;
        end
        else begin
            intf_rst_en <= 1'b0;
        end
    end

    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            intf_wdata <= 0;
        end
        else if(opcode_vld && opcode_instr==OP_DS_WR) begin
            intf_wdata <= opcode_data;
        end
    end

    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            intf_wr_en <= 0;
        end
        else if(opcode_vld && opcode_instr==OP_DS_WR) begin
            intf_wr_en <= 1'b1;
        end
        else begin
            intf_wr_en <= 1'b0;
        end
    end

    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            intf_rd_en <= 0;
        end
        else if(opcode_vld && (opcode_instr==OP_DS_LSB_RD ||opcode_instr==OP_DS_MSB_RD ||opcode_instr==OP_DS_RD)) begin
            intf_rd_en <= 1'b1;
        end
        else begin
            intf_rd_en <= 1'b0;
        end
    end

    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            rdata_addr <= 0;
        end
        else if(opcode_vld)begin
           if(opcode_instr==OP_DS_LSB_RD)
               rdata_addr <= 0;
           else if(opcode_instr==OP_DS_MSB_RD)
               rdata_addr <= 1;
           else if(opcode_instr==OP_DS_RD)
               rdata_addr <= 2;
        end
    end


    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            ds_temp_lsb_reg <= 0;
        end
        else if(intf_rdata_vld && rdata_addr==0) begin
            ds_temp_lsb_reg <= intf_rdata;
        end
    end

    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            ds_temp_msb_reg <= 0;
        end
        else if(intf_rdata_vld && rdata_addr==1) begin
            ds_temp_msb_reg <= intf_rdata;
        end
    end

    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            ds_temp_rdata_reg <= 0;
        end
        else if(intf_rdata_vld && rdata_addr==2) begin
            ds_temp_rdata_reg <= intf_rdata;
        end
    end


    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            temp_valid_en <= 1'b0;
        end
        else if(opcode_vld && opcode_instr==OP_TEMP_VALID)begin
            temp_valid_en <= opcode_data[0];
        end
    end

    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            temp_cmp_l <= 0;
        end
        else if(opcode_vld && opcode_instr==OP_TEMP_CMP_L)begin
            temp_cmp_l <= opcode_data;
        end
    end

    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            temp_cmp_h <= 0;
        end
        else if(opcode_vld && opcode_instr==OP_TEMP_CMP_H)begin
            temp_cmp_h <= opcode_data;
        end
    end

    wire[15:0]   ds_temp_reg_rev ;
    wire[15:0]   ds_temp_reg ;
    assign       ds_temp_reg     = {ds_temp_msb_reg,ds_temp_lsb_reg};
    assign       ds_temp_reg_rev = (~ds_temp_reg) + 1;
    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            temp_hex_dot <= 0;
        end
        else if(opcode_vld && opcode_instr==OP_TEMP_CHANGE_EN) begin
            temp_hex_dot <= (ds_temp_msb_reg[7]?ds_temp_reg_rev[3:0]:ds_temp_reg[3:0])*625;
        end
    end

    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            temp_hex_int <= 0;
        end
        else if(opcode_vld && opcode_instr==OP_TEMP_CHANGE_EN) begin
            temp_hex_int <= (ds_temp_msb_reg[7]?ds_temp_reg_rev[10:4]:ds_temp_reg[10:4]);
        end
    end

    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            temp_uns_sign <= 1'b0;
        end
        else if(opcode_vld && opcode_instr==OP_TEMP_CHANGE_EN) begin
            temp_uns_sign <= ds_temp_msb_reg[7];
        end
    end

    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            temp_uns_0dot1 <= 0;
        end
        else begin
            temp_uns_0dot1 <= temp_hex_dot/1000;
        end
    end

    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            temp_uns_0dot01 <= 0;
        end
        else begin
            temp_uns_0dot01 <= (temp_hex_dot/100)%10;
        end
    end

    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            temp_uns_0dot001 <= 0;
        end
        else begin
            temp_uns_0dot001 <= (temp_hex_dot/10)%10;
        end
    end

    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            temp_uns_0dot0001 <= 0;
        end
        else begin
            temp_uns_0dot0001 <= (temp_hex_dot%10);
        end
    end

    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            temp_uns_1 <= 0;
        end
        else begin
            temp_uns_1 <= temp_hex_int%10;
        end
    end

    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            temp_uns_10 <= 0;
        end
        else begin
            temp_uns_10 <= (temp_hex_int/10)%10;
        end
    end

    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            temp_uns_100 <= 0;
        end
        else begin
            temp_uns_100 <= (temp_hex_int/100)%10;
        end
    end


    assign  temp_uns = {{4{temp_uns_sign}},temp_uns_100,temp_uns_10,temp_uns_1,temp_uns_0dot1,temp_uns_0dot01,temp_uns_0dot001,temp_uns_0dot0001};


    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            beep_en <= 1'b0;
        end
        else if(opcode_vld && opcode_instr==OP_BEEP_EN) begin
            beep_en <= opcode_data[0];
        end
    end



    always  @(*)begin
        if(temp_uns_sign)begin
            if(temp_cmp_h[7]==1'b0)
                temp_cmp_h_err = 1'b0;
            else if(temp_hex_int[6:0] > temp_cmp_h[6:0])
                temp_cmp_h_err = 1'b0;
            else
                temp_cmp_h_err = 1'b1;
        end
        else begin
            if(temp_cmp_h[7]==1'b1)
                temp_cmp_h_err = 1'b1;
            else if(temp_hex_int[6:0] > temp_cmp_h[6:0])
                temp_cmp_h_err = 1'b1;
            else
                temp_cmp_h_err = 1'b0;
        end
    end


    always  @(*)begin
        if(temp_uns_sign)begin
            if(temp_cmp_l[7]==1'b0)
                temp_cmp_l_err = 1'b1;
            else if(temp_hex_int[6:0] > temp_cmp_l[6:0])
                temp_cmp_l_err = 1'b1;
            else
                temp_cmp_l_err = 1'b0;
        end
        else begin
            if(temp_cmp_l[7]==1'b1)
                temp_cmp_l_err = 1'b0;
            else if(temp_hex_int[6:0] > temp_cmp_l[6:0])
                temp_cmp_l_err = 1'b0;
            else
                temp_cmp_l_err = 1'b1;
        end
    end



    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            beep <= 1'b1 ;
        end
        else if(beep_en) begin
            if(temp_cmp_l_err || temp_cmp_h_err)
                beep <= 1'b0;
            else
                beep <= 1'b1;
        end
        else begin
            beep <= 1'b1;
        end
    end


    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            led_err <= 1'b1;
        end
        else if(opcode_vld && (opcode_instr==OP_DS_RST ||opcode_instr==OP_DS_LSB_RD ||opcode_instr==OP_DS_MSB_RD ||opcode_instr==OP_DS_RD ||opcode_instr==OP_DS_WR) && intf_rdy==1'b0) begin
            led_err <= 1'b0;
        end
    end


    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            rd_uns_all_flag <= 1'b0;
        end
        else if(opcode_vld && opcode_instr==OP_RD_UNS_ALL) begin
            rd_uns_all_flag <= 1'b1;
        end
        else if(rd_uns_all_flag && rd_uns_all_cnt==RD_UNS_ALL_NUM-1)begin
            rd_uns_all_flag <= 1'b0;
        end
    end

    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            rd_uns_all_cnt <= 0;
        end
        else if(rd_uns_all_flag) begin
            if(rd_uns_all_cnt==RD_UNS_ALL_NUM-1)
                rd_uns_all_cnt <= 0;
            else
                rd_uns_all_cnt <= rd_uns_all_cnt + 1;
        end
        else begin
            rd_uns_all_cnt <= 0;
        end
    end

    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            uart_out     <= 0;
            uart_out_vld <= 1'b0;
        end
        else if(opcode_vld) begin
            case(opcode_instr)
                OP_RD_CMP_L: begin
                    uart_out     <= ds_temp_lsb_reg;
                    uart_out_vld <= 1'b1;
                end
                OP_RD_CMP_H: begin
                    uart_out     <= ds_temp_msb_reg;
                    uart_out_vld <= 1'b1;
                end
                OP_RD_RDATA: begin
                    uart_out     <= ds_temp_rdata_reg;
                    uart_out_vld <= 1'b1;
                end
                OP_RD_UNS_0: begin
                    uart_out     <= {{4{temp_uns_sign}},temp_uns[27:24]};
                    uart_out_vld <= 1'b1;
                end
                OP_RD_UNS_1: begin
                    uart_out     <= temp_uns[23:16];
                    uart_out_vld <= 1'b1;
                end
                OP_RD_UNS_2: begin
                    uart_out     <= temp_uns[15: 8];
                    uart_out_vld <= 1'b1;
                end
                OP_RD_UNS_3: begin
                    uart_out     <= temp_uns[ 7: 0];
                    uart_out_vld <= 1'b1;
                end
                default    : begin
                    uart_out     <= 0              ;
                    uart_out_vld <= 1'b0;
                end
            endcase
        end
        else if(rd_uns_all_flag)begin
            uart_out     <= temp_uns_for_send[(RD_UNS_ALL_NUM-rd_uns_all_cnt)*8-1 -:8];
            uart_out_vld <= 1'b1;
            
        end
        else begin
             uart_out_vld <= 1'b0;
        end
    end

    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            h2a_en <= 1'b1;
        end
        else if(rd_uns_all_flag && (rd_uns_all_cnt==0 || rd_uns_all_cnt==3 || rd_uns_all_cnt==RD_UNS_ALL_NUM-1)) begin
            h2a_en <= 1'b0;
        end
        else begin
            h2a_en <= 1'b1;
        end
    end


    assign  temp_uns_sign_ascii = (temp_uns_sign)?8'h2D:8'h2B;
    assign  ascii_dot           = 8'h2E;
    assign  ascii_enter         = 8'h0A;
    assign  temp_uns_for_send = {temp_uns_sign_ascii,4'b0,temp_uns[27:16],ascii_dot,temp_uns[15:0],ascii_enter};

endmodule

