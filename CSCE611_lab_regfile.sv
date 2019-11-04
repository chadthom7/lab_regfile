
//=======================================================
//  This code is generated by Terasic System Builder
//=======================================================

module CSCE611_lab_regfile(

	//////////// CLOCK //////////
	input 		          		CLOCK_50,
	input 		          		CLOCK2_50,
	input 		          		CLOCK3_50,

	//////////// LED //////////
	output		     [8:0]		LEDG,
	output		    [17:0]		LEDR,

	//////////// KEY //////////
	input 		     [3:0]		KEY,

	//////////// SW //////////
	input 		    [17:0]		SW,

	//////////// SEG7 //////////
	output		     [6:0]		HEX0,
	output		     [6:0]		HEX1,
	output		     [6:0]		HEX2,
	output		     [6:0]		HEX3,
	output		     [6:0]		HEX4,
	output		     [6:0]		HEX5,
	output		     [6:0]		HEX6,
	output		     [6:0]		HEX7
);



//=======================================================
//  REG/WIRE declarations
//=======================================================
// stack reg rpn 
/*
logic [5:0] stack_top_ptr, stack_ptr;
logic pop, push, key_push; 
logic [3:0] op, key_dly, key_dly2;
logic [7:0] shamt; 
logic [31:0] A, B, Aout, Bout;
logic [31:0] stack_top, stack_top_minus_one, val2;
typedef enum logic [3:0] {idle,pop1,pop2,push1} state_type; 
*/

//=======================================================
//  Structural coding
//=======================================================



endmodule
