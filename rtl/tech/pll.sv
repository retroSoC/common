// Copyright (c) 2023-2026 Yuchi Miao <miaoyuchi@ict.ac.cn>
// common is licensed under Mulan PSL v2.
// You can use this software according to the terms and conditions of the Mulan PSL v2.
// You may obtain a copy of Mulan PSL v2 at:
//             http://license.coscl.org.cn/MulanPSL2
// THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
// EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
// MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
// See the Mulan PSL v2 for more details.

// this file only include behavioral model, for ASIC tape-out need to reimplement those models

module tech_pll #(
) (
    input  logic        fref_i,
    input  logic [ 5:0] refdiv_i,
    input        [11:0] fbdiv_i,
    input  logic [ 2:0] postdiv1_i,
    input  logic [ 2:0] postdiv2_i,
    output logic        pll_lock_o,
    output logic        pll_clk_o
);

`ifdef BACKEND
  $error("need to instantiate specific technology cell in this block and remove this statement");
`else
  assign pll_lock_o = 1'b1;
  assign pll_clk_o  = fref_i;
`endif
endmodule
