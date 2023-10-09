`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/08/15 21:51:33
// Design Name: 
// Module Name: CaptureCard_Top
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


module CaptureCard_Top(
    input               i_clk           ,
    input               i_uart_rx       ,
    output              o_uart_tx       ,
    output              o_ad_range      ,
    output [2:0]        o_ad_osc        ,
    output              o_ad_reset      ,
    output              o_ad_consvtA    ,
    output              o_ad_consvtB    ,
    output              o_ad_cs         ,
    output              o_ad_rd         ,
    input               i_ad_busy       ,
    input               i_ad_frstdata   ,
    input  [15:0]       i_ad_data       ,
    output              o_spi_clk       ,
    output              o_spi_cs        ,
    output              o_spi_mosi      ,
    input               i_spi_miso      ,
    output              o_iic_scl       ,
    inout               io_iic_sda      ,
    input               i_extrig        
);

wire                    w_clk_50Mhz         ;
wire                    w_clk_5Mhz          ;
wire                    w_clk_125k          ;
wire                    w_clk_PLL_locked    ;
wire                    w_clk_50Mhz_rst     ;
wire                    w_clk_5Mhz_rst      ;
wire                    w_clk_125k_rst      ;
wire [7 :0]             w_uart_tx_data      ;
wire                    w_uart_tx_valid     ;
wire                    w_uart_tx_ready     ;
wire [7 :0]             w_uart_rx_data      ;
wire                    w_uart_rx_valid     ;
wire                    w_uart_clk          ;
wire                    w_uart_rst          ;
wire [7 :0]             w_uart_rec_len      ;
wire [7 :0]             w_uart_rec_data     ;
wire                    w_uart_rec_last     ;
wire                    w_uart_rec_valid    ;
wire [7 :0]             w_cmd_per_len       ;
wire [7 :0]             w_cmd_per_data      ;
wire                    w_cmd_per_last      ;
wire                    w_cmd_per_valid     ;
wire [7 :0]             w_cmd_post_len      ;
wire [7 :0]             w_cmd_post_data     ;
wire                    w_cmd_post_last     ;
wire                    w_cmd_post_valid    ;
wire [7 :0]             w_cmd_adc_len       ;          
wire [7 :0]             w_cmd_adc_data      ;          
wire                    w_cmd_adc_last      ;          
wire                    w_cmd_adc_valid     ;      
wire [7 :0]             w_cmd_adc_post_len  ;
wire [7 :0]             w_cmd_adc_post_data ;
wire                    w_cmd_adc_post_last ;
wire                    w_cmd_adc_post_valid;    
wire [7 :0]             w_cmd_flash_len     ;          
wire [7 :0]             w_cmd_flash_data    ;          
wire                    w_cmd_flash_last    ;          
wire                    w_cmd_flash_valid   ;          
wire [7 :0]             w_cmd_ctrl_len      ;          
wire [7 :0]             w_cmd_ctrl_data     ;          
wire                    w_cmd_ctrl_last     ;          
wire                    w_cmd_ctrl_valid    ;     
wire [7 :0]             w_adc_len           ;
wire [7 :0]             w_adc_data          ;
wire                    w_adc_last          ;
wire                    w_adc_valid         ;   
wire [7 :0]             w_adc_post_len      ;
wire [7 :0]             w_adc_post_data     ;
wire                    w_adc_post_last     ;
wire                    w_adc_post_valid    ; 
wire                    w_system_run        ; 
wire [7 :0]             w_adc_channel       ;
wire [23:0]             w_adc_speed         ;
wire                    w_adc_start         ;
wire                    w_adc_trig          ;

SYSTEM_CLK SYSTEM_CLK_U0
(
    .clk_in1                            (i_clk              ),
    .clk_out1                           (w_clk_50Mhz        ),     
    .clk_out2                           (w_clk_5Mhz         ), 
    .locked                             (w_clk_PLL_locked   )      
);

CLK_DIV_module#(                
    .P_CLK_DIV_CNT                      (40                     )    
)                       
CLK_DIV_module_U0                       
(                       
    .i_clk                              (w_clk_5Mhz             ),
    .i_rst                              (~w_clk_PLL_locked      ),
    .o_clk_div                          (w_clk_125k             ) //衍生时钟
);                      

rst_gen_module#(                        
    .P_RST_CYCLE                        (10                     )   
)               
rst_gen_module_u0               
(               
    .i_clk                              (w_clk_50Mhz            ),
    .o_rst                              (w_clk_50Mhz_rst        )
);      

rst_gen_module#(                        
    .P_RST_CYCLE                        (10                     )   
)               
rst_gen_module_u1               
(               
    .i_clk                              (w_clk_5Mhz             ),
    .o_rst                              (w_clk_5Mhz_rst         )
);      

rst_gen_module#(                        
    .P_RST_CYCLE                        (10                     )   
)               
rst_gen_module_u2               
(               
    .i_clk                              (w_clk_125k             ),
    .o_rst                              (w_clk_125k_rst         )
);

//串口驱动
uart_drive#(
    .P_SYSTEM_CLK                       (50_000_000                     ),   //输入时钟频率
    .P_UART_BUADRATE                    (115200                         ),   //波特率
    .P_UART_DATA_WIDTH                  (8                              ),   //数据宽度
    .P_UART_STOP_WIDTH                  (1                              ),   //1或者2
    .P_UART_CHECK                       (0                              )    //None=0 Odd-1 Even-2
)
uart_drive_u0
(                  
    .i_clk                              (w_clk_50Mhz                    ),
    .i_rst                              (w_clk_50Mhz_rst                ),  
    .i_uart_rx                          (i_uart_rx                      ),
    .o_uart_tx                          (o_uart_tx                      ),

    .i_user_tx_data                     (w_uart_tx_data                 ),
    .i_user_tx_valid                    (w_uart_tx_valid                ),
    .o_user_tx_ready                    (w_uart_tx_ready                ),
    .o_user_rx_data                     (w_uart_rx_data                 ),
    .o_user_rx_valid                    (w_uart_rx_valid                ),

    .o_user_clk                         (w_uart_clk                     ),
    .o_user_rst                         (w_uart_rst                     )
);

//串口DMA
Uart_DMA Uart_DMA_u0(
    .i_clk                              (w_uart_clk                     ),
    .i_rst                              (w_uart_rst                     ),

    .o_user_tx_data                     (w_uart_tx_data                 ),
    .o_user_tx_valid                    (w_uart_tx_valid                ),
    .i_user_tx_ready                    (w_uart_tx_ready                ),
    .i_user_rx_data                     (w_uart_rx_data                 ),
    .i_user_rx_valid                    (w_uart_rx_valid                ),

    .i_uart_send_data                   (w_adc_post_data                ),
    .i_uart_send_last                   (w_adc_post_last                ),
    .i_uart_send_valid                  (w_adc_post_valid               ),
    .o_uart_send_ready                  (),
    .o_uart_rec_len                     (w_uart_rec_len                 ),
    .o_uart_rec_data                    (w_uart_rec_data                ),
    .o_uart_rec_last                    (w_uart_rec_last                ),
    .o_uart_rec_valid                   (w_uart_rec_valid               )
);

//数据跨时钟域模块
Data_Mclk_buf Data_Mclk_buf_u2(
    .i_per_clk                          (w_clk_50Mhz                    ),
    .i_per_rst                          (w_clk_50Mhz_rst                ),        
    .i_per_len                          (w_adc_len                      ),
    .i_per_data                         (w_adc_data                     ),
    .i_per_last                         (w_adc_last                     ),
    .i_per_valid                        (w_adc_valid                    ),
                    
    .i_post_clk                         (w_uart_clk                     ),
    .i_post_rst                         (w_uart_rst                     ),    
    .o_post_len                         (w_adc_post_len                 ),
    .o_post_data                        (w_adc_post_data                ),
    .o_post_last                        (w_adc_post_last                ),
    .o_post_valid                       (w_adc_post_valid               )   
);

//数据跨时钟域模块
Data_Mclk_buf Data_Mclk_buf_u0(
    .i_per_clk                          (w_uart_clk                     ),
    .i_per_rst                          (w_uart_rst                     ),        
    .i_per_len                          (w_uart_rec_len                 ),
    .i_per_data                         (w_uart_rec_data                ),
    .i_per_last                         (w_uart_rec_last                ),
    .i_per_valid                        (w_uart_rec_valid               ),
                    
    .i_post_clk                         (w_clk_125k                     ),
    .i_post_rst                         (w_clk_125k_rst                 ),    
    .o_post_len                         (w_cmd_per_len                  ),
    .o_post_data                        (w_cmd_per_data                 ),
    .o_post_last                        (w_cmd_per_last                 ),
    .o_post_valid                       (w_cmd_per_valid                )   
);

//系统参数管理
Param_ctrl Param_ctrl_u0(
    .i_clk                              (w_clk_125k                     ),
    .i_rst                              (w_clk_125k_rst                 ),
            
    .i_cmd_per_len                      (w_cmd_per_len                  ),
    .i_cmd_per_data                     (w_cmd_per_data                 ),
    .i_cmd_per_last                     (w_cmd_per_last                 ),
    .i_cmd_per_valid                    (w_cmd_per_valid                ),
    .o_cmd_post_len                     (w_cmd_post_len                 ),
    .o_cmd_post_data                    (w_cmd_post_data                ),
    .o_cmd_post_last                    (w_cmd_post_last                ),
    .o_cmd_post_valid                   (w_cmd_post_valid               ),
            
    .o_system_run                       (w_system_run                   ),
    .o_adc_channel                      (w_adc_channel                  ),
    .o_adc_speed                        (w_adc_speed                    ),
    .o_adc_start                        (w_adc_start                    ),
    .o_adc_trig                         (w_adc_trig                     ),
    .o_flash_start                      (                               ),
    .o_flash_num                        (                               ),
            
    .o_iic_scl                          (o_iic_scl                      ),//IIC的时钟
    .io_iic_sda                         (io_iic_sda                     ) //IIC的双向数据项
);


//总线分流器
BUS_MUX BUS_MUX_u0(
    .i_clk                              (w_clk_125k                     ),
    .i_rst                              (w_clk_125k_rst                 ),
    .i_cmd_len                          (w_cmd_post_len                 ),
    .i_cmd_data                         (w_cmd_post_data                ),
    .i_cmd_last                         (w_cmd_post_last                ),
    .i_cmd_valid                        (w_cmd_post_valid               ),
                    
    .o_adc_len                          (w_cmd_adc_len                  ),
    .o_adc_data                         (w_cmd_adc_data                 ),
    .o_adc_last                         (w_cmd_adc_last                 ),
    .o_adc_valid                        (w_cmd_adc_valid                ),          
    .o_flash_len                        (w_cmd_flash_len                ),
    .o_flash_data                       (w_cmd_flash_data               ),
    .o_flash_last                       (w_cmd_flash_last               ),
    .o_flash_valid                      (w_cmd_flash_valid              ),
    .o_ctrl_len                         (w_cmd_ctrl_len                 ),
    .o_ctrl_data                        (w_cmd_ctrl_data                ),
    .o_ctrl_last                        (w_cmd_ctrl_last                ),
    .o_ctrl_valid                       (w_cmd_ctrl_valid               )
);

//数据跨时钟域模块
Data_Mclk_buf Data_Mclk_buf_u1(
    .i_per_clk                          (w_clk_125k                     ),
    .i_per_rst                          (w_clk_125k_rst                 ),        
    .i_per_len                          (w_cmd_adc_len                  ),
    .i_per_data                         (w_cmd_adc_data                 ),
    .i_per_last                         (w_cmd_adc_last                 ),
    .i_per_valid                        (w_cmd_adc_valid                ),
                    
    .i_post_clk                         (w_clk_50Mhz                    ),
    .i_post_rst                         (w_clk_50Mhz_rst                ),    
    .o_post_len                         (w_cmd_adc_post_len             ),
    .o_post_data                        (w_cmd_adc_post_data            ),
    .o_post_last                        (w_cmd_adc_post_last            ),
    .o_post_valid                       (w_cmd_adc_post_valid           )   
);

//AD7606采集模块
AD7606_Module AD7606_Module_u0( 
    .i_clk                              (w_clk_50Mhz                    ),
    .i_rst                              (w_clk_50Mhz_rst                ),
    .o_ad_range                         (o_ad_range                     ),
    .o_ad_osc                           (o_ad_osc                       ),
    .o_ad_reset                         (o_ad_reset                     ),
    .o_ad_consvtA                       (o_ad_consvtA                   ),
    .o_ad_consvtB                       (o_ad_consvtB                   ),
    .o_ad_cs                            (o_ad_cs                        ),
    .o_ad_rd                            (o_ad_rd                        ),
    .i_ad_busy                          (i_ad_busy                      ),
    .i_ad_frstdata                      (i_ad_frstdata                  ),
    .i_ad_data                          (i_ad_data                      ),
    .i_system_run                       (w_system_run                   ),
    .i_adc_channel                      (w_adc_channel                  ),
    .i_adc_speed                        (w_adc_speed                    ),
    .i_adc_start                        (w_adc_start                    ),
    .i_adc_trig                         (w_adc_trig                     ),
    .i_extrig                           (i_extrig                       ),

    .i_cmd_len                          (w_cmd_adc_post_len             ),
    .i_cmd_data                         (w_cmd_adc_post_data            ),
    .i_cmd_last                         (w_cmd_adc_post_last            ),
    .i_cmd_valid                        (w_cmd_adc_post_valid           ),

    .o_adc_len                          (w_adc_len                      ),
    .o_adc_data                         (w_adc_data                     ),
    .o_adc_last                         (w_adc_last                     ),
    .o_adc_valid                        (w_adc_valid                    )
);

endmodule
