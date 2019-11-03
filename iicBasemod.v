module iicBasemod(
	input CLOCK, RESET,		//时钟和复位信号
	input clk1hz,
	output SCL,					//时钟线
	inout SDA,					//信号线
	input SW_oData,
	input clockMode,
	input [63:0] iData,     //[47:24]是时间，[23:0]是日期，[63:48]是闹钟
	output reg [63:0] oData,    //输出数据
	output reg        rdDone
	);
    wire [7:0]DataU1;
	 wire DoneU1;

    iic_savemod U1
	 (
	     .CLOCK( CLOCK ),
		  .RESET( RESET ),
		  .SCL( SCL ),         // > top
		  .SDA( SDA ),         // <> top
		  .iCall( isCall ),    // < core
		  .oDone( DoneU1 ),    // > core
		  .iAddr( D1 ),        // < core   //读写地址
		  .iData( D2 ),        // < core   //写数据
		  .oData( DataU1 )     // > core	  //读数据
	 );
	 
	 parameter T400MS = 21'd50_0000;
	 //**************************增加按键消抖************************
	reg F4, F3;
	
	always @ (posedge CLOCK or negedge RESET)
	begin
		if (!RESET)
		begin 
			{F4, F3} <= 2'b11;
		end
		else
			{F4, F3} <= {F3, SW_oData};
	end
	
	wire isSW_oDataH2L = (F4 == 1 && F3 == 0);
	wire isSW_oDataL2H = (F4 == 0 && F3 == 1);
	
	reg [3:0] _i;
	reg isSW_oDataPress, isSW_oDataRelease;
	reg [18:0] C2;
	
	always @ ( posedge CLOCK or negedge RESET )
	begin 
		if (!RESET)
		begin 
			_i <= 4'd0;
			{isSW_oDataPress, isSW_oDataRelease} <= 1'b0;
			C2 <= 19'd0;
		end
		else 
		begin 
			case (_i)
				0:
				if (isSW_oDataH2L) _i <= _i + 1'b1;
				1:
				if (C2 == T400MS - 1) begin C2 <= 19'd0; _i <= _i + 1'b1; end
				else C2 <= C2 + 1'b1;
				2:
				begin isSW_oDataPress <= 1'b1; _i <= _i + 1'b1; end
				3:
				begin isSW_oDataPress <= 1'b0; _i <= _i + 1'b1; end
				4:
				if (isSW_oDataL2H) _i <= _i + 1'b1;
				5:
				if (C2 == T400MS - 1) begin C2 <= 19'd0; _i <= _i + 1'b1; end
				else C2 <= C2 + 1'b1;
				6:
				begin isSW_oDataRelease <= 1'b1; _i <= _i + 1'b1; end
				7:
				begin isSW_oDataRelease <= 1'b0; _i <= 4'd0; end
			endcase
		end
	end
	//*************************************************************
	reg wrStatus;
	reg rdFlag;
	 always @ (posedge CLOCK or negedge RESET)
	 begin
		if (!RESET)
		begin
			wrStatus <= 1'b0;        //上电后先从FLASH里面读
			rdFlag   <= 1'b0;
		end
		else
		begin
			if (isSW_oDataPress && clockMode)
			begin
				wrStatus <= 1'b1;
				rdFlag   <= 1'b0;
			end
			else
			if (iRead == 4'd8)       //读完后切换到写状态
			begin
				wrStatus <= 1'b0;
				rdFlag   <= 1'b1;
			end
		end
	 end
	
	reg F2, F1;
	
	always @ (posedge CLOCK or negedge RESET)
	begin
		if (!RESET)
		begin 
			{F2, F1} <= 2'b00;
		end
		else
			{F2, F1} <= {F1, clk1hz};
	end
	
	wire clk1hzL2H = (F2 == 0 && F1 == 1);
	
	reg [3:0] i, iRead;
	reg [7:0] D1; //地址
	reg [7:0] D2; //数据
	reg [1:0] isCall;
	
	  
    always @ ( posedge CLOCK or negedge RESET )	// core
	     if( !RESET )
		      begin
				    i <= 4'd0;
					 iRead <= 4'd0;
					 { D1,D2 } <= { 8'd0,8'd0 };
					 oData <= 64'd0;
					 isCall <= 2'b00;
					 rdDone <= 1'b0;
				end
		  else
			if (!wrStatus && rdFlag)
			begin
				rdDone <= 1'b0;
		      case( i )
				
				    0: //将8'hAB写入地址0
					 if( DoneU1 ) begin isCall <= 2'b00; i <= i + 1'b1; end
					 else begin isCall <= 2'b10; D1 <= 8'd0; D2 <= iData[63:56]; end
					 
					 1: //将8'hCD写入地址1
					 if( DoneU1 ) begin isCall <= 2'b00; i <= i + 1'b1; end
					 else begin isCall <= 2'b10; D1 <= 8'd1; D2 <= iData[55:48]; end
					 
					 2: //将8'hEF写入地址2
					 if( DoneU1 ) begin isCall <= 2'b00; i <= i + 1'b1; end
					 else begin isCall <= 2'b10; D1 <= 8'd2; D2 <= iData[47:40]; end
					 3:
					 if( DoneU1 ) begin isCall <= 2'b00; i <= i + 1'b1; end
					 else begin isCall <= 2'b10; D1 <= 8'd3; D2 <= iData[39:32]; end
					 4:
					 if( DoneU1 ) begin isCall <= 2'b00; i <= i + 1'b1; end
					 else begin isCall <= 2'b10; D1 <= 8'd4; D2 <= iData[31:24]; end
					 5:
					 if( DoneU1 ) begin isCall <= 2'b00; i <= i + 1'b1; end
					 else begin isCall <= 2'b10; D1 <= 8'd5; D2 <= iData[23:16]; end
					 6:
					 if( DoneU1 ) begin isCall <= 2'b00; i <= i + 1'b1; end
					 else begin isCall <= 2'b10; D1 <= 8'd6; D2 <= iData[15:8]; end
					 7:
					 if( DoneU1 ) begin isCall <= 2'b00; i <= i + 1'b1; end
					 else begin isCall <= 2'b10; D1 <= 8'd7; D2 <= iData[7:0]; end
					 8:
					 if (clk1hzL2H)
						i <= 4'd0;
					 else
						i <= i;
				endcase
			end
			else if (wrStatus)
				case (iRead)
					0:
					 if( DoneU1 ) begin oData[63:56] <= DataU1; isCall <= 2'b00; iRead <= iRead + 1'b1; end
					 else begin isCall <= 2'b01; D1 <= 8'd0; end
					 
					1:
                if( DoneU1 ) begin oData[55:48] <= DataU1; isCall <= 2'b00; iRead <= iRead + 1'b1; end
					 else begin isCall <= 2'b01; D1 <= 8'd1; end
					 
					2:
					 if( DoneU1 ) begin oData[47:40] <= DataU1; isCall <= 2'b00; iRead <= iRead + 1'b1; end
					 else begin isCall <= 2'b01; D1 <= 8'd2; end
					
					3:
					 if( DoneU1 ) begin oData[39:32] <= DataU1; isCall <= 2'b00; iRead <= iRead + 1'b1; end
					 else begin isCall <= 2'b01; D1 <= 8'd3; end
					 
					4:
                if( DoneU1 ) begin oData[31:24] <= DataU1; isCall <= 2'b00; iRead <= iRead + 1'b1; end
					 else begin isCall <= 2'b01; D1 <= 8'd4; end
					 
					5:
					 if( DoneU1 ) begin oData[23:16] <= DataU1; isCall <= 2'b00; iRead <= iRead + 1'b1; end
					 else begin isCall <= 2'b01; D1 <= 8'd5; end
					6:
					 if( DoneU1 ) begin oData[15:8] <= DataU1; isCall <= 2'b00; iRead <= iRead + 1'b1; end
					 else begin isCall <= 2'b01; D1 <= 8'd6; end
					7:
					 if( DoneU1 ) begin oData[7:0] <= DataU1; isCall <= 2'b00; iRead <= iRead + 1'b1; end
					 else begin isCall <= 2'b01; D1 <= 8'd7; end
					8:
					begin
						iRead <= 4'd0;
						rdDone <= 1'b1;
					end
				endcase
					
					
				
endmodule

