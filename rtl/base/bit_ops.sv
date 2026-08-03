// Copyright (c) 2026 Yuchi Miao <miaoyuchi@ict.ac.cn>
// SPDX-License-Identifier: MulanPSL-2.0
// Small combinational primitives intentionally have no external dependency.

module bit_count #(
    parameter int WIDTH       = 32,
    parameter int COUNT_WIDTH = $clog2(WIDTH + 1)
) (
    input  logic [      WIDTH-1:0] value_i,
    output logic [COUNT_WIDTH-1:0] count_o
);
  always_comb begin
    count_o = '0;
    for (int unsigned bit_idx = 0; bit_idx < WIDTH; bit_idx++) begin
      count_o = count_o + value_i[bit_idx];
    end
  end
endmodule

module leading_zero_count #(
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
    for (int bit_idx = WIDTH - 1; bit_idx >= 0; bit_idx--) begin
      if (!s_seen_one && value_i[bit_idx]) begin
        s_seen_one = 1'b1;
      end else if (!s_seen_one) begin
        count_o = count_o + 1'b1;
      end
    end
    all_zero_o = !s_seen_one;
  end
endmodule

module onehot_check #(
    parameter int WIDTH      = 32,
    parameter bit ALLOW_ZERO = 1'b0
) (
    input  logic [WIDTH-1:0] value_i,
    output logic             valid_o
);
  always_comb begin
    valid_o = (value_i != '0) && ((value_i & (value_i - 1'b1)) == '0);
    if (ALLOW_ZERO && value_i == '0) begin
      valid_o = 1'b1;
    end
  end
endmodule

module onehot_to_index #(
    parameter int WIDTH       = 32,
    parameter int INDEX_WIDTH = (WIDTH > 1) ? $clog2(WIDTH) : 1
) (
    input  logic [      WIDTH-1:0] value_i,
    output logic [INDEX_WIDTH-1:0] index_o,
    output logic                   valid_o
);
  logic [WIDTH-1:0] s_onehot;

  onehot_check #(
      .WIDTH     (WIDTH),
      .ALLOW_ZERO(1'b0)
  ) u_onehot_check (
      .value_i(value_i),
      .valid_o(valid_o)
  );

  assign s_onehot = value_i;
  always_comb begin
    index_o = '0;
    for (int unsigned bit_idx = 0; bit_idx < WIDTH; bit_idx++) begin
      if (s_onehot[bit_idx]) begin
        index_o = INDEX_WIDTH'(bit_idx);
      end
    end
  end
endmodule
