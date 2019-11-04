	// Module to make counter
module cnt6(input clk, rst, en_up, en_down, output logic [5:0] cnt);
	// en_up is push
	// en_down is pop
	// Logic to control the counter 
	always @(posedge clk, posedge rst) begin // <--- Should we remove "posedge rst" ?
		if (rst) cnt <= 0;
		else if (en_up) cnt <= cnt + 6'b1;
		else if (en_down) cnt <= cnt - 6'b1;
	end
	
	
endmodule
