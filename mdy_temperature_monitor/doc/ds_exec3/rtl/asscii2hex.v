module asscii2hex(
               clk      ,
               rst_n    ,
               din      ,
               din_vld  ,
               dout     ,
               dout_vld  
 );

 input              clk     ;
 input              rst_n   ;
 input [7:0]        din     ;
 input              din_vld ;
 output[3:0]        dout    ;
 output             dout_vld;
 reg   [3:0]        dout    ;
 reg                dout_vld;


 always  @(posedge clk or negedge rst_n)begin
     if(rst_n==1'b0)begin
         dout<= 0 ;
     end
     else if(din_vld)begin
         if(din>=8'd48&&din<8'd58)begin
             dout <= din - 8'd48;
         end
         else if(din>=8'd65&&din<8'd71)begin
             dout <= din - 8'd55;
         end
         else if(din>=8'd97&&din<8'd123)begin
             dout <= din - 8'd87;
         end
         else begin
             dout <= 0;
         end
     end
     else begin
         dout<=dout;
     end
 end


 always  @(posedge clk or negedge rst_n)begin
     if(rst_n==1'b0)begin
         dout_vld<= 1'b0 ;
     end
     else if(din_vld && ((din>=8'd48&&din<8'd58) || (din>=8'd65&&din<8'd71)||(din>=8'd97&&din<8'd123)))begin
         dout_vld<= 1'b1 ;
     end
     else begin
         dout_vld<= 1'b0 ;
     end
 end

endmodule 
