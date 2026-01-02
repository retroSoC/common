// Copyright (c) 2023-2026 Yuchi Miao <miaoyuchi@ict.ac.cn>
// common is licensed under Mulan PSL v2.
// You can use this software according to the terms and conditions of the Mulan PSL v2.
// You may obtain a copy of Mulan PSL v2 at:
//             http://license.coscl.org.cn/MulanPSL2
// THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
// EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
// MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
// See the Mulan PSL v2 for more details.

module cdc_sync #(
    parameter int STAGE      = 2,
    parameter int DATA_WIDTH = 1
) (
    input  logic                  clk_i,
    input  logic                  rst_n_i,
    input  logic [DATA_WIDTH-1:0] dat_i,
    output logic [DATA_WIDTH-1:0] dat_o
);

  logic [DATA_WIDTH-1:0] s_sync_dat[0:STAGE-1];
  for (genvar i = 0; i < STAGE; i++) begin : CDC_SYNC_BLOCK
    if (i == 0) begin : CDC_SYNC_0_BLOCK
      dffr #(DATA_WIDTH) u_sync_dffr (
          clk_i,
          rst_n_i,
          dat_i,
          s_sync_dat[0]
      );
    end else begin : CDC_SYNC_N0_BLOCK
      dffr #(DATA_WIDTH) u_sync_dffr (
          clk_i,
          rst_n_i,
          s_sync_dat[i-1],
          s_sync_dat[i]
      );
    end
  end

  assign dat_o = s_sync_dat[STAGE-1];
endmodule

module cdc_sync_det #(
    parameter int STAGE      = 2,
    parameter int DATA_WIDTH = 1
) (
    input  logic                  clk_i,
    input  logic                  rst_n_i,
    input  logic [DATA_WIDTH-1:0] dat_i,
    output logic [DATA_WIDTH-1:0] dat_pre_o,
    output logic [DATA_WIDTH-1:0] dat_o
);

  logic [DATA_WIDTH-1:0] s_sync_dat[0:STAGE-1];
  for (genvar i = 0; i < STAGE; i++) begin : CDC_SYNC_DET_BLOCK
    if (i == 0) begin
      dffr #(DATA_WIDTH) u_sync_dffr (
          clk_i,
          rst_n_i,
          dat_i,
          s_sync_dat[0]
      );
    end else begin
      dffr #(DATA_WIDTH) u_sync_dffr (
          clk_i,
          rst_n_i,
          s_sync_dat[i-1],
          s_sync_dat[i]
      );
    end
  end

  assign dat_pre_o = s_sync_dat[STAGE-2];
  assign dat_o     = s_sync_dat[STAGE-1];
endmodule
