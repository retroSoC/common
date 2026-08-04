// Copyright 2020 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License. You may obtain a copy at
// http://solderpad.org/licenses/SHL-0.51.
// SPDX-License-Identifier: SHL-0.51
//
// Derived design work: Copyright (c) 2026 Yuchi Miao <miaoyuchi@ict.ac.cn>
// Design independently implemented for common; see NOTICE for attribution.

interface ready_valid_if #(
    parameter int DATA_WIDTH = 32
) (
    input logic clk_i
);
  logic [DATA_WIDTH-1:0] data;
  logic                  valid;
  logic                  ready;

  modport source(output data, valid, input ready);
  modport sink(input data, valid, output ready);
  modport monitor(input data, valid, ready);

`ifndef SV_ASSRT_DISABLE
  property stable_while_stalled;
    @(posedge clk_i) valid && !ready |=> valid && $stable(
        data
    );
  endproperty
  assert property (stable_while_stalled)
  else $error("ready_valid_if: source changed data while stalled");
`endif

  initial begin
    if (DATA_WIDTH < 1) $fatal(1, "ready_valid_if: DATA_WIDTH must be positive");
  end
endinterface
