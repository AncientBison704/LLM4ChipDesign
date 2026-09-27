module binary_to_bcd_converter (
    input  [4:0] binary_input,
    output reg [7:0] bcd_output
);

    integer i;
    reg [3:0] tens;
    reg [3:0] ones;
    reg [7:0] shift_reg;

    always @(*) begin
        // Initialize shift register with the input and zero the BCD outputs
        shift_reg = {3'b000, binary_input};
        tens = 4'b0000;
        ones = 4'b0000;
        
        // Execute the double-dabble algorithm
        for (i = 0; i < 5; i = i + 1) begin
            // If the 4-bit segments >= 5, add 3 to the segment
            if (shift_reg[7:4] >= 5)
                shift_reg[7:4] = shift_reg[7:4] + 3;
            if (shift_reg[3:0] >= 5)
                shift_reg[3:0] = shift_reg[3:0] + 3;
                
            // Shift left by 1
            shift_reg = shift_reg << 1;
        end
        
        // Assign results to BCD output
        tens = shift_reg[7:4];
        ones = shift_reg[3:0];
        bcd_output = {tens, ones};
    end

endmodule
