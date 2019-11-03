`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:54:28 10/7/2019 
// Design Name: 
// Module Name:    hourCounter 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 小时模块
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module hourCounter(
	rst_n, 				//复位信号
	clk,				//时钟
	rdDone,
	timeSetMode,   //模式选择
	hour_set1,    
	hour_set0,
	hour_init1,   //小时高位初始化
	hour_init0,   //小时低位初始化
	hour1,		  //小时高位 0-1
	hour0,			  //小时低位 0-9
	);				 
	
	input  		 clk, rst_n, rdDone; 		//时钟与使能端
	input 		 timeSetMode;
	input  [3:0] hour_set1, hour_set0, hour_init1, hour_init0;
	output [3:0] hour1,hour0;					//小时的高位和低位
	reg    [3:0] hour1,hour0;
	always @(posedge clk or negedge rst_n or posedge timeSetMode or posedge rdDone)
	begin 
	if (!rst_n)//若使用复位端小时清零
		begin 
			hour1 <= 4'd0;
			hour0 <= 4'd0;
		end
		else
		begin
			if (rdDone)//初始化小时位
			begin
				hour1 <= hour_init1;
				hour0 <= hour_init0;
			end
			else if (timeSetMode)//时间模式
			begin 
				hour1 <= hour_set1;
				hour0 <= hour_set0;
			end
			else
			begin 
				if(hour0 < 4'b0011 && hour1 == 4'b0010)//小时低位小于3且小时高位等于2时		
				begin
					hour0 <= hour0 + 4'b1;
				end
				else if (hour1 < 4'b0010 && hour0 < 4'b1001)//小时高位小于2且小时高位等于5时		
				begin 
					hour0 <= hour0 + 4'b1;
				end
				else
				begin
					hour0 <= 4'b0;
					if(hour1 < 4'b0010)
						hour1 <= hour1 + 4'b1;
					else
					begin
						hour1 <= 4'b0;
					end
				end
			end
		end
	end
endmodule
