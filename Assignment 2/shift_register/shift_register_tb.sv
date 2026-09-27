`timescale 1ns/1ps
// AutoChip-format testbench for shift_register.
// NOTE: the GUIDE shift_register_tb.v is unsatisfiable (Part 1: it expects 8'b00001010
// before reset is ever asserted and ignores shift_enable/data_in). This bench checks
// the specification instead: active-low reset clears the register, on each rising edge
// with shift_enable=1 the register shifts left and data_in enters bit 0, and with
// shift_enable=0 it holds. Inputs change on the falling edge; data_out is checked
// before the next falling edge against a reference model.
module tb();
    reg clk = 0;
    always #5 clk = ~clk;
    reg reset_n, data_in, shift_enable;
    wire [7:0] data_out;
    reg  [7:0] model;
    integer errors = 0, samples = 0, k;

    shift_register dut (.clk(clk), .reset_n(reset_n), .data_in(data_in),
                        .shift_enable(shift_enable), .data_out(data_out));

    // reference model
    always @(posedge clk or negedge reset_n)
        if (!reset_n)          model <= 8'b0;
        else if (shift_enable) model <= {model[6:0], data_in};

    task step(input r, input en, input d);
        begin
            @(negedge clk);
            reset_n = r; shift_enable = en; data_in = d;
            @(posedge clk); #1;
            samples = samples + 1;
            if (data_out !== model) begin
                errors = errors + 1;
                if (errors <= 10)
                    $display("Error: reset_n=%b shift_enable=%b data_in=%b -> expected data_out=8'b%b, got 8'b%b",
                             r, en, d, model, data_out);
            end
        end
    endtask

    initial begin
        reset_n = 0; shift_enable = 0; data_in = 0;
        step(0,0,0);                                        // reset clears
        step(1,1,1); step(1,1,0); step(1,1,1); step(1,1,1); // shift in 1,0,1,1
        step(1,0,1); step(1,0,0);                           // hold with enable low
        step(1,1,0); step(1,1,1);                           // continue shifting
        step(0,1,1);                                        // reset dominates enable
        for (k = 0; k < 100; k = k + 1)                     // random traffic
            step(($urandom % 16) != 0, $urandom, $urandom);
        $finish;
    end

    final begin
        $display("Hint: Total mismatched samples is %0d out of %0d samples", errors, samples);
        $display("Mismatches: %0d in %0d samples", errors, samples);
    end
endmodule
