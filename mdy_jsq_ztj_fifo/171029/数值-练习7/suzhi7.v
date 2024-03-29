/*
 * 计数器-数值练习7 张强
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
assign end_cnt = add_cnt && cnt== (7 - 1);   

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        dout <= 1'b0;
    end
    else if(add_cnt && cnt == (5 - 1))begin
        dout <= 1'b1; 
    end
    else if(end_cnt)begin
        dout <= 1'b0;
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



