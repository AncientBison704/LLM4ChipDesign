module cpu (
    input        clk,
    input        rst_n,
    output reg [4:0] pc,
    input  [7:0] instr,
    output [4:0] daddr,
    input  [7:0] ddata_in,
    output reg [7:0] ddata_out,
    output reg       dwe,
    output reg [7:0] acc
);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pc <= 5'b00000;
            acc <= 8'b00000000;
        end else begin
            case (instr[7:5])
                3'b000: begin // LDI
                    acc <= {3'b000, instr[4:0]};
                    pc <= pc + 5'b00001;
                end
                3'b001: begin // LDA
                    acc <= ddata_in;
                    pc <= pc + 5'b00001;
                end
                3'b010: begin // STA
                    ddata_out <= acc;
                    dwe <= 1'b1;
                    pc <= pc + 5'b00001;
                end
                3'b011: begin // ADD
                    acc <= acc + ddata_in;
                    pc <= pc + 5'b00001;
                end
                3'b100: begin // SUB
                    acc <= acc - ddata_in;
                    pc <= pc + 5'b00001;
                end
                3'b101: begin // NAND
                    acc <= ~(acc & ddata_in);
                    pc <= pc + 5'b00001;
                end
                3'b110: begin // JMP
                    pc <= instr[4:0];
                end
                3'b111: begin // JZ
                    if (acc == 8'b00000000)
                        pc <= instr[4:0];
                    else
                        pc <= pc + 5'b00001;
                end
                default: begin
                    pc <= pc + 5'b00001;
                end
            endcase
            dwe <= (instr[7:5] == 3'b010) ? 1'b1 : 1'b0;
        end
    end

    assign daddr = instr[4:0];

endmodule
