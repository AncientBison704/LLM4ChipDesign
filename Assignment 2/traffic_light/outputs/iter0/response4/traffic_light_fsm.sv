module traffic_light_fsm (
    input  clk,
    input  reset_n,
    input  enable,
    output reg red,
    output reg yellow,
    output reg green
);

    // Define state parameters
    localparam RED = 2'b00;
    localparam GREEN = 2'b01;
    localparam YELLOW = 2'b10;
    
    // State and counter registers
    reg [1:0] state;
    reg [5:0] counter; // 6-bit counter to support up to 64 clock cycles

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            // On reset, set to RED light
            state <= RED;
            counter <= 6'd0;
        end else if (enable) begin
            case (state)
                RED: begin
                    if (counter == 6'd31) begin
                        state <= GREEN;
                        counter <= 6'd0;
                    end else begin
                        counter <= counter + 1;
                    end
                end

                GREEN: begin
                    if (counter == 6'd19) begin
                        state <= YELLOW;
                        counter <= 6'd0;
                    end else begin
                        counter <= counter + 1;
                    end
                end

                YELLOW: begin
                    if (counter == 6'd6) begin
                        state <= RED;
                        counter <= 6'd0;
                    end else begin
                        counter <= counter + 1;
                    end
                end

                default: begin
                    state <= RED;
                    counter <= 6'd0;
                end
            endcase
        end
    end

    // Output logic
    always @(*) begin
        red = (state == RED);
        green = (state == GREEN);
        yellow = (state == YELLOW);
    end

endmodule
