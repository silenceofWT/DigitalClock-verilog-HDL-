module dateDisplay(
	input 				clk,//时钟信号
	input 				rst_n,//复位信号
	//input dateDisplayMod,
	input 				dateSetMod, 
	input             timeSetMod,
	input  		[3:0] hour1, hour0,
	input  		[3:0] minute1, minute0,
	input  		[3:0] second1, second0,
	input  		[3:0] year_set3, year_set2, year_set1, year_set0,
	input  		[3:0] month_set1, month_set0,
	input  		[3:0] day_set1, day_set0,
	input       [23:0] datePast,
	input              rdDone,
	output reg 	[3:0] year3, year2, year1, year0,
	output reg 	[3:0] month1, month0,
	output reg 	[3:0] day1, day0
	);

	reg [7:0] DAYS;
	reg       dayCarry, monthCarry;
	
	initial
	begin
		{year3, year2, year1, year0} <= 16'h2019; //年份初始化为2019年1月1日
		{day1, day0}                 <= 8'h01;
		{month1, month0}             <= 8'h01;
	end
	
	always @ (posedge clk or negedge rst_n or posedge dateSetMod or posedge rdDone)
	begin 
		if (!rst_n)
		begin 
			{day1, day0} <= 8'h01;
		end
		else 
		begin 
			if (rdDone)
				{day1, day0} <= datePast[7:0];
			else if (dateSetMod)
			begin
				{day1, day0} <= {day_set1, day_set0};
			end
			else if (!timeSetMod)
			begin
				if ({hour1, hour0, minute1, minute0, second1, second0} == 24'h235959)
				begin 
					if (day0 == 4'd9)
					begin 
						if (day1 == 4'd0)
						begin
							day0 <= 4'd1;
							day1 <= day1 + 1'b1;
						end
						else
						begin
							day0 <= 4'd0;
							day1 <= day1 + 1'b1;
						end
					end
					else
					begin
						day0 <= day0 + 1'b1;
					end
					if ({day1, day0} == DAYS)
					begin 
						dayCarry <= 1'b1;
						{day1, day0} <= 8'h01;
					end
					else
						dayCarry <= 1'b0;
				end
			end
		end
	end
	
	always @ (posedge dayCarry or negedge rst_n or posedge dateSetMod or posedge rdDone)
	begin 
		if (!rst_n)
		begin 
			month1 <= 4'd0;
			month0 <= 4'd1;
		end
		else
		begin 
			if (rdDone)
				{month1, month0} <= datePast[15:8];
			else if (dateSetMod)
			begin
				{month1, month0} <= {month_set1, month_set0};
			end
			else
			begin
				if (month1 == 4'd0 && month0 < 4'd9)
					month0 <= month0 + 1'b1;
				else if (month1 == 4'd1 && month0 < 4'd2)
					month0 <= month0 + 1'b1;
				else
				begin
					if (month1 == 4'd1)
						month0 <= 4'd1;
					else
						month0 <= 4'd0;
					if (month1 == 4'd1 && month0 == 4'd2)
					begin 
						month1 <= 4'd0;
						monthCarry <= 1'b1;
					end
					else
					begin
						month1 <= month1 + 1'b1;
						monthCarry <= 1'b0;
					end
				end
			end
		end
	end
		
	wire yearCarry;
	assign yearCarry = ({monthCarry, dayCarry} == 2'b11 ? 1 : 0);
	always @ (posedge yearCarry or negedge rst_n or posedge dateSetMod or posedge rdDone)
	begin
		if (!rst_n)
			{year3, year2, year1, year0} <= 16'h2016;
		else
		begin
			if (rdDone)
				{year1, year0} <= datePast[23:16];
			else if (dateSetMod)
			begin
				{year3, year2, year1, year0} <= {year_set3, year_set2, year_set1, year_set0};
			end
			else
			begin
				if (year0 < 4'd9)
					year0 <= year0 + 1'b1;
				else
				begin
					year0 <= 4'd0;
					if (year1 < 4'd9)
						year1 <= year1 + 1'b1;
					else
						year1 <= 4'd0;
				end
			end
		end
	end
	always		//判断月份天数
	begin 
		case ({month1, month0})
			8'h01: DAYS <= 8'h31;
			8'h02: 
			begin
				if (({year3*1000 + year2*100 + year1*10 + year0} % 4 == 0) && ({year3*1000 + year2*100 + year1*10 + year0} % 100 != 0) || ({year3*1000 + year2*100 + year1*10 + year0} % 400 == 0))
					DAYS <= 8'h29;
				else
					DAYS <= 8'h28;
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
