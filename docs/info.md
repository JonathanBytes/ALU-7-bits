<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works

This project implements a **7-bit ALU** with:

- **Serial input** (`Bit_in`) for both operands.
- **Parallel output** (`Data_out[6:0]`) for the computed result.
- **Completion flag** (`Done`) asserted when the operation is finished.

The ALU behavior matches the guide:

1. `rst_n = 0` resets internal state (`A`, `B`, `Data_out`, counter, and `Done`).
2. With `rst_n = 1`, each rising clock edge captures one serial bit on `Bit_in`.
3. Bits are loaded **LSB-first**:
   - First 7 bits -> operand `A`
   - Next 7 bits -> operand `B`
4. After the 14th bit, the operation selected by `op[2:0]` is executed:
   - `000`: `A + B`
   - `001`: `A & B`
   - `010`: `A | B`
   - `011`: `A ^ B`
   - `100`: `A - B`
5. `Data_out` is updated in parallel and `Done` goes high.

On Tiny Tapeout top-level pins:
- `ui[0]` = `Bit_in`
- `ui[3:1]` = `op[2:0]`
- `uo[6:0]` = `Data_out[6:0]`
- `uo[7]` = `Done`
- Core `clk` and `rst_n` are used for clock/reset.

## How to test

1. Apply reset (`rst_n = 0`) for at least one clock edge, then release (`rst_n = 1`).
2. Set `op[2:0]`.
3. Shift in 14 bits through `Bit_in`, one bit per rising edge:
   - Bits 1-7: `A[0]` to `A[6]` (LSB-first)
   - Bits 8-14: `B[0]` to `B[6]` (LSB-first)
4. After the 14th bit, read:
   - `uo[6:0]` as the ALU result
   - `uo[7]` as `Done = 1`

To process a new operation, assert reset and repeat.

## External hardware

No external hardware is required.
