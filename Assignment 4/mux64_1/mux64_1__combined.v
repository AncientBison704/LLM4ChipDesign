module mux2_1(input wire in1, input wire in2, input wire select, output wire out);
  assign out = select ? in2 : in1;
endmodule
module mux4_1(input [1:0] sel, input [3:0] in, output reg out);
    always @(*) begin
        case (sel)
            2'b00: out = in[0];
            2'b01: out = in[1];
            2'b10: out = in[2];
            2'b11: out = in[3];
            default: out = 1'b0;
        endcase
    end
endmodule
module mux8_1(input [2:0] sel, input [7:0] in, output wire out);
    wire out0, out1;

    mux4_1 mux_lower(
        .sel(sel[1:0]),
        .in(in[3:0]),
        .out(out0)
    );

    mux4_1 mux_upper(
        .sel(sel[1:0]),
        .in(in[7:4]),
        .out(out1)
    );

    mux2_1 mux_final(
        .in1(out0),
        .in2(out1),
        .select(sel[2]),
        .out(out)
    );
endmodule
module mux16_1(input [3:0] sel, input [15:0] in, output wire out);
    wire out1, out2;

    mux8_1 mux_first(.sel(sel[2:0]), .in(in[7:0]), .out(out1));
    mux8_1 mux_second(.sel(sel[2:0]), .in(in[15:8]), .out(out2));
    mux2_1 mux_final (.in1(out1), .in2(out2), .select(sel[3]), .out(out));
endmodule
module mux32_1(input [4:0] sel, input [31:0] in, output wire out);
    wire out1, out2;

    mux16_1 mux1 (
        .sel(sel[3:0]), 
        .in(in[15:0]), 
        .out(out1)
    );

    mux16_1 mux2 (
        .sel(sel[3:0]), 
        .in(in[31:16]), 
        .out(out2)
    );

    mux2_1 mux3 (
        .in1(out1), 
        .in2(out2), 
        .select(sel[4]), 
        .out(out)
    );
endmodule
module mux64_1(input [5:0] sel, input [63:0] in, output wire out);

  wire out0, out1;

  mux32_1 mux32_1_0 (
    .sel(sel[4:0]),
    .in(in[31:0]),
    .out(out0)
  );

  mux32_1 mux32_1_1 (
    .sel(sel[4:0]),
    .in(in[63:32]),
    .out(out1)
  );

  mux2_1 mux2_1_0 (
    .in1(out0),
    .in2(out1),
    .select(sel[5]),
    .out(out)
  );

endmodule
