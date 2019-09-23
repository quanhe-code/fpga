IDLE: ��ʾ��һ�׶�
S1: ��ʾ�ڶ��׶�
S3: ��ʾ�����׶�
S4: ��ʾ���Ľ׶�
//�Ķ�ʽ״̬��

//��һ�Σ�ͬ��ʱ��alwaysģ�飬��ʽ��������̬�Ĵ���Ǩ�Ƶ���̬�Ĵ���(������ģ�
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        state_c <= IDLE;
    end
    else begin
        state_c <= state_n;
    end
end

//�ڶ��Σ�����߼�alwaysģ�飬����״̬ת�������ж�
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
        S2:begin
            if(s22s3_start)begin
                state_n = S3;
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
//�����Σ����ת������
assign idl2s1_start  = state_c==IDLE && end_cnt1;
assign s12s2_start = state_c==S1    && end_cnt1;
assign s22s3_start  = state_c==S2    && end_cnt1;
assign s32idl_start  = state_c==S3    && end_cnt1;

//���ĶΣ�ͬ��ʱ��alwaysģ�飬��ʽ�������Ĵ�����������ж�������
always  @(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        dout <=1'b0      //��ʼ��
    end
    else if(add_cnt0 &&��cnt0 == (x - 1 - 1))begin
        dout <= 1'b1;
    end
    else if(end_cnt0) begin
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

assign add_cnt0 = (state_c == S1 || state_c == S2 || state_c == S3);
assign end_cnt0 = add_cnt0 && cnt0== (x - 1);
always @(posedge clk or negedge rst_n)begin if(!rst_n)begin
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
assign end_cnt1 = add_cnt1 && cnt1== (y - 1);

always  @(*)begin
    if(state_c == IDLE)begin
        x = 2;
        y = 1000;
    end
    else if(state_c == S1)begin
        x = 4;
        y = 1000;
    end
    else if(state_c == S2)begin
        x = 10;
        y = 1000;
    end
    else if(state_c == S3)begin
        x = 20;
        y = 1000;
    end
end

