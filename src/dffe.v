/*
 * D Flip-Flop w/ enable that can store a single bit of information.
 *
 * Usage
 * dffe bit0(q[0],d[0],clk,enable,reset);
 * dffe bit1(q[1],d[1],clk,enable,reset);
 *
 */

module dffe (
    output reg  q,       //! Current state of the flip-flop
    input  wire d,       //! Next state to be taken by the flip-flop on the next clock edge
    input  wire clock,   //! Clock signal, positive edge-sensitive
    input  wire enable,  //! Load new value? (yes = 1, no = 0)
    input  wire reset    //! Asynchronous reset
);
  always @(reset) if (reset == 1'b1) q <= 0;
  always @(posedge clock) if ((reset == 1'b0) && (enable == 1'b1)) q <= d;
endmodule
