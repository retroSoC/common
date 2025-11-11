// Copyright 2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License. You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.
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
