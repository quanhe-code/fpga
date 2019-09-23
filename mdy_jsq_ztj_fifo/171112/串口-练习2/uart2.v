/*
 * ´®¿Ú-Á·Ï°2
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

assign add_cnt0 = (flag_tx==1);
assign end_cnt0 = add_cnt0 && cnt0== (5208 - 1);

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
assign end_cnt1 = add_cnt1 && cnt1== (10 - 1);

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
        flag_tx <= 0;
    end
    else if(din_vld)begin
        flag_tx <= 1;
    end
    else if(end_cnt1)begin
        flag_tx <= 0;
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        tx <= 1'b0;
    end
    else if(add_cnt0 && cnt0 == (1 - 1))begin
        tx <= data_x[cnt1]
    end
end

always  @(*)begin
    if(cnt2 == 0)
        data_x = {1'b1, 11010110, 1'b0};
    else if(cnt2 == 1)
        data_x = {1'b1, 01110101, 1'b0};
    else
        data_x = {1'b1, 01000101, 1'b0};
end 

