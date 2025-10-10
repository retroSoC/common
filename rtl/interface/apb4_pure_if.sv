// Copyright (c) 2023-2025 Yuchi Miao <miaoyuchi@ict.ac.cn>
// common is licensed under Mulan PSL v2.
// You can use this software according to the terms and conditions of the Mulan PSL v2.
// You may obtain a copy of Mulan PSL v2 at:
//             http://license.coscl.org.cn/MulanPSL2
// THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
// EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
// MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
// See the Mulan PSL v2 for more details.

interface apb4_pure_if #(
    parameter int APB_ADDR_WIDTH = 32,
    parameter int APB_DATA_WIDTH = 32
) ();

  logic [  APB_ADDR_WIDTH-1:0] paddr;
  logic [                 2:0] pprot;
  logic                        psel;
  logic                        penable;
  logic                        pwrite;
  logic [  APB_DATA_WIDTH-1:0] pwdata;
  logic [APB_DATA_WIDTH/8-1:0] pstrb;
  logic                        pready;
  logic [  APB_DATA_WIDTH-1:0] prdata;
  logic                        pslverr;

  modport slave(
      input paddr,
      input pprot,
      input psel,
      input penable,
      input pwrite,
      input pwdata,
      input pstrb,
      output pready,
      output prdata,
      output pslverr
  );

  modport master(
      output paddr,
      output pprot,
      output psel,
      output penable,
      output pwrite,
      output pwdata,
      output pstrb,
      input pready,
      input prdata,
      input pslverr
  );

endinterface
