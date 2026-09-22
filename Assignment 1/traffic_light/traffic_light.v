
module traffic_light_fsm(
    input wire clk,
    input wire reset_n,   // Active-low reset
    input wire enable,
    output reg red,
    output reg yellow,
    output reg green
);

    // State definitions
    parameter STATE_RED = 2'b00;
    parameter STATE_GREEN = 2'b01;
    parameter STATE_YELLOW = 2'b10;

    // State and counter variables
    reg [1:0] current_state;
    reg [5:0] cycle_counter; // 6-bit counter to hold values up to 63

    // State duration constants
    parameter RED_DURATION = 6'd32;
    parameter GREEN_DURATION = 6'd20;
    parameter YELLOW_DURATION = 6'd7;

    // Sequential logic for state and counter management
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            current_state <= STATE_RED;
            cycle_counter <= 6'd1;
        end else if (enable) begin
            if ((current_state == STATE_RED && cycle_counter == RED_DURATION) ||
                (current_state == STATE_GREEN && cycle_counter == GREEN_DURATION) ||
                (current_state == STATE_YELLOW && cycle_counter == YELLOW_DURATION)) begin
                // State transition based on current state and counter
                current_state <= (current_state == STATE_RED) ? STATE_GREEN :
                                 (current_state == STATE_GREEN) ? STATE_YELLOW :
                                 STATE_RED;
                cycle_counter <= 6'd1;
            end else begin
                cycle_counter <= cycle_counter + 6'd1;
            end
        end
    end

    // Combinational logic for outputs
    always @(*) begin
        // Default to all lights off
        red = 1'b0;
        yellow = 1'b0;
        green = 1'b0;

        case (current_state)
            STATE_RED: red = 1'b1;
            STATE_GREEN: green = 1'b1;
            STATE_YELLOW: yellow = 1'b1;
        endcase
    end

endmodule
