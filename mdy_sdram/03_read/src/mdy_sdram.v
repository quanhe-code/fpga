module mdy_sdram(
    clk             ,
    rst_n           ,
    
    wr_req          ,
    waddr           ,
    wdata           ,
    wr_ack          ,

    rd_req          ,
    raddr          ,
    rd_ack          ,
    rdata           ,
    rdata_vld       ,

    cke             ,
    cs_n            ,
    ras_n           ,
    cas_n           ,
    we_n            ,
    dqm             ,
    addr            ,
    bank            ,
    dq              
);

input                       clk;
input                       rst_n;           

input                       wr_req;
input   [21:0]              waddr;
input   [15:0]              wdata;
output                      wr_ack;

input                       rd_req;         
input   [21:0]              raddr;         
output                      rd_ack;          
output  [15:0]              rdata;           
output                      rdata_vld;       


output                      cke;             
output                      cs_n;            
output                      ras_n;           
output                      cas_n;           
output                      we_n;            
output                      dqm;             
output  [11:0]              addr;            
output  [1:0]               bank;            
inout   [15:0]              dq;              

// SDRAM命令表
parameter   SDRAM_CMD_LMR           = 4'd0;
parameter   SDRAM_CMD_REFRESH       = 4'd1;
parameter   SDRAM_CMD_PRECHARGE     = 4'd2;
parameter   SDRAM_CMD_ACTIVE        = 4'd3;
parameter   SDRAM_CMD_WRITE         = 4'd4;
parameter   SDRAM_CMD_READ          = 4'd5;
parameter   SDRAM_CMD_NOP           = 4'd7;

// 以100M工作时间计算
parameter   SDRAM_TIMING_STABLE     = 16'd20000;// 至少200us
parameter   SDRAM_TIMING_TRP        = 16'd200;
parameter   SDRAM_TIMING_TRC        = 16'd7;
parameter   SDRAM_TIMING_TMRD       = 16'd200;
parameter   SDRAM_TIMING_TRCD       = 16'd10;

parameter   SDRAM_REFRESH_PERIOD    = 16'd1262;// 自动刷新请求周期小于等于1562
parameter   SDRAM_CAS_LATENCY       = 3'd3;// 自动刷新请求周期   

reg                     wr_ack;
reg                     dqm;
reg     [11:0]          addr;
reg     [1:0]           bank;
reg     [15:0]          dq;

reg                     rd_ack;          
reg     [15:0]          rdata;           
reg                     rdata_vld;

reg     [3:0]           sdram_cmd;

reg     [15:0]          cnt_sub_phase;
wire                    add_cnt_sub_phase;
wire                    end_cnt_sub_phase;

reg     [3:0]           cnt_init_phase;
wire                    add_cnt_init_phase;
wire                    end_cnt_init_phase;

reg                     flag_init_done;

reg     [15:0]          cnt_refresh_req;
wire                    add_cnt_refresh_req;
wire                    end_cnt_refresh_req;

reg     [15:0]          x;
reg     [15:0]          y;

localparam              START     = 3'd0;
localparam              IDLE      = 3'd1;
localparam              REFRESH   = 3'd2;
localparam              READ      = 3'd3;
localparam              WRITE     = 3'd4;


reg     [2:0]           state_c;
reg     [2:0]           state_n;
wire                    start2idle_start;
wire                    idle2refresh_start;
wire                    idle2wr_start;
wire                    idle2rd_start;
wire                    refresh2idle_start;
wire                    rd2idle_start;
wire                    wr2idle_start;
reg                     ref_req;

wire    [15:0]          dq_in;
reg     [15:0]          dq_out;
reg                     dq_oen;
//四段式状态机

//第一段：同步时序always模块，格式化描述次态寄存器迁移到现态寄存器(不需更改）
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        state_c <= START;
    end
    else begin
        state_c <= state_n;
    end
end

