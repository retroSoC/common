// Copyright (c) 2026 Yuchi Miao <miaoyuchi@ict.ac.cn>
// SPDX-License-Identifier: MulanPSL-2.0

module secded_formal;
  (* anyseq *)logic [ 7:0] data_i;
  (* anyseq *)logic [12:0] fault_mask_i;
  logic [12:0] clean_code;
  logic [ 7:0] decoded_data;
  logic [ 3:0] syndrome;
  logic        corrected;
  logic        parity_error;
  logic        uncorrectable;

  secded_encode #(
      .DATA_WIDTH(8)
  ) u_encoder (
      .data_i(data_i),
      .code_o(clean_code)
  );
  secded_decode #(
      .DATA_WIDTH(8)
  ) u_decoder (
      .code_i                (clean_code ^ fault_mask_i),
      .data_o                (decoded_data),
      .syndrome_o            (syndrome),
      .corrected_o           (corrected),
      .overall_parity_error_o(parity_error),
      .uncorrectable_o       (uncorrectable)
  );

  always_comb begin
    assume ((fault_mask_i & (fault_mask_i - 1'b1)) == '0);
    assert (decoded_data == data_i);
    assert (!uncorrectable);
    if (fault_mask_i == '0) begin
      assert (!corrected && !parity_error);
    end else if (fault_mask_i[12]) begin
      assert (!corrected && parity_error);
    end else begin
      assert (corrected && !parity_error);
    end
  end
endmodule
