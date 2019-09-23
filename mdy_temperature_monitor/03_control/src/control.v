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
    temp_valid_en         
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

    output reg [7:0]         uart_out       ;
    output reg              uart_out_vld   ;
    output reg               h2a_en         ;
    output reg               intf_rst_en    ;
    output reg               intf_wr_en     ;
    output reg [7:0]         intf_wdata     ;
    output reg               intf_rd_en     ;
    output reg               beep           ;
    output wire[31:0]        temp_uns       ;
    output reg               temp_valid_en  ;

    reg [7:0]            uart_in_t;
    reg [7:0]            uart_in_tt;   
    reg                  flag_intf_rst;
    reg                  flag_intf_wr;
    reg                  flag_intf_rd;
    reg [7:0]            ds_temp_lsb_reg;
    reg [7:0]            ds_temp_msb_reg;
    reg [7:0]            ds_temp_rdata_reg;
    reg [3:0]            temp_uns_sign;
    reg [3:0]            temp_uns_dot_4;
    reg [3:0]            temp_uns_dot_3;
    reg [3:0]            temp_uns_dot_2;
    reg [3:0]            temp_uns_dot_1;
    reg [3:0]            temp_uns_g;
    reg [3:0]            temp_uns_s;
    reg [3:0]            temp_uns_b;
    reg [7:0]            temp_cmp_l;
    reg [7:0]            temp_cmp_h;
    reg                  beep_en;
    reg [7:0]            uart_out1;
    reg                  uart_out_vld1;
    reg                  h2a_en1;
    reg [7:0]            uart_out2;
    reg                  uart_out_vld2;
    reg                  h2a_en2;
    reg [7:0]            uart_out3;
    reg                  uart_out_vld3;
    reg                  h2a_en3;
    reg [2:0]            cnt;
    wire                add_cnt;
    wire                end_cnt;
    wire[10:0]          ds_temp_data_raw_rev;
    wire[10:0]          ds_temp_data_raw;
    wire[31:0]          ds_temp_data;
    wire[7:0]           ds_temp_int;
    reg                beep_warn1;
    reg                beep_warn2;

    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            uart_in_t <= 8'h0;
        end
        else if(uart_in_vld)begin
            uart_in_t <= uart_in;
        end
    end

    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            uart_in_tt <= 8'h00;
        end
        else if(uart_in_vld) begin
            uart_in_tt <= uart_in_t;
        end
    end
   
   // 80xx 复位请求 
    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            flag_intf_rst <= 0;
        end
        else if(uart_in_t == 8'h80 && uart_in_vld)begin
            flag_intf_rst <= 1;
        end
        else if(intf_rdy == 1)begin
            flag_intf_rst <= 0;
        end
    end

    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            intf_rst_en <= 0;
        end
        else if(flag_intf_rst && intf_rdy)begin
            intf_rst_en <= 1;
        end
        else begin
            intf_rst_en <= 0;
        end
    end

    // 81xx 写DS18B20
    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            flag_intf_wr <= 0;
        end
        else if(uart_in_t == 8'h81 && uart_in_vld)begin
            flag_intf_wr <= 1;
        end
        else if(intf_rdy == 1)begin
            flag_intf_wr <= 0;
        end
    end

    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            intf_wr_en <= 0;
        end
        else if(uart_in_t == 8'h81 && uart_in_vld)begin
            intf_wr_en <= 1;
        end
        else begin
            intf_wr_en <= 0;
        end
    end

    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            intf_wdata <= 8'h00;
        end
        else if(uart_in_t == 8'h81 && uart_in_vld)begin
            intf_wdata <= uart_in;
        end
    end

    // 82xx/83xx/84xx 读ds18b20
    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            intf_rd_en <= 0;
        end
        else if((uart_in_t == 8'h82 || uart_in_t == 8'h83 || uart_in_t == 8'h84) && uart_in_vld)begin
            intf_rd_en <= 1; 
        end
        else begin
            intf_rd_en <= 0;
        end
    end

    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            flag_intf_rd <= 0;
        end
        else if((uart_in_t == 8'h82 || uart_in_t == 8'h83 || uart_in_t == 8'h84) && uart_in_vld)begin
            flag_intf_rd <= 1;
        end
        else if(intf_rdata_vld)begin
            flag_intf_rd <= 0;
        end
    end

    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            ds_temp_lsb_reg <= 8'h00;
        end
        else if(flag_intf_rd && intf_rdata_vld && uart_in_tt == 8'h82)begin
            ds_temp_lsb_reg <= intf_rdata;
        end
    end

    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            ds_temp_msb_reg <= 8'h00;
        end
        else if(flag_intf_rd && intf_rdata_vld && uart_in_tt == 8'h83)begin
            ds_temp_msb_reg <= intf_rdata;
        end
    end
    
    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            ds_temp_rdata_reg <= 8'h00;
        end
        else if(flag_intf_rd && intf_rdata_vld && uart_in_tt == 8'h84)begin
            ds_temp_rdata_reg <= intf_rdata;
        end
    end

    // 01xx 设置数码管开关
    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            temp_valid_en <= 0;
        end
        else if(uart_in_t == 8'h01 && uart_in_vld && uart_in == 8'h00)begin
            temp_valid_en <= 0;
        end
        else if(uart_in_t == 8'h01 && uart_in_vld && uart_in == 8'h01)begin
            temp_valid_en <= 1;
        end
    end

    // 02xx 设置温度报警器范围的下限
     always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            temp_cmp_l <= 8'h00;
        end
        else if(uart_in_t == OP_TEMP_CMP_L && uart_in_vld)begin
            temp_cmp_l <= uart_in;
        end
    end

    // 03xx 设置温度报警器范围的上限
    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            temp_cmp_h <= 8'h00;
        end
        else if(uart_in_t == OP_TEMP_CMP_H && uart_in_vld)begin
            temp_cmp_h <= uart_in;
        end
    end

    // 04xx 计算温度值
    assign ds_temp_data_raw = {ds_temp_msb_reg[2:0], ds_temp_lsb_reg[7:0]};
    assign ds_temp_data_raw_rev = ds_temp_msb_reg[7]?((~ds_temp_data_raw) + 1):ds_temp_data_raw;
    assign ds_temp_data = (ds_temp_data_raw_rev * 625);

    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            temp_uns_sign <= 4'h0;
        end
        else if(uart_in_t == OP_TEMP_CHANGE_EN && uart_in_vld && ds_temp_msb_reg[7]==1)begin
           temp_uns_sign <= 4'hf; 
        end
        else if(uart_in_t == OP_TEMP_CHANGE_EN && uart_in_vld && ds_temp_msb_reg[7]==0)begin
            temp_uns_sign <= 4'h0;
        end
    end

    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            temp_uns_dot_4 <= 4'h0;
        end
        else if(uart_in_t == OP_TEMP_CHANGE_EN && uart_in_vld)begin
            temp_uns_dot_4 <= (ds_temp_data % 10);
        end
    end
    
    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            temp_uns_dot_3 <= 4'h0;
        end
        else if(uart_in_t == OP_TEMP_CHANGE_EN && uart_in_vld)begin
            temp_uns_dot_3 <= ((ds_temp_data / 10) % 10);
        end
    end
    
    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            temp_uns_dot_2 <= 4'h0;
        end
        else if(uart_in_t == OP_TEMP_CHANGE_EN && uart_in_vld)begin
            temp_uns_dot_2 <= ((ds_temp_data / 100) % 10);
        end
    end

    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            temp_uns_dot_1 <= 4'h0;
        end
        else if(uart_in_t == OP_TEMP_CHANGE_EN && uart_in_vld)begin
            temp_uns_dot_1 <= ((ds_temp_data / 1000) % 10);
        end
    end

    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            temp_uns_g <= 4'h0;
        end
        else if(uart_in_t == OP_TEMP_CHANGE_EN && uart_in_vld)begin
            temp_uns_g <= ((ds_temp_data / 10000) % 10);
        end
    end

    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            temp_uns_s <= 4'h0;
        end
        else if(uart_in_t == OP_TEMP_CHANGE_EN && uart_in_vld)begin
            temp_uns_s <= ((ds_temp_data / 100000) % 10);
        end
    end

    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            temp_uns_b <= 4'h0;
        end
        else if(uart_in_t == OP_TEMP_CHANGE_EN && uart_in_vld)begin
            temp_uns_b <= ((ds_temp_data / 1000000) % 10);
        end
    end

    assign temp_uns = {temp_uns_sign,temp_uns_b, temp_uns_s, temp_uns_g, 
        temp_uns_dot_1, temp_uns_dot_2, temp_uns_dot_3, temp_uns_dot_4};

    // 05xx 设置温度报警功能
    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            beep_en <= 1'b0;
        end
        else if(uart_in_t == OP_BEEP_EN && uart_in_vld && uart_in == 8'h00)begin
            beep_en <= 1'b0;
        end
        else if(uart_in_t == OP_BEEP_EN && uart_in_vld && uart_in == 8'h01)begin
            beep_en <= 1'b1;
        end
    end
    
    // 06xx/07xx/08xx/09xx/
    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            uart_out1 <= 8'h00;
        end
        else if((uart_in_t == OP_RD_UNS_0 || uart_in_t == OP_RD_UNS_1 || uart_in_t == OP_RD_UNS_2 
            || uart_in_t == OP_RD_UNS_3) &&  uart_in_vld)begin
            uart_out1 <= (temp_uns >> ((9 - uart_in_t) * 8));
        end
    end
    
    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            uart_out_vld1 <= 1'b0;
        end
        else if((uart_in_t == OP_RD_UNS_0 || uart_in_t == OP_RD_UNS_1 || uart_in_t == OP_RD_UNS_2 
            || uart_in_t == OP_RD_UNS_3) &&  uart_in_vld)begin
            uart_out_vld1 <= 1'b1;
        end
        else begin
            uart_out_vld1 <= 1'b0;
        end
    end

    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            h2a_en1 <= 1'b0;
        end
        else if((uart_in_t == OP_RD_UNS_0 || uart_in_t == OP_RD_UNS_1 || uart_in_t == OP_RD_UNS_2 
            || uart_in_t == OP_RD_UNS_3) &&  uart_in_vld)begin
            h2a_en1 <= 1'b1;
        end
        else begin
            h2a_en1 <= 1'b0;
        end
    end

    // 0axx/0bxx/0cxx
    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            uart_out2 <= 8'h00;
        end
        else if(uart_in_t==OP_RD_CMP_L && uart_in_vld)begin
            uart_out2 <= ds_temp_lsb_reg;
        end
        else if(uart_in_t==OP_RD_CMP_H && uart_in_vld)begin
            uart_out2 <= ds_temp_msb_reg;
        end
        else if(uart_in_t == OP_RD_RDATA && uart_in_vld) begin
            uart_out2 <= ds_temp_rdata_reg;
        end
    end
    
    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            uart_out_vld2 <= 1'b0;
        end
        else if((uart_in_t==OP_RD_CMP_L || uart_in_t==OP_RD_CMP_H 
            || uart_in_t == OP_RD_RDATA) && uart_in_vld) begin
            uart_out_vld2 <= 1'b1;
        end
        else begin
            uart_out_vld2 <= 1'b0;
        end
    end

    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            h2a_en2 <= 1'b0;
        end
        else if((uart_in_t==OP_RD_CMP_L || uart_in_t==OP_RD_CMP_H 
            || uart_in_t == OP_RD_RDATA) && uart_in_vld) begin
            h2a_en2 <= 1'b1;
        end
        else begin
            h2a_en2 <= 1'b0;
        end
    end

    // 0dxx
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

    assign add_cnt = (uart_out_vld3);       
    assign end_cnt = add_cnt && cnt== (7 - 1);   

    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            uart_out3 <= 8'h00;
        end
        else if(uart_in_t == OP_RD_UNS_ALL && uart_in_vld) begin
            uart_out3 <= (temp_uns[31:28] == 4'h0 ? 8'h2b : 8'h2d);
        end
        else if(add_cnt && cnt == (1 - 1)) begin
            uart_out3 <= temp_uns[27:24];
        end
        else if(add_cnt && cnt == (2 - 1)) begin
            uart_out3 <= temp_uns[23:16];
        end
        else if(add_cnt && cnt == (3 - 1)) begin
            uart_out3 <= 8'h2e;
        end
        else if(add_cnt && cnt == (4 - 1)) begin
            uart_out3 <= temp_uns[15:8];
        end
        else if(add_cnt && cnt == (5 - 1)) begin
            uart_out3 <= temp_uns[7:0];
        end
        else if(add_cnt && cnt == (6 - 1)) begin
            uart_out3 <= 8'h0a;
        end
        else begin
            uart_out3 <= uart_out3;
        end
    end

    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            uart_out_vld3 <= 1'b0;
        end
        else if(uart_in_t == OP_RD_UNS_ALL && uart_in_vld)begin
            uart_out_vld3 <= 1'b1;
        end
        else if(end_cnt)begin
            uart_out_vld3 <= 1'b0;
        end
    end

    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            h2a_en3 <= 1'b0;
        end
        else if(add_cnt && cnt == (1 - 1))begin
            h2a_en3 <= 1'b0;
        end
        else if(add_cnt && cnt == (2 - 1))begin
            h2a_en3 <= 1'b1;
        end
        else if(add_cnt && cnt == (4 - 1))begin
            h2a_en3 <= 1'b0;
        end
        else if(add_cnt && cnt == (5 - 1))begin
            h2a_en3 <= 1'b1;
        end
        else if(add_cnt && cnt == (6 - 1))begin
            h2a_en3 <= 1'b0;
        end
        else if(add_cnt && cnt == (7 - 1))begin
            h2a_en3 <= 1'b1;
        end
        else begin
            h2a_en3 <= h2a_en3;
        end
    end

    // 整合信号uart_out uart_out_vld h2a_en
    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            uart_out <= 8'h00;
        end
        else if(uart_out_vld1)begin
            uart_out <= uart_out1;
        end
        else if(uart_out_vld2)begin
            uart_out <= uart_out2;
        end
        else if(uart_out_vld3)begin
            uart_out <= uart_out3;
        end
        else begin
            uart_out <= uart_out;
        end
    end

    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            h2a_en <= 1'b0;
        end
        else if(uart_out_vld1)begin
            h2a_en <= h2a_en1;
        end
        else if(uart_out_vld2)begin
            h2a_en <= h2a_en2;
        end
        else if(uart_out_vld3)begin
            h2a_en <= h2a_en3;
        end
        else begin
            h2a_en <= 1'b0;
        end
    end

    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            uart_out_vld <= 1'b0;
        end
        else if(uart_out_vld1 || uart_out_vld2 || uart_out_vld3)begin
            uart_out_vld <= 1'b1;
        end
        else begin
            uart_out_vld <= 1'b0;
        end
    end

    // 温度报警功能
    assign ds_temp_int[6:0] = (ds_temp_data / 10000);   
    assign ds_temp_int[7] = (temp_uns_sign == 4'h0 ? 1'b0 : 1'b1);
    always  @(*)begin
        if(beep_en) begin
            if(ds_temp_int[7] == 1'h0 && temp_cmp_h[7] == 1'b0) begin
                if(ds_temp_int[6:0] > temp_cmp_h[6:0]) begin
                    beep_warn1 = 1'b0;
                end
                else begin
                    beep_warn1 = 1'b1;
                end
            end
            else if(ds_temp_int[7] == 1'h0 && temp_cmp_h[7] == 1'b1) begin
                beep_warn1 = 1'b0;
            end
            else if(ds_temp_int[7] == 1'h1 && temp_cmp_h[7] == 1'b0) begin
                beep_warn1 = 1'b1;
            end
            else begin
                if(ds_temp_int[6:0] > temp_cmp_h[6:0]) begin
                    beep_warn1 = 1'b1;
                end
                else begin
                    beep_warn1 = 1'b0;
                end
            end
        end
        else begin
            beep_warn1 = 1'b1;
        end
    end

    always  @(*)begin
        if(beep_en)begin
           if(ds_temp_int[7] == 1'h0 && temp_cmp_l[7] == 1'b0) begin
                if(ds_temp_int[6:0] > temp_cmp_l[6:0]) begin
                    beep_warn2 = 1'b1;
                end
                else begin
                    beep_warn2 = 1'b0;
                end
            end
            else if(ds_temp_int[7] == 1'h0 && temp_cmp_l[7] == 1'b1) begin
                beep_warn2 = 1'b1;
            end
            else if(ds_temp_int[7] == 1'h1 && temp_cmp_l[7] == 1'b0) begin
                beep_warn2 = 1'b0;
            end
            else begin
                if(ds_temp_int[6:0] > temp_cmp_l[6:0]) begin
                    beep_warn2 = 1'b0;
                end
                else begin
                    beep_warn2 = 1'b1;
                end
            end 
        end
        else begin
            beep_warn2 = 1'b1;
        end
    end

    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            beep <= 1'b1;
        end
        else begin
            beep <= (beep_warn1 & beep_warn2);
        end
    end
endmodule

