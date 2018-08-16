module sSegDisplay_8(ck, digit0, digit1, digit2, digit3, digit4, digit5, digit6, digit7, seg, an);
	input ck; //100MHz system clock
	input [0:6] digit0, digit1, digit2, digit3, digit4, digit5, digit6, digit7; // 8 digit number to be displayed
	output [0:7] seg;   // display cathodes
	output [0:7] an;    // display anodes (active-low, due to transistor complementing)

	reg [19:0]cnt=20'b0; //divider counter for ~95.3Hz refresh rate (with 100MHz main clock)
	reg [0:7]hex;  // hexadecimal digit
	reg [0:7]intAn; 		// internal signal representing anode data

	assign  an = intAn;
	assign   seg = hex;
	
	always@(posedge ck)
   begin
         cnt <= cnt + 1'b1;
   end  
		
	// Anode Select
   always@(cnt[19:17])  // 100MHz/2^20 = 95.3Hz
	begin
			case(cnt[19:17])    
				0: begin intAn = 8'b11111110; hex = {digit0, 1'b1}; end
				1: begin intAn = 8'b11111101; hex = {digit1, 1'b1}; end
				2: begin intAn = 8'b11111011; hex = {digit2, 1'b1}; end
				3: begin intAn = 8'b11110111; hex = {digit3, 1'b1}; end
				4: begin intAn = 8'b11101111; hex = {digit4, 1'b1}; end
				5: begin intAn = 8'b11011111; hex = {digit5, 1'b1}; end
				6: begin intAn = 8'b10111111; hex = {digit6, 1'b1}; end
				default: begin intAn = 8'b01111111; hex={digit7, 1'b1}; end
			endcase
	end
	
endmodule
