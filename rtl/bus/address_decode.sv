// Copyright 2018-2024 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51. You may obtain a copy at
// http://solderpad.org/licenses/SHL-0.51.
//
// Derived design work: Copyright (c) 2026 Yuchi Miao <miaoyuchi@ict.ac.cn>
// SPDX-License-Identifier: SHL-0.51
// Design independently implemented for common; see NOTICE for attribution.

// The lowest numbered matching map wins. A zero mask deliberately matches all
// addresses and can therefore be used as an explicit default entry.
module address_map #(
    parameter int ADDR_WIDTH  = 32,
    parameter int REGIONS     = 4,
    parameter int INDEX_WIDTH = (REGIONS > 1) ? $clog2(REGIONS) : 1
) (
    input  logic [ ADDR_WIDTH-1:0]                 addr_i,
    input  logic [    REGIONS-1:0][ADDR_WIDTH-1:0] base_i,
    input  logic [    REGIONS-1:0][ADDR_WIDTH-1:0] mask_i,
    output logic [    REGIONS-1:0]                 hit_o,
    output logic [INDEX_WIDTH-1:0]                 selected_o,
    output logic                                   valid_o
);
  logic s_found;

  always_comb begin
    hit_o      = '0;
    selected_o = '0;
    s_found    = 1'b0;
    for (int unsigned region_idx = 0; region_idx < REGIONS; region_idx++) begin
      if (!s_found &&
          ((addr_i & mask_i[region_idx]) == (base_i[region_idx] & mask_i[region_idx]))) begin
        hit_o[region_idx] = 1'b1;
        selected_o        = INDEX_WIDTH'(region_idx);
        s_found           = 1'b1;
      end
    end
    valid_o = s_found;
  end
endmodule

module address_region #(
    parameter int                    ADDR_WIDTH = 32,
    parameter logic [ADDR_WIDTH-1:0] BASE       = '0,
    parameter logic [ADDR_WIDTH-1:0] MASK       = '0
) (
    input  logic [ADDR_WIDTH-1:0] addr_i,
    output logic                  match_o
);
  assign match_o = (addr_i & MASK) == (BASE & MASK);
endmodule
