// Copyright (c) 2023-2026 Yuchi Miao <miaoyuchi@ict.ac.cn>
// SPDX-License-Identifier: MulanPSL-2.0

module gray_code_tb;
  logic [2:0] binary_value;
  logic [2:0] gray_value;
  logic [2:0] restored_value;

  bin2gray #(
      .DATA_WIDTH(3)
  ) u_bin2gray (
      .bin_i (binary_value),
      .gray_o(gray_value)
  );
  gray2bin #(
      .DATA_WIDTH(3)
  ) u_gray2bin (
      .gray_i(gray_value),
      .bin_o (restored_value)
  );

  initial begin
    for (int unsigned test_value = 0; test_value < 8; test_value++) begin
      binary_value = 3'(test_value);
      #1;
      if (restored_value !== binary_value) begin
        $fatal(1, "gray conversion failed for %0d", test_value);
      end
    end
    $display("[PASS] gray_code_tb");
    $finish;
  end
endmodule
