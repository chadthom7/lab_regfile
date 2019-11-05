/* RPN calculator module implementation */

module rpncalc (

/**** inputs ****************************************************************/

input [0:0 ] clk,  /* clock */
input [0:0 ] rst,  /* reset */
input [1:0 ] mode,  /* mode from SW17 and SW16 */
input [3:0 ] key,  /* value from KEYs */

    /* Remember that the 2 bit mode and
     * 4 bit key value are used to
     * uniquely identify one of 16
     * operations. Also keep in mind that
     * they keys are onehot (i.e. only one
     * key is pressed at a time -- if
     * more than one key is pressed at a
     * time, the behavior is undefined
     * (i.e. you may choose your own
     * behavior). */

input [15:0] val,  /* 16 bit value from SW15...SW0 */

/**** outputs ****************************************************************/

output [15:0] top,  /* 16 bit value at the top of the
     * stack, to be shown on HEX3...HEX0 */

output [15:0] next,  /* 16 bit value second-to-top in the
     * stack, to be shown on HEX7...HEX4 */

output [7:0] counter  /* counter value to show on LEDG */

);
/********************************************************* RPN LOGIC *******************************************/
// Declaring logic variables is default 1 bit
logic pop, push, key_push, full, empty;
logic [3:0] op, key_dly, key_dly2;
logic [5:0] caseVal;
logic [7:0] shamt;
logic [31:0] A, B, Aout, Bout;
logic [31:0] stack_top, stack_top_minus_one, val2;
logic [31:0] top_captured, next_captured; //changed to 31 from 15

logic [5:0] stack_ptr;
// [7:0] .... counter = {2'b0, stack_ptr[5:0]}; 


// Declaration of state types
typedef enum logic [4:0] {idle,pop1,pop2,push1,push2} state_type;
state_type current_state, next_state;

 
// Instantiating the Stack / Register file
stack STACK(.clk(clk),
 .rst(rst),  
 .pop(pop),
 .push(push),
 .data_in(val2),
 .stack_top(stack_top),
 .stack_top_minus_one(stack_top_minus_one),
 .full(full), 
 .empty(empty),
 .stack_ptr(stack_ptr)); // Full and empty return bit values ie, True / False
 
//hexdriver mydriver(.val(), .HEX());
 
// Instantiation of ALU
//alu ALU(.a(stack_top), .b(stack_top_minus_one), .op(op), .shamt(shamt), .hi(A), .lo(B), .zero());
alu ALU(.a(top_captured), .b(next_captured), .op(op), .shamt(shamt), .hi(A), .lo(B), .zero());



// For saving the values on the stack for reversing
always_ff @(posedge clk) begin
  if (key_push) begin
    top_captured = stack_top[15:0]; //top; // Should capture the values at top of stack
    next_captured = stack_top_minus_one[15:0]; //next; // Should capture value second from top of stack
  end
end
 
// For showing values on the hex display on the fpga
assign top = stack_top[15:0]; // A in alu computations
assign next = stack_top_minus_one[15:0]; // B in alu copmutations
 
assign Aout = top;
assign Bout = next;

