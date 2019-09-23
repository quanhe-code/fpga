HEAD: ��ʾ���հ���ͷ״̬
SEG: ��ʾ���ն���
LEN: ��ʾ�����ֽڳ���
DATA: ��ʾ��������
FCS: ��ʾ����FCS

//�Ķ�ʽ״̬��

//��һ�Σ�ͬ��ʱ��alwaysģ�飬��ʽ��������̬�Ĵ���Ǩ�Ƶ���̬�Ĵ���(������ģ�
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        state_c <= HEAD;
    end
    else begin
        state_c <= state_n;
    end
end

//�ڶ��Σ�����߼�alwaysģ�飬����״̬ת�������ж�
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
            if(seg2len_start)begin
                state_n = LEN;
            end
            else begin
                state_n = state_c;
            end
        end
        LEN:begin
            if(len2data_start)begin
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
            else if(fcs2len_start)begin
                state_n = LEN;
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
assign head2seg_start = state_c==HEAD && (din_t == 8'h55 && din == 8'hd5);
assign seg2len_start = state_c==SEG && (1);
assign len2data_start= state_c== LEN && end_cnt0;
assign data2fcs_start= state_c == DATA && end_cnt0;
assign fcs2len_start= state_c == FCS && end_cnt0 && cnt1 < (seg_num - 1);
assign fcs2head_start= state_c == FCS && end_cnt0 && cnt1 == (seg_num - 1);

//���ĶΣ�ͬ��ʱ��alwaysģ�飬��ʽ�������Ĵ�����������ж�������
always  @(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        dout <=1'b0      //��ʼ��
    end
    else begin
        dout <= din;
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        dout_sop <= 0;
    end
    else if(state_c == DATA && add_cnt0 && cnt0 == 1 - 1&& cnt1 == 1 - 1)begin
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
    else if(state_c == DATA && add_cnt0 && cnt0 == x - 1 && cnt1 == seg_num - 1)begin
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
        seg_num <= 0;
    end
    else if(state_c == SEG)begin
        seg_num <= din;
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        len <= 0;
    end
    else if(state_c == LEN)begin
        len <= {len[7:0], din}
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

assign add_cnt0 = (state_c == LEN && state_c == DATA && state_c == FCS);
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

assign add_cnt1 = (state_c == FCS && end_cnt0);
assign end_cnt1 = add_cnt1 && cnt1== (seg_num - 1);

always  @(*)begin
    if(state_c == LEN)
        x = 2;
    else if(state_c == DATA)
        x = len;
    else
        x = 4;
end

