// Waveform wrapper added by the coverage flow; the testbench itself is unchanged.
module cov_dump;
  initial begin
    $dumpfile("./coverage/adder8/final/adder8_raw.vcd");
    $dumpvars(0, tb_adder8);
  end
endmodule
