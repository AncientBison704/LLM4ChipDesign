`timescale 1ns/1ps
module tb_full_adder;
    reg  a, b, cin;
    wire sum, cout;

    full_adder dut (.a(a), .b(b), .cin(cin), .sum(sum), .cout(cout));

    integer testnum;
    integer fail_count;

    task check;
        input in_a, in_b, in_cin;
        reg [1:0] exp;
        begin
            a = in_a; b = in_b; cin = in_cin;
            #10;
            exp = in_a + in_b + in_cin;
            testnum = testnum + 1;
            if ({cout, sum} === exp)
                $display("Test %0d passed (a=%b b=%b cin=%b sum=%b cout=%b)", testnum, a, b, cin, sum, cout);
            else begin
                $display("Test %0d FAILED (a=%b b=%b cin=%b expected {cout,sum}=%b got %b%b)",
                         testnum, a, b, cin, exp, cout, sum);
                fail_count = fail_count + 1;
            end
        end
    endtask

    initial begin
        testnum = 0; fail_count = 0;
        a = 0; b = 0; cin = 0;

        // === BASELINE TESTS ===
        check(0, 0, 0);
        check(0, 1, 0);
        check(1, 0, 0);
        check(1, 1, 0);
        check(1, 1, 1);
        // === COVERAGE TESTS ===

        if (fail_count == 0)
            $display("All tests passed!");
        else
            $display("SUMMARY: %0d test(s) FAILED", fail_count);
        $finish;
    end
endmodule
