// tb_baseline.v - mirrors spi_ice40_crypto_ip_test.py against recovered RTL
`timescale 1ns/1ps
`default_nettype none
module tb_baseline;
    reg SCK=0, RST_N=1, MOSI=0, NORM_CS_N=1, START=0, ENC_DEC=0;
    wire MISO, BUSY, ICE_LED;
    integer errors = 0;

    spi_les_top dut(.SCK(SCK), .RST_N(RST_N), .MOSI(MOSI), .NORM_CS_N(NORM_CS_N),
                    .START(START), .ENC_DEC(ENC_DEC), .MISO(MISO),
                    .BUSY(BUSY), .ICE_LED(ICE_LED));

    // one SPI bit: sample MISO (pre-shift MSB), drive MOSI, pulse SCK
    task spi_bit(input mb, output rb);
        begin
            rb = MISO;
            MOSI = mb;
            #5 SCK = 1;
            #5 SCK = 0;
        end
    endtask

    task spi_word(input [31:0] din, output [31:0] dout);
        integer i; reg rb;
        begin
            NORM_CS_N = 0; #5;
            for (i=31; i>=0; i=i-1) begin spi_bit(din[i], rb); dout[i]=rb; end
            NORM_CS_N = 1; #5;
        end
    endtask

    task tick; begin #5 SCK=1; #5 SCK=0; end endtask

    task do_reset;
        begin RST_N=0; tick; RST_N=1; tick; end
    endtask

    task do_start;                         // CS already high
        begin START=1; #5 SCK=1; #5 SCK=0; START=0; end
    endtask

    task check(input [127:0] name, input [31:0] got, input [31:0] exp);
        begin
            if (got===exp) $display("  PASS %0s = %08h", name, got);
            else begin $display("  FAIL %0s = %08h (expected %08h)", name, got, exp); errors=errors+1; end
        end
    endtask

    reg [31:0] rx;
    integer k;
    initial begin
        $dumpfile("baseline.vcd"); $dumpvars(0, tb_baseline);

        do_reset;

        $display("[SPI loopback]");
        spi_word(32'h59C359C3, rx);        // load plaintext
        spi_word(32'h59C359C3, rx);        // read it back
        check("loopback", rx, 32'h59C359C3);

        $display("[Encrypt] ENC_DEC=0, PT=59C359C3");
        ENC_DEC = 0;
        do_start;
        if (BUSY!==1'b1) begin $display("  FAIL core did not go busy"); errors=errors+1; end
        else $display("  PASS core busy after START");
        for (k=0;k<7;k=k+1) tick;
        if (BUSY!==1'b0) begin $display("  FAIL core still busy"); errors=errors+1; end
        else $display("  PASS core finished");
        spi_word(32'h00000000, rx);
        check("ciphertext", rx, 32'h9CD84392);

        $display("[Decrypt] ENC_DEC=1, CT=9CD84392");
        do_reset;
        ENC_DEC = 1;
        spi_word(32'h9CD84392, rx);        // load ciphertext
        do_start;
        for (k=0;k<7;k=k+1) tick;
        if (BUSY!==1'b0) begin $display("  FAIL core still busy"); errors=errors+1; end
        else $display("  PASS core finished");
        spi_word(32'h00000000, rx);
        check("plaintext", rx, 32'h59C359C3);

        $display("");
        if (errors==0) $display("==== BASELINE: ALL TESTS PASS ====");
        else           $display("==== BASELINE: %0d FAILURE(S) ====", errors);
        $finish;
    end
endmodule
`default_nettype wire
