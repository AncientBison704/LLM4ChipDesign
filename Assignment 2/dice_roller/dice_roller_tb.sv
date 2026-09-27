`timescale 1ns/1ps
// AutoChip-format testbench for dice_roller.
// Same stimulus and range check as the GUIDE dice_roller_tb.v: for each die_select
// (00=d4, 01=d6, 10=d8, 11=d20) it pulses roll high for one clock 1000 times and checks
// 1 <= rolled_number <= sides. One extra check per die: every face must appear at least
// once in the 1000 rolls (so a constant output cannot pass as "random").
module tb();
    reg clk = 0;
    always #5 clk = ~clk;
    reg rst_n, roll;
    reg [1:0] die_select;
    wire [7:0] rolled_number;
    integer errors = 0, samples = 0, d, j, f, sides;
    integer counts [0:255];

    dice_roller dut (.clk(clk), .rst_n(rst_n), .die_select(die_select), .roll(roll),
                     .rolled_number(rolled_number));

    initial begin
        rst_n = 0; roll = 0; die_select = 0;
        @(negedge clk); @(negedge clk);
        rst_n = 1;
        @(negedge clk);
        for (d = 0; d < 4; d = d + 1) begin
            die_select = d;
            sides = (d == 0) ? 4 : (d == 1) ? 6 : (d == 2) ? 8 : 20;
            for (f = 0; f < 256; f = f + 1) counts[f] = 0;
            for (j = 0; j < 1000; j = j + 1) begin
                @(negedge clk); roll = 1;   // one rising edge with roll high
                @(negedge clk); roll = 0;   // one rising edge with roll low
                @(negedge clk);             // check (same spacing as the GUIDE bench)
                samples = samples + 1;
                if (^rolled_number === 1'bx || rolled_number < 1 || rolled_number > sides) begin
                    errors = errors + 1;
                    if (errors <= 10)
                        $display("Error: die_select=%b (%0d-sided die): rolled_number=%0d is outside 1..%0d",
                                 die_select, sides, rolled_number, sides);
                end else
                    counts[rolled_number] = counts[rolled_number] + 1;
            end
            for (f = 1; f <= sides; f = f + 1) begin
                samples = samples + 1;
                if (counts[f] == 0) begin
                    errors = errors + 1;
                    if (errors <= 10)
                        $display("Error: die_select=%b (%0d-sided die): face %0d never appeared in 1000 rolls",
                                 die_select, sides, f);
                end
            end
            $display("die_select=%b: face counts d%0d = %0d %0d %0d %0d ...", die_select, sides,
                     counts[1], counts[2], counts[3], counts[4]);
        end
        $finish;
    end

    final begin
        $display("Hint: Total mismatched samples is %0d out of %0d samples", errors, samples);
        $display("Mismatches: %0d in %0d samples", errors, samples);
    end
endmodule
