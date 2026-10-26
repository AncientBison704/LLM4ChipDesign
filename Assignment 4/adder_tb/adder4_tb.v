`timescale 1ns/1ps
module tb_adder4;
    reg  [3:0] a, b;
    reg        cin;
    wire [3:0] sum;
    wire       cout;

    adder4 dut (.a(a), .b(b), .cin(cin), .sum(sum), .cout(cout));

    integer testnum;
    integer fail_count;

    task check;
        input [3:0] in_a, in_b;
        input       in_cin;
        reg   [4:0] exp;
        begin
            a = in_a; b = in_b; cin = in_cin;
            #10;
            exp = in_a + in_b + in_cin;
            testnum = testnum + 1;
            if ({cout, sum} === exp)
                $display("Test %0d passed (a=%h b=%h cin=%b sum=%h cout=%b)", testnum, a, b, cin, sum, cout);
            else begin
                $display("Test %0d FAILED (a=%h b=%h cin=%b expected {cout,sum}=%b got %b%b)",
                         testnum, a, b, cin, exp, cout, sum);
                fail_count = fail_count + 1;
            end
        end
    endtask

    initial begin
        testnum = 0; fail_count = 0;
        a = 0; b = 0; cin = 0;

        // === BASELINE TESTS ===
        check(4'h0, 4'h0, 0);
        check(4'h1, 4'h1, 0);
        check(4'h5, 4'hA, 0);
        check(4'h7, 4'h1, 0);
        check(4'h3, 4'h4, 0);
        check(4'h9, 4'h6, 0);
        // === COVERAGE TESTS ===

        if (fail_count == 0)
            $display("All tests passed!");
        else
            $display("SUMMARY: %0d test(s) FAILED", fail_count);
        $finish;
    end
endmodule
