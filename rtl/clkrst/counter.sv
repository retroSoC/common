// Copyright 2018 ETH Zurich and University of Bologna.
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

module rs_counter #(
    parameter int DATA_WIDTH = 4
) (
    input  logic                  clk_i,
    input  logic                  rst_n_i,
    input  logic                  clr_i,
    input  logic                  en_i,
    input  logic                  load_i,
    input  logic                  down_i,
    input  logic [DATA_WIDTH-1:0] dat_i,
    output logic [DATA_WIDTH-1:0] dat_o,
    output logic                  ovf_o
);

  initial begin
    if (DATA_WIDTH < 1) $fatal(1, "rs_counter: DATA_WIDTH must be positive");
  end

  rs_delta_counter #(DATA_WIDTH) u_delta_counter (
      .clk_i,
      .rst_n_i,
      .clr_i,
      .en_i,
      .load_i,
      .down_i,
      .delta_i({{(DATA_WIDTH - 1) {1'b0}}, 1'b1}),
      .dat_i,
      .dat_o,
      .ovf_o
  );
endmodule

module rs_delta_counter #(
    parameter int DATA_WIDTH = 4
) (
    input  logic                  clk_i,
    input  logic                  rst_n_i,
    input  logic                  clr_i,
    input  logic                  en_i,
    input  logic                  load_i,
    input  logic                  down_i,
    input  logic [DATA_WIDTH-1:0] delta_i,
    input  logic [DATA_WIDTH-1:0] dat_i,
    output logic [DATA_WIDTH-1:0] dat_o,
    output logic                  ovf_o
);

  logic [DATA_WIDTH:0] s_cnt_d, s_cnt_q;

  initial begin
    if (DATA_WIDTH < 1) $fatal(1, "rs_delta_counter: DATA_WIDTH must be positive");
  end

  assign dat_o = s_cnt_q[DATA_WIDTH-1:0];
  assign ovf_o = s_cnt_q[DATA_WIDTH];

  always_comb begin
    s_cnt_d = s_cnt_q;
    if (clr_i) begin
      s_cnt_d = '0;
    end else if (load_i) begin
      s_cnt_d = {1'b0, dat_i};
    end else if (en_i) begin
      if (down_i) begin
        s_cnt_d = s_cnt_q - delta_i;
      end else begin
        s_cnt_d = s_cnt_q + delta_i;
      end
    end
  end

  dffr #(DATA_WIDTH + 1) u_cnt_dffr (
      .clk_i,
      .rst_n_i,
      .dat_i(s_cnt_d),
      .dat_o(s_cnt_q)
  );

endmodule

// Delta counter with a separate high-water mark. The counter state itself is
// provided by rs_delta_counter; the peak uses the same next-state arithmetic so
// an increment is reflected in peak_o on the same clock edge.
module peak_delta_counter #(
    parameter int DATA_WIDTH = 4
) (
    input  logic                  clk_i,
    input  logic                  rst_n_i,
    input  logic                  flush_i,
    input  logic                  clear_value_i,
    input  logic                  clear_peak_i,
    input  logic                  enable_i,
    input  logic                  load_i,
    input  logic                  subtract_i,
    input  logic [DATA_WIDTH-1:0] step_i,
    input  logic [DATA_WIDTH-1:0] load_value_i,
    output logic [DATA_WIDTH-1:0] value_o,
    output logic [DATA_WIDTH-1:0] peak_o,
    output logic                  value_overflow_o,
    output logic                  peak_overflow_o
);
  logic [DATA_WIDTH:0] s_value_next;
  logic [DATA_WIDTH:0] s_peak_next;
  logic [DATA_WIDTH:0] r_peak;

  initial begin
    if (DATA_WIDTH < 1) $fatal(1, "peak_delta_counter: DATA_WIDTH must be positive");
  end

  rs_delta_counter #(
      .DATA_WIDTH(DATA_WIDTH)
  ) u_value_counter (
      .clk_i  (clk_i),
      .rst_n_i(rst_n_i),
      .clr_i  (flush_i || clear_value_i),
      .en_i   (enable_i),
      .load_i (load_i),
      .down_i (subtract_i),
      .delta_i(step_i),
      .dat_i  (load_value_i),
      .dat_o  (value_o),
      .ovf_o  (value_overflow_o)
  );

  always_comb begin
    s_value_next = {value_overflow_o, value_o};
    if (flush_i || clear_value_i) begin
      s_value_next = '0;
    end else if (load_i) begin
      s_value_next = {1'b0, load_value_i};
    end else if (enable_i) begin
      if (subtract_i) begin
        s_value_next = {value_overflow_o, value_o} - step_i;
      end else begin
        s_value_next = {value_overflow_o, value_o} + step_i;
      end
    end

    if (flush_i || clear_peak_i) begin
      s_peak_next = '0;
    end else if (s_value_next > r_peak) begin
      s_peak_next = s_value_next;
    end else begin
      s_peak_next = r_peak;
    end
  end

  dffr #(
      .DATA_WIDTH(DATA_WIDTH + 1)
  ) u_peak_state (
      .clk_i  (clk_i),
      .rst_n_i(rst_n_i),
      .dat_i  (s_peak_next),
      .dat_o  (r_peak)
  );

  assign peak_o          = r_peak[DATA_WIDTH-1:0];
  assign peak_overflow_o = r_peak[DATA_WIDTH];
endmodule
