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

class AXI4Master extends TestBase;
  string                                        name;
  logic                  [`AXI4_DATA_WIDTH-1:0] rd_data[$];
  logic                  [`AXI4_DATA_WIDTH-1:0] wr_data[$];
  virtual axi4_if.master                        axi4;

  function new(string name = "axi4_master", virtual axi4_if.master axi4);
    super.new(name);
    this.name    = name;
    this.rd_data = {};
    this.wr_data = {};
    this.axi4    = axi4;
  endfunction
  extern function bit [`AXI4_WSTRB_WIDTH-1:0] calc_strb(input bit [`AXI4_ADDR_WIDTH-1:0] addr,
                                                        input bit [2:0] size);
  extern function bit [`AXI4_ADDR_WIDTH-1:0] calc_addr(input bit [`AXI4_ADDR_WIDTH-1:0] addr,
                                                       input bit [2:0] size, input bit [1:0] burst);
  extern function bit [`AXI4_ADDR_WIDTH-1:0] calc_burst_addr(
      input bit [`AXI4_ADDR_WIDTH-1:0] addr, input bit [`AXI4_ADDR_WIDTH-1:0] base_addr,
      input bit [7:0] len, input bit [2:0] size, input bit [1:0] burst);
  extern function bit burst_is_legal(input bit [`AXI4_ADDR_WIDTH-1:0] addr, input bit [7:0] len,
                                     input bit [2:0] size, input bit [1:0] burst);
  extern task init();
  extern task write(input bit [`AXI4_ID_WIDTH-1:0] id, input bit [`AXI4_ADDR_WIDTH-1:0] addr,
                    input bit [7:0] len, input bit [2:0] size, input bit [1:0] burst,
                    input bit [`AXI4_DATA_WIDTH-1:0] data[$]);

  extern task read(input bit [`AXI4_ID_WIDTH-1:0] id, input bit [`AXI4_ADDR_WIDTH-1:0] addr,
                   input bit [7:0] len, input bit [2:0] size, input bit [1:0] burst);
  extern task wr_check(input bit [`AXI4_ID_WIDTH-1:0] id, input bit [`AXI4_ADDR_WIDTH-1:0] addr,
                       input bit [7:0] len, input bit [2:0] size, input bit [1:0] burst,
                       input bit [`AXI4_DATA_WIDTH-1:0] data[$],
                       input bit [`AXI4_DATA_WIDTH-1:0] ref_data[$], input Helper::cmp_t cmp_type,
                       input Helper::log_lev_t log_level = Helper::NORM);

  extern task rd_check(input bit [`AXI4_ID_WIDTH-1:0] id, input bit [`AXI4_ADDR_WIDTH-1:0] addr,
                       input bit [7:0] len, input bit [2:0] size, input bit [1:0] burst,
                       input bit [`AXI4_DATA_WIDTH-1:0] ref_data[$], input Helper::cmp_t cmp_type,
                       input Helper::log_lev_t log_level = Helper::NORM);
endclass

task automatic AXI4Master::init();
  this.axi4.awid     = '0;
  this.axi4.awaddr   = 'x;
  this.axi4.awlen    = '0;
  this.axi4.awsize   = `AXI4_BURST_SIZE_1BYTE;
  this.axi4.awburst  = `AXI4_BURST_TYPE_FIXED;
  this.axi4.awlock   = `AXI4_LOCK_NORM;
  this.axi4.awcache  = `AXI4_CACHE_NO_BUF;
  this.axi4.awprot   = `AXI4_PROT_NORMAL;
  this.axi4.awqos    = `AXI4_QOS_NORMAL;
  this.axi4.awregion = `AXI4_REGION_NORMAL;
  this.axi4.awvalid  = '0;

  this.axi4.wdata    = 'x;
  this.axi4.wstrb    = '0;
  this.axi4.wlast    = '0;
  this.axi4.wuser    = '0;
  this.axi4.wvalid   = '0;

  this.axi4.bready   = '0;

  this.axi4.arid     = '0;
  this.axi4.araddr   = 'x;
  this.axi4.arlen    = '0;
  this.axi4.arsize   = `AXI4_BURST_SIZE_1BYTE;
  this.axi4.arburst  = `AXI4_BURST_TYPE_FIXED;
  this.axi4.arlock   = `AXI4_LOCK_NORM;
  this.axi4.arcache  = `AXI4_CACHE_NO_BUF;
  this.axi4.arprot   = `AXI4_PROT_NORMAL;
  this.axi4.arqos    = `AXI4_QOS_NORMAL;
  this.axi4.arregion = `AXI4_REGION_NORMAL;
  this.axi4.arvalid  = '0;

  this.axi4.rready   = '0;

  Helper::print("axi4 master device init done");
