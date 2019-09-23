module huxiled4(
    clk    ,
    rst_n  ,
    led        
    );

    input               clk     ;
    input               rst_n   ;

    output[3:0]         led     ;

    reg [3:0]           led     ;

    reg[25:0]           cnt0    ;
    wire                add_cnt0;
    wire                end_cnt0;

    reg[ 2:0]           cnt1    ;
    wire                add_cnt1;
    wire                end_cnt1;

    reg[ 2:0]           cnt2    ;
    wire                add_cnt2;
    wire                end_cnt2;


    //add always and assign code at below
parameter SECOND_CNT = 25000000;

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
assign end_cnt0 = add_cnt0 && cnt0== (SECOND_CNT - 1);

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
assign end_cnt1 = add_cnt1 && cnt1== (1 + cnt2 + 1 - 1);

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
assign end_cnt2 = add_cnt2 && cnt2== (4 - 1);
 

    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            led <= 4'b1111;
        end
        else if(add_cnt1 && cnt1 == (1 - 1))begin
            led <= (led & ~(1<<cnt2)); 
        end
        else if(end_cnt1)begin
            led <= (led | (1 << cnt2));
        end
    end

endmodule

