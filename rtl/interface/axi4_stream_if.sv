// Copyright (c) 2026 Yuchi Miao <miaoyuchi@ict.ac.cn>
// SPDX-License-Identifier: MulanPSL-2.0

interface axi4_stream_if #(
    parameter int DATA_WIDTH = 32,
    parameter int ID_WIDTH   = 1,
    parameter int DEST_WIDTH = 1,
    parameter int USER_WIDTH = 1
) (
    input logic aclk,
    input logic aresetn
);
  localparam int KEEP_WIDTH = DATA_WIDTH / 8;

  logic [DATA_WIDTH-1:0] tdata;
  logic [KEEP_WIDTH-1:0] tkeep;
  logic [KEEP_WIDTH-1:0] tstrb;
  logic                  tlast;
  logic [  ID_WIDTH-1:0] tid;
  logic [DEST_WIDTH-1:0] tdest;
  logic [USER_WIDTH-1:0] tuser;
  logic                  tvalid;
  logic                  tready;

  modport source(
      input aclk,
      input aresetn,
      output tdata,
      output tkeep,
      output tstrb,
      output tlast,
      output tid,
      output tdest,
      output tuser,
      output tvalid,
      input tready
  );

  modport sink(
      input aclk,
      input aresetn,
      input tdata,
      input tkeep,
      input tstrb,
      input tlast,
      input tid,
      input tdest,
      input tuser,
      input tvalid,
      output tready
  );

  modport monitor(
      input aclk,
      input aresetn,
      input tdata,
      input tkeep,
      input tstrb,
      input tlast,
      input tid,
      input tdest,
      input tuser,
      input tvalid,
      input tready
  );

  initial begin
    if (DATA_WIDTH < 8 || (DATA_WIDTH % 8) != 0 || ID_WIDTH < 1 || DEST_WIDTH < 1 ||
        USER_WIDTH < 1) begin
      $fatal(1, "axi4_stream_if: invalid data, ID, destination, or user width");
    end
  end
endinterface