endtask

function automatic bit [`AXI4_WSTRB_WIDTH-1:0] AXI4Master::calc_strb(
    input bit [`AXI4_ADDR_WIDTH-1:0] addr, input bit [2:0] size);

  int unsigned                         byte_count;
  int unsigned                         byte_offset;
  bit          [`AXI4_WSTRB_WIDTH-1:0] strobe;

  strobe      = '0;
  byte_count  = 1 << size;
  byte_offset = addr % `AXI4_WSTRB_WIDTH;
  if (byte_count <= `AXI4_WSTRB_WIDTH && byte_offset + byte_count <= `AXI4_WSTRB_WIDTH) begin
    for (int unsigned byte_idx = 0; byte_idx < byte_count; byte_idx++) begin
      strobe[byte_offset+byte_idx] = 1'b1;
    end
  end
  return strobe;
endfunction

function automatic bit [`AXI4_ADDR_WIDTH-1:0] AXI4Master::calc_addr(
    input bit [`AXI4_ADDR_WIDTH-1:0] addr, input bit [2:0] size, input bit [1:0] burst);

  unique case (burst)
    `AXI4_BURST_TYPE_FIXED: return addr;
    `AXI4_BURST_TYPE_INCR:  return addr + `AXI4_ADDR_WIDTH'(1 << size);
    default:                return addr;
  endcase
endfunction

function automatic bit [`AXI4_ADDR_WIDTH-1:0] AXI4Master::calc_burst_addr(
    input bit [`AXI4_ADDR_WIDTH-1:0] addr, input bit [`AXI4_ADDR_WIDTH-1:0] base_addr,
    input bit [7:0] len, input bit [2:0] size, input bit [1:0] burst);

  longint unsigned beat_bytes;
  longint unsigned burst_bytes;
  longint unsigned wrap_base;
  longint unsigned next_addr;
  longint unsigned addr_value;
  longint unsigned base_value;
  longint unsigned beat_count;

  addr_value = 64'(addr);
  base_value = 64'(base_addr);
  beat_count = 64'(len) + 64'd1;
  beat_bytes = 64'd1 << size;
  unique case (burst)
    `AXI4_BURST_TYPE_FIXED: return addr;
    `AXI4_BURST_TYPE_INCR:  return `AXI4_ADDR_WIDTH'(addr_value + beat_bytes);
    `AXI4_BURST_TYPE_WRAP: begin
      burst_bytes = beat_bytes * beat_count;
      wrap_base   = (base_value / burst_bytes) * burst_bytes;
      next_addr   = addr_value + beat_bytes;
      return `AXI4_ADDR_WIDTH'((next_addr >= wrap_base + burst_bytes) ? wrap_base : next_addr);
    end
    default:                return addr;
  endcase
endfunction

function automatic bit AXI4Master::burst_is_legal(input bit [`AXI4_ADDR_WIDTH-1:0] addr,
                                                  input bit [7:0] len, input bit [2:0] size,
                                                  input bit [1:0] burst);

  longint unsigned beat_bytes;
  longint unsigned burst_bytes;
  longint unsigned wrap_base;
  longint unsigned addr_value;
  longint unsigned beat_count;

  addr_value     = 64'(addr);
  beat_count     = 64'(len) + 64'd1;
  burst_is_legal = (int'(size) <= `AXI4_DATA_BLOG) && (burst != `AXI4_BURST_TYPE_RESV);
  beat_bytes     = 64'd1 << size;
  if (this.calc_strb(addr, size) == '0) burst_is_legal = 1'b0;
  if (burst_is_legal && burst == `AXI4_BURST_TYPE_WRAP) begin
    if (!(len == 8'd1 || len == 8'd3 || len == 8'd7 || len == 8'd15)) begin
      burst_is_legal = 1'b0;
    end
    if ((addr_value % beat_bytes) != 0) burst_is_legal = 1'b0;
    burst_bytes = beat_bytes * beat_count;
    wrap_base   = (addr_value / burst_bytes) * burst_bytes;
    if ((wrap_base & 64'hfff) + burst_bytes > 64'd4096) burst_is_legal = 1'b0;
  end else if (burst_is_legal && burst == `AXI4_BURST_TYPE_INCR &&
               ((addr_value & 64'hfff) + beat_bytes * beat_count > 64'd4096)) begin
    burst_is_legal = 1'b0;
  end
endfunction


task automatic AXI4Master::write(
    input bit [`AXI4_ID_WIDTH-1:0] id, input bit [`AXI4_ADDR_WIDTH-1:0] addr, input bit [7:0] len,
    input bit [2:0] size, input bit [1:0] burst, input bit [`AXI4_DATA_WIDTH-1:0] data[$]);

  bit          [`AXI4_ADDR_WIDTH-1:0] tmp_addr;
  int unsigned                        beat_count;

  if (!this.burst_is_legal(addr, len, size, burst)) begin
    $fatal(1, "%s: illegal AXI write burst", this.name);
  end
  beat_count = int'(len) + 1;
  if (data.size() != beat_count) begin
    $fatal(1, "%s: write data count does not match AxLEN", this.name);
  end

  // aw channel
  @(negedge this.axi4.aclk);
  this.axi4.awid    = id;
  this.axi4.awaddr  = addr;
  this.axi4.awlen   = len;
  this.axi4.awsize  = size;
  this.axi4.awburst = burst;
  this.axi4.awvalid = 1'b1;

  do @(posedge this.axi4.aclk); while (!this.axi4.awready);
  @(negedge this.axi4.aclk);
  this.axi4.awid    = '0;
  this.axi4.awaddr  = 'x;
  this.axi4.awlen   = '0;
  this.axi4.awsize  = `AXI4_BURST_SIZE_1BYTE;
  this.axi4.awburst = `AXI4_BURST_TYPE_FIXED;
  this.axi4.awvalid = '0;
  // w burst channel
  tmp_addr          = addr;
  for (int unsigned i = 0; i < beat_count; i++) begin
    this.axi4.wdata  = data[i];
    this.axi4.wstrb  = this.calc_strb(tmp_addr, size);
    this.axi4.wlast  = i == beat_count - 1;
    this.axi4.wvalid = 1'b1;
    do @(posedge this.axi4.aclk); while (!this.axi4.wready);
    tmp_addr = this.calc_burst_addr(tmp_addr, addr, len, size, burst);
    @(negedge this.axi4.aclk);
  end

  this.axi4.wdata  = 'x;
  this.axi4.wstrb  = '0;
  this.axi4.wlast  = '0;
  this.axi4.wvalid = '0;

  // b channel
  this.axi4.bready = 1'b1;
  do @(posedge this.axi4.aclk); while (!this.axi4.bvalid);

  if (this.axi4.bid != id) begin
    $fatal(1, "%s: write response ID mismatch", this.name);
  end
  if (this.axi4.bresp != `AXI4_RESP_OKAY && this.axi4.bresp != `AXI4_RESP_EXOKAY) begin
    $fatal(1, "%s: write response error %0b", this.name, this.axi4.bresp);
  end
  @(negedge this.axi4.aclk);
  this.axi4.bready = 1'b0;
endtask

task automatic AXI4Master::read(input bit [`AXI4_ID_WIDTH-1:0] id,
                                input bit [`AXI4_ADDR_WIDTH-1:0] addr, input bit [7:0] len,
                                input bit [2:0] size, input bit [1:0] burst);
  bit          [ `AXI4_ADDR_WIDTH-1:0] tmp_addr;
  bit          [`AXI4_WSTRB_WIDTH-1:0] tmp_strb;
  bit          [ `AXI4_DATA_WIDTH-1:0] tmp_mask;
  int unsigned                         beat_count;
  this.rd_data = {};
  if (!this.burst_is_legal(addr, len, size, burst)) begin
    $fatal(1, "%s: illegal AXI read burst", this.name);
  end

  // ar channel
  @(negedge this.axi4.aclk);
  this.axi4.arid    = id;
  this.axi4.araddr  = addr;
  this.axi4.arlen   = len;
  this.axi4.arsize  = size;
  this.axi4.arburst = burst;
  this.axi4.arvalid = 1'b1;

  do @(posedge this.axi4.aclk); while (!this.axi4.arready);
  @(negedge this.axi4.aclk);
  this.axi4.arid    = '0;
  this.axi4.araddr  = 'x;
  this.axi4.arlen   = '0;
  this.axi4.arsize  = `AXI4_BURST_SIZE_1BYTE;
  this.axi4.arburst = `AXI4_BURST_TYPE_FIXED;
  this.axi4.arvalid = '0;
  // r burst channel
  tmp_addr          = addr;
  beat_count        = int'(len) + 1;
  this.axi4.rready  = 1'b1;
  for (int unsigned i = 0; i < beat_count; i++) begin
    do @(posedge this.axi4.aclk); while (!this.axi4.rvalid);
    tmp_strb = this.calc_strb(tmp_addr, size);
    tmp_mask = '0;
    for (int j = 0; j < `AXI4_WSTRB_WIDTH; j++) begin
      tmp_mask[j*8+:8] = {8{tmp_strb[j]}};
    end
    // $display("%t: this.axi4.rdata: %h", $time, this.axi4.rdata);
    this.rd_data.push_back(this.axi4.rdata & tmp_mask);
    if (this.axi4.rid != id) begin
      $fatal(1, "%s: read response ID mismatch", this.name);
    end
    if (this.axi4.rresp != `AXI4_RESP_OKAY && this.axi4.rresp != `AXI4_RESP_EXOKAY) begin
      $fatal(1, "%s: read response error %0b", this.name, this.axi4.rresp);
    end
    if (this.axi4.rlast != (i == beat_count - 1)) begin
      $fatal(1, "%s: RLAST did not match burst length", this.name);
    end
    tmp_addr = this.calc_burst_addr(tmp_addr, addr, len, size, burst);
  end

  @(negedge this.axi4.aclk);
  this.axi4.rready = 1'b0;
endtask

// task automatic AXI4Master::wr_rd_check(input bit [31:0] addr, string name, input bit [63:0] data,
//                                        input Helper::cmp_t cmp_type,
//                                        input Helper::log_lev_t log_level = Helper::NORM);
//   this.wr_data = data;
//   this.write(addr, this.wr_data);
//   this.read(addr);
//   Helper::check(name, this.rd_data, this.wr_data, cmp_type, log_level);

// endtask

task automatic AXI4Master::wr_check(
    input bit [`AXI4_ID_WIDTH-1:0] id, input bit [`AXI4_ADDR_WIDTH-1:0] addr, input bit [7:0] len,
    input bit [2:0] size, input bit [1:0] burst, input bit [`AXI4_DATA_WIDTH-1:0] data[$],
    input bit [`AXI4_DATA_WIDTH-1:0] ref_data[$], input Helper::cmp_t cmp_type,
    input Helper::log_lev_t log_level = Helper::NORM);

  this.wr_data = data;
  this.write(id, addr, len, size, burst, this.wr_data);
  Helper::check_queue(name, this.wr_data, ref_data, cmp_type, log_level);
endtask

task automatic AXI4Master::rd_check(
    input bit [`AXI4_ID_WIDTH-1:0] id, input bit [`AXI4_ADDR_WIDTH-1:0] addr, input bit [7:0] len,
    input bit [2:0] size, input bit [1:0] burst, input bit [`AXI4_DATA_WIDTH-1:0] ref_data[$],
    input Helper::cmp_t cmp_type, input Helper::log_lev_t log_level = Helper::NORM);
  bit [ `AXI4_DATA_WIDTH-1:0] filter_ref_data[$];
  bit [ `AXI4_ADDR_WIDTH-1:0] nxt_addr;
  bit [`AXI4_WSTRB_WIDTH-1:0] strb;
  bit [ `AXI4_DATA_WIDTH-1:0] mask;

  this.read(id, addr, len, size, burst);

  nxt_addr = addr;
  foreach (ref_data[i]) begin
    strb = this.calc_strb(nxt_addr, size);
    mask = '0;
    for (int unsigned byte_idx = 0; byte_idx < `AXI4_WSTRB_WIDTH; byte_idx++) begin
      mask[byte_idx*8+:8] = {8{strb[byte_idx]}};
    end
    filter_ref_data.push_back(ref_data[i] & mask);
    nxt_addr = this.calc_burst_addr(nxt_addr, addr, len, size, burst);
  end
  Helper::check_queue(name, this.rd_data, filter_ref_data, cmp_type, log_level);
endtask
