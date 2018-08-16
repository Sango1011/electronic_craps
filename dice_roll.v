`timescale 1ns / 1ps

module dice_roll (clk_in,reset,enable,roll,clk_out);
	input clk_in, reset, enable;		//clk_in is 100MHZ
	output reg clk_out;
	parameter n=500;			//clock divider making 500 periods 1 and 500 periods 0
	parameter logn=8;			//to make the count the coreect number of bits
	reg [logn:0]count;
	output reg [3:0]roll;				//counter for the random dice value
	
	always@(posedge clk_in or posedge reset)
	begin
		if (reset) begin 
			clk_out<=1'b0; count<=0; roll<=1'b001; end			//reset values
		else if (enable) begin
			if (count < n) count<=count+1'b1;	//increase count for clock divider
		      else begin clk_out<=~clk_out; 				//toggle the clock
					count<=1'b0; 					//reset count to 0
					roll<=roll+1; 					//increase the roll counter
				    if (roll==3'b110) roll<=3'b001; 	//allows the roll to be from 1 to 6
				end
		end
	end
	
endmodule