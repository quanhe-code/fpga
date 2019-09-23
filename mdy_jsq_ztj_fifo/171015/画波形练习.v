//�߼���doutΪ1�����ź�
//��ϰ1
always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        dout <= 0;
    end
    else begin
        dout <= a;
    end
end


//doutΪ1�����ź�
//��ϰ2
always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        dout <= 0;
    end
    else begin
        dout <= a && b && c;
    end
end



//����߼���doutΪ1�����ź�
//��ϰ3
always  @(*)begin
    dout = (a&&c) || (b&&c);
end



//doutΪ1�����ź�
//��ϰ4
always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        dout <= 0;
    end
    else begin
        dout <= (a && b) || c;
    end
end



//doutΪ1�����ź�
//��ϰ5
always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        dout <= 0;
    end
    else if(a==1) begin
        dout <= 0;
    end
end



//doutΪ1�����ź�
//��ϰ6
always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        dout <= 0;
    end
    else begin
        dout <= a + b;
    end
end



//����߼���doutΪ1�����ź�
//��ϰ7
assign  dout = a + b;


//doutΪ1�����ź�
//��ϰ8
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



//��ϰ9
//CNT
//doutΪ3�����ź�
always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        dout <= 0;
    end
    else if(a&&b) begin
        dout <= dout + 1;
    end
end



//doutΪ3�����ź�
//��ϰ10
always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        dout <= 0;
    end
    else begin
        dout <= d + a;
    end
end



//��ϰ11
//doutΪ3�����źţ�dΪ3�����ź�
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



//doutΪ3�����ź�
//��ϰ12
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



//��ϰ13
//ƴ�ӣ�doutΪ4�����ź�
always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        dout <= 0;
    end
    else begin
        dout <= {dout[2:0],a};
    end
end

//doutΪ4�����ź�
//��ϰ14
always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        dout <= 0;
    end
    else begin
        dout <= {a&&b,dout[2:0]};
    end
end

//doutΪ4�����ź�
//��ϰ15
always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        dout <= 0;
    end
    else begin
        dout <= {dout[2:0],~dout[3]};
    end
end

//doutΪ4�����ź�
//��ϰ16
always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        dout <= 0;
    end
    else begin
        dout <= {dout[0],~dout[3:1]};
    end
end



//doutΪ4�����ź�
//��ϰ17
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





//��ϰ18
//λ��
//doutΪ1�����ź�
always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        dout <= 0;
    end
    else if(a&&b) begin
        dout <= d[e];
    end
end


//��ϰ19
//doutΪ4�����ź�
always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        dout <= 0;
    end
    else if(a&&c) begin
        dout[e] <= b; 
    end
end


//��ϰ20
//doutΪ16�����ź�
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




