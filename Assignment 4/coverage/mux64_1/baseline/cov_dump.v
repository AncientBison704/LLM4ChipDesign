// Waveform wrapper added by the coverage flow; the testbench itself is unchanged.
module cov_dump;
  initial begin
    $dumpfile("./coverage/mux64_1/baseline/mux64_1_raw.vcd");
    $dumpvars(0, tb_mux64_1);
  end
endmodule
