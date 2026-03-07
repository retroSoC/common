// Copyright 2021 ETH Zurich and University of Bologna.
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

module spill_register #(
    parameter int DATA_WIDTH = 32,
    parameter bit BYPASS     = 1'b0  // transparent
) (
    input  logic                  clk_i,
    input  logic                  rst_n_i,
    input  logic                  flush_i,
    input  logic                  valid_i,
    output logic                  ready_o,
    input  logic [DATA_WIDTH-1:0] data_i,
    output logic                  valid_o,
    input  logic                  ready_i,
    output logic [DATA_WIDTH-1:0] data_o
);

  if (BYPASS) begin : SPILL_REG_GEN_BYPASS
    assign valid_o = valid_i;
    assign ready_o = ready_i;
    assign data_o  = data_i;
  end else begin : SPILL_REG_GEN_SPILL
    // The A and B register
    logic [DATA_WIDTH-1:0] r_a_data, r_b_data;
    logic r_a_full, r_b_full;
    logic s_a_fill, s_a_drain, s_b_fill, s_b_drain;

    always_ff @(posedge clk_i or negedge rst_n_i) begin
      if (!rst_n_i) r_a_data <= '0;
      else if (s_a_fill) r_a_data <= data_i;
    end

    always_ff @(posedge clk_i or negedge rst_n_i) begin
      if (!rst_n_i) r_a_full <= 0;
      else if (s_a_fill || s_a_drain) r_a_full <= s_a_fill;
    end

    always_ff @(posedge clk_i or negedge rst_n_i) begin
      if (!rst_n_i) r_b_data <= '0;
      else if (s_b_fill) r_b_data <= r_a_data;
    end

    always_ff @(posedge clk_i or negedge rst_n_i) begin
      if (!rst_n_i) r_b_full <= 0;
      else if (s_b_fill || s_b_drain) r_b_full <= s_b_fill;
    end

    // Fill the A register when the A or B register is empty. Drain the A register
    // whenever it is full and being filled, or if a flush is requested.
    assign s_a_fill  = valid_i && ready_o && (!flush_i);
    assign s_a_drain = (r_a_full && !r_b_full) || flush_i;
    // Fill the B register whenever the A register is drained, but the downstream
    // circuit is not ready. Drain the B register whenever it is full and the
    // downstream circuit is ready, or if a flush is requested.
    assign s_b_fill  = s_a_drain && (!ready_i) && (!flush_i);
    assign s_b_drain = (r_b_full && ready_i) || flush_i;
    // We can accept input as long as register B is not full.
    // Note: flush_i and valid_i must not be high at the same time,
    // otherwise an invalid handshake may occur
    assign ready_o   = !r_a_full || !r_b_full;
    // The unit provides output as long as one of the registers is filled.
    assign valid_o   = r_a_full | r_b_full;
    // We empty the spill register before the slice register.
    assign data_o    = r_b_full ? r_b_data : r_a_data;
  end
endmodule
