/* RPN calculator module implementation */

module rpncalc (

/**** inputs *****************************************************************/

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


// Declaration of state types
typedef enum logic [3:0] {idle,pop1,pop2,push1} state_type;
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
 .empty(empty)); // Full and empty return bit values ie, True / False
 
//hexdriver mydriver(.val(), .HEX());
 
// Instantiation of ALU
alu ALU(.a(stack_top), .b(stack_top_minus_one), .op(op), .shamt(shamt), .hi(A), .lo(B), .zero());
//alu myALU(.a({16'b0, top}), .b({16'b0, next}), .op(op), .shamt(shamt), .hi(A), .lo(B), .zero());

logic [15:0] top_captured, next_captured;

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

/*

logic [3:0] Hex0, Hex1, Hex2, Hex3, Hex4, Hex5, Hex6, Hex7;

assign Hex0 = top[3:0];
assign Hex1 = top[7:4];
assign Hex2 = top[11:8];
assign Hex3 = top[15:12];

assign Hex4 = next[3:0];
assign Hex5 = next[7:4];
assign Hex6 = next[11:8];
assign Hex7 = next[15:12];

hexdriver hex0(.valTop(Hex0), .HEX(HEX0));
hexdriver hex1(.valTop(Hex1), .HEX(HEX1));
hexdriver hex2(.valTop(Hex2), .HEX(HEX2));
hexdriver hex3(.valTop(Hex3), .HEX(HEX3));
hexdriver hex4(.valTop(Hex4), .HEX(HEX4));
hexdriver hex5(.valTop(Hex5), .HEX(HEX5));
hexdriver hex6(.valTop(Hex6), .HEX(HEX6));
hexdriver hex7(.valTop(Hex7), .HEX(HEX7));
*/
           /////////////// State Machine made of several blocks to control the state   //////////////////////////////////////
    ////////////// Should implement synchronus write and asynchronus read and state change    /////////////////////////////



// Clock delay for button press -> Debouncer  
always_ff @ (posedge clk) begin
key_dly <= key;
key_dly2 <= key_dly;
end

// Debouncer ?
// Key push assigned based on delay
assign key_push = &key_dly2 & ~&key_dly;
 // key_push = &key_dly2 & ~&key_dly;  
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
if (current_state == push1) next_state = idle;

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

 
// Pop top two and push sum
6'b00_1101 : begin
  if (current_state ==  pop1) begin
   op = 4'b0100; // Op for adding
   val2 = B; // val2 = {16'b0, B[15:0]}; 
   pop = 1'b1;

  end
  if (current_state ==  pop2) pop = 1'b1;
  if (current_state == push1) begin
    pop = 1'b0;
    //op = 4'b0100; // Op for adding
    //val2 = B; // val2 = {16'b0, B[15:0]};
    push = 1'b1;
 end
 /*
 op = 4'b0100; // Op for adding
 pop = 1'b1;
 //pop = 1'b0;
 //pop = 1'b1;
 //pop = 1'b0;
 val2 = B; // val2 = {16'b0, B[15:0]};
 push = 1'b1;
 //push = 1'b0;
*/
end

//____________________________________________________________________________________________
// Pop top two and push difference
6'b00_1110 : begin
 op = 4'b0101; // Op for subracting
 pop = 1'b1;
 pop = 1'b0;
 val2 = B; // val2 = {16'b0, B[15:0]};
 push = 1'b1;
 push = 1'b0;
end


// Pop top two shift left by top most value
6'b01_1101 : begin  
 op = 4'b1000; // Op for shifting left by top value on stack
 pop = 1'b1;
 pop = 1'b0;
 val2 = B; // val2 = {16'b0, B[15:0]};
 push = 1'b1;
 push = 1'b0;
end


// Pop top two shift right by top most value
6'b01_1101 : begin
 op = 4'b1001; // Op for shifting right by top value on stack
 pop = 1'b1;
 pop = 1'b0;
 val2 = B; // val2 = {16'b0, B[15:0]};
 push = 1'b1;
end


// Pop top two compare, if A < B is true, push A... push 0 otherwise
// Ouput from the alu will be a binary value for B, Bout, and stack_top_minus_one
6'b01_1110 : begin
 op = 4'b1101; // Op for comparing A < B (unsigned)
 pop = 1'b1;
 
 if (B == 1'b1) begin
  val2 = {16'b0, top};
  push = 1'b1;
 end
 else begin
  val2 = {32'b0};
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


/*

// Pop value off stack
if (current_state == idle && next_state == idle && full == 1'b1) pop = 1'b1;

// Push value onto stack
if (current_state == idle && next_state == idle) push = 1'b1;


// Pop - Pop - Push for Operations
if (current_state == idle && next_state == pop1) pop = 1'b1;
if (current_state == pop1 && next_state == pop2) pop = 1'b1;
if (current_state == push1) begin
 op = 4'b0100; // Op for adding
 push = 1'b1;
 val2 = {16'b0, Bout[15:0]};
end

// This is for REVERSING the stack values
// -------- MODIFY THIS TO WORK PORPERLY ----------------//
if (current_state == pop1) pop = 1'b1;
if (current_state == pop2) pop = 1'b1;
if (current_state == push1 ) begin
 push = 1'b1;
 val2 = {16'b0, top_captured};
end

if (current_state == push1) begin
 push = 1'b1;
 val2 = {16'b0, next_captured};
end

*/
