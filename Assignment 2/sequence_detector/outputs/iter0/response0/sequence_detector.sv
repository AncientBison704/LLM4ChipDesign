module sequence_detector (
    input        clk,
    input        reset_n,
    input  [2:0] data,
    output reg   sequence_found
);
    // State encoding
    localparam [3:0] 
        S0 = 4'b0000,
        S1 = 4'b0001,
        S2 = 4'b0010,
        S3 = 4'b0011,
        S4 = 4'b0100,
        S5 = 4'b0101,
        S6 = 4'b0110,
        S7 = 4'b0111,
        S8 = 4'b1000,
        FOUND = 4'b1001;
        
    reg [3:0] current_state, next_state;
    
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n)
            current_state <= S0;
        else
            current_state <= next_state;
    end

    always @(*) begin
        case (current_state)
            S0: if (data == 3'b001) next_state = S1; else next_state = S0;
            S1: if (data == 3'b101) next_state = S2; else next_state = S0;
            S2: if (data == 3'b110) next_state = S3; else next_state = S0;
            S3: if (data == 3'b000) next_state = S4; else next_state = S0;
            S4: if (data == 3'b110) next_state = S5; else next_state = S0;
            S5: if (data == 3'b110) next_state = S6; else next_state = S0;
            S6: if (data == 3'b011) next_state = S7; else next_state = S0;
            S7: if (data == 3'b101) next_state = FOUND; else next_state = S0;
            FOUND: next_state = S0;
            default: next_state = S0;
        endcase
    end
    
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n)
            sequence_found <= 1'b0;
        else if (current_state == FOUND)
            sequence_found <= 1'b1;
        else
            sequence_found <= 1'b0;
    end

endmodule
