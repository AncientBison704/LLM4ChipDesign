module sequence_detector (
    input        clk,
    input        reset_n,
    input  [2:0] data,
    output reg   sequence_found
);

    // State encoding
    reg [3:0] current_state, next_state;
    localparam S0 = 4'd0,
               S1 = 4'd1,
               S2 = 4'd2,
               S3 = 4'd3,
               S4 = 4'd4,
               S5 = 4'd5,
               S6 = 4'd6,
               S7 = 4'd7,
               S8 = 4'd8;  // Final state where sequence is detected

    // State transition
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            current_state <= S0;
        end else begin
            current_state <= next_state;
        end
    end

    // Next state logic
    always @* begin
        next_state = current_state;
        sequence_found = 1'b0;
        case(current_state)
            S0: if (data == 3'b001) next_state = S1;
            S1: if (data == 3'b101) next_state = S2; else next_state = S0;
            S2: if (data == 3'b110) next_state = S3; else next_state = S0;
            S3: if (data == 3'b000) next_state = S4; else next_state = S0;
            S4: if (data == 3'b110) next_state = S5; else next_state = S0;
            S5: if (data == 3'b110) next_state = S6; else next_state = S0;
            S6: if (data == 3'b011) next_state = S7; else next_state = S0;
            S7: if (data == 3'b101) next_state = S8; else next_state = S0;
            S8: begin
                sequence_found = 1'b1;
                if (data == 3'b001) next_state = S1; else next_state = S0;
            end
            default: next_state = S0;
        endcase
    end

endmodule
