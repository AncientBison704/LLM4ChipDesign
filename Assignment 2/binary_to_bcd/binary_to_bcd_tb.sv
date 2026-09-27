`timescale 1ns/1ps
// AutoChip-format testbench for binary_to_bcd_converter.
// Same checks as the GUIDE binary_to_bcd_tb.v (exhaustive 0..31, bcd = {tens, ones}),
// but it counts mismatches instead of stopping at the first one, and ends with the
// "Mismatches: X in Y samples" line that AutoChip's ranker parses.
module tb();
    reg  [4:0] binary_input;
    wire [7:0] bcd_output;
    integer errors = 0, samples = 0, i;
    reg [7:0] expected;

    binary_to_bcd_converter dut (.binary_input(binary_input), .bcd_output(bcd_output));

    initial begin
        for (i = 0; i < 32; i = i + 1) begin
            binary_input = i;
            expected = {4'(i / 10), 4'(i % 10)};
            #10;
            samples = samples + 1;
            if (bcd_output !== expected) begin
                errors = errors + 1;
                if (errors <= 10)
                    $display("Error: binary_input=%0d expected bcd_output=8'b%b (tens=%0d ones=%0d), got 8'b%b",
                             i, expected, expected[7:4], expected[3:0], bcd_output);
            end
        end
        $finish;
    end

    final begin
        $display("Hint: Total mismatched samples is %0d out of %0d samples", errors, samples);
        $display("Mismatches: %0d in %0d samples", errors, samples);
    end
endmodule
