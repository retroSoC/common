// Copyright 2019 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License. You may obtain a copy at
// http://solderpad.org/licenses/SHL-0.51.
// SPDX-License-Identifier: SHL-0.51
//
// Original concepts include substitution-permutation hashing and counting
// Bloom filters. Derived design work: Copyright (c) 2026 Yuchi Miao
// <miaoyuchi@ict.ac.cn>. Design independently implemented for common; see
// NOTICE for attribution.

// A deterministic, non-cryptographic hash. Its elaboration-time keys are used
// only to make separately instantiated hash lanes decorrelate; it must not be
// used for security decisions.
module permutation_hash #(
    parameter int          DATA_WIDTH  = 32,
    parameter int          HASH_WIDTH  = 5,
    parameter int          ROUNDS      = 2,
    parameter logic [31:0] PERMUTE_KEY = 32'h11C0_FFEE,
    parameter logic [31:0] MIX_KEY     = 32'h7A31_9B45
) (
    input  logic [       DATA_WIDTH-1:0] data_i,
    output logic [       HASH_WIDTH-1:0] hash_o,
    output logic [(1 << HASH_WIDTH)-1:0] indicator_o
);
  logic [DATA_WIDTH-1:0] s_state;
  logic [DATA_WIDTH-1:0] s_next;

  always_comb begin
    s_state = data_i;
    for (int unsigned round_idx = 0; round_idx < ROUNDS; round_idx++) begin
      for (int unsigned bit_idx = 0; bit_idx < DATA_WIDTH; bit_idx++) begin
        s_next[bit_idx] = s_state[(bit_idx + PERMUTE_KEY[bit_idx % 32] + round_idx) % DATA_WIDTH] ^
            s_state[(bit_idx + MIX_KEY[(bit_idx + round_idx) % 32] + 1) % DATA_WIDTH] ^
            s_state[(bit_idx + DATA_WIDTH - 1) % DATA_WIDTH];
      end
      s_state = s_next;
    end
    hash_o              = s_state[HASH_WIDTH-1:0];
    indicator_o         = '0;
    indicator_o[hash_o] = 1'b1;
  end

  initial begin
    if (DATA_WIDTH < 1 || HASH_WIDTH < 1 || HASH_WIDTH > DATA_WIDTH || HASH_WIDTH > 12 ||
        ROUNDS < 1) begin
      $fatal(1, "permutation_hash: invalid hash geometry");
    end
  end
endmodule

