`timescale 1ns/1ps
// AutoChip-format testbench for traffic_light_fsm.
// Same timing contract as the GUIDE traffic_light_tb.v: red during and after reset,
// green after exactly 32 rising edges, yellow after 20 more, red after 7 more.
// The GUIDE bench only checks those four points; this bench checks the lights on every
// cycle for two full red->green->yellow periods (enable held high, as in GUIDE).
module tb();
    reg clk = 0;
    always #5 clk = ~clk;
    reg reset_n, enable;
    wire red, yellow, green;
    integer errors = 0, samples = 0, k, cyc;
    reg [2:0] exp_ryg;          // {red, yellow, green}

    traffic_light_fsm dut (.clk(clk), .reset_n(reset_n), .enable(enable),
                           .red(red), .yellow(yellow), .green(green));

    function [2:0] expected_lights(input integer edges);   // edges since reset release
        integer t;
        begin
            t = edges % 59;                                 // 32 + 20 + 7
            if (t < 32)      expected_lights = 3'b100;
            else if (t < 52) expected_lights = 3'b001;
            else             expected_lights = 3'b010;
        end
    endfunction

    initial begin
        reset_n = 0; enable = 1;
        @(negedge clk);
        samples = samples + 1;
        if ({red, yellow, green} !== 3'b100) begin
            errors = errors + 1;
            $display("Error: during reset expected red=1 yellow=0 green=0, got red=%b yellow=%b green=%b",
                     red, yellow, green);
        end
        reset_n = 1;
        cyc = 0;
        for (k = 0; k < 2 * 59; k = k + 1) begin
            @(posedge clk); cyc = cyc + 1;
            #1;
            exp_ryg = expected_lights(cyc);
            samples = samples + 1;
            if ({red, yellow, green} !== exp_ryg) begin
                errors = errors + 1;
                if (errors <= 10)
                    $display("Error: %0d clock cycles after reset: expected red=%b yellow=%b green=%b, got red=%b yellow=%b green=%b",
                             cyc, exp_ryg[2], exp_ryg[1], exp_ryg[0], red, yellow, green);
            end
        end
        $finish;
    end

    final begin
        $display("Hint: Total mismatched samples is %0d out of %0d samples", errors, samples);
        $display("Mismatches: %0d in %0d samples", errors, samples);
    end
endmodule
