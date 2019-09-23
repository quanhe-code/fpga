HEAD: 表示接收包文头状态
SEG: 表示接收段数
DATA: 表示接收数据
FCS: 表示接收检验码

//四段式状态机

//第一段：同步时序always模块，格式化描述次态寄存器迁移到现态寄存器(不需更改）
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        state_c <= HEAD;
    end
    else begin
        state_c <= state_n;
    end
end

//第二段：组合逻辑always模块，描述状态转移条件判断
always@(*)begin
    case(state_c)
        HEAD:begin
            if(head2seg_start)begin
                state_n = SEG;
            end
            else begin
                state_n = state_c;
            end
        end
        SEG:begin
            if(seg2data_start)begin
                state_n = DATA;
            end
            else begin
                state_n = state_c;
            end
        end
        DATA:begin
            if(data2fcs_start)begin
                state_n = FCS;
            end
            else begin
                state_n = state_c;
            end
        end
        FCS:begin
            if(fcs2head_start)begin
                state_n = HEAD;
            end
            else if(fcs2data_start)begin
                state_n = DATA;
            end
            else begin
                state_n = state_c;
            end
        end
        default:begin
            state_n = HEAD;
        end
    endcase
end
//第三段：设计转移条件
assign head2seg_start = state_c==HEAD && (din_t == 8'h55 && din == 8'hd5);
assign seg2data_start = state_c==SEG  && (1);
assign data2fcs_start = state_c==DATA && end_cnt0;
assign fcs2head_start = state_c==FCS  && end_cnt0 && cnt == (seg_num - 1);
assign fcs2data_start = state_c==FCS  && end_cnt0 && cnt != (seg_num - 1);


//第四段：同步时序always模块，格式化描述寄存器输出（可有多个输出）
always  @(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        dout <=1'b0      //初始化
    end
    else begin
        dout <= din;
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        dout_sop <= 0;
    end
    else if(state_c == DATA && add_cnt0 && cnt0 == (1 - 1) && cnt1 == (1 - 1))begin
        dout_sop <= 1;
    end
    else begin
        dout_dop <= 0;
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        dout_eop <= 0;
    end
    else if(state_c == FCS && end_cnt0 && cnt1==(seg_num - 1))begin
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
    else if(state_c == DATA)begin
        dout_vld <= 1;
    end
    else begin
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
        seg_num <= 0;
    end
    else if(state_c == SEG)begin
        seg_num <= din;
    end
    else begin
        seg_num <= seg_num;
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

assign add_cnt0 = (state_c == DATA && state_c == FCS);
assign end_cnt0 = add_cnt0 && cnt0== (x - 1);

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

assign add_cnt1 = end_cnt0 && state_c == FCS;
assign end_cnt1 = add_cnt1 && cnt1== (seg_num - 1);

always  @(*)begin
    if(state_c == DATA)
        x = cnt1 + 1;
    else begin
        x = 4;
    end
end

