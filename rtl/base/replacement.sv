// Copyright 2018-2024 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51. You may obtain a copy at
// http://solderpad.org/licenses/SHL-0.51.
//
// Original pseudo-LRU tree concept: David Schaffenrath and Florian Zaruba.
// Derived design work: Copyright (c) 2026 Yuchi Miao <miaoyuchi@ict.ac.cn>
// SPDX-License-Identifier: SHL-0.51
// Design independently implemented for common; see NOTICE for attribution.

// Tracks a pseudo-LRU binary tree. Tree nodes point to the least-recently-used
// child, and touch_i changes every node on its selected root-to-leaf path.
module plru_victim_selector #(
    parameter int WAYS = 4
) (
    input  logic            clk_i,
    input  logic            rst_n_i,
    input  logic            flush_i,
    input  logic [WAYS-1:0] touch_i,
    output logic [WAYS-1:0] victim_o
);
  localparam int LEVELS = $clog2(WAYS);

  logic [WAYS-2:0] r_tree;
  logic [WAYS-2:0] s_tree_after_touch;
  logic [WAYS-2:0] s_tree_next;
  logic            s_touch_legal;

  initial begin
    if (WAYS < 2 || (WAYS & (WAYS - 1)) != 0) begin
      $fatal(1, "plru_victim_selector: WAYS must be a power of two and at least two");
    end
  end

  onehot_check #(
      .WIDTH     (WAYS),
      .ALLOW_ZERO(1'b1)
  ) u_touch_check (
      .value_i(touch_i),
      .valid_o(s_touch_legal)
  );

  always_comb begin
    int unsigned node_index;
    logic        branch;

    s_tree_after_touch = r_tree;
    node_index         = 0;
    branch             = 1'b0;
    for (int unsigned way_index = 0; way_index < WAYS; way_index++) begin
      if (touch_i[way_index]) begin
        node_index = 0;
        for (int unsigned level = 0; level < LEVELS; level++) begin
          branch                         = ((way_index >> (LEVELS - level - 1)) & 1) != 0;
          // Point to the sibling because it is now less recently used.
          s_tree_after_touch[node_index] = !branch;
          node_index                     = (2 * node_index) + 1 + branch;
        end
      end
    end
  end

  always_comb begin
    int unsigned node_index;
    int unsigned victim_index;
    logic        branch;

    victim_o     = '0;
    node_index   = 0;
    victim_index = 0;
    branch       = 1'b0;
    for (int unsigned level = 0; level < LEVELS; level++) begin
      branch       = r_tree[node_index];
      victim_index = (victim_index << 1) | int'(branch);
      node_index   = (2 * node_index) + 1 + branch;
    end
    victim_o[victim_index] = 1'b1;
  end

  assign s_tree_next = flush_i ? '0 : s_tree_after_touch;
  dffr #(
      .DATA_WIDTH(WAYS - 1)
  ) u_tree_state (
      .clk_i  (clk_i),
      .rst_n_i(rst_n_i),
      .dat_i  (s_tree_next),
      .dat_o  (r_tree)
  );

`ifndef SYNTHESIS
  always_ff @(posedge clk_i) begin
    if (rst_n_i && !flush_i && !s_touch_legal) begin
      $fatal(1, "plru_victim_selector: touch_i must be zero or one-hot");
    end
  end
`endif
endmodule
