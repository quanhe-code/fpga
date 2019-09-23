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
assign end_cnt2 = add_cnt2 && cnt2== (n - 1);   

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        flag_add <= 1'b0;
    end
    else if(en==1)begin
        flag_add <= 1'b1;
    end
    else if(end_cnt2)begin
        flag_add <= 1'b0;
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        dout <= 1'b0;
    end
    else if(add_cnt1 && cnt1 == (x - 1))begin
        dout <= 1'b1;
    end
    else if(end_cnt1)begin
        dout <= 1'b0;
    end
end


always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        flag_sel <= 2'b00;
    end
    else if(en1==1)begin
        flag_sel <= 2'b00;
    end
    else if(en2==1)begin
        flag_sel <= 2'b01;
    end
    else if(en3==1)begin
        flag_sel <= 2'b10;
    end
end

always  @(*)begin
    if(flag_sel == 2'b00)begin
        x = 1;
        y = 1;
        n = 3;
    end
    else if(flag_sel == 2'b01)begin
        x = 1;
        y = 4;
        n = 4;
    end
    else begin
        x = 3;
        y = 4;
        n = 8;
    end
end


