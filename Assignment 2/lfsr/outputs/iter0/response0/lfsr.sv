module lfsr (
    input        clk,
    input        reset_n,
    output reg [7:0] data
);

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n)
            data <= 8'b10001010; // Initial state
        else begin
            // LFSR with taps at bits 1, 4, 6, and 7
            data <= {data[6], data[5], data[4], data[3], 
                     data[2], data[1], data[0], 
                     data[7] ^ data[5] ^ data[3] ^ data[2]};
        end
    end

endmodule
