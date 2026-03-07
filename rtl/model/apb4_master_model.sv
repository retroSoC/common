// Copyright (c) 2023-2026 Yuchi Miao <miaoyuchi@ict.ac.cn>
// common is licensed under Mulan PSL v2.
// You can use this software according to the terms and conditions of the Mulan PSL v2.
// You may obtain a copy of Mulan PSL v2 at:
//             http://license.coscl.org.cn/MulanPSL2
// THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
// EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
// MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
// See the Mulan PSL v2 for more details.

module apb4_master_model (
    apb4_if.master apb4
);

  bit [31:0] rd_data;
  assign apb4.pprot = '0;
  assign apb4.pstrb = apb4.pwrite ? '1 : '0;  // refer to APB4 LRM

  initial begin
    apb4.paddr   = 'x;
    apb4.psel    = '0;
    apb4.penable = '0;
    apb4.pwrite  = '0;
    apb4.pwdata  = 'x;
    Helper::print("apb4 master device init done");
  end

  task automatic write(input bit [31:0] addr, input bit [31:0] data);
    @(posedge apb4.pclk);
    apb4.paddr  = addr;
    apb4.psel   = 1'b1;
    apb4.pwrite = 1'b1;
    apb4.pwdata = data;

    @(posedge apb4.pclk);
    apb4.penable = 1'b1;
    @(posedge apb4.pclk && apb4.pready);
    apb4.paddr   = 'x;
    apb4.psel    = '0;
    apb4.penable = '0;
    apb4.pwrite  = '0;
    apb4.pwdata  = 'x;
  endtask

  task automatic read(input bit [31:0] addr, output bit [31:0] data);
    @(posedge apb4.pclk);
    apb4.paddr  = addr;
    apb4.psel   = 1'b1;
    apb4.pwrite = 1'b0;
    apb4.pwdata = 'x;

    @(posedge apb4.pclk);
    apb4.penable = 1'b1;
    @(posedge apb4.pclk && apb4.pready);
    apb4.paddr   = 'x;
    apb4.psel    = '0;
    apb4.penable = '0;
    apb4.pwrite  = '0;
    apb4.pwdata  = 'x;
    data         = apb4.prdata;
  endtask

  task automatic cmp_data(input bit [31:0] addr, input bit [31:0] ref_data);
    read(addr, rd_data);
    if (ref_data != rd_data) begin
      $display("%t [ERRO]: compare error-> receive: %h, expected: %h", $time, rd_data, ref_data);
    end
  endtask
endmodule
