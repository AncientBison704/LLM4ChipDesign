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

    initial begin
        // Test Case 1: Minimal boundary (0 + 0)
        a = 4'b0000; b = 4'b0000;
        #10 $display("Test Case 1: a = %b, b = %b, sum = %b, carry = %b", a, b, sum, carry);
        
        // Test Case 2: Max input without carry (7 + 7)
        a = 4'b0111; b = 4'b0111;
        #10 $display("Test Case 2: a = %b, b = %b, sum = %b, carry = %b", a, b, sum, carry);

        // Test Case 3: Max input with carry (8 + 8)
        a = 4'b1000; b = 4'b1000;
        #10 $display("Test Case 3: a = %b, b = %b, sum = %b, carry = %b", a, b, sum, carry);

        // Test Case 4: Full max value (15 + 0)
        a = 4'b1111; b = 4'b0000;
        #10 $display("Test Case 4: a = %b, b = %b, sum = %b, carry = %b", a, b, sum, carry);

        // Test Case 5: Full max value with carry (15 + 1)
        a = 4'b1111; b = 4'b0001;
        #10 $display("Test Case 5: a = %b, b = %b, sum = %b, carry = %b", a, b, sum, carry);

        // Test Case 6: Random value with no carry (3 + 5)
        a = 4'b0011; b = 4'b0101;
        #10 $display("Test Case 6: a = %b, b = %b, sum = %b, carry = %b", a, b, sum, carry);

        // Test Case 7: Random value with carry (9 + 9)
        a = 4'b1001; b = 4'b1001;
        #10 $display("Test Case 7: a = %b, b = %b, sum = %b, carry = %b", a, b, sum, carry);

        // Test Case 8: Zero with max (0 + 15)
        a = 4'b0000; b = 4'b1111;
        #10 $display("Test Case 8: a = %b, b = %b, sum = %b, carry = %b", a, b, sum, carry);

        // Test Case 9: Mixed boundaries (1 + 14)
        a = 4'b0001; b = 4'b1110;
        #10 $display("Test Case 9: a = %b, b = %b, sum = %b, carry = %b", a, b, sum, carry);

        // Test Case 10: Sequential values (7 + 8)
        a = 4'b0111; b = 4'b1000;
        #10 $display("Test Case 10: a = %b, b = %b, sum = %b, carry = %b", a, b, sum, carry);

        // Test Case 11: Random test
        a = 4'b0101; b = 4'b1010;
        #10 $display("Test Case 11: a = %b, b = %b, sum = %b, carry = %b", a, b, sum, carry);

        // Test Case 12: Random test with carry
        a = 4'b0110; b = 4'b1011;
        #10 $display("Test Case 12: a = %b, b = %b, sum = %b, carry = %b", a, b, sum, carry);

        // Test Case 13: Edge case (max + max)
        a = 4'b1111; b = 4'b1111;
        #10 $display("Test Case 13: a = %b, b = %b, sum = %b, carry = %b", a, b, sum, carry);

        // Finish the simulation
        #10 $finish;
    end
endmodule