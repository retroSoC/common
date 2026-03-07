// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Register slice conforming STWG verilog guide.
//
// -- Adaptable modifications are redistributed under compatible License --
//
// Copyright (c) 2023-2026 Yuchi Miao <miaoyuchi@ict.ac.cn>
// archinfo is licensed under Mulan PSL v2.
// You can use this software according to the terms and conditions of the Mulan PSL v2.
// You may obtain a copy of Mulan PSL v2 at:
//             http://license.coscl.org.cn/MulanPSL2
// THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
// EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
// MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
// See the Mulan PSL v2 for more details.

module regfield #(
    parameter                        DATA_WIDTH = 32,
    parameter                        SW_ACS     = "rw",  // rw, ro, wo, w1c, w1s, w0c, rc
    parameter logic [DATA_WIDTH-1:0] RST_VAL    = '0     // Reset value
) (
    input                         clk_i,
    input                         rst_n_i,
    // from sw, in case of rc, top connects rd pulse to sw_wen_i
    input                         sw_wen_i,
    input        [DATA_WIDTH-1:0] sw_wdata_i,
    // from hw: valid for hrw, hwo
    input                         hw_wen_i,
    input        [DATA_WIDTH-1:0] hw_wdata_i,
    // output to hw and reg rd
    output logic                  data_en_o,
    output logic [DATA_WIDTH-1:0] data_o
);

  logic                  s_wen;
  logic [DATA_WIDTH-1:0] s_wdata;

  if ((SW_ACS == "rw") || (SW_ACS == "wo")) begin : gen_w
    assign s_wen   = sw_wen_i | hw_wen_i;
    assign s_wdata = (sw_wen_i == 1'b1) ? sw_wdata_i : hw_wdata_i;  // sw higher priority
  end else if (SW_ACS == "ro") begin : gen_ro
    // unused sw_wen_i, sw_wdata_i
    assign s_wen   = hw_wen_i;
    assign s_wdata = hw_wdata_i;
  end else if (SW_ACS == "w1s") begin : gen_w1s
    // if SW_ACS is w1s, then assume hw tries to clear.
    // so, give a chance hw to clear when sw tries to set.
    // if both try to set/clr at the same bit pos, sw wins.
    assign s_wen   = sw_wen_i | hw_wen_i;
    assign s_wdata = (hw_wen_i ? hw_wdata_i : data_o) | (sw_wen_i ? sw_wdata_i : '0);
  end else if (SW_ACS == "w1c") begin : gen_w1c
    // if SW_ACS is w1c, then assume hw tries to set.
    // so, give a chance hw to set when sw tries to clear.
    // if both try to set/clr at the same bit pos, sw wins.
    assign s_wen   = sw_wen_i | hw_wen_i;
    assign s_wdata = (hw_wen_i ? hw_wdata_i : data_o) & (sw_wen_i ? ~sw_wdata_i : '1);
  end else if (SW_ACS == "w0c") begin : gen_w0c
    assign s_wen   = sw_wen_i | hw_wen_i;
    assign s_wdata = (hw_wen_i ? hw_wdata_i : data_o) & (sw_wen_i ? sw_wdata_i : '1);
  end else if (SW_ACS == "rc") begin : gen_rc
    // this swtype is not recommended but exists for compatibility.
    // WARN: sw_wen_i signal is actually rd signal not write enable.
    assign s_wen   = sw_wen_i | hw_wen_i;
    assign s_wdata = (hw_wen_i ? hw_wdata_i : data_o) & (sw_wen_i ? '0 : '1);
  end else begin : gen_hw
    assign s_wen   = hw_wen_i;
    assign s_wdata = hw_wdata_i;
  end


  dffr #(1) u_data_en_dffr (
      clk_i,
      rst_n_i,
      sw_wen_i,
      data_en_o
  );

  dfferc #(DATA_WIDTH, RST_VAL) u_data_dfferc (
      clk_i,
      rst_n_i,
      s_wen,
      s_wdata,
      data_o
  );

endmodule
