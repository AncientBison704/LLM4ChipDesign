
module cpu_tb;
    reg clk;
    reg reset;
    wire [3:0] pc;
    wire [7:0] acc;
    wire [7:0] memory_address;
    wire [7:0] data_bus;

    // Instantiate the CPU
    cpu uut (
        .clk(clk),
        .reset(reset),
        .pc(pc),
        .acc(acc),
        .memory_address(memory_address),
        .data_bus(data_bus)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10 time units period
    end

    // Test sequence
    initial begin
        // Initialize
        reset = 1;
        #10 reset = 0;

        // Program setup
        inject_program();

        // Wait for enough cycles to ensure execution
        repeat (12) @(posedge clk);

        // Check results
        check_results();

        $finish;
    end

    // Program injection into the memory
    task inject_program;
        begin
            uut.memory[0] = 8'b00000101; // LOAD 5 into ACC
            uut.memory[1] = 8'b00010101; // ADD 5 to ACC, ACC = 10
            uut.memory[2] = 8'b00100011; // SUB 3 from ACC, ACC = 7
            uut.memory[3] = 8'b01010001; // XOR with 1, ACC = 6
            uut.memory[4] = 8'b01101010; // STORE ACC to memory[10]
            uut.memory[5] = 8'b01110101; // JUMP to address 5 (jump-to-self/halt)
        end
    endtask

    // Results checking
    task check_results;
        begin
            // Check if the final state of the accumulator is correct
            if (acc == 8'b00000110) // Expected: 6
                $display("PASS: Accumulator value is correct.");
            else
                $display("FAIL: Incorrect accumulator value. Expected 6, got %d", acc);

            // Check the memory storage result
            if (uut.memory[10] == 8'b00000110) // Expected: 6 stored in memory[10]
                $display("PASS: Memory value at address 10 is correct.");
            else
                $display("FAIL: Incorrect memory value at address 10. Expected 6, got %d", uut.memory[10]);

            // Check if PC is parked on the halt instruction
            if (pc == 4'b0101) // Program halted at address 5
                $display("PASS: Program counter is correctly parked at halt.");
            else
                $display("FAIL: Incorrect program counter location. Expected 5, got %d", pc);
        end
    endtask

endmodule
