module opcode_detect(
    clk      ,
    rst_n    ,
    din      ,
    din_vld  ,
    dout     ,
    dout_vld   
    );

    input               clk            ;
    input               rst_n          ;
    input[3:0]          din            ;
    input               din_vld        ;
    output[7:0]         dout           ;
    output              dout_vld       ;

reg     [7:0]       dout;
reg                 dout_vld;
reg     [2:0]       state_c;
reg     [2:0]       state_n;
wire                idl2s1_start;
wire                s12s2_start;
wire                s12idl_start;
wire                s22s3_start;
wire                s22idl_start;
wire                s32s4_start;
wire                s32idl_start;
wire                s42idl_start;

reg     [1:0]       cnt;
wire                add_cnt;
wire                end_cnt;


localparam      IDLE    =   3'd0;
localparam      S1      =   3'd1;
localparam      S2      =   3'd2;
localparam      S3      =   3'd3;
localparam      S4      =   3'd4;


//�Ķ�ʽ״̬��
// IDLE:δ�յ�����
// S1:�յ�����5
// S2:�յ�����55
// S3:�յ�����55d
// S4:��ʾ�յ�����55d5
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
            else if(s12idl_start) begin
                state_n = IDLE;
            end
            else begin
                state_n = state_c;
            end
        end
        S2:begin
            if(s22s3_start)begin
                state_n = S3;
            end
            else if(s22idl_start) begin
                state_n = IDLE;
            end
            else begin
                state_n = state_c;
            end
        end
        S3:begin
            if(s32s4_start) begin
                state_n = S4;
            end
            else if(s32idl_start) begin
                state_n = IDLE;
            end
            else begin
                state_n = state_c;
            end
        end
        S4:begin
            if(s42idl_start)begin
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
assign idl2s1_start  = state_c==IDLE && (din_vld && din == 4'h5);
assign s12s2_start = state_c==S1    && (din_vld && din == 4'h5);
assign s12idl_start = state_c==S1    && (din_vld && din != 4'h5);
assign s22s3_start  = state_c==S2    && (din_vld && din == 4'hd);
assign s22idl_start  = state_c==S2    && (din_vld && din != 4'hd);
assign s32s4_start  = state_c==S3    && (din_vld && din == 4'h5);
assign s32idl_start  = state_c==S3    && (din_vld && din != 4'h5);
assign s42idl_start  = state_c==S4    && end_cnt;
//���ĶΣ�ͬ��ʱ��alwaysģ�飬��ʽ�������Ĵ�����������ж�������
always  @(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        dout <=8'h00;      //��ʼ��
    end
    else if(state_c==S4 && din_vld)begin
        dout <= {dout[3:0], din};
    end
    else begin
        dout <= dout;
    end
end

//  ����������
always @(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        cnt <= 0;
    end
    else if(add_cnt)begin
        if(end_cnt)
            cnt <= 0;
        else
            cnt <= cnt + 1'b1;
    end
end

assign add_cnt = (state_c == S4 && din_vld);       
assign end_cnt = add_cnt && cnt== (4 - 1);   

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        dout_vld <= 0;
    end
    else if((add_cnt && (cnt == 2 - 1)) || end_cnt)begin
        dout_vld <= 1;
    end
    else begin
        dout_vld <= 0;
    end
end


endmodule

