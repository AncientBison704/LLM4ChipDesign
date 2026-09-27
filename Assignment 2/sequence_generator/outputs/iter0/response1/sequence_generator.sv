module sequence_generator (
    input        clk,
    input        reset_n,
    input        enable,
    output reg [7:0] data
);

    // State encoding for the sequence
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

    // Update sequence
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            state <= 3'd0;
            data <= SEQ_0;
        end else if (enable) begin
            case (state)
                3'd0: begin
                    data <= SEQ_0;
                    state <= 3'd1;
                end
                3'd1: begin
                    data <= SEQ_1;
                    state <= 3'd2;
                end
                3'd2: begin
                    data <= SEQ_2;
                    state <= 3'd3;
                end
                3'd3: begin
                    data <= SEQ_3;
                    state <= 3'd4;
                end
                3'd4: begin
                    data <= SEQ_4;
                    state <= 3'd5;
                end
                3'd5: begin
                    data <= SEQ_5;
                    state <= 3'd6;
                end
                3'd6: begin
                    data <= SEQ_6;
                    state <= 3'd7;
                end
                3'd7: begin
                    data <= SEQ_7;
                    state <= 3'd0;
                end
                default: begin
                    data <= SEQ_0;
                    state <= 3'd0;
                end
            endcase
        end
    end

endmodule
