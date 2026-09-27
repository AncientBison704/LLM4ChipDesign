module shift_register (
    input        clk,
    input        reset_n,
    input        data_in,
    input        shift_enable,
    output reg [7:0] data_out
);

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n)
            data_out <= 8'b0;  // Active-low reset clears the data
        else if (shift_enable)
            data_out <= {data_out[6:0], data_in};  // Shift left and insert new bit
    end

endmodule
