// Copyright 2018-2022 ETH Zurich, University of Bologna, EPFL, and OpenHW Group.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License. You may obtain a copy at
// http://solderpad.org/licenses/SHL-0.51.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
//
// Derived design work: Copyright (c) 2026 Yuchi Miao <miaoyuchi@ict.ac.cn>
// Design independently implemented for common; see NOTICE for attribution.

// Prevents a signal used only for observability from being optimized away.
(* keep_hierarchy = "yes" *)
module signal_tap #(
    parameter int DATA_WIDTH = 1
) (
    input  logic [DATA_WIDTH-1:0] signal_i,
    output logic [DATA_WIDTH-1:0] signal_o
);
  assign signal_o = signal_i;
endmodule

// Explicitly consumes a signal where an implementation needs a named sink.
// The optional Vivado assignment keeps the port from becoming a black box.
module signal_sink (
    input logic signal_i
);
`ifdef TARGET_VIVADO
  logic s_keep;
  assign s_keep = signal_i;
`endif
endmodule
