`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   20:00:34 03/17/2021
// Design Name:   Float_adder
// Module Name:   C:/Users/amitk/OneDrive/Documents/verilog/Floating_point_adder/Testbench.v
// Project Name:  Floating_point_adder
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: Float_adder
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module Testbench;

	// Inputs
	reg [31:0] num1;
	reg [31:0] num2;

	// Outputs
	wire [31:0] result;

	// Instantiate the Unit Under Test (UUT)
	Float_adder uut (
		.result(result), 
		.num1(num1), 
		.num2(num2)
	);

	initial begin
		// Initialize Inputs
		num1 = 0;
		num2 = 0;

		// Wait 100 ns for global reset to finish
		#100;
      //1 Subtracting a number from itself
      num1=32'b1_10000001_00000000000000000000000;	//-4	c0800000			// result = 0
		num2=32'b0_10000001_00000000000000000000000; //+4	40800000
		#100
		//2	Num1-Num2 where |Num2|>|Num1|
		num1=32'b0_10000001_00000000000000000000000; //+4	40800000			// result = -4 = c0800000
		num2=32'b1_10000010_00000000000000000000000; //-8	c1000000
		#100
		//3	Num1-Num2 where |Num1|>|Num2|
		num1=32'b0_10000001_00000000000000000000000; //+4		40800000		// result = 1.5 = 3fc00000
		num2=32'b1_10000000_01000000000000000000000;	//-2.5	c0200000
		#100
		//4	Num1-Num2 where |Num2|>|Num1|
		num1=32'b0_10000000_01000000000000000000000;	//+2.5	40200000		// result = -1.5 = bfc00000
		num2=32'b1_10000001_00000000000000000000000;	//-4		c0800000
		#100
		//5	Num2-Num1 where |Num2|>|Num1|
		num1=32'b1_10000000_01000000000000000000000;	//-2.5	c0200000		// result = 1.5 = 3fc00000
		num2=32'b0_10000001_00000000000000000000000; //+4 		40800000  
		#100
		//6	Overflow  
		num1=32'b0_11111110_11111111111111111111111;	//7f7fffff		// result = +infinity = 7f800000
		num2=32'b0_11111110_10000000000000000000001; //7f400001  
		#100
		//7	Underflow
		num1=32'b1_11111110_11111111111111111111111;	//ff7fffff		// result = +infinity = ff800000
		num2=32'b1_11111110_10000000000000000000001; //ff400001  
		#100
		//8	normal floating point addition
		num1=32'b0_10000001_11000100000000000000000;	//7.0625		40e20000		// result = 8.09375 = 41018000
		num2=32'b0_01111111_00001000000000000000000; //1.03125  	3f840000
		#100
		//9	+infinity + positive number
		num1=32'b0_11111111_00000000000000000000000;	// + infinity		// output = +infinity
		num2=32'b0_10000001_00000000000000000000000; //+4 	40800000
		#100
		//10	+infinity + negative number
		num1=32'b0_11111111_00000000000000000000000;	// + infinity		// output = +infinity
		num2=32'b1_10000001_00000000000000000000000;	//-4	c0800000
		#100
		//11	+infinity + 0
		num1=32'b0_11111111_00000000000000000000000;	// + infinity		// output = +infinity
		num2=32'b0_00000000_00000000000000000000000; // 0
		#100
		//12	-infinity + positive number
		num1=32'b1_11111111_00000000000000000000000;	// - infinity		// output = -infinity
		num2=32'b0_10000001_00000000000000000000000; //+4 	40800000
		#100
		//13	-infinity + negative number
		num1=32'b1_11111111_00000000000000000000000;	// - infinity		// output = -infinity
		num2=32'b1_10000001_00000000000000000000000;	//-4	c0800000
		#100
		//14	-infinity + 0
		num1=32'b1_11111111_00000000000000000000000;	// - infinity		// output = -infinity
		num2=32'b0_00000000_00000000000000000000000;	// 0
		#100
		//15	infinity + infinity
		num1=32'b0_11111111_00000000000000000000000;	// + infinity		// output = +infinity
		num2=32'b0_11111111_00000000000000000000000;	// + infinity
		#100
		//16	infinity - infinity
		num1=32'b0_11111111_00000000000000000000000;	// + infinity		// output = +infinity // by default
		num2=32'b1_11111111_00000000000000000000000;	// - infinity
		#100
		//17	-infinity - infinity
		num1=32'b1_11111111_00000000000000000000000;	// - infinity		// output = -infinity
		num2=32'b1_11111111_00000000000000000000000;	// - infinity
		#100;
		$stop;    
		

	end
      
endmodule

