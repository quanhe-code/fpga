//�Ķ�ʽ״̬��
IDLE: ��ʾdout���0
S1����ʾdout���1
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
        default:begin
            state_n = IDLE;
        end
    endcase
end
//�����Σ����ת������
assign idl2s1_start  = state_c==IDLE && add_cnt0 && cnt0 = x - 1;
assign s12s2_start = state_c==S1    && end_cnt0;

//���ĶΣ�ͬ��ʱ��alwaysģ�飬��ʽ�������Ĵ�����������ж�������
always  @(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        dout <=1'b0      //��ʼ��
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

