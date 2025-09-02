// Copyright 2018-2019 ETH Zurich and University of Bologna.
//
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License. You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.
//
// Fabian Schuiki <fschuiki@iis.ee.ethz.ch>
// Florian Zaruba <zarubaf@iis.ee.ethz.ch>
//
// -- Adaptable modifications are redistributed under compatible License --
//
// Copyright (c) 2023-2025 Yuchi Miao <miaoyuchi@ict.ac.cn>
// common is licensed under Mulan PSL v2.
// You can use this software according to the terms and conditions of the Mulan PSL v2.
// You may obtain a copy of Mulan PSL v2 at:
//             http://license.coscl.org.cn/MulanPSL2
// THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
// EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
// MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
// See the Mulan PSL v2 for more details.

// verilog_format: off
(* no_ungroup *)
(* no_boundary_optimization *)
// verilog_format: on
module cdc_fifo #(
    parameter int DATA_WIDTH   = 32,
    parameter int BUFFER_DEPTH = 8,
    parameter int SYNC_STAGES  = 2
) (
    input  logic                  src_clk_i,
    input  logic                  src_rst_n_i,
    input  logic [DATA_WIDTH-1:0] src_data_i,
    input  logic                  src_valid_i,
    output logic                  src_ready_o,

    input  logic                  dst_clk_i,
    input  logic                  dst_rst_n_i,
    output logic [DATA_WIDTH-1:0] dst_data_o,
    output logic                  dst_valid_o,
    input  logic                  dst_ready_i
);
  localparam int LOG_BUFFER_DEPTH = (BUFFER_DEPTH > 1) ? $clog2(BUFFER_DEPTH) : 1;

  logic [BUFFER_DEPTH-1:0][DATA_WIDTH-1:0] s_int_mem;
  logic [LOG_BUFFER_DEPTH:0] s_wr_ptr_gray, s_rd_ptr_gray;

  cdc_fifo_src #(DATA_WIDTH, BUFFER_DEPTH, SYNC_STAGES) u_cdc_fifo_src (
                  .clk_i         (src_clk_i),
                  .rst_n_i       (src_rst_n_i),
                  .data_i        (src_data_i),
                  .valid_i       (src_valid_i),
                  .ready_o       (src_ready_o),
      (* async *) .async_data_o  (s_int_mem),
      (* async *) .async_wr_ptr_o(s_wr_ptr_gray),
      (* async *) .async_rd_ptr_i(s_rd_ptr_gray)
  );

  cdc_fifo_dst #(DATA_WIDTH, BUFFER_DEPTH, SYNC_STAGES) u_cdc_fifo_dst (
                  .clk_i         (dst_clk_i),
                  .rst_n_i       (dst_rst_n_i),
                  .data_o        (dst_data_o),
                  .valid_o       (dst_valid_o),
                  .ready_i       (dst_ready_i),
      (* async *) .async_data_i  (s_int_mem),
      (* async *) .async_wr_ptr_i(s_wr_ptr_gray),
      (* async *) .async_rd_ptr_o(s_rd_ptr_gray)
  );
endmodule

// verilog_format: off
(* no_ungroup *)
(* no_boundary_optimization *)
// verilog_format: on
module cdc_fifo_src #(
    parameter int DATA_WIDTH       = 32,
    parameter int BUFFER_DEPTH     = 8,
    parameter int SYNC_STAGES      = 2,
    parameter int LOG_BUFFER_DEPTH = (BUFFER_DEPTH > 1) ? $clog2(BUFFER_DEPTH) : 1
) (
    input  logic                                      clk_i,
    input  logic                                      rst_n_i,
    input  logic [    DATA_WIDTH-1:0]                 data_i,
    input  logic                                      valid_i,
    output logic                                      ready_o,
    output logic [  BUFFER_DEPTH-1:0][DATA_WIDTH-1:0] async_data_o,
    output logic [LOG_BUFFER_DEPTH:0]                 async_wr_ptr_o,
    input  logic [LOG_BUFFER_DEPTH:0]                 async_rd_ptr_i
);

  localparam int PTR_WIDTH = LOG_BUFFER_DEPTH + 1;
  localparam logic [PTR_WIDTH-1:0] PTR_FULL = (1 << LOG_BUFFER_DEPTH);

  logic [BUFFER_DEPTH-1:0][DATA_WIDTH-1:0] s_data;
  logic [PTR_WIDTH-1:0] s_wr_ptr_gray_d, s_wr_ptr_gray_q;
  logic [PTR_WIDTH-1:0] s_wr_ptr_bin, s_wr_ptr_bin_nxt;
  logic [PTR_WIDTH-1:0] s_rd_ptr_gray, s_rd_ptr_bin;
  logic s_hdshk;

  assign s_hdshk        = valid_i & ready_o;
  assign ready_o        = (s_wr_ptr_bin ^ s_rd_ptr_bin) != PTR_FULL;
  assign async_data_o   = s_data;
  assign async_wr_ptr_o = s_wr_ptr_gray_q;

  for (genvar i = 0; i < BUFFER_DEPTH; i++) begin : CDC_FIFO_SRC_DATA
    dffer #(DATA_WIDTH) u_data_dffer (
        clk_i,
        rst_n_i,
        s_hdshk && (s_wr_ptr_bin[LOG_BUFFER_DEPTH-1:0] == i),
        data_i,
        s_data[i]
    );
  end

  // rd
  cdc_sync #(
      .STAGE     (SYNC_STAGES),
      .DATA_WIDTH(PTR_WIDTH)
  ) u_rd_ptr_sync (
      clk_i,
      rst_n_i,
      async_rd_ptr_i,
      s_rd_ptr_gray
  );

  gray2bin #(PTR_WIDTH) u_rd_ptr_g2b (
      s_rd_ptr_gray,
      s_rd_ptr_bin
  );

  // wr
  gray2bin #(PTR_WIDTH) u_wr_ptr_g2b (
      s_wr_ptr_gray_q,
      s_wr_ptr_bin
  );

  assign s_wr_ptr_bin_nxt = s_wr_ptr_bin + 1'b1;
  bin2gray #(PTR_WIDTH) u_wr_ptr_b2g (
      s_wr_ptr_bin_nxt,
      s_wr_ptr_gray_d
  );

  dffer #(PTR_WIDTH) u_wr_ptr_gray_dffer (
      clk_i,
      rst_n_i,
      s_hdshk,
      s_wr_ptr_gray_d,
      s_wr_ptr_gray_q
  );
