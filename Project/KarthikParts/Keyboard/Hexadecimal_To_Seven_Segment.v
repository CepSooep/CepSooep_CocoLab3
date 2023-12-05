/******************************************************************************
 *                                                                            *
 * Module:       Hexadecimal_To_Seven_Segment                                 *
 * Description:                                                               *
 *      This module converts hexadecimal numbers for seven segment displays.  *
 *                                                                            *
 ******************************************************************************/

module Hexadecimal_To_Seven_Segment (
	// Inputs
	hex_number,

	// Bidirectional

	// Outputs
	seven_seg_display
);

/*****************************************************************************
 *                           Parameter Declarations                          *
 *****************************************************************************/


/*****************************************************************************
 *                             Port Declarations                             *
 *****************************************************************************/
// Inputs
input		[3:0]	hex_number;

// Bidirectional

// Outputs
output		[6:0]	seven_seg_display;

/*****************************************************************************
 *                 Internal Wires and Registers Declarations                 *
 *****************************************************************************/
// Internal Wires

// Internal Registers

// State Machine Registers

/*****************************************************************************
 *                         Finite State Machine(s)                           *
 *****************************************************************************/


/*****************************************************************************
 *                             Sequential Logic                              *
 *****************************************************************************/


/*****************************************************************************
 *                            Combinational Logic                            *
 *****************************************************************************/

	wire c0, c1, c2, c3; //for the ease of typing (they are not wires)
	assign c0 = hex_number[0];
	assign c1 = hex_number[1];
	assign c2 = hex_number[2];
	assign c3 = hex_number[3];

	wire [6:0] inverted; //I messed up, everything is inverted

	assign inverted[0] = ~c2&~c0 | ~c3&c2&c0 | c2&c1 | c3&~c2&~c1 | c3&~c0 | ~c3&c1;
	assign inverted[1] = ~c3&~c1&~c0 | ~c2&~c1 | ~c2&~c0 | ~c3&c1&c0 | c3&~c1&c0;
	assign inverted[2] = ~c2&~c1 | ~c2&c0 | ~c1&c0 | ~c3&c2 | c3&~c2;
	assign inverted[3] = ~c3&~c2&~c0 | ~c2&c1&c0 | c2&~c1&c0 | c2&c1&~c0 | c3&~c1;
	assign inverted[4] = ~c2&~c0 | c1&~c0 | c3&c1 |c3&c2;
	assign inverted[5] = ~c1&~c0 | ~c3&c2&~c1 | c2&~c0 | c3&~c2 | c3&c1;
	assign inverted[6] = ~c2&c1 | c1&~c0 | ~c3&c2&~c1 | c3&~c2 | c3&c0;
	
	assign seven_seg_display = ~inverted;

/*****************************************************************************
 *                              Internal Modules                             *
 *****************************************************************************/


endmodule

