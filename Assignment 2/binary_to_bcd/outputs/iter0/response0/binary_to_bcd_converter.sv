module binary_to_bcd_converter (
    input  [4:0] binary_input,
    output reg [7:0] bcd_output
);
    integer i;
    reg [7:0] bcd;

    always @(*) begin
        // Initialize BCD to zero
        bcd = 8'd0;
        
        // Double Dabble algorithm
        for (i = 4; i >= 0; i = i - 1) begin
            // Shift the BCD and place the next binary bit in LSB
            bcd = {bcd[6:0], binary_input[i]};
            
            // If BCD digits greater than or equal to 5, add 3
            if (bcd[3:0] >= 5)
                bcd[3:0] = bcd[3:0] + 3;
            if (bcd[7:4] >= 5)
                bcd[7:4] = bcd[7:4] + 3;
        end
        
        // Assign the converted BCD result to bcd_output
        bcd_output = bcd;
    end
endmodule
