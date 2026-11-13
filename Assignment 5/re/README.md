# Reverse-engineering notes

The design was recovered from `qualifier/ice40_bitstream.bin` using Project
IceStorm, cross-checked against the provided block diagrams and the known
plaintext/ciphertext vector baked into `spi_ice40_crypto_ip_test.py`.

## Commands

```bash
# bitstream -> ASCII bitstream
iceunpack ice40_bitstream.bin bitstream.asc

# ASCII bitstream -> flattened gate/BRAM netlist
icebox_vlog bitstream.asc > netlist.v
```

## Findings that pin down the architecture

| Observation (from netlist) | Conclusion |
| --- | --- |
| `.device 5k` in the `.asc` header | iCE40 UltraPlus **UP5K**, as documented |
| top module `chip` has **6 inputs, 3 outputs** | matches `SCK, RST_N, MOSI, NORM_CS_N, START, ENC_DEC` and `MISO, BUSY, ICE_LED` |
| **4 × `SB_RAM40_4K`** instances | the "AES S-box, one per byte" lanes; each 512 B BRAM holds both `S` and `S^-1`, shared by the two cores |
| combinational `assign` cones + a handful of FFs | the 2-bit round FSM, 32-bit `text_reg`, and 32-bit SPI shift register |

## Cipher recovered (validated numerically, see `scripts/les_ref.py`)

32-bit block, 4 rounds, embedded key `K = 0x8E043CB1`.

```
enc core (ENC_DEC=1):  x_{i+1} = InvSbox( ror8(x_i) ) ^ K        ; out = x4
dec core (ENC_DEC=0):  x_{i+1} = rol8( Sbox( x_i ^ K ) )         ; out = x4
```

`ror8(x) = {x[7:0],x[31:8]}`, `rol8(x) = {x[23:0],x[31:24]}`, S-boxes are the
standard AES S-box and its inverse applied per byte.

Note the `ENC_DEC` label is inverted between the interface doc (which says
`0 = encrypt`) and the silicon mux (`0` selects the `rol8∘Sbox∘⊕K` core). The
RTL here matches the **silicon**, i.e. the observed I/O of the micropython
test: `ENC_DEC=0` maps `0x59C359C3 -> 0x9CD84392`.

`scripts/les_search.py` brute-forces the round-function variants against the
known vector and independently confirms the `(Sbox, rol8, ⊕K, 4 rounds)`
structure for the `ENC_DEC=0` path.
