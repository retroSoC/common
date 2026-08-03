// Copyright (c) 2023-2026 Yuchi Miao <miaoyuchi@ict.ac.cn>
// common is licensed under Mulan PSL v2.
// See LICENSE for the complete license text.
//
// This primitive is for single-bit controls or independently encoded bits.
// It is not a coherent multi-bit data transfer mechanism; use cdc_fifo or
// async_reqack for data buses.
module cdc_sync #(
    parameter int STAGE      = 2,
    parameter int DATA_WIDTH = 1
) (
    input  logic                  clk_i,
    input  logic                  rst_n_i,
    input  logic [DATA_WIDTH-1:0] dat_i,
    output logic [DATA_WIDTH-1:0] dat_o
);

  (* ASYNC_REG = "TRUE" *) logic [DATA_WIDTH-1:0] r_sync[0:STAGE-1];

  initial begin
    if (STAGE < 2 || DATA_WIDTH < 1) begin
      $fatal(1, "cdc_sync: STAGE must be at least two and DATA_WIDTH positive");
    end
  end

  always_ff @(posedge clk_i or negedge rst_n_i) begin
    if (!rst_n_i) begin
      for (int stage_idx = 0; stage_idx < STAGE; stage_idx++) begin
        r_sync[stage_idx] <= '0;
      end
    end else begin
      r_sync[0] <= dat_i;
      for (int unsigned stage_idx = 1; stage_idx < STAGE; stage_idx++) begin
        r_sync[stage_idx] <= r_sync[stage_idx-1];
      end
    end
  end

  assign dat_o = r_sync[STAGE-1];
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

  (* ASYNC_REG = "TRUE" *) logic [DATA_WIDTH-1:0] r_sync[0:STAGE-1];

  initial begin
    if (STAGE < 2 || DATA_WIDTH < 1) begin
      $fatal(1, "cdc_sync_det: STAGE must be at least two and DATA_WIDTH positive");
    end
  end

  always_ff @(posedge clk_i or negedge rst_n_i) begin
    if (!rst_n_i) begin
      for (int stage_idx = 0; stage_idx < STAGE; stage_idx++) begin
        r_sync[stage_idx] <= '0;
      end
    end else begin
      r_sync[0] <= dat_i;
      for (int unsigned stage_idx = 1; stage_idx < STAGE; stage_idx++) begin
        r_sync[stage_idx] <= r_sync[stage_idx-1];
      end
    end
  end

  assign dat_pre_o = r_sync[STAGE-2];
  assign dat_o     = r_sync[STAGE-1];
endmodule
