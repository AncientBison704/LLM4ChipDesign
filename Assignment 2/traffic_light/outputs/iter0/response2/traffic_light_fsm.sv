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
    
    reg [5:0] counter; // 6-bit counter to support up to 64 clock cycles

    // State transition logic
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            current_state <= RED;
            counter <= 6'd0;
        end else if (enable) begin
            current_state <= next_state;
            if (counter == 6'd0 || current_state != next_state) begin
                case (next_state)
                    RED: counter <= 6'd32;
                    GREEN: counter <= 6'd20;
                    YELLOW: counter <= 6'd7;
                endcase
            end else begin
                counter <= counter - 6'd1;
            end
        end
    end

    // Next state logic
    always @(*) begin
        case (current_state)
            RED: next_state = (counter == 6'd0) ? GREEN : RED;
            GREEN: next_state = (counter == 6'd0) ? YELLOW : GREEN;
            YELLOW: next_state = (counter == 6'd0) ? RED : YELLOW;
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
        endcase
    end

endmodule
