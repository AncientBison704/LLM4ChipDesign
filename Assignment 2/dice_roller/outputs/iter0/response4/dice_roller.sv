module dice_roller (
    input        clk,
    input        rst_n,
    input  [1:0] die_select,
    input        roll,
    output reg [7:0] rolled_number
);

    reg [7:0] max_value;

    // Define RNG states
    reg [7:0] lfsr;
    wire feedback = lfsr[7] ^ lfsr[5] ^ lfsr[4] ^ lfsr[3];

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            lfsr <= 8'b00000001; // Initialize LFSR with non-zero value
            rolled_number <= 8'b0;
            max_value <= 8'b0;
        end else if (roll) begin
            // Generate next state of LFSR
            lfsr <= {lfsr[6:0], feedback};

            // Set maximum value based on die select
            case (die_select)
                2'b00: max_value <= 8'd4;   // 4-sided die
                2'b01: max_value <= 8'd6;   // 6-sided die
                2'b10: max_value <= 8'd8;   // 8-sided die
                2'b11: max_value <= 8'd20;  // 20-sided die
                default: max_value <= 8'd4;
            endcase

            // Calculate rolled number
            rolled_number <= (lfsr % max_value) + 1;
        end
    end

endmodule
