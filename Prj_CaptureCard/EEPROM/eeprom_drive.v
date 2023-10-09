`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/07/29 15:52:05
// Design Name: 
// Module Name: eeprom_drive
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


module eeprom_drive(
    input               i_clk                   ,
    input               i_rst                   ,

    input  [2 :0]       i_ctrl_eeprom_addr      ,
    input  [15:0]       i_ctrl_operation_addr   ,
    input  [1 :0]       i_ctrl_operation_type   ,
    input  [7 :0]       i_ctrl_operation_len    ,
    input               i_ctrl_opeartion_valid  ,
    output              o_ctrl_operation_ready  ,
    input  [7 :0]       i_ctrl_write_data       ,
    input               i_ctrl_write_sop        ,
    input               i_ctrl_write_eop        ,
    input               i_ctrl_write_valid      ,
    output [7 :0]       o_ctrl_read_data        ,
    output              o_ctrl_read_valid       ,

    output              o_iic_scl               ,//IIC的时钟
    inout               io_iic_sda               //IIC的双向数据项
);

wire [6 :0]             w_drive                 ;
wire [15:0]             w_operation_addr        ;
wire [7 :0]             w_operation_len         ;
wire [1 :0]             w_operation_type        ;
wire                    w_opeartion_valid       ;
wire                    w_operation_ready       ;
wire [7 :0]             w_write_data            ;
wire                    w_write_req             ;
wire [7 :0]             w_read_data             ;
wire                    w_read_valid            ;

eeprom_ctrl eeprom_ctrl_u0(
    .i_clk                   (i_clk                     ),
    .i_rst                   (i_rst                     ),

    .i_ctrl_eeprom_addr      (i_ctrl_eeprom_addr        ),
    .i_ctrl_operation_addr   (i_ctrl_operation_addr     ),
    .i_ctrl_operation_type   (i_ctrl_operation_type     ),
    .i_ctrl_operation_len    (i_ctrl_operation_len      ),
    .i_ctrl_opeartion_valid  (i_ctrl_opeartion_valid    ),
    .o_ctrl_operation_ready  (o_ctrl_operation_ready    ),
    .i_ctrl_write_data       (i_ctrl_write_data         ),
    .i_ctrl_write_sop        (i_ctrl_write_sop          ),
    .i_ctrl_write_eop        (i_ctrl_write_eop          ),
    .i_ctrl_write_valid      (i_ctrl_write_valid        ),
    .o_ctrl_read_data        (o_ctrl_read_data          ),
    .o_ctrl_read_valid       (o_ctrl_read_valid         ),

    .o_drive                 (w_drive                   ),//用户输入设备地址
    .o_operation_addr        (w_operation_addr          ),//用户输入存储地址
    .o_operation_len         (w_operation_len           ),//用户输入读写长度
    .o_operation_type        (w_operation_type          ),//用户输入操作类型
    .o_opeartion_valid       (w_opeartion_valid         ),//用户输入有效信号
    .i_operation_ready       (w_operation_ready         ),//用户输出准备信号
    .o_write_data            (w_write_data              ),//用户输入写数据
    .i_write_req             (w_write_req               ),//用户写数据请求信号
    .i_read_data             (w_read_data               ),//输出IIC读到的数据
    .i_read_valid            (w_read_valid              ) //输出IIC读数据有效
);

iic_drive#(
    .P_ADDR_WIDTH            (16                        )                      
)       
iic_drive_u0        
(                   
    .i_clk                   (i_clk                     ),//模块输入时钟
    .i_rst                   (i_rst                     ),//模块输入复位-高有效

    .i_drive                 (w_drive                   ),//用户输入设备地址
    .i_operation_addr        (w_operation_addr          ),//用户输入存储地址
    .i_operation_len         (w_operation_len           ),//用户输入读写长度
    .i_operation_type        (w_operation_type          ),//用户输入操作类型
    .i_opeartion_valid       (w_opeartion_valid         ),//用户输入有效信号
    .o_operation_ready       (w_operation_ready         ),//用户输出准备信号
    .i_write_data            (w_write_data              ),//用户输入写数据
    .o_write_req             (w_write_req               ),//用户写数据请求信号
    .o_read_data             (w_read_data               ),//输出IIC读到的数据
    .o_read_valid            (w_read_valid              ),//输出IIC读数据有效
    .o_iic_scl               (o_iic_scl                 ),//IIC的时钟
    .io_iic_sda              (io_iic_sda                ) //IIC的双向数据项
);

endmodule
