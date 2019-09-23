/*
 * 计数器-数值练习4 张强
 */
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

assign add_cnt = (din_vld == 1);       
assign end_cnt = add_cnt && cnt== (8 - 1);   

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        dout <= 8'd0;
    end
    else if(din_vld == 1)begin
        dout[x] = din;
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        dout_vld <= 0;
    end
    else if(end_cnt)begin
        dout_vld <= 1;
    end
    else 
        dout_vld <= 0;
    end
end

assign x = 7 - cnt;
