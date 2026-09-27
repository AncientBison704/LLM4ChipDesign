module lfsr (
    input        clk,
    input        reset_n,
    output reg [7:0] data
);

    // Place to store the internal state for feedback computation
    reg [7:0] state;

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            // Initialize the LFSR to 10001010 on reset
            state <= 8'b10001010;
        end else begin
            // Compute the feedback from the taps at locations 1, 4, 6, and 7
            // using the polynomial x^8 + x^7 + x^6 + x^4 + 1
            state <= {state[6:0], state[7] ^ state[5] ^ state[3] ^ state[2]};
        end
    end

    // Output the state as data
    assign data = state;

endmodule
