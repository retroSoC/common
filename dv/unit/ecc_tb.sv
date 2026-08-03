// Copyright (c) 2026 Yuchi Miao <miaoyuchi@ict.ac.cn>
// SPDX-License-Identifier: MulanPSL-2.0

module ecc_tb;
  logic [ 7:0] data8;
  logic [12:0] clean8;
  logic [12:0] fault8;
  logic [ 7:0] decoded8;
  logic [ 3:0] syndrome8;
  logic        corrected8;
  logic        parity8;
  logic        uncorrectable8;
  logic [31:0] data32;
  logic [38:0] clean32;
  logic [38:0] fault32;
  logic [31:0] decoded32;
  logic [ 5:0] syndrome32;
  logic        corrected32;
  logic        parity32;
  logic        uncorrectable32;

  secded_encode #(
      .DATA_WIDTH(8)
  ) u_encode8 (
      .data_i(data8),
      .code_o(clean8)
  );
  secded_decode #(
      .DATA_WIDTH(8)
  ) u_decode8 (
      .code_i                (fault8),
      .data_o                (decoded8),
      .syndrome_o            (syndrome8),
      .corrected_o           (corrected8),
      .overall_parity_error_o(parity8),
      .uncorrectable_o       (uncorrectable8)
  );
  secded_encode #(
      .DATA_WIDTH(32)
  ) u_encode32 (
      .data_i(data32),
      .code_o(clean32)
  );
  secded_decode #(
      .DATA_WIDTH(32)
  ) u_decode32 (
      .code_i                (fault32),
      .data_o                (decoded32),
      .syndrome_o            (syndrome32),
      .corrected_o           (corrected32),
      .overall_parity_error_o(parity32),
      .uncorrectable_o       (uncorrectable32)
  );

  initial begin
    data8   = 8'ha5;
    data32  = 32'hcafe_1ace;
    fault8  = '0;
    fault32 = '0;
    #1;
    fault8  = clean8;
    fault32 = clean32;
    #1;
    if (decoded8 != data8 || corrected8 || parity8 || uncorrectable8) begin
      $fatal(1, "SECDED eight-bit clean decode failed");
    end
    if (decoded32 != data32 || corrected32 || parity32 || uncorrectable32) begin
      $fatal(1, "SECDED thirty-two-bit clean decode failed");
    end

    for (int bit_index = 0; bit_index < 13; bit_index++) begin
      fault8 = clean8 ^ (13'b1 << bit_index);
      #1;
      if (decoded8 != data8 || uncorrectable8) $fatal(1, "SECDED failed to repair one-bit fault");
      if (bit_index == 12) begin
        if (corrected8 || !parity8) $fatal(1, "SECDED did not classify overall parity fault");
      end else if (!corrected8 || parity8) begin
        $fatal(1, "SECDED did not classify codeword single fault");
      end
    end

    for (int first_bit = 0; first_bit < 13; first_bit++) begin
      for (int second_bit = first_bit + 1; second_bit < 13; second_bit++) begin
        fault8 = clean8 ^ (13'b1 << first_bit) ^ (13'b1 << second_bit);
        #1;
        if (!uncorrectable8 || corrected8 || parity8) begin
          $fatal(1, "SECDED did not classify double-bit fault");
        end
      end
    end

    fault32 = clean32 ^ (39'b1 << 7);
    #1;
    if (decoded32 != data32 || !corrected32 || parity32 || uncorrectable32) begin
      $fatal(1, "SECDED thirty-two-bit data correction failed");
    end
    fault32 = clean32 ^ (39'b1 << 38);
    #1;
    if (decoded32 != data32 || corrected32 || !parity32 || uncorrectable32) begin
      $fatal(1, "SECDED thirty-two-bit parity classification failed");
    end
    $display("[PASS] ecc_tb");
    $finish;
  end
endmodule