// Produces the union of independently keyed hash buckets for a single item.
module hash_indicator_bank #(
    parameter int          DATA_WIDTH = 32,
    parameter int          HASH_WIDTH = 5,
    parameter int          HASHES     = 3,
    parameter int          ROUNDS     = 2,
    parameter logic [31:0] SEED       = 32'hC0DE_1234
) (
    input  logic [       DATA_WIDTH-1:0] data_i,
    output logic [(1 << HASH_WIDTH)-1:0] indicator_o
);
  logic [HASHES-1:0][(1 << HASH_WIDTH)-1:0] s_lane_indicator;

  for (genvar hash_idx = 0; hash_idx < HASHES; hash_idx++) begin : GEN_HASH_LANE
    permutation_hash #(
        .DATA_WIDTH (DATA_WIDTH),
        .HASH_WIDTH (HASH_WIDTH),
        .ROUNDS     (ROUNDS),
        .PERMUTE_KEY(SEED ^ (32'h9E37_79B9 * (hash_idx + 1))),
        .MIX_KEY    ((SEED << (hash_idx % 13)) ^ (32'h85EB_CA6B * (hash_idx + 3)))
    ) u_hash (
        .data_i     (data_i),
        .hash_o     (),
        .indicator_o(s_lane_indicator[hash_idx])
    );
  end

  always_comb begin
    indicator_o = '0;
    for (int unsigned hash_idx = 0; hash_idx < HASHES; hash_idx++) begin
      indicator_o |= s_lane_indicator[hash_idx];
    end
  end

  initial begin
    if (DATA_WIDTH < 1 || HASH_WIDTH < 1 || HASH_WIDTH > DATA_WIDTH || HASH_WIDTH > 12 ||
        HASHES < 1 || ROUNDS < 1) begin
      $fatal(1, "hash_indicator_bank: invalid hash geometry");
    end
  end
endmodule

// A counting Bloom filter. Membership reports can be false positives but, if
// insertion/removal pairs are legal and counters do not saturate, never false
// negatives. insert_i and remove_i are mutually exclusive transactions.
module counting_bloom_filter #(
    parameter int          DATA_WIDTH   = 32,
    parameter int          HASH_WIDTH   = 5,
    parameter int          HASHES       = 3,
    parameter int          BUCKET_WIDTH = 4,
    parameter int          ROUNDS       = 2,
    parameter logic [31:0] SEED         = 32'hC0DE_1234
) (
    input  logic                  clk_i,
    input  logic                  rst_n_i,
    input  logic                  clear_i,
    input  logic [DATA_WIDTH-1:0] lookup_data_i,
    output logic                  member_o,
    input  logic [DATA_WIDTH-1:0] insert_data_i,
    input  logic                  insert_i,
    input  logic [DATA_WIDTH-1:0] remove_data_i,
    input  logic                  remove_i,
    output logic [  HASH_WIDTH:0] usage_o,
    output logic                  empty_o,
    output logic                  full_o,
    output logic                  saturated_o
);
  localparam int BUCKETS = 1 << HASH_WIDTH;
  logic [BUCKET_WIDTH-1:0] r_bucket             [0:BUCKETS-1];
  logic [     BUCKETS-1:0] s_lookup;
  logic [     BUCKETS-1:0] s_insert;
  logic [     BUCKETS-1:0] s_remove;
  logic [    HASH_WIDTH:0] r_usage;
  logic                    s_all_lookup_present;
  logic                    s_insert_saturates;
  logic                    s_remove_underflows;

  hash_indicator_bank #(
      .DATA_WIDTH(DATA_WIDTH),
      .HASH_WIDTH(HASH_WIDTH),
      .HASHES    (HASHES),
      .ROUNDS    (ROUNDS),
      .SEED      (SEED)
  ) u_lookup_hash (
      .data_i     (lookup_data_i),
      .indicator_o(s_lookup)
  );
  hash_indicator_bank #(
      .DATA_WIDTH(DATA_WIDTH),
      .HASH_WIDTH(HASH_WIDTH),
      .HASHES    (HASHES),
      .ROUNDS    (ROUNDS),
      .SEED      (SEED)
  ) u_insert_hash (
      .data_i     (insert_data_i),
      .indicator_o(s_insert)
  );
  hash_indicator_bank #(
      .DATA_WIDTH(DATA_WIDTH),
      .HASH_WIDTH(HASH_WIDTH),
      .HASHES    (HASHES),
      .ROUNDS    (ROUNDS),
      .SEED      (SEED)
  ) u_remove_hash (
      .data_i     (remove_data_i),
      .indicator_o(s_remove)
  );

  always_comb begin
    s_all_lookup_present = 1'b1;
    s_insert_saturates   = 1'b0;
    s_remove_underflows  = 1'b0;
    for (int unsigned bucket_idx = 0; bucket_idx < BUCKETS; bucket_idx++) begin
      if (s_lookup[bucket_idx] && (r_bucket[bucket_idx] == '0)) s_all_lookup_present = 1'b0;
      if (s_insert[bucket_idx] && (r_bucket[bucket_idx] == {BUCKET_WIDTH{1'b1}})) begin
        s_insert_saturates = 1'b1;
      end
      if (s_remove[bucket_idx] && (r_bucket[bucket_idx] == '0)) begin
        s_remove_underflows = 1'b1;
      end
    end
  end

  always_ff @(posedge clk_i or negedge rst_n_i) begin
    if (!rst_n_i || clear_i) begin
      r_usage     <= '0;
      saturated_o <= 1'b0;
      for (int unsigned bucket_idx = 0; bucket_idx < BUCKETS; bucket_idx++) begin
        r_bucket[bucket_idx] <= '0;
      end
    end else begin
      if (insert_i && !remove_i) begin
        if (r_usage != {HASH_WIDTH + 1{1'b1}}) r_usage <= r_usage + 1'b1;
        if (s_insert_saturates) saturated_o <= 1'b1;
        for (int unsigned bucket_idx = 0; bucket_idx < BUCKETS; bucket_idx++) begin
          if (s_insert[bucket_idx] && (r_bucket[bucket_idx] != {BUCKET_WIDTH{1'b1}})) begin
            r_bucket[bucket_idx] <= r_bucket[bucket_idx] + 1'b1;
          end
        end
      end else if (remove_i && !insert_i) begin
        if (r_usage != '0) r_usage <= r_usage - 1'b1;
        if (s_remove_underflows) saturated_o <= 1'b1;
        for (int unsigned bucket_idx = 0; bucket_idx < BUCKETS; bucket_idx++) begin
          if (s_remove[bucket_idx] && (r_bucket[bucket_idx] != '0)) begin
            r_bucket[bucket_idx] <= r_bucket[bucket_idx] - 1'b1;
          end
        end
      end
    end
  end

  assign member_o = s_all_lookup_present;
  assign usage_o  = r_usage;
  assign empty_o  = (r_usage == '0);
  assign full_o   = (r_usage == {HASH_WIDTH + 1{1'b1}});

`ifndef SYNTHESIS
  always_ff @(posedge clk_i) begin
    if (rst_n_i && !clear_i && insert_i && remove_i) begin
      $fatal(1, "counting_bloom_filter: insert_i and remove_i are mutually exclusive");
    end
  end
`endif

  initial begin
    if (DATA_WIDTH < 1 || HASH_WIDTH < 1 || HASH_WIDTH > DATA_WIDTH || HASH_WIDTH > 10 ||
        HASHES < 1 || BUCKET_WIDTH < 1 || ROUNDS < 1) begin
      $fatal(1, "counting_bloom_filter: invalid geometry");
    end
  end
endmodule
