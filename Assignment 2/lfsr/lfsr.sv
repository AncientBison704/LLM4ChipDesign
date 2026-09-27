module lfsr (
    input        clk,
    input        reset_n,
    output reg [7:0] data
);

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            data <= 8'b10001010; // Initial state
        end else begin
            // Feedback polynomial x^8 + x^7 + x^6 + x^5 + 1
            data <= {data[6:0], data[7] ^ data[6] ^ data[5] ^ data[4]};
        end
    end

endmodule

