module lfsr (
    input        clk,
    input        reset_n,
    output reg [7:0] data
);

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            data <= 8'b10001010; // Initial state
        end else begin
            // Taps at bit locations 7, 5, 3, and 2 (1-indexed corresponding to the error trace)
            // Correct feedback polynomial: those locations are data[7], data[4], data[2], data[1] in 0-indexed array notation
            data <= {data[6:0], data[7] ^ data[4] ^ data[2] ^ data[1]}; // Correct feedback calculation
        end
    end

endmodule
