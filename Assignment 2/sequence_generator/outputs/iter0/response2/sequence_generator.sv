module sequence_generator (
    input        clk,
    input        reset_n,
    input        enable,
    output reg [7:0] data
);
    // Internal register to hold the current state of the sequence
    reg [2:0] state;

    // Sequence of values to be output
    reg [7:0] sequence [0:7];

    // Initialize the sequence
    initial begin
        sequence[0] = 8'hAF;
        sequence[1] = 8'hBC;
        sequence[2] = 8'hE2;
        sequence[3] = 8'h78;
        sequence[4] = 8'hFF;
        sequence[5] = 8'hE2;
        sequence[6] = 8'h0B;
        sequence[7] = 8'h8D;
    end

    // Sequential logic to update state and data
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            state <= 3'b000;  // Reset state to 0
            data <= 8'h00;    // Reset data output
        end else if (enable) begin
            data <= sequence[state];   // Output current value in sequence
            state <= state + 1;        // Move to the next state
            if (state == 3'b111) begin
                state <= 3'b000;       // Wrap around to the first state
            end
        end
    end
endmodule
