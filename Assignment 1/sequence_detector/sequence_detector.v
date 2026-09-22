
module sequence_detector (
    input        clk,
    input        reset_n,
    input  [2:0] data,
    output       sequence_found
);
    reg [2:0] state;

    assign sequence_found = (state == 3'd7) && (data == 3'b101);

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n)
            state <= 3'd0;
        else begin
            case (state)
                3'd0: state <= (data == 3'b001) ? 3'd1 : 3'd0;
                3'd1: state <= (data == 3'b101) ? 3'd2 : (data == 3'b001) ? 3'd1 : 3'd0;
                3'd2: state <= (data == 3'b110) ? 3'd3 : (data == 3'b001) ? 3'd1 : 3'd0;
                3'd3: state <= (data == 3'b000) ? 3'd4 : (data == 3'b001) ? 3'd1 : 3'd0;
                3'd4: state <= (data == 3'b110) ? 3'd5 : (data == 3'b001) ? 3'd1 : 3'd0;
                3'd5: state <= (data == 3'b110) ? 3'd6 : (data == 3'b001) ? 3'd1 : 3'd0;
                3'd6: state <= (data == 3'b011) ? 3'd7 : (data == 3'b001) ? 3'd1 : 3'd0;
                3'd7: state <= (data == 3'b001) ? 3'd1 : 3'd0;
                default: state <= 3'd0;
            endcase
        end
    end
endmodule

