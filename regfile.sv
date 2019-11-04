/* 32 x 32 register file implementation */

module regfile (

/**** inputs *****************************************************************/

	input [0:0 ] clk,				/* clock */
	input [0:0 ] rst,				/* reset */
	input [0:0 ] we,				/* write enable */
	input [4:0 ] readaddr1,		/* read address 1 */
	input [4:0 ] readaddr2,		/* read address 2 */
	input [4:0 ] writeaddr,		/* write address */
	input [31:0] writedata,		/* write data */

/**** outputs ****************************************************************/

	output [31:0] readdata1,	/* read data 1 */
	output [31:0] readdata2		/* read data 2 */
);


	// This creates the 32 x 32 bit register
	reg [31:0] mem[31:0];
	
	
	// At positive edge of clock we write making it synchronous write
	always @(posedge clk) begin
	
	// Write enable write data at address on Posedge of clk
	if (we) mem[writeaddr] <= writedata;
	
	end
	
	
	// Implement Write Bypass for readdata 1 and 2, this is asynchronous as it requires no clock timing 
	assign readdata1 = readaddr1 == writeaddr && we ? writedata : mem[readaddr1];
	
	//assign readdata2 = readaddr2 == writeaddr && we ? writedata : mem[readaddr2];
	assign readdata2 = mem[readaddr2];
	//condition ? if true : if false
endmodule








