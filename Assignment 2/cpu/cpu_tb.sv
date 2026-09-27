`timescale 1ns/1ps
// AutoChip-format testbench for the 8-bit accumulator CPU.
// The testbench owns the instruction ROM and two copies of the data RAM: one for the DUT and
// one for a behavioural reference CPU (cpu_ref below). Both run the same programs from reset and
// pc, acc, dwe, daddr and ddata_out are compared every cycle.
// Programs:
//   1. sum loop: acc = 5+4+3+2+1 using LDA/ADD/STA/SUB/JZ/JMP, stores 15 to ram[30], then halts
//   2. NAND/LDI coverage program
//   3-6. random ROM and RAM contents (every opcode, taken and not-taken JZ, pc wrap-around)

module cpu_ref (
    input            clk,
    input            rst_n,
    output reg [4:0] pc,
    input      [7:0] instr,
    output     [4:0] daddr,
    input      [7:0] ddata_in,
    output     [7:0] ddata_out,
    output           dwe,
    output reg [7:0] acc
);
    wire [2:0] op = instr[7:5];
    assign daddr     = instr[4:0];
    assign ddata_out = acc;
    assign dwe       = (op == 3'b010);
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pc  <= 5'd0;
            acc <= 8'd0;
        end else begin
            pc <= pc + 5'd1;
            case (op)
                3'b000: acc <= {3'b000, instr[4:0]};
                3'b001: acc <= ddata_in;
                3'b010: ;
                3'b011: acc <= acc + ddata_in;
                3'b100: acc <= acc - ddata_in;
                3'b101: acc <= ~(acc & ddata_in);
                3'b110: pc  <= instr[4:0];
                3'b111: if (acc == 8'd0) pc <= instr[4:0];
            endcase
        end
    end
endmodule

module tb();
    reg clk = 0;
    always #5 clk = ~clk;
    reg rst_n;

    reg [7:0] rom     [0:31];
    reg [7:0] ram_dut [0:31];
    reg [7:0] ram_ref [0:31];

    wire [4:0] pc_d, daddr_d, pc_r, daddr_r;
    wire [7:0] acc_d, dout_d, acc_r, dout_r;
    wire       dwe_d, dwe_r;
    wire [7:0] instr_d = rom[pc_d];
    wire [7:0] instr_r = rom[pc_r];
    wire [7:0] din_d   = ram_dut[daddr_d];
    wire [7:0] din_r   = ram_ref[daddr_r];

    cpu dut (.clk(clk), .rst_n(rst_n), .pc(pc_d), .instr(instr_d), .daddr(daddr_d),
             .ddata_in(din_d), .ddata_out(dout_d), .dwe(dwe_d), .acc(acc_d));
    cpu_ref good (.clk(clk), .rst_n(rst_n), .pc(pc_r), .instr(instr_r), .daddr(daddr_r),
                  .ddata_in(din_r), .ddata_out(dout_r), .dwe(dwe_r), .acc(acc_r));

    always @(posedge clk) begin
        if (dwe_d === 1'b1) ram_dut[daddr_d] <= dout_d;
        if (dwe_r === 1'b1) ram_ref[daddr_r] <= dout_r;
    end

    integer errors = 0, samples = 0, i, cyc, prog;
    reg [8*20-1:0] prog_name;

    function [7:0] I(input [2:0] op, input [4:0] arg);
        I = {op, arg};
    endfunction
    localparam LDI=3'd0, LDA=3'd1, STA=3'd2, ADD=3'd3, SUB=3'd4, NAND=3'd5, JMP=3'd6, JZ=3'd7;

    task clear_mem;
        begin
            for (i = 0; i < 32; i = i + 1) begin
                rom[i] = I(JMP, i[4:0]);         // unused slots halt
                ram_dut[i] = 8'd0; ram_ref[i] = 8'd0;
            end
        end
    endtask

    task set_ram(input [4:0] a, input [7:0] v);
        begin ram_dut[a] = v; ram_ref[a] = v; end
    endtask

    task run(input integer cycles);
        begin
            rst_n = 0;
            @(negedge clk); @(negedge clk);
            rst_n = 1;
            for (cyc = 1; cyc <= cycles; cyc = cyc + 1) begin
                @(negedge clk);
                samples = samples + 1;
                if ({pc_d, acc_d, dwe_d} !== {pc_r, acc_r, dwe_r} ||
                    (dwe_r && {daddr_d, dout_d} !== {daddr_r, dout_r})) begin
                    errors = errors + 1;
                    if (errors <= 10)
                        $display("Error: %0s cycle %0d (instr=8'b%b_%b): expected pc=%0d acc=%0d dwe=%b daddr=%0d ddata_out=%0d, got pc=%0d acc=%0d dwe=%b daddr=%0d ddata_out=%0d",
                                 prog_name, cyc, instr_r[7:5], instr_r[4:0],
                                 pc_r, acc_r, dwe_r, daddr_r, dout_r, pc_d, acc_d, dwe_d, daddr_d, dout_d);
                end
            end
            $display("%0s: final acc dut=%0d ref=%0d, ram[30] dut=%0d ref=%0d", prog_name,
                     acc_d, acc_r, ram_dut[30], ram_ref[30]);
        end
    endtask

    initial begin
        rst_n = 0;

        // Program 1: sum = 5+4+3+2+1, stored to ram[30]
        prog_name = "sum loop";
        clear_mem;
        set_ram(20, 8'd1);   // constant one
        set_ram(21, 8'd5);   // n
        set_ram(22, 8'd0);   // sum
        rom[0]  = I(LDA, 21);
        rom[1]  = I(JZ,  8);
        rom[2]  = I(ADD, 22);
        rom[3]  = I(STA, 22);
        rom[4]  = I(LDA, 21);
        rom[5]  = I(SUB, 20);
        rom[6]  = I(STA, 21);
        rom[7]  = I(JMP, 0);
        rom[8]  = I(LDA, 22);
        rom[9]  = I(STA, 30);
        rom[10] = I(JMP, 10);
        run(60);

        // Program 2: LDI / NAND / not-taken JZ / wrap-free straight line
        prog_name = "ldi nand";
        clear_mem;
        set_ram(3, 8'hF0);
        rom[0] = I(LDI, 5'd31);
        rom[1] = I(NAND, 3);
        rom[2] = I(STA, 4);
        rom[3] = I(JZ, 0);
        rom[4] = I(SUB, 4);
        rom[5] = I(JZ, 7);
        rom[6] = I(LDI, 5'd1);
        rom[7] = I(ADD, 3);
        rom[8] = I(STA, 30);
        rom[9] = I(JMP, 9);
        run(20);

        // Programs 3-6: random ROM/RAM
        for (prog = 0; prog < 4; prog = prog + 1) begin
            prog_name = "random program";
            for (i = 0; i < 32; i = i + 1) begin
                rom[i] = $urandom;
                ram_dut[i] = $urandom; ram_ref[i] = ram_dut[i];
            end
            run(80);
        end
        $finish;
    end

    final begin
        $display("Hint: Total mismatched samples is %0d out of %0d samples", errors, samples);
        $display("Mismatches: %0d in %0d samples", errors, samples);
    end
endmodule
