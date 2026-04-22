/*
 * Copyright (c) 2026 Jonathan Cardona Ramírez
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_jonathanbytes_alu7_serial (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

  wire [6:0] data_out;
  wire done;

  alu7_serial alu7_uut (
      .CLK(clk),
      .RST_n(rst_n),
      .Bit_in(ui_in[0]),
      .op(ui_in[3:1]),
      .Data_out(data_out),
      .Done(done)
  );

  // Data_out[6:0] + Done en paralelo por las salidas dedicadas.
  assign uo_out = {done, data_out};
  assign uio_out = 8'b0;
  assign uio_oe = 8'b0;

  // List all unused inputs to prevent warnings
  wire _unused = &{ena, ui_in[7:4], uio_in, 1'b0};

endmodule
