/*
 * ´®¿Ú-Á·Ï°1
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

assign add_cnt0 = (flag_tx);
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
assign end_cnt1 = add_cnt1 && cnt1== (9 - 1);

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        tx <= 1'b1;
    end
    else if(tx_flag)begin
        tx <= data[cnt];
    end
    else 
        tx <= 1'b1;
    end
end

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

assign data = {11010110, 0};
