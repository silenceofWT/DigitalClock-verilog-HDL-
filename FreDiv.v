`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:14:03 10/7/2019 
// Design Name: 
// Module Name:    FreDiv 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 分频模块
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module FreDiv(
	input clk,//时钟信号
	input RESET,//复位信号
	output reg clk1hz,//分频出1hz信号
	output reg clk5ms//数码管扫描频率
	);
	
	reg [25:0] cnt, cnt1;//两个计数器
	always @ (posedge clk or negedge RESET)//分频出1hz
	begin 
	if (!RESET)//复位信号触发
		begin 
			clk1hz <= 0;
			cnt <= 0;
		end
		else
		begin //分频出1hz的信号
			if (cnt == 26'd24_999_999)
			begin
				cnt <= 26'd0;
				clk1hz <= ~	clk1hz;
			end
			else
			begin 
				cnt <= cnt + 1'b1;
			end
		end
	end
	
	always @ (posedge clk or negedge RESET)
	begin 
		if (!RESET)//复位信号触发
		begin 
			clk5ms <= 0;
			cnt1 <= 0;
		end
		else
		begin //分频出5ms的信号
			if (cnt1 == 26'd24_999_9)
			begin
				cnt1 <= 26'd0;
				clk5ms <= ~	clk5ms;
			end
			else
			begin 
				cnt1 <= cnt1 + 1'b1;
			end
		end
	end
	
endmodule
