//////////////////////////////////////////////////////////////////////////////////
// Company:         xxx
// Engineer:        yuqi
// 
// Create Date:     2023/07/01
// Design Name:     xxx
// Module Name:     xxx
// Project Name:    xxx
// Target Devices:  xxx
// Tool Versions:   VIVADO2017.4
// Description:     xxx
// 
// Dependencies:    xxx
// 
// Revision:     v0.1
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module iic_drive#(
    parameter           P_ADDR_WIDTH = 16                      
)(              
    input               i_clk                   ,//模块输入时钟
    input               i_rst                   ,//模块输入复位-高有效

    /*--------用户接口--------*/
    input  [6 :0]       i_drive                 ,//用户输入设备地址
    input  [15:0]       i_operation_addr        ,//用户输入存储地址
    input  [7 :0]       i_operation_len         ,//用户输入读写长度
    input  [1 :0]       i_operation_type        ,//用户输入操作类型
    input               i_opeartion_valid       ,//用户输入有效信号
    output              o_operation_ready       ,//用户输出准备信号

    input  [7 :0]       i_write_data            ,//用户输入写数据
    output              o_write_req             ,//用户写数据请求信号

    output [7 :0]       o_read_data             ,//输出IIC读到的数据
    output              o_read_valid            ,//输出IIC读数据有效

    /*--------IIC接口--------*/
    output              o_iic_scl               ,//IIC的时钟
    inout               io_iic_sda               //IIC的双向数据项
);

/***************function**************/

/***************parameter*************/
parameter               P_ST_IDLE   = 0         ,//状态机-空闲
                        P_ST_START  = 1         ,//状态机-起始
                        P_ST_UADDR  = 2         ,//状态机-设备地址
                        P_ST_DADDR1 = 3         ,//状态机-存储地址高位
                        P_ST_DADDR2 = 4         ,//状态机-存储地址地位
                        P_ST_WRITE  = 5         ,//状态机-写数据
                        P_ST_RESTART= 6         ,
                        P_ST_READ   = 7         ,//状态机-读数据
                        P_ST_WAIT   = 8         ,
                        P_ST_STOP   = 9         ,//状态机-停止
                        P_ST_EMPTY  = 10        ;

localparam              P_W =   1               ,//2'b01
                        P_R =   2               ;//2'b10
                        

/***************port******************/             

/***************mechine***************/
reg  [7 :0]             r_st_current            ;//当前状态机
reg  [7 :0]             r_st_next               ;//下一个状态机
reg  [7 :0]             r_st_cnt                ;//状态机计数器


/***************reg*******************/
reg                     ro_operation_ready      ;//操作准备信号
reg                     ro_write_req            ;//写数据请求
reg                     ro_write_valid          ;//写数据有效
reg  [7 :0]             ro_read_data            ;//读数据
reg                     ro_read_valid           ;//读数据有效
reg                     ro_iic_scl              ;//IIC的SCL输出寄存器
reg  [7 :0]             ri_drive                ;//输入的设备地址
reg  [15:0]             ri_operation_addr       ;//输入的存储地址
reg  [7 :0]             ri_operation_len        ;//输入的读写长度
reg  [1 :0]             ri_operation_type       ;//输入读写类型
reg  [7 :0]             ri_write_data           ;//输入的写数据
reg                     r_iic_st                ;//iic时钟状态
reg                     r_iic_sda_ctrl          ;//iic数据三态门控制信号
reg                     ro_iic_sda              ;//iic数据信号
reg  [7 :0]             r_wr_cnt                ;//读写数据bit计数器
reg                     r_slave_ack             ;//iic操作里的从机应答
reg                     r_ack_valid             ;//应答有效
reg                     r_st_restart            ;
reg                     r_ack_lock              ;
reg  [7 :0]             r_read_drive            ;

/***************wire******************/
wire                    w_operation_active      ;//操作激活信号
wire                    w_st_trun               ;//状态机跳转信号
wire                    w_iic_sda               ;//iic数据线输入信号

/***************component*************/

/***************assign****************/
//组合逻辑
assign o_operation_ready    = ro_operation_ready    ;//准备信号
assign o_write_req          = ro_write_req          ;//写数据请求信号
assign o_read_data          = ro_read_data          ;//读数据
assign o_read_valid         = ro_read_valid         ;//读数据有效
assign o_iic_scl            = ro_iic_scl            ;//iic的scl
assign w_operation_active   = i_opeartion_valid & o_operation_ready ;//激活信号
assign w_st_trun            = r_st_cnt == 8 && r_iic_st             ;//状态机跳转条件
//三态门使用
assign io_iic_sda           = r_iic_sda_ctrl  ? ro_iic_sda : 1'bz   ;//三态门输出
assign w_iic_sda            = !r_iic_sda_ctrl ? io_iic_sda : 1'b0   ;//三态门输入

// IOBUF #(
//    .DRIVE           (12                 ),
//    .IBUF_LOW_PWR    ("TRUE"             ),
//    .IOSTANDARD      ("DEFAULT"          ),
//    .SLEW            ("SLOW"             ) 
// ) 
// IOBUF_u0 
// (      
//    .O               (ro_iic_sda         ),  
//    .IO              (io_iic_sda         ),  
//    .I               (w_iic_sda          ),  
//    .T               (!r_iic_sda_ctrl    )   
// );