// Clock delay for button press -> Debouncer  
always_ff @ (posedge clk) begin
key_dly <= key;
key_dly2 <= key_dly;
end
/*
always @(posedge clk) begin
counter = {2'b0, stack_ptr[5:0]}; 
end
*/
assign counter = {2'b0, stack_ptr[5:0]};


// Debouncer, Key push assigned based on delay
assign key_push = &key_dly2 & ~&key_dly;
always_ff @(posedge clk) if (rst) current_state <= idle; else current_state <= next_state;

// This block controls the state logic / State Register
always_comb begin

next_state = current_state;

// 2 special cases for staying in idle ->  when completeing a single Pop or Push
// -------------------------------------------------------------------------------------------------------------

//                             caseVal == 00_0111  
// Push value onto stack       Case val = 00_0111 * // Changed next_state from idle to push1
if (current_state == idle && ~mode[1] && ~mode[0] && ~key_dly[3] && key_push) next_state = push1;
 

//                              Case val = 00_1011
// Pop top most value from stack and smash that shit *
if (current_state == idle && ~mode[1] && ~mode[0] && ~key_dly[2] && key_push) next_state = pop1;//idle
 
// -------------------------------------------------------------------------------------------------------------


// Pop top 2 and push sum on stack *   // Case val = 00_1101 *
if (current_state == idle && ~mode[1] && ~mode[0] && ~key_dly[1] && key_push) next_state = pop1;


// Pop top 2 and push difference on stack *   // Case val = 00_1110
if (current_state == idle && ~mode[1] && ~mode[0] && ~key_dly[0] && key_push) next_state = pop1;


// Pop top 2 push second to top value shifted left by topmost value *   // Case val = 01_1101
if (current_state == idle && ~mode[1] && mode[0] && ~key_dly[2] && key_push) next_state = pop1;


// Pop top 2 push second to top shifted right (logical) by topmost value *   // Case val = 01_1101
if (current_state == idle && ~mode[1] && mode[0] && ~key_dly[1] && key_push) next_state = pop1;


//                                   // Case val = 01_1110
// Pop top 2 , Less than, if A < B or topmost is less than second to top, push 1 on stack, 0 otherwise *
if (current_state == idle && ~mode[1] && mode[0] && ~key_dly[0] && key_push) next_state = pop1;


// Pop top 2 push bitwise AND onto stack *   // Case val = 10_0111  
if (current_state == idle && mode[1] && ~mode[0] && ~key_dly[3] && key_push) next_state = pop1;


// Pop top 2 push bitwise OR onto stack *   // Case val = 10_0100
if (current_state == idle && mode[1] && ~mode[0] && ~key_dly[2] && key_push) next_state = pop1;


// Pop top 2 push bitwise NOR onto stack *   // Case val = 10_1101
if (current_state == idle && mode[1] && ~mode[0] && ~key_dly[1] && key_push) next_state = pop1;


// Pop top 2 push bitwise XOR onto stack  *  // Case val = 10_1110
if (current_state == idle && mode[1] && ~mode[0] && ~key_dly[0] && key_push) next_state = pop1;


// Pop top 2 values push lower 32 bits of unsigned product *   // Case val = 01_0111
if (current_state == idle && ~mode[1] && mode[0] && ~key_dly[3] && key_push) next_state = pop1;


// Pop top 2 values and switch them and push back onto stack *   // Case val = 11_0111
if (current_state == idle && mode[1] && mode[0] && ~key_dly[3] && key_push) next_state = pop1;

if (current_state == pop1) next_state = pop2;
if (current_state == pop2) next_state = push1;
if (current_state == push1 && mode[1] && mode[0]) next_state = push2;
else if (current_state == push1) next_state = idle;
if (current_state == push2) next_state = idle;

end

// Mode[1] -> SW17, Mode[0] -> SW16
// This block controls the calculator logic and connects to the alu and stack

always_ff@(posedge clk) begin


val2 = {16'b0, val}; // Value input from FPGA switches SW15 -> SW0 then padded with 0's
if(current_state== idle) begin
  push = 1'b0;
  pop = 1'b0;
end
//if(pop == 1'b1) pop = 1'b0;
//if(push == 1'b1) push = 1'b0;
//pop = 1'b0;
//push = 1'b0;

caseVal = {mode, key_dly};

case(caseVal)

// Push onto stack and state stays idle -> Tested in modelsim and confirmed
6'b00_0111 : begin // Changed nest_state from idle to push
  if(current_state ==  push1) push = 1'b1;
 //val2 = {16'b0, val};
 //push = 1'b0;
end


// Pop single value and state stays idle
6'b00_1011 : begin
  if(current_state ==  pop1) pop = 1'b1;
  if(current_state !=  pop1) pop <= 1'b0;
 //pop = 1'b0;
end

//____________________________________________________________________________________________
// Pop top two and push sum           
6'b00_1101 : begin
  if (current_state ==  pop1) begin
   op = 4'b0100; // Op for adding
   pop = 1'b1;
  end
  if (current_state ==  pop2) pop = 1'b1;
  if (current_state == push1) begin
    pop = 1'b0;
    val2 = B; 
    push = 1'b1;
  end
end

//_____________________________________ Might be backwards, this is (top - next)xxxx now it's next-top (I changed alu formula)
// Pop top two and push difference
6'b00_1110 : begin
  if (current_state ==  pop1) begin
   op = 4'b0101; // Op for subracting
   pop = 1'b1;
  end
  if (current_state ==  pop2) pop = 1'b1;
  if (current_state == push1) begin
    pop = 1'b0;
    val2 = B; 
    push = 1'b1;
  end
end
//____________________________________________________________________________________________

// Pop top two and push product
6'b01_0111 : begin
  if (current_state ==  pop1) begin
   op = 4'b0111; // Op for multiplication
   pop = 1'b1;
  end
  if (current_state ==  pop2) pop = 1'b1;
  if (current_state == push1) begin
    pop = 1'b0;
    val2 = B; 
    push = 1'b1;
  end
end

//____________________________________________________________________________________________
// Pop top two, shift left by top most value
6'b01_1011 : begin 
  if (current_state ==  pop1) begin
   op = 4'b1000; // Op for shifting
   pop = 1'b1;
  end
  if (current_state ==  pop2) pop = 1'b1;
  if (current_state == push1) begin
    pop = 1'b0;
    val2 = B; 
    push = 1'b1;
  end
end 
//____________________________________________________________________________________________

// Pop top two shift right by top most value
6'b01_1101 : begin
  if (current_state ==  pop1) begin
    op = 4'b1001; // Op for shifting
    pop = 1'b1;
  end
  if (current_state ==  pop2) pop = 1'b1;
  if (current_state == push1) begin
    pop = 1'b0;
    val2 = B; 
    push = 1'b1;
  end
end
//____________________________________________________________________________________________

// Pop top two compare, if A < B is true, push A... push 0 otherwise
// Ouput from the alu will be a binary value for B, Bout, and stack_top_minus_one
6'b01_1110 : begin
   if (current_state ==  pop1) begin
     op = 4'b1100; // Op for 
     pop = 1'b1;
  end
  if (current_state ==  pop2) pop = 1'b1;
  if (current_state == push1) begin
    pop = 1'b0;
    val2 = B; 
    push = 1'b1;
  end
end

//__________________________________________________________________________________and or nor xor
6'b10_0111 : begin
   if (current_state ==  pop1) begin
     op = 4'b0000; // Op for and
     pop = 1'b1;
  end
  if (current_state ==  pop2) pop = 1'b1;
  if (current_state == push1) begin
    pop = 1'b0;
    val2 = B; 
    push = 1'b1;
  end
end

6'b10_1011 : begin
   if (current_state ==  pop1) begin
     op = 4'b0001; // Op for or
     pop = 1'b1;
  end
  if (current_state ==  pop2) pop = 1'b1;
  if (current_state == push1) begin
    pop = 1'b0;
    val2 = B; 
    push = 1'b1;
  end
end
6'b10_1101 : begin
   if (current_state ==  pop1) begin
     op = 4'b0010; // Op for nor
     pop = 1'b1;
  end
  if (current_state ==  pop2) pop = 1'b1;
  if (current_state == push1) begin
    pop = 1'b0;
    val2 = B; 
    push = 1'b1;
  end
end
6'b10_1110 : begin
   if (current_state ==  pop1) begin
     op = 4'b0011; // Op for xor
     pop = 1'b1;
  end
  if (current_state ==  pop2) pop = 1'b1;
  if (current_state == push1) begin
    pop = 1'b0;
    val2 = B; 
    push = 1'b1;
  end
end
//_____________________Uno Reverse Card_______________________________________________________________________
6'b11_0111 : begin
  if (current_state ==  pop1) begin
   pop = 1'b1;
  end
  if (current_state ==  pop2) begin
    pop = 1'b1;
  end
  if (current_state == push1) begin
    pop = 1'b0;
    val2 = top_captured; 
    push = 1'b1;
  end
  if (current_state == push2) begin
    val2 = next_captured; 
    push = 1'b1;
  end
end

// TODO 6 more cases and the reverse case
default : begin
// TODO Finsh Default
end
endcase
end
endmodule

