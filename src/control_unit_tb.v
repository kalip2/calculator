`timescale 1ns / 1ps

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


    // 2.5 + 3.5
    press_button(`TWO);
    press_button(`TOGGLE);
    press_button(`SUB_DEC);
    press_button(`FIVE);
    press_button(`ADD_DIV);
    press_button(`THREE);
    press_button(`TOGGLE);
    press_button(`SUB_DEC);
    press_button(`FIVE);
    press_button(`EQUAL);
    press_button(`CLEAR);

    // .9 + .7
    press_button(`TOGGLE);
    press_button(`SUB_DEC);
    press_button(`NINE);
    press_button(`ADD_DIV);
    press_button(`TOGGLE);
    press_button(`SUB_DEC);
    press_button(`SEVEN);
    press_button(`EQUAL);
    press_button(`CLEAR);

    // .09 + .07
    press_button(`TOGGLE);
    press_button(`SUB_DEC);
    press_button(`ZERO);
    press_button(`NINE);
    press_button(`ADD_DIV);
    press_button(`TOGGLE);
    press_button(`SUB_DEC);
    press_button(`ZERO);
    press_button(`SEVEN);
    press_button(`EQUAL);
    press_button(`CLEAR);

    // .09 + 4.93 - 5.01
    press_button(`TOGGLE);
    press_button(`SUB_DEC);
    press_button(`ZERO);
    press_button(`NINE);
    press_button(`ADD_DIV);
    press_button(`FOUR);
    press_button(`TOGGLE);
    press_button(`SUB_DEC);
    press_button(`NINE);
    press_button(`THREE);
    press_button(`EQUAL);
    press_button(`SUB_DEC);
    press_button(`FIVE);
    press_button(`TOGGLE);
    press_button(`SUB_DEC);
    press_button(`ZERO);
    press_button(`ONE);
    press_button(`EQUAL);
    press_button(`CLEAR);

    // 5.09 * 1.25
    press_button(`FIVE);
    press_button(`TOGGLE);
    press_button(`SUB_DEC);
    press_button(`ZERO);
    press_button(`NINE);
    press_button(`MUL_NEG);
    press_button(`ONE);
    press_button(`TOGGLE);
    press_button(`SUB_DEC);
    press_button(`TWO);
    press_button(`FIVE);
    press_button(`EQUAL);
    press_button(`CLEAR);

    // -5.09 / 1.25
    press_button(`TOGGLE);
    press_button(`MUL_NEG);
    press_button(`FIVE);
    press_button(`TOGGLE);
    press_button(`SUB_DEC);
    press_button(`ZERO);
    press_button(`NINE);
    press_button(`TOGGLE);
    press_button(`ADD_DIV);
    press_button(`ONE);
    press_button(`TOGGLE);
    press_button(`SUB_DEC);
    press_button(`TWO);
    press_button(`FIVE);
    press_button(`EQUAL);
    press_button(`CLEAR);

    //-.09 / 1.25
    press_button(`TOGGLE);
    press_button(`MUL_NEG);
    press_button(`TOGGLE);
    press_button(`SUB_DEC);
    press_button(`ZERO);
    press_button(`NINE);
    press_button(`TOGGLE);
    press_button(`ADD_DIV);
    press_button(`ONE);
    press_button(`TOGGLE);
    press_button(`SUB_DEC);
    press_button(`TWO);
    press_button(`FIVE);
    press_button(`EQUAL);
    press_button(`CLEAR);

    // 5+3 = 8 -> MEM
    // CLEAR
    // 2 + 5 = 7
    // MEM -> 8 + 4 = 12
    // MEM_CLEAR = 0
    // MEM -> 0 + 4 = 4
    press_button(`FIVE);
    press_button(`ADD_DIV);
    press_button(`THREE);
    press_button(`EQUAL);
    press_button(`TOGGLE);
    press_button(`MEM_STORE);
    press_button(`CLEAR);
    press_button(`TWO);
    press_button(`ADD_DIV);
    press_button(`FIVE);
    press_button(`EQUAL);
    press_button(`CLEAR);
    press_button(`TOGGLE);
    press_button(`MEM_LOAD);
    press_button(`ADD_DIV);
    press_button(`FOUR);
    press_button(`EQUAL);
    press_button(`CLEAR);
    press_button(`TOGGLE);
    press_button(`MEM_CLEAR);
    press_button(`TOGGLE);
    press_button(`MEM_LOAD);
    press_button(`ADD_DIV);
    press_button(`FOUR);
    press_button(`EQUAL);
    press_button(`CLEAR);

    #10 reset = 1;
    // End simulation after a specified time
    #50 $finish;
  end

endmodule
