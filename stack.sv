// Stack where we connect the reg and cnt6 files
module stack (
	input clk, rst, pop, push, 
	input [31:0] data_in, 
	output [31:0] stack_top, 
	stack_top_minus_one,
	output full, empty, logic [5:0] stack_ptr);
	// stack_ptr is the ptr to the top most spot of stack
	// stack_top_ptr is next to top of stack
 
	
	logic [5:0] stack_top_ptr;
	//logic [5:0] stack_top_ptr, stack_ptr;

	cnt6 cnt6(.clk(clk), 
						.rst(rst), 
						.en_up(push), 
						.en_down(pop), 
						.cnt(stack_ptr));
	
	assign stack_top_ptr = stack_ptr - 6'b1;
	assign full = stack_top_ptr == 6'd32 ? 1'd1: 1'd0; // If space below top has a number then stack is full
	assign empty = stack_ptr == 6'd0 ? 1'd1 : 1'd0;
	
	regfile regi(.clk(clk), 
				.rst(rst), 
				.we(push), 
				.readaddr1(stack_top_ptr[4:0]),
				.readaddr2(stack_top_ptr[4:0] - 5'b1),
				.writeaddr(stack_ptr[4:0]),
				.writedata(data_in),
				.readdata1(stack_top),
				.readdata2(stack_top_minus_one));						
endmodule 
