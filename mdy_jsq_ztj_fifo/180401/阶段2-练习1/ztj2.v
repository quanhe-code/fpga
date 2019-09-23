IDLE: ��ʾδ�յ�en1��en2��en3�ź�
S1�� ��ʾ�յ�en1��״̬
S2����ʾ�յ�en2��״̬
S3: ��ʾ�յ�en3��״̬

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
            else if(idl2s2_start) begin
                state_n = S2;
            end
            else if(idl2s3_start) begin
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
            if(s32idl_start) begin
                state_n = IDLE;
            end
            else begin
                state_n = state_c
            end
        end
        default:begin
            state_n = IDLE;
        end
    endcase
end
//�����Σ����ת������
assign idl2s1_start  = state_c==IDLE && (en1 == 1 && en2 == 0 && en3 == 0);
assign idl2s2_start  = state_c==IDLE && (en2 == 1 && en1 == 0 && en3 ==0);
assign idl2s3_start  = state_c==IDLE && (en3 == 1 && en1 == 0 && en2 == 0);
assign s12idl_start = state_c==S1    && end_cnt1;
assign s22idl_start = state_c==S2 && end_cnt1;
assign s32idl_start = state_c==S3 && end_cnt1;

//���ĶΣ�ͬ��ʱ��alwaysģ�飬��ʽ�������Ĵ�����������ж�������
always  @(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        dout <=1'b0      //��ʼ��
    end
    else if(add_cnt0 && cnt0 == x - 1)begin
        dout <= 1'b1;
    end
    else if(end_cnt0)begin
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

always  @(*)begin
    if(state_c == S1) begin
        x = 1;
        y = 1;
        z = 3;
    end
    else if(state_c == S2) begin
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

