module traffic_light_fsm (
    input  clk,
    input  reset_n,
    input  enable,
    output reg red,
    output reg yellow,
    output reg green
);

    // State encoding
    typedef enum reg [1:0] {
        RED = 2'b00,
        GREEN = 2'b01,
        YELLOW = 2'b10
    } state_t;

    reg [1:0] current_state, next_state;
    reg [5:0] counter;  // Counter to count clock cycles

    // Next state logic and counter management
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            current_state <= RED;
            counter <= 6'd0;
        end else if (enable) begin
            current_state <= next_state;
            counter <= (next_state == current_state) ? counter + 6'd1 : 6'd0;
        end
    end

    // State transitions
    always @(*) begin
        case (current_state)
            RED: begin
                if (counter >= 6'd31)
                    next_state = GREEN;
                else
                    next_state = RED;
            end
            GREEN: begin
                if (counter >= 6'd19)
                    next_state = YELLOW;
                else
                    next_state = GREEN;
            end
            YELLOW: begin
                if (counter >= 6'd6)
                    next_state = RED;
                else
                    next_state = YELLOW;
            end
            default: next_state = RED;
        endcase
    end

    // Output logic
    always @(*) begin
        red = (current_state == RED);
        yellow = (current_state == YELLOW);
        green = (current_state == GREEN);
    end

endmodule

