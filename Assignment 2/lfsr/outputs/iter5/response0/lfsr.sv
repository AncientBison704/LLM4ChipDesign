module lfsr (
    input        clk,
    input        reset_n,
    output reg [7:0] data
);

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            data <= 8'b10001010; // Initial state
        end else begin
            // Correct feedback polynomial x^8 + x^7 + x^6 + x^4 + 1
            data <= {data[6:0], data[7] ^ data[4] ^ data[2] ^ data[1]};
        end
    end

endmodule
