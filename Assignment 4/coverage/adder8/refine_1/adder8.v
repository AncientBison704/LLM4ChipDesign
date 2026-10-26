module adder8(input wire [7:0] a, input wire [7:0] b, input wire cin, output wire [7:0] sum, output wire cout);
    wire carry_out_low;

    adder4 adder_low (
        .a(a[3:0]),
        .b(b[3:0]),
        .cin(cin),
        .sum(sum[3:0]),
        .cout(carry_out_low)
    );

    adder4 adder_high (
        .a(a[7:4]),
        .b(b[7:4]),
        .cin(carry_out_low),
        .sum(sum[7:4]),
        .cout(cout)
    );
endmodule
