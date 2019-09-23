/*
 * VGA½Ó¿Ú-Á·Ï°1
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

assign add_cnt = (rst_n == 1);       
assign end_cnt = add_cnt && cnt== (875 - 1);   

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        hys <= 0;
    end
    else if(add_cnt && cnt == (171 - 1))begin
        hys <= 1;
    end
    else if(end_cnt)begin
        hys <= 0;
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        data_vld_hys <= 0;
    end
    else if(add_cnt && cnt == (216 - 1))begin
        data_vld_hys <= 1;
    end
    else if(add_cnt && cnt == (862 - 1))begin
        data_vld_hys <= 0;
    end
end


