`timescale 1ns/1ps
// AutoChip-format testbench for abro_state_machine.
// Reproduces the GUIDE abro_state_machine_tb.v expectations without its sampling race.
// Inputs change on the falling edge, the design samples them on the rising edge, and
// O/State are checked before the next falling edge. The GUIDE contract is:
//   reset -> State = 4'b0001
//   A=1,B=0 -> State becomes 4'b0010      A=0,B=1 -> State becomes 4'b0001
//   A=1,B=1 -> State becomes 4'b0100      A=0,B=0 -> State holds
//   O = A & B
module tb();
    reg clk = 0;
    always #5 clk = ~clk;
    reg rst_n, A, B;
    wire O;
    wire [3:0] State;
    reg  [3:0] exp_state;
    integer errors = 0, samples = 0, k;

    abro_state_machine dut (.clk(clk), .rst_n(rst_n), .A(A), .B(B), .O(O), .State(State));

    task step(input a, input b);
        begin
            @(negedge clk);
            A = a; B = b;
            @(posedge clk);
            case ({a, b})
                2'b10: exp_state = 4'b0010;
                2'b01: exp_state = 4'b0001;
                2'b11: exp_state = 4'b0100;
                default: exp_state = exp_state;
            endcase
            #1;
            samples = samples + 1;
            if (O !== (a & b) || State !== exp_state) begin
                errors = errors + 1;
                if (errors <= 10)
                    $display("Error: A=%b B=%b -> expected O=%b State=%b, got O=%b State=%b",
                             a, b, a & b, exp_state, O, State);
            end
        end
    endtask

    initial begin
        rst_n = 0; A = 0; B = 0; exp_state = 4'b0001;
        @(negedge clk); @(negedge clk);
        samples = samples + 1;
        if (State !== 4'b0001 || O !== 1'b0) begin
            errors = errors + 1;
            $display("Error: during reset expected O=0 State=0001, got O=%b State=%b", O, State);
        end
        rst_n = 1;
        // same 16-case sequence as the GUIDE bench: 00, 01, 10, 11, then (i-1)%2 / ((i-1)/2)%2 pattern
        step(0,0); step(0,1); step(1,0); step(1,1);
        for (k = 4; k < 16; k = k + 1)
            step((k-1) % 2, ((k-1) / 2) % 2);
        // random traffic
        for (k = 0; k < 60; k = k + 1)
            step($urandom, $urandom);
        $finish;
    end

    final begin
        $display("Hint: Total mismatched samples is %0d out of %0d samples", errors, samples);
        $display("Mismatches: %0d in %0d samples", errors, samples);
    end
endmodule
