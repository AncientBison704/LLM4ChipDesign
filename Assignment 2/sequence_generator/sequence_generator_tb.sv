`timescale 1ns/1ps
// AutoChip-format testbench for sequence_generator.
// Reproduces the GUIDE sequence_generator_tb.v contract without its sampling race:
// after reset data = 0xAF (first value); each rising edge with enable=1 advances data to
// the next value (wrapping 0x8D -> 0xAF); with enable=0 data holds. Checks generation,
// repetition, and disable, as the GUIDE bench does, plus random enable toggling.
module tb();
    reg clk = 0;
    always #5 clk = ~clk;
    reg reset_n, enable;
    wire [7:0] data;
    reg  [7:0] seq [0:7];
    integer idx, errors = 0, samples = 0, k;

    sequence_generator dut (.clk(clk), .reset_n(reset_n), .enable(enable), .data(data));

    task step(input en, input [8*24-1:0] label);
        begin
            @(negedge clk);
            enable = en;
            @(posedge clk);
            if (en) idx = (idx + 1) % 8;
            #1;
            samples = samples + 1;
            if (data !== seq[idx]) begin
                errors = errors + 1;
                if (errors <= 10)
                    $display("Error: %0s: enable=%b, expected data=%h (sequence position %0d), got %h",
                             label, en, seq[idx], idx, data);
            end
        end
    endtask

    initial begin
        seq[0]=8'hAF; seq[1]=8'hBC; seq[2]=8'hE2; seq[3]=8'h78;
        seq[4]=8'hFF; seq[5]=8'hE2; seq[6]=8'h0B; seq[7]=8'h8D;
        reset_n = 0; enable = 0; idx = 0;
        @(negedge clk); @(negedge clk);
        samples = samples + 1;
        if (data !== 8'hAF) begin
            errors = errors + 1;
            $display("Error: during reset expected data=af, got %h", data);
        end
        reset_n = 1;
        step(0, "after reset, disabled");
        for (k = 0; k < 7; k = k + 1)  step(1, "sequence generation");
        for (k = 0; k < 8; k = k + 1)  step(1, "sequence repetition");
        step(0, "disable");  step(0, "disable");
        for (k = 0; k < 40; k = k + 1) step($urandom, "random enable");
        $finish;
    end

    final begin
        $display("Hint: Total mismatched samples is %0d out of %0d samples", errors, samples);
        $display("Mismatches: %0d in %0d samples", errors, samples);
    end
endmodule
