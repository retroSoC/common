// Copyright (c) 2023-2026 Yuchi Miao <miaoyuchi@ict.ac.cn>
// SPDX-License-Identifier: MulanPSL-2.0
// Compatibility behavioral register-file models. All controls are active low;
// disabled operations retain the previous read value rather than injecting X
// or random data, making regressions deterministic.

module tech_regfile #(
    parameter int BIT_WIDTH  = 128,
    parameter int WORD_DEPTH = 64,
    parameter int ADDR_WIDTH = (WORD_DEPTH > 1) ? $clog2(WORD_DEPTH) : 1
) (
    input  logic                  clk_i,
    input  logic                  en_i,
    input  logic                  wen_i,
    input  logic [ADDR_WIDTH-1:0] addr_i,
    input  logic [ BIT_WIDTH-1:0] dat_i,
    output logic [ BIT_WIDTH-1:0] dat_o
);
`ifdef TECH_REGFILE_BACKEND
  $error("tech_regfile: provide a technology implementation when backend is enabled");
`else
  logic [BIT_WIDTH-1:0] r_storage[0:WORD_DEPTH-1];
  always_ff @(posedge clk_i) begin
    if (!en_i && !wen_i) r_storage[addr_i] <= dat_i;
    else if (!en_i && wen_i) dat_o <= r_storage[addr_i];
  end
`endif
endmodule

module tech_regfile_bm #(
    parameter int BIT_WIDTH  = 128,
    parameter int WORD_DEPTH = 64,
    parameter int ADDR_WIDTH = (WORD_DEPTH > 1) ? $clog2(WORD_DEPTH) : 1,
    parameter int BYTE_COUNT = BIT_WIDTH / 8
) (
    input  logic                  clk_i,
    input  logic                  en_i,
    input  logic                  wen_i,
    input  logic [BYTE_COUNT-1:0] bm_i,
    input  logic [ADDR_WIDTH-1:0] addr_i,
    input  logic [ BIT_WIDTH-1:0] dat_i,
    output logic [ BIT_WIDTH-1:0] dat_o
);
`ifdef TECH_REGFILE_BM_BACKEND
  $error("tech_regfile_bm: provide a technology implementation when backend is enabled");
`else
  logic [BIT_WIDTH-1:0] r_storage[0:WORD_DEPTH-1];
  initial begin
    if (BIT_WIDTH < 8 || BIT_WIDTH % 8 != 0 || WORD_DEPTH < 1) begin
      $fatal(1, "tech_regfile_bm: BIT_WIDTH must be a positive multiple of eight");
    end
  end
  always_ff @(posedge clk_i) begin
    if (!en_i && !wen_i) begin
      for (int unsigned byte_idx = 0; byte_idx < BYTE_COUNT; byte_idx++) begin
        if (!bm_i[byte_idx]) r_storage[addr_i][byte_idx*8+:8] <= dat_i[byte_idx*8+:8];
      end
    end else if (!en_i && wen_i) begin
      dat_o <= r_storage[addr_i];
    end
  end
`endif
endmodule
