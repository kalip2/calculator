`define add 4'hA
`define sub 4'hB
`define mul 4'hC
`define div 4'hD
`define equal 4'hE
`define clear 4'hF

module control_unit (
    output display,  //! OLED Display
    output reg [31:0] operandF = 0,
    output reg [31:0] operandS = 0,
    input [3:0] button,  //! The button pressed by the user (0-9, +, -, *, /, =)
    input is_pressed_next,  // When the user presses a button    
    input clock,  // positive edge
    input reset  // When we initialize the calculator and reset
);

  // operandF = 0;  //! The first number shown on the display
  // operandS = 0;  //! The second number shown on the display
  reg [1:0] alu_op = 0;  //! state 0 = +, state 1 = -, state 2 = *, state 3 = /

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
  wire button_pressed = (is_pressed == 0 & is_pressed_next == 1);

  wire is_number = button_pressed & (button >= 4'h0 && button <= 4'h9);
  wire is_equal = button_pressed & (button == `equal);
  wire is_op = button_pressed & (button == `add | button == `sub | button == `mul | button == `div);
  wire is_clear = button_pressed & (button == `clear);
  wire is_pressed;
  // if state is initial or operandF, 

  always @(posedge clock) begin
    if (s_initial && is_number) begin
      operandF = button;
    end else if (s_operandF && is_number) begin
      operandF = operandF * 10 + button;
    end else if ((s_operandF || s_result) && is_op) begin
      if (button == `add) begin
        alu_op = 0;
      end else if (button == `sub) begin
        alu_op = 1;
      end else if (button == `mul) begin
        alu_op = 2;
      end else if (button == `div) begin
        alu_op = 3;
      end
    end else if (s_operation && is_number) begin
      operandS = button;
    end else if (s_operandS && is_number) begin
      operandS = operandS * 10 + button;
    end else if (s_operandS && is_equal) begin
      if (alu_op == 0) begin
        operandF = operandF + operandS;
      end else if (alu_op == 1) begin
        operandF = operandF - operandS;
      end else if (alu_op == 2) begin
        operandF = operandF * operandS;
      end else if (alu_op == 3) begin
        operandF = operandF / operandS;
      end
      operandS = 0;
      alu_op   = 0;
    end else if (is_clear) begin
      operandF = 0;
      operandS = 0;
      alu_op   = 0;
    end
  end

  assign display = s_operandS;

  dffe is_pressed_state (
      is_pressed,
      is_pressed_next,
      clock,
      1'b1,
      1'b0
  );  // 1 clock interval delay between button presses

  assign next_initial = reset | is_clear | (is_equal && s_initial) | (is_op && s_initial) | (~button_pressed & s_initial);
  assign next_operandF = ((is_number && s_initial) | (is_number && s_operandF) | (is_equal && s_operandF) | (~button_pressed & s_operandF)) && ~reset;
  assign next_operation = ((is_op && s_operandF) | (is_op && s_operation) | (is_equal && s_operation) | (is_op && s_result) | (~button_pressed & s_operation)) && ~reset;
  assign next_operandS =  ((is_number && s_operation)  | (is_number && s_operandS) | (is_op && s_operandS) | (~button_pressed & s_operandS) ) && ~reset;
  assign next_result = ((is_equal && s_operandS) | (is_equal && s_result) | (is_number && s_result) | (~button_pressed & s_result)) && ~reset;


  // One hot encoding
  dffe fsInitial (
      s_initial,
      next_initial,
      clock,
      1'b1,
      1'b0
  );

  dffe fsOperandF (
      s_operandF,
      next_operandF,
      clock,
      1'b1,
      1'b0
  );

  dffe fsOperation (
      s_operation,
      next_operation,
      clock,
      1'b1,
      1'b0
  );

  dffe fsOperandS (
      s_operandS,
      next_operandS,
      clock,
      1'b1,
      1'b0
  );

  dffe fsResult (
      s_result,
      next_result,
      clock,
      1'b1,
      1'b0
  );




endmodule
