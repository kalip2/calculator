`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////////////////////////////
// Company: Digilent Inc 2011
// Engineer: Michelle Yu  
//				 Josh Sackos
// Create Date:    17:05:39 08/23/2011 
//
// Module Name:    calc
// Project Name:   calculator
// Target Devices: Basys3
// Tool versions:  Xilinx ISE 14.1 
// Description: This file defines a project that outputs the key pressed on the PmodKYPD to the 
//					 seven segment display.
//
// Revision History: 
// 						Revision 0.01 - File Created (Michelle Yu)
//							Revision 0.01 - Converted from VHDL to Verilog (Josh Sackos)
//////////////////////////////////////////////////////////////////////////////////////////////////////////

// ==============================================================================================
// 												Define Module
// ==============================================================================================
module calc(
    clk,
    JC,
	btnC,
	sw,
    an,
    seg,
	led,
	dp
    );
	 
	 
// ==============================================================================================
// 											Port Declarations
// ==============================================================================================
	input clk;					// 100Mhz onboard clock
	inout [7:0] JC;			// Port JA on Basys3, JA[3:0] is Columns, JA[7:4] is rows
	input btnC;
	input [15:0] sw;
	output [3:0] an;			// Anodes on seven segment display
	output [6:0] seg;			// Cathodes on seven segment display
	output [15:0] led;
	output dp;

// ==============================================================================================
// 							  		Parameters, Regsiters, and Wires
// ==============================================================================================
	
	// Output wires
	wire [3:0] an;
	wire [6:0] seg;
	
	wire [3:0] Decode;
	wire       currentlyPressed;
	wire [3:0] digitToDisplay;
	wire       firstOrSecond;
	wire       negative;
	wire signed [31:0]      operandF;
	wire signed [31:0]      operandS;
	wire signed [31:0]      operandToDisplay = firstOrSecond ? operandS : operandF;
	wire [31:0]      absOperandToDisplay = (operandToDisplay > 0) ? operandToDisplay : -operandToDisplay;
	wire [3:0] digit0 = absOperandToDisplay % 10;
	wire [3:0] digit1 = (absOperandToDisplay / 10) % 10;
	wire [3:0] digit2 = (absOperandToDisplay / 100) % 10;
	wire [3:0] digit3 = (absOperandToDisplay / 1000) % 10;
	wire [3:0] digit4 = (absOperandToDisplay / 10000) % 10;
	wire [3:0] digit5 = (absOperandToDisplay / 100000) % 10;
	wire [3:0] digit6 = (absOperandToDisplay / 1000000) % 10;
	wire [3:0] digit7 = (absOperandToDisplay / 10000000) % 10;
	wire       displayNegative = negative | (operandToDisplay < 0);
	assign       led[15] = displayNegative;

// ==============================================================================================
// 												Implementation
// ==============================================================================================

	//-----------------------------------------------
	//  						Decoder
	//-----------------------------------------------
	Decoder C0(
			.clk(clk),
			.Row(JC[7:4]),
			.Col(JC[3:0]),
			.DecodeOut(Decode),
			.currentlyPressed(currentlyPressed)
	);

	//-----------------------------------------------
	//  		Seven Segment Display Controller
	//-----------------------------------------------
	DisplayController C1(
			.DispVal(digitToDisplay),
			.anode(),
			.segOut(seg)
	);

	DisplayRotator C2(
			.clk(clk),
			.digit0(digit0),
			.digit1(digit1),
			.digit2(digit2),
			.digit3(digit3),
			.digit4(digit4),
			.digit5(digit5),
			.digit6(digit6),
			.digit7(digit7),
			.displayUpper(sw[0]),
			.dpEnable(dp),
			.an(an),
			.digitToDisplay(digitToDisplay)
	);

    control_unit C3(
		.display(firstOrSecond),
		.operandF(operandF),     // First operand
		.operandS(operandS),     // Second operand
		.toggle(led[0]),
		.negative(negative),
		.button(Decode),           // User input button (0-9, +, -, *, /, =)
		.is_pressed_next(currentlyPressed),  // Button press signal
		.clock(clk),            // Clock signal
		.reset(btnC)            // Reset signal
	);

endmodule
