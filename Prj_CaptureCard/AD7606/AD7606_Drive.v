`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/07/31 22:19:06
// Design Name: 
// Module Name: AD7606_Drive
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


module AD7606_Drive#(
    parameter       P_RANGE =   0   
)(
    input           i_clk           ,//50MHZ
    input           i_rst           ,

    /*--------用户接口--------*/
    input           i_extrig        ,
    input           i_trig_mode     ,
    input  [23:0]   i_cap_seep      ,
    input           i_user_ctrl     ,
    output [15:0]   o_user_data_1   ,
    output          o_user_valid_1  ,
    output [15:0]   o_user_data_2   ,
    output          o_user_valid_2  ,
    output [15:0]   o_user_data_3   ,
    output          o_user_valid_3  ,
    output [15:0]   o_user_data_4   ,
    output          o_user_valid_4  ,
    output [15:0]   o_user_data_5   ,
    output          o_user_valid_5  ,
    output [15:0]   o_user_data_6   ,
    output          o_user_valid_6  ,
    output [15:0]   o_user_data_7   ,
    output          o_user_valid_7  ,
    output [15:0]   o_user_data_8   ,
    output          o_user_valid_8  ,

    
    /*--------ADC接口--------*/
    output          o_ad_psb_sel    ,
    output          o_ad_stby       ,
    output          o_ad_range      ,
    output [2:0]    o_ad_osc        ,
    output          o_ad_reset      ,
    output          o_ad_consvtA    ,
    output          o_ad_consvtB    ,
    output          o_ad_cs         ,
    output          o_ad_rd         ,
    input           i_ad_busy       ,
    input           i_ad_frstdata   ,
    input  [15:0]   i_ad_data       
);

/***************function**************/

/***************parameter*************/
localparam          P_ST_RESET  = 0 ,
                    P_ST_CONSVT = 1 ,
                    P_ST_BUSY   = 2 ,
                    P_ST_READ   = 3 ,
                    P_ST_WAIT   = 4 ;

/***************port******************/             

/***************mechine***************/
reg  [7 :0]         r_st_current    ;
reg  [7 :0]         r_st_next       ;
reg  [15:0]         r_st_cnt        ;

/***************reg*******************/
reg                 ro_ad_psb_sel   ;
reg                 ro_ad_stby      ;
reg  [2:0]          ro_ad_osc       ;
reg                 ro_ad_reset     ;
reg                 ro_ad_consvtA   ;
reg                 ro_ad_consvtB   ;
reg                 ro_ad_cs        ;
reg                 ro_ad_rd        ;
reg                 ri_ad_busy      ;
// reg                 ri_ad_frstdata  ;
// reg  [15:0]         ri_ad_data      ;
reg                 ro_ad_rd_1d     ;
reg  [2 :0]         ro_user_channel ;  
reg                 ri_user_ctrl    ;
reg  [15:0]         ro_user_data_1  ;
reg                 ro_user_valid_1 ;
reg  [15:0]         ro_user_data_2  ;
reg                 ro_user_valid_2 ;
reg  [15:0]         ro_user_data_3  ;
reg                 ro_user_valid_3 ;
reg  [15:0]         ro_user_data_4  ;
reg                 ro_user_valid_4 ;
reg  [15:0]         ro_user_data_5  ;
reg                 ro_user_valid_5 ;
reg  [15:0]         ro_user_data_6  ;
reg                 ro_user_valid_6 ;
reg  [15:0]         ro_user_data_7  ;
reg                 ro_user_valid_7 ;
reg  [15:0]         ro_user_data_8  ;
reg                 ro_user_valid_8 ;
reg  [23:0]         ri_cap_seep     ;
reg  [2 :0]         ri_extrig       ;
reg                 ri_trig_mode    ;
/***************wire******************/

/***************component*************/

/***************assign****************/
assign o_ad_psb_sel     = ro_ad_psb_sel     ;
assign o_ad_stby        = ro_ad_stby        ;
assign o_ad_osc         = ro_ad_osc         ;
assign o_ad_reset       = ro_ad_reset       ;
assign o_ad_consvtA     = ro_ad_consvtA     ;
assign o_ad_consvtB     = ro_ad_consvtB     ;
assign o_ad_cs          = ro_ad_cs          ;
assign o_ad_rd          = ro_ad_rd          ;
assign o_user_data_1    = ro_user_data_1    ;
assign o_user_valid_1   = ro_user_valid_1   ;
assign o_user_data_2    = ro_user_data_2    ;
assign o_user_valid_2   = ro_user_valid_2   ;
assign o_user_data_3    = ro_user_data_3    ;
assign o_user_valid_3   = ro_user_valid_3   ;
assign o_user_data_4    = ro_user_data_4    ;
assign o_user_valid_4   = ro_user_valid_4   ;
assign o_user_data_5    = ro_user_data_5    ;
assign o_user_valid_5   = ro_user_valid_5   ;
assign o_user_data_6    = ro_user_data_6    ;
assign o_user_valid_6   = ro_user_valid_6   ;
assign o_user_data_7    = ro_user_data_7    ;
assign o_user_valid_7   = ro_user_valid_7   ;
assign o_user_data_8    = ro_user_data_8    ;
assign o_user_valid_8   = ro_user_valid_8   ;
assign o_ad_range       = P_RANGE           ;
/***************always****************/   
always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_st_current <= P_ST_RESET;
    else    
        r_st_current <= r_st_next;
end

always@(*)
begin
   case(r_st_current)
        P_ST_RESET  : r_st_next = r_st_cnt == 10                ? P_ST_CONSVT   :  P_ST_RESET   ;
        P_ST_CONSVT : r_st_next = ri_user_ctrl &((!ri_trig_mode) || (ri_trig_mode && ri_extrig[2] && ri_extrig[1]) )
                                  ? P_ST_BUSY     : P_ST_CONSVT   ;
        P_ST_BUSY   : r_st_next = r_st_cnt >= 10 & !ri_ad_busy  ? P_ST_READ     : P_ST_BUSY     ;
        P_ST_READ   : r_st_next = r_st_cnt == 15                ? P_ST_WAIT     : P_ST_READ     ;
        P_ST_WAIT   : r_st_next = r_st_cnt == ri_cap_seep       ? P_ST_CONSVT   : P_ST_WAIT     ;
        default     : r_st_next = P_ST_RESET;
   endcase 
end


always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        ri_extrig <= 'd0;
    else
        ri_extrig <= {ri_extrig[2:0],i_extrig};
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        ri_trig_mode <= 'd0;
    else
        ri_trig_mode <= i_trig_mode;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        ri_cap_seep <= 'd0;
    else if(i_cap_seep < 230)
        ri_cap_seep <= 230;
    else 
        ri_cap_seep <= i_cap_seep;

end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_st_cnt <= 'd0;
    else if(r_st_current != r_st_next)
        r_st_cnt <= 'd0;
    else
        r_st_cnt <= r_st_cnt + 1;
end

//AD7606启动信号
always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        ri_user_ctrl <= 'd0;
    else    
        ri_user_ctrl <= i_user_ctrl;
end

//接口类型，选择并行
always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        ro_ad_psb_sel <= 'd0;
    else    
        ro_ad_psb_sel <= 'd0;
end

//睡眠信号
always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        ro_ad_stby <= 'd0;
    else    
        ro_ad_stby <= 'd0;
end

//AD7606转换繁忙
always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst) begin
        ri_ad_busy     <= 'd0;
    end else begin    
        ri_ad_busy     <= i_ad_busy;
    end
end

//设置采样率
always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        ro_ad_osc <= 'd0;
    else 
        ro_ad_osc <= 'd0;
end

//芯片复位
always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        ro_ad_reset <= 'd1;
    else if(r_st_current == P_ST_RESET)
        ro_ad_reset <= 'd1;
    else    
        ro_ad_reset <= 'd0;
end

//1~4通道启动转换 
always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        ro_ad_consvtA <= 'd1;
    else if(r_st_current == P_ST_CONSVT)
        ro_ad_consvtA <= 'd0;
    else    
        ro_ad_consvtA <= 'd1;
end

//5~8通道启动转换 
always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        ro_ad_consvtB <= 'd1;
    else if(r_st_current == P_ST_CONSVT)
        ro_ad_consvtB <= 'd0;
    else    
        ro_ad_consvtB <= 'd1;
end

//芯片片选
always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        ro_ad_cs <= 'd1;
    else if(r_st_current == P_ST_READ)
        ro_ad_cs <= 'd0; 
    else    
        ro_ad_cs <= 'd1;
end

//读数据信号
always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        ro_ad_rd <= 'd1;
    else if(r_st_current == P_ST_READ)
        ro_ad_rd <= ~ro_ad_rd; 
    else    
        ro_ad_rd <= 'd1;
end
        
//读数据信号1拍
always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        ro_ad_rd_1d <= 'd1;
    else        
        ro_ad_rd_1d <= ro_ad_rd;
end

//读数据
// always@(posedge i_clk,posedge i_rst)
// begin
//     if(i_rst)
//         ri_ad_data     <= 'd0;
//     else if(ro_ad_rd && !ro_ad_rd_1d)
//         ri_ad_data     <= i_ad_data ; 
//     else 
//         ri_ad_data     <= ri_ad_data;
// end

// //第一通道数据指示信号
// always@(posedge i_clk,posedge i_rst)
// begin
//     if(i_rst)
//         ri_ad_frstdata <= 'd0;
//     else if(ro_ad_rd && !ro_ad_rd_1d)
//         ri_ad_frstdata <= i_ad_frstdata;
//     else 
//         ri_ad_frstdata <= 'd0;
// end

//通道标识
always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        ro_user_channel <= 'd0;
    else if(r_st_current == P_ST_CONSVT)
        ro_user_channel <= 'd0;
    else if(ro_ad_rd && !ro_ad_rd_1d)
        ro_user_channel <= ro_user_channel + 1;
    else 
        ro_user_channel <= ro_user_channel;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        ro_user_data_1 <= 'd0;
    else if(ro_ad_rd && !ro_ad_rd_1d && ro_user_channel == 0)
        ro_user_data_1 <= i_ad_data;
    else    
        ro_user_data_1 <= 'd0;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        ro_user_data_2 <= 'd0;
    else if(ro_ad_rd && !ro_ad_rd_1d && ro_user_channel == 1)
        ro_user_data_2 <= i_ad_data;
    else    
        ro_user_data_2 <= 'd0;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        ro_user_data_3 <= 'd0;
    else if(ro_ad_rd && !ro_ad_rd_1d && ro_user_channel == 2)
        ro_user_data_3 <= i_ad_data;
    else    
        ro_user_data_3 <= 'd0;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        ro_user_data_4 <= 'd0;
    else if(ro_ad_rd && !ro_ad_rd_1d && ro_user_channel == 3)
        ro_user_data_4 <= i_ad_data;
    else    
        ro_user_data_4 <= 'd0;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        ro_user_data_5 <= 'd0;
    else if(ro_ad_rd && !ro_ad_rd_1d && ro_user_channel == 4)
        ro_user_data_5 <= i_ad_data;
    else    
        ro_user_data_5 <= 'd0;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        ro_user_data_6 <= 'd0;
    else if(ro_ad_rd && !ro_ad_rd_1d && ro_user_channel == 5)
        ro_user_data_6 <= i_ad_data;
    else    
        ro_user_data_6 <= 'd0;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        ro_user_data_7 <= 'd0;
    else if(ro_ad_rd && !ro_ad_rd_1d && ro_user_channel == 6)
        ro_user_data_7 <= i_ad_data;
    else    
        ro_user_data_7 <= 'd0;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        ro_user_data_8 <= 'd0;
    else if(ro_ad_rd && !ro_ad_rd_1d && ro_user_channel == 7)
        ro_user_data_8 <= i_ad_data;
    else    
        ro_user_data_8 <= 'd0;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        ro_user_valid_1 <= 'd0;
    else if(ro_ad_rd && !ro_ad_rd_1d && ro_user_channel == 0)
        ro_user_valid_1 <= 'd1;
    else    
        ro_user_valid_1 <= 'd0;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        ro_user_valid_2 <= 'd0;
    else if(ro_ad_rd && !ro_ad_rd_1d && ro_user_channel == 1)
        ro_user_valid_2 <= 'd1;
    else    
        ro_user_valid_2 <= 'd0;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        ro_user_valid_3 <= 'd0;
    else if(ro_ad_rd && !ro_ad_rd_1d && ro_user_channel == 2)
        ro_user_valid_3 <= 'd1;
    else    
        ro_user_valid_3 <= 'd0;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        ro_user_valid_4 <= 'd0;
    else if(ro_ad_rd && !ro_ad_rd_1d && ro_user_channel == 3)
        ro_user_valid_4 <= 'd1;
    else    
        ro_user_valid_4 <= 'd0;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        ro_user_valid_5 <= 'd0;
    else if(ro_ad_rd && !ro_ad_rd_1d && ro_user_channel == 4)
        ro_user_valid_5 <= 'd1;
    else    
        ro_user_valid_5 <= 'd0;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        ro_user_valid_6 <= 'd0;
    else if(ro_ad_rd && !ro_ad_rd_1d && ro_user_channel == 5)
        ro_user_valid_6 <= 'd1;
    else    
        ro_user_valid_6 <= 'd0;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        ro_user_valid_7 <= 'd0;
    else if(ro_ad_rd && !ro_ad_rd_1d && ro_user_channel == 6)
        ro_user_valid_7 <= 'd1;
    else    
        ro_user_valid_7 <= 'd0;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        ro_user_valid_8 <= 'd0;
    else if(ro_ad_rd && !ro_ad_rd_1d && ro_user_channel == 7)
        ro_user_valid_8 <= 'd1;
    else    
        ro_user_valid_8 <= 'd0;
end

endmodule
