
module shift_register (
    input clk,
    input reset_n,             // Active low asynchronous reset
    input data_in,             // Serial data input
    input shift_enable,        // Shift enable control
    output reg [7:0] data_out  // Parallel data output
);

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            data_out <= 8'b0; // Reset the shift register
        end else if (shift_enable) begin
            data_out <= {data_out[6:0], data_in}; // Shift left and insert new bit
        end
    end

endmodule
