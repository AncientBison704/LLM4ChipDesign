`timescale 1ns/1ps
// AutoChip-format testbench for lfsr.
// Same reference model as the GUIDE lfsr_tb.v: reset/initial state 8'b10001010, and
// next = {data[6:0], data[0] ^ data[3] ^ data[5] ^ data[6]} (taps at 1-indexed
// locations 1, 4, 6, 7, feedback shifted in at bit 0). Checks 256 clocks.
module tb();
    reg clk = 0;
    always #5 clk = ~clk;
    reg reset_n;
    wire [7:0] data;
    reg  [7:0] expected;
    integer errors = 0, samples = 0, k;

    lfsr dut (.clk(clk), .reset_n(reset_n), .data(data));

    task check(input integer cyc);
        begin
            samples = samples + 1;
            if (data !== expected) begin
                errors = errors + 1;
                if (errors <= 10)
                    $display("Error: cycle %0d expected data=8'b%b, got 8'b%b", cyc, expected, data);
            end
        end
    endtask

    initial begin
        reset_n = 0;
        expected = 8'b10001010;
        @(negedge clk);
        check(0);                               // state during reset
        reset_n = 1;
        for (k = 1; k <= 256; k = k + 1) begin
            @(negedge clk);
            expected = {expected[6:0], expected[0] ^ expected[3] ^ expected[5] ^ expected[6]};
            check(k);
        end
        $finish;
    end

    final begin
        $display("Hint: Total mismatched samples is %0d out of %0d samples", errors, samples);
        $display("Mismatches: %0d in %0d samples", errors, samples);
    end
endmodule