/***************always****************/
//第一段状态
//时序逻辑
always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_st_current <= P_ST_IDLE;
    else 
        r_st_current <= r_st_next;
end

// wire w_st_current;
// wire r_st_current;
// assign w_st_current = i_rst ? P_ST_IDLE : r_st_next;

// FDCE #(
//    .INIT(1'b0) // Initial value of register (1'b0 or 1'b1)
// ) FDCE_inst (
//    .Q(r_st_current[0]),      // 1-bit Data output
//    .C(i_clk),      // 1-bit Clock input
//    .CE(1),    // 1-bit Clock enable input
//    .CLR(0),  // 1-bit Asynchronous clear input
//    .D(w_st_current[0])       // 1-bit Data input
// );

// FDCE #(
//    .INIT(1'b0) // Initial value of register (1'b0 or 1'b1)
// ) FDCE_inst (
//    .Q(r_st_current[1]),      // 1-bit Data output
//    .C(i_clk),      // 1-bit Clock input
//    .CE(1),    // 1-bit Clock enable input
//    .CLR(0),  // 1-bit Asynchronous clear input
//    .D(w_st_current[1])       // 1-bit Data input
// );
//状态机跳转

//组合逻辑
always@(*)
begin
    case(r_st_current)
        P_ST_IDLE   : r_st_next <= w_operation_active   ? P_ST_START    : P_ST_IDLE     ;//空闲，操作激活时跳转到起始状态
        P_ST_START  : r_st_next <= P_ST_UADDR;                                           //起始状态，跳转设备地址
        P_ST_UADDR  : r_st_next <= w_st_trun            ? 
                                   r_st_restart ? P_ST_READ : P_ST_DADDR1                //判断是否时重启，重启转入读状态，不是重启转入写存储地址状态
                                   : P_ST_UADDR    ;                                     //写设备地址，写完跳转存储地址
        P_ST_DADDR1 : r_st_next <= r_slave_ack          ? P_ST_STOP     :                //存储地址，先等待应答，应答后操作结束跳转存储地址低位
                                   w_st_trun            ? P_ST_DADDR2   : P_ST_DADDR1   ;
        P_ST_DADDR2 : r_st_next <= w_st_trun & ri_operation_type == P_W ? P_ST_WRITE    ://存储地址低位，判断读写，读跳转读状态，写跳转写状态 
                                   w_st_trun & ri_operation_type == P_R ? P_ST_RESTART  :
                                   P_ST_DADDR2   ;
        P_ST_WRITE  : r_st_next <= w_st_trun & r_wr_cnt == ri_operation_len - 1  
                                                        ? P_ST_WAIT     : P_ST_WRITE    ;//写数据状态，写完目标长度跳转结束
        P_ST_RESTART: r_st_next <= P_ST_STOP;                                            //读数据时，重启总线状态
        P_ST_READ   : r_st_next <= w_st_trun ? P_ST_WAIT     : P_ST_READ     ;//读数据状态，写完目标长度跳转结束
        P_ST_WAIT   : r_st_next <= P_ST_STOP    ;
        P_ST_STOP   : r_st_next <= r_st_cnt == 1? P_ST_EMPTY : P_ST_STOP;
        P_ST_EMPTY  : r_st_next <= r_st_restart | r_ack_lock ? P_ST_START : P_ST_IDLE;   //空状态，等待IIC成功停止，判断是否重启，重启转入START，不重启转入IDLE
        default     : r_st_next <= P_ST_IDLE;
    endcase
end

//iic应答状态，1为没应答
//时序逻辑
always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_ack_lock <= 'd0;
    else if(r_ack_valid && !w_iic_sda && r_st_current == P_ST_DADDR1)
        r_ack_lock <= 'd0;
    else if(r_ack_valid && w_iic_sda && r_st_current == P_ST_DADDR1)
        r_ack_lock <= 'd1;
    else 
        r_ack_lock <= r_ack_lock;
end

//读数据时，假写操作后重启信号
always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_st_restart <= 'd0;
    else if(r_st_current == P_ST_READ)
        r_st_restart <= 'd0;
    else if(r_st_current == P_ST_RESTART)
        r_st_restart <= 'd1;
    else 
        r_st_restart <= r_st_restart;
end

//操作准备信号
always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        ro_operation_ready <= 'd1;
    else if(w_operation_active)
        ro_operation_ready <= 'd0;
    else if(r_st_current == P_ST_IDLE)
        ro_operation_ready <= 'd1;
    else 
        ro_operation_ready <= ro_operation_ready;
end

