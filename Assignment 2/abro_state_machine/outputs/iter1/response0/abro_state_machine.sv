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
            O <= 1'b0;
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
                if (A && B) begin
                    next_state = SAB;
                    O = 1'b1;
                end else if (A) begin
                    next_state = SA;
                end else if (B) begin
                    next_state = SB;
                end
            end
            SA: begin
                if (B) begin
                    next_state = SAB;
                    O = 1'b1;
                end
            end
            SB: begin
                if (A) begin
                    next_state = SAB;
                    O = 1'b1;
                end
            end
            SAB: begin
                O = 1'b1;  // Output high when in the SAB state
                next_state = IDLE; // Reset to IDLE
            end
            default: next_state = IDLE;
        endcase
    end

endmodule
