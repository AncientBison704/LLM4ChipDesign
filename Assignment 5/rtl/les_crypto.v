// =====================================================================
//  les_crypto.v  -  Baseline RTL recovered from the iCE40 bitstream
//  LES: 32-bit lightweight block cipher, 4 rounds, embedded key K.
//
//  Recovered from qualifier/ice40_bitstream.bin (device 5k) and the
//  provided block diagrams, validated against the known vector
//     ENC_DEC=0 : 0x59C359C3 -> 0x9CD84392
//     ENC_DEC=1 : 0x9CD84392 -> 0x59C359C3
//
//  Round functions (per byte S-box, ror/rol by 8, XOR with K):
//     enc core : x_{i+1} = InvSbox( ror8(x_i) ) ^ K          (sel by ENC_DEC=1)
//     dec core : x_{i+1} = rol8( Sbox( x_i ^ K ) )           (sel by ENC_DEC=0)
//  The whole design runs on SCK (single clock domain), reset sync, active low.
// =====================================================================
`default_nettype none

module spi_les_top (
    input  wire SCK,        // unified system + SPI clock
    input  wire RST_N,      // sync active-low reset
    input  wire MOSI,       // serial in
    input  wire NORM_CS_N,  // active-low chip select / shift enable
    input  wire START,      // start pulse (to both cores)
    input  wire ENC_DEC,    // 1 -> enc core, 0 -> dec core (matches silicon I/O)
    output wire MISO,       // serial out
    output wire BUSY,       // high while processing
    output wire ICE_LED     // mirrors BUSY
);
    localparam [31:0] KEY = 32'h8E043CB1;   // embedded key, recovered

    // ---- S-box ROMs (forward + inverse), 4 lanes shared by both cores ----
    reg [7:0] SBOX  [0:255];
    reg [7:0] ISBOX [0:255];
    initial begin
        $readmemh("sbox.mem",  SBOX);
        $readmemh("isbox.mem", ISBOX);
    end

    function [31:0] sub_fwd; input [31:0] x;
        sub_fwd = {SBOX[x[31:24]], SBOX[x[23:16]], SBOX[x[15:8]], SBOX[x[7:0]]};
    endfunction
    function [31:0] sub_inv; input [31:0] x;
        sub_inv = {ISBOX[x[31:24]], ISBOX[x[23:16]], ISBOX[x[15:8]], ISBOX[x[7:0]]};
    endfunction
    function [31:0] ror8; input [31:0] x; ror8 = {x[7:0],  x[31:8]};  endfunction
    function [31:0] rol8; input [31:0] x; rol8 = {x[23:0], x[31:24]}; endfunction

    function [31:0] round_e; input [31:0] x; round_e = sub_inv(ror8(x)) ^ KEY; endfunction
    function [31:0] round_d; input [31:0] x; round_d = rol8(sub_fwd(x ^ KEY)); endfunction

    wire clr = ~RST_N;

    // ---- SPI shift register (32-bit, MSB first). priority: clr > shift > load
    reg [31:0] sh;
    wire       shift_en = ~NORM_CS_N;

    // ---- two round cores, 2-bit FSM each: IDLE->R1->R2->R3->IDLE -------------
    localparam IDLE=2'd0, R1=2'd1, R2=2'd2, R3=2'd3;

    reg [1:0]  e_state, d_state;
    reg [31:0] e_reg,  d_reg;

    wire e_busy = (e_state != IDLE) | START;   // combinational busy
    wire [31:0] e_in = sh;                      // round-1 input = latched word

    always @(posedge SCK) begin
        if (clr) begin e_state <= IDLE; e_reg <= 32'd0; end
        else case (e_state)
            IDLE: if (START) begin e_reg <= round_e(e_in); e_state <= R1; end
            R1:   begin e_reg <= round_e(e_reg); e_state <= R2; end
            R2:   begin e_reg <= round_e(e_reg); e_state <= R3; end
            R3:   begin e_reg <= round_e(e_reg); e_state <= IDLE; end
        endcase
    end

    wire [31:0] d_in = sh;
    always @(posedge SCK) begin
        if (clr) begin d_state <= IDLE; d_reg <= 32'd0; end
        else case (d_state)
            IDLE: if (START) begin d_reg <= round_d(d_in); d_state <= R1; end
            R1:   begin d_reg <= round_d(d_reg); d_state <= R2; end
            R2:   begin d_reg <= round_d(d_reg); d_state <= R3; end
            R3:   begin d_reg <= round_d(d_reg); d_state <= IDLE; end
        endcase
    end

    // both cores share identical timing; use one as the system busy
    wire        busy    = e_busy;
    wire [31:0] text_out = ENC_DEC ? e_reg : d_reg;   // mux

    // busy falling-edge detect -> parallel load result into shift register
    reg busy_d;
    always @(posedge SCK) busy_d <= clr ? 1'b0 : busy;
    wire load = busy_d & ~busy;

    always @(posedge SCK) begin
        if (clr)            sh <= 32'd0;
        else if (shift_en)  sh <= {sh[30:0], MOSI};
        else if (load)      sh <= text_out;
    end

    assign MISO    = sh[31];
    assign BUSY    = busy;
    assign ICE_LED = busy;
endmodule

`default_nettype wire
