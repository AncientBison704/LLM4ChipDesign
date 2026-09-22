module tb_shift_register();
    reg clk;
    reg reset_n;
    reg data_in;
    reg shift_enable;
    wire [7:0] data_out;

    // Instantiate the shift_register
    shift_register dut (
        .clk(clk),
        .reset_n(reset_n),
        .data_in(data_in),
        .shift_enable(shift_enable),
        .data_out(data_out)
    );

    // Clock generation
    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;  // 10 ns period
    end

    integer errors = 0;
    reg [7:0] expected_data_out;

    initial begin
        // Initialize to known state at time 0
        reset_n = 1'b0;
        data_in = 1'b0;
        shift_enable = 1'b0;

        // Test 1: Reset Functionality
        @(negedge clk);
        expected_data_out = 8'b00000000;
        #1;  // Sample the output after reset
        if (data_out !== expected_data_out) begin
            $display("RESET FAILED: Expected: %b, Got: %b", expected_data_out, data_out);
            errors = errors + 1;
        end

        // Immediately prepare for the next test
        reset_n = 1'b1;
        data_in = 1'b1;
        shift_enable = 1'b1;
        
        // Test 2: Shift data when enabled
        @(negedge clk);
        expected_data_out = 8'b00000001;
        #1;
        if (data_out !== expected_data_out) begin
            $display("SHIFT FAILED: Expected: %b, Got: %b", expected_data_out, data_out);
            errors = errors + 1;
        end

        // Prepare for hold test
        data_in = 1'b0;
        shift_enable = 1'b0;

        // Test 3: Hold when shift_enable is low
        @(negedge clk);
        expected_data_out = 8'b00000001;
        #1;
        if (data_out !== expected_data_out) begin
            $display("HOLD FAILED: Expected: %b, Got: %b", expected_data_out, data_out);
            errors = errors + 1;
        end

        // Prepare to continue shifting when enabled
        shift_enable = 1'b1;

        // Test 4: Continue shifting when enabled
        @(negedge clk);
        expected_data_out = 8'b00000010;
        #1;
        if (data_out !== expected_data_out) begin
            $display("CONTINUE SHIFT FAILED: Expected: %b, Got: %b", expected_data_out, data_out);
            errors = errors + 1;
        end

        // Print test results
        if (errors == 0) begin
            $display("All tests passed!");
        end else begin
            $display("%0d test(s) failed.", errors);
        end

        $finish;
    end
endmodule