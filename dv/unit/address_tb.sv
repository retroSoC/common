// Copyright (c) 2023-2026 Yuchi Miao <miaoyuchi@ict.ac.cn>
// SPDX-License-Identifier: MulanPSL-2.0

module address_tb;
  logic [15:0]       address;
  logic [ 2:0][15:0] base;
  logic [ 2:0][15:0] mask;
  logic [ 2:0]       hit;
  logic [ 1:0]       selected;
  logic              valid;
  logic              region_match;

  address_map #(
      .ADDR_WIDTH(16),
      .REGIONS   (3)
  ) u_map (
      .addr_i    (address),
      .base_i    (base),
      .mask_i    (mask),
      .hit_o     (hit),
      .selected_o(selected),
      .valid_o   (valid)
  );
  address_region #(
      .ADDR_WIDTH(16),
      .BASE      (16'h2000),
      .MASK      (16'hf000)
  ) u_region (
      .addr_i (address),
      .match_o(region_match)
  );

  initial begin
    base[0] = 16'h1000;
    mask[0] = 16'hf000;
    base[1] = 16'h1200;
    mask[1] = 16'hff00;
    base[2] = 16'h0000;
    mask[2] = 16'h0000;
    address = 16'h12a5;
    #1;
    if (!valid || hit != 3'b001 || selected != 0 || region_match) $fatal(1, "map priority");
    address = 16'h2abc;
    #1;
    if (!valid || hit != 3'b100 || selected != 2 || !region_match) $fatal(1, "map default");
    $display("[PASS] address_tb");
    $finish;
  end
endmodule
