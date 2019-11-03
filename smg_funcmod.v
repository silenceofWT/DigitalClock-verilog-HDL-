`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    13:24:08 10/7/2019
// Design Name: 
// Module Name:    smg_funcmod 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module smg_funcmod
(
    input CLOCK, RESET,
	 input timeSetMode,
	 input dateSetMode,
	 input alarmClockMode,
	 input timerMode,
	 input [23:0]iData,
	 input [2:0] timeSetSel,
	 output [9:0]oData
);
	 parameter T100US = 13'd5000;
	 
	 
	 reg [3:0]i;
	 reg [26:0]C1;
	 reg [3:0]D1;
	 reg [5:0]D2;
	 integer flag, flag1, flag2, flag3, flag4, flag5;
	 
	 always @ ( posedge CLOCK or negedge RESET )
	     if( !RESET )
		      begin
		          i <= 4'd0;
					 C1 <= 26'd0;
			    	 D1 <= 4'd0;
					 D2 <= 6'b111_110;
					 flag <= 0;
					 flag1 <= 0;
					 flag2 <= 0;
					 flag3 <= 0;
					 flag4 <= 0;
					 flag5 <= 0;
				end
		  else 
		      case( i )
				
				    0:
					 if( C1 == T100US -1 ) begin C1 <= 26'd0; i <= i + 1'b1; if (timeSetSel == 3'd0 && (timeSetMode || dateSetMode || alarmClockMode || timerMode)) flag <= flag + 1; else flag <= 1'b0; end
				    else
					 begin
						if (flag <= 1000 - 1)
						begin 
							C1 <= C1 + 1'b1; D1 <= iData[23:20];D2 <= 6'b111_110;
						end
					   if (flag <= 2000 - 1 && flag > 1000 - 1) begin C1 <= C1 + 1'b1; D1 <= iData[23:20];D2 <= 6'b111_111; if (flag == 2000 - 1) flag <= 1'b0; end
					 end
					 1:
					 if( C1 == T100US -1 ) begin C1 <= 26'd0; i <= i + 1'b1; if (timeSetSel == 3'd1 && (timeSetMode || dateSetMode || alarmClockMode || timerMode)) flag1 <= flag1 + 1; else flag1 <= 1'b0; end
				    else 
					 begin 
						if (flag1 <= 1000 - 1) begin C1 <= C1 + 1'b1; D1 <= iData[19:16]; D2 <= 6'b111_101; end
						if (flag1 <= 2000 - 1 && flag1 > 1000 - 1) begin C1 <= C1 + 1'b1; D1 <= iData[19:16]; D2 <= 6'b111_111; if (flag1 == 2000 - 1) flag1 <= 1'b0; end
					 end
					 
					 2:
					 if( C1 == T100US -1 ) begin C1 <= 26'd0; i <= i + 1'b1; if (timeSetSel == 3'd2 && (timeSetMode || dateSetMode || alarmClockMode || timerMode)) flag2 <= flag2 + 1; else flag2 <= 1'b0; end
				    else 
					 begin 
						if (flag2 <= 1000 - 1) begin C1 <= C1 + 1'b1; D1 <= iData[15:12]; D2 <= 6'b111_011; end
						if (flag2 <= 2000 - 1 && flag2 > 1000 - 1) begin C1 <= C1 + 1'b1; D1 <= iData[15:12]; D2 <= 6'b111_111; if (flag2 == 2000 - 1) flag2 <= 1'b0; end
					 end
					 
					 3:
					 if( C1 == T100US -1 ) begin C1 <= 26'd0; i <= i + 1'b1; if (timeSetSel == 3'd3 && (timeSetMode || dateSetMode || alarmClockMode || timerMode)) flag3 <= flag3 + 1; else flag3 <= 1'b0; end
				    else 
					 begin 
						if (flag3 <= 1000 - 1) begin C1 <= C1 + 1'b1; D1 <= iData[11:8]; D2 <= 6'b110_111; end
						if (flag3 <= 2000 - 1 && flag3 > 1000 - 1) begin C1 <= C1 + 1'b1; D1 <= iData[11:8]; D2 <= 6'b111_111; if (flag3 == 2000 - 1) flag3 <= 1'b0; end
					 end
					 
					 4:
					 if( C1 == T100US -1 ) begin C1 <= 26'd0; i <= i + 1'b1; if (timeSetSel == 3'd4 && (timeSetMode || dateSetMode || alarmClockMode || timerMode)) flag4 <= flag4 + 1; else flag4 <= 1'b0; end
				    else 
					 begin 
						if (flag4 <= 1000 - 1) begin C1 <= C1 + 1'b1; D1 <= iData[7:4]; D2 <= 6'b101_111; end
						if (flag4 <= 2000 - 1 && flag4 > 1000 - 1) begin C1 <= C1 + 1'b1; D1 <= iData[7:4]; D2 <= 6'b111_111; if (flag4 == 2000 - 1) flag4 <= 1'b0; end
					 end
					 
					 5:
					 if( C1 == T100US -1 ) begin C1 <= 26'd0; i <= 4'd0; if (timeSetSel == 3'd5 && (timeSetMode || dateSetMode || alarmClockMode || timerMode)) flag5 <= flag5 + 1; else flag5 <= 1'b0; end
				    else 
					 begin 
						if (flag5 <= 1000 - 1) begin C1 <= C1 + 1'b1; D1 <= iData[3:0]; D2 <= 6'b011_111; end
						if (flag5 <= 2000 - 1 && flag5 > 1000 - 1 ) begin C1 <= C1 + 1'b1; D1 <= iData[3:0]; D2 <= 6'b111_111; if (flag5 == 2000 - 1) flag5 <= 1'b0; end
					 end
					 
				endcase
	 

	
	 assign oData = {D1,D2};
	 
endmodule