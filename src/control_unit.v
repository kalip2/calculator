// Define operation codes
`define ZERO 4'h0
`define ONE 4'h1
`define TWO 4'h2
`define THREE 4'h3
`define FOUR 4'h4
`define FIVE 4'h5
`define SIX 4'h6
`define SEVEN 4'h7
`define EIGHT 4'h8
`define NINE 4'h9
`define ADD_DIV 4'hA
`define SUB_DEC 4'hB
`define MUL_NEG 4'hC
`define TOGGLE 4'hD
`define EQUAL 4'hE
`define CLEAR 4'hF

/*
is_toggled 
is_toggled 
*/


//

module control_unit (
    output                   display,          // OLED Display output
    output reg signed [63:0] operandF = 0,     // First operand
    output reg signed [63:0] operandS = 0,     // Second operand
    input             [ 3:0] button,           // User input button (0-9, +, -, *, /, =)
    input                    is_pressed_next,  // Button press signal
    input                    clock,            // Clock signal
    input                    reset             // Reset signal
);

  reg [1:0] alu_op = 0;  // ALU operation state (0: +, 1: -, 2: *, 3: /)

  // State outputs
  reg s_initial, s_operandF, s_operation, s_operandS, s_result;
  reg is_pressed = 0;  // Initialize because it broke under Ryan
  reg toggle = 0;
  reg negative = 0;
  reg decimal = 0;



  // Next state inputs
  wire next_initial, next_operandF, next_operation, next_operandS, next_result;


  wire button_pressed = (is_pressed == 0 && is_pressed_next == 1);
  wire is_symbol = button_pressed && ((button == `SUB_DEC && toggle) || (button == `MUL_NEG && toggle));
  wire is_number = button_pressed && ((button >= `ZERO && button <= `NINE));
  wire is_equal = button_pressed && (button == `EQUAL);
  wire is_op = button_pressed && (button == `ADD_DIV || (button == `SUB_DEC && ~toggle)  ||  ( button == `MUL_NEG && ~toggle));
  wire is_clear = button_pressed && (button == `CLEAR);
  wire is_toggled = button_pressed && (button == `TOGGLE);

  always @(posedge clock or posedge reset) begin
    if (reset) begin
      s_initial <= 1;
      s_operandF <= 0;
      s_operation <= 0;
      s_operandS <= 0;
      s_result <= 0;
      is_pressed <= 0;
      toggle <= 0;
      negative <= 0;
      decimal <= 0;
    end else begin
      s_initial <= next_initial;
      s_operandF <= next_operandF;
      s_operation <= next_operation;
      s_operandS <= next_operandS;
      s_result <= next_result;
      is_pressed <= is_pressed_next;
    end
  end

  assign next_initial = reset || is_clear || (is_equal && s_initial) || 
                                             (is_op && s_initial) || 
                                             (~button_pressed && s_initial) || 
                                             (s_initial && is_toggled || s_initial && is_symbol);
  assign next_operandF = ((is_number && s_initial) || 
                          (is_number && s_operandF) || 
                          (is_equal && s_operandF) || 
                          (~button_pressed && s_operandF) || 
                          (s_operandF && is_toggled || s_operandF && is_symbol)) && ~reset;
  assign next_operation = ((is_op && s_operandF) || 
                           (is_op && s_operation) || 
                           (is_equal && s_operation) || 
                           (is_op && s_result) || 
                           (~button_pressed && s_operation) || 
                           (s_operation && is_toggled || s_operation && is_symbol)) && ~reset;
  assign next_operandS =  ((is_number && s_operation) || 
                           (is_number && s_operandS) || 
                           (is_op && s_operandS) || 
                           (~button_pressed && s_operandS) || 
                           (s_operandS && is_toggled || s_operandS && is_symbol)) && ~reset;
  assign next_result = ((is_equal && s_operandS) || 
                        (is_equal && s_result) || 
                        (is_number && s_result) || 
                        (~button_pressed & s_result) || 
                        (s_result && is_toggled || s_result && is_symbol)) && ~reset;

  localparam fixed_point_length = 2;
  always @(posedge clock) begin
    if (s_initial && is_number) begin
      operandF = button * 10 ** fixed_point_length;
    end else if (s_operandF && is_number) begin
      if (decimal) begin
        operandF = operandF + button * 10 ** (fixed_point_length - decimal);
      end else begin
        operandF = operandF * 10 + button * 10 ** fixed_point_length;
      end
    end else if ((s_initial || s_operandF) && toggle && (button == `MUL_NEG)) begin
      negative = ~negative;
      toggle   = 0;
    end else if ((s_operandF || s_result) && is_op) begin
      if (button == `ADD_DIV && toggle == 0) begin
        alu_op = 0;
        if (negative) begin
          operandF = -operandF;
          negative = 0;
          decimal  = 0;
        end
      end else if (button == `SUB_DEC && toggle == 0) begin
        alu_op = 1;
        if (negative) begin
          operandF = -operandF;
          negative = 0;
          decimal  = 0;
        end
      end else if (button == `MUL_NEG && toggle == 0) begin
        alu_op = 2;
        if (negative) begin
          operandF = -operandF;
          negative = 0;
          decimal  = 0;
        end
      end else if (button == `ADD_DIV && toggle == 1) begin
        alu_op = 3;
        if (negative) begin
          operandF = -operandF;
          negative = 0;
          decimal  = 0;
        end
      end
      toggle = 0;
    end else if (s_operation && is_number) begin
      operandS = button;
    end else if (s_operandS && is_number) begin
      operandS = operandS * 10 + button;
    end else if ((s_operation || s_operandS) && toggle && (button == `MUL_NEG)) begin
      negative = ~negative;
      toggle   = 0;
    end else if (s_operandS && is_equal) begin
      if (negative) begin
        operandS = -operandS;
        negative = 0;
        decimal  = 0;
      end
      case (alu_op)
        0: operandF = operandF + operandS;
        1: operandF = operandF - operandS;
        2: operandF = operandF * operandS;
        3: operandF = operandF / operandS;
      endcase
      operandS = 0;
      alu_op   = 0;
      toggle   = 0;
      negative = 0;
      decimal  = 0;
    end else if (is_clear) begin
      operandF = 0;
      operandS = 0;
      alu_op   = 0;
      toggle   = 0;
      negative = 0;
      decimal  = 0;
    end else if (is_toggled) begin
      toggle = ~toggle;
    end
  end

  assign display = s_operandS;

endmodule
