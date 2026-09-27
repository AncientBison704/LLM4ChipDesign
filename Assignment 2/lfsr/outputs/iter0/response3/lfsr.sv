module lfsr (
    input        clk,
    input        reset_n,
    output reg [7:0] data
);

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            data <= 8'b10001010; // Initial state
        end else begin
            // Compute the feedback bit using XOR of specified taps
            wire feedback = data[0] ^ data[3] ^ data[5] ^ data[6];
            // Shift the register and insert the feedback bit in the MSB
            data <= {data[6:0], feedback};
        end
    end

endmodule
