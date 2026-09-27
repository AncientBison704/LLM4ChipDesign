module lfsr (
    input        clk,
    input        reset_n,
    output reg [7:0] data
);
    reg [7:0] lfsr_reg;

    // Initial block to set initial state
    initial begin
        lfsr_reg = 8'b10001010;
    end

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            // Active low reset
            lfsr_reg <= 8'b10001010;
        end else begin
            // Linear Feedback Shift Register logic
            // XOR taps at positions 1, 4, 6, and 7
            lfsr_reg <= {lfsr_reg[6:0], lfsr_reg[7] ^ lfsr_reg[5] ^ lfsr_reg[3] ^ lfsr_reg[2]};
        end
    end
    
    // Assign the output
    assign data = lfsr_reg;

endmodule
