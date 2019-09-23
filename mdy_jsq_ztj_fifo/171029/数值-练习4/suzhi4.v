/*
 * ������-��ֵ��ϰ4 ��ǿ
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
assign end_cnt = add_cnt && cnt== (x + y - 1);   

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        flag_add <= 1'b0;
    end
    else if(en1==1 || en2==1)begin
        flag_add <= 1'b1;
    end
    else if(end_cnt)begin
        flag_add <= 1'b0;
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        dout <= 2'b00;
    end
    else if(add_cnt && cnt == (x - 1))begin
        dout <= 2'b10;
    end
    else if(end_cnt)begin
        dout <= 2'b00;
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        flag_sel <= 1'b0;
    end
    else if(en1==1)begin
        flag_sel <= 1'b0;
    end
    else if(en2==1)begin
        flag_sel <= 1'b1;
    end
end

always  @(*)begin
    if(flag_sel == 0)begin
        x = 3;
        y = 1;
    end
    else begin
        x = 4;
        y = 5;
     end
end



