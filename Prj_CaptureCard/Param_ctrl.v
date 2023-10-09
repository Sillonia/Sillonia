`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/08/20 14:59:14
// Design Name: 
// Module Name: Param_ctrl
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


module Param_ctrl(
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
    output [7 :0]       o_adc_channel           ,
    output [23:0]       o_adc_speed             ,
    output              o_adc_start             ,
    output              o_adc_trig              ,
    output              o_flash_start           ,
    output [15:0]       o_flash_num             ,
    output              o_iic_scl               ,//IIC的时钟
    inout               io_iic_sda               //IIC的双向数据项
);

wire [2 :0]             w_ctrl_eeprom_addr      ;
wire [15:0]             w_ctrl_operation_addr   ;
wire [1 :0]             w_ctrl_operation_type   ;
wire [7 :0]             w_ctrl_operation_len    ;
wire                    w_ctrl_opeartion_valid  ;
wire                    w_ctrl_operation_ready  ;
wire [7 :0]             w_ctrl_write_data       ;
wire                    w_ctrl_write_sop        ;
wire                    w_ctrl_write_eop        ;
wire                    w_ctrl_write_valid      ;
wire [7 :0]             w_ctrl_read_data        ;
wire                    w_ctrl_read_valid       ;

param_ram param_ram_u0(
    .i_clk                              (i_clk                  ),
    .i_rst                              (i_rst                  ),

    .i_cmd_per_len                      (i_cmd_per_len          ),
    .i_cmd_per_data                     (i_cmd_per_data         ),
    .i_cmd_per_last                     (i_cmd_per_last         ),
    .i_cmd_per_valid                    (i_cmd_per_valid        ),
    .o_cmd_post_len                     (o_cmd_post_len         ),
    .o_cmd_post_data                    (o_cmd_post_data        ),
    .o_cmd_post_last                    (o_cmd_post_last        ),
    .o_cmd_post_valid                   (o_cmd_post_valid       ),
    .o_system_run                       (o_system_run           ),

    .o_ctrl_eeprom_addr                 (w_ctrl_eeprom_addr     ),
    .o_ctrl_operation_addr              (w_ctrl_operation_addr  ),
    .o_ctrl_operation_type              (w_ctrl_operation_type  ),
    .o_ctrl_operation_len               (w_ctrl_operation_len   ),
    .o_ctrl_opeartion_valid             (w_ctrl_opeartion_valid ),
    .i_ctrl_operation_ready             (w_ctrl_operation_ready ),
    .o_ctrl_write_data                  (w_ctrl_write_data      ),
    .o_ctrl_write_sop                   (w_ctrl_write_sop       ),
    .o_ctrl_write_eop                   (w_ctrl_write_eop       ),
    .o_ctrl_write_valid                 (w_ctrl_write_valid     ),
    .i_ctrl_read_data                   (w_ctrl_read_data       ),
    .i_ctrl_read_valid                  (w_ctrl_read_valid      ),

    .o_adc_channel                      (),
    .o_adc_speed                        (),
    .o_adc_start                        (),
    .o_adc_trig                         (),
    .o_flash_start                      (),
    .o_flash_num                        ()
);

//EEPROM驱动
eeprom_drive eeprom_drive_U0(
    .i_clk                              (i_clk                  ),
    .i_rst                              (i_rst                  ),

    .i_ctrl_eeprom_addr                 (w_ctrl_eeprom_addr     ),
    .i_ctrl_operation_addr              (w_ctrl_operation_addr  ),
    .i_ctrl_operation_type              (w_ctrl_operation_type  ),
    .i_ctrl_operation_len               (w_ctrl_operation_len   ),
    .i_ctrl_opeartion_valid             (w_ctrl_opeartion_valid ),
    .o_ctrl_operation_ready             (w_ctrl_operation_ready ),
    .i_ctrl_write_data                  (w_ctrl_write_data      ),
    .i_ctrl_write_sop                   (w_ctrl_write_sop       ),
    .i_ctrl_write_eop                   (w_ctrl_write_eop       ),
    .i_ctrl_write_valid                 (w_ctrl_write_valid     ),
    .o_ctrl_read_data                   (w_ctrl_read_data       ),
    .o_ctrl_read_valid                  (w_ctrl_read_valid      ),

    .o_iic_scl                          (o_iic_scl              ),//IIC的时钟
    .io_iic_sda                         (io_iic_sda             ) //IIC的双向数据项
);

endmodule
