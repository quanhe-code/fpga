module key_scan(
    clk         ,
    rst_n       ,
    key_col     ,
    key_row     ,
    key_num     ,
    key_vld              
);

    parameter     T20MS = 20'd500_000;     //25m时钟
    parameter     CHK_COL = 2'b00,CHK_ROW = 2'b01,WAIT = 2'b10;

    //输入信号定义
    input         clk     ;
    input         rst_n   ;
    input  [3:0]  key_col ;

    //输出信号定义
    output [3:0]  key_row ;
    output [3:0]  key_num ;
    output        key_vld ;

    //输出信号reg定义
    reg    [3:0]  key_row ;
//    reg    [3:0]  key_num ;
    reg           key_vld ;

    //中间信号定义
    reg [1:0]     state_c ;
    reg [1:0]     state_n ;
    reg [3:0]     key_col_ff0;
    reg [3:0]     key_col_ff1;
    reg [19:0]    count_20ms ;
    reg           keep_count_20ms_ff0;
    reg [3:0]     count_row;
    reg [3:0]     count_row_step;
    reg [1:0]     col_num;
    reg [1:0]     row_num;
    reg [3:0]     count_wait;

    wire          col_row ;
    wire          row_wait;
    wire          wait_col;
    wire          add_count_20ms;
    wire          keep_count_20ms;
    wire          l2h;
    wire          add_count_row;
    wire          end_count_row;
    wire          add_count_row_step;
    wire          end_count_row_step;
    wire          flag_key_vld;
    wire          add_count_wait;
    wire          keep_count_wait;

    //三段式状态机

    always @ (posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            state_c <= CHK_COL;
        end
        else begin
            state_c <= state_n;
        end
    end

    always @ (*)begin
        case(state_c)
            CHK_COL:begin
                if(col_row)begin
                    state_n = CHK_ROW;
                end
                else begin
                    state_n = state_c;
                end
            end
            CHK_ROW:begin
                if(row_wait)begin
                    state_n = WAIT;
                end
                else begin
                    state_n = state_c;
                end
            end
            WAIT:begin
                if(wait_col)begin
                    state_n = CHK_COL;
                end
                else begin
                    state_n = state_c;
                end
            end
            default:begin
                state_n = CHK_COL;
            end
        endcase
    end

    assign col_row  = state_c == CHK_COL && l2h;
    assign row_wait = state_c == CHK_ROW && end_count_row_step;
    assign wait_col = state_c == WAIT && keep_count_wait && key_col_ff1 == 4'b1111;

    always @ (posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            key_col_ff0 <= 4'b1111;
            key_col_ff1 <= 4'b1111;
        end
        else begin
            key_col_ff0 <= key_col;
            key_col_ff1 <= key_col_ff0;
        end
    end

    always @ (posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            count_20ms <= 0;
        end
        else if(add_count_20ms)begin
            if(keep_count_20ms)begin
                count_20ms <= T20MS-1;
            end
            else begin
                count_20ms <= count_20ms + 1;
            end
        end
        else begin
            count_20ms <= 0;
        end
    end

    assign add_count_20ms  = state_c == CHK_COL && key_col_ff1 != 4'b1111;
    assign keep_count_20ms = add_count_20ms && count_20ms == T20MS-1;

    always @ (posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            keep_count_20ms_ff0 <= 0;
        end
        else begin
            keep_count_20ms_ff0 <= keep_count_20ms;
        end
    end

    assign l2h = keep_count_20ms == 1 && keep_count_20ms_ff0 == 0;

    always @ (posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            count_row <= 0;
        end
        else if(add_count_row)begin
            if(end_count_row)begin
                count_row <= 0;
            end
            else begin
                count_row <= count_row + 1;
            end
        end
    end

    assign add_count_row = state_c == CHK_ROW;
    assign end_count_row = add_count_row && count_row == 8-1;

    always @ (posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            count_row_step <= 0;
        end
        else if(add_count_row_step)begin
            if(end_count_row_step)begin
                count_row_step <= 0;
            end
            else begin
                count_row_step <= count_row_step + 1;
            end
        end
    end

    assign add_count_row_step = end_count_row;
    assign end_count_row_step = add_count_row_step && count_row_step == 4-1;

    always @ (posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            key_row <= 0;
        end
        else if(state_c == CHK_ROW)begin
            key_row <= ~(1 << count_row_step);
        end
        else begin
            key_row <= 4'b0000;
        end
    end

    always @ (posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            col_num <= 0;
        end
        else if(state_c == CHK_COL && col_row)begin
            if(key_col_ff1 == 4'b1110)begin
                col_num <= 0;
            end
            else if(key_col_ff1 == 4'b1101)begin
                col_num <= 1;
            end
            else if(key_col_ff1 == 4'b1011)begin
                col_num <= 2;
            end
            else if(key_col_ff1 == 4'b0111)begin
                col_num <= 3;
            end
        end
    end

    always @ (posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            row_num <= 0;
        end
        else if(state_c == CHK_ROW)begin
            row_num <= count_row_step[1:0];
        end
    end

    assign key_num = {row_num,col_num};

    always @ (posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            key_vld <= 0;
        end
        else if(state_c == CHK_ROW && flag_key_vld)begin
            key_vld <= 1;
        end
        else begin
            key_vld <= 0;
        end
    end

    assign flag_key_vld = count_row == 8-1 && key_col_ff1[col_num] == 0;

    always @ (posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            count_wait <= 0;
        end
        else if(add_count_wait)begin
            if(keep_count_wait)begin
                count_wait <= 8-1;
            end
            else begin
                count_wait <= count_wait + 1;
            end
        end
        else begin
            count_wait <= 0;
        end
    end

    assign add_count_wait  = state_c == WAIT;
    assign keep_count_wait = add_count_wait && count_wait == 8-1;


    endmodule

