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

    state_t current_state, next_state;

    reg [5:0] counter; // 6-bit counter to count up to 63

    // State transition logic
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            current_state <= RED;
            counter <= 0;
        end else if (enable) begin
            current_state <= next_state;
            if (current_state == next_state) begin
                counter <= counter + 1;
            end else begin
                counter <= 0;
            end
        end
    end

    // Next state logic and output logic
    always @(*) begin
        red = 0;
        yellow = 0;
        green = 0;
        case (current_state)
            RED: begin
                red = 1;
                if (counter >= 32) begin
                    next_state = GREEN;
                end else begin
                    next_state = RED;
                end
            end
            GREEN: begin
                green = 1;
                if (counter >= 20) begin
                    next_state = YELLOW;
                end else begin
                    next_state = GREEN;
                end
            end
            YELLOW: begin
                yellow = 1;
                if (counter >= 7) begin
                    next_state = RED;
                end else begin
                    next_state = YELLOW;
                end
            end
            default: next_state = RED;
        endcase
    end
endmodule
