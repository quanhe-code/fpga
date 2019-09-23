/*
 * 计数器-数值练习8 张强
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

assign add_cnt = (flag==1);       
assign end_cnt = add_cnt && cnt== (x + y - 1);   

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        dout <= 3'd0;
    end
    else if(add_cnt && cnt == (x - 1))begin
        dout <= z;
    end
    else if(end_cnt)begin
        dout <= 3'd0;
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        flag_add <= 1'b0;
    end
    else if(en1==1 || en2==1 || en3==1)begin
        flag_add <= 1'b1;
    end
    else if(end_cnt)begin
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
    else if(en3 ==1)begin
        flag_sel <= 2'd2;
    end
end

always  @(*)begin
    if(flag_sel == 2'd0)begin
        x = 1;
        y = 1;
        z = 2;
    end
    else if(flag_sel == 2'b1)begin
        x = 1;
        y = 3;
        z = 4;
    end
    else begin
        x = 5;
        y = 2;
        z = 1;
    end
end


