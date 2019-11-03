`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:        
// Engineer:       
// 
// Create Date:    23:10:39 10/7/2019
// Design Name: 
// Module Name:    DigitalClock 
// Project Name:   DigitalClock
// Target Devices:  
// Tool versions:  Quartus II 13.0
// Description:    数字钟顶层模块
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments:
//////////////////////////////////////////////////////////////////////////////////
module DigitalClock(
	input 		 clk,//时钟信号
	input 		 RESET,//复位信号
	input 		 SW_Sel,//位选信号
	input 		 SW_Add,//增加信号
	input 		 SW_Mode,				  //0-计数模式，1-时间设置模式，2-闹钟模式，4-秒表模式
	output [7:0] DIG,//数码管显示
	output [5:0] SEL,//位选闪烁
	output       SCL,
	inout        SDA,
	output reg [2:0] LED_workModDisplay,  //LED
	output 		 Buzzer					  //闹钟和整点报时共用一个LED显示
   );

	wire 	   EO_min;					//分钟进位信号
	wire	   EO_sec;					//秒进位
	wire 	   clk1hz;              //分频出来的频率
	wire [3:0] hour_data1, hour_data0, minute_data1, minute_data0, second_data1, second_data0;
	
	
	//模式选择
	reg 	   _ClockMode;		    	//时钟模式
	reg 	   _timeSetMode;			//时间设置模式
	reg 	   _dateDisplayMode;		//日期显示模式
	reg        _dateSetMod;				//日期设置
	reg        _alarmClockMod;			//闹钟
	reg        _stopWatchMode;			//秒表
	reg        _timerMode;           	//定时器
	
	FreDiv uut4 (        //分频           
		.clk	(clk),
		.RESET	(RESET),
		.clk1hz	(clk1hz)
	);
	
	hourCounter utt1 (					//hour
		.rst_n		(RESET), 
		.clk		(EO_min && EO_sec), //分钟与秒钟进位信号都为1时
		.rdDone		(rdDone),
		.timeSetMode(_timeSetMode),
		.hour_set1	(hour_set1),
		.hour_set0	(hour_set0),
		.hour_init1	(oData[47:44]),
		.hour_init0	(oData[43:40]),
		.hour1		(hour_data1), 
		.hour0		(hour_data0),
	);
	
	minCounter uut2 (					//minute
		.rst_n		(RESET), 
		.clk	    (EO_sec), 
		.rdDone		(rdDone),
		.timeSetMode(_timeSetMode),
		.minute_set1(minute_set1),
		.minute_set0(minute_set0),
		.minute_init1(oData[39:36]),
		.minute_init0(oData[35:32]),
		.minute1	(minute_data1), 
		.minute0	(minute_data0), 
		.EO			(EO_min)
	);
	
	minCounter uut3 (					//second
		.rst_n(RESET), 
		.clk(clk1hz), 
		.rdDone(rdDone),
		.timeSetMode(1'b0),
		.minute_set1(4'd0),
		.minute_set0(4'd0),
		.minute_init1(oData[31:28]),
		.minute_init0(oData[27:24]),
		.minute1(second_data1), 
		.minute0(second_data0), 
		.EO(EO_sec)
	);
	
	/*smg_basemod uut5 (
		.CLOCK(clk),
		.RESET(RESET),
		.iData(24'h123456),//{hour_data1, hour_data0, minute_data1, minute_data0, second_data1, second_data0}
		.DIG(DIG),
		.SEL(SEL)
	);*/
	//数码管显示模块
	//****************************************************
	reg  [02:0] SetSel;
	reg  [23:0] timeClock;
	wire [09:0] DataU1;
	wire [03:0] hour_set1, hour_set0, minute_set1, minute_set0;
	wire [02:0] timeSetSel, dateSetSel, alarmSetSel, timerSel;
	
	//assign timeClock = {hour_data1, hour_data0, minute_data1, minute_data0, second_data1, second_data0};
	//assign timeClock = {hour_set1, hour_set0, minute_set1, minute_set0, second_data1, second_data0};_dateDisplayMode ? {year1, year0, month1, month0, day1, day0} : 
	
	//*****************不同模式下的位选控制*********************************
	always @ (posedge clk or negedge RESET)
	begin
		if (!RESET)
			SetSel <= 3'd0;
		else
		begin
			if (_timeSetMode)	SetSel <= timeSetSel;
			else if (_dateSetMod) SetSel <= dateSetSel;
			else if (_alarmClockMod) SetSel <= alarmSetSel;
			else if (_timerMode) SetSel <= timerSel;
		end
	end
	
	//***************不同模式下的显示数据控制*********************************
	always @ (posedge clk or negedge RESET)
	begin 
		if (!RESET)//初始化为时钟显示模式
		begin
			timeClock <= {hour_data1, hour_data0, minute_data1, minute_data0, second_data1, second_data0};
		end
		else
		begin
			if (_ClockMode)//如果是时钟模式
			begin
				timeClock <= {hour_data1, hour_data0, minute_data1, minute_data0, second_data1, second_data0};
			end
			else if (_timeSetMode)//如果是时钟设置模式
				timeClock <= {hour_data1, hour_data0, minute_data1, minute_data0, second_data1, second_data0};
			else if (_dateDisplayMode || _dateSetMod)//如果是日期或者日期设置模式
				timeClock <= {year1, year0, month1, month0, day1, day0};
			else if (_alarmClockMod)
				timeClock <= {4'd0, 4'd0, alarmHour1, alarmHour0, alarmMinute1, alarmMinute0};
			else if (_stopWatchMode)
				timeClock <= {stopWatchMinute1, stopWatchMinute0, stopWatchSecond1, stopWatchSecond0, stopWatchMicroSecond1, stopWatchMicroSecond0};
			else if (_timerMode)
				timeClock <= {timerHour1, timerHour0, timerMinute1, timerMinute0, timerSecond1, timerSecond0};
		end
	end	
	//*****************数码管显示**********************************
	smg_funcmod U1
	(
		.CLOCK			( clk ),//时钟信号
		.RESET			( RESET ),//复位端
		.timeSetMode	(_timeSetMode),//时间设置模式
		.dateSetMode	(_dateSetMod),//日期设置模式
		.alarmClockMode(_alarmClockMod),//闹钟模式
		.timerMode     (_timerMode),//时间显示模式
		.iData			( timeClock ), 		// < top
		.timeSetSel		(SetSel),//位选端
		.oData			( DataU1 )        	// > U2
	);
	
	smg_encode_immdmod U2
	(
		.iData( DataU1[9:6] ),  // < U1
		.oData( DIG )           // > top
	);
	 
	assign SEL = DataU1[5:0];
	//**************************************************************
	
	//********************时间设置模块********************************
	timeSet uut6 (
		.clk(clk),
		.SW_Sel(SW_Sel),
		.SW_Add(SW_Add),
		.timeSetMode(_timeSetMode),
		.rst_n(RESET),
		.hour1(hour_data1),
		.hour0(hour_data0),
		.minute1(minute_data1),
		.minute0(minute_data0),
		.timeSetSel(timeSetSel),
		.hour_set1(hour_set1),
		.hour_set0(hour_set0),
		.minute_set1(minute_set1),
		.minute_set0(minute_set0)
	);
	//****************************************************
	
	//********************模式选择按键消抖******************
	parameter T400MS = 21'd50_0000;
	reg F2, F1;
	
	always @ (posedge clk or negedge RESET)
	begin
		if (!RESET)
		begin 
			{F2, F1} <= 2'b11;
		end
		else
			{F2, F1} <= {F1, SW_Mode};
	end
	
	wire isSW_ModeH2L = (F2 == 1 && F1 == 0);
	wire isSW_ModeL2H = (F2 == 0 && F1 == 1);
	
	reg [3:0] i;
	reg isSW_ModePress, isSW_ModeRelease;
	reg [18:0] C1;
	
	always @ ( posedge clk or negedge RESET )
	begin 
		if (!RESET)
		begin 
			i <= 4'd0;
			{isSW_ModePress, isSW_ModeRelease} <= 2'b00;
			C1 <= 19'd0;
		end
		else 
		begin 
			case (i)
				0:
				if (isSW_ModeH2L) i <= i + 1'b1;
				1:
				if (C1 == T400MS - 1) begin C1 <= 19'd0; i <= i + 1'b1; end
				else C1 <= C1 + 1'b1;
				2:
				begin isSW_ModePress <= 1'b1; i <= i + 1'b1; end
				3:
				begin isSW_ModePress <= 1'b0; i <= i + 1'b1; end
				4:
				begin if (isSW_ModeL2H) i <= i + 1'b1; end
				5:
				if (C1 == T400MS - 1) begin C1 <= 19'd0; i <= i + 1'b1; end
				else C1 <= C1 + 1'b1;
				6:
				begin isSW_ModeRelease <= 1'b1; i <= i + 1'b1; end
				7:
				begin isSW_ModeRelease <= 1'b0; i <= 4'd0; end
			endcase
		end
	end
	//*********************************************************************
	
	//************************************按键选择工作模式*******************
	reg [2:0] clockMode;
	always @ (posedge clk or negedge RESET)
	begin
		if (!RESET)
		begin
			clockMode <= 3'd0;
		end
		else
		begin
			if (isSW_ModePress)
			begin
				if (clockMode == 3'd6)
					clockMode <= 3'd0;
				else
					clockMode <= clockMode + 1'b1;
			end
		end
	end
	
	
	always @ (posedge clk or negedge RESET)
	begin 
		if (!RESET)
		begin 
			_timeSetMode <= 1'b0;
			_ClockMode   <= 1'b0;
			_dateDisplayMode <= 1'b0;
			_dateSetMod      <= 1'b0;
			_alarmClockMod   <= 1'b0;
			_stopWatchMode   <= 1'b0;
			_timerMode       <= 1'b0;
		end
		else
		begin 
			case (clockMode)
				0://时钟模式
				begin 
					_ClockMode <= 1'b1;
					_timeSetMode <= 1'b0;
					_dateDisplayMode <= 1'b0;
					_dateSetMod      <= 1'b0;
					_alarmClockMod   <= 1'b0;
					_stopWatchMode   <= 1'b0;
					_timerMode       <= 1'b0;
				end
				1://时间设置模式
				begin 
					_ClockMode <= 1'b0;
					_timeSetMode <= 1'b1;
					_dateDisplayMode <= 1'b0;
					_dateSetMod      <= 1'b0;
					_alarmClockMod   <= 1'b0;
					_stopWatchMode   <= 1'b0;
					_timerMode       <= 1'b0;
				end
				2:
				begin
					_ClockMode <= 1'b0;
					_timeSetMode <= 1'b0;
					_dateDisplayMode <= 1'b1;
					_dateSetMod      <= 1'b0;
					_alarmClockMod   <= 1'b0;
					_stopWatchMode   <= 1'b0;
					_timerMode       <= 1'b0;
				end
				3:
				begin
					_ClockMode <= 1'b0;
					_timeSetMode <= 1'b0;
					_dateDisplayMode <= 1'b0;
					_dateSetMod      <= 1'b1;
					_alarmClockMod   <= 1'b0;
					_stopWatchMode   <= 1'b0;
					_timerMode       <= 1'b0;
				end
				4:
				begin
					_ClockMode <= 1'b0;
					_timeSetMode <= 1'b0;
					_dateDisplayMode <= 1'b0;
					_dateSetMod      <= 1'b0;
					_alarmClockMod   <= 1'b1;
					_stopWatchMode   <= 1'b0;
					_timerMode       <= 1'b0;
				end
				5:
				begin
					_ClockMode <= 1'b0;
					_timeSetMode <= 1'b0;
					_dateDisplayMode <= 1'b0;
					_dateSetMod      <= 1'b0;
					_alarmClockMod   <= 1'b0;
					_stopWatchMode   <= 1'b1;
					_timerMode       <= 1'b0;
				end
				6:
				begin
					_ClockMode <= 1'b0;
					_timeSetMode <= 1'b0;
					_dateDisplayMode <= 1'b0;
					_dateSetMod      <= 1'b0;
					_alarmClockMod   <= 1'b0;
					_stopWatchMode   <= 1'b0;
					_timerMode       <= 1'b1;
				end
			endcase
		end
	end 

	always @ (posedge clk or negedge RESET)
	begin
		if (!RESET)
		begin
			LED_workModDisplay <= 3'd0;
		end
		else 
		begin
			if (_ClockMode) LED_workModDisplay <= 3'd0;
			else if (_timeSetMode) LED_workModDisplay <= 3'd1;
			else if (_dateDisplayMode) LED_workModDisplay <= 3'd2;
			else if (_dateSetMod) LED_workModDisplay <= 3'd3;
			else if (_alarmClockMod) LED_workModDisplay <= 3'd4;
			else if (_stopWatchMode) LED_workModDisplay <= 3'd5;
			else if (_timerMode) LED_workModDisplay <= 3'd6;
		end
	end
	//***********************************************************

	//***************************整点报时*************************
	wire alarm_radio;
	oclockPlay uut7 (
		.clk(clk),
		.rst_n(RESET),
		.alarm_radio(alarm_radio),	//输出		
		.minute1(minute_data1),
		.minute0(minute_data0),		
		.second1(second_data1),
		.second0(second_data0)
	);
	assign Buzzer = alarm_radio | (alarm && alarmFlag);
	//***********************************************************
	
	//**************************日期显示模式**********************
	wire [3:0] year3, year2, year1, year0;
	wire [3:0] month1, month0;
	wire [3:0] day1, day0;
	dateDisplay utt8 (
		.clk		({hour_data1, hour_data0, minute_data1, minute_data0, second_data1, second_data0} == 24'h235959 ? 1 : 0),
		.rst_n		(RESET),
		.dateSetMod (_dateSetMod),
		.timeSetMod (_timeSetMode),
		//.dateDisplayMod(_dateDisplayMode)
		.hour1		(hour_data1), 
		.hour0		(hour_data0),
		.minute1	(minute_data1), 
		.minute0	(minute_data0),
		.second1	(second_data1), 
		.second0	(second_data0),
		.year_set3	(year_set3),
		.year_set2	(year_set2),
		.year_set1	(year_set1),
		.year_set0	(year_set0),
		.month_set1	(month_set1),
		.month_set0	(month_set0),
		.day_set1	(day_set1),
		.day_set0   (day_set0),
		.year3		(year3), 
		.year2		(year2), 
		.year1		(year1), 
		.year0		(year0),
		.rdDone     (rdDone),
		.datePast   (oData[23:0]),
		.month1		(month1), 
		.month0		(month0),
		.day1		(day1), 
		.day0		(day0)
	);
	//***********************************************************
	
	//********************************日期设置********************
	
	wire [3:0] year_set3, year_set2, year_set1, year_set0;
	wire [3:0] month_set1, month_set0;
	wire [3:0] day_set1, day_set0;
	
	dateSet utt9 (
		.clk		(clk),
		.rst_n		(RESET),
		.dateSetMod	(_dateSetMod),
		.SW_Sel		(SW_Sel),		
		.SW_Add		(SW_Add),	
		.year3		(year3), 
		.year2		(year2), 
		.year1		(year1), 
		.year0		(year0),
		.month1		(month1), 
		.month0		(month0),
		.day1		(day1), 
		.day0		(day0),
		.year_set3	(year_set3), 
		.year_set2	(year_set2), 
		.year_set1	(year_set1), 
		.year_set0	(year_set0),
		.month_set1	(month_set1), 
		.month_set0	(month_set0),
		.day_set1	(day_set1), 
		.day_set0	(day_set0),
		.dateSetSel	(dateSetSel)
	);
	//***********************************************************
	
	//************************止闹按键***************************
	reg F4, F3;
	
	always @ (posedge clk or negedge RESET)
	begin
		if (!RESET)
		begin 
			{F4, F3} <= 2'b11;
		end
		else
			{F4, F3} <= {F3, SW_Sel};
	end
	
	wire isSW_SelH2L = (F4 == 1 && F3 == 0);
	wire isSW_SelL2H = (F4 == 0 && F3 == 1);
	
	reg [3:0] _i;
	reg isSW_SelPress, isSW_SelRelease;
	reg [18:0] C2;
	
	always @ ( posedge clk or negedge RESET )
	begin 
		if (!RESET)
		begin 
			_i <= 4'd0;
			{isSW_SelPress, isSW_SelRelease} <= 2'b00;
			C2 <= 19'd0;
		end
		else 
		begin 
			case (_i)
				0:
				if (isSW_SelH2L) _i <= _i + 1'b1;
				1:
				if (C2 == T400MS - 1) begin C2 <= 19'd0; _i <= _i + 1'b1; end
				else C2 <= C2 + 1'b1;
				2:
				begin isSW_SelPress <= 1'b1; _i <= _i + 1'b1; end
				3:
				begin isSW_SelPress <= 1'b0; _i <= _i + 1'b1; end
				4:
				begin if (isSW_SelL2H) _i <= _i + 1'b1; end
				5:
				if (C2 == T400MS - 1) begin C2 <= 19'd0; _i <= _i + 1'b1; end
				else C2 <= C2 + 1'b1;
				6:
				begin isSW_SelRelease <= 1'b1; _i <= _i + 1'b1; end
				7:
				begin isSW_SelRelease <= 1'b0; _i <= 4'd0; end
			endcase
		end
	end
	
	reg alarmFlag; //辅助控制闹钟信号
	always @ (posedge clk or negedge RESET)
	begin
		if (!RESET)
		begin
			alarmFlag <= 1'b1;
		end
		else
		begin
			if (isSW_SelPress && _ClockMode && alarm && alarmFlag)
			begin
				alarmFlag <= 1'b1;
			end
			else if (isSW_SelPress && _ClockMode && alarm && !alarmFlag)
				alarmFlag <= 1'b0;
		end
	end
	//***********************************************************
	
	//****************************闹钟***************************
	wire       alarm;	//提示信号和整点报时共用LED
	wire [3:0] alarmHour1, alarmHour0, alarmMinute1, alarmMinute0;
	alarmClock uut10 (
		.clk			(clk),
		.rst_n			(RESET),
		.alarmClockMod	(_alarmClockMod),
		.alarmSetSel	(alarmSetSel),
		.SW_Sel			(SW_Sel),
		.SW_Add			(SW_Add),
		.rdDone       	(rdDone),
		.hour1			(hour_data1),
		.hour0			(hour_data0),
		.minute1		(minute_data1),
		.minute0		(minute_data0),
		.hour_set1		(alarmHour1),
		.hour_set0		(alarmHour0),		
		.minute_set1	(alarmMinute1),
		.minute_set0	(alarmMinute0),
		.alarmPast    	(oData[63:48]),
		.alarm			(alarm)			
	);		
	//***********************************************************
	
	//********************************秒表模块********************
	
	wire [3:0] stopWatchMinute1, stopWatchMinute0;
	wire [3:0] stopWatchSecond1, stopWatchSecond0;
	wire [3:0] stopWatchMicroSecond1, stopWatchMicroSecond0;
	stopWatch uut11 (
		.clk						(clk),
		.rst_n						(RESET),
		.stopWatchMode				(_stopWatchMode),
		.SW_Start					(SW_Add),
		.SW_Cnt						(SW_Sel),
		.stopWatchMinute1			(stopWatchMinute1), 
		.stopWatchMinute0			(stopWatchMinute0),
		.stopWatchSecond1			(stopWatchSecond1), 
		.stopWatchSecond0			(stopWatchSecond0),
		.stopWatchMicroSecond1	(stopWatchMicroSecond1), 
		.stopWatchMicroSecond0	(stopWatchMicroSecond0)
	);
	//***********************************************************
	
	//**************************断电时间/日期保持******************
	wire [63:0]  oData;
	wire         rdDone;
	iicBasemod uut12 (
		.CLOCK		(clk),
		.clk1hz		(clk1hz),
		.RESET		(RESET),
		.clockMode	(_ClockMode),
		.SCL		(SCL),
		.SDA		(SDA),
		.SW_oData	(SW_Add),
		.rdDone		(rdDone),
		.iData		({alarmHour1, alarmHour0, alarmMinute1, alarmMinute0, hour_data1, hour_data0, minute_data1, minute_data0, second_data1, second_data0, year1, year0, month1, month0, day1, day0}),
		.oData		(oData)
	);
	
	 //***********************************************************
	//*************************定时器模块*************************
	wire [3:0] timerHour1, timerHour0;
	wire [3:0] timerMinute1, timerMinute0;
	wire [3:0] timerSecond1, timerSecond0;
	
	timerMod uut13 (
		.clk(clk),
		.CLOCK(clk1hz),
		.SW_Sel(SW_Sel),											
		.SW_Add(SW_Add),	
		.timerMode(_timerMode),
		.rst_n(RESET),	  
		.timerSel(timerSel),					//设置位信号
		.hour_set1(timerHour1),
		.hour_set0(timerHour0),
		.minute_set1(timerMinute1),
		.minute_set0(timerMinute0), 	//设置后的时间
		.second_set1(timerSecond1), 
		.second_set0(timerSecond0)
	);
	//***********************************************************
endmodule
