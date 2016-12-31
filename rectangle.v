`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:03:36 12/19/2016 
// Design Name: 
// Module Name:    rectangle 
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
`define DIVISION	40000
`define RATIO		62

module rectangle(clk, rst, para1, para2, para3, data_num, pul1, pul2, dir1, dir2, stop);
input clk;
input rst;
input [7:0]para1;
input [7:0]para2;
input [7:0]para3;
input [3:0]data_num;
output pul1, pul2;
output dir1, dir2;
output stop;

reg [31:0]cnt;
reg clk1;
reg [3:0]num;
reg [15:0]num_x;
reg [15:0]num_y;
reg px, py;
reg dx, dy;
reg rec_flag;		// 纵横交替标志
reg rec_stop;

/* 时钟分频 */
always @(posedge clk or posedge rst) begin
	if(rst) begin
		cnt = 0;
		clk1 = 0;
	end
	else begin
		cnt = cnt + 1;
		if(cnt == `DIVISION)
			cnt = 0;
		else if(cnt == (`DIVISION >> 2))
			clk1 = ~clk1;
	end
end

always@(posedge clk1 or posedge rst) begin
	if(rst) begin
		num = 0;
		num_x = 0;
		num_y = 0;
		px = 1;
		py = 1;
		dx = 0;
		dy = 0;
		rec_flag = 0;
		rec_stop = 0;
	end
	else if(!rec_stop && para1 == 2 && data_num == 5) begin
		if(!rec_flag) begin
			px = ~px;
			num_x = (px == 0) ? (num_x + 1) : num_x;
			if(num_x == para2 * `RATIO) begin
				num_x = 0;
				rec_flag = 1;
				dx = ~dx;
			end
		end
		else begin
			py = ~py;
			num_y = (py == 0) ? (num_y + 1) : num_y;
			if(num_y == para3 * `RATIO) begin
				num_y = 0;
				rec_flag = 0;
				dy = ~dy;
				
				num = num + 1;
				rec_stop = (num == 2) ? 1 : 0;
			end
		end
	end
end

assign pul1 = px;
assign pul2 = py;
assign dir1 = dx;
assign dir2 = dy;
assign stop = rec_stop;

endmodule
