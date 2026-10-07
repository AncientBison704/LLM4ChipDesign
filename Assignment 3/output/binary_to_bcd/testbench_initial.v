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

    initial begin
        // Test case 1: Minimum input value
        binary_input = 5'b00000;
        #10;
        $display("Test 1: binary_input = %b", binary_input);

        // Test case 2: Smallest non-zero input
        binary_input = 5'b00001;
        #10;
        $display("Test 2: binary_input = %b", binary_input);

        // Test case 3: Typical use case in mid-range
        binary_input = 5'b01010; // Decimal 10
        #10;
        $display("Test 3: binary_input = %b", binary_input);

        // Test case 4: Maximum input value
        binary_input = 5'b11111; // Decimal 31
        #10;
        $display("Test 4: binary_input = %b", binary_input);

        // Test case 5: Random value
        binary_input = 5'b10101; // Random value 21
        #10;
        $display("Test 5: binary_input = %b", binary_input);

        // Test case 6: Random value
        binary_input = 5'b01111; // Random value 15
        #10;
        $display("Test 6: binary_input = %b", binary_input);

        // Test case 7: Boundary value
        binary_input = 5'b01110; // Decimal 14
        #10;
        $display("Test 7: binary_input = %b", binary_input);

        // Test case 8: Boundary value just below the max
        binary_input = 5'b11110; // Decimal 30
        #10;
        $display("Test 8: binary_input = %b", binary_input);

        // Test case 9: Random value
        binary_input = 5'b00011; // Random value 3
        #10;
        $display("Test 9: binary_input = %b", binary_input);

        // Test case 10: Random value
        binary_input = 5'b10011; // Random value 19
        #10;
        $display("Test 10: binary_input = %b", binary_input);

        $finish;
    end
endmodule