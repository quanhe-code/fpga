/*
 * SCCB�ӿ�-��ϰ2
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

assign add_cnt0 = (flag_add == 1);
assign end_cnt0 = add_cnt0 && cnt0== (100 - 1);

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
assign end_cnt1 = add_cnt1 && cnt1== (30 - 1);


always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        flag_add <= 0;
    end
    else if(en==1)begin
        flag_add <= 1;
    end
    else if(end_cnt1)begin
        flag_add <= 0;
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        sio_c <= 1;
    end
    else if(end_cnt0 && cnt1 < (30 - 1))begin
        sio_c <= 0;
    end
    else if(add_cnt0 && cnt0 == (50 - 1))begin
        sio_c <= 1;
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        sio_d <= 1;
    end
    else if(add_cnt0 && cnt0 == (25 - 1))begin
        sio_d <= d_data[29 - cnt1]
    end
end
assign d_data = {1'b0, 8'ha1, 1'b0, 8'ha2, 1'b0, 8'ha3, 1'b0, 1'b0, 1'b1}


