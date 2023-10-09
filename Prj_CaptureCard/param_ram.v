`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/08/26 10:30:43
// Design Name: 
// Module Name: param_ram
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies:1.将uart发送的指令包解析出来存入RAM
//              2.将RAM中的数据存入EEPROM
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module param_ram(
    input               i_clk                   ,
    input               i_rst                   ,

    input  [7 :0]       i_cmd_per_len           ,
    input  [7 :0]       i_cmd_per_data          ,
    input               i_cmd_per_last          ,
    input               i_cmd_per_valid         ,

    output [7 :0]       o_cmd_post_len          ,
    output [7 :0]       o_cmd_post_data         ,
    output              o_cmd_post_last         ,
    output              o_cmd_post_valid        ,

    output              o_system_run            ,
    /*--------eeprom--------*/
    output [2 :0]       o_ctrl_eeprom_addr      ,
    output [15:0]       o_ctrl_operation_addr   ,
    output [1 :0]       o_ctrl_operation_type   ,
    output [7 :0]       o_ctrl_operation_len    ,
    output              o_ctrl_opeartion_valid  ,
    input               i_ctrl_operation_ready  ,
    output [7 :0]       o_ctrl_write_data       ,
    output              o_ctrl_write_sop        ,
    output              o_ctrl_write_eop        ,
    output              o_ctrl_write_valid      ,
    input  [7 :0]       i_ctrl_read_data        ,
    input               i_ctrl_read_valid       ,

    output [7 :0]       o_adc_channel           ,
    output [23:0]       o_adc_speed             ,
    output              o_adc_start             ,
    output              o_adc_trig              ,
    output              o_flash_start           ,
    output [15:0]       o_flash_num             
);
/***************function**************/

/***************parameter*************/
localparam              P_EEPROM_ADDR = 3'b011      ;

/***************port******************/             

/***************mechine***************/

/***************reg*******************/
reg  [7 :0]             ri_cmd_per_len              ;
reg  [7 :0]             ri_cmd_per_data             ;
reg                     ri_cmd_per_last             ;
reg                     ri_cmd_per_valid            ;
reg  [7 :0]             ro_cmd_post_len             ;
reg  [7 :0]             ro_cmd_post_data            ;
reg                     ro_cmd_post_last            ;
reg                     ro_cmd_post_valid           ;
reg  [15:0]             ri_ctrl_operation_addr      ;
reg  [1 :0]             ri_ctrl_operation_type      ;
reg  [7 :0]             ri_ctrl_operation_len       ;
reg                     i_ctrl_opeartion_valid      ;
reg  [15:0]             ro_ctrl_operation_addr      ;
reg  [1 :0]             ro_ctrl_operation_type      ;
reg  [7 :0]             ro_ctrl_operation_len       ;
reg                     ro_ctrl_opeartion_valid     ;   
reg  [7 :0]             ro_ctrl_write_data          ;
reg                     ro_ctrl_write_sop           ;
reg                     ro_ctrl_write_eop           ;
reg                     ro_ctrl_write_valid         ;
reg  [7 :0]             ri_ctrl_read_data           ;
reg                     ri_ctrl_read_valid          ;
reg                     ri_ctrl_read_valid_1d       ;
reg                     ro_system_run               ;
reg  [7 :0]             r_cnt                       ;
reg                     r_cmd_header                ;
reg  [7 :0]             r_cmd_type                  ;
reg  [7 :0]             r_cmd_len                   ;
reg  [7 :0]             r_cmd_data                  ;
reg                     r_cmd_data_valid            ;
reg                     r_cmd_data_valid_1d         ;
reg                     r_ram_en                    ;
reg                     r_ram_wen                   ;
reg  [6 :0]             r_ram_addr                  ;
reg  [7 :0]             r_ram_data                  ;
reg                     r_eeprom_trig               ;
reg  [7 :0]             r_eeprom_wcnt               ;
reg  [1 :0]             r_run_ctrl                  ;
reg                     r_ram_en_B                  ;
reg                     r_ram_wen_B                 ;
reg  [6 :0]             r_ram_addr_B                ;
reg  [7 :0]             r_ram_data_B                ;
reg  [7 :0]             r_pkt_cnt                   ;              
reg  [7 :0]             ro_adc_channel              ;
reg  [23:0]             ro_adc_speed                ;
reg                     ro_adc_start                ;
reg                     ro_adc_trig                 ;
reg                     ro_flash_start              ;
reg  [15:0]             ro_flash_num                ;
/***************wire******************/
wire                    w_ctrl_active               ;
wire [7 :0]             w_ram_dout                  ;
wire [7 :0]             w_ram_dout_B                ;
wire                    w_ram_init_com              ;

/***************component*************/
RAM8X128 RAM8X128_u0 (
  .clka     (i_clk              ),
  .ena      (r_ram_en           ),  
  .wea      (r_ram_wen          ),  
  .addra    (r_ram_addr         ),
  .dina     (r_ram_data         ), 
  .douta    (w_ram_dout         ),

  .clkb     (i_clk),
  .enb      (r_ram_en_B         ),     
  .web      (r_ram_wen_B        ),     
  .addrb    (r_ram_addr_B       ), 
  .dinb     (r_ram_data_B       ), 
  .doutb    (w_ram_dout_B       )  
);
/***************assign****************/
assign w_ram_init_com           = !ri_ctrl_read_valid && ri_ctrl_read_valid_1d;
assign o_cmd_post_len           = ro_cmd_post_len           ;
assign o_cmd_post_data          = ro_cmd_post_data          ;
assign o_cmd_post_last          = ro_cmd_post_last          ;
assign o_cmd_post_valid         = ro_cmd_post_valid         ;
assign o_ctrl_eeprom_addr       = P_EEPROM_ADDR             ;
assign o_ctrl_operation_addr    = ro_ctrl_operation_addr    ;
assign o_ctrl_operation_type    = ro_ctrl_operation_type    ;
assign o_ctrl_operation_len     = ro_ctrl_operation_len     ;
assign o_ctrl_opeartion_valid   = ro_ctrl_opeartion_valid   ;
assign o_ctrl_write_data        = ro_ctrl_write_data        ;
assign o_ctrl_write_sop         = ro_ctrl_write_sop         ;
assign o_ctrl_write_eop         = ro_ctrl_write_eop         ;
assign o_ctrl_write_valid       = ro_ctrl_write_valid       ;
assign o_system_run             = ro_system_run             ;
assign w_ctrl_active            = o_ctrl_opeartion_valid & i_ctrl_operation_ready;
assign o_adc_channel            = ro_adc_channel            ;
assign o_adc_speed              = ro_adc_speed              ;
assign o_adc_start              = ro_adc_start              ;
assign o_adc_trig               = ro_adc_trig               ;
assign o_flash_start            = ro_flash_start            ;
assign o_flash_num              = ro_flash_num              ;

/***************always****************/
always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst) begin
        ri_cmd_per_len          <= 'd0;
        ri_cmd_per_data         <= 'd0;
        ri_cmd_per_last         <= 'd0;
        ri_cmd_per_valid        <= 'd0;
        ri_ctrl_read_data       <= 'd0;
        ri_ctrl_read_valid      <= 'd0;
        ri_ctrl_read_valid_1d   <= 'd0;
    end else begin
        ri_cmd_per_len          <= i_cmd_per_len        ;
        ri_cmd_per_data         <= i_cmd_per_data       ;
        ri_cmd_per_last         <= i_cmd_per_last       ;
        ri_cmd_per_valid        <= i_cmd_per_valid      ;
        ri_ctrl_read_data       <= i_ctrl_read_data     ;
        ri_ctrl_read_valid      <= i_ctrl_read_valid    ;
        ri_ctrl_read_valid_1d   <= ri_ctrl_read_valid   ;
    end 
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_cnt <= 'd0;
    else if(ri_cmd_per_valid)
        r_cnt <= r_cnt + 1;
    else 
        r_cnt <= 'd0;
end
   
always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_cmd_header <= 'd0;
    else if(r_cnt == 0 && ri_cmd_per_valid && ri_cmd_per_data == 8'h55 )
        r_cmd_header <= 'd1;
    else if(r_cnt == 0 && ri_cmd_per_valid && ri_cmd_per_data != 8'h55)
        r_cmd_header <= 'd0;
    else    
        r_cmd_header <= r_cmd_header;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_cmd_type <= 'd0;
    else if(r_cnt == 1 && ri_cmd_per_valid)
        r_cmd_type <= ri_cmd_per_data;
    else 
        r_cmd_type <= r_cmd_type;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_cmd_len <= 'd0;
    else if(r_cnt == 2 && ri_cmd_per_valid)
        r_cmd_len <= ri_cmd_per_data;
    else 
        r_cmd_len <= r_cmd_len;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_cmd_data_valid <= 'd0;
    else if(ri_cmd_per_last)
        r_cmd_data_valid <= 'd0;
    else if(r_cnt == 2 && ri_cmd_per_valid && r_cmd_header && r_cmd_type < 10 && r_cmd_type!= 5)
        r_cmd_data_valid <= 'd1;
    else 
        r_cmd_data_valid <= r_cmd_data_valid;
end         

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_cmd_data_valid_1d <= 'd0;
    else 
        r_cmd_data_valid_1d <= r_cmd_data_valid;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_ram_en <= 'd0;
    else if(r_eeprom_wcnt == 8 || (!r_cmd_data_valid && r_cmd_data_valid_1d))
        r_ram_en <= 'd0;
    else if(w_ctrl_active && ro_ctrl_operation_type == 1)//写eeprom读ram
        r_ram_en <= 'd1;
    else if(r_cmd_data_valid)//UART发指令写ram
        r_ram_en <= 'd1;
    else 
        r_ram_en <= r_ram_en;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_ram_wen <= 'd0;
    else 
        r_ram_wen <= r_cmd_data_valid;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_ram_addr <= 'd0;
    else if(r_eeprom_trig)
        r_ram_addr <= 'd0;
    else if(r_ram_en && (w_ctrl_active || ro_ctrl_write_valid)) //写eeprom读ram
        r_ram_addr <= r_ram_addr;
    else if(r_cnt == 2)//uart指令写ram
        case(r_cmd_type)
            1           :r_ram_addr <= 'd0;
            2           :r_ram_addr <= 'd1;
            3           :r_ram_addr <= 'd4;
            4           :r_ram_addr <= 'd5; 
            6           :r_ram_addr <= 'd6;
            7           :r_ram_addr <= 'd7;
            default     :r_ram_addr <= 'd0;
        endcase
    else if(r_ram_wen)
        r_ram_addr <= r_ram_addr + 1;
    else 
        r_ram_addr <= r_ram_addr;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_ram_data <= 'd0;
    else 
        r_ram_data <= ri_cmd_per_data;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_eeprom_trig <= 'd0;
    else if(r_cmd_type == 9 && r_cnt == 1 && ri_cmd_per_valid)
        r_eeprom_trig <= 'd1;
    else 
        r_eeprom_trig <= 'd0;
end 

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst) begin
        ro_ctrl_operation_addr  <= 'd0;
        ro_ctrl_operation_type  <= 'd0;
        ro_ctrl_operation_len   <= 'd0;
        ro_ctrl_opeartion_valid <= 'd0;
    end else if(w_ctrl_active) begin
        ro_ctrl_operation_addr  <= 'd0;
        ro_ctrl_operation_type  <= 'd0;
        ro_ctrl_operation_len   <= 'd0;
        ro_ctrl_opeartion_valid <= 'd0;
    end else if(r_run_ctrl == 0)begin
        ro_ctrl_operation_addr  <= 'd0;
        ro_ctrl_operation_type  <= 'd2;
        ro_ctrl_operation_len   <= 'd9;
        ro_ctrl_opeartion_valid <= 'd1;  
    end else if(r_eeprom_trig)begin
        ro_ctrl_operation_addr  <= 'd0;
        ro_ctrl_operation_type  <= 'd1;
        ro_ctrl_operation_len   <= 'd9;
        ro_ctrl_opeartion_valid <= 'd1;    
    end else begin
        ro_ctrl_operation_addr  <= ro_ctrl_operation_addr ;
        ro_ctrl_operation_type  <= ro_ctrl_operation_type ;
        ro_ctrl_operation_len   <= ro_ctrl_operation_len  ;
        ro_ctrl_opeartion_valid <= ro_ctrl_opeartion_valid;
    end 
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_eeprom_wcnt <= 'd0;
    else if(r_eeprom_wcnt == 9)
        r_eeprom_wcnt <= 'd0;
    else if(ro_ctrl_write_sop || r_eeprom_wcnt > 0)
        r_eeprom_wcnt <= r_eeprom_wcnt + 1;
    else 
        r_eeprom_wcnt <= r_eeprom_wcnt;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        ro_ctrl_write_data <= 'd0;
    else
        ro_ctrl_write_data <= w_ram_dout;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        ro_ctrl_write_sop <= 'd0;
    else if(w_ctrl_active && ro_ctrl_operation_type == 1)
        ro_ctrl_write_sop <= 'd1;
    else 
        ro_ctrl_write_sop <= 'd0;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        ro_ctrl_write_eop <= 'd0;
    else if(r_eeprom_wcnt == 8)
        ro_ctrl_write_eop <= 'd1;
    else 
        ro_ctrl_write_eop <= 'd0;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        ro_ctrl_write_valid <= 'd0;
    else if(ro_ctrl_write_eop)
        ro_ctrl_write_valid <= 'd0;
    else if(w_ctrl_active && ro_ctrl_operation_type == 1)
        ro_ctrl_write_valid <= 'd1;
    else 
        ro_ctrl_write_valid <= ro_ctrl_write_valid;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        ro_system_run <= 'd1;
    else if(w_ram_init_com)
        ro_system_run <= 'd1;
    else 
        ro_system_run <= ro_system_run;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_run_ctrl <= 'd0;
    else if(w_ram_init_com)
        r_run_ctrl <= r_run_ctrl + 1;
    else if(w_ctrl_active && r_run_ctrl == 0)
        r_run_ctrl <= r_run_ctrl + 1;
    else 
        r_run_ctrl <= r_run_ctrl;
end  
 
always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst) begin
        r_ram_en_B  <= 'd0;
        r_ram_wen_B <= 'd0;
    // else if()
    //     r_ram_en_B  <= 'd1; 
    //     r_ram_wen_B <= 'd0;
    end else if(ri_ctrl_read_valid)begin
        r_ram_en_B  <= 'd1; 
        r_ram_wen_B <= 'd1;
    end else begin
        r_ram_en_B  <= 'd0; 
        r_ram_wen_B <= 'd0;
    end
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_ram_addr_B <= 'd0;
    else if(ri_ctrl_read_valid)
        r_ram_addr_B <= r_ram_addr_B + 1;
    else 
        r_ram_addr_B <= 'd0;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_ram_data_B <= 'd0;
    else if(ri_ctrl_read_valid)
        r_ram_data_B <= ri_ctrl_read_data;
    else 
        r_ram_data_B <= 'd0;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst) begin
        ro_adc_channel <= 'd0;
        ro_adc_speed   <= 'd0;
        ro_adc_start   <= 'd0;
        ro_adc_trig    <= 'd0;
        ro_flash_start <= 'd0;
        ro_flash_num   <= 'd0;
    end else case(r_ram_addr_B)
        0       :ro_adc_channel         <= ri_ctrl_read_data;
        1       :ro_adc_speed[7 : 0]    <= ri_ctrl_read_data;
        2       :ro_adc_speed[15: 8]    <= ri_ctrl_read_data;
        3       :ro_adc_speed[23:16]    <= ri_ctrl_read_data;
        4       :ro_adc_start           <= ri_ctrl_read_data;
        5       :ro_adc_trig            <= ri_ctrl_read_data;
        6       :ro_flash_start         <= ri_ctrl_read_data;
        7       :ro_flash_num[7 :0]     <= ri_ctrl_read_data;
        8       :ro_flash_num[15:8]     <= ri_ctrl_read_data;
        // default : 
    endcase
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst) begin
        ro_cmd_post_len   <= 'd0;
        ro_cmd_post_data  <= 'd0;
        ro_cmd_post_last  <= 'd0;
        ro_cmd_post_valid <= 'd0;
    end else begin
        ro_cmd_post_len   <= ri_cmd_per_len  ;
        ro_cmd_post_data  <= ri_cmd_per_data ;
        ro_cmd_post_last  <= ri_cmd_per_last ;
        ro_cmd_post_valid <= ri_cmd_per_valid;
    end
end
  
  
   

  

endmodule
