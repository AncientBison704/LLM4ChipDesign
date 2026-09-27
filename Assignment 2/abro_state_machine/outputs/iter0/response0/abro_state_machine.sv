module abro_state_machine (
    input        clk,
    input        rst_n,
    input        A,
    input        B,
    output reg   O,
    output reg [3:0] State
);

    // One-hot encoded state representation
    typedef enum reg [3:0] {
        IDLE      = 4'b0001,
        WAIT_FOR_A = 4'b0010,
        WAIT_FOR_B = 4'b0100,
        DONE      = 4'b1000
    } state_t;

    // State registers
    reg [3:0] current_state, next_state;

    // State transition and output logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            current_state <= IDLE;
            State <= 4'b0000;
            O <= 0;
        end else begin
            current_state <= next_state;
            State <= current_state; // Output current state
        end
    end

    // Next state logic
    always @* begin
        next_state = current_state; // Default to remain in same state
        O = 1'b0; // Default output

        case (current_state)
            IDLE: begin
                if (A) next_state = WAIT_FOR_B;
                else if (B) next_state = WAIT_FOR_A;
            end

            WAIT_FOR_A: begin
                if (A) next_state = DONE;
            end

            WAIT_FOR_B: begin
                if (B) next_state = DONE;
            end

            DONE: begin
                O = 1'b1; // Set the output
                if (!A && !B) next_state = IDLE; // Return to IDLE if both A and B are low
            end

            default: next_state = IDLE; // Reset to IDLE on undefined state
        endcase
    end

endmodule
