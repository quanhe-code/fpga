IDLE: 表示未收到包文头相关数据
S1: 表示收到包文头的第一个字节8'h55
S2: 表示收到包文头的第二个字节8'hd5
S3: 表示收到包文类型
S4: 表示收到包文长度
S5: 表示收到包文数据
S6: 表示收到包文命令数据
S7: 表示收到检验码

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
            else if (s12idl_start) begin
                state_n = IDLE;
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
            else if(s32s6_start)begin
                state_n = S6;
            end
            else begin
                state_n = state_c;
            end
        end
        S4:begin
            if(s42s5_start) begin
                state_n = S5;
            end
            else begin
                state_n = state_c;
            end
        end
        S5:begin
            if(s52s6_start) begin
                state_n = S6;
            end
            else begin
                state_n = state_c;
            end
        end
        S6:begin
            if(s62s7_start)begin
                state_n = S7;
            end
            else begin
                state_n = state_c;
            end
        end
        S7:begin
            if(s72idl_start)begin
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
assign idl2s1_start  = state_c==IDLE && (din == 8'h55);
assign s12s2_start = state_c==S1    && (din == 8'hd5);
assign s12idl_start = state_c==S1    && (din != 8'hd5);
assign s22s3_start  = state_c==S2    && (1);
assign s32s4_start = state_c==S3     && (din != 8'h00); 
assign s32s6_start = state_c==S3     && (din == 8'h00); 
assign s42s5_start = state_c==S4     &&  end_cnt; 
assign s52s6_start = state_c==S5     &&  end_cnt; 
assign s62s7_start = state_c==S6     &&  end_cnt; 
assign s72idl_start = state_c==S7     &&  end_cnt; 

//第四段：同步时序always模块，格式化描述寄存器输出（可有多个输出）
always  @(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        dout <=8'b0      //初始化
    end
    else if(state_c==S3 || state_c == S4 || state_c == S5 || state_c == S6 || state_c == S7)begin
        dout <= din;
    end
    else begin
        dout <= 8'b0;
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        dout_vld <= 1'b0;
    end
    else if(state_c == S3)
        dout_vld <= 1;
    end
    else if(state_c == S7 && end_cnt)begin
        dout_vld <= 0;
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        dout_sop <= 0;
    end
    else if (state_c == S3)begin
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
    else if(state_c == S7 && add_cnt && cnt = x - 1 -1)begin
        dout_eop <= 1;
    end
    else begin
        dout_eop <= 0;
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        data_length[15:0] <= 0;
    end
    else if (state_c == S4 && add_cnt && cnt = (1 -1))begin
        data_length[15:8] <= din;
    end
    else if(state_c == S4 && add_cnt && cnt = (2 - 1))begin
        data_length[7:0] <= din;
    end    
end

// 计数器部分
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

assign add_cnt = (state_c == S4 || state_c == S5 || state_c == S6 || state_c == S7);       
assign end_cnt = add_cnt && cnt== (x - 1);   

always  @(*)begin
    if(state_c == s4)
        x = 2;
    else if(state_c == S5)
        x = data_length;
    else if (state_c == S6)
        x = 64;
    else 
        x = 4;
end

