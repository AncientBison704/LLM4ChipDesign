module sequence_generator (
    input        clk,
    input        reset_n,
    input        enable,
    output reg [7:0] data
);

    // State variables
    reg [2:0] state;

    // Output sequence
    reg [7:0] sequence [0:7];

    // Initial setup
    initial begin
        sequence[0] = 8'hAF;
        sequence[1] = 8'hBC;
        sequence[2] = 8'hE2;
        sequence[3] = 8'h78;
        sequence[4] = 8'hFF;
        sequence[5] = 8'hE2;
        sequence[6] = 8'h0B;
        sequence[7] = 8'h8D;
        state = 3'b000;
    end

    // Process logic
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            state <= 3'b000;
            data <= 8'b00000000;
        end
        else if (enable) begin
            data <= sequence[state];
            state <= state + 1;
            if (state == 3'b111) begin
                state <= 3'b000;
            end
        end
    end

endmodule
