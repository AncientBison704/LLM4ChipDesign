module mux2_1(input wire in1, input wire in2, input wire select, output wire out);
    assign out = select ? in2 : in1;
endmodule
module mux4_1(input [1:0] sel, input [3:0] in, output out);
    assign out = in[sel];
endmodule
module mux8_1(input [2:0] sel, input [7:0] in, output out);
  assign out = in[sel];
endmodule
module mux16_1(input [3:0] sel, input [15:0] in, output out);
    wire [3:0] level0;
    wire [1:0] level1;
    
    assign level0[0] = sel[1] ? in[3] : in[2];
    assign level0[1] = sel[1] ? in[1] : in[0];
    assign level0[2] = sel[1] ? in[7] : in[6];
    assign level0[3] = sel[1] ? in[5] : in[4];

    assign level1[0] = sel[2] ? level0[2] : level0[0];
    assign level1[1] = sel[2] ? level0[3] : level0[1];

    assign out = sel[3] ? in[{sel[2:0]}] : level1[sel[0]];

endmodule
