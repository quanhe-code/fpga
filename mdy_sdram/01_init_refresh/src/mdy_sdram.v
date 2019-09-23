module mdy_sdram(
    clk             ,
    rst_n           ,
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
output                      cke;             
output                      cs_n;            
output                      ras_n;           
output                      cas_n;           
output                      we_n;            
output                      dqm;             
output  [11:0]              addr;            
output  [1:0]               bank;            
output  [15:0]              dq;              

// SDRAM命令表
parameter   SDRAM_CMD_LMR           = 4'd0;
parameter   SDRAM_CMD_REFRESH       = 4'd1;
parameter   SDRAM_CMD_PRECHARGE     = 4'd2;
parameter   SDRAM_CMD_ACTIVE        = 4'd3;
parameter   SDRAM_CMD_WRITE         = 4'd4;
parameter   SDRAM_CMD_READ          = 4'd5;
parameter   SDRAM_CMD_NOP           = 4'd7;

parameter   SDRAM_TIMING_STABLE     = 16'd200;
parameter   SDRAM_TIMING_TRP        = 16'd200;
parameter   SDRAM_TIMING_TRC        = 16'd2;
parameter   SDRAM_TIMING_TMRD       = 16'd200;

parameter   SDRAM_REFRESH_PERIOD    = 16'd60;

reg                     dqm;
reg     [11:0]          addr;
reg     [1:0]           bank;
reg     [15:0]          dq;

reg     [3:0]           sdram_cmd;

reg     [15:0]          cnt_sub_phase;
wire                    add_cnt_sub_phase;
wire                    end_cnt_sub_phase;

reg     [3:0]           cnt_init_phase;
wire                    add_cnt_init_phase;
wire                    end_cnt_init_phase;

reg                     flag_init;

reg     [15:0]          cnt_refresh_req;
wire                    add_cnt_refresh_req;
wire                    end_cnt_refresh_req;

reg     [7:0]           cnt_refresh;
wire                    add_cnt_refresh;
wire                    end_cnt_refresh;

reg                     flag_refresh;
reg     [15:0]          x;


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

assign add_cnt_sub_phase = (flag_init == 1'b0);
assign end_cnt_sub_phase = add_cnt_sub_phase && cnt_sub_phase== (x - 1'b1);

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
assign end_cnt_init_phase = add_cnt_init_phase && cnt_init_phase== (4 - 1);

always  @(*)begin
    if(cnt_init_phase == 4'd0) begin
        x = SDRAM_TIMING_STABLE;
    end
    else if(cnt_init_phase == 4'd1) begin
        x = SDRAM_TIMING_TRP;
    end
    else if(cnt_init_phase == 4'd2) begin
        x = SDRAM_TIMING_TRC * 8;
    end
    else begin
        x = SDRAM_TIMING_TMRD;
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        flag_init <= 1'b0;
    end
    else if(end_cnt_init_phase)begin
        flag_init <= 1'b1;
    end
end


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

assign add_cnt_refresh_req = (flag_init == 1'b1);       
assign end_cnt_refresh_req = add_cnt_refresh_req && cnt_refresh_req== (SDRAM_REFRESH_PERIOD - 1);   

always @(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        cnt_refresh <= 0;
    end
    else if(add_cnt_refresh)begin
        if(end_cnt_refresh)
            cnt_refresh <= 0;
        else
            cnt_refresh <= cnt_refresh + 1;
    end
end

assign add_cnt_refresh = (flag_refresh == 1'b1);       
assign end_cnt_refresh = add_cnt_refresh && cnt_refresh== (SDRAM_TIMING_TRC - 1);   

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        flag_refresh <= 1'b0;
    end
    else if(end_cnt_refresh_req)begin
        flag_refresh <= 1'b1;
    end
    else if(end_cnt_refresh)begin
        flag_refresh <= 1'b0;
    end
end

assign cke = 1'b1;

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        sdram_cmd <= SDRAM_CMD_NOP;
    end
    else if(cnt_init_phase == 1 && add_cnt_sub_phase && cnt_sub_phase == 0)begin
        sdram_cmd <= SDRAM_CMD_PRECHARGE;
    end
    else if(cnt_init_phase == 2 && add_cnt_sub_phase && (cnt_sub_phase % SDRAM_TIMING_TRC) == 0)begin
        sdram_cmd <= SDRAM_CMD_REFRESH;
    end
    else if(cnt_init_phase == 3 && add_cnt_sub_phase && cnt_sub_phase == 0)begin
        sdram_cmd <= SDRAM_CMD_LMR;
    end
    else if(add_cnt_refresh && (cnt_refresh == (1 - 1)))
        sdram_cmd <= SDRAM_CMD_REFRESH;
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
        dqm <= 1'b0;
    end
    else if(flag_init == 1'b0)begin
        dqm <= 1'b1;
    end
    else if(flag_init == 1'b1)begin
        dqm <= 1'b0;
    end
end


always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        addr <= 12'd0;
    end
    else if(cnt_init_phase == 1 && add_cnt_sub_phase && cnt_sub_phase == 0)begin
        addr[10] <= 1'b1;//precharge all bank
    end
    else if(cnt_init_phase == 3 && add_cnt_sub_phase && cnt_sub_phase == 0)begin
        addr[11:0] <= {2'b00, 
                        1'b0, //write burst
                        2'b00,// Mode Register Set 
                        3'b011, // CAS Latency 3 
                        1'b0, // Burst type Sequential
                        3'b111 // Full Page
                       };
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        bank <= 2'd0;
    end
    else if(cnt_init_phase == 3 && add_cnt_sub_phase && cnt_sub_phase == 0)begin
        bank <= 2'd0;
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        dq <= 16'd0;
    end
    else if(flag_init == 1'b0)begin
        dq <= 16'bzzzzzzzzzzzzzzzz;
    end
end

endmodule

