`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/07/29 15:23:26
// Design Name: 
// Module Name: eeprom_ctrl
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
`include "define_top.vh"

module eeprom_ctrl(
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

    /*--------iic dirve--------*/
    output [6 :0]       o_drive                 ,//用户输入设备地址
    output [15:0]       o_operation_addr        ,//用户输入存储地址
    output [7 :0]       o_operation_len         ,//用户输入读写长度
    output [1 :0]       o_operation_type        ,//用户输入操作类型
    output              o_opeartion_valid       ,//用户输入有效信号
    input               i_operation_ready       ,//用户输出准备信号

    output [7 :0]       o_write_data            ,//用户输入写数据
    input               i_write_req             ,//用户写数据请求信号

    input  [7 :0]       i_read_data             ,//输出IIC读到的数据
    input               i_read_valid             //输出IIC读数据有效
);

/***************function**************/

/***************parameter*************/
localparam              P_ST_IDLE       =   0               ,
                        P_ST_WRITE      =   1               ,
                        P_ST_WAIT       =   2               ,
                        P_ST_READ       =   3               ,
                        P_ST_REREAD     =   4               ,
                        P_ST_OREAD      =   5               ;

/***************port******************/             

/***************mechine***************/
reg  [7 :0]             r_st_current                        ;
reg  [7 :0]             r_st_next                           ;

/***************reg*******************/
reg                     ro_ctrl_operation_ready             ;
reg  [7 :0]             ro_ctrl_read_data                   ;
reg                     ro_ctrl_read_valid                  ;
reg  [7 :0]             ri_ctrl_write_data                  ;
reg                     ri_ctrl_write_sop                   ;
reg                     ri_ctrl_write_eop                   ;
reg                     ri_ctrl_write_valid                 ;
reg  [2 :0]             ri_ctrl_eeprom_addr                 ;
reg  [15:0]             ri_ctrl_operation_addr              ;
reg  [1 :0]             ri_ctrl_operation_type              ;
reg  [7 :0]             ri_ctrl_operation_len               ;
reg                     ri_operation_ready                  ;
reg  [7 :0]             ri_read_data                        ;
reg                     ri_read_valid                       ;
reg  [6 :0]             ro_drive                            ;
reg  [15:0]             ro_operation_addr                   ;
reg  [7 :0]             ro_operation_len                    ;
reg  [1 :0]             ro_operation_type                   ;
reg                     ro_opeartion_valid                  ;
reg                     r_fifo_read_en                      ;
reg  [7 :0]             r_read_cnt                          ;
reg  [15:0]             r_read_addr                         ;
reg                     r_read_vld_1d                       ;

/***************wire******************/     
wire                    w_ctrl_active                       ;
wire                    w_drive_end                         ;
wire                    w_drive_act                         ;
wire [7 :0]             w_fifo_read_data                    ;
wire                    w_fifo_empty                        ;


/***************component*************/
`ifdef VIVADO

    FIFO_8X1024 FIFO_8X1024_WRITE_U0 (
    .clk                  (i_clk                  ),
    .srst                 (i_rst                  ),
    .din                  (ri_ctrl_write_data     ),
    .wr_en                (ri_ctrl_write_valid    ),
    .rd_en                (i_write_req            ),
    .dout                 (o_write_data           ),
    .full                 (),
    .empty                () 
    );

    FIFO_8X1024 FIFO_8X1024_READ_U0 (
    .clk                  (i_clk                  ),
    .srst                 (i_rst                  ),
    .din                  (ri_read_data           ),
    .wr_en                (ri_read_valid          ),
    .rd_en                (r_fifo_read_en         ),
    .dout                 (w_fifo_read_data       ),
    .full                 (),
    .empty                (w_fifo_empty           ) 
    );
`elsif QUARTUS
    FIFO_8X1024 FIFO_8X1024_WRITE_U0(
	.clock                (i_clk                  ),
	.data                 (ri_ctrl_write_data     ),
	.rdreq                (i_write_req            ),
	.wrreq                (ri_ctrl_write_valid    ),
	.empty                (),
	.full                 (),
	.q                    (o_write_data           )
    );

    FIFO_8X1024 FIFO_8X1024_READ_U0(
	.clock                (i_clk                  ),
	.data                 (ri_read_data           ),
	.rdreq                (r_fifo_read_en         ),
	.wrreq                (ri_read_valid          ),
	.empty                (),
	.full                 (),
	.q                    (w_fifo_read_data       )
    );
