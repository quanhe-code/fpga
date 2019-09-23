/*
 * 计数器-数值练习16 张强
 */
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

assign add_cnt1 = (dout == x);       
assign end_cnt1 = add_cnt1 && cnt1== (y - 1);   

always @(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        cnt2 <= 0;
    end
    else if(add_cnt2)begin
        if(end_cnt2)
            cnt2 <= 0;
        else
            cnt2 <= cnt2 + 1;
    end
end

assign add_cnt2 = (end_cnt1);       
assign end_cnt2 = add_cnt2 && cnt2== (3 - 1);   

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        dout <= 2'd0;
    end
    else if(en==1)begin
        dout <= x;
    end
    else if(end_cnt1)begin
        dout <= 2'd0;
    end
end

always  @(*)begin
    if(cnt2 == 0)begin
        x = 1;
        y = 5;
    end
    else if(cnt2 == 1)begin
        x = 2;
        y = 7;
    end
    else begin
        x = 3;
        y = 2;
    end
end


