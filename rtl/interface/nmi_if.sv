// Copyright (c) 2023-2025 Yuchi Miao <miaoyuchi@ict.ac.cn>
// common is licensed under Mulan PSL v2.
// You can use this software according to the terms and conditions of the Mulan PSL v2.
// You may obtain a copy of Mulan PSL v2 at:
//             http://license.coscl.org.cn/MulanPSL2
// THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
// EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
// MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
// See the Mulan PSL v2 for more details.

interface nmi_if (
    input logic clk,
    input logic rstn
);

  logic        valid;
  logic [31:0] addr;
  logic [31:0] wdata;
  logic [ 3:0] wstrb;
  logic [31:0] rdata;
  logic        ready;

  modport slave(
      input clk,
      input rstn,
      input valid,
      input addr,
      input wdata,
      input wstrb,
      output rdata,
      output ready
  );

  modport master(
      input clk,
      input rstn,
      output valid,
      output addr,
      output wdata,
      output wstrb,
      input rdata,
      input ready
  );

endinterface
