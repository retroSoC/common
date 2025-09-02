// Copyright (c) 2023-2025 Yuchi Miao <miaoyuchi@ict.ac.cn>
// common is licensed under Mulan PSL v2.
// You can use this software according to the terms and conditions of the Mulan PSL v2.
// You may obtain a copy of Mulan PSL v2 at:
//             http://license.coscl.org.cn/MulanPSL2
// THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
// EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
// MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
// See the Mulan PSL v2 for more details.

//NOTE: buffer depth need to be 2^x val
module fifo #(
    parameter int DATA_WIDTH       = 32,
    parameter int BUFFER_DEPTH     = 8,
    parameter int LOG_BUFFER_DEPTH = (BUFFER_DEPTH > 1) ? $clog2(BUFFER_DEPTH) : 1
) (
    input  logic                      clk_i,
    input  logic                      rst_n_i,
    input  logic                      flush_i,
    output logic                      full_o,
    output logic                      empty_o,
    output logic [LOG_BUFFER_DEPTH:0] cnt_o,
    input  logic [    DATA_WIDTH-1:0] dat_i,
    input  logic                      push_i,
    output logic [    DATA_WIDTH-1:0] dat_o,
    input  logic                      pop_i
);

  logic [LOG_BUFFER_DEPTH - 1:0] s_rd_ptr_d, s_rd_ptr_q, s_wr_ptr_d, s_wr_ptr_q;
  logic [LOG_BUFFER_DEPTH:0] s_cnt_d, s_cnt_q;
  logic [BUFFER_DEPTH - 1:0][DATA_WIDTH-1:0] s_mem_d, s_mem_q;
  logic push_hdshk, pop_hdshk;

  assign push_hdshk = push_i & ~full_o;
  assign pop_hdshk  = pop_i & ~empty_o;
  assign cnt_o      = s_cnt_q;
  assign empty_o    = s_cnt_q == 0;
  assign full_o     = s_cnt_q == BUFFER_DEPTH[LOG_BUFFER_DEPTH:0];
  assign dat_o      = s_mem_q[s_rd_ptr_q];

  always_comb begin
    s_rd_ptr_d = s_rd_ptr_q;
    if (flush_i) begin
      s_rd_ptr_d = '0;
    end else if (pop_hdshk) begin
      s_rd_ptr_d = s_rd_ptr_q + 1'b1;
    end
  end
  dffr #(LOG_BUFFER_DEPTH) u_rd_ptr_dffr (
      clk_i,
      rst_n_i,
      s_rd_ptr_d,
      s_rd_ptr_q
  );

  always_comb begin
    s_wr_ptr_d = s_wr_ptr_q;
    if (flush_i) begin
      s_wr_ptr_d = '0;
    end else if (push_hdshk) begin
      s_wr_ptr_d = s_wr_ptr_q + 1'b1;
    end
  end
  dffr #(LOG_BUFFER_DEPTH) u_wr_ptr_dffr (
      clk_i,
      rst_n_i,
      s_wr_ptr_d,
      s_wr_ptr_q
  );

  // push, pop in the meantime, s_cnt_d will not change
  always_comb begin
    s_cnt_d = s_cnt_q;
    if (flush_i) begin
      s_cnt_d = '0;
    end else if (push_hdshk && ~pop_hdshk) begin
      s_cnt_d = s_cnt_q + 1'b1;
    end else if (~push_hdshk && pop_hdshk) begin
      s_cnt_d = s_cnt_q - 1'b1;
    end
  end
  dffr #(LOG_BUFFER_DEPTH + 1) u_cnt_dffr (
      clk_i,
      rst_n_i,
      s_cnt_d,
      s_cnt_q
  );

  always_comb begin
    s_mem_d = s_mem_q;
    if (push_hdshk) begin
      s_mem_d[s_wr_ptr_q] = dat_i;
    end
  end

  dffr #(BUFFER_DEPTH * DATA_WIDTH) u_mem_dffr (
      clk_i,
      rst_n_i,
      s_mem_d,
      s_mem_q
  );

endmodule


module stream_fifo #(
    parameter int DATA_WIDTH       = 32,
    parameter int BUFFER_DEPTH     = 8,
    parameter int LOG_BUFFER_DEPTH = (BUFFER_DEPTH > 1) ? $clog2(BUFFER_DEPTH) : 1
) (
    input  logic                      clk_i,
    input  logic                      rst_n_i,
    input  logic                      flush_i,
    output logic                      full_o,
    output logic                      empty_o,
    output logic [LOG_BUFFER_DEPTH:0] cnt_o,
    input  logic [    DATA_WIDTH-1:0] dat_i,
    input  logic                      push_i,
    output logic [    DATA_WIDTH-1:0] dat_o,
    input  logic                      pop_i
);

  logic [LOG_BUFFER_DEPTH - 1:0] s_rd_ptr_d, s_rd_ptr_q, s_wr_ptr_d, s_wr_ptr_q;
  logic [LOG_BUFFER_DEPTH:0] s_cnt_d, s_cnt_q;
  logic push_hdshk, pop_hdshk;

  assign push_hdshk = push_i & ~full_o;
  assign pop_hdshk  = pop_i & ~empty_o;
  assign cnt_o      = s_cnt_q;
  assign empty_o    = s_cnt_q == 0;
  assign full_o     = s_cnt_q == BUFFER_DEPTH;

  always_comb begin
    s_rd_ptr_d = s_rd_ptr_q;
    if (flush_i) begin
      s_rd_ptr_d = '0;
    end else if (pop_hdshk) begin
      s_rd_ptr_d = s_rd_ptr_q + 1'b1;
    end
  end
  dffr #(LOG_BUFFER_DEPTH) u_rd_ptr_dffr (
      clk_i,
      rst_n_i,
      s_rd_ptr_d,
      s_rd_ptr_q
  );

  always_comb begin
    s_wr_ptr_d = s_wr_ptr_q;
    if (flush_i) begin
      s_wr_ptr_d = '0;
    end else if (push_hdshk) begin
      s_wr_ptr_d = s_wr_ptr_q + 1'b1;
    end
  end
  dffr #(LOG_BUFFER_DEPTH) u_wr_ptr_dffr (
      clk_i,
      rst_n_i,
      s_wr_ptr_d,
      s_wr_ptr_q
  );

  // push, pop in the meantime, s_cnt_d will not change
  always_comb begin
    s_cnt_d = s_cnt_q;
    if (flush_i) begin
      s_cnt_d = '0;
    end else if (push_hdshk && ~pop_hdshk) begin
      s_cnt_d = s_cnt_q + 1'b1;
    end else if (~push_hdshk && pop_hdshk) begin
      s_cnt_d = s_cnt_q - 1'b1;
    end
  end
  dffr #(LOG_BUFFER_DEPTH + 1) u_cnt_dffr (
      clk_i,
      rst_n_i,
      s_cnt_d,
      s_cnt_q
  );

  // BUG: need to reimplement this block
  tech_regfile_bm #(
      .BIT_WIDTH (DATA_WIDTH),
      .WORD_DEPTH(BUFFER_DEPTH)
  ) u_tech_ram_bm (
      .clk_i (clk_i),
      .en_i  ('0),
      .wen_i (~push_hdshk),
      .bm_i  ('0),
      .addr_i(s_rd_ptr_q),
      .dat_i (dat_i),
      .dat_o (dat_o)
  );

endmodule
