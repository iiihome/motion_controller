`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    09:57:03 12/19/2016 
// Design Name: 
// Module Name:    line 
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
`define RATIO		62

module line(clk, rst, para1, para2, para3, data_num, pul1, pul2, dir1, dir2, stop);
input clk;
input rst;
input [7:0]para1;
input [7:0]para2;
input [7:0]para3;
input [3:0]data_num;
output pul1, pul2;
output dir1, dir2;
output stop;

reg [31:0]cnt_x, cnt_y;
reg [15:0]num_x, num_y;
reg line_stop;
reg px, py;
reg dx, dy;

always @(posedge clk or posedge rst) begin
	if(rst) begin
		cnt_x = 0;
		px = 1;
		num_x = 0;
		line_stop = 0;
	end
	else if(!line_stop && para1 == 1 && data_num == 5) begin
		cnt_x = cnt_x + 1;
		if(cnt_x == 20000 * para3) begin
			cnt_x = 0;
			px = ~px;
			num_x = (px == 0) ? (num_x + 1) : num_x;
			if(num_x == para2 * `RATIO)
				line_stop = 1;
		end
	end
end

always @(posedge clk or posedge rst) begin
	if(rst) begin
		cnt_y = 0;
		py = 1;
		num_y = 0;
	end
	else if(!line_stop && para1 == 1 && data_num == 5) begin
		cnt_y = cnt_y + 1;
		if(cnt_y == 20000 * para2) begin
			cnt_y = 0;
			py = ~py;
			num_y = (py == 0) ? (num_y + 1) : num_y;
		end
	end
end

assign pul1 = px;
assign pul2 = py;
assign dir1 = dx;
assign dir2 = dy;
assign stop = line_stop;

endmodule
