module sequence_detector (
    input        clk,
    input        reset_n,
    input  [2:0] data,
    output reg   sequence_found
);
    reg [2:0] state, next_state;

    // State encoding
    localparam IDLE    = 3'd0,
               S0      = 3'd1,
               S1      = 3'd2,
               S2      = 3'd3,
               S3      = 3'd4,
               S4      = 3'd5,
               S5      = 3'd6,
               S6      = 3'd7;

    // State transition logic
    always @ (posedge clk or negedge reset_n) begin
        if (!reset_n)
            state <= IDLE;
        else
            state <= next_state;
    end

    // Next state logic and output logic
    always @ (*) begin
        next_state = state; // Default state stays the same
        sequence_found = 1'b0;

        case (state)
            IDLE: 
                if (data == 3'b001)
                    next_state = S0;

            S0: 
                if (data == 3'b101)
                    next_state = S1;
                else if (data == 3'b001)
                    next_state = S0;
                else
                    next_state = IDLE;

            S1: 
                if (data == 3'b110)
                    next_state = S2;
                else if (data == 3'b001)
                    next_state = S0;
                else
                    next_state = IDLE;

            S2: 
                if (data == 3'b000)
                    next_state = S3;
                else if (data == 3'b001)
                    next_state = S0;
                else
                    next_state = IDLE;

            S3: 
                if (data == 3'b110)
                    next_state = S4;
                else if (data == 3'b001)
                    next_state = S0;
                else
                    next_state = IDLE;

            S4: 
                if (data == 3'b110)
                    next_state = S5;
                else if (data == 3'b001)
                    next_state = S0;
                else
                    next_state = IDLE;

            S5: 
                if (data == 3'b011)
                    next_state = S6;
                else if (data == 3'b001)
                    next_state = S0;
                else
                    next_state = IDLE;

            S6: 
                if (data == 3'b101) begin
                    next_state = IDLE;
                    sequence_found = 1'b1; // Sequence completed
                end
                else if (data == 3'b001)
                    next_state = S0;
                else
                    next_state = IDLE;

            default: 
                next_state = IDLE;
        endcase
    end
endmodule

