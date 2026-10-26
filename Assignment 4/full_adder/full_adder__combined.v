module half_adder(input wire a, input wire b, output wire sum, output wire cout);
    assign sum = a ^ b;
    assign cout = a & b;
endmodule
module full_adder(input wire a, input wire b, input wire cin, output wire sum, output wire cout);
    wire sum1, c1, c2;

    half_adder ha1 (
        .a(a),
        .b(b),
        .sum(sum1),
        .cout(c1)
    );

    half_adder ha2 (
        .a(sum1),
        .b(cin),
        .sum(sum),
        .cout(c2)
    );

    assign cout = c1 | c2;
endmodule
