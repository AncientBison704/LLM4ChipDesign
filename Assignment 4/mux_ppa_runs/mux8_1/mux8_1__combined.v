module mux2_1(input wire in1, input wire in2, input wire select, output wire out);
    assign out = select ? in2 : in1;
endmodule
module mux4_1(input [1:0] sel, input [3:0] in, output out);
    assign out = in[sel];
endmodule
module mux8_1(input [2:0] sel, input [7:0] in, output out);
  wire [7:0] mask = 8'b00000001 << sel;
  assign out = |(in & mask);
endmodule
