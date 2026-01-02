// Copyright (c) 2023-2026 Yuchi Miao <miaoyuchi@ict.ac.cn>
// common is licensed under Mulan PSL v2.
// You can use this software according to the terms and conditions of the Mulan PSL v2.
// You may obtain a copy of Mulan PSL v2 at:
//             http://license.coscl.org.cn/MulanPSL2
// THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
// EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
// MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
// See the Mulan PSL v2 for more details.

module gray2bin #(
    parameter int DATA_WIDTH = 1
) (
    input  logic [DATA_WIDTH-1:0] gray_i,
    output logic [DATA_WIDTH-1:0] bin_o
);

  for (genvar i = 0; i < DATA_WIDTH; i++) begin : GRAY2BIN_BLOCK
    assign bin_o[i] = ^gray_i[DATA_WIDTH-1:i];
  end
endmodule
