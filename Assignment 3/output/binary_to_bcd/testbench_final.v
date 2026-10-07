module tb_binary_to_bcd_converter;
    // Declare input stimulus
    reg [4:0] binary_input;
    // Declare output wires
    wire [7:0] bcd_output;

    // Instantiate the module under test
    binary_to_bcd_converter uut (
        .binary_input(binary_input),
        .bcd_output(bcd_output)
    );

    integer passed_tests, failed_tests;

    initial begin
        passed_tests = 0;
        failed_tests = 0;

        // Test case 1: Minimum input value
        binary_input = 5'b00000;
        #10;
        $display("Test 1: binary_input = %b", binary_input);
        #10;
        if (bcd_output === 8'b00000000) begin
            $display("✓ Test 1 Passed: bcd_output = %b (Expected: 00000000)", bcd_output);
            passed_tests = passed_tests + 1;
        end else begin
            $display("✗ Test 1 Failed: bcd_output = %b (Expected: 00000000)", bcd_output);
            failed_tests = failed_tests + 1;
        end

        // Test case 2: Smallest non-zero input
        binary_input = 5'b00001;
        #10;
        $display("Test 2: binary_input = %b", binary_input);
        #10;
        if (bcd_output === 8'b00000001) begin
            $display("✓ Test 2 Passed: bcd_output = %b (Expected: 00000001)", bcd_output);
            passed_tests = passed_tests + 1;
        end else begin
            $display("✗ Test 2 Failed: bcd_output = %b (Expected: 00000001)", bcd_output);
            failed_tests = failed_tests + 1;
        end

        // Test case 3: Typical use case in mid-range
        binary_input = 5'b01010; // Decimal 10
        #10;
        $display("Test 3: binary_input = %b", binary_input);
        #10;
        if (bcd_output === 8'b00010000) begin
            $display("✓ Test 3 Passed: bcd_output = %b (Expected: 00010000)", bcd_output);
            passed_tests = passed_tests + 1;
        end else begin
            $display("✗ Test 3 Failed: bcd_output = %b (Expected: 00010000)", bcd_output);
            failed_tests = failed_tests + 1;
        end

        // Test case 4: Maximum input value
        binary_input = 5'b11111; // Decimal 31
        #10;
        $display("Test 4: binary_input = %b", binary_input);
        #10;
        if (bcd_output === 8'b00110001) begin
            $display("✓ Test 4 Passed: bcd_output = %b (Expected: 00110001)", bcd_output);
            passed_tests = passed_tests + 1;
        end else begin
            $display("✗ Test 4 Failed: bcd_output = %b (Expected: 00110001)", bcd_output);
            failed_tests = failed_tests + 1;
        end

        // Test case 5: Random value
        binary_input = 5'b10101; // Random value 21
        #10;
        $display("Test 5: binary_input = %b", binary_input);
        #10;
        if (bcd_output === 8'b00100001) begin
            $display("✓ Test 5 Passed: bcd_output = %b (Expected: 00100001)", bcd_output);
            passed_tests = passed_tests + 1;
        end else begin
            $display("✗ Test 5 Failed: bcd_output = %b (Expected: 00100001)", bcd_output);
            failed_tests = failed_tests + 1;
        end

        // Test case 6: Random value
        binary_input = 5'b01111; // Random value 15
        #10;
        $display("Test 6: binary_input = %b", binary_input);
        #10;
        if (bcd_output === 8'b00010101) begin
            $display("✓ Test 6 Passed: bcd_output = %b (Expected: 00010101)", bcd_output);
            passed_tests = passed_tests + 1;
        end else begin
            $display("✗ Test 6 Failed: bcd_output = %b (Expected: 00010101)", bcd_output);
            failed_tests = failed_tests + 1;
        end

        // Test case 7: Boundary value
        binary_input = 5'b01110; // Decimal 14
        #10;
        $display("Test 7: binary_input = %b", binary_input);
        #10;
        if (bcd_output === 8'b00010100) begin
            $display("✓ Test 7 Passed: bcd_output = %b (Expected: 00010100)", bcd_output);
            passed_tests = passed_tests + 1;
        end else begin
            $display("✗ Test 7 Failed: bcd_output = %b (Expected: 00010100)", bcd_output);
            failed_tests = failed_tests + 1;
        end

        // Test case 8: Boundary value just below the max
        binary_input = 5'b11110; // Decimal 30
        #10;
        $display("Test 8: binary_input = %b", binary_input);
        #10;
        if (bcd_output === 8'b00110000) begin
            $display("✓ Test 8 Passed: bcd_output = %b (Expected: 00110000)", bcd_output);
            passed_tests = passed_tests + 1;
        end else begin
            $display("✗ Test 8 Failed: bcd_output = %b (Expected: 00110000)", bcd_output);
            failed_tests = failed_tests + 1;
        end

        // Test case 9: Random value
        binary_input = 5'b00011; // Random value 3
        #10;
        $display("Test 9: binary_input = %b", binary_input);
        #10;
        if (bcd_output === 8'b00000011) begin
            $display("✓ Test 9 Passed: bcd_output = %b (Expected: 00000011)", bcd_output);
            passed_tests = passed_tests + 1;
        end else begin
            $display("✗ Test 9 Failed: bcd_output = %b (Expected: 00000011)", bcd_output);
            failed_tests = failed_tests + 1;
        end

        // Test case 10: Random value
        binary_input = 5'b10011; // Random value 19
        #10;
        $display("Test 10: binary_input = %b", binary_input);
        #10;
        if (bcd_output === 8'b00011001) begin
            $display("✓ Test 10 Passed: bcd_output = %b (Expected: 00011001)", bcd_output);
            passed_tests = passed_tests + 1;
        end else begin
            $display("✗ Test 10 Failed: bcd_output = %b (Expected: 00011001)", bcd_output);
            failed_tests = failed_tests + 1;
        end

        $display("Test Summary: Total Tests = 10, Passed = %0d, Failed = %0d", passed_tests, failed_tests);
        $finish;
    end
endmodule