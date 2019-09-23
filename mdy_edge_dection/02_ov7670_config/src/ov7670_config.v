module ov7670_config(
    clk        ,
    rst_n      ,
    config_en  ,
    rdy        ,
    rdata      ,
    rdata_vld  ,
    wdata      ,
    addr       ,
    wr_en	   ,
	rd_en      ,
    cmos_en    , 
    pwdn         
    );

    //参数定义
    parameter      DATA_W  =     8;

    localparam      IDLE = 3'd0;
    localparam      S1 = 3'd1;
    localparam      S2 = 3'd2;  // nop
    localparam      S3 = 3'd3;  //write
    localparam      S4 = 3'd4;  // read
    
    //输入信号定义
    input               clk      ;   //50Mhz
    input               rst_n    ;
    input               config_en;
    input               rdy      ;
    input [DATA_W-1:0]  rdata    ;
    input               rdata_vld;

    //输出信号定义
    output reg  [DATA_W-1:0]    wdata    ;
    output reg  [DATA_W-1:0]    addr     ;
    
    output reg                  cmos_en  ;
    output reg                  wr_en    ;
    output reg                  rd_en    ;
    output                      pwdn     ;

    reg  [31:0]         reg_cnt;
    wire                add_cnt;
    wire                end_cnt;

    reg  [17:0]         add_wdata;

    reg  [3:0]          state_c;
    reg  [3:0]          state_n;
    wire                idl2s1_start; 
    wire                s12idl_start; 
    wire                s12s2_start; 
    wire                s12s3_start; 
    wire                s12s4_start; 
    wire                s12s5_start; 
    wire                s22s1_start; 
    wire                s32s1_start; 
    wire                s32s4_start; 
    wire                s42s1_start; 

    parameter      REG_NUM =       68;
    always@(*) begin
	    case(reg_cnt)
		    0   : add_wdata = {2'b11,16'h1280};	
	        1   : add_wdata = {2'b11,16'h3d03};	
	        2   : add_wdata = {2'b11,16'h1502}; 
	        3   : add_wdata = {2'b11,16'h1722};	
	        4   : add_wdata = {2'b11,16'h18a4};	
	        5   : add_wdata = {2'b11,16'h1907};	
	        6   : add_wdata = {2'b11,16'h1af0};	
	        7   : add_wdata = {2'b11,16'h3200};	
	        8   : add_wdata = {2'b11,16'h29A0};	
	        9   : add_wdata = {2'b11,16'h2CF0};	
	        10  : add_wdata = {2'b11,16'h0d41};	
	        11  : add_wdata = {2'b11,16'h1101};	
	        12  : add_wdata = {2'b11,16'h1206};	
	        13  : add_wdata = {2'b11,16'h0c10};	
	        14  : add_wdata = {2'b11,16'h427f};	
	        15  : add_wdata = {2'b11,16'h4d09};	
	        16  : add_wdata = {2'b11,16'h63f0};	
	        17  : add_wdata = {2'b11,16'h64ff};	
	        18  : add_wdata = {2'b11,16'h6500};	
	        19  : add_wdata = {2'b11,16'h6600};	
	        20  : add_wdata = {2'b11,16'h6700};
	        21  : add_wdata = {2'b11,16'h13ff};
	        22  : add_wdata = {2'b11,16'h0fc5};
	        23  : add_wdata = {2'b11,16'h1411};
	        24  : add_wdata = {2'b11,16'h2298};
	        25  : add_wdata = {2'b11,16'h2303};
	        26  : add_wdata = {2'b11,16'h2440};
	        27  : add_wdata = {2'b11,16'h2530};
	        28  : add_wdata = {2'b11,16'h26a1};
	        29  : add_wdata = {2'b11,16'h2b9e};
	        30  : add_wdata = {2'b11,16'h6baa};
	        31  : add_wdata = {2'b11,16'h13ff};
	        32  : add_wdata = {2'b11,16'h900a};
	        33  : add_wdata = {2'b11,16'h9101};
	        34  : add_wdata = {2'b11,16'h9201};
	        35  : add_wdata = {2'b11,16'h9301};
	        36  : add_wdata = {2'b11,16'h945f};
	        37  : add_wdata = {2'b11,16'h9553};//
	        38  : add_wdata = {2'b11,16'h9611};
	        39  : add_wdata = {2'b11,16'h971a};
	        40  : add_wdata = {2'b11,16'h983d}; 
	        41  : add_wdata = {2'b11,16'h995a};
	        42  : add_wdata = {2'b11,16'h9a1e};
	        43  : add_wdata = {2'b11,16'h9b3f};
	        44  : add_wdata = {2'b11,16'h9c25};
	        45  : add_wdata = {2'b11,16'h9e81};
	        46  : add_wdata = {2'b11,16'ha606};
	        47  : add_wdata = {2'b11,16'ha765};
	        48  : add_wdata = {2'b11,16'ha865};
	        49  : add_wdata = {2'b11,16'ha980};
	        50  : add_wdata = {2'b11,16'haa80};
	        51  : add_wdata = {2'b11,16'h7e0c};
	        52  : add_wdata = {2'b11,16'h7f16};
	        53  : add_wdata = {2'b11,16'h802a};
	        54  : add_wdata = {2'b11,16'h814e};  
	        55  : add_wdata = {2'b11,16'h8261};
	        56  : add_wdata = {2'b11,16'h836f};
	        57  : add_wdata = {2'b11,16'h847b};
	        58  : add_wdata = {2'b11,16'h8586};
	        59  : add_wdata = {2'b11,16'h868e};
	        60  : add_wdata = {2'b11,16'h8797};
	        61  : add_wdata = {2'b11,16'h88a4};
	        62  : add_wdata = {2'b11,16'h89af};
	        63  : add_wdata = {2'b11,16'h8ac5};
	        64  : add_wdata = {2'b11,16'h8bd7};
	        65  : add_wdata = {2'b11,16'h8ce8};
	        66  : add_wdata = {2'b11,16'h8d20};
	        67  : add_wdata = {2'b11,16'h0e65};
	    default : add_wdata = 0;
	    endcase
	end
		
	
    //四段式状态机

    //第一段：同步时序always模块，格式化描述次态寄存器迁移到现态寄存器(不需更改）
    always@(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            state_c <= IDLE;
        end
        else begin
            state_c <= state_n;
        end
    end

    //第二段：组合逻辑always模块，描述状态转移条件判断
    always@(*)begin
        case(state_c)
            IDLE:begin
                if(idl2s1_start)begin
                    state_n = S1;
                end                
                else begin
                    state_n = state_c;
                end
            end
            S1:begin
                if(s12idl_start)begin
                    state_n = IDLE;
                end
                else if(s12s2_start)begin
                    state_n = S2;
                end
                else if(s12s3_start)begin
                    state_n = S3;
                end
                else if(s12s4_start)begin
                    state_n = S4;
                end
                else begin
                    state_n = state_c;
                end
            end
            S2:begin
                if(s22s1_start)begin
                    state_n = S1;
                end
                else begin
                    state_n = state_c;
                end
            end
            S3:begin
                if(s32s1_start)begin
                    state_n = S1;
                end
                else if(s32s4_start)begin
                    state_n = S4;
                end
                else begin
                    state_n = state_c;
                end
            end
            S4:begin
                if(s42s1_start)begin
                    state_n = S1;
                end
                else begin
                    state_n = state_c;
                end 
            end
            default:begin
                state_n = IDLE;
            end
        endcase
    end
    //第三段：设计转移条件
    assign idl2s1_start  = state_c==IDLE && (config_en == 1'b1);
    assign s12idl_start  = state_c==S1 && (cmos_en == 1'b1);
    assign s12s2_start  = state_c==S1 && (cmos_en==1'b0 && rdy == 1'b1 && add_wdata[17:16] == 2'b00 );
    assign s12s3_start  = state_c==S1 && (cmos_en==1'b0 && rdy == 1'b1 
                                && (add_wdata[17:16] == 2'b01 || add_wdata[17:16] == 2'b11));
    assign s12s4_start  = state_c==S1 && (cmos_en==1'b0 && rdy == 1'b1 && add_wdata[17:16] == 2'b10 );
    assign s22s1_start  = state_c==S2    && (rst_n == 1'b1);
    assign s32s1_start  = state_c==S3    && (add_wdata[17:16] == 2'b10 && wr_en == 1'b1);
    assign s32s4_start  = state_c==S3    && (add_wdata[17:16] == 2'b11 && rdy == 1'b1);
    assign s42s1_start  = state_c==S4    && (rd_en == 1'b1);

    //第四段：同步时序always模块，格式化描述寄存器输出（可有多个输出）
    always @(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            reg_cnt <= 0;
        end
        else if(add_cnt)begin
            if(end_cnt)
                reg_cnt <= 0;
            else
                reg_cnt <= reg_cnt + 1;
        end
    end

    assign add_cnt = (s22s1_start | s32s1_start | s42s1_start);       
    assign end_cnt = add_cnt && reg_cnt== (REG_NUM - 1);   

    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            addr <= {DATA_W{1'b1}};
        end
        else if(s12s3_start | s12s4_start)begin
            addr <= add_wdata[15:8];
        end
    end

    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            wr_en <= 1'b0;
        end
        else if(s12s3_start)begin
            wr_en <= 1'b1;
        end
        else begin
            wr_en <= 1'b0;
        end
    end

    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            wdata <= {DATA_W{1'b0}};
        end
        else if(s12s3_start)begin
            wdata <= add_wdata[7:0];
        end
    end

    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            rd_en <= 1'b0;
        end
        else if(s12s4_start || s32s4_start)begin
            rd_en <= 1'b1;
        end
        else begin
            rd_en <= 1'b0;
        end
    end

    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            cmos_en <= 1'b0;
        end
        else if(idl2s1_start)begin
            cmos_en <= 1'b0;
        end
        else if(end_cnt)begin
            cmos_en <= 1'b1;
        end
    end

    assign pwdn = 1'b0;

endmodule

