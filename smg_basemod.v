module smg_basemod
(
    input CLOCK, RESET,
	 input  [23:0] iData,  //输入的数据
	 output [7:0]DIG,  //八段数码管
	 output [5:0]SEL //位选
); 
    wire [9:0]DataU1;

    smg_funcmod U1
    (
	     .CLOCK( CLOCK ),
		  .RESET( RESET ),
	     .iData( iData ), 		// < top
		  .oData( DataU1 )      // > U2
	 );
	 
	 smg_encode_immdmod U2
	 (
		  .iData( DataU1[9:6] ),  // < U1
		  .oData( DIG )           // > top
	 );
	 
	 assign SEL = DataU1[5:0];
	 
endmodule
