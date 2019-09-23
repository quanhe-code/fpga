/*
 * 计数器-取值练习5 张强
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

assign add_cnt = (din_vld == 0 && flag_add == 0);       
assign end_cnt = add_cnt && cnt== (24 - 1);   

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        dout <= 8'd0;
    end
    else if(add_cnt && (cnt >= 16 && cnt <= 23))begin
        dout[cnt - 16] <= din;
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        flag_add <= 1'b0;
    end
    else if(end_cnt)begin
        flag_add <= 1'b1;
    end
    else if(din_vld == 1)begin
        flag_add <= 1'b0;
    end
end