endmodule

// verilog_format: off
(* no_ungroup *)
(* no_boundary_optimization *)
// verilog_format: on
module cdc_fifo_dst #(
    parameter int DATA_WIDTH       = 32,
    parameter int BUFFER_DEPTH     = 8,
    parameter int SYNC_STAGES      = 2,
    parameter int LOG_BUFFER_DEPTH = (BUFFER_DEPTH > 1) ? $clog2(BUFFER_DEPTH) : 1
) (
    input  logic                                      clk_i,
    input  logic                                      rst_n_i,
    output logic [    DATA_WIDTH-1:0]                 data_o,
    output logic                                      valid_o,
    input  logic                                      ready_i,
    input  logic [  BUFFER_DEPTH-1:0][DATA_WIDTH-1:0] async_data_i,
    input  logic [LOG_BUFFER_DEPTH:0]                 async_wr_ptr_i,
    output logic [LOG_BUFFER_DEPTH:0]                 async_rd_ptr_o
);

  localparam int PTR_WIDTH = LOG_BUFFER_DEPTH + 1;
  localparam logic [PTR_WIDTH-1:0] PTR_EMPTY = '0;

  logic [DATA_WIDTH-1:0] s_data;
  logic [PTR_WIDTH-1:0] s_rd_ptr_gray_q, s_rd_ptr_gray_d;
  logic [PTR_WIDTH-1:0] s_rd_ptr_bin, s_rd_ptr_bin_nxt;
  logic [PTR_WIDTH-1:0] s_wr_ptr_gray, s_wr_ptr_bin;
  logic s_hdshk, s_valid, s_ready;

  assign s_hdshk        = s_valid & s_ready;
  assign s_data         = async_data_i[s_rd_ptr_bin[LOG_BUFFER_DEPTH-1:0]];
  assign s_valid        = (s_wr_ptr_bin ^ s_rd_ptr_bin) != PTR_EMPTY;
  assign async_rd_ptr_o = s_rd_ptr_gray_q;

  // wr
  cdc_sync #(
      .STAGE     (SYNC_STAGES),
      .DATA_WIDTH(PTR_WIDTH)
  ) u_wr_ptr_sync (
      clk_i,
      rst_n_i,
      async_wr_ptr_i,
      s_wr_ptr_gray
  );

  gray2bin #(PTR_WIDTH) u_wr_ptr_g2b (
      s_wr_ptr_gray,
      s_wr_ptr_bin
  );

  // rd
  gray2bin #(PTR_WIDTH) u_rd_ptr_g2b (
      s_rd_ptr_gray_q,
      s_rd_ptr_bin
  );

  assign s_rd_ptr_bin_nxt = s_rd_ptr_bin + 1'b1;
  bin2gray #(PTR_WIDTH) u_rd_ptr_b2g (
      s_rd_ptr_bin_nxt,
      s_rd_ptr_gray_d
  );

  dffer #(PTR_WIDTH) u_rd_ptr_gray_dffer (
      clk_i,
      rst_n_i,
      s_hdshk,
      s_rd_ptr_gray_d,
      s_rd_ptr_gray_q
  );

  spill_register #(DATA_WIDTH) u_spill_register (
      .clk_i  (clk_i),
      .rst_n_i(rst_n_i),
      .flush_i(1'b0),
      .valid_i(s_valid),
      .ready_o(s_ready),
      .data_i (s_data),
      .valid_o(valid_o),
      .ready_i(ready_i),
      .data_o (data_o)
  );
endmodule
