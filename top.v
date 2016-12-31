`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
// 
// Create Date:    09:40:57 12/19/2016
// Design Name:
// Module Name:    top
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
module top(
	input clk, 
	input rst, 
	output stop, 
	input rx, 
	output [7:0]segment_h, 
	output [7:0]segment_l, 
	output pul1, 
	output pul2, 
	output dir1, 
	output dir2, 
	output led1, 
	output led2, 
	output led3
);

wire [7:0]para1;		// 参数1：图形选择
wire [7:0]para2;		// 参数2：长（半径）
wire [7:0]para3;		// 参数3：宽
wire [3:0]data_num;		// 接收到的参数个数

wire lin_p1, lin_p2, rec_p1, rec_p2, cir_p1, cir_p2;
wire lin_d1, lin_d2, rec_d1, rec_d2, cir_d1, cir_d2;
wire lin_stop, rec_stop, cir_stop;

/* 实例化子模块 */
uart_rx uart_rx(
	clk, 
	rst, 
	rx, 
	para1, 
	para2, 
	para3, 
	data_num, 
	segment_h, 
	segment_l, 
	led1, 
	led2, 
	led3
);

line line(
	clk, 
	rst, 
	para1, 
	para2, 
	para3, 
	data_num, 
	lin_p1, 
	lin_p2, 
	lin_d1, 
	lin_d2, 
	lin_stop
);

rectangle rectangle(
	clk, 
	rst, 
	para1, 
	para2, 
	para3, 
	data_num, 
	rec_p1, 
	rec_p2, 
	rec_d1, 
	rec_d2, 
	rec_stop
);

circle circle(
	clk, 
	rst, 
	data_num, 
	para1, 
	para2, 
	cir_p1, 
	cir_p2, 
	cir_d1, 
	cir_d2, 
	cir_stop
);

assign stop = (rec_stop || lin_stop || cir_stop) ? 1 : 0;
assign pul1 = (para1 == 1) ? lin_p1 : ((para1 == 2) ? rec_p1 : cir_p1);
assign pul2 = (para1 == 1) ? lin_p2 : ((para1 == 2) ? rec_p2 : cir_p2);
assign dir1 = (para1 == 1) ? lin_d1 : ((para1 == 2) ? rec_d1 : cir_d1);
assign dir2 = (para1 == 1) ? lin_d2 : ((para1 == 2) ? rec_d2 : cir_d2);

endmodule
