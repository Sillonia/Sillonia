`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/08/20 14:59:14
// Design Name: 
// Module Name: AD7606_Ctrl
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


module AD7606_Ctrl(
    input               i_clk           ,
    input               i_rst           ,

    input  [7 :0]       i_cmd_len       ,
    input  [7 :0]       i_cmd_data      ,
    input               i_cmd_last      ,
    input               i_cmd_valid     ,
    input               i_system_run    ,
    input  [7 :0]       i_adc_channel   ,
    input  [23:0]       i_adc_speed     ,
    input               i_adc_start     ,
    input               i_adc_trig      ,

    output [7 :0]       o_cap_channel   ,
    output              o_cap_enable    ,
    output [23:0]       o_cap_speed     ,
    output              o_cap_trig      ,
    output              o_cap_seek      
);

/***************function**************/

/***************parameter*************/

/***************port******************/             

/***************mechine***************/

/***************reg*******************/
reg  [7 :0]             ri_cmd_len      ;
reg  [7 :0]             ri_cmd_data     ;
reg                     ri_cmd_last     ;
reg                     ri_cmd_valid    ;
reg  [7 :0]             ro_cap_channel  ;
reg                     ro_cap_enable   ;
reg  [23:0]             ro_cap_speed    ;
reg                     ro_cap_trig     ;
reg                     ro_cap_seek     ;
reg  [7 :0]             r_cnt           ;
reg  [7 :0]             r_type          ;
reg  [7 :0]             r_payload       ;//payload data len
reg                     ri_system_run   ;
reg                     ri_system_run_1d;
/***************wire******************/
wire                    w_system_pos    ;

/***************component*************/

/***************assign****************/
assign o_cap_channel = ro_cap_channel   ;
assign o_cap_enable  = ro_cap_enable    ;
assign o_cap_speed   = ro_cap_speed     ;
assign o_cap_trig    = ro_cap_trig      ;
assign o_cap_seek    = ro_cap_seek      ;
assign w_system_pos  = ri_system_run & !ri_system_run_1d;

/***************always****************/
always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst) begin
        ri_cmd_len   <= 0;
        ri_cmd_data  <= 0;
        ri_cmd_last  <= 0;
        ri_cmd_valid <= 0;
    end else begin
        ri_cmd_len   <= i_cmd_len  ;
        ri_cmd_data  <= i_cmd_data ;
        ri_cmd_last  <= i_cmd_last ;
        ri_cmd_valid <= i_cmd_valid;
    end
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_cnt <= 'd0;
    else if(ri_cmd_valid)
        r_cnt <= r_cnt  + 1;
    else 
        r_cnt <= 'd0;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_type <= 'd0;
    else if(ri_cmd_valid && r_cnt == 1)
        r_type <= ri_cmd_data;
    else    
        r_type <= r_type;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_payload <= 'd0;
    else if(ri_cmd_valid && r_cnt == 1)
        r_payload <= i_cmd_data;
    else 
        r_payload <= r_payload;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        ro_cap_channel <= 'd0;
    else if(w_system_pos)
        ro_cap_channel <= i_adc_channel;
    else if(ri_cmd_valid && r_cnt == 2 + r_payload && r_type == 1)
        ro_cap_channel <= ri_cmd_data;
    else 
        ro_cap_channel <= ro_cap_channel;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        ro_cap_speed <= 'd0;
    else if(w_system_pos)
        ro_cap_speed <= i_adc_speed;
    else if(ri_cmd_valid && r_cnt >= 3 && r_cnt <= 2 + r_payload && r_type == 2)
        ro_cap_speed <= {ro_cap_speed[15:0],ri_cmd_data};
    else 
        ro_cap_speed <= ro_cap_speed;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        ro_cap_enable <= 'd0;
    else if(w_system_pos)
        ro_cap_enable <= i_adc_speed;
    else if(ri_cmd_valid && r_cnt == 2 + r_payload && r_type == 3)
        ro_cap_enable <= ri_cmd_data;
    else 
        ro_cap_enable <= ro_cap_enable;
end



always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        ro_cap_trig <= 'd0;
    else if(w_system_pos)
        ro_cap_trig <= i_adc_trig;
    else if(ri_cmd_valid && r_cnt == 2 + r_payload && r_type == 4)
        ro_cap_trig <= ri_cmd_data;
    else 
        ro_cap_trig <= ro_cap_trig;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        ro_cap_seek <= 'd0;
    else if(ro_cap_seek)
        ro_cap_seek <= 'd0;
    else if(ri_cmd_valid && r_cnt == 2 + r_payload && r_type == 5)
        ro_cap_seek <= ri_cmd_data;
    else 
        ro_cap_seek <= 'd0;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst) begin
        ri_system_run    <= 'd0;
        ri_system_run_1d <= 'd0;
    end else begin
        ri_system_run    <= 'd0;
        ri_system_run_1d <= ri_system_run;
    end
end

endmodule
