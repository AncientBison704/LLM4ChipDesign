module dice_roller (
    input        clk,
    input        rst_n,
    input  [1:0] die_select,
    input        roll,
    output reg [7:0] rolled_number
);

    reg [7:0] max_number;
    reg [7:0] random_number;

    // Random number generation using a simple LFSR
    wire feedback = random_number[7] ^ random_number[5] ^ random_number[4] ^ random_number[3];
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            random_number <= 8'b0000_0010; // Initial seed value
        end else if (roll) begin
            random_number <= {random_number[6:0], feedback}; // Shift LFSR with feedback
        end
    end

    // Determine the max number based on die_select
    always @* begin
        case (die_select)
            2'b00: max_number = 4;    // 4-sided die
            2'b01: max_number = 6;    // 6-sided die
            2'b10: max_number = 8;    // 8-sided die
            2'b11: max_number = 20;   // 20-sided die
            default: max_number = 4;
        endcase
    end

    // Update rolled_number based on roll and max_number
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rolled_number <= 0;
        end else if (roll) begin
            rolled_number <= (random_number % max_number) + 1;
        end
    end

endmodule
