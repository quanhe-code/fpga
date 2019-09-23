IDLE: 检测包文的头
S1: 接收包文的类型
S2: 接收数据的长度
S3: 接收数据或者命令
S4: 接收检验码

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
            if(s12s2_start)begin
                state_n = S2;
            end
            else if (s12s3_start)begin
                state_n = S3;
            end
            else begin
                state_n = state_c;
            end
        end
        S2:begin
            if(s22s3_start)begin
                state_n = S3;
            end
            else begin
                state_n = state_c;
            end
        end
        S3:begin
            if(s32s4_start)begin
                state_n = S4;
            end
            else begin
                state_n = state_c;
            end
        end
        S4:begin
            if(s42idl_start)begin
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
assign idl2s1_start  = state_c==IDLE && (din_t == 8'h55 && din == 8'hd5);
assign s12s2_start = state_c==S1    && (din != 0);
assign s12s3_start = state_c==S1    && (din == 0);
assign s22s3_start  = state_c==S2    && end_cnt;
assign s32s4_start  = state_c==S3    && end_cnt;
assign s42sidl_start  = state_c==S4    && end_cnt;

//第四段：同步时序always模块，格式化描述寄存器输出（可有多个输出）
always  @(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        dout <=1'b0      //初始化
    end
    else if(state_c != IDLE)begin
        dout <= din;
    end
    else begin
        dout <= 0;
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        dout_sop <= 0;
    end
    else if(state_c == S1) begin
        dout_sop <= 1;
    end
    else begin
        dout_sop <= 0;
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        dout_eop <= 0;
    end
    else if(state_c == S4 && add_cnt && cnt = x - 1) begin
        dout_eop <= 1;
    end
    else begin
        dout_eop <= 0;
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        dout_vld <= 0;
    end
    else if(idl2s1_start)begin
        dout_vld <= 1;
    end
    else if(state_c == S4 && add_cnt && cnt = x -1)begin
        dout_vlkd <= 0;
    end
end


always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        din_t <= 0;
    end
    else begin
        din_t <= din;
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        len <= 0;
    end
    else if(s22s3_start) begin
        len <= {din, din_t};
    end
    else if(s12s3_start)begin
        len <= 64;
    end
end

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

assign add_cnt = (state_c == S2 && state_c == S3 && state_c == S4);       
assign end_cnt = add_cnt && cnt== (x - 1);   

always  @(*)begin
    if(state_c == S2)
        x = 2;
    else if(state_c == S3)
        x = len
    else
        x = 4;
end

