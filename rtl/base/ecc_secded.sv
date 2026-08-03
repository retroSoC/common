// Copyright 2020 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51. You may obtain a copy at
// http://solderpad.org/licenses/SHL-0.51.
//
// Original SECDED implementation concept: Florian Zaruba.
// Derived design work: Copyright (c) 2026 Yuchi Miao <miaoyuchi@ict.ac.cn>
// SPDX-License-Identifier: SHL-0.51
// Design independently implemented for common; see NOTICE for attribution.

package secded_layout_pkg;
  function automatic integer check_bits_for(input integer data_width);
    integer check_bits;
    begin
      check_bits = 0;
      while ((1 << check_bits) < (data_width + check_bits + 1)) begin
        check_bits++;
      end
      check_bits_for = check_bits;
    end
  endfunction

  function automatic logic is_check_position(input int position);
    begin
      is_check_position = (position > 0) && ((position & (position - 1)) == 0);
    end
  endfunction
endpackage

// Combinational extended-Hamming SECDED encoder. The most-significant encoded
// bit is the overall parity bit; lower bits are numbered one-based internally.
module secded_encode #(
    parameter int DATA_WIDTH = 64
) (
    input  logic [                                            DATA_WIDTH-1:0] data_i,
    output logic [DATA_WIDTH+secded_layout_pkg::check_bits_for(DATA_WIDTH):0] code_o
);
  localparam int CHECK_BITS = secded_layout_pkg::check_bits_for(DATA_WIDTH);
  localparam int HAMMING_WIDTH = DATA_WIDTH + CHECK_BITS;

  logic [HAMMING_WIDTH-1:0] s_hamming_word;

  initial begin
    if (DATA_WIDTH < 1) $fatal(1, "secded_encode: DATA_WIDTH must be positive");
  end

  always_comb begin
    int unsigned data_index;
    logic        parity_value;

    s_hamming_word = '0;
    data_index     = 0;
    for (int unsigned position = 1; position <= HAMMING_WIDTH; position++) begin
      if (!secded_layout_pkg::is_check_position(position)) begin
        s_hamming_word[position-1] = data_i[data_index];
        data_index++;
      end
    end
    for (int unsigned check_index = 0; check_index < CHECK_BITS; check_index++) begin
      parity_value = 1'b0;
      for (int unsigned position = 1; position <= HAMMING_WIDTH; position++) begin
        if ((position & (1 << check_index)) != 0) begin
          parity_value = parity_value ^ s_hamming_word[position-1];
        end
      end
      s_hamming_word[(1<<check_index)-1] = parity_value;
    end
    code_o[HAMMING_WIDTH-1:0] = s_hamming_word;
    code_o[HAMMING_WIDTH]     = ^s_hamming_word;
  end
endmodule

// Combinational extended-Hamming SECDED decoder. Double-bit faults are
// reported but never corrected; this prevents a fabricated correction from
// changing the data presented to the caller.
module secded_decode #(
    parameter int DATA_WIDTH = 64
) (
    input logic [DATA_WIDTH+secded_layout_pkg::check_bits_for(DATA_WIDTH):0] code_i,
    output logic [DATA_WIDTH-1:0] data_o,
    output logic [secded_layout_pkg::check_bits_for(DATA_WIDTH)-1:0] syndrome_o,
    output logic corrected_o,
    output logic overall_parity_error_o,
    output logic uncorrectable_o
);
  localparam int CHECK_BITS = secded_layout_pkg::check_bits_for(DATA_WIDTH);
  localparam int HAMMING_WIDTH = DATA_WIDTH + CHECK_BITS;

  logic [   CHECK_BITS-1:0] s_syndrome;
  logic [HAMMING_WIDTH-1:0] s_corrected_word;
  logic                     s_total_parity_bad;
  logic                     s_syndrome_in_range;

  initial begin
    if (DATA_WIDTH < 1) $fatal(1, "secded_decode: DATA_WIDTH must be positive");
  end

  always_comb begin
    logic parity_value;

    s_syndrome = '0;
    for (int unsigned check_index = 0; check_index < CHECK_BITS; check_index++) begin
      parity_value = 1'b0;
      for (int unsigned position = 1; position <= HAMMING_WIDTH; position++) begin
        if ((position & (1 << check_index)) != 0) begin
          parity_value = parity_value ^ code_i[position-1];
        end
      end
      s_syndrome[check_index] = parity_value;
    end
  end

  assign s_total_parity_bad = ^code_i;
  assign s_syndrome_in_range = (int'($unsigned(s_syndrome)) <= HAMMING_WIDTH);
  assign corrected_o = s_total_parity_bad && (s_syndrome != '0) && s_syndrome_in_range;
  assign overall_parity_error_o = s_total_parity_bad && (s_syndrome == '0);
  assign uncorrectable_o          = (!s_total_parity_bad && (s_syndrome != '0)) ||
      (s_total_parity_bad && (s_syndrome != '0) && !s_syndrome_in_range);
  assign syndrome_o = s_syndrome;

  always_comb begin
    int unsigned data_index;

    s_corrected_word = code_i[HAMMING_WIDTH-1:0];
    if (corrected_o) begin
      s_corrected_word[$unsigned(s_syndrome)-1] = ~code_i[$unsigned(s_syndrome)-1];
    end
    data_o     = '0;
    data_index = 0;
    for (int unsigned position = 1; position <= HAMMING_WIDTH; position++) begin
      if (!secded_layout_pkg::is_check_position(position)) begin
        data_o[data_index] = s_corrected_word[position-1];
        data_index++;
      end
    end
  end
endmodule
