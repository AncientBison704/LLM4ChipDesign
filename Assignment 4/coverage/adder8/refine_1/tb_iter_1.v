`timescale 1ns/1ps
module tb_adder8;
    reg  [7:0] a, b;
    reg        cin;
    wire [7:0] sum;
    wire       cout;

    adder8 dut (.a(a), .b(b), .cin(cin), .sum(sum), .cout(cout));

    integer testnum;
    integer fail_count;

    task check;
        input [7:0] in_a, in_b;
        input       in_cin;
        reg   [8:0] exp;
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
        check(8'h00, 8'h00, 0);
        check(8'h01, 8'h01, 0);
        check(8'h0F, 8'h01, 0);
        check(8'h55, 8'h2A, 0);
        check(8'h12, 8'h34, 0);
        check(8'h80, 8'h7F, 0);
        check(8'h0F, 8'h0F, 0);
        check(8'h33, 8'h44, 0);
        // === COVERAGE TESTS ===
        // Toggle a[5]: Ensure bit 5 toggles from 1->0
        check(8'hFF, 8'h1E, 0);
        // Toggle b[7]: Ensure bit 7 toggles from 1->0
        check(8'h00, 8'hFF, 0);
        // Toggle b[2]: Ensure bit 2 toggles from 1->0
        check(8'h00, 8'h07, 0);
        // Toggle cin: Ensure cin toggles 0->1 and 1->0
        check(8'h00, 8'h00, 1);
        // Toggle cout: Ensure cout toggles 0->1 and 1->0
        check(8'hFF, 8'hFF, 0);
        // Exercise fa0: Assign cout = c1 | c2; missing -1
        check(8'h08, 8'h00, 1);

        if (fail_count == 0)
            $display("All tests passed!");
        else
            $display("SUMMARY: %0d test(s) FAILED", fail_count);
        $finish;
    end
endmodule
