// Define operation codes
`define ZERO 4'h0
`define ONE 4'h1
`define TWO 4'h2
`define THREE 4'h3
`define MEM_STORE 4'h1
`define MEM_LOAD 4'h2
`define MEM_CLEAR 4'h3
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

module control_unit (
    output                   display,          // OLED Display output
    output reg signed [31:0] operandF = 0,     // First operand
    output reg signed [31:0] operandS = 0,     // Second operand
    output reg               toggle = 0,
    output reg               negative = 0,
    input             [ 3:0] button,           // User input button (0-9, +, -, *, /, =)
    input                    is_pressed_next,  // Button press signal
    input                    clock,            // Clock signal
    input                    reset             // Reset signal
);

  reg [1:0] alu_op = 0;  // ALU operation state (0: +, 1: -, 2: *, 3: /)

  // State outputs
  reg s_initial, s_operandF, s_operation, s_operandS, s_result;
  reg is_pressed = 0;  // Initialize because it broke under Ryan
  reg [1:0] decimal = 0;
  reg signed [31:0] stored_value = 0;
  reg stored_negative = 0;

  localparam fixed_point_length = 2;
  // Vivado does not support exponentiation :((((
  // Workaround:
  localparam fixed_point_multiplier = 100; // 10^fixed_point_length

  reg [31:0] current_multiplier = fixed_point_multiplier / 10; //10^(fixed_point_length - decimal)

  // Next state inputs
  wire next_initial, next_operandF, next_operation, next_operandS, next_result;


  wire button_pressed = (is_pressed == 0 && is_pressed_next == 1);
  wire is_symbol = button_pressed && ((button == `SUB_DEC && toggle) || (button == `MUL_NEG && toggle));
  wire is_number = button_pressed && ((button >= `ZERO && button <= `NINE) && ~toggle);
  wire is_equal = button_pressed && (button == `EQUAL);
  wire is_op = button_pressed && (button == `ADD_DIV || (button == `SUB_DEC && ~toggle)  ||  ( button == `MUL_NEG && ~toggle));
  wire is_clear = button_pressed && (button == `CLEAR);
  wire is_toggled = button_pressed && (button == `TOGGLE);
  wire is_mem_op = button_pressed && toggle && (button == `MEM_STORE || button == `MEM_LOAD || button == `MEM_CLEAR);

  // always @(posedge clock or posedge reset) begin
  //   if (reset) begin
  //     s_initial = 1;
  //     s_operandF = 0;
  //     s_operation = 0;
  //     s_operandS = 0;
  //     s_result = 0;
  //     is_pressed = 0;
  //     toggle = 0;
  //     negative = 0;
  //     decimal = 0;
  //     stored_value = 0;
  //     current_multiplier = fixed_point_multiplier / 10;
  //   end else begin
  //     s_initial = next_initial;
  //     s_operandF = next_operandF;
  //     s_operation = next_operation;
  //     s_operandS = next_operandS;
  //     s_result = next_result;
  //     is_pressed = is_pressed_next;
  //   end
  // end

  assign next_initial = reset || is_clear || (is_equal && s_initial) || 
                                             (is_op && s_initial) || 
                                             (~button_pressed && s_initial) || 
                                             (s_initial && is_toggled);
  assign next_operandF = ((is_number && s_initial) || 
                          (is_number && s_operandF) || 
                          (is_equal && s_operandF) || 
                          (~button_pressed && s_operandF) || 
                          (s_operandF && is_toggled) || 
                          (s_initial && is_symbol) ||
                          (s_operandF && is_symbol) || 
                          (s_initial && is_mem_op) || 
                          (s_operandF && is_mem_op)) && ~reset;
  assign next_operation = ((is_op && s_operandF) || 
                           (is_op && s_operation) || 
                           (is_equal && s_operation) || 
                           (is_op && s_result) || 
                           (~button_pressed && s_operation) || 
                           (s_operation && is_toggled)) && ~reset;
  assign next_operandS =  ((is_number && s_operation) || 
                           (is_number && s_operandS) || 
                           (is_op && s_operandS) || 
                           (~button_pressed && s_operandS) || 
                           (s_operandS && is_toggled) || 
                           (s_operation && is_symbol) ||
                           (s_operandS && is_symbol) || 
                           (s_operation && is_mem_op) ||
                           (s_operandS && is_mem_op)) && ~reset;
  assign next_result = ((is_equal && s_operandS) || 
                        (is_equal && s_result) || 
                        (is_number && s_result) || 
                        (~button_pressed & s_result) || 
                        (s_result && is_toggled) || 
                        (s_result && is_symbol) ||
                        (s_result && is_mem_op)) && ~reset;


  always @(posedge clock) begin
    if (reset) begin
      s_initial = 1;
      s_operandF = 0;
      s_operation = 0;
      s_operandS = 0;
      s_result = 0;
      is_pressed = 0;
      toggle = 0;
      negative = 0;
      decimal = 0;
      stored_value = 0;
      current_multiplier = fixed_point_multiplier / 10;
    end else begin
      if (s_initial && is_number) begin
        operandF = button * fixed_point_multiplier;
      end else if (is_toggled) begin
        toggle = ~toggle;
      end else if (s_operandF && is_number) begin
        if (decimal) begin
          operandF = operandF + button * current_multiplier;
          decimal  = decimal + 1;
          current_multiplier = current_multiplier / 10;
        end else begin
          operandF = operandF * 10 + button * fixed_point_multiplier;
        end
      end else if ((s_initial || s_operandF) && toggle && is_symbol && (button == `MUL_NEG)) begin
        negative = ~negative;
        toggle   = 0;
      end else if ((s_initial || s_operandF) && toggle && is_symbol && (button == `SUB_DEC)) begin
        if (decimal == 0) begin
          decimal = 1;
          current_multiplier = fixed_point_multiplier / 10;
        end
        toggle = 0;
      end else if ((s_initial || s_operandF) && toggle && is_mem_op && button == `MEM_LOAD) begin
        operandF = stored_value;
        negative = stored_negative;
        decimal  = fixed_point_length + 1;
        current_multiplier = 0;
        toggle   = 0;
      end else if ((s_operandF || s_result) && is_op) begin
        if (button == `ADD_DIV && toggle == 0) begin
          alu_op = 0;
          if (negative) begin
            operandF = -operandF;
            negative = 0;
          end
          decimal = 0;
          current_multiplier = fixed_point_multiplier / 10;
        end else if (button == `SUB_DEC && toggle == 0) begin
          alu_op = 1;
          if (negative) begin
            operandF = -operandF;
            negative = 0;
          end
          decimal = 0;
          current_multiplier = fixed_point_multiplier / 10;
        end else if (button == `MUL_NEG && toggle == 0) begin
          alu_op = 2;
          if (negative) begin
            operandF = -operandF;
            negative = 0;
          end
          decimal = 0;
          current_multiplier = fixed_point_multiplier / 10;
        end else if (button == `ADD_DIV && toggle == 1) begin
          alu_op = 3;
          if (negative) begin
            operandF = -operandF;
            negative = 0;
          end
          decimal = 0;
          current_multiplier = fixed_point_multiplier / 10;
        end
        toggle = 0;
      end else if (s_operation && is_number) begin
        operandS = button * fixed_point_multiplier;
      end else if (s_operandS && is_number) begin
        if (decimal) begin
          operandS = operandS + button * current_multiplier;
          decimal  = decimal + 1;
          current_multiplier = current_multiplier / 10;
        end else begin
          operandS = operandS * 10 + button * fixed_point_multiplier;
        end
      end else if ((s_operation || s_operandS) && toggle && is_symbol && (button == `MUL_NEG)) begin
        negative = ~negative;
        toggle   = 0;
      end else if ((s_operation || s_operandS) && toggle && is_symbol && (button == `SUB_DEC)) begin
        if (decimal == 0) begin
          decimal = 1;
          current_multiplier = fixed_point_multiplier / 10;
        end
        toggle = 0;
      end else if ((s_operation || s_operandS) && toggle && is_mem_op && button == `MEM_LOAD) begin
        operandS = stored_value;
        negative = stored_negative;
        decimal  = fixed_point_length + 1;
        current_multiplier = 0;
        toggle   = 0;
      end else if (s_operandS && is_equal) begin
        if (negative) begin
          operandS = -operandS;
          negative = 0;
          decimal  = 0;
          current_multiplier = fixed_point_multiplier / 10;
        end
        case (alu_op)
          0: operandF = operandF + operandS;
          1: operandF = operandF - operandS;
          2: operandF = (operandF * operandS) / (fixed_point_multiplier);
          3: operandF = (operandF * (fixed_point_multiplier) / operandS);
        endcase
        operandS = 0;
        alu_op   = 0;
        toggle   = 0;
        negative = 0;
        decimal  = 0;
        current_multiplier = fixed_point_multiplier / 10;
      end else if (s_result && toggle && is_mem_op && button == `MEM_STORE) begin
        stored_value = operandF;
        if (operandF < 0) begin
          stored_value = -stored_value;
        end
        stored_negative = (operandF < 0);
        toggle = 0;
      end else if (is_clear) begin
        operandF = 0;
        operandS = 0;
        alu_op   = 0;
        toggle   = 0;
        negative = 0;
        decimal  = 0;
        current_multiplier = fixed_point_multiplier / 10;
      end else if (toggle && is_mem_op && button == `MEM_CLEAR) begin
        stored_value = 0;
        stored_negative = 0;
        toggle = 0;
      end
      s_initial = next_initial;
      s_operandF = next_operandF;
      s_operation = next_operation;
      s_operandS = next_operandS;
      s_result = next_result;
      is_pressed = is_pressed_next;
    end
  end

  assign display = s_operandS;

endmodule
