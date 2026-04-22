![](../../workflows/gds/badge.svg) ![](../../workflows/docs/badge.svg) ![](../../workflows/test/badge.svg) ![](../../workflows/fpga/badge.svg)

# ALU7 Serial (Tiny Tapeout)

- [Project documentation](docs/info.md)

This project implements a 7-bit ALU where operands are loaded serially (LSB-first) and the result is produced in parallel.

## Interface summary

- `ui[0]`: `Bit_in`
- `ui[3:1]`: `op[2:0]`
- `clk`: system clock
- `rst_n`: active-low reset
- `uo[6:0]`: `Data_out[6:0]`
- `uo[7]`: `Done`

Operations:

- `000`: Add
- `001`: AND
- `010`: OR
- `011`: XOR
- `100`: Subtract

## Data loading sequence

1. Reset with `rst_n = 0`, then release reset (`rst_n = 1`).
2. Set `op[2:0]` before starting the transfer. The ALU samples `op` with the first input bit.
3. Shift in 14 bits on `ui[0]`, one per rising edge:
   - First 7 bits: operand A (`A[0]` to `A[6]`)
   - Next 7 bits: operand B (`B[0]` to `B[6]`)
4. After the 14th bit, `Done` goes high and `uo[6:0]` contains the ALU result.
