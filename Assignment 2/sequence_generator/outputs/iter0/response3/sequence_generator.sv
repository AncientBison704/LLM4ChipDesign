module sequence_generator (
    input        clk,
    input        reset_n,
    input        enable,
    output reg [7:0] data
);
    // Declare a counter to track the sequence position
    reg [2:0] counter;

    // Combinational logic to determine the sequence value based on counter
    always @(*) begin
        case (counter)
            3'd0: data = 8'hAF;
            3'd1: data = 8'hBC;
            3'd2: data = 8'hE2;
            3'd3: data = 8'h78;
            3'd4: data = 8'hFF;
            3'd5: data = 8'hE2;
            3'd6: data = 8'h0B;
            3'd7: data = 8'h8D;
            default: data = 8'h00; // Default to 0 if something unexpected occurs
        endcase
    end

    // Sequential logic for the counter
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n)
            counter <= 3'd0; // Reset the counter to 0 on active low reset
        else if (enable)
            counter <= counter + 3'd1; // Increment the counter if enabled
    end

endmodule
