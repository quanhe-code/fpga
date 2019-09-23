/*
 * 1001���м����״̬�����
 */

S0:��ʾδ�յ���Ч��
S1����ʾ�յ�1λ��Ч��1
S2����ʾ�յ�2λ��Ч��10
S3����ʾ�յ�3λ��Ч��100

//�Ķ�ʽ״̬��

//��һ�Σ�ͬ��ʱ��alwaysģ�飬��ʽ��������̬�Ĵ���Ǩ�Ƶ���̬�Ĵ���(������ģ�
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        state_c <= S0;
    end
    else begin
        state_c <= state_n;
    end
end

//�ڶ��Σ�����߼�alwaysģ�飬����״̬ת�������ж�
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
//�����Σ����ת������
assign s02s1_start  = state_c==S0 && din==1;
assign s02s0_start  = state_c==S0 && din==0;
assign s12s2_start = state_c==S1    &&din==0;
assign s12s1_start = state_c==S1    &&din==1;
assign s22s3_start  = state_c==S2    && din==0;
assign s22s1_start  = state_c==S2    && din==1;
assign s32s1_start  = state_c==S3    && din==1;
assign s32s0_start  = state_c==S3    && din==0;

//���ĶΣ�ͬ��ʱ��alwaysģ�飬��ʽ�������Ĵ�����������ж�������
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

