`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/08/20 14:59:14
// Design Name: 
// Module Name: Data_Mclk_buf
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

module Data_Mclk_buf(
    input               i_per_clk       ,
    input               i_per_rst       ,

    input  [7 :0]       i_per_len       ,
    input  [7 :0]       i_per_data      ,
    input               i_per_last      ,
    input               i_per_valid     ,

    input               i_post_clk      ,
    input               i_post_rst      ,

    output [7 :0]       o_post_len      ,
    output [7 :0]       o_post_data     ,
    output              o_post_last     ,
    output              o_post_valid
);

/***************function**************/

/***************parameter*************/

/***************port******************/             

/***************mechine***************/

/***************reg*******************/
reg  [7 :0]             ro_post_len             ;
reg  [7 :0]             ro_post_data            ;
reg                     ro_post_last            ;
reg                     ro_post_valid           ;
reg  [7 :0]             ri_per_len              ;
reg  [7 :0]             ri_per_data             ;
reg                     ri_per_last             ;
reg                     ri_per_valid            ;
reg                     r_fifo_len_rd_en        ;
reg                     r_fifo_len_rd_en_1d     ;
reg                     r_run                   ;
reg  [7 :0]             r_post_cnt              ;
reg                     r_fifo_data_rd_en       ;
reg                     r_fifo_data_rd_en_1d    ;

/***************wire******************/     
wire                    w_fifo_len_empty        ;
wire [7 :0]             w_fifo_len_rdata        ;
wire [7 :0]             w_fifo_data_rdata       ;

/***************component*************/
//存数据
ASYNC_FIFO ASYNC_FIFO_U0 (
    .wr_clk             (i_per_clk      ),  // input wire wr_clk
    .wr_rst             (i_per_rst      ),  // input wire wr_rst
    .rd_clk             (i_post_clk     ),  // input wire rd_clk
    .rd_rst             (i_post_rst     ),  // input wire rd_rst
    .din                (ri_per_data    ),        // input wire [7 : 0] din
    .wr_en              (ri_per_valid   ),    // input wire wr_en
    .rd_en              (r_fifo_data_rd_en),    // input wire rd_en
    .dout               (w_fifo_data_rdata),      // output wire [7 : 0] dout
    .full               (),      // output wire full
    .empty              ()    // output wire empty
);
//存指令长度
ASYNC_FIFO ASYNC_FIFO_U1 (
    .wr_clk             (i_per_clk          ),  // input wire wr_clk
    .wr_rst             (i_per_rst          ),  // input wire wr_rst
    .rd_clk             (i_post_clk         ),  // input wire rd_clk
    .rd_rst             (i_post_rst         ),  // input wire rd_rst
    .din                (ri_per_len         ),        // input wire [7 : 0] din
    .wr_en              (ri_per_last        ),    // input wire wr_en
    .rd_en              (r_fifo_len_rd_en   ),    // input wire rd_en
    .dout               (w_fifo_len_rdata   ),      // output wire [7 : 0] dout
    .full               (),      // output wire full
    .empty              (w_fifo_len_empty   )    // output wire empty
);
/***************assign****************/
assign o_post_len   = ro_post_len       ;
assign o_post_data  = ro_post_data      ;
assign o_post_last  = ro_post_last      ;
assign o_post_valid = ro_post_valid     ;
/***************always****************/
always@(posedge i_per_clk,posedge i_per_rst)
begin
    if(i_per_rst) begin
        ri_per_len   <= 'd0;
        ri_per_data  <= 'd0;
        ri_per_last  <= 'd0;
        ri_per_valid <= 'd0;
    end else begin
        ri_per_len   <= i_per_len  ;
        ri_per_data  <= i_per_data ;
        ri_per_last  <= i_per_last ;
        ri_per_valid <= i_per_valid;
    end
end

always@(posedge i_post_clk,posedge i_post_rst)
begin
    if(i_post_rst)
        r_fifo_len_rd_en <= 'd0;
    else if(!w_fifo_len_empty && !r_run)
        r_fifo_len_rd_en <= 'd1;
    else 
        r_fifo_len_rd_en <= 'd0;
end

always@(posedge i_post_clk,posedge i_post_rst)
begin
    if(i_post_rst)
        r_fifo_len_rd_en_1d <= 'd0;
    else 
        r_fifo_len_rd_en_1d <= r_fifo_len_rd_en;
end

always@(posedge i_post_clk,posedge i_post_rst)
begin
    if(i_post_rst)
        r_run <= 'd0;
    else if(ro_post_last)
        r_run <= 'd0;
    else if(r_fifo_len_rd_en)
        r_run <= 'd1;
    else 
        r_run <= r_run;
end

always@(posedge i_post_clk,posedge i_post_rst)
begin
    if(i_post_rst)
        ro_post_len <= 'd0;
    else if(r_fifo_len_rd_en_1d)
        ro_post_len <= w_fifo_len_rdata;
    else 
        ro_post_len <= ro_post_len;
end
 
always@(posedge i_post_clk,posedge i_post_rst)
begin
    if(i_post_rst)
        r_fifo_data_rd_en <= 'd0;
    else if(r_post_cnt == ro_post_len - 1)
        r_fifo_data_rd_en <= 'd0;
    else if(r_fifo_len_rd_en_1d)
        r_fifo_data_rd_en <= 'd1;
    else 
        r_fifo_data_rd_en <= r_fifo_data_rd_en;
end

always@(posedge i_post_clk,posedge i_post_rst)
begin
    if(i_post_rst)
        r_fifo_data_rd_en_1d <= 'd0;
    else
        r_fifo_data_rd_en_1d <= r_fifo_data_rd_en;
end

always@(posedge i_post_clk,posedge i_post_rst)
begin
    if(i_post_rst)
        ro_post_valid <= 'd0;
    else if(ro_post_last)
        ro_post_valid <= 'd0;
    else if(r_fifo_data_rd_en_1d)
        ro_post_valid <= 'd1;
    else 
        ro_post_valid <= ro_post_valid;
end

always@(posedge i_post_clk,posedge i_post_rst)
begin
    if(i_post_rst)
        ro_post_last <= 'd0;
    else if(!r_fifo_data_rd_en && r_fifo_data_rd_en_1d)
        ro_post_last <= 'd1;
    else 
        ro_post_last <= 'd0;
end

always@(posedge i_post_clk,posedge i_post_rst)
begin
    if(i_post_rst)
        ro_post_data <= 'd0;
    else if(r_fifo_data_rd_en_1d)
        ro_post_data <= w_fifo_data_rdata;
    else 
        ro_post_data <= ro_post_data;
end

always@(posedge i_post_clk,posedge i_post_rst)
begin
    if(i_post_rst)
        r_post_cnt <= 'd0;
    else if(r_post_cnt == ro_post_len - 1)
        r_post_cnt <= 'd0;
    else if(r_fifo_data_rd_en)
        r_post_cnt <= r_post_cnt + 1;
    else 
        r_post_cnt <= r_post_cnt;
end


endmodule
