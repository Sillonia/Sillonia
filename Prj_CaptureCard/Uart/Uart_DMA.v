`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/07/22 10:08:58
// Design Name: 
// Module Name: flash_ctrl
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

module Uart_DMA(
    input           i_clk                           ,
    input           i_rst                           ,

    output [7: 0]   o_user_tx_data                  ,
    output          o_user_tx_valid                 ,
    input           i_user_tx_ready                 ,

    input  [7: 0]   i_user_rx_data                  ,
    input           i_user_rx_valid                 ,

    input  [7 :0]   i_uart_send_data                ,
    input           i_uart_send_last                ,
    input           i_uart_send_valid               ,
    output          o_uart_send_ready               ,

    output [7 :0]   o_uart_rec_len                  ,
    output [7 :0]   o_uart_rec_data                 ,
    output          o_uart_rec_last                 ,
    output          o_uart_rec_valid                
);

/***************function**************/

/***************parameter*************/

/***************port******************/             

/***************mechine***************/


/***************reg*******************/
reg  [7 :0]         ro_uart_DMA_data                ;
reg                 ro_uart_DMA_last                ;
reg                 ro_uart_DMA_valid               ;
reg  [7: 0]         ro_user_tx_data                 ;
reg                 ro_user_tx_valid                ;
reg                 ri_user_tx_ready                ;
reg  [7: 0]         ri_user_rx_data                 ;
reg                 ri_user_rx_valid                ;
reg  [7 :0]         r_rec_cnt                       ;
reg  [7 :0]         r_rec_len                       ;
reg                 r_rec_end                       ;
reg                 r_send_trig                     ;
reg  [7 :0]         r_rec_end_len                   ;
reg  [7 :0]         r_send_cnt                      ;
reg  [7 :0]         r_send_1_cnt                    ;
reg                 r_fifo_rd_en                    ;
reg                 r_fifo_rd_en_1d                 ;
reg                 ro_uart_send_ready              ;
reg                 r_send_run                      ;
reg  [7 :0]         r_send_len                      ;
reg  [7 :0]         r_uart_send_cnt                 ;
reg                 r_fifo_send_rd_en               ;
reg                 r_fifo_send_rd_en_1d            ;
reg  [7 :0]         ro_uart_rec_len                 ;

/***************wire******************/
wire [7 :0]         w_fifo_rd_data                  ;
wire                w_fifo_full                     ;
wire                w_fifo_empty                    ;
wire                w_send_active                   ;
wire                w_fifo_send_full                ;
wire                w_fifo_send_empty               ;
wire [7 :0]         w_fifo_send_rd_data             ;
wire                w_uart_tx_active                ;


/***************component*************/
FIFO_8X1024 FIFO_8X1024_REC_U0 (
  .clk                      (i_clk              ), 
  .srst                     (i_rst              ), 
  .din                      (ri_user_rx_data    ), 
  .wr_en                    (ri_user_rx_valid   ), 
  .rd_en                    (r_fifo_rd_en       ), 
  .dout                     (w_fifo_rd_data     ), 
  .full                     (w_fifo_full        ), 
  .empty                    (w_fifo_empty       )  
);

FIFO_8X1024 FIFO_8X1024_SEND_U0 (
  .clk                      (i_clk              ), 
  .srst                     (i_rst              ), 
  .din                      (i_uart_send_data   ), 
  .wr_en                    (w_send_active      ), 
  .rd_en                    (r_fifo_send_rd_en  ), 
  .dout                     (w_fifo_send_rd_data), 
  .full                     (w_fifo_send_full   ), 
  .empty                    (w_fifo_send_empty  )  
);

/***************assign****************/
assign o_uart_rec_data   = ro_uart_DMA_data         ;
assign o_uart_rec_last   = ro_uart_DMA_last         ;
assign o_uart_rec_valid  = ro_uart_DMA_valid        ;
assign o_user_tx_data    = ro_user_tx_data          ;
assign o_user_tx_valid   = ro_user_tx_valid         ;
assign w_send_active     = i_uart_send_valid & o_uart_send_ready;
assign o_uart_send_ready = !w_fifo_full       ;    
assign w_uart_tx_active  = o_user_tx_valid & i_user_tx_ready;
assign o_uart_rec_len    = ro_uart_rec_len          ;

/***************always****************/
always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst) begin
        ri_user_rx_data  <= 'd0;
        ri_user_rx_valid <= 'd0;
    end else begin
        ri_user_rx_data  <= i_user_rx_data ;
        ri_user_rx_valid <= i_user_rx_valid;
    end

end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_rec_cnt <= 'd0;
    else if(r_rec_cnt == 3 + r_rec_len - 1 && ri_user_rx_valid)
        r_rec_cnt <= 'd0;
    else if(ri_user_rx_valid && ri_user_rx_data == 8'h55)
        r_rec_cnt <= r_rec_cnt + 1;
    else if(r_rec_cnt > 0 && ri_user_rx_valid)
        r_rec_cnt <= r_rec_cnt + 1;
    else     
        r_rec_cnt <= r_rec_cnt;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_rec_len <= 'd255;
    else if(r_rec_cnt == 2 && ri_user_rx_valid)
        r_rec_len <= ri_user_rx_data;
    else 
        r_rec_len <= r_rec_len;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_rec_end <= 'd0;
    else if(r_send_trig)
        r_rec_end <= 'd0;
    else if(r_rec_cnt == 3 + r_rec_len - 1 && ri_user_rx_valid)
        r_rec_end <= 'd1;
    else 
        r_rec_end <= r_rec_end;
end


always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_send_trig <= 'd0;
    else if(r_send_trig)
        r_send_trig <= 'd0;
    else if(r_rec_end && !o_uart_rec_valid)
        r_send_trig <= 'd1;
    else 
        r_send_trig <= r_send_trig;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_rec_end_len <= 'd0;
    else if(r_rec_cnt == 3 + r_rec_len - 1 && ri_user_rx_valid)
        r_rec_end_len <= r_rec_len;
    else 
        r_rec_end_len <= r_rec_end_len;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_fifo_rd_en <= 'd0;
    else if(r_send_1_cnt == 3 + r_rec_end_len - 1)
        r_fifo_rd_en <= 'd0;
    else if(r_send_trig)
        r_fifo_rd_en <= 'd1;
    else 
        r_fifo_rd_en <= r_fifo_rd_en;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_send_1_cnt <= 'd0;
    else if(r_fifo_rd_en)
        r_send_1_cnt <= r_send_1_cnt + 1;
    else 
        r_send_1_cnt <= 'd0;
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
    if(i_rst)
        ro_uart_DMA_data <= 'd0;
    else if(r_fifo_rd_en_1d)    
        ro_uart_DMA_data <= w_fifo_rd_data;
    else 
        ro_uart_DMA_data <= ro_uart_DMA_data;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        ro_uart_DMA_valid <= 'd0;
    else if(r_fifo_rd_en_1d)    
        ro_uart_DMA_valid <= 'd1;
    else 
        ro_uart_DMA_valid <= 'd0;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        ro_uart_DMA_last <= 'd0;
    else if(r_send_1_cnt == 3 + r_rec_end_len)
        ro_uart_DMA_last <= 'd1;
    else 
        ro_uart_DMA_last <= 'd0;
end

/*--------send data--------*/

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_fifo_send_rd_en <= 'd0;
    else if(r_fifo_send_rd_en)
        r_fifo_send_rd_en <= 'd0;
    else if (!w_fifo_send_empty && i_user_tx_ready && r_uart_send_cnt == 0)
        r_fifo_send_rd_en <= 'd1;
    else 
        r_fifo_send_rd_en <= 'd0;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_uart_send_cnt <= 'd0;
    else if(r_uart_send_cnt == 3)
        r_uart_send_cnt <= 'd0;
    else if(r_fifo_send_rd_en || r_uart_send_cnt > 0)
        r_uart_send_cnt <= r_uart_send_cnt + 1;
    else 
        r_uart_send_cnt <= r_uart_send_cnt;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_fifo_send_rd_en_1d <= 'd0;
    else
        r_fifo_send_rd_en_1d <= r_fifo_send_rd_en;
end 

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        ro_user_tx_valid <= 'd0;
    else if(r_fifo_send_rd_en_1d)
        ro_user_tx_valid <= 'd1;
    else
        ro_user_tx_valid <= 'd0;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        ro_user_tx_data <= 'd0;
    else if(r_fifo_send_rd_en_1d)
        ro_user_tx_data <= w_fifo_send_rd_data;
    else
        ro_user_tx_data <= 'd0;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        ro_uart_rec_len <= 'd0;
    else
        ro_uart_rec_len <= 3 + r_rec_end_len;
end

endmodule
