// Copyright 2018-2024 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51. You may obtain a copy at
// http://solderpad.org/licenses/SHL-0.51.
//
// Derived design work: Copyright (c) 2026 Yuchi Miao <miaoyuchi@ict.ac.cn>
// SPDX-License-Identifier: SHL-0.51
// Design independently implemented for common; see NOTICE for attribution.

module round_robin_arbiter #(
    parameter int CLIENTS     = 4,
    parameter int INDEX_WIDTH = (CLIENTS > 1) ? $clog2(CLIENTS) : 1
) (
    input  logic                   clk_i,
    input  logic                   rst_n_i,
    input  logic                   advance_i,
    input  logic [    CLIENTS-1:0] request_i,
    output logic [    CLIENTS-1:0] grant_o,
    output logic [INDEX_WIDTH-1:0] selected_o,
    output logic                   valid_o
);
  logic        [INDEX_WIDTH-1:0] r_cursor;
  logic                          s_found;
  int unsigned                   s_candidate;

  initial begin
    if (CLIENTS < 2) begin
      $fatal(1, "round_robin_arbiter: CLIENTS must be at least two");
    end
  end

  always_comb begin
    grant_o    = '0;
    selected_o = '0;
    s_found    = 1'b0;
    for (int unsigned offset = 0; offset < CLIENTS; offset++) begin
      s_candidate = int'(r_cursor) + offset;
      if (s_candidate >= CLIENTS) begin
        s_candidate = s_candidate - CLIENTS;
      end
      if (!s_found && request_i[s_candidate]) begin
        grant_o[s_candidate] = 1'b1;
        selected_o           = INDEX_WIDTH'(s_candidate);
        s_found              = 1'b1;
      end
    end
    valid_o = s_found;
  end

  always_ff @(posedge clk_i or negedge rst_n_i) begin
    if (!rst_n_i) begin
      r_cursor <= '0;
    end else if (advance_i && valid_o) begin
      if (selected_o == INDEX_WIDTH'(CLIENTS - 1)) begin
        r_cursor <= '0;
      end else begin
        r_cursor <= selected_o + 1'b1;
      end
    end
  end
endmodule
