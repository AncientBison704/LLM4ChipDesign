module cpu (
    input        clk,
    input        rst_n,
    output reg [4:0] pc,
    input  [7:0] instr,
    output [4:0] daddr,
    input  [7:0] ddata_in,
    output [7:0] ddata_out,
    output       dwe,
    output reg [7:0] acc
);

    wire [2:0] opcode = instr[7:5];
    wire [4:0] operand = instr[4:0];

    assign daddr = operand;
    assign ddata_out = acc;
    assign dwe = (opcode == 3'b010); // STA instruction

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pc <= 5'd0;
            acc <= 8'd0;
        end else begin
            case (opcode)
                3'b000: begin // LDI imm
                    acc <= {3'b000, operand};
                end
                3'b001: begin // LDA addr
                    acc <= ddata_in;
                end
                3'b010: begin // STA addr
                    // acc remains unchanged
                end
                3'b011: begin // ADD addr
                    acc <= acc + ddata_in;
                end
                3'b100: begin // SUB addr
                    acc <= acc - ddata_in;
                end
                3'b101: begin // NAND addr
                    acc <= ~(acc & ddata_in);
                end
                3'b110: begin // JMP addr
                    pc <= operand;
                end
                3'b111: begin // JZ  addr
                    pc <= (acc == 8'd0) ? operand : pc + 5'd1;
                end
                default: begin
                    // Should not happen, handle as NOP
                    // acc and pc remain unchanged
                end
            endcase

            // Increment PC for instructions other than JMP and taken JZ
            if (opcode != 3'b110 && !(opcode == 3'b111 && acc == 8'd0)) begin
                pc <= pc + 5'd1;
            end
        end
    end

endmodule

