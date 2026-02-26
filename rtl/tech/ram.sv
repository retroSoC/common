// Copyright (c) 2023-2025 Yuchi Miao <miaoyuchi@ict.ac.cn>
// common is licensed under Mulan PSL v2.
// You can use this software according to the terms and conditions of the Mulan PSL v2.
// You may obtain a copy of Mulan PSL v2 at:
//             http://license.coscl.org.cn/MulanPSL2
// THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
// EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
// MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
// See the Mulan PSL v2 for more details.

`include "config.svh"

// this file only include behavioral model, for ASIC tape-out need to reimplement those models
module tech_ram #(
    parameter int BIT_WIDTH  = 128,
    parameter int WORD_DEPTH = 64
) (
    input  logic                          clk_i,
    input  logic                          en_i,
    input  logic                          wen_i,
    input  logic [$clog2(WORD_DEPTH)-1:0] addr_i,
    input  logic [         BIT_WIDTH-1:0] dat_i,
    output logic [         BIT_WIDTH-1:0] dat_o

);

`ifdef BACKEND
  $error("need to instantiate specific technology cell in this block and remove this statement");
`else
  logic [BIT_WIDTH-1:0] r_intern_ram[0:WORD_DEPTH-1];
  always_ff @(posedge clk_i) begin
    if (~en_i && ~wen_i) begin
      r_intern_ram[addr_i] <= dat_i;
    end else begin
      dat_o <= (~en_i && wen_i) ? r_intern_ram[addr_i] : {(BIT_WIDTH / 32) {$random}};
    end
  end
`endif
endmodule

module tech_ram_bm #(
    parameter int BIT_WIDTH  = 128,
    parameter int WORD_DEPTH = 64
) (
    input  logic                          clk_i,
    input  logic                          en_i,
    input  logic                          wen_i,
    input  logic [       BIT_WIDTH/8-1:0] bm_i,
    input  logic [$clog2(WORD_DEPTH)-1:0] addr_i,
    input  logic [         BIT_WIDTH-1:0] dat_i,
    output logic [         BIT_WIDTH-1:0] dat_o

);

`ifdef BACKEND
  $error("need to instantiate specific technology cell in this block and remove this statement");
`else
  logic [WORD_DEPTH-1:0][BIT_WIDTH-1:0] r_intern_ram;
  logic [ BIT_WIDTH-1:0]                s_dat_i;
  for (genvar i = 0; i < BIT_WIDTH / 8; i++) begin
    assign s_dat_i[i*8+:8] = dat_i[i*8+:8] & {8{bm_i[i-1]}};
  end

  always_ff @(posedge clk_i) begin
    if (~en_i && ~wen_i) begin
      r_intern_ram[addr_i] <= s_dat_i;
    end else begin
      dat_o <= (~en_i && wen_i) ? r_intern_ram[addr_i] : {(BIT_WIDTH / 32) {$random}};
    end
  end
`endif
endmodule
