
module dice_roller (
    input wire clk,               // Clock input
    input wire rst_n,             // Active-low reset
    input wire [1:0] die_select,  // 2-bit die select input
    input wire roll,              // Roll input signal
    output reg [7:0] rolled_number // Rolled number output
);

    // Internal variable for the maximum number on the die
    reg [7:0] max_number;

    // Calculate maximum number for the selected die type
    always @(*) begin
        case (die_select)
            2'b00: max_number = 4;    // 4-sided die
            2'b01: max_number = 6;    // 6-sided die
            2'b10: max_number = 8;    // 8-sided die
            2'b11: max_number = 20;   // 20-sided die
            default: max_number = 0;  // Default case (shouldn't happen)
        endcase
    end

    // The roll logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rolled_number <= 0;
        end else if (roll) begin
            rolled_number <= ($random % max_number) + 1;
        end
    end

endmodule
