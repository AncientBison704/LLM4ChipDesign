
module sequence_generator(
    input wire clk,          // Clock signal
    input wire reset_n,      // Active-low reset
    input wire enable,       // Enable signal
    output reg [7:0] data    // 8-bit data output
);
    // State counter to determine which sequence value to output
    reg [2:0] state;

    // Sequence values
    localparam [7:0] SEQ_0 = 8'hAF;
    localparam [7:0] SEQ_1 = 8'hBC;
    localparam [7:0] SEQ_2 = 8'hE2;
    localparam [7:0] SEQ_3 = 8'h78;
    localparam [7:0] SEQ_4 = 8'hFF;
    localparam [7:0] SEQ_5 = 8'hE2;
    localparam [7:0] SEQ_6 = 8'h0B;
    localparam [7:0] SEQ_7 = 8'h8D;

    // Process that updates the state and output data on the rising edge of the clock
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            // Reset state and output data to initial value
            state <= 3'b000;
            data <= SEQ_0;
        end else if (enable) begin
            // If enabled, output the next value in the sequence
            case (state)
                3'b000: data <= SEQ_1;
                3'b001: data <= SEQ_2;
                3'b010: data <= SEQ_3;
                3'b011: data <= SEQ_4;
                3'b100: data <= SEQ_5;
                3'b101: data <= SEQ_6;
                3'b110: data <= SEQ_7;
                3'b111: data <= SEQ_0;
                default: data <= SEQ_0; // Default case - initialized to the first element
            endcase
            // Advance to the next state
            state <= state + 1;
        end
    end

endmodule
