module lfsr (
    input        clk,
    input        reset_n,
    output reg [7:0] data
);

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            data <= 8'b10001010; // Initial state
        end else begin
            data <= {data[6:0], data[7] ^ data[5] ^ data[3] ^ data[2]}; // Feedback calculation
        end
    end

endmodule
