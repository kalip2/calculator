`define add 4'hA
`define sub 4'hB
`define mul 4'hC
`define div 4'hD
`define equal 4'hE
`define clear 4'hF

module control_unit (
    output display,  //! OLED Display
    input [3:0] button,  //! The button pressed by the user (0-9, +, -, *, /, =)
    input is_pressed_next,  // When the user presses a button    
    input clock,  // positive edge
    input reset  // When we initialize the calculator and reset


);

  reg [31:0] operandF;  //! The first number shown on the display
  reg [31:0] operandS;  //! The second number shown on the display
  reg alu_op;  //! state 0 = +, state 1 = -, state 2 = *, state 3 = /

  // output of the DFFE's state
  wire s_initial;  // state 0
  wire s_operandF;  // state 1
  wire s_operation;  // state 2
  wire s_operandS;  // state 3
  wire s_result;  // state 4

  // input of the DFFE's next state
  wire next_initial;
  wire next_operandF;
  wire next_operation;
  wire next_operandS;
  wire next_result;

  wire is_number = (is_pressed == 0 & is_pressed_next == 1) & (button == 4'h0 | button == 4'h1 | button == 4'h2 | button == 4'h3 | button == 4'h4 | button == 4'h5 | button == 4'h6 | button == 4'h7 | button == 4'h8 | button == 4'h9);
  wire is_equal = (is_pressed == 0 & is_pressed_next == 1) & (button == `equal);
  wire is_op = (is_pressed == 0 & is_pressed_next == 1) & (button == `add | button == `sub | button == `mul | button == `div);
  wire is_clear = (is_pressed == 0 & is_pressed_next == 1) & (button == `clear);
  wire is_pressed;
  dffe is_pressed_state (
      is_pressed,
      is_pressed_next,
      clock,
      1'b0,
      1'b1
  );  // 1 clock interval delay between button presses

  assign next_initial = reset | is_clear | (is_equal && s_initial) | (is_op && s_initial) | (~is_pressed_next & s_initial);
  assign next_operandF = ((is_number && s_initial) | (is_number && s_operandF) | (is_equal && s_operandF) | (~is_pressed_next & s_operandF)) && ~reset;
  assign next_operation = ((is_op && s_operandF) | (is_op && s_operation) | (is_equal && s_operation) | (is_op && s_result) | (~is_pressed_next & s_operation)) && ~reset;
  assign next_operandS =  ((is_number && s_operation)  | (is_number && s_operandS) | (is_op && s_operandS) | (~is_pressed_next & s_operandS) ) && ~reset;
  assign next_result = ((is_equal && s_operandS) | (is_equal && s_result) | (is_number && s_result) | (~is_pressed_next & s_result)) && ~reset;


  // One hot encoding
  dffe fsInitial (
      s_initial,
      next_initial,
      clock,
      1'b0,
      1'b1
  );
  dffe fsOperandF (
      s_operandF,
      next_operandF,
      clock,
      1'b0,
      1'b1
  );
  dffe fsOperation (
      s_operation,
      next_operation,
      clock,
      1'b0,
      1'b1
  );
  dffe fsOperandS (
      s_operandS,
      next_operandS,
      clock,
      1'b0,
      1'b1
  );
  dffe fsResult (
      s_result,
      next_result,
      clock,
      1'b0,
      1'b1
  );




endmodule
