`timescale 1ns / 1ps

module craps (enable,reset,CLK100MHZ,state,an,seg,play,win,loose);
	input enable, reset,CLK100MHZ;
	output reg [3:0]state;
	reg [6:0]D0,D1,D2,D3,D4,D5,D6,D7;
	output [0:7]seg,an;
	output reg play,win,loose;
	reg [3:0]next;
	wire [3:0]R1,R2,sum;
	reg [3:0]pt10s,pt1s,pt;
	wire [6:0] pt10,pt1,dice1,dice2;
	wire CLK10KHZ;
	
	//calling modules for 10KHZ clock, and the two dice rolls
	clock_div #(5000,12) U1 (.clk_in(CLK100MHZ),.reset(reset),.clk_out(CLK10KHZ));
	roll_dice Dice_1 (.CLK100MHZ(CLK100MHZ),.enable(enable),.reset(reset),.roll(R1));
	roll_dice2 Dice_2 (.CLK100MHZ(CLK100MHZ),.enable(enable),.reset(reset),.roll(R2));
	
	//calling the code converter to convert the outputs for the segment display
	code_con Roll1 (.M(R1),.N(dice1));
	code_con Roll2 (.M(R2),.N(dice2));
	code_con points10 (.M(pt10s),.N(pt10));
	code_con points1 (.M(pt1s),.N(pt1));

	
	parameter S0=4'b0000, S1=4'b0001, S2=4'b0010, S3=4'b0011, S4=4'b0100, S5=4'b0101, 
	       S6=4'b0110, S7=4'b0111, S8=4'b1000, S9=4'b1001;
	
	//next state logic
	always@(state,enable,pt,sum)
    begin
        case(state)
            S0: if(enable) next=S1;    //push button for next state
                else next=S0;
            S1: if(enable) next=S1;    //rolling state, release button for next state
                else next=S2;
            S2: if(sum==4'b0111 || sum==4'b1011) next=S6;  //sum of 7 or 11 goes to win state
                else if(sum==4'b0010 || sum==4'b0011 || sum==4'b1100) next=S8; //sum 2,3,or 12 foes to loose state
                else next=S3;          //next roll
            S3: if(enable) next=S4;    //hold state, push button to continue to next state
                else next=S3;
            S4: if(enable) next=S4;    //hold state or release button to move to next state
                else next=S5;
            S5: if(pt==sum) next=S6;   //win state if point equals sum
                else if (sum==4'b0111) next=S8;    //sum of 7 goes to loose state
                else next=S3;          //roll again
            S6: if(enable) next=S7;    //hold state, press button to move to winner state
                else next=S6;
            S7: next=S7;
            S8: if(enable) next=S9;    //hold state, press buttonm to move to loose state
                else next=S8;
            S9: next=S9;
            default:  next=S0;
        endcase
    end
    
    //reset conditions
	always@(posedge CLK10KHZ or posedge reset)
    begin
        if(reset) state<=S0;
        else state<=next;
    end
	
	assign sum = R1 + R2; 
	
	//output display conditions
    always@(pt)
        begin
        if(pt>=4'b1010) 
            begin           //output when pt > 9
            pt10s=4'b0001; pt1s=pt-4'b1010;
            end
        else
            begin           //output when pt < 9
            pt10s=4'b0000; pt1s=pt;
            end
    end
    
    //state transition logic (only happens in state 2)
    always@(posedge CLK10KHZ)
    begin
        if(state==4'b0010)
            pt<=sum;      //transfer sum to pt in S2
        else pt<=pt;
	end
	
	//output logic
    always@(state,sum,pt10,pt1,dice1,dice2)
    begin
        case(state)
            S0: begin      //initial state
                play=1'b0; win=1'b0; loose=1'b0;
                D0=7'b0110001; //C
                D1=7'b1111010; //r
                D2=7'b0001000; //A
                D3=7'b0011000; //P
                D4=7'b0100100; //S
				D5=7'b1111111; //off
				D6=7'b1111111; //off
				D7=7'b1111111; //off
                end
            S1,S2,S4: begin //rolling states
                play=1'b1; win=1'b0; loose=1'b0;
                D0=7'b1111111; //off
                D1=7'b1111111;
                D2=7'b1111111;
                D3=7'b1111111;
                D4=7'b1111111;
                D5=7'b1111111;
                D6=7'b1111111;
                D7=7'b1111111;
                end
            S3: begin       //checking state
                play=1'b1; win=1'b0; loose=1'b0;
                D0=7'b0011000; //P
                D1=7'b1110000; //t
                    if(pt<4'b1010) D2=7'b1111111;
                    else D2=pt10;
                D3=pt1;
                D4=7'b1111111; //off
                D5=dice1;
                D6=7'b1111111;
                D7=dice2;
                end
            S5,S6,S8: begin       //checking state
                play=1'b1; win=1'b0; loose=1'b0;
                D0=7'b0011000; //P
                D1=7'b1110000; //t
                   if(pt<4'b1010) D2=7'b1111111;
                   else D2=pt10;
                D3=pt1;
                D4=7'b1111111; //off
                D5=dice1;
                D6=7'b1111111;
                D7=dice2;
                end
            S7: begin       //win state
                play=1'b0; win=1'b1; loose=1'b0;
                D0=7'b1000001; //U
                D1=7'b1000001; //U
                D2=7'b1001111; //I
                D3=7'b1101010; //n
				D4=7'b1111111; //off
				D5=7'b1111111; //off
				D6=7'b1111111; //off
				D7=7'b1111111; //off
                end
            S9: begin       //loose state
                play=1'b0; win=1'b0; loose=1'b1;
                D0=7'b1110001; //L
                D1=7'b0000001; //O
				D2=7'b0100100; //S
                D3=7'b0110000; //E
                D4=7'b1111111; //off
				D5=7'b1111111; //off
				D6=7'b1111111; //off
				D7=7'b1111111; //off
                end
            default: begin
                play=1'b0; win=1'b0; loose=1'b0;
                D0=7'b1111111; //off
                D1=7'b1111111;
                D2=7'b1111111;
                D3=7'b1111111;
                D4=7'b1111111;
                D5=7'b1111111;
                D6=7'b1111111;
                D7=7'b1111111;
                end
        endcase
    end 
	
    sSegDisplay_8 display (.ck(CLK100MHZ),.digit0(D0),.digit1(D1),.digit2(D2),.digit3(D3),.digit4(D4),
			.digit5(D5),.digit6(D6),.digit7(D7),.seg(seg),.an(an)); 

endmodule			
	