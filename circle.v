`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:52:34 12/19/2016 
// Design Name: 
// Module Name:    circle 
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
`define DIVISION	30000
`define RATIO		62

module circle(clk, rst, data_num, para1, para2, pul1, pul2, dir1, dir2, stop);
input clk;
input rst;
input [7:0]para1;
input [7:0]para2;
input [3:0]data_num;
output pul1, pul2;
output dir1, dir2;
output stop;

reg [31:0]cnt;						// 分频计数
reg clk1;
reg signed[15:0]site_x, site_y;		// 坐标（有符号数）
reg px, py;
reg dx, dy;
reg cir_start, cir_stop;

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

always @(posedge clk1 or posedge rst) begin
	if(rst) begin
		site_x = 0;
		site_y = 0;
		px = 1;
		py = 1;
		dx = 0;
		dy = 0;
		cir_start = 0;
		cir_stop = 0;
	end
	else if(para1 == 3 && data_num == 5) begin
		if(!cir_start && para2) begin
			site_x = para2 * `RATIO;	// 坐标初值
			cir_start = 1;
		end
		/* 第一象限 */
		if(site_x >= 0 && site_y >= 0 && !cir_stop) begin
			dx = 0;
			dy = 1;
			if((site_x*site_x + site_y*site_y) >= para2*para2*`RATIO**2) begin
				px = ~px;
				site_x = (px == 0) ? (site_x - 1) : site_x;
			end
			else begin
				py = ~py;
				site_y = (py == 0) ? (site_y + 1) : site_y;
			end
		end
		/* 第二象限 */
		else if(site_x < 0 && site_y >= 0) begin
			dx = 0;
			dy = 0;
			if((site_x*site_x + site_y*site_y) >= para2*para2*`RATIO**2) begin
				py = ~py;
				site_y = (py == 0) ? (site_y - 1) : site_y;
			end
			else begin
				px = ~px;
				site_x = (px == 0) ? (site_x - 1) : site_x;
			end
		end
		/* 第三象限 */
		else if(site_x < 0 && site_y < 0) begin
			dx = 1;
			dy = 0;
			if((site_x*site_x + site_y*site_y) >= para2*para2*`RATIO**2) begin
				px = ~px;
				site_x = (px == 0) ? (site_x + 1) : site_x;
			end
			else begin
				py = ~py;
				site_y = (py == 0) ? (site_y - 1) : site_y;
			end
		end
		/* 第四象限 */
		else if(site_x >= 0 && site_y < 0) begin
			dx = 1;
			dy = 1;
//            cir_stop = 1;
			if((site_x*site_x + site_y*site_y) >= para2*para2*`RATIO**2) begin
				py = ~py;
				site_y = (py == 0) ? (site_y + 1) : site_y;
                if(site_y == 0)
                    cir_stop = 1;
			end
			else begin
				px = ~px;
				site_x = (px == 0) ? (site_x + 1) : site_x;
			end
		end
	end
end

assign pul1 = px;
assign pul2 = py;
assign dir1 = dx;
assign dir2 = dy;
assign stop = cir_stop;

endmodule
