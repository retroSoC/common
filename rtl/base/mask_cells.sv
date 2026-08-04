// Copyright 2021 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License. You may obtain a copy at
// http://solderpad.org/licenses/SHL-0.51.
// SPDX-License-Identifier: SHL-0.51
//
// Derived design work: Copyright (c) 2026 Yuchi Miao <miaoyuchi@ict.ac.cn>
// Design independently implemented for common; see NOTICE for attribution.

// Generates a saturated mask with bits [0, position_i] asserted.
module prefix_ones_mask #(
    parameter int WIDTH       = 32,
    parameter int INDEX_WIDTH = (WIDTH > 1) ? $clog2(WIDTH) : 1
) (
    input  logic [INDEX_WIDTH-1:0] position_i,
    output logic [      WIDTH-1:0] mask_o
);
  always_comb begin
    mask_o = '0;
    for (int unsigned bit_idx = 0; bit_idx < WIDTH; bit_idx++) begin
      if (bit_idx <= position_i) mask_o[bit_idx] = 1'b1;
    end
  end

  initial begin
    if (WIDTH < 1 || INDEX_WIDTH < ((WIDTH > 1) ? $clog2(WIDTH) : 1)) begin
      $fatal(1, "prefix_ones_mask: invalid width");
    end
  end
endmodule

// Generates a mask for the open/closed interval (lower_i, upper_i].
module interval_ones_mask #(
    parameter int WIDTH       = 32,
    parameter int INDEX_WIDTH = (WIDTH > 1) ? $clog2(WIDTH) : 1
) (
    input  logic [INDEX_WIDTH-1:0] lower_i,
    input  logic [INDEX_WIDTH-1:0] upper_i,
    output logic [      WIDTH-1:0] mask_o
);
  logic [WIDTH-1:0] s_lower_mask;
  logic [WIDTH-1:0] s_upper_mask;

  prefix_ones_mask #(
      .WIDTH      (WIDTH),
      .INDEX_WIDTH(INDEX_WIDTH)
  ) u_lower_mask (
      .position_i(lower_i),
      .mask_o    (s_lower_mask)
  );
  prefix_ones_mask #(
      .WIDTH      (WIDTH),
      .INDEX_WIDTH(INDEX_WIDTH)
  ) u_upper_mask (
      .position_i(upper_i),
      .mask_o    (s_upper_mask)
  );

  assign mask_o = s_upper_mask & ~s_lower_mask;

  initial begin
    if (WIDTH < 1 || INDEX_WIDTH < ((WIDTH > 1) ? $clog2(WIDTH) : 1)) begin
      $fatal(1, "interval_ones_mask: invalid width");
    end
  end
endmodule

module trailing_zero_count #(
    parameter int WIDTH       = 32,
    parameter int COUNT_WIDTH = $clog2(WIDTH + 1)
) (
    input  logic [      WIDTH-1:0] value_i,
    output logic [COUNT_WIDTH-1:0] count_o,
    output logic                   all_zero_o
);
  logic s_seen_one;

  always_comb begin
    count_o    = '0;
    s_seen_one = 1'b0;
    for (int unsigned bit_idx = 0; bit_idx < WIDTH; bit_idx++) begin
      if (!s_seen_one && value_i[bit_idx]) begin
        s_seen_one = 1'b1;
      end else if (!s_seen_one) begin
        count_o = count_o + 1'b1;
      end
    end
    all_zero_o = !s_seen_one;
  end

  initial begin
    if (WIDTH < 1 || COUNT_WIDTH < $clog2(WIDTH + 1)) begin
      $fatal(1, "trailing_zero_count: invalid width");
    end
  end
endmodule

module index_to_onehot #(
    parameter int WIDTH       = 32,
    parameter int INDEX_WIDTH = (WIDTH > 1) ? $clog2(WIDTH) : 1
) (
    input  logic [INDEX_WIDTH-1:0] index_i,
    input  logic                   enable_i,
    output logic [      WIDTH-1:0] onehot_o,
    output logic                   valid_o
);
  localparam logic [INDEX_WIDTH:0] INDEX_LIMIT = (INDEX_WIDTH + 1)'(WIDTH);
  logic [INDEX_WIDTH:0] s_index_extended;

  always_comb begin
    s_index_extended = {1'b0, index_i};
    onehot_o         = '0;
    valid_o          = enable_i && (s_index_extended < INDEX_LIMIT);
    if (valid_o) onehot_o[index_i] = 1'b1;
  end

  initial begin
    if (WIDTH < 1 || INDEX_WIDTH < ((WIDTH > 1) ? $clog2(WIDTH) : 1)) begin
      $fatal(1, "index_to_onehot: invalid width");
    end
  end
endmodule
