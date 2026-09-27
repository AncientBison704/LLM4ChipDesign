module dice_roller (
    input        clk,
    input        rst_n,
    input  [1:0] die_select,
    input        roll,
    output reg [7:0] rolled_number
);

    reg [7:0] random_number;
    reg [7:0] die_max;

    // This is a simple Linear Feedback Shift Register (LFSR) for generating pseudo-random numbers
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            random_number <= 8'h1; // Initialize on reset
        end else begin
            random_number <= {random_number[6:0], random_number[7] ^ random_number[5]};
        end
    end

    // Determine the maximum number for the current die
    always @(*) begin
        case(die_select)
            2'b00: die_max = 4;
            2'b01: die_max = 6;
            2'b10: die_max = 8;
            2'b11: die_max = 20;
            default: die_max = 8;
        endcase
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rolled_number <= 0;
        end else if (roll) begin
            // Scale the random number to the range of the selected die
            rolled_number <= (random_number % die_max) + 1;
        end
    end

endmodule
