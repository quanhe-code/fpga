/*
 * 计数器-取值练习1
 */
always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        dout <= 3'd0;
    end
    else if(din_vld == 1)begin
        dout <= din;
    end
    else begin
        dout <= dout;
    end
end


