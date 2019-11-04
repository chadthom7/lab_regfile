module CSCE611_alu_testbench;

	logic [31:0] a, b;
	logic [3 :0] op;
	logic [4 :0] shamt;

	// actual values
	logic[31:0] hi, lo;
	logic[0 :0] zero;

	// expected values
	logic[31:0] hi_e, lo_e;
	logic[0 :0] zero_e;

	logic [147:0] vectors [999:0]; // 1e3 148 bit test vectors
	logic [147:0] current; // current test vector
	logic [31:0] i; //vector subscript
	logic [3:0] enable; // test vector enable
	logic [31:0] error; // error counter

	initial begin
		a     = 0;
		b     = 0;
		op    = 0;
		shamt = 0;
		i     = 0;
		error = 0;
	end

	/* instantiate the ALU we plan to test */
	alu dut (.a(a), .b(b), .op(op), .shamt(shamt), .hi(hi), .lo(lo), .zero(zero));

	initial begin
		// load test vectors from disk

		// Reads in test vectors from file
		$readmemh("vectors.dat", vectors);
		
		i = 32'b0; 
		error = 32'b0;		

		for (i = 0; i < 1000; i = i + 1) begin

			$display("---------------------------------------------------------");
			current = vectors[i];

			enable = current[147:144];			

			if(enable === 4'hx) $finish();
			a = current[143:112];
			b = current[111:80];
			shamt = current[79:72];
			op = current[71:68];
			hi_e = current[67:36];
			lo_e = current[35:4];
			zero_e = current[3:0];
			
			$display("Show enable:%h", enable);
			#2 // Literally Time in Nano Seconds

			// check to see if this test vector is unused
			//if (enable == 4'b1111) begin
			$display("");
			
			if(hi !== hi_e || lo !== lo_e || zero !== zero_e) begin
			$display("Error Detected: a = %h b = %h shamt = %h op = %h hi_e = %h lo_e = %h zero_e = %h ", 
				a, b, shamt, op, hi_e, lo_e, zero_e);
			$display("");
			//$display("hi = %h(%h expected)", hi, hi_e);
			$display("Error Detected in hi: output = %h", hi);
			$display("hi expected = %h", hi_e);	
			$display("");
			//$display("lo = %h(%h expected)", lo, lo_e);
			$display("Error Detected in lo: output = %h", lo);
			$display("lo expected = %h", lo_e);
			$display("");
			//$display("zero = %h(%h expected)", zero, zero_e);
			$display("Error Detected in zero: output = %h", zero);
			$display("zero expected = %h", zero_e);	
			error = error + 32'b1;
			$display("---------------------------------------------------------");
			
			end // if (current[3:0] 4'b1111) begin

		end // for (i = 0; i < 1000; i++) begin

		// tell the simulator we're done
		$stop();

	end // initial begin

endmodule


