//四段式状态机
IDLE: 表示dout输出0
S1：表示dout输出1
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
assign idl2s1_start  = state_c==IDLE && add_cnt0 && cnt0 = x - 1;
assign s12s2_start = state_c==S1    && end_cnt0;

//第四段：同步时序always模块，格式化描述寄存器输出（可有多个输出）
always  @(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        dout <=1'b0      //初始化
    end
    else if(state_c==S1)begin
        dout <= 1'b1;
    end
    else begin
        dout <= 1'b0;
    end
end



always @(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        cnt0 <= 0;
    end
    else if(add_cnt0)begin
        if(end_cnt0)
            cnt0 <= 0;
        else
            cnt0 <= cnt0 + 1;
    end
end

assign add_cnt0 = (flag_add == 1);
assign end_cnt0 = add_cnt0 && cnt0== (x + y - 1);

always @(posedge clk or negedge rst_n)begin 
    if(!rst_n)begin
        cnt1 <= 0;
    end
    else if(add_cnt1)begin
        if(end_cnt1)
            cnt1 <= 0;
        else
            cnt1 <= cnt1 + 1;
    end
end

assign add_cnt1 = end_cnt0;
assign end_cnt1 = add_cnt1 && cnt1== (z - 1);

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        flag_add <= 0;
    end
    else if (en1 == 1 || en2 == 1 || en3 == 1) begin
        flag_add <= 1;  
    end
    else if (end_cnt1) begin
        flag_add <= 0;
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        flag_sel <= 2'b00;
    end
    else if(en1)begin
        flag_sel <= 2'b00;
    end
    else if(en2)begin
        flag_sel <= 2'b01;
    end
    else if(en3)begin
        flag_sel <= 2'b10;
    end
end

always  @(*)begin
    if(flag_sel == 2'b00) begin
        x = 1;
        y = 1;
        z = 3;
    end
    else if(flag_sel == 2'b01) begin
        x = 1;
        y = 4;
        z = 4;
    end
    else begin
        x = 3;
        y = 4;
        z = 8;
    end
end

