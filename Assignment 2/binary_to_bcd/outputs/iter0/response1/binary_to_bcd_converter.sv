module binary_to_bcd_converter (
    input  [4:0] binary_input,
    output reg [7:0] bcd_output
);

    always @(*) begin
        integer i;
        reg [7:0] bcd; // Temporary BCD register

        bcd = 8'b0; // Initialize the BCD register to zero

        // Double-dabble algorithm to convert binary to BCD
        for (i = 4; i >= 0; i = i - 1) begin
            // Shift left by 1
            bcd = {bcd[6:0], binary_input[i]};

            // If the number in the tens place is greater than or equal to 5, add 3
            if (bcd[7:4] >= 5)
                bcd[7:4] = bcd[7:4] + 3;

            // If the number in the ones place is greater than or equal to 5, add 3
            if (bcd[3:0] >= 5)
                bcd[3:0] = bcd[3:0] + 3;
        end

        bcd_output = bcd; // Assign the result to output
    end

endmodule
