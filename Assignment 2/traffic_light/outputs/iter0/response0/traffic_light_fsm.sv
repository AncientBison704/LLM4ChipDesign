module traffic_light_fsm (
    input  clk,
    input  reset_n,
    input  enable,
    output reg red,
    output reg yellow,
    output reg green
);

    // Define states
    typedef enum reg [1:0] {
        RED = 2'b00,
        GREEN = 2'b01,
        YELLOW = 2'b10
    } state_t;

    state_t current_state, next_state;
    reg [5:0] counter;  // Counter to monitor clock cycles

    // State transition logic
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            current_state <= RED;
            counter <= 6'd0;
        end
        else if (enable) begin
            current_state <= next_state;
        end
    end

    // Next state logic and counter management
    always @(*) begin
        case (current_state)
            RED: begin
                if (counter == 6'd31) begin
                    next_state = GREEN;
                    counter = 6'd0;
                end else begin
                    next_state = RED;
                    counter = counter + 1;
                end
            end

            GREEN: begin
                if (counter == 6'd19) begin
                    next_state = YELLOW;
                    counter = 6'd0;
                end else begin
                    next_state = GREEN;
                    counter = counter + 1;
                end
            end

            YELLOW: begin
                if (counter == 6'd6) begin
                    next_state = RED;
                    counter = 6'd0;
                end else begin
                    next_state = YELLOW;
                    counter = counter + 1;
                end
            end

            default: begin
                next_state = RED;
                counter = 6'd0;
            end
        endcase
    end

    // Output logic
    always @(*) begin
        case (current_state)
            RED: begin
                red = 1'b1;
                yellow = 1'b0;
                green = 1'b0;
            end

            GREEN: begin
                red = 1'b0;
                yellow = 1'b0;
                green = 1'b1;
            end

            YELLOW: begin
                red = 1'b0;
                yellow = 1'b1;
                green = 1'b0;
            end

            default: begin
                red = 1'b1;
                yellow = 1'b0;
                green = 1'b0;
            end
        endcase
    end

endmodule
