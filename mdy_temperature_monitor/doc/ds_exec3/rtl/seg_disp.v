/*********www.mdy-edu.com 明德扬科教 注释开始****************
模块功能说明：设计一个数码管显示，显示0时停止1秒；显示1时停止2秒；依次类推，显示9时停止10秒。

接口定义：
clk               : 时钟信号，频率是50MHz
rst_n             : 复位信号，在低电平时有效
seg_sel        : 位选信号，在低电平是该位置数码管亮。
segment       : 段选信号，共8位。由低到高，分别表示数码管的a,b,c,d,e,f,g,点。当该比特为0时，表示点亮相应位置；为1时熄灭。
**********www.mdy-edu.com 明德扬科教 注释结束****************/

module  seg_disp(rst_n       ,
                 clk         ,
                 disp_en     ,
                 din         ,
                 din_vld     ,
                 seg_sel     ,
                 segment      
             );

/*********www.mdy-edu.com 明德扬科教 注释开始****************
参数定义，明德扬规范要求，verilog内的用到的数字，都使用参数表示。
参数信号全部大写
**********www.mdy-edu.com 明德扬科教 注释结束****************/

parameter  SEG_WID        =       8;
parameter  SEG_NUM        =       8;
parameter  COUNT_WID      =       26;
parameter  TIME_20US      =       20'd1000;

 
parameter  NUM_0          =       8'b1100_0000;
parameter  NUM_1          =       8'b1111_1001;
parameter  NUM_2          =       8'b1010_0100;
parameter  NUM_3          =       8'b1011_0000;
parameter  NUM_4          =       8'b1001_1001;
parameter  NUM_5          =       8'b1001_0010;
parameter  NUM_6          =       8'b1000_0010;
parameter  NUM_7          =       8'b1111_1000;
parameter  NUM_8          =       8'b1000_0000;
parameter  NUM_9          =       8'b1001_0000;
parameter  NUM_F          =       8'b1011_1111;
parameter  NUM_ERR        =       8'b1000_0110;


input                             clk       ;
input                             rst_n     ;
input                             disp_en   ;
input  [SEG_NUM*4-1:0]            din       ;
input  [SEG_NUM-1:0]              din_vld   ;
output [SEG_NUM-1:0]              seg_sel   ;
output [SEG_WID-1:0]              segment   ;

reg    [SEG_NUM-1:0]              seg_sel   ;
reg    [SEG_WID-1:0]              segment   ;
reg    [COUNT_WID-1:0]            cnt0      ;
wire                              add_cnt0  ;
wire                              end_cnt0  ;
reg    [SEG_NUM-1:0]              cnt1      ;
wire                              add_cnt1  ;
wire                              end_cnt1  ;
reg    [4*SEG_NUM-1:0]            din_ff0   ;
reg    [        4-1:0]            seg_tmp   ;
wire                              flag_20us ;
integer                           ii        ;


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

assign add_cnt0 = 1;
assign end_cnt0 = add_cnt0 && cnt0==TIME_20US-1 ;

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
assign end_cnt1 = add_cnt1 && cnt1==SEG_NUM-1 ;

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        seg_sel <= {SEG_NUM{1'b1}};
    end
    else if(disp_en)
        seg_sel <= ~(1'b1 << cnt1);
    else 
        seg_sel <= {SEG_NUM{1'b1}};
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        din_ff0 <= 0;
    end
    else begin
        for(ii=0;ii<SEG_NUM;ii=ii+1)begin
            if(din_vld[ii]==1'b1)begin
                din_ff0[(ii+1)*4-1 -:4] <= din[(ii+1)*4-1 -:4];
            end
            else begin
                din_ff0[(ii+1)*4-1 -:4] <= din_ff0[(ii+1)*4-1 -:4];
            end
        end
    end
end

always  @(*)begin
    seg_tmp = din_ff0[(cnt1+1)*4-1 -:4]; 
end


always@(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        segment<=NUM_0;
    end
    else if(seg_tmp==0)begin
          segment<=NUM_0;
    end
    else if(seg_tmp==1)begin
          segment<=NUM_1;
     end
    else if(seg_tmp==2)begin
          segment<=NUM_2;
    end
    else if(seg_tmp==3)begin
          segment<=NUM_3;
    end
    else if(seg_tmp==4)begin
          segment<=NUM_4;
    end
    else if(seg_tmp==5)begin
          segment<=NUM_5;
    end
    else if(seg_tmp==6)begin
          segment<=NUM_6;
    end
    else if(seg_tmp==7)begin
          segment<=NUM_7;
    end
    else if(seg_tmp==8)begin
          segment<=NUM_8;
    end
    else if(seg_tmp==9)begin
          segment<=NUM_9;
    end
    else if(seg_tmp==4'hf)begin
          segment<=NUM_F;
    end
    else begin
        segment<=NUM_ERR;    
    end
end

endmodule
