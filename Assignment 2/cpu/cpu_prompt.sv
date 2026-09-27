// Let us make a brand new microprocessor design together. We're severely constrained on space and I/O.
// We have to fit in 1000 standard cells of an ASIC, so I think we will need to restrict ourselves to an
// accumulator based 8-bit architecture with no multi-byte instructions.
//
// We have settled on the following architecture. Implement it as a single Verilog module named cpu.
//
// Architecture
//   - 8-bit accumulator (acc) and a 5-bit program counter (pc). No other architectural registers.
//   - Harvard organisation with BOTH memories outside the cpu module (to save cells):
//       * Instruction memory: 32 x 8-bit ROM. The cpu drives pc; the ROM returns instr = rom[pc]
//         combinationally in the same cycle.
//       * Data memory: 32 x 8-bit RAM. The cpu drives daddr; the RAM returns ddata_in = ram[daddr]
//         combinationally. When dwe = 1 the RAM writes ddata_out into ram[daddr] on the rising clock edge.
//   - Every instruction is exactly one byte and executes in a single clock cycle.
//   - Instruction format: instr[7:5] = opcode, instr[4:0] = operand (5-bit address or immediate).
//
// Instruction set (M = ram[operand], all arithmetic is modulo 256)
//   3'b000  LDI imm : acc <= {3'b000, imm}
//   3'b001  LDA addr: acc <= M
//   3'b010  STA addr: M <= acc            (acc unchanged)
//   3'b011  ADD addr: acc <= acc + M
//   3'b100  SUB addr: acc <= acc - M
//   3'b101  NAND addr: acc <= ~(acc & M)
//   3'b110  JMP addr: pc <= addr
//   3'b111  JZ  addr: if (acc == 0) pc <= addr, else pc <= pc + 1
//   Every instruction other than JMP and a taken JZ does pc <= pc + 1 (5-bit, wraps from 31 to 0).
//   A program halts by jumping to itself.
//
// Interface behaviour
//   - rst_n is an active-low asynchronous reset: pc <= 0 and acc <= 0.
//   - daddr is always instr[4:0].
//   - ddata_out is always acc.
//   - dwe is 1 exactly when the current instruction is STA (combinational decode of instr).
//   - acc is exported for verification.

module cpu (
    input        clk,
    input        rst_n,
    output [4:0] pc,
    input  [7:0] instr,
    output [4:0] daddr,
    input  [7:0] ddata_in,
    output [7:0] ddata_out,
    output       dwe,
    output [7:0] acc
);
