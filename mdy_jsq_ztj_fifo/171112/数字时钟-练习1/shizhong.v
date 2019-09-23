/*
 * Êı×ÖÊ±ÖÓ-Á·Ï°1
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

assign add_cnt0 = (rst==1);       
assign end_cnt0 = add_cnt0 && cnt0== (100000000 - 1);   

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

assign add_cnt2 = (end_cnt1);       
assign end_cnt2 = add_cnt2 && cnt2== (6 - 1);   

always @(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        cnt3 <= 0;
    end
    else if(add_cnt3)begin
        if(end_cnt3)
            cnt3 <= 0;
        else
            cnt3 <= cnt3 + 1;
    end
end

assign add_cnt3 = end_cnt2;       
assign end_cnt3 = add_cnt3 && cnt3== (10 - 1);   

always @(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        cnt4 <= 0;
    end
    else if(add_cnt4)begin
        if(end_cnt4)
            cnt4 <= 0;
        else
            cnt4 <= cnt4 + 1;
    end
end

assign add_cnt4 = end_cnt3;       
assign end_cnt4 = add_cnt4 && cnt4== (6 - 1);

always @(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        cnt5 <= 0;
    end
    else if(add_cnt5)begin
        if(end_cnt5)
            cnt5 <= 0;
        else
            cnt5 <= cnt5 + 1;
    end
end

assign add_cnt5 = end_cnt4;       
assign end_cnt5 = add_cnt5 && cnt5== (x - 1);   

always @(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        cnt6 <= 0;
    end
    else if(add_cnt6)begin
        if(end_cnt6)
            cnt6 <= 0;
        else
            cnt6 <= cnt6 + 1;
    end
end

assign add_cnt6 = (end_cnt5);       
assign end_cnt6 = add_cnt6 && cnt6== (3 - 1);   

always  @(*)begin
   if(cnt6 == 2)
        x = 4;
   else
      x = 10; 
end

assign miao_g = cnt1;
assign miao_s = cnt2;
assign fen_g = cnt3;
assign fen_s = cnt4;
assign shi_g = cnt5;
assign shi_s = cnt6;
