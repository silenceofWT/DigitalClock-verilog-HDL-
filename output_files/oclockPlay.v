`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    22:17:08 10/7/2019
// Design Name: 
// Module Name:    oclockPlay 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 时钟整点报时
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module oclockPlay(
	clk,  //时钟端
	rst_n, //复位端
	alarm_radio,			//输出蜂鸣器信号
	minute1,minute0,		//输入的时间，判断报时
	second1,second0
	);
		
	input clk, rst_n;
	input  [3:0] minute1,minute0,second1,second0;
	output       alarm_radio; 	
	reg 			 alarm_radio;  			//报时输出信号
	initial 
	begin 
		alarm_radio <= 1'b0;//初始化
	end

	parameter T1MS = 17'd25_000;
	parameter T500US = 17'd12_500;
	
	reg F500HZ, F1KHZ;
	reg [16:0] C1, C2;
	always @ ( posedge clk or negedge rst_n )
	begin
		if (!rst_n)
		begin 
			C1 <= 17'd0;
			F500HZ <= 1'd0;
		end
		else
		begin 
			if (C1 < T1MS - 1) C1 <= C1 + 1'b1;
			else begin C1 <= 17'd0; F500HZ = ~F500HZ; end
		end
	end
	
	always @ (posedge clk or negedge rst_n)
	begin 
		if (!rst_n)
		begin 
			C2 <= 17'd0;
			F1KHZ <= 1'b0;
		end
		else
		begin 
			if (C2 < T500US - 1)	C2 <= C2 + 1'b1;
			else begin C2 <= 17'd0; F1KHZ = ~F1KHZ; end
		end
	end

	
	always @ (minute1 or minute0 or second1 or second0)
	begin 
		begin 
		if ( minute1 == 4'd5 && minute0 == 4'd9)
		begin 
			case ({second1, second0})
				//8'h50, 
				//8'h52,
				//8'h54,
				8'h56,
				8'h58: alarm_radio <= F500HZ;
				default: alarm_radio <= 1'b0;
			endcase
		end
		else if ({minute1, minute0} == 8'h00 && {second1, second0} == 8'h00)
			alarm_radio <= F1KHZ;
		else
			alarm_radio <= 1'b0;
		end
	end

endmodule
