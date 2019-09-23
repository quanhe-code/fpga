/*
 * 计数器-数值练习6 张强
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

assign add_cnt = (flag_add == 1);       
assign end_cnt = add_cnt && cnt== (4 - 1);   

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        dout <= 3'd0;
    end
    else if(add_cnt && cnt == (1 - 1))begin
        dout <= 3'd4;
    end
    else if(end_cnt)begin
        dout <= 3'd0;
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        flag_add <= 1'b0;
    end
    else if(en==1)begin
        flag_add <= 1'b1;
    end
    else if(end_cnt)begin
        flag_add <= 1'b0;
    end
end





