module tb_adder4bit;
    // Declare signals
    reg [3:0] a;
    reg [3:0] b;
    wire [3:0] sum;
    wire carry;

    // Instantiate the module under test
    adder4bit uut (
        .a(a),
        .b(b),
        .sum(sum),
        .carry(carry)
    );

    integer passed_tests = 0;
    integer failed_tests = 0;
    integer total_tests = 13;

    initial begin
        // Test Case 1: Minimal boundary (0 + 0)
        a = 4'b0000; b = 4'b0000;
        #10 $display("Test Case 1: a = %b, b = %b, sum = %b, carry = %b", a, b, sum, carry);
        if (sum == 4'b0000 && carry == 1'b0) begin
            $display("  ✓ Test Case 1 Passed");
            passed_tests = passed_tests + 1;
        end else begin
            $display("  ✗ Test Case 1 Failed: Expected sum = 0000, carry = 0");
            failed_tests = failed_tests + 1;
        end

        // Test Case 2: Max input without carry (7 + 7)
        a = 4'b0111; b = 4'b0111;
        #10 $display("Test Case 2: a = %b, b = %b, sum = %b, carry = %b", a, b, sum, carry);
        if (sum == 4'b1110 && carry == 1'b0) begin
            $display("  ✓ Test Case 2 Passed");
            passed_tests = passed_tests + 1;
        end else begin
            $display("  ✗ Test Case 2 Failed: Expected sum = 1110, carry = 0");
            failed_tests = failed_tests + 1;
        end

        // Test Case 3: Max input with carry (8 + 8)
        a = 4'b1000; b = 4'b1000;
        #10 $display("Test Case 3: a = %b, b = %b, sum = %b, carry = %b", a, b, sum, carry);
        if (sum == 4'b0000 && carry == 1'b1) begin
            $display("  ✓ Test Case 3 Passed");
            passed_tests = passed_tests + 1;
        end else begin
            $display("  ✗ Test Case 3 Failed: Expected sum = 0000, carry = 1");
            failed_tests = failed_tests + 1;
        end

        // Test Case 4: Full max value (15 + 0)
        a = 4'b1111; b = 4'b0000;
        #10 $display("Test Case 4: a = %b, b = %b, sum = %b, carry = %b", a, b, sum, carry);
        if (sum == 4'b1111 && carry == 1'b0) begin
            $display("  ✓ Test Case 4 Passed");
            passed_tests = passed_tests + 1;
        end else begin
            $display("  ✗ Test Case 4 Failed: Expected sum = 1111, carry = 0");
            failed_tests = failed_tests + 1;
        end

        // Test Case 5: Full max value with carry (15 + 1)
        a = 4'b1111; b = 4'b0001;
        #10 $display("Test Case 5: a = %b, b = %b, sum = %b, carry = %b", a, b, sum, carry);
        if (sum == 4'b0000 && carry == 1'b1) begin
            $display("  ✓ Test Case 5 Passed");
            passed_tests = passed_tests + 1;
        end else begin
            $display("  ✗ Test Case 5 Failed: Expected sum = 0000, carry = 1");
            failed_tests = failed_tests + 1;
        end

        // Test Case 6: Random value with no carry (3 + 5)
        a = 4'b0011; b = 4'b0101;
        #10 $display("Test Case 6: a = %b, b = %b, sum = %b, carry = %b", a, b, sum, carry);
        if (sum == 4'b1000 && carry == 1'b0) begin
            $display("  ✓ Test Case 6 Passed");
            passed_tests = passed_tests + 1;
        end else begin
            $display("  ✗ Test Case 6 Failed: Expected sum = 1000, carry = 0");
            failed_tests = failed_tests + 1;
        end

        // Test Case 7: Random value with carry (9 + 9)
        a = 4'b1001; b = 4'b1001;
        #10 $display("Test Case 7: a = %b, b = %b, sum = %b, carry = %b", a, b, sum, carry);
        if (sum == 4'b0010 && carry == 1'b1) begin
            $display("  ✓ Test Case 7 Passed");
            passed_tests = passed_tests + 1;
        end else begin
            $display("  ✗ Test Case 7 Failed: Expected sum = 0010, carry = 1");
            failed_tests = failed_tests + 1;
        end

        // Test Case 8: Zero with max (0 + 15)
        a = 4'b0000; b = 4'b1111;
        #10 $display("Test Case 8: a = %b, b = %b, sum = %b, carry = %b", a, b, sum, carry);
        if (sum == 4'b1111 && carry == 1'b0) begin
            $display("  ✓ Test Case 8 Passed");
            passed_tests = passed_tests + 1;
        end else begin
            $display("  ✗ Test Case 8 Failed: Expected sum = 1111, carry = 0");
            failed_tests = failed_tests + 1;
        end

        // Test Case 9: Mixed boundaries (1 + 14)
        a = 4'b0001; b = 4'b1110;
        #10 $display("Test Case 9: a = %b, b = %b, sum = %b, carry = %b", a, b, sum, carry);
        if (sum == 4'b1111 && carry == 1'b0) begin
            $display("  ✓ Test Case 9 Passed");
            passed_tests = passed_tests + 1;
        end else begin
            $display("  ✗ Test Case 9 Failed: Expected sum = 1111, carry = 0");
            failed_tests = failed_tests + 1;
        end

        // Test Case 10: Sequential values (7 + 8)
        a = 4'b0111; b = 4'b1000;
        #10 $display("Test Case 10: a = %b, b = %b, sum = %b, carry = %b", a, b, sum, carry);
        if (sum == 4'b1111 && carry == 1'b0) begin
            $display("  ✓ Test Case 10 Passed");
            passed_tests = passed_tests + 1;
        end else begin
            $display("  ✗ Test Case 10 Failed: Expected sum = 1111, carry = 0");
            failed_tests = failed_tests + 1;
        end

        // Test Case 11: Random test
        a = 4'b0101; b = 4'b1010;
        #10 $display("Test Case 11: a = %b, b = %b, sum = %b, carry = %b", a, b, sum, carry);
        if (sum == 4'b1111 && carry == 1'b0) begin
            $display("  ✓ Test Case 11 Passed");
            passed_tests = passed_tests + 1;
        end else begin
            $display("  ✗ Test Case 11 Failed: Expected sum = 1111, carry = 0");
            failed_tests = failed_tests + 1;
        end

        // Test Case 12: Random test with carry
        a = 4'b0110; b = 4'b1011;
        #10 $display("Test Case 12: a = %b, b = %b, sum = %b, carry = %b", a, b, sum, carry);
        if (sum == 4'b0001 && carry == 1'b1) begin
            $display("  ✓ Test Case 12 Passed");
            passed_tests = passed_tests + 1;
        end else begin
            $display("  ✗ Test Case 12 Failed: Expected sum = 0001, carry = 1");
            failed_tests = failed_tests + 1;
        end

        // Test Case 13: Edge case (max + max)
        a = 4'b1111; b = 4'b1111;
        #10 $display("Test Case 13: a = %b, b = %b, sum = %b, carry = %b", a, b, sum, carry);
        if (sum == 4'b1110 && carry == 1'b1) begin
            $display("  ✓ Test Case 13 Passed");
            passed_tests = passed_tests + 1;
        end else begin
            $display("  ✗ Test Case 13 Failed: Expected sum = 1110, carry = 1");
            failed_tests = failed_tests + 1;
        end

        // Test Summary
        $display("Test Summary:");
        $display("  Total Tests Run: %0d", total_tests);
        $display("  Tests Passed: %0d", passed_tests);
        $display("  Tests Failed: %0d", failed_tests);

        // Finish the simulation
        #10 $finish;
    end
endmodule