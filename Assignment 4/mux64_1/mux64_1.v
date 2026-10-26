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
