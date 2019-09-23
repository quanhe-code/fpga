/*
 * SCCB½Ó¿Ú-Á·Ï°4
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

assign add_cnt0 = (flag_add==1);
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
assign end_cnt1 = add_cnt1 && cnt1== (x - 1);

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
assign end_cnt2 = add_cnt2 && cnt2== (y - 1);
 
always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        flag_add <= 0;
    end
    else if(wr_en==1 || rd_en==1)begin
        flag_add <= 1;
    end
    else if(end_cnt2)begin
        flag_add <= 0;
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        flag_sel <= 0;
    end
    else if(wr_en == 1)begin
        flag_sel <= 0;
    end
    else if(rd_en == 1)begin
        flag_sel <= 1;
    end
end

always  @(posedge clk or negedge rst_n)begin

    if(rst_n==1'b0)begin
        sio_c <= 1;
    end
    else if(end_cnt0 && cnt1 < (x - 1))begin
        sio_c <= 0;
    end
    else if(add_cnt0 && cnt0 == (50 - 1))begin
        sio_c <= 1;
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        sio_dout <= 1;
    end
    else if(add_cnt0 && cnt0 == (25 - 1))begin
        sio_dout <= data[x - 1 - cnt1]
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        dout <= 0;
    end
    else if(cnt2 == (2 - 1) && cnt1 >= (11 - 1) && cnt1 < (19 - 1) && add_cnt0 && cnt0 == (50 - 1))begin
        dout[17 - cnt1] <= sio_din;
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        dout_vld <= 0;
    end
    else if(end_cnt2)begin
        dout_vld <= 1;
    end
    else
        dout_vld <= 0;
    end
end

always  @(*)begin
    if(flag_sel == 0)begin
        x = 30;
        y = 1;
        data = {1'b0, 8'ha1, 1'b0, 8'h2a, 1'b0, 8'h5c, 1'b0, 1'b0, 1'b1};
    end
    else begin
        x = 21;
        y = 2;
        if(cnt2 == 0)
            data = {1'b0, 8'ha1, 1'b0, 8'h2a, 1'b0, 1'b0, 1'b1};
        else
            data = {1'b0, 8'ha1, 1'b0, 8'h00, 1'b0, 1'b0, 1'b1};
    end
end
