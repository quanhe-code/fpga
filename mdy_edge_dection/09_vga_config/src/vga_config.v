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

    output reg          dout     ;
    output reg          wr_end   ;

    reg             flag_add;
    reg  [31:0]     cnt0;
    wire            add_cnt0;
    wire            end_cnt0;

    reg  [31:0]     cnt1;
    wire            add_cnt1;
    wire            end_cnt1;

    reg             wr_data;
    reg             wr_addr;
    reg             wr_en;

    reg             wr_en0;
    reg             wr_en1;

    reg             rd_en0;
    reg             rd_en1;
    
    reg             q0;
    reg             q1;

    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            flag_add <= 1'b0;
        end
        else if(din_sop)begin
            flag_add <= 1'b1;
        end
        else if(din_eop)begin
            flag_add <= 1'b0;
        end
    end

    always @(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            cnt0 <= 0;
        end
        else if(add_cnt0)begin
            if(end_cnt0)
                cnt0 <= 0;
            else
                cnt0 <= cnt0 + 1;
        end
    end

    assign add_cnt0 = (din_sop | flag_add) && wr_end == 1'b0;
    assign end_cnt0 = add_cnt0 && cnt0== (640 - 1);

    always @(posedge clk or negedge rst_n)begin 
        if(!rst_n)begin
            cnt1 <= 0;
        end
        else if(add_cnt1)begin
            if(end_cnt1)
                cnt1 <= 0;
            else
                cnt1 <= cnt1 + 1;
        end
    end

    assign add_cnt1 = end_cnt0;
    assign end_cnt1 = add_cnt1 && cnt1== (480 - 1);

    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            wr_data <= 1'b0;
        end
        else if(din_vld)begin
            wr_data <= din;
        end
    end

    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            wr_addr <= 0;
        end
        else if(cnt0 >= 160 & cnt0 < 480 && cnt1 >= 120 && cnt1 < 320)begin
            wr_addr <= (((cnt1 - 120) * 320) + (cnt0 - 160));
        end
        else begin
            wr_addr <= 0;
        end
    end

    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            wr_en <= 1'b0;
        end
        else if(cnt0 >= 160 & cnt0 < 480 && cnt1 >= 120 && cnt1 < 320)begin
            wr_en <= 1'b1;
        end
        else begin
            wr_en <= 1'b0;
        end
    end

    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            wr_end <= 1'b0;
        end
        else if(end_cnt1)begin
            wr_end <= 1'b1;
        end
        else if(wr_end == 1'b1 && rd_end == 1'b1)begin
            wr_end <= 1'b0;
        end
    end

    always  @(*)begin
        if(rd_addr_sel == 1'b0) begin
            wr_en0 = wr_en;
            wr_en1 = 0;

            rd_en0 = 0;
            rd_en1 = rd_en;

            dout = q1;
        end
        else begin
            wr_en0 = 0;
            wr_en1 = wr_en; 

            rd_en0 = rd_en;
            rd_en1 = 0;

            dout = q0;
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



endmodule

