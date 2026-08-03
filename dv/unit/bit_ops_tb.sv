// Copyright (c) 2023-2026 Yuchi Miao <miaoyuchi@ict.ac.cn>
// SPDX-License-Identifier: MulanPSL-2.0

module bit_ops_tb;
  logic [7:0] value;
  logic [3:0] population;
  logic [3:0] leading;
  logic       all_zero;
  logic       onehot;
  logic [2:0] index;
  logic       index_valid;

  bit_count #(
      .WIDTH(8)
  ) u_count (
      .value_i(value),
      .count_o(population)
  );
  leading_zero_count #(
      .WIDTH(8)
  ) u_leading (
      .value_i   (value),
      .count_o   (leading),
      .all_zero_o(all_zero)
  );
  onehot_check #(
      .WIDTH(8)
  ) u_onehot (
      .value_i(value),
      .valid_o(onehot)
  );
  onehot_to_index #(
      .WIDTH(8)
  ) u_index (
      .value_i(value),
      .index_o(index),
      .valid_o(index_valid)
  );

  initial begin
    value = 8'b0011_0101;
    #1;
    if (population != 4 || leading != 2 || all_zero || onehot || index_valid)
      $fatal(1, "bit ops case 1");
    value = 8'b0001_0000;
    #1;
    if (population != 1 || leading != 3 || all_zero || !onehot || !index_valid || index != 4)
      $fatal(1, "bit ops case 2");
    value = '0;
    #1;
    if (population != 0 || leading != 8 || !all_zero || onehot || index_valid)
      $fatal(1, "bit ops case 3");
    $display("[PASS] bit_ops_tb");
    $finish;
  end
endmodule
