/*
 * VGA½Ó¿Ú-Á·Ï°2
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
assign end_cnt0 = add_cnt0 && cnt0== (875 - 1);

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
assign end_cnt1 = add_cnt1 && cnt1== (525 - 1);

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        hys <= 0;
    end
    else if(add_cnt0 && cnt0 == (171 - 1))begin
        hys <= 1;
    end
    else if(end_cnt0)begin
        hys <= 0;
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        data_vld_hys <= 0;
    end
    else if(add_cnt0 && cnt0 == (216 - 1))begin
        data_vld_hys <= 1;
    end
    else if(add_cnt0 && cnt0 == (862 - 1))begin
        data_vld_hys <= 0;
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        vys <= 0;
    end
    else if(add_cnt1 && cnt1 == (2 - 1))begin
        vys <= 1;
    end
    else if(end_cnt1)begin
        vys <= 0;
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        data_vld_vys <= 0;
    end
    else if(add_cnt1 && cnt1 == (32 - 1))begin
        data_vld_vys <= 1;
    end
    else if(add_cnt2 && cnt1 == (516 - 1))begin
        data_vld_vys <= 0;
    end
end




