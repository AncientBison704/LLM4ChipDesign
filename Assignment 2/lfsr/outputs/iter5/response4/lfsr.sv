module lfsr (
    input        clk,
    input        reset_n,
    output reg [7:0] data
);

    reg feedback;

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            data <= 8'b10001010; // Initial state
        end else begin
            feedback = data[7] ^ data[6] ^ data[4] ^ data[3]; // Correct feedback logic
            data <= {data[6:0], feedback}; // Shift and insert feedback
        end
    end

endmodule
