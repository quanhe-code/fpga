IDLE: 表示未收到en1、en2、en3信号
S1: 表示收到en1信号
S2: 表示收到en2信号
S3: 表示收到en3信号

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
            else if(idl2s2_start)begin
                state_n = S2;
            end
            else if(idl2s3_start)begin
                state_n = S3;
            end
            else begin
                state_n = state_c;
            end
        end
        S1:begin
            if(s12idl_start)begin
                state_n = IDLE;
            end
            else begin
                state_n = state_c;
            end
        end
        S2:begin
            if(s22idl_start)begin
                state_n = IDLE;
            end
            else begin
                state_n = state_c;
            end
        end
        S3:begin
            if(s32idl_start)begin
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
assign idl2s1_start  = state_c==IDLE && (en1 == 1 && en2 == 0 && en3 == 0);
assign idl2s2_start  = state_c==IDLE && (en1 == 0 && en2 == 1 && en3 == 0);
assign idl2s3_start  = state_c==IDLE && (en1 == 0 && en2 == 0 && en3 == 1);
assign s12idl_start = state_c==S1    && end_cnt;
assign s22idl_start = state_c==S2    && end_cnt;
assign s32idl_start = state_c==S3    && end_cnt;

//第四段：同步时序always模块，格式化描述寄存器输出（可有多个输出）
always  @(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        dout <=1'b0      //初始化
    end
    else if(add_cnt && cnt == (x - 1))begin
        dout <= z;
    end
    else if(end_cnt)begin 
        dout <= 1'b0;
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

assign add_cnt = (state_c == S1 || state_c == S2 || state_c == S3);       
assign end_cnt = add_cnt && cnt== (x + y - 1);   

always  @(*)begin
    if(state_c == S1) begin
        x = 1;
        y = 1;
        z = 2;
    end
    else if(state_c == S2) begin
        x = 1;
        y = 3;
        z = 4;
    end
    else begin
        x = 5;
        y = 2;
        z = 1;
    end
end

