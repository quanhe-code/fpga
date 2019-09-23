/*
 * 自动售货机状态机-设计1
 */
IDLE：表示累计收到0.0元
S1  ：表示累计收到0.5元
S2  ：表示累计收到1.0元
S3  ：表示累计收到1.5元

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
            else if(idl2s2_start) begin
                state_n = S2;
            end
            else begin
                state_n = state_c;
            end
        end
        S1:begin
            if(s12s2_start)begin
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
            else if(s22idl_start)begin
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
assign idl2s1_start  = state_c==IDLE && din_vld && din==0;
assign idl2s2_start  = state_c==IDLE && din_vld && din==1;
assign s12s2_start   = state_c==S1    && din_vld && din==0;
assign s12s3_start   = state_c==S1    && din_vld && din==1;
assign s22s3_start   = state_c==S2    && din_vld && din==0;
assign s22idl_start   = state_c==S2    && din_vld && din==1;
assign s32idl_start   = state_c==S3    && din_vld;

//第四段：同步时序always模块，格式化描述寄存器输出（可有多个输出）
always  @(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        dout_vld <= 0;
    end
    else if(s22idl_start || s32idl_start)begin
        dout_vld <= 1;
    end
    else begin
        dout_vld <= 0;
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        dout <= 0;
    end
    else if(s32idl_start && din_vld && din==1)begin
        dout <= 1;
    end
    else 
        dout <= 0;
    end
end


