//100进制计数器
//10ms时钟进秒
module microSecCounter(
	rst_n,
	clk,
	timeSetMode,
	minute_set1,
	minute_set0,
	minute1,
	minute0,
	EO);
	input  clk,rst_n;
	input timeSetMode;
	input [3:0] minute_set1, minute_set0;
	output [3:0] minute1,minute0;
	output EO;    
	reg [3:0] minute1,minute0;
	reg EO;
	
	always @(posedge clk or negedge rst_n or posedge timeSetMode)   
	begin   
		if (!rst_n)
		begin
			minute1 <= 4'd0;
			minute0 <= 4'd0;
			EO      <= 1'd0;
		end
		else
		 begin
			if (timeSetMode)
			begin 
				minute1 <= minute_set1;
				minute0 <= minute_set0;
			end
			else
			begin 
			if(minute0 < 4'b1001)
			begin 
				minute0 <= minute0 + 4'b1;
				EO <= 1'b0;
			end
			else
			begin
				EO <= 1'b0;
				minute0 <= 4'b0;
				if(minute1 < 4'b1001)
					minute1 <= minute1 + 4'b1;
				else
				begin
					minute1 <= 4'b0;
					EO <= 1'b1;
				 end
			end
			end
		end
	end

endmodule
