/*
 * ¸´ÔÓ¼ÆÊıÆ÷-Á·Ï°3
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
    else begin
        cnt0 <= 0;
    end
end

assign add_cnt0 = (din_vld==0 && flag_add==0);
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

assign add_cnt1 = (rst_n==1);
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

assign add_cnt2 = end_cnt1;
assign end_cnt2 = add_cnt2 && cnt2== (4 - 1);
 
always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        flag_add <= 0;
    end
    else if(end_cnt0)begin
        flag_add <= 1;
    end
    else if(din_vld == 1)begin
        flag_add <= 0;
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        dout < = 0;
    end
    else if(end_cnt0)begin
        dout <= 1;
    end
    else begin
        dout <= 0;
    end
end

always  @(*)begin
    if(cnt2==0)begin
        x = 5;
        y = 20000;
    end
    else if(cnt2 == 1)begin
        x = 10;
        y = 40000;
    end
    else if(cnt2==2)begin
        x = 20;
        y = 100000;
    end
    else begin
        x = 4;
        y = 200000;
    end
end

