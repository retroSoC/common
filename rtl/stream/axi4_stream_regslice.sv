// Copyright (c) 2026 Yuchi Miao <miaoyuchi@ict.ac.cn>
// SPDX-License-Identifier: MulanPSL-2.0

module axi4_stream_regslice #(
    parameter int DATA_WIDTH = 32,
    parameter int ID_WIDTH   = 1,
    parameter int DEST_WIDTH = 1,
    parameter int USER_WIDTH = 1,
    parameter bit BYPASS     = 1'b0
) (
    input logic                 clk_i,
    input logic                 rst_n_i,
    input logic                 flush_i,
          axi4_stream_if.sink   sink,
          axi4_stream_if.source source
);
  localparam int KEEP_WIDTH = DATA_WIDTH / 8;
  localparam int PAYLOAD_WIDTH = DATA_WIDTH + (2 * KEEP_WIDTH) + 1 + ID_WIDTH + DEST_WIDTH +
      USER_WIDTH;

  logic [PAYLOAD_WIDTH-1:0] s_payload_in, s_payload_out;

  assign s_payload_in = {
    sink.tdata, sink.tkeep, sink.tstrb, sink.tlast, sink.tid, sink.tdest, sink.tuser
  };
  assign {
    source.tdata, source.tkeep, source.tstrb, source.tlast, source.tid, source.tdest,
    source.tuser
  } = s_payload_out;

  spill_register #(
      .DATA_WIDTH(PAYLOAD_WIDTH),
      .BYPASS    (BYPASS)
  ) u_spill_register (
      .clk_i  (clk_i),
      .rst_n_i(rst_n_i),
      .flush_i(flush_i),
      .valid_i(sink.tvalid),
      .ready_o(sink.tready),
      .data_i (s_payload_in),
      .valid_o(source.tvalid),
      .ready_i(source.tready),
      .data_o (s_payload_out)
  );

  initial begin
    if (DATA_WIDTH < 8 || (DATA_WIDTH % 8) != 0 || ID_WIDTH < 1 || DEST_WIDTH < 1 ||
        USER_WIDTH < 1) begin
      $fatal(1, "axi4_stream_regslice: invalid interface geometry");
    end
  end
endmodule
