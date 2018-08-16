`timescale 1ns / 1ps

module clock_div (clk_in,clk_out,reset);
	input clk_in, reset;		//100MHZ clock in
	output reg clk_out;			
	parameter n=500;			//having 500 periods 1 and 500 periods 0
	parameter logn=8;			
	reg [logn:0]count;			//setting the corect count vector size
	
	always@(posedge clk_in or posedge reset)
	begin
		if (reset) begin 
			clk_out<=1'b0; count<=0; end		//resetting values
		else if (count < n) count<=count+1'b1;		//increase the count with every clock cycle
		else begin clk_out<=~clk_out; count<=1'b0; end	//toggle when clock cycles have finished
	end
endmodule