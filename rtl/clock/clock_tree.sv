// Copyright 2020 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License. You may obtain a copy at
// http://solderpad.org/licenses/SHL-0.51.
// SPDX-License-Identifier: SHL-0.51
//
// Derived design work: Copyright (c) 2026 Yuchi Miao <miaoyuchi@ict.ac.cn>
// Design independently implemented for common; see NOTICE for attribution.

// Reduces a set of already-safe gated clocks. Callers must ensure inputs do
// not overlap high; this is a clock construction primitive, not a mux.
module clock_or_tree #(
    parameter int CLOCKS = 2
) (
    input  logic [CLOCKS-1:0] clock_i,
    output logic              clock_o
);
  if (CLOCKS == 1) begin : GEN_LEAF
    assign clock_o = clock_i[0];
  end else begin : GEN_TREE
    localparam int LEFT_CLOCKS = CLOCKS / 2;
    localparam int RIGHT_CLOCKS = CLOCKS - LEFT_CLOCKS;
    logic s_left;
    logic s_right;
    clock_or_tree #(
        .CLOCKS(LEFT_CLOCKS)
    ) u_left (
        .clock_i(clock_i[0+:LEFT_CLOCKS]),
        .clock_o(s_left)
    );
    clock_or_tree #(
        .CLOCKS(RIGHT_CLOCKS)
    ) u_right (
        .clock_i(clock_i[LEFT_CLOCKS+:RIGHT_CLOCKS]),
        .clock_o(s_right)
    );
    assign clock_o = s_left | s_right;
  end
  initial begin
    if (CLOCKS < 1) $fatal(1, "clock_or_tree: CLOCKS must be positive");
  end
endmodule
