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
