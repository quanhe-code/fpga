module vga_config(
    clk         ,
    rst_n       ,
    din         ,
    din_vld     ,
    din_sop     ,
    din_eop     ,
    rd_addr     ,
    rd_en       ,
    rd_end      ,
    rd_addr_sel ,
    dout        ,
    wr_end           
);

    //输入信号定义
    input         clk        ;
    input         rst_n      ;
    input         din        ;
    input         din_vld    ;
    input         din_sop    ;
    input         din_eop    ;
    input  [15:0] rd_addr    ;
    input         rd_en      ;
    input         rd_end     ;
    input         rd_addr_sel;

    //输出信号定义
    output        dout     ;
    output        wr_end   ;

    //输出信号reg定义
    reg           dout     ;
    reg           wr_end   ;

    //中间信号定义
    reg    [9:0]  cnt_col         ;
    reg    [9:0]  cnt_row         ;
    reg           wr_data         ;
    reg    [15:0] wr_addr         ;
    reg           wr_addr_sel     ;
    reg           wr_en0          ;
    reg           wr_en1          ;
    reg           rd_en0          ;
    reg           rd_en1          ;
    reg           flag_wr         ;

    wire          add_cnt_col     ;
    wire          end_cnt_col     ;
    wire          add_cnt_row     ;
    wire          end_cnt_row     ;
    wire          display_area    ;
    wire          q0              ;
    wire          q1              ;

    always @ (posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            cnt_col <= 0;
        end
        else if(add_cnt_col)begin
            if(end_cnt_col)
                cnt_col <= 0;
            else
                cnt_col <= cnt_col + 1;
        end
    end

    assign add_cnt_col = (flag_wr || (wr_end==0 && din_sop)) && din_vld;
    assign end_cnt_col = add_cnt_col && cnt_col == 640-1;

    always @ (posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            cnt_row <= 0;
        end
        else if(add_cnt_row)begin
            if(end_cnt_row)
                cnt_row <= 0;
            else
                cnt_row <= cnt_row + 1;
        end
    end

    assign add_cnt_row = end_cnt_col;
    assign end_cnt_row = add_cnt_row && cnt_row == 480-1;

    always @ (posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            wr_data <= 0;
        end
        else if(display_area)begin
            wr_data <= din;
        end
    end

    assign display_area = cnt_col >= 160 && cnt_col < 480 && cnt_row >= 140 && cnt_row <= 340;

    always @ (posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            wr_addr <= 0;
        end
        else if(display_area)begin
            wr_addr <= (cnt_col-160) + 320*(cnt_row-140);
        end
    end

    always @ (posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            wr_addr_sel <= 0;
        end
        else if(wr_end && rd_end)begin
            wr_addr_sel <= ~wr_addr_sel;
        end
    end

    always @ (posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            wr_end <= 0;
        end
        else if(end_cnt_row)begin
            wr_end <= 1;
        end
        else if(wr_end && rd_end)begin
            wr_end <= 0;
        end
    end
    
    always @ (posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            flag_wr <= 0;
        end
        else if(wr_end == 0 && din_sop)begin
            flag_wr <= 1;
        end
        else if(end_cnt_row)begin
            flag_wr <= 0;
        end
    end

    always @ (posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            wr_en0 <= 0;
        end
        else if(display_area && wr_addr_sel==0 && din_vld)begin
            wr_en0 <= 1;
        end
        else begin
            wr_en0 <= 0;
        end
    end

    always @ (posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            wr_en1 <= 0;
        end
        else if(display_area && wr_addr_sel==1 && din_vld)begin
            wr_en1 <= 1;
        end
        else begin
            wr_en1 <= 0;
        end
    end

    ram_ipcore u0(
	    .clock      (clk       ),
	    .data       (wr_data   ),
	    .rdaddress  (rd_addr   ),
	    .rden       (rd_en0    ),
	    .wraddress  (wr_addr   ),
	    .wren       (wr_en0    ),
	    .q          (q0        ) 
    );

    ram_ipcore u1(
	    .clock      (clk       ),
	    .data       (wr_data   ),
	    .rdaddress  (rd_addr   ),
	    .rden       (rd_en1    ),
	    .wraddress  (wr_addr   ),
	    .wren       (wr_en1    ),
	    .q          (q1        ) 
    );

    always @ (*)begin
        if(rd_en && rd_addr_sel == 0)
            rd_en0 = 1;
        else 
            rd_en0 = 0;
    end

    always @ (*)begin
        if(rd_en && rd_addr_sel == 1)
            rd_en1 = 1;
        else 
            rd_en1 = 0;
    end

    always @ (*)begin
        if(rd_addr_sel == 0)begin
            dout = q0;
        end
        else if(rd_addr_sel == 1)begin
            dout = q1;
        end
        else begin
            dout = 0;
        end
    end


endmodule

