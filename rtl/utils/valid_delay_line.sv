// Copyright 2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License. You may obtain a copy at
// http://solderpad.org/licenses/SHL-0.51.
// SPDX-License-Identifier: SHL-0.51
//
// Derived design work: Copyright (c) 2026 Yuchi Miao <miaoyuchi@ict.ac.cn>
// Design independently implemented for common; see NOTICE for attribution.

// Delays valid-tagged data without a ready path. Payload flip-flops only load
// with a valid item, allowing synthesis to infer clock enables safely.
module valid_delay_line #(
    parameter int DATA_WIDTH = 32,
    parameter int DEPTH      = 2
) (
    input  logic                  clk_i,
    input  logic                  rst_n_i,
    input  logic                  clear_i,
    input  logic                  in_valid_i,
    input  logic [DATA_WIDTH-1:0] in_data_i,
    output logic                  out_valid_o,
    output logic [DATA_WIDTH-1:0] out_data_o
);
  if (DEPTH == 0) begin : GEN_BYPASS
    assign out_valid_o = in_valid_i;
    assign out_data_o  = in_data_i;
  end else begin : GEN_DELAY
    logic [DEPTH-1:0]                 r_valid;
    logic [DEPTH-1:0][DATA_WIDTH-1:0] r_data;
    always_ff @(posedge clk_i or negedge rst_n_i) begin
      if (!rst_n_i || clear_i) begin
        r_valid <= '0;
        r_data  <= '0;
      end else begin
        r_valid[0] <= in_valid_i;
        if (in_valid_i) r_data[0] <= in_data_i;
        for (int unsigned stage_idx = 1; stage_idx < DEPTH; stage_idx++) begin
          r_valid[stage_idx] <= r_valid[stage_idx-1];
          if (r_valid[stage_idx-1]) r_data[stage_idx] <= r_data[stage_idx-1];
        end
      end
    end
    assign out_valid_o = r_valid[DEPTH-1];
    assign out_data_o  = r_data[DEPTH-1];
  end

  initial begin
    if (DATA_WIDTH < 1 || DEPTH < 0) $fatal(1, "valid_delay_line: invalid geometry");
  end
endmodule
