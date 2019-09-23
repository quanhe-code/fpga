module vga_driver(
    clk         ,
    rst_n       ,
   
    vga_clk     , 
    vga_hys     ,
    vga_vys     ,
    vga_rgb     ,
    vga_blank_n ,
    
    din         ,
    rd_addr     ,
    rd_en       ,

    wr_end      ,
    rd_end      ,
    rd_addr_sel  
);
    parameter       DATA_AHEAD = 8'd3;
    parameter       DATA_W = 8'd16;
    parameter       VGA_WIDTH = 16'd640;    
    parameter       VGA_HSPW = 8'd96;
    parameter       VGA_HBP = 8'd48;
    parameter       VGA_HFP = 8'd16;
    parameter       VGA_HEIGHT = 16'd480;
    parameter       VGA_VSPW = 8'd2;
    parameter       VGA_VBP = 8'd33;
    parameter       VGA_VFP = 8'd10;
    
 //   parameter       DATA_AHEAD = 8'd1;
 //   parameter       DATA_W = 8'd16;
 //   parameter       VGA_WIDTH = 16'd1024;    
 //   parameter       VGA_HSPW = 8'd20;
 //   parameter       VGA_HBP = 8'd218;
 //   parameter       VGA_HFP = 8'd82;
 //   parameter       VGA_HEIGHT = 16'd600;
 //   parameter       VGA_VSPW = 8'd6;
 //   parameter       VGA_VBP = 8'd23;
 //   parameter       VGA_VFP = 8'd37;
    
    localparam      SHOW_WIDTH = 16'd320;
    localparam      SHOW_HEIGHT = 16'd200;
    localparam      SHOW_START_HORIZON = VGA_HSPW + VGA_HBP + ((VGA_WIDTH - SHOW_WIDTH) / 8'd2);
    localparam      SHOW_START_VERTICAL = VGA_VSPW + VGA_VBP + ((VGA_HEIGHT - SHOW_HEIGHT) / 8'd2);

    input                       clk      ;
    input                       rst_n    ;
   
    
    output                      vga_clk;
    output reg                  vga_hys    ;
    output reg                  vga_vys    ;
    output reg  [DATA_W-1:0]    vga_rgb    ;
    output                      vga_blank_n;
    
    input                       din      ;
    input                       wr_end   ;
    output reg  [15:0]          rd_addr    ;
    output reg                  rd_en      ;
    output reg                  rd_end     ;
    output reg                  rd_addr_sel;
    
    wire                        vga_en;
    wire                        show_area_en;

    reg  [15:0]     cnt0;
    wire            add_cnt0;
    wire            end_cnt0;

    reg  [15:0]     cnt1;
    wire            add_cnt1;
    wire            end_cnt1;


    assign vga_clk = ~clk;
    assign vga_blank_n = 1'b1;

    always @(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            cnt0 <= 0;
        end
        else if(add_cnt0)begin
            if(end_cnt0)
                cnt0 <= 0;
            else
                cnt0 <= cnt0 + 1'b1;
        end
    end

    assign add_cnt0 = (rst_n == 1'b1);
    assign end_cnt0 = add_cnt0 && cnt0== (VGA_HSPW + VGA_HBP + VGA_WIDTH + VGA_HFP - 1);

    always @(posedge clk or negedge rst_n)begin 
        if(!rst_n)begin
            cnt1 <= 0;
        end
        else if(add_cnt1)begin
            if(end_cnt1)
                cnt1 <= 0;
            else
                cnt1 <= cnt1 + 1'b1;
        end
    end

    assign add_cnt1 = end_cnt0;
    assign end_cnt1 = add_cnt1 && cnt1== (VGA_VSPW + VGA_VBP + VGA_HEIGHT + VGA_VFP - 1);

    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            vga_hys <= 1'b1;
        end
        else if(add_cnt0 && cnt0 == (1 - 1))begin
            vga_hys <= 1'b0;
        end
        else if(add_cnt0 && cnt0 == (VGA_HSPW - 1))begin
            vga_hys <= 1'b1;
        end
    end

    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            vga_vys <= 1'b1;
        end
        else if(add_cnt1 && cnt1 == (1 - 1))begin
            vga_vys <= 1'b0;
        end
        else if(add_cnt1 && cnt1 == (VGA_VSPW - 1))begin
            vga_vys <= 1'b1;
        end
    end


   assign vga_en = cnt0 >= (VGA_HSPW + VGA_HBP) 
                            && cnt0 < (VGA_HSPW + VGA_HBP + VGA_WIDTH)
                            && cnt1 >= (VGA_VSPW + VGA_VBP) 
                            && cnt1 < (VGA_VSPW + VGA_VBP + VGA_HEIGHT);

   assign show_area_en = cnt0 >= SHOW_START_HORIZON && cnt0 < (SHOW_START_HORIZON + SHOW_WIDTH)
                            && cnt1 >= SHOW_START_VERTICAL && cnt1 < (SHOW_START_VERTICAL + SHOW_HEIGHT);
   always  @(posedge clk or negedge rst_n)begin
       if(rst_n==1'b0)begin
           vga_rgb <= {DATA_W{1'b0}};
       end
       else if(vga_en)begin
            if(show_area_en)begin
                vga_rgb <= {16{din}};
            end 
            else begin
                vga_rgb <= 16'hFFFF;
            end
       end
       else begin
           vga_rgb <= {DATA_W{1'b0}};
       end
   end


   always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            rd_addr <= 16'h0000;
        end
        else if(cnt0 >= (SHOW_START_HORIZON - DATA_AHEAD)
                && cnt0 < (SHOW_START_HORIZON- DATA_AHEAD + SHOW_WIDTH)
                && cnt1 >= SHOW_START_VERTICAL 
                && cnt1 < (SHOW_START_VERTICAL + SHOW_HEIGHT))begin
            rd_addr <= (cnt0 - (SHOW_START_HORIZON - DATA_AHEAD)) + ((cnt1 - SHOW_START_VERTICAL) * SHOW_WIDTH);
        end
        else begin
            rd_addr <= 16'h0000;
        end
    end

    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            rd_en <= 1'b0;
        end
        else if(cnt0 >= (SHOW_START_HORIZON - DATA_AHEAD)
                && cnt0 < (SHOW_START_HORIZON- DATA_AHEAD + SHOW_WIDTH)
                && cnt1 >= SHOW_START_VERTICAL 
                && cnt1 < (SHOW_START_VERTICAL + SHOW_HEIGHT))begin
            rd_en <= 1'b1;
        end
        else begin
            rd_en <= 1'b0;
        end
    end

    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            rd_end <= 1'b0;
        end
        else if(end_cnt1)begin
            rd_end <= 1'b1;
        end
        else begin
            rd_end <= 1'b0;
        end
    end

    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            rd_addr_sel <= 1'b0;
        end
        else if(wr_end && rd_end)begin
            rd_addr_sel <= ~rd_addr_sel;
        end
    end

endmodule