`endif 

/***************assign****************/
assign o_ctrl_operation_ready   = ro_ctrl_operation_ready   ;
assign o_ctrl_read_data         = ro_ctrl_read_data         ;
assign o_ctrl_read_valid        = r_read_vld_1d             ;
assign w_ctrl_active            = i_ctrl_opeartion_valid&o_ctrl_operation_ready;
assign w_drive_end              = i_operation_ready & !ri_operation_ready;
assign w_drive_act              = o_opeartion_valid & i_operation_ready;
assign o_drive                  = ro_drive          ;
assign o_operation_addr         = ro_operation_addr ;
assign o_operation_len          = ro_operation_len  ;
assign o_operation_type         = ro_operation_type ;
assign o_opeartion_valid        = ro_opeartion_valid;
/***************always****************/
always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst) 
        r_st_current <= P_ST_IDLE;
    else
        r_st_current <= r_st_next;
end

always@(*)
begin
    case(r_st_current)
        P_ST_IDLE   :r_st_next = w_ctrl_active && i_ctrl_operation_type == 1 ? P_ST_WRITE : 
                                 w_ctrl_active && i_ctrl_operation_type == 2 ? P_ST_WAIT  :
                                 P_ST_IDLE; 
        P_ST_WRITE  :r_st_next = w_drive_end ? P_ST_IDLE : P_ST_WRITE; 
        P_ST_WAIT   :r_st_next = P_ST_READ;
        P_ST_READ   :r_st_next = w_drive_end ? 
                                 r_read_cnt == ri_ctrl_operation_len - 1  ? P_ST_OREAD : P_ST_REREAD 
                                 : P_ST_READ; 
        P_ST_REREAD :r_st_next = P_ST_READ;
        P_ST_OREAD  :r_st_next = w_fifo_empty ? P_ST_IDLE : P_ST_OREAD;
        default     :r_st_next = P_ST_IDLE;
    endcase
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst) 
        r_fifo_read_en <= 'd0;
    else if(w_fifo_empty)
        r_fifo_read_en <= 'd0;
    else if(r_st_current != P_ST_OREAD && r_st_next == P_ST_OREAD)
        r_fifo_read_en <= 'd1;
    else 
        r_fifo_read_en <= r_fifo_read_en;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst) 
        ro_ctrl_read_data <= 'd0;
    else 
        ro_ctrl_read_data <= w_fifo_read_data;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst) 
        ro_ctrl_read_valid <= 'd0;
    else if(w_fifo_empty)
        ro_ctrl_read_valid <= 'd0;
    else if(r_fifo_read_en)
        ro_ctrl_read_valid <= 'd1;
    else 
        ro_ctrl_read_valid <= ro_ctrl_read_valid;
end


always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst) 
        r_read_vld_1d <= 'd0;
    else 
        r_read_vld_1d <= ro_ctrl_read_valid;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst) begin
        ri_ctrl_eeprom_addr    <= 'd0;
        ri_ctrl_operation_addr <= 'd0;
        ri_ctrl_operation_type <= 'd0;
        ri_ctrl_operation_len  <= 'd0;
    end else if(w_ctrl_active) begin
        ri_ctrl_eeprom_addr    <= i_ctrl_eeprom_addr    ;
        ri_ctrl_operation_addr <= i_ctrl_operation_addr;
        ri_ctrl_operation_type <= i_ctrl_operation_type;
        ri_ctrl_operation_len  <= i_ctrl_operation_len;
    end else begin
        ri_ctrl_eeprom_addr    <= ri_ctrl_eeprom_addr   ;
        ri_ctrl_operation_addr <= ri_ctrl_operation_addr;
        ri_ctrl_operation_type <= ri_ctrl_operation_type;
        ri_ctrl_operation_len  <= ri_ctrl_operation_len;
    end
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst) begin
        ri_ctrl_write_data  <= 'd0;
        ri_ctrl_write_sop   <= 'd0;
        ri_ctrl_write_eop   <= 'd0;
        ri_ctrl_write_valid <= 'd0;
    end else begin
        ri_ctrl_write_data  <= i_ctrl_write_data    ;
        ri_ctrl_write_sop   <= i_ctrl_write_sop     ;
        ri_ctrl_write_eop   <= i_ctrl_write_eop     ;
        ri_ctrl_write_valid <= i_ctrl_write_valid   ;
    end
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        ro_ctrl_operation_ready <= 'd1;
    else if(w_ctrl_active)
        ro_ctrl_operation_ready <= 'd0;
    else if(r_st_current == P_ST_IDLE)
        ro_ctrl_operation_ready <= 'd1;
    else
        ro_ctrl_operation_ready <= ro_ctrl_operation_ready; 
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        ri_operation_ready <= 'd0;
    else
        ri_operation_ready <= i_operation_ready;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst) begin
        ri_read_data  <= 'd0;
        ri_read_valid <= 'd0;
    end else begin
        ri_read_data  <= i_read_data ;
        ri_read_valid <= i_read_valid;
    end
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst) begin
        ro_drive           <= 'd0;
        ro_operation_addr  <= 'd0;
        ro_operation_len   <= 'd0;
        ro_operation_type  <= 'd0;
        ro_opeartion_valid <= 'd0;
    end else if(w_drive_act) begin
        ro_drive           <= 'd0;
        ro_operation_addr  <= 'd0;
        ro_operation_len   <= 'd0;
        ro_operation_type  <= 'd0;
        ro_opeartion_valid <= 'd0;
    end else if(ri_ctrl_write_eop) begin
        ro_drive           <= {4'b1010,ri_ctrl_eeprom_addr};
        ro_operation_addr  <= ri_ctrl_operation_addr;
        ro_operation_len   <= ri_ctrl_operation_len;
        ro_operation_type  <= ri_ctrl_operation_type;
        ro_opeartion_valid <= 'd1;
    end else if(r_st_next == P_ST_READ && r_st_current != P_ST_READ) begin
        ro_drive           <= {4'b1010,ri_ctrl_eeprom_addr};
        ro_operation_addr  <= r_read_addr;
        ro_operation_len   <= 1;
        ro_operation_type  <= ri_ctrl_operation_type;
        ro_opeartion_valid <= 'd1;
    end else begin
        ro_drive           <= ro_drive          ;
        ro_operation_addr  <= ro_operation_addr ;
        ro_operation_len   <= ro_operation_len  ;
        ro_operation_type  <= ro_operation_type ;
        ro_opeartion_valid <= ro_opeartion_valid;
    end
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_read_addr <= 'd0;
    else if(w_ctrl_active)
        r_read_addr <= i_ctrl_operation_addr;
    else if(r_st_current == P_ST_READ && w_drive_end)
        r_read_addr <= r_read_addr + 1 ;
    else
        r_read_addr <= r_read_addr;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_read_cnt <= 'd0;
    else if(r_st_current == P_ST_IDLE)
        r_read_cnt <= 'd0;
    else if(r_st_current == P_ST_READ && w_drive_end)
        r_read_cnt <= r_read_cnt  +1;
    else
        r_read_cnt <= r_read_cnt;
end

endmodule
