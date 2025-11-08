`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:59:27 02/21/2021 
// Design Name: 
// Module Name:    Float_adder 
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
/*	this module is used to calculate the difference between the exponents of both the input numbers
	the exponent difference is calculated as exp of num1 - exp of num2, hence if num1 is greater, than 
	the difference is positive, else the difference is negative. The size of the exponent difference 
	is 1 greater than the actual exponent size, because the extra bit is used to store the sign of the difference.
	it takes the exponent of both the numbers as input and outputs the exponent difference.*/
module small_alu(exp_diff,exp1,exp2);												
		output reg[8:0] exp_diff;														
		input [7:0] exp1,exp2;
		always @ (exp1,exp2)
		begin
			exp_diff = {1'b0, exp1[7:0]} + {1'b1, ~exp2[7:0]}+1'b1;			// subtracting the exponents by using the 2's complement method
		end
endmodule
/* this is a mux that will output the exponent of the greater number, it does so by comparing the sign bit of the exponent difference,
	if the sign bit is 1, then num2 is greater, if sign bit=0 then num1 is greater.
	it takes the exponent of both the numbers as input, and the sign bit of exponent difference and outputs exponent of greater number.*/
module mux_greater_exponent(op,ip1,ip2,exp_diff_sign); 						
	output reg [7:0] op;
	input exp_diff_sign;
	input [7:0] ip1,ip2;
	always @ (ip1,ip2,exp_diff_sign)
	begin
		if(exp_diff_sign==1)						// if true, i.e. exp_diff= 1 the difference is negative, hence num2 is greater
			op=ip2;									// the exponent of greater number is given as output
		else
			op=ip1;							
	end
endmodule
/* this is a mux that takes in fractional part of both the numbers and outputs the fractional part corresponding to the smaller number.
it also takes the exponent difference sign and one bit called as checkbit. the exponent difference tells which number is smaller, in case
the exponent difference sign is 0, it means the difference is either 0 or positive. So the check bit is used which tells whether the exp diff
is 0 or not. if the difference is 0 then the fractional part of the numbers is compared. */
module mux_smaller_fraction(op,exp_diff_sign,fract1,fract2, checkbit);	
	output reg [23:0] op;
	input exp_diff_sign, checkbit;													
	input [23:0] fract1,fract2;
	always @ (exp_diff_sign,fract1,fract2,checkbit)
	begin
		if(exp_diff_sign==1)								// exp_diff_sign==1 means num1 is small
			op=fract1;				
		else if (checkbit==1)							// checkbit==1 means that the the exponent difference if 0 i.e. exp of both numbers are same
		begin
			if(fract1<fract2)								// if exponent of both numbers are same then the fractional parts are compared 
				op=fract1;
			else 
				op=fract2;
		end
		else 
			op=fract2;
	end
endmodule
/* this is a mux that takes in fractional part of both the numbers and outputs the fractional part corresponding to the greater number.
it also takes the exponent difference sign and one bit called as checkbit. the exponent difference tells which number is greater, in case
the exponent difference sign is 0, it means the difference is either 0 or positive. So the check bit is used which tells whether the exp diff
is 0 or not. if the difference is 0 then the fractional part of the numbers is compared. the greatline is given as the output that tells which
number is smaller and greater.( used to get final comaprison control, as in case when exponent diff is 0 the expdiff sign doesnot say anything)*/
module mux_greater_fraction(op,exp_diff_sign,fract1,fract2, checkbit, greatline);	 
	output reg [23:0] op;
	output reg greatline;										// if greatline=1 means num2 is big, this will be used further to know which number is greater
	input exp_diff_sign,checkbit;								// checkbit=1 it tells the exp diff is 0 i.e. exp of both numbers are same
	input [23:0] fract1,fract2;
	always @ (exp_diff_sign,fract1,fract2,checkbit)
	begin
		if(exp_diff_sign==1)										// exp_diff_sign==1 means num2 is greater
		begin
			op=fract2;
			greatline=1;
		end
		else if (checkbit==1)									// if exp of both the numbers is same then compare fractional part
		begin
			if(fract1<fract2)
			begin	
				op=fract2;
				greatline=1;
			end
			else 
			begin	
				op=fract1;
				greatline=0;
			end
		end	
		else
		begin
			op=fract1;
			greatline=0;
		end
	end
endmodule 
/* this module gives the absolute value of exponent difference as the output */
module absofexpdiff(op,ip);								
	output reg [8:0]op;
	input [8:0] ip;
	always @ (ip)
	begin
		if(ip[8]==1)											// if true it is a negative number
			op = ~ip[8:0]+1'b1;								//	if the exponent_difference is negative then take 2's complement of it, to make it positive
		else
			op=ip;												// if the exponent_difference is positive then leave it as it is
	end
endmodule
/* this modules takes the fractional part of the smaller number as input, and the absolute value of 
exponent difference and shifts the fractional part of the smaller number till the exponents of both the numbers are made equal*/
module shift_right(op,ip,shift_value);					
	output reg [23:0] op;
	input [23:0] ip;
	input [8:0] shift_value;
	always @ (ip,shift_value)
	begin
		op = ip >> shift_value;								// shifts the smaller fraction to right, smaller fraction is given as input 
	end
endmodule
/* this module adds/subtracts both the fractional parts once the exponents of both the numbers have been made equal.
this modules takes the greater fractional part and the right shifted fractional part as input, it also takes the sign bits of both the 
number and the great_line(defined in mux_greater_fraction) as input. 
if sign of both the input nums is same then addition is performed and the input number sign is given to the addition result.
if signs are different then the fractional part corresponding to the smaller number(inpshifted) is subtracted from the fractional part 
of the greater number(inpbig), and the sign of greater number is given to the result. the great_line is used to decide the sign of the result.*/
module big_alu(signop,addop,inpshifted,inpbig,sign1,sign2,great_line);	
	output reg [24:0] addop;
	output reg signop;
	input great_line;										// if this great_line is 1 means num2 is big
	input [23:0] inpbig, inpshifted;
	input sign1,sign2;
	always @(inpshifted,inpbig,sign1,sign2,great_line)
	begin
		if(sign1==sign2)									// if same sign then add and result sign = input sign
		begin
			addop = inpshifted + inpbig;
			signop = sign1;														
		end
		else													// sign of both the numbers is different, so subtraction operation is to be performed
		begin
				addop = {1'b0,inpbig} + {1'b1,~inpshifted} + 1'b1; // the smaller number is subtracted from the bigger number 
				if(great_line==1)							// checking which fractional part is bigger, the sign of the result is the sign of the bigger number			
					signop = sign2;							
				else
					signop = sign1;
		end
	end
endmodule
/* this is a mux that takes fractional part as input from the BIG ALU and the fractional part from rounding hardware, and on the basis of the 
control_line the output is decided. control_line=0 means output is of BIG ALU else rounding hardware fraction. in this case no seperate rounding 
hardware has been designed , so the output is always the fractional part of BIG ALU, the control_line is always equal to 0.
If a seperate rounding hardware is designed in future then the control_line can be used to select the output of the mux.*/
module mux_normalize_fraction(op,ip1,ip2,control_line);	
	output reg [24:0] op;
	input [24:0] ip1,ip2;
	input control_line;
	always @(ip1,ip2,control_line)
	begin
		if(control_line==0)
			op=ip1;
		else
			op=ip2;
	end
endmodule
/* this is a mux that takes the greater exponent part as input and the exponent part from rounding hardware, and on the basis of the 
control_line the output is decided. control_line=0 means output is greater exponent else rounding hardware exponent. In this case no 
seperate rounding hardware has been designed , so the output is always the greater exponent, the control_line is always equal to 0.
If a seperate rounding hardware is designed in future then the control_line can be used to select the output of the mux.*/
module mux_normalize_exponent(op,ip1,ip2,control_line);	
	output reg [8:0] op;
	input [8:0] ip2;
	input [7:0] ip1;
	input control_line;
	always @(ip1,ip2,control_line)
	begin
		if(control_line==0)
			op=ip1;
		else
			op=ip2;
	end
endmodule
/* the fractional part here is of 25 bits size(counting from indedx 1 to 25 or index 0 to 24), 23 bits of fraction(index 1 to 23 or index 0 to 22)
+1 bit of normalisation resulting in 24 bits and addition of two 24 bits number gives 25 bits output.

Here while refereing to the index of any number in the code as well as commensts, it is assumed that the index starts from index 0.

This module is used for normalising the result obtained from BIG ALU.
it takes output obtained from BIG ALU and normalises it. several conditions have been checked here while normalising.

if the fractional part is 0, means the it was a subtraction operation and the ans=0, so the exponent part is also made 0.

if the 24th bit is equal to 1, it means a carry was generated during the BIG ALU operation and hence the fractional part must be shifted right 
to make it in the normalised form, and the exponent value is incremented by 1, and this is the final ans.

if no carry was generated(24th bit=0) and the 23rd bit is 0, means the fractional part is not in normalised form, so the fractional part must be 
shifted left so that 23rd bit becomes 1 and the number is in normalsied form, while shifting left until 1 is achieved the exponent part is being 
decremented by 1 in each left shift operation. since there are only 24bits. 

if after normalising the exponent is negative then it means underflow condition has occured and hence the result is made as 0.

if after normalising the exponent is equal to 8'b11111111 means that the overflow condition has occured and the output is infinity.
hence the exponent part is =8'b11111111 sign is sign of result from BIG ALU(+ or - infinity) and the fractional part is made 0.*/
module fract_shift_left_right(fround,eround,fnorm,enorm);	//this module is used for normalising the output results from the BIG ALU 
	output reg [24:0] fround;
	output reg [8:0] eround;
	input [24:0] fnorm;
	input [8:0] enorm;
	always @(fnorm,enorm)
	begin
		fround = fnorm[24:0];						
		eround=enorm[8:0];							
		if(fround != 25'b0)							// if the fractional part is 0, then make the exponent=0, as ans = 0
		begin
			if(fround[24]==1'b1)						// if the 24th bit is 1 then it means a carrys has been generated, so shift the fractional part right by 1 and increment 
			begin 										// the exponent by 1
				fround=fround>>1;
				eround=eround+1'b1;
			end
			else 											// if no carry is generated 
			begin
				repeat(24)								// repeat 24 times because there are only 24 bits in fractional part( considering 1 from normalising)
				begin		
					if(fround[23]==0)					// if the 23th bit is =0 it means that the number is not in normalised form, 
					begin									// so shift it left until we get 1 and decrement the exponent in each iteration
						fround = fround << 1'b1;
						eround = eround - 8'b1;
					end
				end
			end
		end
		else												// if the fractional part is 0 after subtraction make the exponent 0
		begin
			eround=8'b0;
		end
		if(eround<0)									// if underflow then exp=0 fract=0
		begin
			eround=0;
			fround=0;
		end
		if(eround==8'b11111111)						// if overflow, then output is infinity
		begin
			fround=0;
		end
	end
	
endmodule

/* this module is just used for combining the fractional part, exponent part and sign bit into a single 32 bit register and 
displaying it as output. this modules is also used for checking boundary conditions.
if any one of the original input numbers is infinity then the output is also infinity, with the proper sign.
in case of subtracting two infinite numbers the output is given as infinity by default.
if infinity conditions dont occur then the output from the normalising module is combined into 32 bit register.*/
module final_hardware(op, fract, exp, sign, original_num1, original_num2);  
	output reg [31:0] op;																	
	input [24:0] fract;
	input [31:0] original_num1, original_num2;
	input [8:0] exp;
	input sign;
	integer i;
	always @(fract,exp,sign,original_num1, original_num2)
	begin
		if(original_num1==0 && original_num2==0)										// if both inputs are 0 then output is 0
		begin
			op=0;
		end
		else if(original_num1[30:23]==8'b11111111 && original_num2[22:0]==8'b11111111)// if both the input numbers are infinity then the output is also +or - infinity depending on the sign of input		
		begin
			if(original_num1[31]==original_num2[31])									// if input has same sign
			begin
				op[31]=original_num1[31];
			end
			else																					// if sign is different, the default output is + infinity
			begin
				op[31]=0;
			end
			op[30:23]=8'b11111111;															// making the exponet =255(decimal)
			op[22:0]=23'b0;																	// making fractional part=0 for infinity
		end
		else if(original_num1[30:23]==8'b11111111)									// if num1 is infinity
		begin
			op[31]=original_num1[31];
			op[30:23]=8'b11111111;
			op[22:0]=23'b0;
		end
		else if(original_num2[22:0]==8'b11111111)										// if num2 is infinity
		begin 
			op[31]=original_num2[31];
			op[30:23]=8'b11111111;
			op[22:0]=23'b0;
		end
		else if(fract==0 && exp==0)														// if num is 0 then sign is 0
		begin	
			op=0;
		end
		else 																						// if input number is not infinity
		begin
				op[31]=sign;																	// the sign bit is stored in result register		
				
			for(i=0;i<23;i=i+1) 																// the fraction bits are stored in result register
			begin	
				op[i]=fract[i];				
			end
			for (i=0;i<8;i=i+1) 																// the exponent bits are stored in result register
			begin	
				op[i+23]=exp[i];
			end
		end
	end
endmodule
/* this is the main module where all the different modules defined above have been called. 
this module takes two numbers in IEEE-754 format and the input is assumed to be in normalised form.
the output is also given in IEEE-754 format and it is assumed to be in normalised form.*/
module Float_adder(result, num1, num2);
	input [31:0] num1,num2;						// store both the input numbers
	output wire[31:0] result;					// stores the result of the binary floating point addition
	reg signbit1, signbit2;						// store the sign bits of both the numbers
	reg [7:0] exponent1,exponent2;			// stores the exponent of number 1 and 2
	reg [23:0] fraction1,fraction2;			// stores the fraction of number 1 and 2, the size is one more than actual due to 1 present in the normalisation
	integer i;										// variable used for loops

	always @(num1,num2)
	begin
		signbit1 = num1[31];						// stores the sign bit of number 1
		signbit2 = num2[31];						// stores the sign bit of number 2
		fraction1[23]=1;							// the normalised form has 1 before decimal point
		fraction2[23]=1;							// the normalised form has 1 before decimal point
		for(i=0;i<23;i=i+1) begin				// the fraction bits are stored in respective registers
			fraction1[i]=num1[i];				
			fraction2[i]=num2[i];
		end
		for (i=0;i<8;i=i+1) begin				// the exponent bits are stored in respective registers
			exponent1[i]=num1[i+23];
			exponent2[i]=num2[i+23];
		end
	end
		
	wire [8:0] exponent_difference;			// the difference between the exponents of both the input numbers is stored, size is 1 larger than exponent size so as to store sign bit
	small_alu u0 (exponent_difference, exponent1, exponent2);
	
	reg select_line1, select_line2;
	wire select_line3;								// select_line3 =1 means fract1 < fract2 
	always @(*)
	begin
		select_line1 = ~|exponent_difference;	// this bit is =1 if the difference between the exponents =0
		select_line2 = exponent_difference[8];	// this bit=1 if num1 is smaller, if bit=0 then num2 is smaller
	end
	
	wire [7:0] greater_exponent;					// this will store the greater exponent
	mux_greater_exponent u1 (greater_exponent, exponent1, exponent2, select_line2);
	
	wire [23:0] fract_big_exp,fract_small_exp;// this will store the fraction corresponding to the greater and smaller number
	mux_smaller_fraction u2( fract_small_exp, select_line2, fraction1, fraction2, select_line1);
	mux_greater_fraction u3( fract_big_exp, select_line2, fraction1, fraction2, select_line1, select_line3);
	
	wire [23:0] right_shifted_value;				// final right shifted value is stored after making the exponents equal
	wire [8:0] abs_of_exponent_difference;		// abs value of the exponent is stored
	absofexpdiff u4 (abs_of_exponent_difference,exponent_difference);		
	shift_right u5 (right_shifted_value, fract_small_exp, abs_of_exponent_difference);	// shifts the smaller numbers fraction to make exponent same
	
	wire [24:0] fract_addition_result;			// stores the output of big_alu
	wire sign_addition_result;						// sign of the bigalu result is stored
	big_alu u6 (sign_addition_result, fract_addition_result, right_shifted_value, fract_big_exp, signbit1, signbit2, select_line3);
	
	reg control_line1,control_line2;				// used for mux_normalise_fraction and mux_normalise_exponent
	wire [24:0] final_fract;						//output of fract_shift_left_right module
	wire [8:0] final_exp;							//output of fract_shift_left_right module
	wire [24:0] fract_to_be_normalised;			//output of mux_normalise_fraction
	reg [24:0] fract_rounded;						//output of fract_shift_left_right module
	wire [8:0] exp_to_be_normalised;				//output of mux_normalise_exponent
	reg [8:0] exp_rounded;							//output of fract_shift_left_right module
	reg final_sign;
	
	always @(*)
	begin
		control_line1 = 0;						// line=0 means fractional part is from BIG ALU
		control_line2 = 0;						// line=0 means exponent part is of greater number
		final_sign = sign_addition_result;	// stores the final sign of the result after all the comparisons
		fract_rounded=0;							// made 0 since no specific rounding hardware is present
		exp_rounded=0;								// made 0 since no specific rounding hardware is present
	end
	
	mux_normalize_fraction u7 (fract_to_be_normalised, fract_addition_result, fract_rounded, control_line1);
	
	mux_normalize_exponent u8 (exp_to_be_normalised, greater_exponent, exp_rounded, control_line2);
	
	fract_shift_left_right u9 (final_fract, final_exp, fract_to_be_normalised, exp_to_be_normalised);
	
	final_hardware u10 (result, final_fract, final_exp, final_sign, num1,num2);
	
endmodule

