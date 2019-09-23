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
 output reg [3:0]   dout    ;
 output reg         dout_vld;

wire con_shuzi;
wire con_lowcase;
wire con_upcase;

 always  @(posedge clk or negedge rst_n)begin
     if(rst_n==1'b0)begin
     end
     else if(con_shuzi)begin
         dout <= (din - 48);
     end
     else if(con_upcase)begin
         dout <= (din - 8'd55);
     end
     else if(con_lowcase) begin
         dout <= (din - 8'd87);
     end
     else begin
         dout <= 0;
     end
 end

 always  @(posedge clk or negedge rst_n)begin
     if(rst_n==1'b0)begin
         dout_vld <= 0;
     end
     else if(con_shuzi || con_lowcase || con_upcase)begin
         dout_vld <= 1;
     end
     else begin 
         dout_vld <= 0;
     end
 end
 



 assign con_shuzi = din_vld && (din >= 48 && din < 58);
 assign con_upcase = din_vld && (din >= 65 && din < 71);
 assign con_lowcase = din_vld && (din >= 97 && din < 103);

endmodule 
