// Copyright (c) 2023-2026 Yuchi Miao <miaoyuchi@ict.ac.cn>
// common is licensed under Mulan PSL v2.
// You can use this software according to the terms and conditions of the Mulan PSL v2.
// You may obtain a copy of Mulan PSL v2 at:
//             http://license.coscl.org.cn/MulanPSL2
// THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
// EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
// MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
// See the Mulan PSL v2 for more details.

`include "config.svh"

class APB4AXI4Master extends TestBase;
  string     name;
  APB4Master apb4_mstr;
  AXI4Master axi4_mstr;

  extern function new(string name = "apb4_axi4_master", virtual apb4_if.master apb4,
                      virtual axi4_if.master axi4);
  extern task automatic init();
  extern task automatic apb4_write(input bit [31:0] addr, input bit [31:0] data);
  extern task automatic apb4_read(input bit [31:0] addr);
  extern task automatic apb4_wr_rd_check(input bit [31:0] addr, string name, input bit [31:0] data,
                                         input Helper::cmp_t cmp_type,
                                         input Helper::log_lev_t log_level = Helper::NORM);
  extern task automatic apb4_wr_check(input bit [31:0] addr, string name, input bit [31:0] data,
                                      input bit [31:0] ref_data, input Helper::cmp_t cmp_type,
                                      input Helper::log_lev_t log_level = Helper::NORM);
  extern task automatic apb4_rd_check(input bit [31:0] addr, string name, input bit [31:0] ref_data,
                                      input Helper::cmp_t cmp_type,
                                      input Helper::log_lev_t log_level = Helper::NORM);

  extern task automatic axi4_write(
      input bit [`AXI4_ID_WIDTH-1:0] id, input bit [`AXI4_ADDR_WIDTH-1:0] addr, input bit [7:0] len,
      input bit [2:0] size, input bit [1:0] burst, input bit [`AXI4_DATA_WIDTH-1:0] data[$]);
  extern task automatic axi4_read(input bit [`AXI4_ID_WIDTH-1:0] id,
                                  input bit [`AXI4_ADDR_WIDTH-1:0] addr, input bit [7:0] len,
                                  input bit [2:0] size, input bit [1:0] burst);
  extern task automatic axi4_wr_check(
      input bit [`AXI4_ID_WIDTH-1:0] id, input bit [`AXI4_ADDR_WIDTH-1:0] addr, input bit [7:0] len,
      input bit [2:0] size, input bit [1:0] burst, input bit [`AXI4_DATA_WIDTH-1:0] data[$],
      input bit [`AXI4_DATA_WIDTH-1:0] ref_data[$], input Helper::cmp_t cmp_type,
      input Helper::log_lev_t log_level = Helper::NORM);
  extern task automatic axi4_rd_check(
      input bit [`AXI4_ID_WIDTH-1:0] id, input bit [`AXI4_ADDR_WIDTH-1:0] addr, input bit [7:0] len,
      input bit [2:0] size, input bit [1:0] burst, input bit [`AXI4_DATA_WIDTH-1:0] ref_data[$],
      input Helper::cmp_t cmp_type, input Helper::log_lev_t log_level = Helper::NORM);
endclass


function APB4AXI4Master::new(string name, virtual apb4_if.master apb4, virtual axi4_if.master axi4);
  super.new();
  this.name      = name;
  this.apb4_mstr = new("apb4_master", apb4);
  this.axi4_mstr = new("axi4_master", axi4);
endfunction

task automatic APB4AXI4Master::init();
  this.apb4_mstr.init();
  this.axi4_mstr.init();
endtask

task automatic APB4AXI4Master::apb4_write(input bit [31:0] addr, input bit [31:0] data);
  this.apb4_mstr.write(addr, data);
endtask

task automatic APB4AXI4Master::apb4_read(input bit [31:0] addr);
  this.apb4_mstr.read(addr);
endtask

task automatic APB4AXI4Master::apb4_wr_rd_check(input bit [31:0] addr, string name,
                                                input bit [31:0] data, input Helper::cmp_t cmp_type,
                                                input Helper::log_lev_t log_level = Helper::NORM);
  this.apb4_mstr.wr_rd_check(addr, name, data, cmp_type, log_level);
endtask

task automatic APB4AXI4Master::apb4_wr_check(
    input bit [31:0] addr, string name, input bit [31:0] data, input bit [31:0] ref_data,
    input Helper::cmp_t cmp_type, input Helper::log_lev_t log_level = Helper::NORM);
  this.apb4_mstr.wr_check(addr, name, data, ref_data, cmp_type, log_level);
endtask

task automatic APB4AXI4Master::apb4_rd_check(
    input bit [31:0] addr, string name, input bit [31:0] ref_data, input Helper::cmp_t cmp_type,
    input Helper::log_lev_t log_level = Helper::NORM);
  this.apb4_mstr.rd_check(addr, name, ref_data, cmp_type, log_level);
endtask


task automatic APB4AXI4Master::axi4_write(
    input bit [`AXI4_ID_WIDTH-1:0] id, input bit [`AXI4_ADDR_WIDTH-1:0] addr, input bit [7:0] len,
    input bit [2:0] size, input bit [1:0] burst, input bit [`AXI4_DATA_WIDTH-1:0] data[$]);
  this.axi4_mstr.write(id, addr, len, size, burst, data);
endtask

task automatic APB4AXI4Master::axi4_read(input bit [`AXI4_ID_WIDTH-1:0] id,
                                         input bit [`AXI4_ADDR_WIDTH-1:0] addr, input bit [7:0] len,
                                         input bit [2:0] size, input bit [1:0] burst);
  this.axi4_mstr.read(id, addr, len, size, burst);
endtask

task automatic APB4AXI4Master::axi4_wr_check(
    input bit [`AXI4_ID_WIDTH-1:0] id, input bit [`AXI4_ADDR_WIDTH-1:0] addr, input bit [7:0] len,
    input bit [2:0] size, input bit [1:0] burst, input bit [`AXI4_DATA_WIDTH-1:0] data[$],
    input bit [`AXI4_DATA_WIDTH-1:0] ref_data[$], input Helper::cmp_t cmp_type,
    input Helper::log_lev_t log_level = Helper::NORM);
  this.axi4_mstr.wr_check(id, addr, len, size, burst, data, ref_data, cmp_type, log_level);
endtask

task automatic APB4AXI4Master::axi4_rd_check(
    input bit [`AXI4_ID_WIDTH-1:0] id, input bit [`AXI4_ADDR_WIDTH-1:0] addr, input bit [7:0] len,
    input bit [2:0] size, input bit [1:0] burst, input bit [`AXI4_DATA_WIDTH-1:0] ref_data[$],
    input Helper::cmp_t cmp_type, input Helper::log_lev_t log_level = Helper::NORM);
  this.axi4_mstr.rd_check(id, addr, len, size, burst, ref_data, cmp_type, log_level);
endtask
