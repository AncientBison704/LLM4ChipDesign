module dice_roller (
    input        clk,
    input        rst_n,
    input  [1:0] die_select,
    input        roll,
    output reg [7:0] rolled_number
);

    reg [3:0] max_number; // Maximum number based on die.

    // Determine maximum number based on die select.
    always @(*) begin
        case (die_select)
            2'b00: max_number = 4;  // 4-sided die
            2'b01: max_number = 6;  // 6-sided die
            2'b10: max_number = 8;  // 8-sided die
            2'b11: max_number = 20; // 20-sided die
            default: max_number = 0;
        endcase
    end
    
    // Register to hold random number
    reg [7:0] rand_num;
    
    // Random number generation or rolling logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rand_num <= 8'b0;
            rolled_number <= 8'b0;
        end else if (roll) begin
            // Simple LFSR for random number generation
            rand_num <= {rand_num[6:0], rand_num[7] ^ rand_num[5]};
            
            // Derive rolled number based on max_number
            rolled_number <= (rand_num % max_number) + 1;
        end
    end

endmodule
