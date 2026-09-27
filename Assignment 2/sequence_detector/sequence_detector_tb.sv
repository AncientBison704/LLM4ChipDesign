`timescale 1ns/1ps
// AutoChip-format testbench for sequence_detector.
// Reproduces the GUIDE sequence_detector_tb.v contract without its sampling race:
// data changes on the falling edge and is sampled on the rising edge, and
// sequence_found is checked just before the next rising edge. The GUIDE bench
// expects sequence_found = 1 while the 8th value (0b101) is on data, i.e. once
// the first seven values have been clocked in. Earlier values and a broken
// sequence must give 0.
module tb();
    reg clk = 0;
    always #5 clk = ~clk;
    reg reset_n;
    reg [2:0] data;
    wire sequence_found;
    integer errors = 0, samples = 0, k;

    sequence_detector dut (.clk(clk), .reset_n(reset_n), .data(data), .sequence_found(sequence_found));

    reg [2:0] good [0:7];
    reg [2:0] bad  [0:3];

    task apply_and_check(input [2:0] v, input exp, input integer step, input [8*24-1:0] label);
        begin
            @(negedge clk);
            data = v;
            #4;                                   // settle, still before the rising edge
            samples = samples + 1;
            if (sequence_found !== exp) begin
                errors = errors + 1;
                if (errors <= 10)
                    $display("Error: %0s step %0d (data=3'b%b): expected sequence_found=%b, got %b",
                             label, step, v, exp, sequence_found);
            end
        end
    endtask

    initial begin
        good[0]=3'b001; good[1]=3'b101; good[2]=3'b110; good[3]=3'b000;
        good[4]=3'b110; good[5]=3'b110; good[6]=3'b011; good[7]=3'b101;
        bad[0]=3'b001;  bad[1]=3'b101;  bad[2]=3'b010;  bad[3]=3'b000;

        reset_n = 0; data = 3'b000;
        @(negedge clk); @(negedge clk);
        reset_n = 1;

        // Correct sequence: sequence_found must be 0 for values 1..7 and 1 while value 8 is present
        for (k = 0; k < 8; k = k + 1)
            apply_and_check(good[k], (k == 7), k + 1, "correct sequence");

        // Incorrect sequence: never found
        for (k = 0; k < 4; k = k + 1)
            apply_and_check(bad[k], 1'b0, k + 1, "incorrect sequence");

        // Reset in the middle, then the full sequence again
        @(negedge clk); reset_n = 0; @(negedge clk); reset_n = 1;
        for (k = 0; k < 8; k = k + 1)
            apply_and_check(good[k], (k == 7), k + 1, "after reset");

        @(negedge clk);
        $finish;
    end

    final begin
        $display("Hint: Total mismatched samples is %0d out of %0d samples", errors, samples);
        $display("Mismatches: %0d in %0d samples", errors, samples);
    end
endmodule
