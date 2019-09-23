/*
 * 按键默认状态为高电平，按下后为低电平
 */

module key(
    input           clk,
    input           rst_n,
    input           key_sw,
    output   reg  	key_down_int
);
	
reg                  key_sw_r1;
reg                  key_sw_r2;
reg                  count_en;
reg     [18:0]       cnt;


parameter PARA_MAX_CNT = 19'd499999; //20ms

always @(posedge clk or negedge rst_n) begin
   if(!rst_n)
       key_sw_r1 <= 1'b0;
   else
       key_sw_r1 <= key_sw;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        key_sw_r2 <= 1'b0;
    else
        key_sw_r2 <= key_sw_r1;
end

wire key_change = key_sw_r2 & (~key_sw_r1);

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        count_en <= 1'b0;
    else if(key_change)
        count_en <= 1'b1;
    else if(cnt == PARA_MAX_CNT)
        count_en <= 1'b0;
    else
        count_en <= count_en;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        cnt <= 1'b0;
    else if(count_en && (cnt == PARA_MAX_CNT || key_change))
           cnt <= 1'b0;
    else if(count_en)
           cnt <= cnt + 1'b1;
    else
        cnt <= 1'b0;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        key_down_int <= 1'b0;
    else if(cnt == PARA_MAX_CNT && key_sw == 1'b0)    
        key_down_int <= 1'b1;
    else
        key_down_int <= 1'b0;
end

endmodule
