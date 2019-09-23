/*
 * SPI½Ó¿Ú-Á·Ï°5
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

assign add_cnt0 = (cs == 1);
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
assign end_cnt1 = add_cnt1 && cnt1== (26 - 1);

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        cs <= 0;
    end
    else if(en)begin
        cs <= 1;
    end
    else if(end_cnt1)begin
        cs <= 0;
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        sck <= 1;
    end
    else if(add_cnt0 && cnt0 == (1 - 1))begin
        sck <= 0;
    end
    else if(add_cnt0 && cnt0 == (50 - 1))begin
        sck <= 1;
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        di <= 0;
    end
    else if(add_cnt0 && cnt0 == (1 - 1) && (cnt1< 9))begin
        di <= di_data[8 - cnt1]
    end
end
assign di_data = {3'b110, 6'b101111};

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        dout <= 0;
    end
    else if((cnt1 > 9) && add_cnt0 && cnt0 == (50 - 1))begin
        dout <= {do, dout[15:1]};
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        dout_vld <= 0;
    end
    else if(end_cnt1)begin
        dout_vld <= 1;
    end
    else 
        dout_vld <= 0;
    end
end


