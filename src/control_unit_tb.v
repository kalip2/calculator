`timescale 1ns / 1ps

module control_unit_test;

  // Signal Declarations
  reg [3:0] button = 4'h0;
  reg is_pressed_next = 0;
  reg clock = 0;
  reg reset = 1;




  // Instantiate Device Under Test (DUT)
  control_unit dut (
      .button(button),
      .is_pressed_next(is_pressed_next),
      .clock(clock),
      .reset(reset)
  );

  // Clock generation (100 MHz)
  always #5 clock = ~clock;

  // Initial block for simulation control
  initial begin
    // Set up VCD file for waveform dump
    $dumpfile("bin/control_unit.vcd");
    $dumpvars;

    // Reset sequence
    #10 reset = 0;

    #10 button = `clear;
    is_pressed_next = 1;

    #10 is_pressed_next = 0;

    #10 button = 4'h8;
    is_pressed_next = 1;
    #10 is_pressed_next = 0;

    #10 button = 4'h9;
    is_pressed_next = 1;
    #10 is_pressed_next = 0;

    #10 button = `clear;
    is_pressed_next = 1;
    #10 is_pressed_next = 0;

    #10 button = 4'h3;
    is_pressed_next = 1;
    #10 is_pressed_next = 0;



    #10 button = `add;
    is_pressed_next = 1;

    #20 is_pressed_next = 0;

    #10 button = 4'h2;
    is_pressed_next = 1;

    #10 is_pressed_next = 0;

    #10 button = `equal;
    is_pressed_next = 1;

    #10 is_pressed_next = 0;

    #10 button = `clear;
    is_pressed_next = 1;

    #10 is_pressed_next = 0;

    #10 button = 4'h7;
    is_pressed_next = 1;
    #10 is_pressed_next = 0;

    #10 button = `div;
    is_pressed_next = 1;
    #10 is_pressed_next = 0;

    #10 button = 4'h4;
    is_pressed_next = 1;
    #10 is_pressed_next = 0;

    #10 button = `equal;
    is_pressed_next = 1;
    #10 is_pressed_next = 0;

    #10 button = `add;
    is_pressed_next = 1;
    #10 is_pressed_next = 0;

    #10 button = 4'h7;
    is_pressed_next = 1;
    #10 is_pressed_next = 0;

    #10 button = `equal;
    is_pressed_next = 1;
    #10 is_pressed_next = 0;


    #10 button = `clear;
    is_pressed_next = 1;
    #10 is_pressed_next = 0;



    // End simulation after a specified time
    #50 $finish;
  end

endmodule
