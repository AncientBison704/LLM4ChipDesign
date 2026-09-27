module lfsr (
    input        clk,
    input        reset_n,
    output reg [7:0] data
);

    wire feedback;

    assign feedback = data[7] ^ data[4] ^ data[2] ^ data[1]; // Taps at locations 1, 4, 6, and 7

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            data <= 8'b10001010; // Initial state
        end else begin
            data <= {data[6:0], feedback};
        end
    end

endmodule
