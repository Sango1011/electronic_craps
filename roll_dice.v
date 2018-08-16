`timescale 1ns / 1ps

module roll_dice (CLK100MHZ,clock,reset,enable,roll);
	input clock, reset, enable,CLK100MHZ;		//clock is 100MHZ
	output reg [2:0]roll;				//counter for the random dice value
	
	clock_div U1(.clk_in(CLK100MHZ),.clk_out(clock),.reset(reset));
	
	always@(posedge clock or posedge reset)
	begin
		if (reset) roll<=3'b001;				//reset values
		else if (enable) begin roll<=roll+1'b1;	//increase the roll register by 1
			if (roll==3'b110) roll<=3'b001; 	//when the register gets to 6 start back at 1
		end
	end
	
endmodule