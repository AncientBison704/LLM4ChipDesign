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
    assign dwe = (opcode == 3'b010); // STA
  
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pc <= 5'd0;
            acc <= 8'd0;
        end else begin
            case (opcode)
                3'b000: begin // LDI
                    acc <= {3'b000, operand};
                    pc <= pc + 1;
                end
                
                3'b001: begin // LDA
                    acc <= ddata_in;
                    pc <= pc + 1;
                end
                
                3'b010: begin // STA
                    // acc unchanged
                    pc <= pc + 1;
                end
                
                3'b011: begin // ADD
                    acc <= acc + ddata_in;
                    pc <= pc + 1;
                end
                
                3'b100: begin // SUB
                    acc <= acc - ddata_in;
                    pc <= pc + 1;
                end
                
                3'b101: begin // NAND
                    acc <= ~(acc & ddata_in);
                    pc <= pc + 1;
                end

                3'b110: begin // JMP
                    pc <= operand;
                end
                
                3'b111: begin // JZ
                    if (acc == 8'd0) 
                        pc <= operand;
                    else
                        pc <= pc + 1;
                end
                
                default: begin
                    pc <= pc + 1;
                end
            endcase
        end
    end
  
endmodule
