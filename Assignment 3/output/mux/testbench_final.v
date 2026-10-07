module tb_mux2to1;
    // Declare testbench signals
    reg a, b, sel;
    wire y;
    integer passed_tests, failed_tests;

    // Instantiate the module under test
    mux2to1 uut (
        .a(a),
        .b(b),
        .sel(sel),
        .y(y)
    );

    initial begin
        // Initialize test counters
        passed_tests = 0;
        failed_tests = 0;

        // Test Case 1: sel=0, a=0, b=0
        a = 0; b = 0; sel = 0;
        #10;
        $display("Test 1: a=%b, b=%b, sel=%b, y=%b", a, b, sel, y);
        #10;
        if (y === 0) begin
            $display("✓ Test 1 Pass: y=%b (Expected: 0)", y);
            passed_tests = passed_tests + 1;
        end else begin
            $display("✗ Test 1 Fail: y=%b (Expected: 0)", y);
            failed_tests = failed_tests + 1;
        end

        // Test Case 2: sel=0, a=0, b=1
        a = 0; b = 1; sel = 0;
        #10;
        $display("Test 2: a=%b, b=%b, sel=%b, y=%b", a, b, sel, y);
        #10;
        if (y === 0) begin
            $display("✓ Test 2 Pass: y=%b (Expected: 0)", y);
            passed_tests = passed_tests + 1;
        end else begin
            $display("✗ Test 2 Fail: y=%b (Expected: 0)", y);
            failed_tests = failed_tests + 1;
        end

        // Test Case 3: sel=0, a=1, b=0
        a = 1; b = 0; sel = 0;
        #10;
        $display("Test 3: a=%b, b=%b, sel=%b, y=%b", a, b, sel, y);
        #10;
        if (y === 1) begin
            $display("✓ Test 3 Pass: y=%b (Expected: 1)", y);
            passed_tests = passed_tests + 1;
        end else begin
            $display("✗ Test 3 Fail: y=%b (Expected: 1)", y);
            failed_tests = failed_tests + 1;
        end

        // Test Case 4: sel=0, a=1, b=1
        a = 1; b = 1; sel = 0;
        #10;
        $display("Test 4: a=%b, b=%b, sel=%b, y=%b", a, b, sel, y);
        #10;
        if (y === 1) begin
            $display("✓ Test 4 Pass: y=%b (Expected: 1)", y);
            passed_tests = passed_tests + 1;
        end else begin
            $display("✗ Test 4 Fail: y=%b (Expected: 1)", y);
            failed_tests = failed_tests + 1;
        end

        // Test Case 5: sel=1, a=0, b=0
        a = 0; b = 0; sel = 1;
        #10;
        $display("Test 5: a=%b, b=%b, sel=%b, y=%b", a, b, sel, y);
        #10;
        if (y === 0) begin
            $display("✓ Test 5 Pass: y=%b (Expected: 0)", y);
            passed_tests = passed_tests + 1;
        end else begin
            $display("✗ Test 5 Fail: y=%b (Expected: 0)", y);
            failed_tests = failed_tests + 1;
        end

        // Test Case 6: sel=1, a=0, b=1
        a = 0; b = 1; sel = 1;
        #10;
        $display("Test 6: a=%b, b=%b, sel=%b, y=%b", a, b, sel, y);
        #10;
        if (y === 1) begin
            $display("✓ Test 6 Pass: y=%b (Expected: 1)", y);
            passed_tests = passed_tests + 1;
        end else begin
            $display("✗ Test 6 Fail: y=%b (Expected: 1)", y);
            failed_tests = failed_tests + 1;
        end

        // Test Case 7: sel=1, a=1, b=0
        a = 1; b = 0; sel = 1;
        #10;
        $display("Test 7: a=%b, b=%b, sel=%b, y=%b", a, b, sel, y);
        #10;
        if (y === 0) begin
            $display("✓ Test 7 Pass: y=%b (Expected: 0)", y);
            passed_tests = passed_tests + 1;
        end else begin
            $display("✗ Test 7 Fail: y=%b (Expected: 0)", y);
            failed_tests = failed_tests + 1;
        end

        // Test Case 8: sel=1, a=1, b=1
        a = 1; b = 1; sel = 1;
        #10;
        $display("Test 8: a=%b, b=%b, sel=%b, y=%b", a, b, sel, y);
        #10;
        if (y === 1) begin
            $display("✓ Test 8 Pass: y=%b (Expected: 1)", y);
            passed_tests = passed_tests + 1;
        end else begin
            $display("✗ Test 8 Fail: y=%b (Expected: 1)", y);
            failed_tests = failed_tests + 1;
        end

        // Test summary
        $display("Total Tests Run: %d", passed_tests + failed_tests);
        $display("Tests Passed: %d", passed_tests);
        $display("Tests Failed: %d", failed_tests);

        $finish;
    end
endmodule