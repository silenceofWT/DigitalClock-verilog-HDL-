`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    22:53:53 10/7/2019
// Design Name: 
// Module Name:    minCounter 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 分钟和秒模块
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

module minCounter(
	rst_n,//复位端
	clk,//适中端
	rdDone,//预制时间
	timeSetMode,//时间设置
	minute_set1,//分钟设置高位
	minute_set0,//分钟设置低位
	minute_init1,//分钟初始化高位
	minute_init0,//分钟初始化低位
	minute1,//分钟高位
	minute0,//分钟低位
	EO);//使能进位
	input  		 clk,rst_n, rdDone;
	input 		 timeSetMode;
	input  [3:0] minute_set1, minute_set0, minute_init0, minute_init1;
	output [3:0] minute1,minute0;
	output 		 EO;    
	reg 	 [3:0] minute1,minute0;
	reg 			 EO;
	
	always @(posedge clk or negedge rst_n or posedge timeSetMode or posedge rdDone)   
	begin   
	if (!rst_n)//遇到复位信号 分钟高位 低位 以及使能端清零
		begin
			minute1 <= 4'd0;
			minute0 <= 4'd0;
			EO      <= 1'd0;
		end
		else
		 begin
			if (rdDone)//遇到读取信号 初始化分钟高位低位
			begin
				minute1 <= minute_init1;
				minute0 <= minute_init0;
			end
			else if (timeSetMode)//遇到时间设置信号 获得设置的时间值
			begin 
				minute1 <= minute_set1;
				minute0 <= minute_set0;
			end
			else
			begin 
			if(minute0 < 4'b1001)//b1001 = 9 低位小于9时 低位加一 使能信号为0 不进位
				begin 
					minute0 <= minute0 + 4'b1;
					EO <= 1'b0;
				end
				else
				begin
					EO <= 1'b0;
					minute0 <= 4'b0;
					if(minute1 < 4'b0101)//b0101 = 5 分钟高位小于5 进位 
						minute1 <= minute1 + 4'b1;
					else//若等于五 再获取到分钟低位的进位信号以后 高位清0 并发出使能信号
					begin
						minute1 <= 4'b0;
						EO <= 1'b1;
					end
				end
			end
		end
	end
endmodule
