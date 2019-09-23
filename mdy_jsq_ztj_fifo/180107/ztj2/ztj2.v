/*
 * �Զ��ۻ���״̬��--���2
 */

S0:��ʾ�յ�0��Ԫ
S1:��ʾ�յ�5��Ԫ
S2:��ʾ�յ�10��Ԫ
S3:��ʾ�յ�15��Ԫ
S4:��ʾ�յ�20��Ԫ


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
        S0:begin
            if(s02s1_start)begin
                state_n = S1;
            end
            else if(s02s2_start) begin
                state_n = S2;
            end
            else begin
                state_n = state_c;
            end
        end
        S1:begin
            if(s12s0_start)begin
                state_n = S0;
            end
            else if(s12s2_start)begin
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
            else if(s22s4_start)begin
                state_n = S4;
            end
            else if(s22s0_start)begin
                state_n = S0;
            end
            else begin
                state_n = state_c;
            end
        end
        S3:begin
            if(s32s4_start)begin
                state_n = S4;
            end
            else if (s32s0_start)begin
                state_n = S0;
            end
            else begin
                state_n = state_c
            end
        end
        S4:begin
            if(s42s0_start)begin
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
assign s02s1_start  = state_c== S0 && din_vld && din == 0;
assign s02s2_start  = state_c== S0 && din_vld && din == 1;
assign s12s2_start = state_c==S1    && din_vld && din == 0;
assign s12s3_start = state_c==S1    && din_vld && din == 1;
assign s12s0_start = state_c==S1    && din_vld && din == 2;
assign s22s3_start  = state_c==S2    && din_vld && din == 0;
assign s22s4_start  = state_c==S2    && din_vld && din == 1;
assign s22s0_start  = state_c==S2    && din_vld && din == 2;
assign s32s4_start  = state_c==S3    && din_vld && din == 0;
assign s32s0_start  = state_c==S3    && (din_vld && din == 1) || (din_vld && din == 2);
assign s42s0_start  = state_c==S4    && din_vld;
//���ĶΣ�ͬ��ʱ��alwaysģ�飬��ʽ�������Ĵ�����������ж�������
always  @(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        dout_vld <= 0;
    end
    else if((state_c==S0 && din_vld && din==2) || s12s0_start  
                || s22s0_start || s32s0_start || s42s0_start)begin
        dout_vld <= 1'b1;
    end
    else begin
        dout_vld <= 1'b0;
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        dout <= 0;
    end
    else if(s12s0_start || (s42s0_start && din_vld && din==1))begin
        dout <= 5;
    end
    else if(s22s0_start)begin
        dout <= 10;
    end
    else if(s32s0_start && din_vld && din==2)begin
        dout <= 15;
    end
    else if (s42s0_start && din_vld && din==2) begin
        dout <= 20;
    end
    else begin
        dout <= 0;
    end 
end


