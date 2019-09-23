/*
 * �Զ��ۻ���״̬��-���1
 */
IDLE����ʾ�ۼ��յ�0.0Ԫ
S1  ����ʾ�ۼ��յ�0.5Ԫ
S2  ����ʾ�ۼ��յ�1.0Ԫ
S3  ����ʾ�ۼ��յ�1.5Ԫ

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
//�����Σ����ת������
assign idl2s1_start  = state_c==IDLE && din_vld && din==0;
assign idl2s2_start  = state_c==IDLE && din_vld && din==1;
assign s12s2_start   = state_c==S1    && din_vld && din==0;
assign s12s3_start   = state_c==S1    && din_vld && din==1;
assign s22s3_start   = state_c==S2    && din_vld && din==0;
assign s22idl_start   = state_c==S2    && din_vld && din==1;
assign s32idl_start   = state_c==S3    && din_vld;

//���ĶΣ�ͬ��ʱ��alwaysģ�飬��ʽ�������Ĵ�����������ж�������
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


