/*
 * 自动售货机状态机--设计2
 */

S0:表示收到0美元
S1:表示收到5美元
S2:表示收到10美元
S3:表示收到15美元
S4:表示收到20美元


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
        S0:begin
            if(s02s1_start)begin
                state_n = S1;
            end
            else if(s02s2_start) begin
                state_n = S2;
            end
            else begin
                state_n = state_c;
            end
        end
        S1:begin
            if(s12s0_start)begin
                state_n = S0;
            end
            else if(s12s2_start)begin
                state_n = S2;
            end
            else if(s12s3_start)begin
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
            else if(s22s4_start)begin
                state_n = S4;
            end
            else if(s22s0_start)begin
                state_n = S0;
            end
            else begin
                state_n = state_c;
            end
        end
        S3:begin
            if(s32s4_start)begin
                state_n = S4;
            end
            else if (s32s0_start)begin
                state_n = S0;
            end
            else begin
                state_n = state_c
            end
        end
        S4:begin
            if(s42s0_start)begin
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
assign s02s1_start  = state_c== S0 && din_vld && din == 0;
assign s02s2_start  = state_c== S0 && din_vld && din == 1;
assign s12s2_start = state_c==S1    && din_vld && din == 0;
assign s12s3_start = state_c==S1    && din_vld && din == 1;
assign s12s0_start = state_c==S1    && din_vld && din == 2;
assign s22s3_start  = state_c==S2    && din_vld && din == 0;
assign s22s4_start  = state_c==S2    && din_vld && din == 1;
assign s22s0_start  = state_c==S2    && din_vld && din == 2;
assign s32s4_start  = state_c==S3    && din_vld && din == 0;
assign s32s0_start  = state_c==S3    && (din_vld && din == 1) || (din_vld && din == 2);
assign s42s0_start  = state_c==S4    && din_vld;
//第四段：同步时序always模块，格式化描述寄存器输出（可有多个输出）
always  @(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        dout_vld <= 0;
    end
    else if((state_c==S0 && din_vld && din==2) || s12s0_start  
                || s22s0_start || s32s0_start || s42s0_start)begin
        dout_vld <= 1'b1;
    end
    else begin
        dout_vld <= 1'b0;
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        dout <= 0;
    end
    else if(s12s0_start || (s42s0_start && din_vld && din==1))begin
        dout <= 5;
    end
    else if(s22s0_start)begin
        dout <= 10;
    end
    else if(s32s0_start && din_vld && din==2)begin
        dout <= 15;
    end
    else if (s42s0_start && din_vld && din==2) begin
        dout <= 20;
    end
    else begin
        dout <= 0;
    end 
end


