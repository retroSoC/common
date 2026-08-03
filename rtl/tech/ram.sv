// Copyright (c) 2023-2026 Yuchi Miao <miaoyuchi@ict.ac.cn>
// SPDX-License-Identifier: MulanPSL-2.0
// Behavioral replacement for technology RAMs. en_i, wen_i and bm_i are active
// low to retain the historical public interface. Disabled reads hold dat_o.

module tech_ram #(
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
`ifdef BACKEND
  $error("tech_ram: provide a technology implementation when BACKEND is set");
`else
  logic [BIT_WIDTH-1:0] r_storage[0:WORD_DEPTH-1];

  initial begin
    if (BIT_WIDTH < 1 || WORD_DEPTH < 1) $fatal(1, "tech_ram: invalid geometry");
  end

  always_ff @(posedge clk_i) begin
    if (!en_i && !wen_i) begin
      r_storage[addr_i] <= dat_i;
    end else if (!en_i && wen_i) begin
      dat_o <= r_storage[addr_i];
    end
  end
`endif
endmodule

module tech_ram_bm #(
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
`ifdef BACKEND
  $error("tech_ram_bm: provide a technology implementation when BACKEND is set");
`else
  logic [BIT_WIDTH-1:0] r_storage[0:WORD_DEPTH-1];

  initial begin
    if (BIT_WIDTH < 8 || BIT_WIDTH % 8 != 0 || WORD_DEPTH < 1) begin
      $fatal(1, "tech_ram_bm: BIT_WIDTH must be a positive multiple of eight");
    end
  end

  always_ff @(posedge clk_i) begin
    if (!en_i && !wen_i) begin
      for (int unsigned byte_idx = 0; byte_idx < BYTE_COUNT; byte_idx++) begin
        if (!bm_i[byte_idx]) begin
          r_storage[addr_i][byte_idx*8+:8] <= dat_i[byte_idx*8+:8];
        end
      end
    end else if (!en_i && wen_i) begin
      dat_o <= r_storage[addr_i];
    end
  end
`endif
endmodule
