`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/07/08 20:36:12
// Design Name: 
// Module Name: CLK_DIV_module
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


module CLK_DIV_module#(
    parameter       P_CLK_DIV_CNT = 2    //最大为65535
)(
    input           i_clk               ,//输入时钟
    input           i_rst               ,//high value
    output          o_clk_div            //分频后的时钟
);

/***************function**************/

/***************parameter*************/

/***************port******************/             

/***************mechine***************/

/***************reg*******************/
reg                 ro_o_clk_div    ;
reg  [15:0]         r_cnt           ;

/***************wire******************/

/***************component*************/

/***************assign****************/
assign o_clk_div = ro_o_clk_div     ;

/***************always****************/
always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_cnt <= 'd0;
    else if(r_cnt == (P_CLK_DIV_CNT >> 1) - 1)
        r_cnt <= 'd0;
    else 
        r_cnt <= r_cnt + 1;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        ro_o_clk_div <= 'd0;
    else if(r_cnt == (P_CLK_DIV_CNT >> 1) - 1)
        ro_o_clk_div <= ~ro_o_clk_div;
    else 
        ro_o_clk_div <= ro_o_clk_div;
end

// always@(posedge i_clk,posedge i_rst)
// begin
//     if(i_rst)

//     else if()

//     else 

// end

endmodule
