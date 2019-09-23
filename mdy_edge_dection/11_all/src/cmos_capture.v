module cmos_capture(
    clk         ,
    rst_n       ,
    en_capture  ,
    vsync       ,
    href        ,
    din         ,
    dout        ,
    dout_vld    ,
    dout_sop    ,
    dout_eop     
);

    input          clk          ; 
    input          rst_n        ;
    input          en_capture   ;
    input          vsync        ;
    input          href         ;
    input  [7:0]   din          ;

    output reg  [15:0]  dout         ;
    output reg          dout_vld     ;
    output reg          dout_sop     ;
    output reg          dout_eop     ;

    reg             vsync_t1;
    reg  [31:0]     cnt0;
    wire            add_cnt0;
    wire            end_cnt0;

    reg  [31:0]     cnt1;
    wire            add_cnt1;
    wire            end_cnt1;

    reg  [31:0]     cnt2;
    wire            add_cnt2;
    wire            end_cnt2;

    reg             flag_capture;


    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            vsync_t1 <= 1'b0;
        end
        else begin
            vsync_t1 <= vsync;
        end
    end

   always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            flag_capture <= 1'b0;
        end
        else if(en_capture && vsync_t1 && ~vsync)begin
            flag_capture <= 1'b1;
        end
        else if(en_capture == 1'b0 && vsync_t1 && ~vsync)begin
            flag_capture <= 1'b0;
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

    assign add_cnt0 = (flag_capture == 1'b1 && href == 1'b1);
    assign end_cnt0 = add_cnt0 && cnt0== (2 - 1);

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
    assign end_cnt1 = add_cnt1 && cnt1== (640 - 1);

    always @(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            cnt2 <= 0;
        end
        else if(add_cnt2)begin
            if(end_cnt2)
                cnt2 <= 0;
            else
                cnt2 <= cnt2 + 1;
        end
    end

    assign add_cnt2 = end_cnt1;       
    assign end_cnt2 = add_cnt2 && cnt2== (480 - 1);   


    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            dout <= 16'h00; 
        end
        else if(add_cnt0)begin
            // for test
            //if(cnt2 > 16'd220 && cnt2 < 16'd230)begin
            //     dout <= 16'hffff;
            //end
            //else begin
            //    dout <= 16'h0000;
            //end
            dout <= {dout[7:0], din};
        end
    end

    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            dout_vld <= 1'b0;
        end
        else if(end_cnt0)begin
            dout_vld <= 1'b1;
        end
        else begin
            dout_vld <= 1'b0;
        end
    end

    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            dout_sop <= 1'b0;
        end
        else if(end_cnt0 && cnt1 == (1 - 1) && cnt2 == (1 - 1))begin
            dout_sop <= 1'b1;
        end
        else begin
            dout_sop <= 1'b0;
        end
    end


    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            dout_eop <= 1'b0;
        end
        else if(end_cnt2)begin
            dout_eop <= 1'b1;
        end
        else begin
            dout_eop <= 1'b0;
        end
    end


endmodule

