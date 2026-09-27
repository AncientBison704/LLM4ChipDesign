module binary_to_bcd_converter (
    input  [4:0] binary_input,
    output reg [7:0] bcd_output
);

    // Convert the 5-bit binary input to BCD
    reg [3:0] tens;
    reg [3:0] ones;
    integer i;

    always @(*) begin
        // Initialize BCD digits
        tens = 4'b0000;
        ones = 4'b0000;

        // Process each bit of the binary input
        for (i = 4; i >= 0; i = i - 1) begin
            // Shift the BCD digits to make space for the next bit
            if (tens >= 5) tens = tens + 3;
            if (ones >= 5) ones = ones + 3;

            {tens, ones} = {tens, ones} << 1;
            ones[0] = binary_input[i];
        end

        // Output the BCD result
        bcd_output = {tens, ones};
    end

endmodule
