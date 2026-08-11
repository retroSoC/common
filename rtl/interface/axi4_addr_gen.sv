// Copyright (c) 2023-2026 Yuchi Miao <miaoyuchi@ict.ac.cn>
// SPDX-License-Identifier: MulanPSL-2.0
// Computes the next address within the 4 KiB AXI page represented by addr_i.
// The caller is responsible for rejecting bursts that cross the page boundary.

`include "axi4_define.svh"

module axi4_addr_gen #(
    parameter int ADDR_WIDTH = `AXI4_ADDR_OFT_WIDTH
) (
    input  logic [           7:0] alen_i,
    input  logic [           2:0] asize_i,
    input  logic [           1:0] aburst_i,
    input  logic [ADDR_WIDTH-1:0] addr_i,
    output logic [ADDR_WIDTH-1:0] addr_o
);
  logic [ADDR_WIDTH-1:0] s_beat_bytes;
  logic [ADDR_WIDTH-1:0] s_burst_bytes;
  logic [ADDR_WIDTH-1:0] s_next_addr;
  logic [ADDR_WIDTH-1:0] s_wrap_mask;
  logic                  s_wrap_length_valid;

  always_comb begin
    s_beat_bytes = {{(ADDR_WIDTH - 1) {1'b0}}, 1'b1} << asize_i;
    s_next_addr = addr_i + s_beat_bytes;
    s_wrap_length_valid = (alen_i == 8'd1) || (alen_i == 8'd3) || (alen_i == 8'd7) ||
        (alen_i == 8'd15);
    s_burst_bytes = s_beat_bytes * ADDR_WIDTH'(alen_i + 1'b1);
    s_wrap_mask = s_burst_bytes - 1'b1;

    case (aburst_i)
      `AXI4_BURST_TYPE_FIXED: addr_o = addr_i;
      `AXI4_BURST_TYPE_WRAP: begin
        // AXI wrap lengths are powers of two, so this is a boundary mask,
        // not a mask made from AxLEN itself.
        if (s_wrap_length_valid && s_burst_bytes != '0) begin
          addr_o = (addr_i & ~s_wrap_mask) | (s_next_addr & s_wrap_mask);
        end else begin
          addr_o = s_next_addr;
        end
      end
      default:                addr_o = s_next_addr;
    endcase
  end

  initial begin
    if (ADDR_WIDTH < 2) $fatal(1, "axi4_addr_gen: ADDR_WIDTH must be at least two");
  end
endmodule
