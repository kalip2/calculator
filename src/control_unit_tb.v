`timescale 1ns / 1ps

module control_unit_test;

  // Testbench Signals
  reg [3:0] button = 4'h0;
  reg is_pressed_next = 0;
  reg clock = 0;
  reg reset = 1;// we need to remove this so that the control unit always initilizes to the "initial state" when powered

  // Instantiate Device Under Test (DUT)
  control_unit dut (
      .button(button),
      .is_pressed_next(is_pressed_next),
      .clock(clock),
      .reset(reset)
  );

  // Clock generation (100 MHz)
  always #5 clock = ~clock;

  // Function to simulate button press
  task press_button;
    input [3:0] btn;
    begin
      #10 button = btn;
      is_pressed_next = 1;
      #10 is_pressed_next = 0;  // Mimic button press duration
    end
  endtask

  // Initial block for simulation control
  initial begin
    // Setup waveform dump
    $dumpfile("bin/control_unit.vcd");
    $dumpvars;

    // Reset the DUT
    #10 reset = 0;

    // press_button(`CLEAR);
    // press_button(`EIGHT);
    // press_button(`NINE);

    // press_button(`CLEAR);
    // press_button(`THREE);
    // press_button(`ADD_DIV);
    // press_button(`TWO);
    // press_button(`EQUAL);

    // press_button(`CLEAR);
    // press_button(`SEVEN);
    // press_button(`ADD_DIV);
    // press_button(`FOUR);
    // press_button(`EQUAL);

    // press_button(`ADD_DIV);
    // press_button(`SEVEN);
    // press_button(`EQUAL);
    // press_button(`CLEAR);




    // pos + pos
    // 9 + 7 = 16
    press_button(`NINE);
    press_button(`ADD_DIV);
    press_button(`SEVEN);
    press_button(`EQUAL);
    press_button(`CLEAR);


    // pos + neg 
    // 9 + -7 = 2
    press_button(`NINE);
    press_button(`ADD_DIV);
    press_button(`SEVEN);
    press_button(`TOGGLE);
    press_button(`MUL_NEG);
    press_button(`EQUAL);
    press_button(`CLEAR);

    // neg + neg
    // -9 + -7 = -16
    press_button(`NINE);
    press_button(`TOGGLE);
    press_button(`MUL_NEG);
    press_button(`ADD_DIV);
    press_button(`SEVEN);
    press_button(`TOGGLE);
    press_button(`MUL_NEG);
    press_button(`EQUAL);
    press_button(`CLEAR);

    // neg + pos
    // -9 + 7 = -2
    press_button(`NINE);
    press_button(`TOGGLE);
    press_button(`MUL_NEG);
    press_button(`ADD_DIV);
    press_button(`SEVEN);
    press_button(`EQUAL);
    press_button(`CLEAR);

    // pos - pos
    // 9 - 7 = 2
    press_button(`NINE);
    press_button(`SUB_DEC);
    press_button(`SEVEN);
    press_button(`EQUAL);
    press_button(`CLEAR);

    // pos - neg
    // 9 - -7 = 16
    press_button(`NINE);
    press_button(`SUB_DEC);
    press_button(`SEVEN);
    press_button(`TOGGLE);
    press_button(`MUL_NEG);
    press_button(`EQUAL);
    press_button(`CLEAR);


    // neg - neg
    // -9 - -7 = -2
    press_button(`NINE);
    press_button(`TOGGLE);
    press_button(`MUL_NEG);
    press_button(`SUB_DEC);
    press_button(`SEVEN);
    press_button(`TOGGLE);
    press_button(`MUL_NEG);
    press_button(`EQUAL);
    press_button(`CLEAR);

    // neg - pos
    // -9 - 7 = -16
    press_button(`NINE);
    press_button(`TOGGLE);
    press_button(`MUL_NEG);
    press_button(`SUB_DEC);
    press_button(`SEVEN);
    press_button(`EQUAL);
    press_button(`CLEAR);


    // pos * pos
    // 9 * 7 = 63
    press_button(`NINE);
    press_button(`MUL_NEG);
    press_button(`SEVEN);
    press_button(`EQUAL);
    press_button(`CLEAR);

    // pos * neg
    // 9 * -7 = -63
    press_button(`NINE);
    press_button(`MUL_NEG);
    press_button(`SEVEN);
    press_button(`TOGGLE);
    press_button(`MUL_NEG);
    press_button(`EQUAL);
    press_button(`CLEAR);

    // neg * neg
    // -9 * -7 = 63
    press_button(`NINE);
    press_button(`TOGGLE);
    press_button(`MUL_NEG);
    press_button(`MUL_NEG);
    press_button(`SEVEN);
    press_button(`TOGGLE);
    press_button(`MUL_NEG);
    press_button(`EQUAL);
    press_button(`CLEAR);

    // neg * pos
    // -9 * 7 = -63
    press_button(`NINE);
    press_button(`TOGGLE);
    press_button(`MUL_NEG);
    press_button(`MUL_NEG);
    press_button(`SEVEN);
    press_button(`EQUAL);
    press_button(`CLEAR);

    // pos / pos
    // 9 / 7 = 1
    press_button(`NINE);
    press_button(`TOGGLE);
    press_button(`ADD_DIV);
    press_button(`SEVEN);
    press_button(`EQUAL);
    press_button(`CLEAR);

    // pos / neg
    // 9 / -7 = -1
    press_button(`NINE);
    press_button(`TOGGLE);
    press_button(`ADD_DIV);
    press_button(`SEVEN);
    press_button(`TOGGLE);
    press_button(`MUL_NEG);
    press_button(`EQUAL);
    press_button(`CLEAR);

    // neg / neg
    // -9 / -7 = 1
    press_button(`NINE);
    press_button(`TOGGLE);
    press_button(`MUL_NEG);
    press_button(`TOGGLE);
    press_button(`ADD_DIV);
    press_button(`SEVEN);
    press_button(`TOGGLE);
    press_button(`MUL_NEG);
    press_button(`EQUAL);
    press_button(`CLEAR);

    // neg / pos
    // -9 / 7 = -1
    press_button(`NINE);
    press_button(`TOGGLE);
    press_button(`MUL_NEG);
    press_button(`TOGGLE);
    press_button(`ADD_DIV);
    press_button(`SEVEN);
    press_button(`EQUAL);
    press_button(`CLEAR);


    #10 reset = 1;
    // End simulation after a specified time
    #50 $finish;
  end

endmodule
