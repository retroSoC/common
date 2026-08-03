// Copyright 2018 ETH Zurich and University of Bologna.
//
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License. You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.
// SPDX-License-Identifier: SHL-0.51
//
// Fabian Schuiki <fschuiki@iis.ee.ethz.ch>
//
// -- Adaptable modifications are redistributed under compatible License --
//
// Copyright (c) 2023-2026 Yuchi Miao <miaoyuchi@ict.ac.cn>
// common is licensed under Mulan PSL v2.
// You can use this software according to the terms and conditions of the Mulan PSL v2.
// You may obtain a copy of Mulan PSL v2 at:
//             http://license.coscl.org.cn/MulanPSL2
// THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
// EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
// MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
// See the Mulan PSL v2 for more details.

`include "config.svh"

module cdc_2phase #(
    parameter int DATA_WIDTH  = 32,
    parameter int SYNC_STAGES = 2
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

  logic                  s_async_req;
  logic                  s_async_ack;
  logic [DATA_WIDTH-1:0] s_async_data;
  logic                  s_link_rst_n;
  logic                  s_src_rst_n;
  logic                  s_dst_rst_n;
  logic                  s_src_ready;
  logic                  s_dst_valid;

  initial begin
    if (DATA_WIDTH < 1 || SYNC_STAGES < 2) begin
      $fatal(1, "cdc_2phase: DATA_WIDTH must be positive and SYNC_STAGES at least two");
    end
  end

  // A toggle handshake has no unambiguous unilateral-reset recovery state.
  // Either endpoint reset therefore aborts the in-flight item and flushes both
  // local protocol states before synchronized release.
  assign s_link_rst_n = src_rst_n_i && dst_rst_n_i;
  cdc_reset_barrier #(
      .STAGES(SYNC_STAGES)
  ) u_reset_barrier (
      .clk_a_i  (src_clk_i),
      .clk_b_i  (dst_clk_i),
      .rst_n_i  (s_link_rst_n),
      .release_i(1'b1),
      .rst_a_n_o(s_src_rst_n),
      .rst_b_n_o(s_dst_rst_n)
  );

  assign src_ready_o = s_src_rst_n && s_src_ready;
  assign dst_valid_o = s_dst_rst_n && s_dst_valid;

  cdc_2phase_src #(
      .DATA_WIDTH (DATA_WIDTH),
      .SYNC_STAGES(SYNC_STAGES)
  ) u_cdc_2phase_src (
      .clk_i       (src_clk_i),
      .rst_n_i     (s_src_rst_n),
      .data_i      (src_data_i),
      .valid_i     (src_valid_i),
      .ready_o     (s_src_ready),
      .async_req_o (s_async_req),
      .async_ack_i (s_async_ack),
      .async_data_o(s_async_data)
  );

  cdc_2phase_dst #(
      .DATA_WIDTH (DATA_WIDTH),
      .SYNC_STAGES(SYNC_STAGES)
  ) u_cdc_2phase_dst (
      .clk_i       (dst_clk_i),
      .rst_n_i     (s_dst_rst_n),
      .data_o      (dst_data_o),
      .valid_o     (s_dst_valid),
      .ready_i     (dst_ready_i),
      .async_req_i (s_async_req),
      .async_ack_o (s_async_ack),
      .async_data_i(s_async_data)
  );

endmodule

module cdc_2phase_src #(
    parameter int DATA_WIDTH  = 32,
    parameter int SYNC_STAGES = 2
) (
    input  logic                  clk_i,
    input  logic                  rst_n_i,
    input  logic [DATA_WIDTH-1:0] data_i,
    input  logic                  valid_i,
    output logic                  ready_o,
    output logic                  async_req_o,
    input  logic                  async_ack_i,
    output logic [DATA_WIDTH-1:0] async_data_o
);

  logic s_req_src_d, s_req_src_q;
  logic s_ack_src_d, s_ack_src_q;
  logic s_ack_q;
  logic [DATA_WIDTH-1:0] s_data_src_d, s_data_src_q;

  initial begin
    if (DATA_WIDTH < 1 || SYNC_STAGES < 2) begin
      $fatal(1, "cdc_2phase_src: DATA_WIDTH must be positive and SYNC_STAGES at least two");
    end
  end

  // The req_src and data_src registers change when a new data item is accepted.
  assign s_req_src_d = (valid_i && ready_o) ? ~s_req_src_q : s_req_src_q;
  dffr #(1) u_req_src_dffr (
      clk_i,
      rst_n_i,
      s_req_src_d,
      s_req_src_q
  );

  assign s_data_src_d = (valid_i && ready_o) ? data_i : s_data_src_q;
  dffr #(DATA_WIDTH) u_data_src_dffr (
      clk_i,
      rst_n_i,
      s_data_src_d,
      s_data_src_q
  );

  cdc_sync #(
      .STAGE(SYNC_STAGES)
  ) u_ack_sync (
      .clk_i  (clk_i),
      .rst_n_i(rst_n_i),
      .dat_i  (async_ack_i),
      .dat_o  (s_ack_q)
  );

  assign ready_o      = (s_req_src_q == s_ack_q);
  assign async_req_o  = s_req_src_q;
  assign async_data_o = s_data_src_q;

endmodule

module cdc_2phase_dst #(
    parameter int DATA_WIDTH  = 32,
    parameter int SYNC_STAGES = 2
) (
    input  logic                  rst_n_i,
    input  logic                  clk_i,
    output logic [DATA_WIDTH-1:0] data_o,
    output logic                  valid_o,
    input  logic                  ready_i,
    input  logic                  async_req_i,
    output logic                  async_ack_o,
    input  logic [DATA_WIDTH-1:0] async_data_i
);


  logic s_req_pre;
  logic s_req_sync;
  logic s_ack_dst_d, s_ack_dst_q;
  logic [DATA_WIDTH-1:0] s_data_dst_d, s_data_dst_q;

  initial begin
    if (DATA_WIDTH < 1 || SYNC_STAGES < 2) begin
      $fatal(1, "cdc_2phase_dst: DATA_WIDTH must be positive and SYNC_STAGES at least two");
    end
  end

  // The ack_dst register changes when a new data item is accepted.
  assign s_ack_dst_d = (valid_o && ready_i) ? ~s_ack_dst_q : s_ack_dst_q;
  dffr #(1) u_ack_dst_dffr (
      clk_i,
      rst_n_i,
      s_ack_dst_d,
      s_ack_dst_q
  );

  // Capture bundled data one cycle before the synchronized toggle becomes
  // visible as valid. The source holds it stable until acknowledgement.
  assign s_data_dst_d = (s_req_pre != s_req_sync && !valid_o) ? async_data_i : s_data_dst_q;
  dffr #(DATA_WIDTH) u_data_dst_dffr (
      clk_i,
      rst_n_i,
      s_data_dst_d,
      s_data_dst_q
  );

  cdc_sync_det #(
      .STAGE(SYNC_STAGES)
  ) u_req_sync (
      .clk_i    (clk_i),
      .rst_n_i  (rst_n_i),
      .dat_i    (async_req_i),
      .dat_pre_o(s_req_pre),
      .dat_o    (s_req_sync)
  );

  assign valid_o     = (s_ack_dst_q != s_req_sync);
  assign data_o      = s_data_dst_q;
  assign async_ack_o = s_ack_dst_q;

endmodule
