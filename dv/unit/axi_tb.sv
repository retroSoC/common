// Copyright (c) 2023-2026 Yuchi Miao <miaoyuchi@ict.ac.cn>
// SPDX-License-Identifier: MulanPSL-2.0

`include "axi4_define.svh"

module axi_tb;
  logic [                     7:0] length;
  logic [                     2:0] size;
  logic [                     1:0] burst;
  logic [`AXI4_ADDR_OFT_WIDTH-1:0] address;
  logic [`AXI4_ADDR_OFT_WIDTH-1:0] next_address;

  axi4_addr_gen u_address_gen (
      .alen_i  (length),
      .asize_i (size),
      .aburst_i(burst),
      .addr_i  (address),
      .addr_o  (next_address)
  );

  initial begin
    length  = 3;
    size    = `AXI4_BURST_SIZE_4BYTES;
    burst   = `AXI4_BURST_TYPE_INCR;
    address = 12'h104;
    #1;
    if (next_address != 12'h108) $fatal(1, "axi incr failed");
    burst = `AXI4_BURST_TYPE_FIXED;
    #1;
    if (next_address != 12'h104) $fatal(1, "axi fixed failed");
    burst   = `AXI4_BURST_TYPE_WRAP;
    address = 12'h10c;
    #1;
    if (next_address != 12'h100) $fatal(1, "axi wrap failed: %h", next_address);
    length  = 2;
    address = 12'h104;
    #1;
    if (next_address != 12'h108) $fatal(1, "invalid wrap must increment");
    $display("[PASS] axi_tb");
    $finish;
  end
endmodule
