
module abro_state_machine (
  input wire clk,
  input wire rst_n,  // Active-low reset
  input wire A,
  input wire B,
  output wire O,
  output reg [3:0] State
);

  // Assign combinational output
  assign O = A & B;

  // State transition logic
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
      State <= 4'b0001;  // Reset to initial state
    else begin
      case ({A, B})
        2'b10: State <= 4'b0010;  // A is high, B is low
        2'b01: State <= 4'b0001;  // B is high, A is low (Return to reset state)
        2'b11: State <= 4'b0100;  // Both A and B are high
        2'b00: State <= State;    // Maintain current state
        default: State <= 4'b0001; // Default safety state
      endcase
    end
  end

endmodule
