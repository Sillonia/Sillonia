`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/08/20 14:59:14
// Design Name: 
// Module Name: AD7606_Data_pkt
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module AD7606_Data_pkt(
    input           i_clk           ,
    input           i_rst           ,
    input  [15:0]   i_user_data_1   ,
    input           i_user_valid_1  ,
    input  [15:0]   i_user_data_2   ,
    input           i_user_valid_2  ,
    input  [15:0]   i_user_data_3   ,
    input           i_user_valid_3  ,
    input  [15:0]   i_user_data_4   ,
    input           i_user_valid_4  ,
    input  [15:0]   i_user_data_5   ,
    input           i_user_valid_5  ,
    input  [15:0]   i_user_data_6   ,
    input           i_user_valid_6  ,
    input  [15:0]   i_user_data_7   ,
    input           i_user_valid_7  ,
    input  [15:0]   i_user_data_8   ,
    input           i_user_valid_8  ,

    input  [7 :0]   i_cap_channel   ,
    input           i_cap_seek      ,

    output [7 :0]   o_adc_len       ,
    output [7 :0]   o_adc_data      ,
    output          o_adc_last      ,
    output          o_adc_valid 
);

/***************function**************/

/***************parameter*************/

/***************port******************/             

/***************mechine***************/

/***************reg*******************/
reg  [15:0]         ri_user_data_1  ;
reg                 ri_user_valid_1 ;
reg  [15:0]         ri_user_data_2  ;
reg                 ri_user_valid_2 ;
reg  [15:0]         ri_user_data_3  ;
reg                 ri_user_valid_3 ;
reg  [15:0]         ri_user_data_4  ;
reg                 ri_user_valid_4 ;
reg  [15:0]         ri_user_data_5  ;
reg                 ri_user_valid_5 ;
reg  [15:0]         ri_user_data_6  ;
reg                 ri_user_valid_6 ;
reg  [15:0]         ri_user_data_7  ;
reg                 ri_user_valid_7 ;
reg  [15:0]         ri_user_data_8  ;
reg                 ri_user_valid_8 ;
reg  [7 :0]         ri_cap_channel  ;
reg                 ri_cap_seek     ;
reg  [7 :0]         ro_adc_len      ;
reg  [7 :0]         ro_adc_data     ;
reg                 ro_adc_last     ;
reg                 ro_adc_valid    ;
reg  [7 :0]         r_cnt           ;
reg  [7 :0]         r_adc_per_data  ;
reg                 r_adc_per_valid ;
reg                 r_valid_end     ;
reg                 r_fifo_rd_en    ;
reg                 r_fifo_rd_en_1d ;
reg  [7 :0]         r_send_cnt      ;
/***************wire******************/
wire [7 :0]         w_fifo_dout     ;
wire                w_fifo_empty    ;

/***************component*************/
FIFO_8X1024 FIFO_8X1024_u0 (
  .clk              (i_clk          ),      // input wire clk
  .srst             (i_rst          ),    // input wire srst
  .din              (r_adc_per_data ),      // input wire [7 : 0] din
  .wr_en            (r_adc_per_valid),  // input wire wr_en
  .rd_en            (r_fifo_rd_en   ),  // input wire rd_en
  .dout             (w_fifo_dout    ),    // output wire [7 : 0] dout
  .full             (),    // output wire full
  .empty            (w_fifo_empty   )  // output wire empty
);
/***************assign****************/
assign o_adc_len   = ro_adc_len     ;
assign o_adc_data  = ro_adc_data    ;
assign o_adc_last  = ro_adc_last    ;
assign o_adc_valid = ro_adc_valid   ;
/***************always****************/
always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst) begin
        ri_user_data_1  <= 'd0;
        ri_user_valid_1 <= 'd0;
        ri_user_data_2  <= 'd0;
        ri_user_valid_2 <= 'd0;
        ri_user_data_3  <= 'd0;
        ri_user_valid_3 <= 'd0;
        ri_user_data_4  <= 'd0;
        ri_user_valid_4 <= 'd0;
        ri_user_data_5  <= 'd0;
        ri_user_valid_5 <= 'd0;
        ri_user_data_6  <= 'd0;
        ri_user_valid_6 <= 'd0;
        ri_user_data_7  <= 'd0;
        ri_user_valid_7 <= 'd0;
        ri_user_data_8  <= 'd0;
        ri_user_valid_8 <= 'd0;
        ri_cap_channel  <= 'd0;
        ri_cap_seek     <= 'd0;
    end else begin
        ri_user_data_1  <= i_user_data_1 ;
        ri_user_valid_1 <= i_user_valid_1;
        ri_user_data_2  <= i_user_data_2 ;
        ri_user_valid_2 <= i_user_valid_2;
        ri_user_data_3  <= i_user_data_3 ;
        ri_user_valid_3 <= i_user_valid_3;
        ri_user_data_4  <= i_user_data_4 ;
        ri_user_valid_4 <= i_user_valid_4;
        ri_user_data_5  <= i_user_data_5 ;
        ri_user_valid_5 <= i_user_valid_5;
        ri_user_data_6  <= i_user_data_6 ;
        ri_user_valid_6 <= i_user_valid_6;
        ri_user_data_7  <= i_user_data_7 ;
        ri_user_valid_7 <= i_user_valid_7;
        ri_user_data_8  <= i_user_data_8 ;
        ri_user_valid_8 <= i_user_valid_8;
        ri_cap_channel  <= i_cap_channel ;
        ri_cap_seek     <= i_cap_seek    ;
    end
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_adc_per_data <= 'd0; 
    else case(r_cnt)
        0       :r_adc_per_data <= 8'h55;                                                               //前导码
        1       :r_adc_per_data <= 'd5;                                                                 //指令
        2       :r_adc_per_data <= ri_cap_channel + ri_cap_channel + ri_cap_channel;                    //长度
        3       :r_adc_per_data <= 1;                                                                   //通道数
        4       :r_adc_per_data <= ri_user_data_1[15:8];                                                //数据高字节
        5       :r_adc_per_data <= ri_user_data_1[7 :0];                                                //数据低字节   
        6       :r_adc_per_data <= 2;                                                                   //通道数
        7       :r_adc_per_data <= ri_user_data_2[15:8];                                                //数据高字节
        8       :r_adc_per_data <= ri_user_data_2[7 :0];                                                //数据低字节
        9       :r_adc_per_data <= 3;                                                                   //通道数
        10      :r_adc_per_data <= ri_user_data_3[15:8];                                                //数据高字节
        11      :r_adc_per_data <= ri_user_data_3[7 :0];                                                //数据低字节
        12      :r_adc_per_data <= 4;                                                                   //通道数
        13      :r_adc_per_data <= ri_user_data_4[15:8];                                                //数据高字节
        14      :r_adc_per_data <= ri_user_data_4[7 :0];                                                //数据低字节
        15      :r_adc_per_data <= 5;                                                                   //通道数
        16      :r_adc_per_data <= ri_user_data_5[15:8];                                                //数据高字节
        17      :r_adc_per_data <= ri_user_data_5[7 :0];                                                //数据低字节
        18      :r_adc_per_data <= 6;                                                                   //通道数
        19      :r_adc_per_data <= ri_user_data_6[15:8];                                                //数据高字节
        20      :r_adc_per_data <= ri_user_data_6[7 :0];                                                //数据低字节
        21      :r_adc_per_data <= 7;                                                                   //通道数
        22      :r_adc_per_data <= ri_user_data_7[15:8];                                                //数据高字节
        23      :r_adc_per_data <= ri_user_data_7[7 :0];                                                //数据低字节
        24      :r_adc_per_data <= 8;                                                                   //通道数
        25      :r_adc_per_data <= ri_user_data_8[15:8];                                                //数据高字节
        26      :r_adc_per_data <= ri_user_data_8[7 :0];                                                //数据低字节
    endcase
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_cnt <= 'd0;
    else if(r_cnt == 2 + (ri_cap_channel + ri_cap_channel + ri_cap_channel))
        r_cnt <= 'd0;
    else if(r_cnt > 4)
        r_cnt <= r_cnt + 1;
    else if(r_cnt == 4 && ri_user_valid_1)
        r_cnt <= r_cnt + 1;
    else if(ri_cap_seek || (r_cnt > 0 && r_cnt < 4))
        r_cnt <= r_cnt + 1;
    else 
        r_cnt <= r_cnt;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_adc_per_valid <= 'd0;
    else if((r_cnt == 4 && !ri_user_valid_1) || r_valid_end)
        r_adc_per_valid <= 'd0;
    else if(ri_cap_seek || (ri_user_valid_1 && r_cnt >= 4))
        r_adc_per_valid <= 'd1;
    else 
        r_adc_per_valid <= r_adc_per_valid;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_valid_end <= 'd0;
    else if(r_cnt == 2 + (ri_cap_channel + ri_cap_channel + ri_cap_channel))
        r_valid_end <= 'd1;
    else 
        r_valid_end <= 'd0;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)    
        r_fifo_rd_en <= 'd0;
    else if(w_fifo_empty)
        r_fifo_rd_en <= 'd0;
    else if(r_valid_end)
        r_fifo_rd_en <= 'd1;
    else 
        r_fifo_rd_en <= r_fifo_rd_en;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_fifo_rd_en_1d <= 'd0;
    else 
        r_fifo_rd_en_1d <= r_fifo_rd_en;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst) begin
        ro_adc_len   <= 'd0;
        ro_adc_data  <= 'd0;
    end else if(r_fifo_rd_en_1d) begin
        ro_adc_len   <= 'd27;
        ro_adc_data  <= w_fifo_dout;
    end else begin 
        ro_adc_len   <= 'd0;
        ro_adc_data  <= 'd0;
        
    end
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        ro_adc_valid <= 'd0;
    else if(ro_adc_last)
        ro_adc_valid <= 'd0;
    else if(r_fifo_rd_en_1d)
        ro_adc_valid <= 'd1;
    else 
        ro_adc_valid <= ro_adc_valid;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        ro_adc_last  <= 'd0;
    else if(r_send_cnt ==  1 + (ri_cap_channel + ri_cap_channel + ri_cap_channel))
        ro_adc_last  <= 'd1;
    else 
        ro_adc_last  <= 'd0;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_send_cnt <= 'd0;
    else if(ro_adc_valid)
        r_send_cnt <= r_send_cnt + 1;
    else
        r_send_cnt <= 'd0;
end
endmodule
