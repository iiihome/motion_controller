`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    09:41:22 12/19/2016 
// Design Name: 
// Module Name:    uart_rx 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
`define UART_CLK		18432000
`define BAUD_RATE		9600
`define NUM				8
`define STOP			1

module uart_rx(clk, rst, rx, p1, p2, p3, d_n, s_h, s_l, led1, led2, led3);
input clk;				// 18.432MHz
input rst;				// 复位
input rx;				// 接收
output [7:0]p1;			// para1
output [7:0]p2;			// para2
output [7:0]p3;			// para3
output [3:0]d_n;		// data_num
output [7:0]s_h;		// segment_h
output [7:0]s_l;		// segment_l

/********** 时钟计数 **********/
reg [15:0]cnt;			// 采样计数器
reg [15:0]cnt_stop;		// 停止位计数器

/********** 接收状态 **********/
reg rx_idle;				// 空闲
reg rx_done;				// 传送完成
reg [3:0]rx_cnt;			// 接收数据位计数器

/********** 接收字节 **********/
reg [15:0]data;
reg [3:0]data_cnt;		// 接收到的字节数
reg [3:0]data_num;		// 参数计数器

/********** 参数 **********/
reg [7:0]para;
reg [7:0]para1;			// 参数1：图形选择
reg [7:0]para2;			// 参数2：长（半径）
reg [7:0]para3;			// 参数3：宽

/********** 数码管 **********/
reg [7:0]segment_h;		// 高位数码管
reg [7:0]segment_l;		// 低位数码管

/********** 测试用 **********/
output led1, led2, led3;
reg t1, t2, t3;
assign led1 = t1;		// D31
assign led2 = t2;		// D30
assign led3 = t3;		// D29

always @(posedge clk or posedge rst) begin
	if(rst) begin
		segment_h = 0;
		segment_l = 0;

		cnt = 0;
		cnt_stop = 0;

		rx_idle = 1;
		rx_done = 0;
		rx_cnt = 0;

		data = 0;
		data_cnt = 0;
		data_num = 1;

		para = 0;
		para1 = 0;
		para2 = 0;
		para3 = 0;

		t1 = 0;
		t2 = 0;
		t3 = 0;
	end
	else begin
		/* 起始位 */
		if(rx_idle && !rx) begin
			cnt = cnt + 1;
			if(cnt == `UART_CLK / (2 * `BAUD_RATE)) begin	// 到达起始位中间
				cnt = 0;
				rx_idle = 0;
				data = 0;
				end
		end

		/* 数据 */
		if(!rx_idle && rx_cnt < `NUM) begin
			cnt = cnt + 1;
			if(cnt == `UART_CLK / `BAUD_RATE) begin
				cnt = 0;
				/* 保存ASCII码 */
				data[data_cnt + rx_cnt] = rx;
				rx_cnt = rx_cnt + 1;
			end
		end

		/* 停止位 */
		else if(!rx_idle && rx_cnt == `NUM) begin
			cnt_stop = cnt_stop + 1;
			if(cnt_stop == `UART_CLK * (`STOP + 1) / `BAUD_RATE) begin
				cnt_stop = 0;
				rx_cnt = 0;
				if(!rx) begin	// 下一字节数据
					data_cnt = data_cnt + 8;
				end
				else begin
					rx_idle = 1;
					rx_done = 1;
					data_cnt = 0;
				end
			end
		end

		/* 数据处理 */
		if(rx_done) begin
			rx_done = 0;
			
			/* 数码管显示 & 数码转换 */
			case(data & 8'hff)						// 高位
				8'h30: begin						//  0
					segment_h = 8'b00111111;
					para = 0;
				end
				8'h31: begin						// 1
					segment_h = 8'b00000110;
					para = 1;
				end
				8'h32: begin						// 2
					segment_h = 8'b01011011;
					para = 2;
				end
				8'h33: begin						// 3
					segment_h = 8'b01001111;
					para = 3;
				end
				8'h34: begin						// 4
					segment_h = 8'b01100110;
					para = 4;
				end
				8'h35: begin						// 5
					segment_h = 8'b01101101;
					para = 5;
				end
				8'h36: begin						// 6
					segment_h = 8'b01111101;
					para = 6;
				end
				8'h37: begin						// 7
					segment_h = 8'b00000111;
					para = 7;
				end
				8'h38: begin						// 8
					segment_h = 8'b01111111;
					para = 8;
				end
				8'h39: begin						// 9
					segment_h = 8'b01101111;
					para = 9;
				end
				8'h00: segment_h = 8'b00000000;		// 灭
				default: segment_h = 8'b01111001;	// 错误
			endcase
			case((data >> 8) & 8'hff)				// 低位
				8'h30: begin
					segment_l = 8'b00111111;
					para = para * 10;
				end
				8'h31: begin
					segment_l = 8'b00000110;
					para = para * 10 + 1;
				end
				8'h32: begin
					segment_l = 8'b01011011;
					para = para * 10 + 2;
				end
				8'h33: begin
					segment_l = 8'b01001111;
					para = para * 10 + 3;
				end
				8'h34: begin
					segment_l = 8'b01100110;
					para = para * 10 + 4;
				end
				8'h35: begin
					segment_l = 8'b01101101;
					para = para * 10 + 5;
				end
				8'h36: begin
					segment_l = 8'b01111101;
					para = para * 10 + 6;
				end
				8'h37: begin
					segment_l = 8'b00000111;
					para = para * 10 + 7;
				end
				8'h38: begin
					segment_l = 8'b01111111;
					para = para * 10 + 8;
				end
				8'h39: begin
					segment_l = 8'b01101111;
					para = para * 10 + 9;
				end
				8'h00: segment_l = 8'b00000000;
				default: segment_l = 8'b01111001;
			endcase
			
			/* 参数存储 */
			case(data_num)
				1: para1 = para;
				2: para2 = para << 1;
				3: para3 = para << 1;
				default: data_num = 4;
			endcase
			
			data_num = data_num + 1;
		end

		/* 测试 */
		t1 = (para1 == 3) ? 1 : 0;
		t2 = (para2 == 12) ? 1 : 0;
		t3 = (para3 == 20) ? 1 : 0;
	end
end

assign p1 = para1;
assign p2 = para2;
assign p3 = para3;
assign d_n = data_num;
assign s_h = segment_h;
assign s_l = segment_l;

endmodule
