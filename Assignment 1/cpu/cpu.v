
module cpu (
    input wire clk,
    input wire reset,
    output reg [3:0] pc,  // Program Counter
    output reg [7:0] acc, // Accumulator
    output wire [7:0] memory_address,
    inout wire [7:0] data_bus
);

    wire [7:0] instruction;
    reg [7:0] memory[0:15]; // Small memory for illustration

    assign memory_address = pc;
    assign instruction = memory[pc];

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            pc <= 4'b0000;  // Reset program counter
            acc <= 8'b00000000; // Reset accumulator
        end else begin
            case (instruction[7:4]) // Opcode
                4'b0000: acc <= instruction[3:0]; // LOAD
                4'b0001: acc <= acc + instruction[3:0]; // ADD
                4'b0010: acc <= acc - instruction[3:0]; // SUB
                4'b0011: acc <= acc & instruction[3:0]; // AND
                4'b0100: acc <= acc | instruction[3:0]; // OR
                4'b0101: acc <= acc ^ instruction[3:0]; // XOR
                4'b0110: memory[instruction[3:0]] <= acc; // STORE
                4'b0111: pc <= instruction[3:0]; // JUMP
                default: pc <= pc + 1; // Increment Program Counter
            endcase
            if (instruction[7:4] != 4'b0111)
                pc <= pc + 1; // Increment PC, except for JUMP
        end
    end

endmodule
