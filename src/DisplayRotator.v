module DisplayRotator(
    input            clk,
    input      [3:0] digit0,
    input      [3:0] digit1,
    input      [3:0] digit2,
    input      [3:0] digit3,
    output reg [3:0] an,
    output reg [3:0] digitToDisplay
);

reg [12:0] counter = 13'b0;


// YOU SHOULD NOT NEED TO EDIT THIS ALWAYS BLOCK

always @(posedge clk) begin
  counter <= counter + 1;
end


// YOU SHOULD EDIT ONLY THE digitToDisplay LINES BELOW

always @(*) begin
  case(counter[12:11])
    2'b00: begin
      an <= 4'b1110;
      digitToDisplay <= digit0;
    end
    2'b01: begin
      an <= 4'b1101;
      digitToDisplay <= digit1;
    end
    2'b10: begin
      an <= 4'b1011;
      digitToDisplay <= digit2;
    end
    2'b11: begin
      an <= 4'b0111;
      digitToDisplay <= digit3;
    end
  endcase
end

endmodule