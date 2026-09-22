
module lfsr (
    input wire clk,
    input wire reset_n,   // Active low reset
    output reg [7:0] data
);

    // Declare a feedback reg for internal use
    reg feedback;

    // Initial block to set the initial state
    initial begin
        data = 8'b10001010;
    end

    always @(posedge clk or negedge reset_n) begin
        // Check for reset (active low)
        if (!reset_n) begin
            data <= 8'b10001010;  // Reset state
        end else begin
            // Calculate the feedback based on the tapped positions
            feedback = data[0] ^ data[3] ^ data[5] ^ data[6];
            // Shift left the data and insert the feedback into LSB
            data <= {data[6:0], feedback};
        end
    end

endmodule
