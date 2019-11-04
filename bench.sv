module bench;
	

//____________________________________________________________

	reg clk, clk2, rst;
	reg [1:0 ] mode;	/* mode from SW17 and SW16 */ ///  mode = switch
	reg [3:0 ] key;		/* value from KEYs */
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
	reg [15:0] val;		/* 16 bit value from SW15...SW0 */
	reg [15:0] top;		/* 16 bit value at the top of the
					 * stack, to be shown on HEX3...HEX0 */
	reg [15:0] next;		/* 16 bit value second-to-top in the
					 * stack, to be shown on HEX7...HEX4 */
	reg [7:0] counter;		/* counter value to show on LEDG */
//_____________________________________________________________
	// TESTBENCH DATA
	logic [61:0] vectors [99:0]; // 1e3 62 bit test vectors
	logic [31:0] error, vectornum; // error counter

	// EXPECTED INPUT
	reg [15:0] top_expected;
	reg [15:0] next_expected;
	reg [7:0] counter_expected;

	initial begin
		//key   = 4'b1111; // making sure keys start out as unpressed (being pressed is active low)
		error = 0;	
	end
	
	/* instantiate the ALU we plan to test */
	rpncalc rpncalc(.clk(clk), .rst(rst), .mode(mode), .key(key), .val(val), .top(top), .next(next), .counter(counter));


	// RPNCALC CLOCK
	always begin
		clk = 1'b1; #5; clk = 1'b0; #5;
	end

	// CLOCK FOR DOWNLOADING VECTORS
	always begin
		clk2 = 1'b1; #25; clk2 = 1'b0; #25;
	end

	/*
	always @(negedge clk2) begin
		//#5; 
		key <= 4'b1111;
	end
	*/
	initial begin
		$readmemb("vectors.dat", vectors); // read as bits
		vectornum = 32'b0; 
		error = 32'b0;
		rst = 1'b1; #27; rst = 1'b0;		
	end


			// keys have active low mapping of the 4 bits for which one is pressed 
			// key3 = 0111 or 7     key2= 1011 or 11    key1 = 1101 or 13      key0 = 1110 or 14
	always @(posedge clk2) begin
		{mode, key, val, top_expected, next_expected, counter_expected} = vectors[vectornum]; 
		//vector doesn't need clk, rst
		// size should be [1:0 ]+[3:0 ] +[15:0]+[15:0]+[15:0]+[7:0]
		// 2+ 4+ 16*3 + 8 =>  14 + 16*3 => 14 + 48 = 62 bits
		vectornum = vectornum + 1;
	end	



	always @(posedge clk2) begin
		if (~rst && key!= 4'b1111) begin
		if (top!=top_expected || next != next_expected || counter != counter_expected) begin
	$display("Error Detected: mode = %h key = %h val = %h top_expected = %h next_expected = %h counter_expected = %h", 
				mode, key, val, top_expected, next_expected, counter_expected);
			$display("");
			//$display("hi = %h(%h expected)", hi, hi_e);
			$display("Error Detected in top: output = %h", top);
			$display("top_expected = %h", top_expected);	
			$display("");
			//$display("lo = %h(%h expected)", lo, lo_e);
			$display("Error Detected in next: output = %h", next);
			$display("next_expected = %h", next_expected);
			$display("");
			//$display("zero = %h(%h expected)", zero, zero_e);
			$display("Error Detected in counter: output = %h", counter);
			$display("counter_expected = %h", counter_expected);	
			error = error + 32'b1;
			$display("---------------------------------------------------------");
		end else begin
			$display("top_expected = %h, top = %h", top_expected, top);
			$display("next_expected = %h, next = %h", next_expected, next);	
			$display("counter_expected = %h, counter = %h", counter_expected, counter);
		end
		end
		
	end


		



endmodule

