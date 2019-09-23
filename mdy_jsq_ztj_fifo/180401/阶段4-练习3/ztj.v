IDLE:表示接收包文头状态
S1:表示接收包文类型
S2:表示接收数据长度
S3:表示接收数据
S4:表示接收检验码

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
            else if(s12s3_start)begin
                state_n = S3;
            end
            else if(s12s4_start)begin
                state_n = S4;
            end
            else if(s12idl_start)begin
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
            else begin
                state_n = state_c;
            end
        end
        S4:begin
            if(s42idl_start)begin
                state_n = IDLE;
            end
            else
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
assign s12s2_start = state_c==S1    && (din == 8'h00);
assign s12s3_start = state_c==S1    && (din == 8'h01);
assign s12s4_start = state_c==S1    && (din == 8'h02);
assign s12sidl_start = state_c==S1    && (din!=8'h00 && din!=8'h01 && din!=8'h02);
assign s22s3_start  = state_c==S2    && end_cnt;
assign s32s4_start  = state_c==S3    && end_cnt;
assign s42idl_start  = state_c==IDLE    && end_cnt;

//第四段：同步时序always模块，格式化描述寄存器输出（可有多个输出）
always  @(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        dout <=8'b0      //初始化
    end
    else if(state_c == S3 || state_c == S4)begin
        dout <= din;
    end
    else begin
        dout <= 8'b0;
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        dout_sop <= 0;
    end
    else if((type == 8'h00 || type == 8'h01) && state_c == S3 && add_cnt && cnt = 1 - 1)begin
        dout_sop <= 1;
    end
    else if(type == 8'h02 && state_c == S4 add_cnt && cnt = 1 - 1)begin
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
    else if(s42idle_start)begin
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
    else if((type == 8'h00 || type == 8'h01) && state_c == S3 && add_cnt && cnt = 1 - 1) begin
        dout_vld <= 1;
    end
    else if(type == 8'h02 && state_c == S4 add_cnt && cnt = 1 - 1)begin
        dout_vld <= 1;
    end
    else if(state_c == IDLE)begin
        dout_vld <= 0;
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
        date_len <= 0;
    end
    else if(s22s3_start)begin
        data_len <= {din_t,din}
    end
    else if(s12s3_start)begin
        data_len <= 64;
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        fcs_len <= 0;
    end
    else if(s32s4_start)begin
        fcs_len <= 4;
    end
    else if(s12s4_start)begin
        fcs_len <= 2;
    end
end

//计数器
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

assign add_cnt = (state_c == S2 || state_c == S3 || state_c == S4);       
assign end_cnt = add_cnt && cnt== (x - 1);   

always  @(*)begin
    if(state_c == S2)
        x = 2;
    else if(state_c == S3)
        x = date_len;
    else 
        x = fcs_len;
end

