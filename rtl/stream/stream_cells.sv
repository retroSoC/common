// Copyright 2018-2024 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51. You may obtain a copy at
// http://solderpad.org/licenses/SHL-0.51.
//
// Derived design work: Copyright (c) 2026 Yuchi Miao <miaoyuchi@ict.ac.cn>
// SPDX-License-Identifier: SHL-0.51
// Design independently implemented for common; see NOTICE for attribution.

module bypass_buffer #(
    parameter int DATA_WIDTH = 32
) (
    input  logic                  flush_i,
    input  logic                  in_valid_i,
    output logic                  in_ready_o,
    input  logic [DATA_WIDTH-1:0] in_data_i,
    output logic                  out_valid_o,
    input  logic                  out_ready_i,
    output logic [DATA_WIDTH-1:0] out_data_o
);
  initial begin
    if (DATA_WIDTH < 1) $fatal(1, "bypass_buffer: DATA_WIDTH must be positive");
  end

  assign in_ready_o  = out_ready_i && !flush_i;
  assign out_valid_o = in_valid_i && !flush_i;
  assign out_data_o  = in_data_i;
endmodule

// Reuses the two-entry registered common primitive for elastic timing relief.
module stream_buffer #(
    parameter int DATA_WIDTH  = 32,
    parameter bit TRANSPARENT = 1'b0
) (
    input  logic                  clk_i,
    input  logic                  rst_n_i,
    input  logic                  flush_i,
    input  logic                  in_valid_i,
    output logic                  in_ready_o,
    input  logic [DATA_WIDTH-1:0] in_data_i,
    output logic                  out_valid_o,
    input  logic                  out_ready_i,
    output logic [DATA_WIDTH-1:0] out_data_o
);
  initial begin
    if (DATA_WIDTH < 1) $fatal(1, "stream_buffer: DATA_WIDTH must be positive");
  end

  spill_register #(
      .DATA_WIDTH(DATA_WIDTH),
      .BYPASS    (TRANSPARENT)
  ) u_spill_register (
      .clk_i  (clk_i),
      .rst_n_i(rst_n_i),
      .flush_i(flush_i),
      .valid_i(in_valid_i),
      .ready_o(in_ready_o),
      .data_i (in_data_i),
      .valid_o(out_valid_o),
      .ready_i(out_ready_i),
      .data_o (out_data_o)
  );
endmodule

