module dateSet(
		input clk,
		input rst_n,
		input dateSetMod,
		input SW_Sel,			//位选
		input SW_Add,			//增加
		input [3:0] year3, year2, year1, year0,
		input [3:0] month1, month0,
		input [3:0] day1, day0,
		output reg [3:0] year_set3, year_set2, year_set1, year_set0,
		output reg [3:0] month_set1, month_set0,
		output reg [3:0] day_set1, day_set0,
		output reg [2:0] dateSetSel
	);
	
	parameter T400MS = 21'd50_0000;
	
	//**************************位选按键消抖*********************
	reg F2, F1;
	
	always @ (posedge clk or negedge rst_n)
	begin
		if (!rst_n)
		begin 
			{F2, F1} <= 2'b11;
		end
		else
			{F2, F1} <= {F1, SW_Sel};
	end
	
	wire isSW_SelH2L = (F2 == 1 && F1 == 0);
	wire isSW_SelL2H = (F2 == 0 && F1 == 1);
	
	reg [3:0] i;
	reg isSW_SelPress, isSW_SelRelease;
	reg [18:0] C1;
	
	always @ ( posedge clk or negedge rst_n )
	begin 
		if (!rst_n)
		begin 
			i <= 4'd0;
			{isSW_SelPress, isSW_SelRelease} <= 2'b00;
			C1 <= 19'd0;
		end
		else 
		begin 
			case (i)
				0:
				if (isSW_SelH2L) i <= i + 1'b1;
				1:
				if (C1 == T400MS - 1) begin C1 <= 19'd0; i <= i + 1'b1; end
				else C1 <= C1 + 1'b1;
				2:
				begin isSW_SelPress <= 1'b1; i <= i + 1'b1; end
				3:
				begin isSW_SelPress <= 1'b0; i <= i + 1'b1; end
				4:
				begin if (isSW_SelL2H) i <= i + 1'b1; end
				5:
				if (C1 == T400MS - 1) begin C1 <= 19'd0; i <= i + 1'b1; end
				else C1 <= C1 + 1'b1;
				6:
				begin isSW_SelRelease <= 1'b1; i <= i + 1'b1; end
				7:
				begin isSW_SelRelease <= 1'b0; i <= 4'd0; end
			endcase
		end
	end
	//*************************************************************
	//**************************增加按键消抖************************
	reg F4, F3;
	
	always @ (posedge clk or negedge rst_n)
	begin
		if (!rst_n)
		begin 
			{F4, F3} <= 2'b11;
		end
		else
			{F4, F3} <= {F3, SW_Add};
	end
	
	wire isSW_AddH2L = (F4 == 1 && F3 == 0);
	wire isSW_AddL2H = (F4 == 0 && F3 == 1);
	
	reg [3:0] _i;
	reg isSW_AddPress, isSW_AddRelease;
	reg [18:0] C2;
	
	always @ ( posedge clk or negedge rst_n )
	begin 
		if (!rst_n)
		begin 
			_i <= 4'd0;
			{isSW_AddPress, isSW_AddRelease} <= 1'b0;
			C2 <= 19'd0;
		end
		else 
		begin 
			case (_i)
				0:
				if (isSW_AddH2L) _i <= _i + 1'b1;
				1:
				if (C2 == T400MS - 1) begin C2 <= 19'd0; _i <= _i + 1'b1; end
				else C2 <= C2 + 1'b1;
				2:
				begin isSW_AddPress <= 1'b1; _i <= _i + 1'b1; end
				3:
				begin isSW_AddPress <= 1'b0; _i <= _i + 1'b1; end
				4:
				if (isSW_AddL2H) _i <= _i + 1'b1;
				5:
				if (C2 == T400MS - 1) begin C2 <= 19'd0; _i <= _i + 1'b1; end
				else C2 <= C2 + 1'b1;
				6:
				begin isSW_AddRelease <= 1'b1; _i <= _i + 1'b1; end
				7:
				begin isSW_AddRelease <= 1'b0; _i <= 4'd0; end
			endcase
		end
	end
	//*************************************************************
	
	//****************************位选控制**************************
	always @ (negedge clk or negedge rst_n)
	begin 
		if (!rst_n)
		begin 
			dateSetSel <= 3'd0;
		end
		else 
		begin
			if (isSW_SelPress && dateSetMod)
			begin 
				if (dateSetSel == 3'd5)
					dateSetSel <= 3'd0;
				else 
					dateSetSel <= dateSetSel + 1'b1;
			end
		end
	end
	//**************************************************************
	
	always @ (negedge clk or negedge rst_n)
	begin 
		if (!rst_n)
		begin 
			{year_set3, year_set2, year_set1, year_set0} <= {year3, year2, year1, year0};
			{month_set1, month_set0}                     <= {month1, month0};
			{day_set1, day_set0}								   <= {day1, day0};
		end
		else 
		begin 
			if (isSW_AddPress && dateSetMod)			//增加按键按下且日期设置模式打开
			begin 
				case (dateSetSel)
					3'd0:
					begin
						if (year_set1 < 4'd9)
							year_set1 <= year_set1 + 1'b1;
						else
						begin
							year_set1 <= 4'd0;
						end
					end
					3'd1:
					begin
						if (year_set0 < 4'd9)
							year_set0 <= year_set0 + 1'b1;
						else
							year_set0 <= 4'd0;
					end
					3'd2:
					begin
						if (month_set1 < 4'd1)
							month_set1 <= month_set1 + 1'b1;
						else
							month_set1 <= 4'd0;
					end
					3'd3:
					begin
						if (month_set0 < 4'd9 && month_set1 == 4'd0)
							month_set0 <= month_set0 + 1'b1;
						else if (month_set0 < 4'd2 && month_set1 == 4'd1)
							month_set0 <= month_set0 + 1'b1;
						else
						begin
							if (month_set1 == 4'd0)
								month_set0 <= 4'd1;
							else
								month_set0 <= 4'd0;
						end
					end
					3'd4:
					begin
					end
					3'd5:
					begin
						day_set0 <= day_set0 + 1'b1;
						if (day_set0 == 4'd9)
						begin
							day_set0 <= 4'd0;
							day_set1 <= day_set1 + 4'd1;
						end
						if ({day_set1, day_set0} == DAYS)
						begin
							day_set0 <= 4'd1;
							day_set1 <= 4'd0;
						end
					end
				endcase
			end
			else
			begin 
				{year_set3, year_set2, year_set1, year_set0} <= {year3, year2, year1, year0};
				{month_set1, month_set0}                     <= {month1, month0};
				{day_set1, day_set0}								   <= {day1, day0};
			end
		end
	end
	
	reg [7:0] DAYS;
	
	always		//判断月份天数
	begin 
		case ({month_set1, month_set0})
			8'h01: DAYS <= 8'h31;
			8'h02: 
			begin
				if ((({year_set3*1000 + year_set2*100 + year_set1*10 + year_set0}%4 == 0) && ({year_set3*1000 + year_set2*100 + year_set1*10 + year_set0}%100 != 0)) || ({year_set3*1000 + year_set2*100 + year_set1*10 + year_set0}%400 == 0))
					DAYS <= 8'h29;
				else
					DAYS <= 8'h21;
			end
			8'h03: DAYS <= 8'h31;
			8'h04: DAYS <= 8'h30;
			8'h05: DAYS <= 8'h31;
			8'h06: DAYS <= 8'h30;
			8'h07: DAYS <= 8'h31;
			8'h08: DAYS <= 8'h31;
			8'h09: DAYS <= 8'h30;
			8'h10: DAYS <= 8'h31;
			8'h11: DAYS <= 8'h30;
			8'h12: DAYS <= 8'h31;
			default: DAYS <= 8'h30;
		endcase
	end

endmodule
