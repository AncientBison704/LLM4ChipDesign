module abro_state_machine (
    input        clk,
    input        rst_n,
    input        A,
    input        B,
    output reg   O,
    output reg [3:0] State
);

    // Define the states using one-hot encoding
    localparam IDLE      = 4'b0001;
    localparam SA        = 4'b0010;
    localparam SB        = 4'b0100;
    localparam SAB       = 4'b1000;

    reg [3:0] current_state, next_state;

    // State transition logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            current_state <= IDLE;  // Reset to IDLE state on active low reset
        else
            current_state <= next_state;  // Move to the next state
    end

    // Next state logic
    always @(*) begin
        case (current_state)
            IDLE: begin
                if (A && B)
                    next_state = SAB;
                else if (A)
                    next_state = SA;
                else if (B)
                    next_state = SB;
                else
                    next_state = IDLE;
            end

            SA: begin
                if (B)
                    next_state = SAB;
                else
                    next_state = SA;
            end

            SB: begin
                if (A)
                    next_state = SAB;
                else
                    next_state = SB;
            end

            SAB: begin
                next_state = IDLE;
            end

            default: begin
                next_state = IDLE;  // Default state
            end
        endcase
    end

    // Output logic
    always @(*) begin
        case (current_state)
            SAB: O = 1'b1;
            default: O = 1'b0;
        endcase
    end

    // Assign current_state to the output State
    always @(*) begin
        State = current_state;
    end

endmodule