module stream_selector #(
    parameter int DATA_WIDTH   = 32,
    parameter int PORTS        = 4,
    parameter int SELECT_WIDTH = (PORTS > 1) ? $clog2(PORTS) : 1
) (
    input  logic [SELECT_WIDTH-1:0]                 select_i,
    input  logic [       PORTS-1:0]                 in_valid_i,
    output logic [       PORTS-1:0]                 in_ready_o,
    input  logic [       PORTS-1:0][DATA_WIDTH-1:0] in_data_i,
    output logic                                    out_valid_o,
    input  logic                                    out_ready_i,
    output logic [  DATA_WIDTH-1:0]                 out_data_o
);
  initial begin
    if (DATA_WIDTH < 1 || PORTS < 1 || SELECT_WIDTH < ((PORTS > 1) ? $clog2(PORTS) : 1)) begin
      $fatal(1, "stream_selector: invalid data, port, or select width");
    end
  end

  always_comb begin
    in_ready_o  = '0;
    out_valid_o = 1'b0;
    out_data_o  = '0;
    // The comparison is only non-trivial for a non-power-of-two port count.
    // verilator lint_off CMPCONST
    if (select_i <= SELECT_WIDTH'(PORTS - 1)) begin
      // verilator lint_on CMPCONST
      out_valid_o          = in_valid_i[select_i];
      out_data_o           = in_data_i[select_i];
      in_ready_o[select_i] = out_ready_i;
    end
  end
endmodule

module stream_router #(
    parameter int DATA_WIDTH   = 32,
    parameter int PORTS        = 4,
    parameter int SELECT_WIDTH = (PORTS > 1) ? $clog2(PORTS) : 1
) (
    input  logic [SELECT_WIDTH-1:0]                 select_i,
    input  logic                                    in_valid_i,
    output logic                                    in_ready_o,
    input  logic [  DATA_WIDTH-1:0]                 in_data_i,
    output logic [       PORTS-1:0]                 out_valid_o,
    input  logic [       PORTS-1:0]                 out_ready_i,
    output logic [       PORTS-1:0][DATA_WIDTH-1:0] out_data_o
);
  initial begin
    if (DATA_WIDTH < 1 || PORTS < 1 || SELECT_WIDTH < ((PORTS > 1) ? $clog2(PORTS) : 1)) begin
      $fatal(1, "stream_router: invalid data, port, or select width");
    end
  end

  always_comb begin
    in_ready_o  = 1'b0;
    out_valid_o = '0;
    out_data_o  = '0;
    // The comparison is only non-trivial for a non-power-of-two port count.
    // verilator lint_off CMPCONST
    if (select_i <= SELECT_WIDTH'(PORTS - 1)) begin
      // verilator lint_on CMPCONST
      in_ready_o            = out_ready_i[select_i];
      out_valid_o[select_i] = in_valid_i;
      out_data_o[select_i]  = in_data_i;
    end
  end
endmodule

module stream_replicator #(
    parameter int DATA_WIDTH = 32,
    parameter int PORTS      = 4
) (
    input  logic                                  clk_i,
    input  logic                                  rst_n_i,
    input  logic                                  flush_i,
    input  logic                                  in_valid_i,
    output logic                                  in_ready_o,
    input  logic [DATA_WIDTH-1:0]                 in_data_i,
    input  logic [     PORTS-1:0]                 enable_i,
    output logic [     PORTS-1:0]                 out_valid_o,
    input  logic [     PORTS-1:0]                 out_ready_i,
    output logic [     PORTS-1:0][DATA_WIDTH-1:0] out_data_o
);
  logic [DATA_WIDTH-1:0] r_payload;
  logic [     PORTS-1:0] r_pending;
  logic                  r_active;
  logic [     PORTS-1:0] s_pending_after_transfer;

  initial begin
    if (DATA_WIDTH < 1 || PORTS < 1) begin
      $fatal(1, "stream_replicator: DATA_WIDTH and PORTS must be positive");
    end
  end

  // The target mask and payload are sampled on the input handshake. Every
  // enabled target keeps valid asserted until its own transfer completes.
  assign in_ready_o               = !r_active && !flush_i;
  assign out_valid_o              = r_pending & {PORTS{r_active && !flush_i}};
  assign s_pending_after_transfer = r_pending & ~out_ready_i;
  for (genvar port_idx = 0; port_idx < PORTS; port_idx++) begin : GEN_REPLICA_DATA
    assign out_data_o[port_idx] = r_payload;
  end

  always_ff @(posedge clk_i or negedge rst_n_i) begin
    if (!rst_n_i) begin
      r_payload <= '0;
      r_pending <= '0;
      r_active  <= 1'b0;
    end else if (flush_i) begin
      r_pending <= '0;
      r_active  <= 1'b0;
    end else if (!r_active) begin
      if (in_valid_i) begin
        r_payload <= in_data_i;
        r_pending <= enable_i;
        r_active  <= |enable_i;
      end
    end else begin
      r_pending <= s_pending_after_transfer;
      if (s_pending_after_transfer == '0) begin
        r_active <= 1'b0;
      end
    end
  end
endmodule

module stream_collector #(
    parameter int DATA_WIDTH = 32,
    parameter int PORTS      = 4
) (
    input  logic [           PORTS-1:0]                 in_valid_i,
    output logic [           PORTS-1:0]                 in_ready_o,
    input  logic [           PORTS-1:0][DATA_WIDTH-1:0] in_data_i,
    input  logic [           PORTS-1:0]                 enable_i,
    output logic                                        out_valid_o,
    input  logic                                        out_ready_i,
    output logic [PORTS*DATA_WIDTH-1:0]                 out_data_o
);
  logic s_all_present;

  initial begin
    if (DATA_WIDTH < 1 || PORTS < 1) begin
      $fatal(1, "stream_collector: DATA_WIDTH and PORTS must be positive");
    end
  end

  assign s_all_present = |enable_i && &(in_valid_i | ~enable_i);
  assign out_valid_o   = s_all_present;
  assign in_ready_o    = {PORTS{out_ready_i && s_all_present}} & enable_i;
  assign out_data_o    = in_data_i;
endmodule

module stream_credit_limiter #(
    parameter int DATA_WIDTH   = 32,
    parameter int MAX_CREDITS  = 4,
    parameter int CREDIT_WIDTH = $clog2(MAX_CREDITS + 1)
) (
    input  logic                    clk_i,
    input  logic                    rst_n_i,
    input  logic                    flush_i,
    input  logic                    release_i,
    input  logic                    in_valid_i,
    output logic                    in_ready_o,
    input  logic [  DATA_WIDTH-1:0] in_data_i,
    output logic                    out_valid_o,
    input  logic                    out_ready_i,
    output logic [  DATA_WIDTH-1:0] out_data_o,
    output logic [CREDIT_WIDTH-1:0] credit_o
);
  logic [CREDIT_WIDTH-1:0] r_credit;
  logic                    s_accept;

  initial begin
    if (DATA_WIDTH < 1 || MAX_CREDITS < 1 || CREDIT_WIDTH < $clog2(MAX_CREDITS + 1)) begin
      $fatal(1, "stream_credit_limiter: invalid data, credit, or counter width");
    end
  end

  assign out_valid_o = in_valid_i && (r_credit != '0) && !flush_i;
  assign in_ready_o  = out_ready_i && (r_credit != '0) && !flush_i;
  assign out_data_o  = in_data_i;
  assign s_accept    = out_valid_o && out_ready_i;
  assign credit_o    = r_credit;

  always_ff @(posedge clk_i or negedge rst_n_i) begin
    if (!rst_n_i || flush_i) begin
      r_credit <= CREDIT_WIDTH'(MAX_CREDITS);
    end else begin
      case ({
        release_i && (r_credit < CREDIT_WIDTH'(MAX_CREDITS)), s_accept
      })
        2'b10:   r_credit <= r_credit + 1'b1;
        2'b01:   r_credit <= r_credit - 1'b1;
        default: r_credit <= r_credit;
      endcase
    end
  end
endmodule
