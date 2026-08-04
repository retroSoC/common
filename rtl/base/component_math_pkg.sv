// Copyright 2025 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License. You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51.
// SPDX-License-Identifier: SHL-0.51
//
// Derived design work: Copyright (c) 2026 Yuchi Miao <miaoyuchi@ict.ac.cn>
// Design independently implemented for common; see NOTICE for attribution.

package component_math_pkg;
  function automatic int unsigned ceil_divide(input int unsigned numerator,
                                              input int unsigned denominator);
    if (denominator == 0) begin
      $fatal(1, "ceil_divide: denominator must be non-zero");
    end
    return (numerator / denominator) + ((numerator % denominator) != 0);
  endfunction

  function automatic int unsigned index_bits(input int unsigned item_count);
    return (item_count > 1) ? $clog2(item_count) : 1;
  endfunction

  function automatic int unsigned counter_bits(input int unsigned maximum);
    return index_bits(maximum + 1);
  endfunction

  function automatic bit power_of_two(input int unsigned value);
    return (value != 0) && ((value & (value - 1)) == 0);
  endfunction
endpackage
