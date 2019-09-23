IDLE: ��ʾδ�յ�en1��en2��en3�ź�
S1: ��ʾ�յ�en1�ź�
S2: ��ʾ�յ�en2�ź�
S3: ��ʾ�յ�en3�ź�

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
//�����Σ����ת������
assign idl2s1_start  = state_c==IDLE && (en1 == 1 && en2 == 0 && en3 == 0);
assign idl2s2_start  = state_c==IDLE && (en1 == 0 && en2 == 1 && en3 == 0);
assign idl2s3_start  = state_c==IDLE && (en1 == 0 && en2 == 0 && en3 == 1);
assign s12idl_start = state_c==S1    && end_cnt;
assign s22idl_start = state_c==S2    && end_cnt;
assign s32idl_start = state_c==S3    && end_cnt;

//���ĶΣ�ͬ��ʱ��alwaysģ�飬��ʽ�������Ĵ�����������ж�������
always  @(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        dout <=1'b0      //��ʼ��
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

