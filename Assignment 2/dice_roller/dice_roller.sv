module dice_roller (
    input        clk,
    input        rst_n,
    input  [1:0] die_select,
    input        roll,
    output reg [7:0] rolled_number
);

    reg [7:0] max_roll_value;

    // Determine the maximum value for the selected die
    always @(*) begin
        case (die_select)
            2'b00: max_roll_value = 8'd4;   // 4-sided die
            2'b01: max_roll_value = 8'd6;   // 6-sided die
            2'b10: max_roll_value = 8'd8;   // 8-sided die
            2'b11: max_roll_value = 8'd20;  // 20-sided die
            default: max_roll_value = 8'd0;
        endcase
    end

    // Simulate the random roll
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rolled_number <= 8'd0;
        end
        else if (roll) begin
            rolled_number <= ($random % max_roll_value) + 1;
        end
    end

endmodule

