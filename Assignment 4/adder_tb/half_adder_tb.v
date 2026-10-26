`timescale 1ns/1ps
module tb_half_adder;
    reg  a, b;
    wire sum, cout;

    half_adder dut (.a(a), .b(b), .sum(sum), .cout(cout));

    integer testnum;
    integer fail_count;

    task check;
        input in_a, in_b;
        reg [1:0] exp;
        begin
            a = in_a; b = in_b;
            #10;
            exp = in_a + in_b;
            testnum = testnum + 1;
            if ({cout, sum} === exp)
                $display("Test %0d passed (a=%b b=%b sum=%b cout=%b)", testnum, a, b, sum, cout);
            else begin
                $display("Test %0d FAILED (a=%b b=%b expected {cout,sum}=%b got %b%b)",
                         testnum, a, b, exp, cout, sum);
                fail_count = fail_count + 1;
            end
        end
    endtask

    initial begin
        testnum = 0; fail_count = 0;
        a = 0; b = 0;

        // === BASELINE TESTS ===
        check(0, 0);
        check(0, 1);
        check(1, 0);
        check(1, 1);
        // === COVERAGE TESTS ===

        if (fail_count == 0)
            $display("All tests passed!");
        else
            $display("SUMMARY: %0d test(s) FAILED", fail_count);
        $finish;
    end
endmodule
