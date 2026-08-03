// Copyright (c) 2023-2026 Yuchi Miao <miaoyuchi@ict.ac.cn>
// common is licensed under Mulan PSL v2.
// You can use this software according to the terms and conditions of the Mulan PSL v2.
// You may obtain a copy of Mulan PSL v2 at:
//             http://license.coscl.org.cn/MulanPSL2
// THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
// EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
// MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
// See the Mulan PSL v2 for more details.

//https://en.wikipedia.org/wiki/Linear-feedback_shift_register
// MSB -> LSB [DATA_WIDTH-1:0]
module lfsr_galois #(
    parameter int                    DATA_WIDTH = 32,
    parameter logic [DATA_WIDTH-1:0] POLY       = {{(DATA_WIDTH - 1) {1'b0}}, 1'b1},
    parameter logic [DATA_WIDTH-1:0] RESET_SEED = {{(DATA_WIDTH - 1) {1'b0}}, 1'b1}
) (
    input  logic                  clk_i,
    input  logic                  rst_n_i,
    input  logic                  wr_i,
    input  logic [DATA_WIDTH-1:0] dat_i,
    output logic [DATA_WIDTH-1:0] dat_o
);

  logic [DATA_WIDTH-1:0] s_shift_d, s_shift_q;
  initial begin
    if (DATA_WIDTH < 2 || POLY == '0 || RESET_SEED == '0) begin
      $fatal(1, "lfsr_galois: width, polynomial and reset seed must be non-zero");
    end
  end
  for (genvar i = 0; i < DATA_WIDTH; i++) begin : LFSR_GALOIS_BLOCK
    if (i == DATA_WIDTH - 1) begin : LFSR_GALOIS_LAST_BLOCK
      assign s_shift_d[i] = wr_i ? dat_i[i] : s_shift_q[0];
    end else begin : LFSR_GALOIS_NLAST_BLOCK
      if (|(POLY & (1 << i))) begin : LFSR_GALOIS_HVALUE_BLOCK
        assign s_shift_d[i] = wr_i ? dat_i[i] : s_shift_q[i+1] ^ s_shift_q[0];
      end else begin : LFSR_GALOIS_NHVALUE_BLOCK
        assign s_shift_d[i] = wr_i ? dat_i[i] : s_shift_q[i+1];
      end
    end
  end

  assign dat_o = s_shift_q;
  dffrc #(DATA_WIDTH, RESET_SEED) u_shift_dffrc (
      clk_i,
      rst_n_i,
      s_shift_d,
      s_shift_q
  );

endmodule

// Fibonacci form is retained for compatibility. It uses the same non-zero
// reset requirement as the Galois implementation.
module lfsr_fibonacci #(
    parameter int DATA_WIDTH = 32,
    parameter int SEED       = 0
) (
    input  logic                  clk_i,
    input  logic                  rst_n_i,
    input  logic                  wr_i,
    input  logic [DATA_WIDTH-1:0] dat_i,
    output logic [DATA_WIDTH-1:0] dat_o
);

  logic [DATA_WIDTH-1:0] s_shift_d, s_shift_q;
  initial begin
    if (DATA_WIDTH < 2 || SEED == 0) begin
      $fatal(1, "lfsr_fibonacci: DATA_WIDTH must be at least two and SEED non-zero");
    end
  end

  assign dat_o = s_shift_q;
  for (genvar i = 0; i <= DATA_WIDTH - 1; i++) begin : LFSR_FIBONACCI_BLOCK
    if (i == DATA_WIDTH - 1) begin
      assign s_shift_d[i] = wr_i ? dat_i[i] : s_shift_q[0] ^ s_shift_q[1];
    end else begin
      assign s_shift_d[i] = wr_i ? dat_i[i] : s_shift_q[i+1];
    end
  end

  dffrc #(DATA_WIDTH, SEED) u_shift_dffrc (
      clk_i,
      rst_n_i,
      s_shift_d,
      s_shift_q
  );

endmodule
