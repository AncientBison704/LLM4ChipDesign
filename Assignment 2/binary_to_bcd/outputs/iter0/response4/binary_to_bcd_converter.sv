module binary_to_bcd_converter (
    input  [4:0] binary_input,
    output reg [7:0] bcd_output
);
    integer i;
    reg [7:0] bcd;

    always @ (binary_input) begin
        bcd = 8'b0000_0000;

        for (i = 0; i < 5; i = i + 1) begin
            if (bcd[3:0] >= 5)
                bcd[3:0] = bcd[3:0] + 3;
            if (bcd[7:4] >= 5)
                bcd[7:4] = bcd[7:4] + 3;
            
            bcd = {bcd[6:0], binary_input[4-i]};
        end
        bcd_output = bcd;
    end

endmodule