//第二段：组合逻辑always模块，描述状态转移条件判断
always@(*)begin
    case(state_c)
        START:begin
            if(start2idle_start)begin
                state_n = IDLE;
            end
            else begin
                state_n = state_c;
            end
        end
        IDLE:begin
            if(idle2refresh_start)begin
                state_n = REFRESH;
            end
            else if(idle2rd_start)begin
                state_n = READ;
            end
            else if(idle2wr_start)begin
                state_n = WRITE;
            end
            else begin
                state_n = state_c;
            end
        end
        REFRESH:begin
            if(refresh2idle_start)begin
                state_n = IDLE;
            end
            else begin
                state_n = state_c;
            end
        end
        READ:begin
            if(rd2idle_start)begin
                state_n = IDLE;
            end
            else begin
                state_n = state_c;
            end
        end
        WRITE:begin
            if(wr2idle_start)begin
                state_n = IDLE;
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
assign start2idle_start = state_c==START && end_cnt_init_phase;
assign idle2refresh_start = state_c==IDLE&& ref_req;
assign idle2rd_start = state_c==IDLE&& rd_req;
assign idle2wr_start = state_c==IDLE&& wr_req;
assign refresh2idle_start = state_c==REFRESH && end_cnt_init_phase;
assign rd2idle_start = state_c==READ && end_cnt_init_phase;
assign wr2idle_start = state_c==WRITE && end_cnt_init_phase;



