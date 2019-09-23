/*
 * 计数器-取值练习2
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
    else begin
        cnt <= 0;
    end
end

assign add_cnt = (din_vld == 1 && flag == 0);       
assign end_cnt = add_cnt && cnt== (10 - 1);   

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        dout <= 0;
    end
    else if(end_cnt)begin
        dout <= din;
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        flag <= 1'b0;
    end
    else if(end_cnt)begin
        flag <= 1'b1;
    end
    else if(din_vld == 0)begin
        flag <= 1'b0;
    end
end




