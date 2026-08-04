// Copyright 2019 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License. You may obtain a copy at
// http://solderpad.org/licenses/SHL-0.51.
// SPDX-License-Identifier: SHL-0.51
//
// Original concepts include dynamically configured range and address-set
// decoding. Derived design work: Copyright (c) 2026 Yuchi Miao
// <miaoyuchi@ict.ac.cn>. Design independently implemented for common; see
// NOTICE for attribution.

// Lowest numbered matching entry wins. An end value of zero means the range
// continues through the top of the address space.
module address_range_decoder #(
    parameter int ADDR_WIDTH  = 32,
    parameter int RULES       = 4,
    parameter int TARGETS     = 4,
    parameter int INDEX_WIDTH = (TARGETS > 1) ? $clog2(TARGETS) : 1
) (
    input  logic [ ADDR_WIDTH-1:0]                  addr_i,
    input  logic [      RULES-1:0][INDEX_WIDTH-1:0] target_i,
    input  logic [      RULES-1:0][ ADDR_WIDTH-1:0] first_i,
    input  logic [      RULES-1:0][ ADDR_WIDTH-1:0] last_i,
    input  logic                                    updating_i,
    input  logic                                    default_enable_i,
    input  logic [INDEX_WIDTH-1:0]                  default_target_i,
    output logic [    TARGETS-1:0]                  select_o,
    output logic [INDEX_WIDTH-1:0]                  target_o,
    output logic                                    valid_o,
    output logic                                    error_o
);
  logic s_found;

  always_comb begin
    select_o = '0;
    target_o = '0;
    valid_o  = 1'b0;
    s_found  = 1'b0;
    for (int unsigned rule_idx = 0; rule_idx < RULES; rule_idx++) begin
      if (!s_found && (target_i[rule_idx] < TARGETS) &&
          (addr_i >= first_i[rule_idx]) &&
          ((last_i[rule_idx] == '0) || (addr_i < last_i[rule_idx]))) begin
        select_o[target_i[rule_idx]] = 1'b1;
        target_o                     = target_i[rule_idx];
        valid_o                      = 1'b1;
        s_found                      = 1'b1;
      end
    end
    if (!s_found && default_enable_i && (default_target_i < TARGETS)) begin
      select_o[default_target_i] = 1'b1;
      target_o                   = default_target_i;
      valid_o                    = 1'b1;
    end
    error_o = !valid_o && !updating_i;
  end

  initial begin
    if (ADDR_WIDTH < 1 || RULES < 1 || TARGETS < 1 || INDEX_WIDTH < ((TARGETS > 1) ? $clog2(
            TARGETS
        ) : 1)) begin
      $fatal(1, "address_range_decoder: invalid geometry");
    end
  end
endmodule

// Routes an address set represented as {address, wildcard-mask}. A rule may
// match partially; the corresponding output set is the intersection.
module address_set_decoder #(
    parameter int ADDR_WIDTH  = 32,
    parameter int RULES       = 4,
    parameter int TARGETS     = 4,
    parameter int INDEX_WIDTH = (TARGETS > 1) ? $clog2(TARGETS) : 1
) (
    input  logic [ ADDR_WIDTH-1:0]                  addr_i,
    input  logic [ ADDR_WIDTH-1:0]                  wildcard_i,
    input  logic [      RULES-1:0][INDEX_WIDTH-1:0] target_i,
    input  logic [      RULES-1:0][ ADDR_WIDTH-1:0] rule_addr_i,
    input  logic [      RULES-1:0][ ADDR_WIDTH-1:0] rule_wildcard_i,
    input  logic                                    default_enable_i,
    input  logic [INDEX_WIDTH-1:0]                  default_target_i,
    output logic [    TARGETS-1:0]                  select_o,
    output logic [    TARGETS-1:0][ ADDR_WIDTH-1:0] addr_o,
    output logic [    TARGETS-1:0][ ADDR_WIDTH-1:0] wildcard_o,
    output logic                                    valid_o,
    output logic                                    error_o
);
  logic [ADDR_WIDTH-1:0] s_dont_care;
  logic [ADDR_WIDTH-1:0] s_matching;

  always_comb begin
    select_o   = '0;
    addr_o     = '0;
    wildcard_o = '0;
    valid_o    = 1'b0;
    for (int unsigned rule_idx = 0; rule_idx < RULES; rule_idx++) begin
      s_dont_care = wildcard_i | rule_wildcard_i[rule_idx];
      s_matching  = ~(addr_i ^ rule_addr_i[rule_idx]);
      if ((target_i[rule_idx] < TARGETS) && &(s_dont_care | s_matching)) begin
        select_o[target_i[rule_idx]] = 1'b1;
        wildcard_o[target_i[rule_idx]] = wildcard_i & rule_wildcard_i[rule_idx];
        addr_o[target_i[rule_idx]] = (~wildcard_i & addr_i) | (wildcard_i & rule_addr_i[rule_idx]);
        valid_o = 1'b1;
      end
    end
    if (default_enable_i && (default_target_i < TARGETS) && !valid_o) begin
      select_o[default_target_i]   = 1'b1;
      addr_o[default_target_i]     = addr_i;
      wildcard_o[default_target_i] = wildcard_i;
      valid_o                      = 1'b1;
    end
    error_o = !valid_o;
  end

  initial begin
    if (ADDR_WIDTH < 1 || RULES < 1 || TARGETS < 1 || INDEX_WIDTH < ((TARGETS > 1) ? $clog2(
            TARGETS
        ) : 1)) begin
      $fatal(1, "address_set_decoder: invalid geometry");
    end
  end
endmodule
