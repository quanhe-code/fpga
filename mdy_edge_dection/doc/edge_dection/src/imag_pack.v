module imag_pack(
    clk          ,
    clk_100m     ,
    rst_n        ,
    din           ,
    din_sop       ,
    din_eop       ,
    din_vld       ,
    din_rdy       ,
    dout         ,
    dout_sop     ,
    dout_eop     ,
    dout_vld     ,
    dout_rdy     ,
    dout_mty       

);
 `include "clogb2.v"

    parameter      DATA_W    = 16      ;
    parameter      D_DATA_W  = 16 +3   ;
    parameter      D_DEPT_W  = 512     ;
    parameter      D_DEPT_W_C = clogb2(D_DEPT_W)-1;

    parameter    CHAN        = 8'b0;
    parameter    PAYL_LEN    = 1024;  //BYTE
    parameter    TOTAL_BYTE  = 640*480;
    parameter    TOTAL_NUM   = TOTAL_BYTE/PAYL_LEN;  
    parameter    HEAD_LEN    = 16;

    input          clk          ;
    input          clk_100m     ;
    input          rst_n        ;
    input[ 7:0]    din           ;
    input          din_sop       ;
    input          din_eop       ;
    input          din_vld       ;
    output         din_rdy       ;
    output[15:0]   dout         ;
    output         dout_sop     ;
    output         dout_eop     ;
    output         dout_vld     ;
    input          dout_rdy     ;
    output         dout_mty     ; 


    reg            din_rdy       ;
    reg   [15:0]   dout         ;
    reg            dout_sop     ;
    reg            dout_eop     ;
    reg            dout_vld     ;
    reg            dout_mty     ; 

    wire[D_DATA_W-1 :0] d_data  ;
    wire                d_rdreq ;
    wire                d_wrreq ;
    wire                d_empty ;
    wire[D_DATA_W-1 :0] d_q      ;
    wire  [D_DEPT_W_C-1:0] d_usedw    ;

    wire                d_q_sop  ;
    wire                d_q_eop  ;
    wire                d_q_mty  ;

    reg [18:0]          din_ff0;
    reg                 din_sop_ff0;
    reg                 din_eop_ff0;
    reg                 din_mty_ff0;
    reg  [ 1:0]         cnt0     ;
    wire                add_cnt0 ;
    wire                end_cnt0 ;
    reg  [ 15:0]        cnt1    ;
    wire                add_cnt1;
    wire                end_cnt1;
    reg  [  2:0]        cnt2    ;
    wire                add_cnt2;
    wire                end_cnt2;
    reg  [ 15:0]        cnt3    ;
    wire                add_cnt3;
    wire                end_cnt3;
    wire [HEAD_LEN*8-1:0]  head    ;
    wire [ 15:0]        tail    ;
    reg  [ 15:0]        sum     ;

    reg                 flag_work;
    wire                flag_work_start;
    wire                flag_work_stop ;
    reg  [ 15:0]        x       ;

    reg [31:0]      cnt_time;
    wire            add_cnt_time;
    wire            end_cnt_time;

    reg[1:0]        flag_time;


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

    assign add_cnt0 = din_vld;
    assign end_cnt0 = add_cnt0 && (cnt0==2-1 || din_eop) ;


    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            din_ff0 <= 0;
        end
        else if(add_cnt0) begin
            din_ff0[15-8*cnt0 -:8] <= din;
        end
    end

    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            din_sop_ff0 <= 0;
        end
        else if(add_cnt0 && cnt0==1-1) begin
            din_sop_ff0 <= din_sop;
        end
    end

    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            din_eop_ff0 <= 0;
        end
        else if(end_cnt0) begin
            din_eop_ff0 <= din_eop;
        end
    end

    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            din_mty_ff0 <= 0;
        end
        else if(din_vld && din_eop) begin
            din_mty_ff0 <= 1-cnt0;
        end
    end

    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            din_rdy <= 1;
        end
        else begin
            din_rdy <= (d_usedw < (D_DEPT_W-16));
        end
    end

    
    assign d_data  = {din_sop_ff0,din_eop_ff0,din_mty_ff0,din_ff0};
    assign d_wrreq = end_cnt0;

    fifo_ahead#(.DATA_W(D_DATA_W),.DEPT_W(D_DEPT_W)) u_dfifo(
        .aclr    (~rst_n  ),
    	.data    (d_data  ) ,
    	.rdclk   (clk_100m) ,
    	.rdreq   (d_rdreq ) ,
    	.wrclk   (clk     ) ,
    	.wrreq   (d_wrreq ) ,
        .wrusedw (d_usedw ) ,
    	.rdempty (d_empty ) ,
    	.q       (d_q     ) );

     
    wire [ 31:0]  total_byte;
    wire [ 15:0]  total_num ;
    wire [ 15:0]  chan      ;
    wire [ 15:0]  data_len  ;

    assign total_byte = TOTAL_BYTE;
    assign total_num  = TOTAL_NUM ;
    assign chan       = CHAN      ;


    assign d_rdreq = cnt2==1 && dout_rdy && d_empty==0;

    assign data_len   = PAYL_LEN +10;
    assign head       = {16'hefef,chan,data_len,total_byte,sum,total_num,cnt3};
    assign tail       = 16'hfefe;

    assign flag_work_start = flag_work_start==0 && d_empty==0;
    assign flag_work_stop  = flag_work_start    && end_cnt2;

    always  @(posedge clk_100m or negedge rst_n)begin
        if(rst_n==1'b0)begin
            flag_work <= 0;
        end
        else if(flag_work_start) begin
            flag_work <= 1;
        end
        else if(flag_work_stop) begin
            flag_work <= 0;
        end
    end

    

    always @(posedge clk_100m or negedge rst_n)begin 
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

    assign add_cnt1 = (flag_work && cnt2!=1) || d_rdreq;
    assign end_cnt1 = add_cnt1 && cnt1==x-1 ;

    always @(posedge clk_100m or negedge rst_n)begin
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
    assign end_cnt2 = add_cnt2 && cnt2==3-1 ;


    always @(posedge clk_100m or negedge rst_n)begin
        if(!rst_n)begin
            cnt3 <= 0;
        end
        else if(add_cnt3)begin
            if(end_cnt3)
                cnt3 <= 0;
            else
                cnt3 <= cnt3 + 1;
        end
    end

    assign add_cnt3 = end_cnt2;
    assign end_cnt3 = add_cnt3 && cnt3==TOTAL_NUM-1 ;

    always  @(*)begin
        if(cnt2==0)
            x = HEAD_LEN/2;
        else if(cnt2==1)
            x = PAYL_LEN/2;
        else
            x = 1;
    end


    always  @(posedge clk_100m or negedge rst_n)begin
        if(rst_n==1'b0)begin
            dout_sop <= 0;
        end
        else if(add_cnt1 && cnt1==1-1 && cnt2==0) begin
            dout_sop <= 1;
        end
        else begin
            dout_sop <= 0;
        end
    end
    
    
    always  @(posedge clk_100m or negedge rst_n)begin
        if(rst_n==1'b0)begin
            dout_eop <= 0;
        end
        else begin
            dout_eop <= end_cnt2;
        end
    end
    
    always  @(posedge clk_100m or negedge rst_n)begin
        if(rst_n==1'b0)begin
            dout <= 0;
        end
        else if(cnt2==0) begin
            dout <= head[127-16*cnt1 -:16];
        end
        else if(cnt2==1)begin
            dout <= d_q[15:0];
        end
        else begin
            dout <= tail;
        end
    end
    
    always  @(posedge clk_100m or negedge rst_n)begin
        if(rst_n==1'b0)begin
            dout_vld <= 0;
        end
        else begin
            dout_vld <= add_cnt1 && flag_time==3;
        end
    end
    
    always  @(posedge clk_100m or negedge rst_n)begin
        if(rst_n==1'b0)begin
            dout_mty <= 0;
        end
        else begin
            dout_mty <= 0;
        end
    end


   
    always @(posedge clk_100m or negedge rst_n)begin
        if(!rst_n)begin
            cnt_time <= 0;
        end
        else if(add_cnt_time)begin
            if(end_cnt_time)
                cnt_time <= 0;
            else
                cnt_time <= cnt_time + 1;
        end
    end

    assign add_cnt_time = 1;       
    assign end_cnt_time = add_cnt_time && cnt_time==1000_000_000-1 ;

    always  @(posedge clk_100m or negedge rst_n)begin
        if(rst_n==1'b0)begin
            flag_time <= 0;
        end
        else if(flag_time==0 && end_cnt_time) begin
            flag_time <= 1;
        end
        else if(flag_time!=0 && end_cnt3)begin
            flag_time <= flag_time + 1;
        end
    end



    

    
    
endmodule


 

