/*
 * 计数器-数值练习15 张强
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
assign end_cnt1 = add_cnt1 && cnt1== (5 - 1);   

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

assign x = (cnt2 + 1);
