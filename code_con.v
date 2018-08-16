//This is the dataflow code for a code converter that drives an active low seven-segment display	

module code_con (M,N);
	input [3:0]M;      //declare ports
	output [6:0]N;
	wire T1;           //declare internal wire
	
	assign T1 = (M[3]&M[2])|(M[3]&M[1]),             //logic statement used in all outputs
			N[6] = (M[2]&~M[1]&~M[0])|(~M[3]&~M[2]&~M[1]&M[0])|T1,
			N[5] = (M[2]&~M[1]&M[0])|(M[2]&M[1]&~M[0])|T1,
			N[4] = (~M[2]&M[1]&~M[0])|T1,
			N[3] = (M[2]&~M[1]&~M[0])|(~M[3]&~M[2]&~M[1]&M[0])|(M[2]&M[1]&M[0])|T1,
			N[2] = (M[2]&~M[1]&~M[0])|M[0]|T1,
			N[1] = (~M[3]&~M[2]&M[0])|(M[1]&M[0])|(~M[2]&M[1]&~M[0])|T1,
			N[0] = (~M[3]&~M[2]&~M[1])|(M[2]&M[1]&M[0])|T1;
			
endmodule