/*
 * 计数器-数值练习12 张强
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

assign add_cnt1 = (flag_add == 1);       
assign end_cnt1 = add_cnt1 && cnt1== (x + y - 1);   

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
assign end_cnt2 = add_cnt2 && cnt2== (3 - 1);   

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        dout <= 2'd0;
    end
    else if(add_cnt1 && cnt1 == (x - 1))begin
        dout <= 2'd3;
    end
    else if(end_cnt1)begin
        dout <= 2'd0;
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        flag_add <= 1'b0;
    end
    else if(en1==1 || en2==1 || en3==1)begin
        flag_add <= 1'b1;
    end
    else if(end_cnt2)begin
        flag_add <= 1'b0;
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        flag_sel <= 2'd0;
    end
    else if(en1==1)begin
        flag_sel <= 2'd0;
    end
    else if(en2==1)begin
        flag_sel <= 2'd1;
    end
    else if(en3==1)begin
        flag_sel <= 2'd2;
    end
end

always  @(*)begin
    if(flag_sel == 2'd0)begin
        x = 1;
        y = 1;
    end
    else if(flag_sel == 2'd1)begin
        x = 1;
        y = 5;
    end
    else begin
        x = 4;
        y = 3;
    end
end

