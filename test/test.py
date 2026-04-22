# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles


async def reset_dut(dut):
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 2)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 1)


async def shift_operands_lsb_first(dut, a, b, op):
    for idx in range(7):
        bit = (a >> idx) & 0x1
        dut.ui_in.value = (op << 1) | bit
        await ClockCycles(dut.clk, 1)

    for idx in range(7):
        bit = (b >> idx) & 0x1
        dut.ui_in.value = (op << 1) | bit
        await ClockCycles(dut.clk, 1)


@cocotb.test()
async def test_project(dut):
    dut._log.info("Start")

    clock = Clock(dut.clk, 10, unit="us")
    cocotb.start_soon(clock.start())

    test_vectors = [
        (0b0101011, 0b0010110, 0b000, lambda a, b: (a + b) & 0x7F),  # ADD
        (0b0101011, 0b0010110, 0b001, lambda a, b: a & b),            # AND
        (0b0101011, 0b0010110, 0b010, lambda a, b: a | b),            # OR
        (0b0101011, 0b0010110, 0b011, lambda a, b: a ^ b),            # XOR
        (0b0101011, 0b0010110, 0b100, lambda a, b: (a - b) & 0x7F),  # SUB
    ]

    for a, b, op, expected_fn in test_vectors:
        await reset_dut(dut)
        await shift_operands_lsb_first(dut, a, b, op)

        expected = expected_fn(a, b)
        result = int(dut.uo_out.value) & 0x7F
        done = (int(dut.uo_out.value) >> 7) & 0x1

        assert done == 1, f"Done should be high after 14 bits for op {op:03b}"
        assert result == expected, (
            f"Unexpected result for op {op:03b}: got {result:07b}, expected {expected:07b}"
        )
