`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/07/09 20:32:42
// Design Name: 
// Module Name: uart_tx
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


module uart_tx#(
    parameter                           P_SYSTEM_CLK      = 50_000_000  ,   //输入时钟频率
    parameter                           P_UART_BUADRATE   = 9600        ,   //波特率
    parameter                           P_UART_DATA_WIDTH = 8           ,   //数据宽度
    parameter                           P_UART_STOP_WIDTH = 1           ,   //1或者2
    parameter                           P_UART_CHECK      = 0               //None=0 Odd-1 Even-2
)(                  
    input                               i_clk                           ,
    input                               i_rst                           ,

    output                              o_uart_tx                       ,

    input  [P_UART_DATA_WIDTH - 1 : 0]  i_user_tx_data                  ,
    input                               i_user_tx_valid                 ,
    output                              o_user_tx_ready                 
);

/***************function**************/

/***************parameter*************/

/***************port******************/             

/***************mechine***************/

/***************reg*******************/
reg                                 ro_uart_tx          ;
reg                                 ro_user_tx_ready    ;
reg  [15:0]                         r_cnt               ;//计数器位宽高于16bit时，组合逻辑的逻辑级数过高，谨慎使用。
reg  [P_UART_DATA_WIDTH - 1 : 0]    r_tx_data           ;
reg                                 r_tx_check          ;

/***************wire******************/

/***************component*************/

/***************assign****************/
assign o_uart_tx        = ro_uart_tx        ;
assign o_user_tx_ready  = ro_user_tx_ready  ;
assign w_tx_active      = i_user_tx_valid & o_user_tx_ready;

/***************always****************/
always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        ro_user_tx_ready <= 'd1;
    else if(w_tx_active)
        ro_user_tx_ready <= 'd0;
    else if(r_cnt == 2 + P_UART_DATA_WIDTH + P_UART_STOP_WIDTH - 3 && P_UART_CHECK == 0)
        ro_user_tx_ready <= 'd1;
    else if(r_cnt == 2 + P_UART_DATA_WIDTH + P_UART_STOP_WIDTH - 2 && P_UART_CHECK > 0)
        ro_user_tx_ready <= 'd1;
    else 
        ro_user_tx_ready <= ro_user_tx_ready;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_cnt <= 'd0;
    else if(r_cnt == 3 + P_UART_DATA_WIDTH + P_UART_STOP_WIDTH - 3 && P_UART_CHECK == 0)
        r_cnt <= 'd0;
    else if(r_cnt == 3 + P_UART_DATA_WIDTH + P_UART_STOP_WIDTH - 2 && P_UART_CHECK > 0)
        r_cnt <= 'd0;
    else if(!ro_user_tx_ready)
        r_cnt <= r_cnt + 1;
    else 
        r_cnt <= r_cnt;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_tx_data <= 'd0;
    else if(w_tx_active)
        r_tx_data <= i_user_tx_data;
    else if(!ro_user_tx_ready)
        r_tx_data <= r_tx_data >> 1;
    else 
        r_tx_data <= r_tx_data;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)    
        ro_uart_tx <= 'd1;
    else if(w_tx_active)
        ro_uart_tx <= 'd0;
    else if(r_cnt == 3 + P_UART_DATA_WIDTH - 3 && P_UART_CHECK > 0)//开启了校验位
        ro_uart_tx <= P_UART_CHECK == 1 ? ~r_tx_check : r_tx_check;//判断开启的是奇校验还是偶校验
    else if(r_cnt >= 3 + P_UART_DATA_WIDTH - 3 && P_UART_CHECK == 0)//没有开启校验位，直接发送停止位
        ro_uart_tx <= 'd1;
    else if(r_cnt >= 3 + P_UART_DATA_WIDTH - 2 && P_UART_CHECK > 0)//开启了校验位，发送完校验位在发送停止位
        ro_uart_tx <= 'd1;
    else if(!ro_user_tx_ready)//发送数据
        ro_uart_tx <= r_tx_data[0];
    else 
        ro_uart_tx <= 'd1;
end

//奇偶算错了
// always@(posedge i_clk,posedge i_rst)
// begin
//     if(i_rst)
//         r_tx_check <= 'd0;
//     else if(!ro_user_tx_ready && P_UART_CHECK == 1)//odd
//         r_tx_check <= ~(r_tx_check ^ ro_uart_tx);
//     else if(!ro_user_tx_ready && P_UART_CHECK == 2)//even
//         r_tx_check <= r_tx_check ^ ro_uart_tx;
//     else 
//         r_tx_check <= 'd0;
// end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_tx_check <= 'd0;
    else if(r_cnt == 3 + P_UART_DATA_WIDTH - 3)
        r_tx_check <= 'd0;
    else 
        r_tx_check <= r_tx_check ^ r_tx_data[0];
end

endmodule
