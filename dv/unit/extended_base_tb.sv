// Copyright (c) 2026 Yuchi Miao <miaoyuchi@ict.ac.cn>
// SPDX-License-Identifier: MulanPSL-2.0

module extended_base_tb;
  logic       clk = 1'b0;
  logic       rst_n = 1'b0;
  logic       clear;
  logic [2:0] position;
  logic [7:0] prefix;
  logic [2:0] lower, upper;
  logic [7:0] interval;
  logic [7:0] trailing_value;
  logic [3:0] trailing_count;
  logic       trailing_zero;
  logic [2:0] index;
  logic [7:0] onehot;
  logic       onehot_valid;
  logic give, take;
  logic [2:0] credit;
  logic has_credit, near_full, credit_full;
  logic advance;
  logic [3:0] step, limit, loop_value;
  logic at_limit, wrapped;
  logic stable_enable, stable_sample, stable_level;
  logic majority_enable, majority_sample, majority_level;
  logic [7:0] bloom_lookup, bloom_insert, bloom_remove;
  logic bloom_insert_valid, bloom_remove_valid, bloom_member;
  logic [3:0] bloom_usage;
  logic bloom_empty, bloom_full, bloom_saturated;

  always #5 clk = !clk;

  prefix_ones_mask #(
      .WIDTH(8)
  ) u_prefix (
      .position_i(position),
      .mask_o    (prefix)
  );
  interval_ones_mask #(
      .WIDTH(8)
  ) u_interval (
      .lower_i(lower),
      .upper_i(upper),
      .mask_o (interval)
  );
  trailing_zero_count #(
      .WIDTH(8)
  ) u_trailing (
      .value_i   (trailing_value),
      .count_o   (trailing_count),
      .all_zero_o(trailing_zero)
  );
  index_to_onehot #(
      .WIDTH(8)
  ) u_onehot (
      .index_i (index),
      .enable_i(1'b1),
      .onehot_o(onehot),
      .valid_o (onehot_valid)
  );
  credit_pool #(
      .MAX_CREDITS(4)
  ) u_credit (
      .clk_i          (clk),
      .rst_n_i        (rst_n),
      .clear_i        (clear),
      .give_i         (give),
      .take_i         (take),
      .available_o    (credit),
      .has_credit_o   (has_credit),
      .one_from_full_o(near_full),
      .full_o         (credit_full)
  );
  loop_trip_counter #(
      .DATA_WIDTH(4)
  ) u_loop (
      .clk_i     (clk),
      .rst_n_i   (rst_n),
      .clear_i   (clear),
      .advance_i (advance),
      .step_i    (step),
      .limit_i   (limit),
      .value_o   (loop_value),
      .at_limit_o(at_limit),
      .wrap_o    (wrapped)
  );
  stable_level_filter #(
      .STABLE_CYCLES(2)
  ) u_stable (
      .clk_i    (clk),
      .rst_n_i  (rst_n),
      .clear_i  (clear),
      .restart_i(1'b0),
      .enable_i (stable_enable),
      .sample_i (stable_sample),
      .level_o  (stable_level)
  );
  sample_majority_filter #(
      .WINDOW_LENGTH   (4),
      .ASSERT_THRESHOLD(3)
  ) u_majority (
      .clk_i   (clk),
      .rst_n_i (rst_n),
      .clear_i (clear),
      .enable_i(majority_enable),
      .sample_i(majority_sample),
      .level_o (majority_level)
  );
  counting_bloom_filter #(
      .DATA_WIDTH  (8),
      .HASH_WIDTH  (3),
      .HASHES      (2),
      .BUCKET_WIDTH(3),
      .ROUNDS      (1)
  ) u_bloom (
      .clk_i        (clk),
      .rst_n_i      (rst_n),
      .clear_i      (clear),
      .lookup_data_i(bloom_lookup),
      .member_o     (bloom_member),
      .insert_data_i(bloom_insert),
      .insert_i     (bloom_insert_valid),
      .remove_data_i(bloom_remove),
      .remove_i     (bloom_remove_valid),
      .usage_o      (bloom_usage),
      .empty_o      (bloom_empty),
      .full_o       (bloom_full),
      .saturated_o  (bloom_saturated)
  );

  initial begin
    clear              = 0;
    position           = 3;
    lower              = 2;
    upper              = 5;
    trailing_value     = 8'h28;
    index              = 3;
    give               = 0;
    take               = 0;
    advance            = 0;
    step               = 2;
    limit              = 4;
    stable_enable      = 0;
    stable_sample      = 0;
    majority_enable    = 0;
    majority_sample    = 0;
    bloom_lookup       = 0;
    bloom_insert       = 0;
    bloom_remove       = 0;
    bloom_insert_valid = 0;
    bloom_remove_valid = 0;
    repeat (2) @(negedge clk);
    rst_n = 1;
    #1;
    if (prefix != 8'h0f || interval != 8'h38 || trailing_count != 3 || trailing_zero ||
        !onehot_valid || onehot != 8'h08)
      $fatal(1, "base combinational cells failed");
    trailing_value = '0;
    #1;
    if (!trailing_zero || trailing_count != 8) $fatal(1, "trailing zero all-zero behavior failed");
    if (credit != 4 || !credit_full) $fatal(1, "credit reset state failed");
    @(negedge clk);
    take = 1;
    @(negedge clk);
    take = 0;
    #1;
    if (credit != 3 || !near_full) $fatal(1, "credit take failed");
    @(negedge clk);
    give = 1;
    @(negedge clk);
    give = 0;
    #1;
    if (credit != 4 || !credit_full || !has_credit) $fatal(1, "credit give failed");
    @(negedge clk);
    advance = 1;
    @(negedge clk);
    #1;
    if (loop_value != 2 || at_limit || wrapped) $fatal(1, "loop first step failed");
    @(negedge clk);
    #1;
    if (loop_value != 4 || !at_limit || !wrapped) $fatal(1, "loop limit failed");
    @(negedge clk);
    advance = 0;
    #1;
    if (loop_value != 0) $fatal(1, "loop wrap reset failed");
    @(negedge clk);
    stable_enable = 1;
    stable_sample = 1;
    @(negedge clk);
    #1;
    if (stable_level) $fatal(1, "stable filter changed too early");
    @(negedge clk);
    #1;
    if (!stable_level) $fatal(1, "stable filter did not accept stable level");
    majority_enable = 1;
    majority_sample = 1;
    repeat (3) @(negedge clk);
    #1;
    if (!majority_level) $fatal(1, "majority filter failed");
    majority_enable = 0;
    bloom_lookup    = 8'ha5;
    bloom_insert    = 8'ha5;
    @(negedge clk);
    bloom_insert_valid = 1;
    @(negedge clk);
    bloom_insert_valid = 0;
    #1;
    if (!bloom_member || bloom_empty || bloom_usage != 1 || bloom_saturated) begin
      $fatal(1, "counting bloom insert failed");
    end
    bloom_remove = 8'ha5;
    @(negedge clk);
    bloom_remove_valid = 1;
    @(negedge clk);
    bloom_remove_valid = 0;
    #1;
    if (bloom_member || !bloom_empty || bloom_usage != 0) $fatal(1, "counting bloom remove failed");
    $display("[PASS] extended_base_tb");
    $finish;
  end
endmodule
