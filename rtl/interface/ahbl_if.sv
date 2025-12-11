// Copyright (c) 2023-2025 Yuchi Miao <miaoyuchi@ict.ac.cn>
// common is licensed under Mulan PSL v2.
// You can use this software according to the terms and conditions of the Mulan PSL v2.
// You may obtain a copy of Mulan PSL v2 at:
//             http://license.coscl.org.cn/MulanPSL2
// THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
// EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
// MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
// See the Mulan PSL v2 for more details.


interface ahbl_if (
    input logic hclk,
    input logic hresetn
);

  logic [31:0] haddr;
  logic        hwrite;
  logic [ 2:0] hsize;
  logic [ 2:0] hburst;
  logic [ 3:0] hprot;
  logic [ 1:0] htrans;
  logic        hmastrlock;
  logic [31:0] hwdata;
  logic        hready;
  logic        hresp;
  logic [31:0] hrdata;

  modport slave(
      input hclk,
      input hresetn,

      input haddr,
      input hwrite,
      input hsize,
      input hburst,
      input hprot,
      input htrans,
      input hmastrlock,
      input hwdata,
      output hready,
      output hresp,
      output hrdata
  );

  modport master(
      input hclk,
      input hresetn,

      output haddr,
      output hwrite,
      output hsize,
      output hburst,
      output hprot,
      output htrans,
      output hmastrlock,
      output hwdata,
      input hready,
      input hresp,
      input hrdata
  );

endinterface









