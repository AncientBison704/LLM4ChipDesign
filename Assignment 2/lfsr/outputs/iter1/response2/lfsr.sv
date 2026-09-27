module lfsr (
    input        clk,
    input        reset_n,
    output reg [7:0] data
);

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            data <= 8'b10001010; // Initial state
        end else begin
            // Correct the feedback taps
            data <= {data[6:0], data[7] ^ data[5] ^ data[3] ^ data[2]};
        end
    end

endmodule
