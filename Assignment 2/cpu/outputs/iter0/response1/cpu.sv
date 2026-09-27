module cpu (
    input        clk,
    input        rst_n,
    output reg [4:0] pc,
    input  [7:0] instr,
    output reg [4:0] daddr,
    input  [7:0] ddata_in,
    output reg [7:0] ddata_out,
    output reg       dwe,
    output reg [7:0] acc
);

    wire [2:0] opcode;
    wire [4:0] operand;

    assign opcode = instr[7:5];
    assign operand = instr[4:0];
    assign daddr = operand;
    assign ddata_out = acc;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pc <= 5'b0;
            acc <= 8'b0;
        end else begin
            case (opcode)
                3'b000: begin // LDI imm
                    acc <= {3'b000, operand};
                    pc <= pc + 1;
                end
                3'b001: begin // LDA addr
                    acc <= ddata_in;
                    pc <= pc + 1;
                end
                3'b010: begin // STA addr
                    dwe <= 1;
                    pc <= pc + 1;
                end
                3'b011: begin // ADD addr
                    acc <= acc + ddata_in;
                    pc <= pc + 1;
                end
                3'b100: begin // SUB addr
                    acc <= acc - ddata_in;
                    pc <= pc + 1;
                end
                3'b101: begin // NAND addr
                    acc <= ~(acc & ddata_in);
                    pc <= pc + 1;
                end
                3'b110: begin // JMP addr
                    pc <= operand;
                end
                3'b111: begin // JZ  addr
                    if (acc == 8'b0)
                        pc <= operand;
                    else
                        pc <= pc + 1;
                end
                default: begin
                    pc <= pc + 1; // Default increment for unsupported operations 
                end
            endcase

            if (opcode != 3'b010) begin
                dwe <= 0; // Clear dwe unless STA is executed
            end
        end
    end
endmodule
