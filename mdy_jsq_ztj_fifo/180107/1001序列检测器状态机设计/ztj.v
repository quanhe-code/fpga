/*
 * 1001序列检测器状态机设计
 */

S0:表示未收到有效码
S1：表示收到1位有效码1
S2：表示收到2位有效码10
S3：表示收到3位有效码100

//四段式状态机

//第一段：同步时序always模块，格式化描述次态寄存器迁移到现态寄存器(不需更改）
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        state_c <= S0;
    end
    else begin
        state_c <= state_n;
    end
end

//第二段：组合逻辑always模块，描述状态转移条件判断
always@(*)begin
    case(state_c)
        S0:begin
            if(s02s1_start)begin
                state_n = S1;
            end
            else if (s02s0_start)begin
                state_n = S0;
            end
            else begin
                state_n = state_c;
            end
        end
        S1:begin
            if(s12s2_start)begin
                state_n = S2;
            end
            else if(s12s1_start)begin
                state_n = S1;
            end
            else begin
                state_n = state_c;
            end
        end
        S2:begin
            if(s22s3_start)begin
                state_n = S3;
            end
            else if(s22s1_start)begin
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
            else if(s32s0_start)begin
                state_n = S0;
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
assign s02s1_start  = state_c==S0 && din==1;
assign s02s0_start  = state_c==S0 && din==0;
assign s12s2_start = state_c==S1    &&din==0;
assign s12s1_start = state_c==S1    &&din==1;
assign s22s3_start  = state_c==S2    && din==0;
assign s22s1_start  = state_c==S2    && din==1;
assign s32s1_start  = state_c==S3    && din==1;
assign s32s0_start  = state_c==S3    && din==0;

//第四段：同步时序always模块，格式化描述寄存器输出（可有多个输出）
always  @(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        dout <= 0;
    end
    else if(s32s1_start)begin
        dout <= 1;
    end
    else begin
        dout <= 0;
    end
end

