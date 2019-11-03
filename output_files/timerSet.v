module timeSet(
	input clk,
	input SW_Sel,										//按键选择设置位
	input SW_Add,										//时间增加键
	input timeSetMode,
	input rst_n,	
	input   [3:0] hour1,hour0,			
	input   [3:0] minute1,minute0,				//当前时间   
	output reg [2:0] timeSetSel,					//设置位信号
	output reg [3:0] hour_set1,hour_set0,
	output reg [3:0] minute_set1,minute_set0 	//设置后的时间
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
	always @ (posedge clk or negedge rst_n)
	begin 
		if (!rst_n)
		begin 
			timeSetSel <= 3'd0;
		end
		else 
		begin
			if (isSW_SelPress && timeSetMode)
			begin 
				if (timeSetSel == 3'd5)
					timeSetSel <= 3'd0;
				else 
					timeSetSel <= timeSetSel + 1'b1;
			end
		end
	end
	
	always @ (posedge clk or negedge rst_n)
	begin 
		if (!rst_n)
		begin 
			hour_set1 <= hour1;
			hour_set0 <= hour0;
			minute_set1 <= minute1;
			minute_set0 <= minute0;
		end
		else 
		begin 
			if (isSW_AddPress && timeSetMode)
			begin 
				case (timeSetSel)
					3'd0:
					begin 
						if (hour_set1 < 4'd2)
							hour_set1 <= hour_set1 + 1'b1;
						else 
							hour_set1 <= 4'd0;
					end
					3'd1:
					begin 
						if (hour_set0 < 4'd3 && hour_set1 == 4'd2)
							hour_set0 <= hour_set0 + 1'b1;
						else if (hour_set0 < 4'd9 && hour_set1 < 4'd2)
							hour_set0 <= hour_set0 + 1'b1;
						else
							hour_set0 <= 4'd0;
					end
					3'd2:
					begin 
						if (minute_set1 < 4'd5)
							minute_set1 <= minute_set1 + 1'b1;
						else 
							minute_set1 <= 4'd0;
					end
					3'd3:
					begin 
						if (minute_set0 < 4'd9)
							minute_set0 <= minute_set0 + 1'b1;
						else
							minute_set0 <= 4'd0;
					end
					3'd4:
					begin 
					
					end
					3'd5:
					begin 
					
					end
				endcase
			end
			else
			begin 
				hour_set1 <= hour1;
				hour_set0 <= hour0;
				minute_set1 <= minute1;
				minute_set0 <= minute0;
			end
		end
	end

endmodule