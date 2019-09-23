//逻辑，dout为1比特信号
//练习1
always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        dout <= 0;
    end
    else begin
        dout <= a;
    end
end


//dout为1比特信号
//练习2
always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        dout <= 0;
    end
    else begin
        dout <= a && b && c;
    end
end



//组合逻辑，dout为1比特信号
//练习3
always  @(*)begin
    dout = (a&&c) || (b&&c);
end



//dout为1比特信号
//练习4
always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        dout <= 0;
    end
    else begin
        dout <= (a && b) || c;
    end
end



//dout为1比特信号
//练习5
always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        dout <= 0;
    end
    else if(a==1) begin
        dout <= 0;
    end
end



//dout为1比特信号
//练习6
always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        dout <= 0;
    end
    else begin
        dout <= a + b;
    end
end



//组合逻辑，dout为1比特信号
//练习7
assign  dout = a + b;


//dout为1比特信号
//练习8
always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        dout <= 0;
    end
    else if(d==2) begin
        if(a==1)
            dout <= c;
        else
            dout <= b;
    end
    else begin
        dout <= c && b;
    end
end



//练习9
//CNT
//dout为3比特信号
always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        dout <= 0;
    end
    else if(a&&b) begin
        dout <= dout + 1;
    end
end



//dout为3比特信号
//练习10
always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        dout <= 0;
    end
    else begin
        dout <= d + a;
    end
end



//练习11
//dout为3比特信号，d为3比特信号
always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        dout <= 0;
    end
    else if(a==1) begin
        dout <= d -1;
    end
    else begin
        dout <= d +2;
    end
end



//dout为3比特信号
//练习12
always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        dout <= 0;
    end
    else if(add_dout) begin
        if(end_dout)
            dout <= 0;
        else
            dout <= dout + 1;
    end
end
assign add_dout = a==1;
assign end_dout = add_dout && dout==3-1;



//练习13
//拼接，dout为4比特信号
always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        dout <= 0;
    end
    else begin
        dout <= {dout[2:0],a};
    end
end

//dout为4比特信号
//练习14
always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        dout <= 0;
    end
    else begin
        dout <= {a&&b,dout[2:0]};
    end
end

//dout为4比特信号
//练习15
always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        dout <= 0;
    end
    else begin
        dout <= {dout[2:0],~dout[3]};
    end
end

//dout为4比特信号
//练习16
always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        dout <= 0;
    end
    else begin
        dout <= {dout[0],~dout[3:1]};
    end
end



//dout为4比特信号
//练习17
always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        dout <= 0;
    end
    else if(a&&b && (d!=2)) begin
        dout <= {dout[2:0],~dout[3]};
    end
    else begin
        dout <= {~dout[0],dout[3:1]};
    end
end





//练习18
//位宽
//dout为1比特信号
always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        dout <= 0;
    end
    else if(a&&b) begin
        dout <= d[e];
    end
end


//练习19
//dout为4比特信号
always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        dout <= 0;
    end
    else if(a&&c) begin
        dout[e] <= b; 
    end
end


//练习20
//dout为16比特信号
always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        dout <= 0;
    end
    else if(a&&c) begin
        dout[15:8] <= d; 
    end
    else if(b) begin
        dout[7:0] <= e; 
    end
end




