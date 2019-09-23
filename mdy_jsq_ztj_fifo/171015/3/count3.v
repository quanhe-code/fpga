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

assign add_cnt = (dout == 0);       
assign end_cnt = add_cnt && cnt== (x - 1);

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        dout <= 1'b1;
    end
    else if(en1 == 1 || en2 == 1)begin
        dout <= 1'b0;
    end
    else if(end_cnt)begin
        dout <= 1'b1;
    end
end


always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        flag_sel <= 1'b0;
    end
    else if(en1 == 1)begin
        flag_sel <= 1'b0;
    end
    else if(en2 == 1)begin
        flag_sel <= 1'b1;
    end
end

always  @(*)begin
    if(flag_sel == 0)
        x = 5;
    else
        x = 7;
end

   