//寄存操作数据
always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst) begin
        ri_drive          <= 'd0;
        ri_operation_addr <= 'd0;
        ri_operation_len  <= 'd0;
        ri_operation_type <= 'd0;
    end else if(w_operation_active) begin
        ri_drive          <= {i_drive,1'b0};
        ri_operation_addr <= i_operation_addr   ;
        ri_operation_len  <= i_operation_len    ;
        ri_operation_type <= i_operation_type   ;
    end else begin
        ri_drive          <= ri_drive           ;
        ri_operation_addr <= ri_operation_addr  ;
        ri_operation_len  <= ri_operation_len   ;
        ri_operation_type <= ri_operation_type  ;
    end
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_read_drive <= 'd0;
    else if(w_operation_active)
        r_read_drive <= {i_drive,1'b1};
    else 
        r_read_drive <= r_read_drive;
end

//状态计数器
always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst) 
        r_st_cnt <= 'd0;
    else if(r_st_current != r_st_next || ro_write_valid || ro_read_valid)//状态跳转、写完8bit数、读写8bit数
        r_st_cnt <= 'd0;
    else if(r_st_current == P_ST_STOP)
        r_st_cnt <= r_st_cnt + 1;
    else if(r_iic_st)
        r_st_cnt <= r_st_cnt + 1;
    else
        r_st_cnt <= r_st_cnt;
end

//iic时钟
always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        ro_iic_scl <= 'd1;
    else if(r_st_current >= P_ST_UADDR && r_st_current <= P_ST_WAIT)
        ro_iic_scl <= ~ro_iic_scl;
    else
        ro_iic_scl <= 'd1;
end

//iic时钟状态
always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_iic_st <= 'd0;
    else if(r_st_current >= P_ST_UADDR && r_st_current <= P_ST_WAIT)
        r_iic_st <= ~r_iic_st;
    else
        r_iic_st <= 'd0;
end

//iic数据线三态门控制
always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_iic_sda_ctrl <= 'd0;
    else if(r_st_cnt == 8 || r_st_next == P_ST_IDLE)
        r_iic_sda_ctrl <= 'd0;
    else if(r_st_current >= P_ST_START && r_st_current <= P_ST_WRITE || r_st_current == P_ST_STOP)
        r_iic_sda_ctrl <= 'd1;
    else
        r_iic_sda_ctrl <= r_iic_sda_ctrl;
end
 
//iic数据线写数据
always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        ro_iic_sda <= 'd0;
    else if(r_st_current == P_ST_START)
        ro_iic_sda <= 'd0;
    else if(r_st_current == P_ST_UADDR)
        ro_iic_sda <= r_st_restart ? r_read_drive[7 - r_st_cnt] :  ri_drive[7 - r_st_cnt];
    else if(r_st_current == P_ST_DADDR1)
        ro_iic_sda <= ri_operation_addr[15 - r_st_cnt];
    else if(r_st_current == P_ST_DADDR2)
        ro_iic_sda <= ri_operation_addr[7  - r_st_cnt];
    else if(r_st_current == P_ST_WRITE)
        ro_iic_sda <= ri_write_data[7  - r_st_cnt];
    else if(r_st_current == P_ST_STOP && r_st_cnt == 1)
        ro_iic_sda <= 'd1;
    else
        ro_iic_sda <= 'd0;
end

//写请求
always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        ro_write_req <= 'd0;
    else if(r_st_current == P_ST_DADDR2 && ri_operation_type == P_W && r_st_cnt == 7 && r_iic_st)
        ro_write_req <= 'd1;
    else if(r_st_current >= P_ST_DADDR2 && ri_operation_type == P_W && r_st_cnt == 7 && r_iic_st)
        ro_write_req <= r_wr_cnt < ri_operation_len - 1 ? 1'b1 : 1'b0;
    else
        ro_write_req <= 'd0;
end

//写有效
always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        ro_write_valid <= 'd0;
    else 
        ro_write_valid <= ro_write_req;
end

//写数据
always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        ri_write_data <= 'd0;
    else if(ro_write_valid)
        ri_write_data <= i_write_data;
    else        
        ri_write_data <= ri_write_data;
end

//读写计数器
always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_wr_cnt <= 'd0;
    else if(r_st_current == P_ST_IDLE)
        r_wr_cnt <= 'd0;
    else if((r_st_current == P_ST_WRITE || r_st_current == P_ST_READ) && w_st_trun)
        r_wr_cnt <= r_wr_cnt + 1;
    else 
        r_wr_cnt <= r_wr_cnt;
end

//读出数据
always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        ro_read_data <= 'd0;
    else if(r_st_current == P_ST_READ && r_st_cnt >= 1 && r_st_cnt <= 8 && !r_iic_st)       
        ro_read_data <= {ro_read_data[6:0],w_iic_sda};
    else 
        ro_read_data <= ro_read_data;
end

//读出数据有效
always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        ro_read_valid <= 'd0;
    else if(r_st_current == P_ST_READ && r_st_cnt == 8 && !r_iic_st)
        ro_read_valid <= 'd1;
    else 
        ro_read_valid <= 'd0;
end

//从机应答信号
always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_slave_ack <= 'd0;
    else if(r_ack_valid)
        r_slave_ack <= w_iic_sda;
    else 
        r_slave_ack <= 'd0;
end

//指示应答有效信号
always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_ack_valid <= 'd0;
    else 
        r_ack_valid <= w_st_trun;
end
endmodule