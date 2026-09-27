module sequence_detector (
    input        clk,
    input        reset_n,
    input  [2:0] data,
    output reg   sequence_found
);

    // Enumeration for states
    typedef enum logic [2:0] {
        IDLE        = 3'b000,
        STATE_001   = 3'b001,
        STATE_101   = 3'b010,
        STATE_110_1 = 3'b011,
        STATE_000   = 3'b100,
        STATE_110_2 = 3'b101,
        STATE_110_3 = 3'b110,
        STATE_011   = 3'b111,
        FINAL_STATE = 3'b110
    } state_t;

    state_t current_state, next_state;

    // State transition logic
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n)
            current_state <= IDLE;
        else
            current_state <= next_state;
    end

    // Next state logic
    always @(*) begin
        sequence_found = 1'b0; // Default to not found
        case (current_state)
            IDLE: begin
                if (data == 3'b001) 
                    next_state = STATE_001;
                else
                    next_state = IDLE;
            end
            STATE_001: begin
                if (data == 3'b101)
                    next_state = STATE_101;
                else
                    next_state = IDLE;
            end
            STATE_101: begin
                if (data == 3'b110)
                    next_state = STATE_110_1;
                else
                    next_state = IDLE;
            end
            STATE_110_1: begin
                if (data == 3'b000)
                    next_state = STATE_000;
                else
                    next_state = IDLE;
            end
            STATE_000: begin
                if (data == 3'b110)
                    next_state = STATE_110_2;
                else
                    next_state = IDLE;
            end
            STATE_110_2: begin
                if (data == 3'b110)
                    next_state = STATE_110_3;
                else
                    next_state = IDLE;
            end
            STATE_110_3: begin
                if (data == 3'b011)
                    next_state = STATE_011;
                else
                    next_state = IDLE;
            end
            STATE_011: begin
                if (data == 3'b101) begin
                    next_state = FINAL_STATE;
                    sequence_found = 1'b1;
                end else begin
                    next_state = IDLE;
                end
            end
            FINAL_STATE: begin
                next_state = IDLE;
            end
            default: next_state = IDLE;
        endcase
    end

endmodule
