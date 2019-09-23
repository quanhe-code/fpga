/*
 * ¸´ÔÓ¼ÆÊıÆ÷1
 */
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

assign add_cnt0 = (rst_n == 1);
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
assign end_cnt1 = add_cnt1 && cnt1== (1000 - 1);

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

assign add_cnt2 = end_cnt1;
assign end_cnt2 = add_cnt2 && cnt2== (4 - 1);
 
always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        dout <= 0;
    end
    else if(add_cnt0 && cnt0 == (x - 1))begin
        dout <= 1;
    end
    else if(end_cnt0)begin
        dout <= 0;
    end
end

always  @(*)begin
    if(cnt2 == 0)begin
        x = 1;
        y = 1;
    end
    else if(cnt2 == 1)begin
        x = 3;
        y = 1;
    end
    else if(cnt2 == 2)begin
        x = 9;
        y = 1;
    end
    else begin
        x = 19;
        y = 1;
    end
end

