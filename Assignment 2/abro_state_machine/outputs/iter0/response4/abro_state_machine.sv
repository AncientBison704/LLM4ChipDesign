module abro_state_machine (
    input        clk,
    input        rst_n,
    input        A,
    input        B,
    output reg   O,
    output reg [3:0] State
);

// State encoding
localparam [3:0]
    IDLE  = 4'b0001,
    SA    = 4'b0010,
    SB    = 4'b0100,
    SAB   = 4'b1000;

// State variables
reg [3:0] current_state, next_state;

// State transition logic
always @(*) begin
    case (current_state)
        IDLE: begin
            if (A)      next_state = SA;
            else if (B) next_state = SB;
            else        next_state = IDLE;
        end
        SA: begin
            if (B)      next_state = SAB;
            else        next_state = SA;
        end
        SB: begin
            if (A)      next_state = SAB;
            else        next_state = SB;
        end
        SAB: begin
            next_state = IDLE; // Reset after output condition is met
        end
        default: begin
            next_state = IDLE; // Default case to handle unknown states
        end
    endcase
end

// State register
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        current_state <= IDLE;
    end else begin
        current_state <= next_state;
    end
end

// Output logic
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        O <= 1'b0;
        State <= IDLE;
    end else begin
        O <= (current_state == SAB);
        State <= current_state;
    end
end

endmodule
