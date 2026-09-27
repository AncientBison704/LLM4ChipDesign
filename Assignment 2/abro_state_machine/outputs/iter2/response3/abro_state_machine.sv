module abro_state_machine (
    input        clk,
    input        rst_n,
    input        A,
    input        B,
    output reg   O,
    output reg [3:0] State
);

    // One-hot encoded state representation
    parameter IDLE  = 4'b0001;
    parameter SA    = 4'b0010;
    parameter SB    = 4'b0100;
    parameter SAB   = 4'b1000;

    reg [3:0] next_state;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            State <= IDLE;
        end else begin
            State <= next_state;
        end
    end

    always @(*) begin
        // Default assignments
        next_state = State;
        O = 1'b0;
        
        case (State)
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
                O = 1'b1; // Output should be set for SAB state
                next_state = IDLE;
            end
            default: next_state = IDLE;
        endcase
    end

endmodule
