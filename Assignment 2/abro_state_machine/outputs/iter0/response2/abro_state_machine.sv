module abro_state_machine (
    input        clk,
    input        rst_n,
    input        A,
    input        B,
    output reg   O,
    output reg [3:0] State
);

    // State encoding - using one-hot representation
    localparam S_IDLE   = 4'b0001,
               S_A      = 4'b0010,
               S_B      = 4'b0100,
               S_AB     = 4'b1000;

    reg [3:0] current_state, next_state;

    // State transition and output logic
    always @ (posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            current_state <= S_IDLE;
            O <= 0;
        end else begin
            current_state <= next_state;
        end
    end

    // Next state logic
    always @ (*) begin
        case (current_state)
            S_IDLE: begin
                if (A & B) begin
                    next_state = S_AB;
                    O = 1;
                end else if (A) begin
                    next_state = S_A;
                    O = 0;
                end else if (B) begin
                    next_state = S_B;
                    O = 0;
                end else begin
                    next_state = S_IDLE;
                    O = 0;
                end
            end

            S_A: begin
                if (B) begin
                    next_state = S_AB;
                    O = 1;
                end else begin
                    next_state = S_A;
                    O = 0;
                end
            end

            S_B: begin
                if (A) begin
                    next_state = S_AB;
                    O = 1;
                end else begin
                    next_state = S_B;
                    O = 0;
                end
            end

            S_AB: begin
                next_state = S_IDLE;
                O = 0;
            end

            default: begin
                next_state = S_IDLE;
                O = 0;
            end
        endcase
    end

    // Output current state for verification
    always @ (posedge clk or negedge rst_n) begin
        if (!rst_n)
            State <= S_IDLE;
        else
            State <= current_state;
    end

endmodule
