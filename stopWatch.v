`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    22:53:53 10/7/2019
// Design Name: 
// Module Name:    stopWatch 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description:  秒表模块
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module stopWatch(
	input 				clk,
	input 				rst_n,
	input 				stopWatchMode,
	input 				SW_Start,															//控制开始与暂停
	input 				SW_Cnt,
	output reg [3:0] 	stopWatchMinute1, stopWatchMinute0,
	output reg [3:0] 	stopWatchSecond1, stopWatchSecond0,
	output reg [3:0] 	stopWatchMicroSecond1, stopWatchMicroSecond0
	);
	
	wire clk5ms;
	wire EO_min, EO_sec;
	reg  RESET;
	
	parameter T400MS = 21'd50_0000;
	
	//**************************开始按键消抖*********************
	reg F2, F1;
	
	always @ (posedge clk or negedge rst_n)
	begin
		if (!rst_n)
		begin 
			{F2, F1} <= 2'b11;
		end
		else
			{F2, F1} <= {F1, SW_Start};
	end
	
	wire isSW_StartH2L = (F2 == 1 && F1 == 0);
	wire isSW_StartL2H = (F2 == 0 && F1 == 1);
	
	reg [3:0] i;
	reg isSW_StartPress, isSW_StartRelease;
	reg [18:0] C1;
	
	always @ ( posedge clk or negedge rst_n )
	begin 
		if (!rst_n)
		begin 
			
			{isSW_StartPress, isSW_StartRelease} <= 2'b00;
			C1 <= 19'd0;
			i  <= 4'd0;
		end
		else 
		begin 
			case (i)
				0:
				if (isSW_StartH2L) i <= i + 1'b1;
				1:
				if (C1 == T400MS - 1) begin C1 <= 19'd0; i <= i + 1'b1; end
				else C1 <= C1 + 1'b1;
				2:
				begin isSW_StartPress <= 1'b1; i <= i + 1'b1; end
				3:
				begin isSW_StartPress <= 1'b0; i <= i + 1'b1; end
				4:
				begin if (isSW_StartL2H) i <= i + 1'b1; end
				5:
				if (C1 == T400MS - 1) begin C1 <= 19'd0; i <= i + 1'b1; end
				else C1 <= C1 + 1'b1;
				6:
				begin isSW_StartRelease <= 1'b1; i <= i + 1'b1; end
				7:
				begin isSW_StartRelease <= 1'b0; i <= 4'd0; end
			endcase
		end
	end
	//*************************************************************
	//**************************暂停按键消抖************************
	reg F4, F3;
	
	always @ (posedge clk or negedge rst_n)
	begin
		if (!rst_n)
		begin 
			{F4, F3} <= 2'b11;
		end
		else
			{F4, F3} <= {F3, SW_Cnt};
	end
	
	wire isSW_CntH2L = (F4 == 1 && F3 == 0);
	wire isSW_CntL2H = (F4 == 0 && F3 == 1);
	
	reg [3:0] _i;
	reg isSW_CntPress, isSW_CntRelease;
	reg [18:0] C2;
	
	always @ ( posedge clk or negedge rst_n )
	begin 
		if (!rst_n)
		begin 
			_i <= 4'd0;
			{isSW_CntPress, isSW_CntRelease} <= 1'b0;
			C2 <= 19'd0;
		end
		else 
		begin 
			case (_i)
				0:
				if (isSW_CntH2L) _i <= _i + 1'b1;
				1:
				if (C2 == T400MS - 1) begin C2 <= 19'd0; _i <= _i + 1'b1; end
				else C2 <= C2 + 1'b1;
				2:
				begin isSW_CntPress <= 1'b1; _i <= _i + 1'b1; end
				3:
				begin isSW_CntPress <= 1'b0; _i <= _i + 1'b1; end
				4:
				if (isSW_CntL2H) _i <= _i + 1'b1;
				5:
				if (C2 == T400MS - 1) begin C2 <= 19'd0; _i <= _i + 1'b1; end
				else C2 <= C2 + 1'b1;
				6:
				begin isSW_CntRelease <= 1'b1; _i <= _i + 1'b1; end
				7:
				begin isSW_CntRelease <= 1'b0; _i <= 4'd0; end
			endcase
		end
	end
	//*************************************************************
	reg Enable;
	reg stopWatchStatus;                         //1表示开始，0表示停止
	always @ (posedge clk or negedge rst_n)
	begin
		if (!rst_n)
		begin
			Enable 			 <= 1'b0;
			stopWatchStatus <= 1'b0;
		end
		else
		begin
			if (isSW_StartPress && stopWatchMode && !stopWatchStatus)
			begin
				Enable          <= 1'b1;
				stopWatchStatus <= 1'b1;
			end
			else if (isSW_StartPress && stopWatchMode && stopWatchStatus)
			begin
				Enable 			 <= 1'b0;
				stopWatchStatus <= 1'b0;
			end
			else if (!stopWatchMode)
			begin
				stopWatchStatus <= 1'b0;
				Enable 			 <= 1'b0;
			end
			else if (!RESET)
			begin
				Enable 		    <= 1'b0;
				stopWatchStatus <= 1'b0;
			end
			else
				Enable <= Enable;
		end
	end
	
	
	
	/*always @ (*) //若没有开启秒表模式，秒表一直处于复位状态
	begin
		if (stopWatchMode)
		begin
			RESET <= rst_n;
		end
		else
			RESET <= 1'b0;
	end*/
	
	wire [3:0] Minute1, Minute0;
	wire [3:0] Second1, Second0;
	wire [3:0] MicroSecond1, MicroSecond0;
	always @ (posedge clk or negedge rst_n)
	begin
		if (!rst_n)
		begin
			stopWatchMinute1 <= Minute1;
			stopWatchMinute0 <= Minute0;
			stopWatchSecond1 <= Second1;
			stopWatchSecond0 <= Second0;
			stopWatchMicroSecond1 <= MicroSecond1;
			stopWatchMicroSecond0 <= MicroSecond0;
		end
		else
		begin
			if (status)                         //处于读状态
			begin
				stopWatchMinute1 <= q_sig[23:20];
				stopWatchMinute0 <= q_sig[19:16];
				stopWatchSecond1 <= q_sig[15:12];
				stopWatchSecond0 <= q_sig[11:8];
				stopWatchMicroSecond1 <= q_sig[7:4];
				stopWatchMicroSecond0 <= q_sig[3:0];
			end
			else
			begin											//处于写状态
				stopWatchMinute1 <= Minute1;
				stopWatchMinute0 <= Minute0;
				stopWatchSecond1 <= Second1;
				stopWatchSecond0 <= Second0;
				stopWatchMicroSecond1 <= MicroSecond1;
				stopWatchMicroSecond0 <= MicroSecond0;
			end
		end
	end
	
	reg  [04:0] address_sig;
	reg  [23:0] data_sig;
	reg        	wren_sig;
	wire [23:0] q_sig;
	reg  [03:0] timeCnt;								//计次超过5次该按键变为显示选择键
	//reg [5:0] timeReadCnt;
	reg       status;
	always @ (posedge clk or negedge rst_n)
	begin
		if (!rst_n)
		begin
			status      <= 1'b0;
			address_sig <= 5'd0;
			timeCnt     <= 4'd0;
			wren_sig    <= 1'bz;
		end
		else
		begin
		if (stopWatchMode)		//秒表模式&&按下计次按键，秒表运行状态计次有效，否则为复位
		begin
			RESET <= rst_n;
			if (stopWatchStatus && isSW_CntPress)						//计次
			begin
				if (timeCnt < 4'd5)
				begin
					status 		<= 1'b0;
					timeCnt 		<= timeCnt + 1'b1;
					address_sig <= address_sig + 1'b1;
					data_sig    <= {Minute1, Minute0, Second1, Second0, MicroSecond1, MicroSecond0};
					wren_sig    <= 1'b1;
				end
				else if (timeCnt > 4'd4 && timeCnt < 4'd10)
				begin
					if (timeCnt == 4'd5)
						address_sig <= 5'd1;
					else
					begin
						address_sig <= address_sig + 1'b1;
					end
					status <= 1'b1;
					timeCnt  <= timeCnt + 1'b1;
					wren_sig <= 1'b0;
				end
				else
				begin
					status  <= 1'b0;
					timeCnt <= 4'd0;
					RESET   <= 1'b0;
					address_sig <= 5'd0;
				end
			end
			else if (!stopWatchStatus && isSW_CntPress)											//否则秒表复位
			begin
				RESET 		<= 1'b0;
				address_sig <= 5'd0;
				timeCnt 		<= 4'd0;
				status 		<= 1'b0;
				wren_sig	 	<= 1'bz;
			end
		end
		else 
		begin
			RESET <= 1'b0;
		end
		end
	end
	
	RAM	RAM_inst (
		.address ( address_sig ),
		.clock 	( clk ),
		.data 	( data_sig ),
		.wren 	( wren_sig ),
		.q 		( q_sig )
	);
	
	FreDiv uut4 (
		.clk		(clk),
		.RESET	(RESET),
		.clk5ms	(clk5ms)
	);
	
	minCounter uut2 (					//minute
		.rst_n		(RESET), 
		.clk			(EO_min && EO_sec), 
		.timeSetMode(!Enable),
		.minute_set1(Minute1),
		.minute_set0(Minute0),
		.minute1		(Minute1), 
		.minute0		(Minute0), 
		.EO			()
	);
	
	minCounter uut3 (					//second
		.rst_n		(RESET), 
		.clk			(EO_sec), 
		.timeSetMode(!Enable),
		.minute_set1(Second1),
		.minute_set0(Second0),
		.minute1		(Second1), 
		.minute0		(Second0), 
		.EO			(EO_min)
	);
	
	microSecCounter uut5 (			//micro_second
		.rst_n		(RESET), 
		.clk			(clk5ms), 
		.timeSetMode(!Enable),
		.minute_set1(MicroSecond1),
		.minute_set0(MicroSecond0),
		.minute1		(MicroSecond1), 
		.minute0		(MicroSecond0), 
		.EO			(EO_sec)
	);
	
endmodule