always @(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        cnt_sub_phase <= 0;
    end
    else if(add_cnt_sub_phase)begin
        if(end_cnt_sub_phase)
            cnt_sub_phase <= 0;
        else
            cnt_sub_phase <= cnt_sub_phase + 1'b1;
    end
end

assign add_cnt_sub_phase = (state_c == START || state_c == REFRESH || state_c == READ|| state_c == WRITE);
assign end_cnt_sub_phase = add_cnt_sub_phase && cnt_sub_phase== (y - 1'b1);

always @(posedge clk or negedge rst_n)begin 
    if(!rst_n)begin
        cnt_init_phase <= 0;
    end
    else if(add_cnt_init_phase)begin
        if(end_cnt_init_phase)
            cnt_init_phase <= 0;
        else
            cnt_init_phase <= cnt_init_phase + 1'b1;
    end
end

assign add_cnt_init_phase = end_cnt_sub_phase;
assign end_cnt_init_phase = add_cnt_init_phase && cnt_init_phase== (x - 1);

always  @(*)begin
    if(state_c == START) begin
        x = 4;
        if(cnt_init_phase == 4'd0) begin
            y = SDRAM_TIMING_STABLE;
        end
        else if(cnt_init_phase == 4'd1) begin
            y = SDRAM_TIMING_TRP;
        end
        else if(cnt_init_phase == 4'd2) begin
            y = SDRAM_TIMING_TRC * 8;
        end
        else begin
            y = SDRAM_TIMING_TMRD;
        end
    end
    else if(state_c == REFRESH) begin
        x = SDRAM_TIMING_TRC;
        y = 1;
    end
    else if(state_c == READ) begin
        x = 3;
        if(cnt_init_phase == 4'd0) begin
            y = SDRAM_TIMING_TRCD;
        end
        else if(cnt_init_phase == 4'd1) begin
            y = SDRAM_CAS_LATENCY + 256;
        end
        else begin
            y = SDRAM_TIMING_TRP;
        end
    end
    else begin
        x = 3;
        if(cnt_init_phase == 4'd0) begin
            y = SDRAM_TIMING_TRCD;
        end
        else if(cnt_init_phase == 4'd1) begin
            y = 256;
        end
        else begin
            y = SDRAM_TIMING_TRP;
        end
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        flag_init_done <= 1'b0;
    end
    else if(start2idle_start)begin
        flag_init_done <= 1'b1;
    end
end

// 产生自刷新请求
always @(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        cnt_refresh_req <= 0;
    end
    else if(add_cnt_refresh_req)begin
        if(end_cnt_refresh_req)
            cnt_refresh_req <= 0;
        else
            cnt_refresh_req <= cnt_refresh_req + 1;
    end
end

assign add_cnt_refresh_req = (flag_init_done == 1'b1);       
assign end_cnt_refresh_req = add_cnt_refresh_req && cnt_refresh_req== (SDRAM_REFRESH_PERIOD - 1);   

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        ref_req <= 1'b0;
    end
    else if(end_cnt_refresh_req)begin
        ref_req <= 1'b1;
    end
    else if(idle2refresh_start)begin
        ref_req <= 1'b0;
    end
end


// 第四段信号输出


// sdram侧接口
assign cke = 1'b1;

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        dqm <= 1'b1;
    end
    else if(state_c == START)begin
        dqm <= 1'b1;
    end
    else if(state_c == WRITE && state_c == READ) begin
        dqm <= 1'b0;
    end
    else begin
        dqm <= 1'b1;
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        sdram_cmd <= SDRAM_CMD_NOP;
    end
    else if(state_c == START && cnt_init_phase == 1 && add_cnt_sub_phase && cnt_sub_phase == 0)begin
        sdram_cmd <= SDRAM_CMD_PRECHARGE;
    end
    else if(state_c == START && cnt_init_phase == 2 
        && add_cnt_sub_phase && (cnt_sub_phase % SDRAM_TIMING_TRC) == 0)begin
        sdram_cmd <= SDRAM_CMD_REFRESH;
    end
    else if(state_c == START && cnt_init_phase == 3 && add_cnt_sub_phase && cnt_sub_phase == 0)begin
        sdram_cmd <= SDRAM_CMD_LMR;
    end
    else if(state_c == REFRESH && add_cnt_init_phase && (cnt_init_phase == (1 - 1))) begin
        sdram_cmd <= SDRAM_CMD_REFRESH;
    end
    else if(state_c == WRITE && cnt_init_phase == 0 && add_cnt_sub_phase && (cnt_sub_phase == (1 - 1))) begin
        sdram_cmd <= SDRAM_CMD_ACTIVE;
    end 
    else if(state_c == WRITE && cnt_init_phase == 1 && add_cnt_sub_phase && (cnt_sub_phase == (1 - 1))) begin
        sdram_cmd <= SDRAM_CMD_WRITE;
    end
    else if(state_c == WRITE && cnt_init_phase == 2 && add_cnt_sub_phase && (cnt_sub_phase == (1 - 1))) begin
        sdram_cmd <= SDRAM_CMD_PRECHARGE;
    end
    else if(state_c == READ && cnt_init_phase == 0 && add_cnt_sub_phase && (cnt_sub_phase == (1 - 1))) begin
        sdram_cmd <= SDRAM_CMD_ACTIVE;
    end 
    else if(state_c == READ && cnt_init_phase == 1 && add_cnt_sub_phase && (cnt_sub_phase == (1 - 1))) begin
        sdram_cmd <= SDRAM_CMD_READ;
    end
    else if(state_c == READ && cnt_init_phase == 2 && add_cnt_sub_phase && (cnt_sub_phase == (1 - 1))) begin
        sdram_cmd <= SDRAM_CMD_PRECHARGE;
    end
    else begin
        sdram_cmd <= SDRAM_CMD_NOP;
    end
end

assign we_n = sdram_cmd[0];
assign cas_n = sdram_cmd[1];
assign ras_n = sdram_cmd[2];
assign cs_n = sdram_cmd[3];

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        addr <= 12'd0;
    end
    else if(state_c == START && cnt_init_phase == 1 && add_cnt_sub_phase && cnt_sub_phase == 0)begin
        addr[10] <= 1'b1;//precharge all bank
    end
    else if(state_c == START && cnt_init_phase == 3 && add_cnt_sub_phase && cnt_sub_phase == 0)begin
        addr[11:0] <= {2'b00, 
                        1'b0, //write burst
                        2'b00,// Mode Register Set 
                        SDRAM_CAS_LATENCY, // CAS Latency 3 
                        1'b0, // Burst type Sequential
                        3'b111 // Full Page
                       };
    end
    else if(state_c == WRITE && cnt_init_phase == 0 && add_cnt_sub_phase && (cnt_sub_phase == (1 - 1))) begin
        addr <= waddr[19:8];
    end 
    else if(state_c == WRITE && cnt_init_phase == 1 && add_cnt_sub_phase && (cnt_sub_phase == (1 - 1))) begin
        addr[7:0] <= waddr[7:0];
    end
    else if(state_c == WRITE && cnt_init_phase == 2 && add_cnt_sub_phase && (cnt_sub_phase == (1 - 1))) begin
        addr[10] <= 1'b1;
    end
    else if(state_c == READ && cnt_init_phase == 0 && add_cnt_sub_phase && (cnt_sub_phase == (1 - 1))) begin
        addr <= raddr[19:8];
    end 
    else if(state_c == READ && cnt_init_phase == 1 && add_cnt_sub_phase && (cnt_sub_phase == (1 - 1))) begin
        addr[7:0] <= raddr[7:0];
    end
    else if(state_c == READ && cnt_init_phase == 2 && add_cnt_sub_phase && (cnt_sub_phase == (1 - 1))) begin
        addr[10] <= 1'b1;
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        bank <= 2'd0;
    end
    else if(state_c == START && cnt_init_phase == 3 && add_cnt_sub_phase && cnt_sub_phase == 0)begin
        bank <= 2'd0;
    end
    else if(state_c == WRITE && cnt_init_phase == 0 && add_cnt_sub_phase && (cnt_sub_phase == (1 - 1))) begin
        bank <= waddr[21:20];
    end
    else if(state_c == READ && cnt_init_phase == 0 && add_cnt_sub_phase && (cnt_sub_phase == (1 - 1))) begin
        bank <= waddr[21:20];
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        dq_out <= 16'd0;
    end
    else if(state_c == START)begin
        dq_out <= {16{1'bz}};
    end
    else if(state_c == WRITE && cnt_init_phase == 1) begin
        dq_out <= wdata;
    end
end

// 用户侧接口
always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        wr_ack <= 1'b0;
    end
    else if(state_c == WRITE && cnt_init_phase == 1 && add_cnt_sub_phase && (cnt_sub_phase == (1 - 1))) begin
        wr_ack <= 1'b1;
    end
    else begin
        wr_ack <= 1'b0;
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        rd_ack <= 1'b0;
    end
    else if(state_c == READ && cnt_init_phase == 1 && add_cnt_sub_phase && (cnt_sub_phase == (1 - 1)))begin
        rd_ack <= 1'b1;
    end
    else begin
        rd_ack <= 1'b0;
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        rdata <= {16{1'b0}};
    end
    else if(state_c == READ && cnt_init_phase == 1 && add_cnt_sub_phase 
        && (cnt_sub_phase >= (SDRAM_CAS_LATENCY - 1) || cnt_sub_phase < (SDRAM_CAS_LATENCY + 256 - 1)))begin
        rdata <= dq_in;
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        rdata_vld <= 1'b0;
    end
    else if(state_c == READ && cnt_init_phase == 1 && add_cnt_sub_phase 
        && (cnt_sub_phase >= (SDRAM_CAS_LATENCY - 1) || cnt_sub_phase < (SDRAM_CAS_LATENCY + 256 - 1)))begin
        rdata_vld <= 1'b1;
    end
    else begin
        rdata_vld <= 1'b0;
    end
end

assign dq_in = dq;
assign dq = dq_oen ? dq_out : {16{1'bz}};

endmodule

