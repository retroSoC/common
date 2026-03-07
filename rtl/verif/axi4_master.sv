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

  extern function new(string name = "axi4_master", virtual axi4_if.master axi4);
  extern function automatic bit [`AXI4_WSTRB_WIDTH-1:0] calc_strb(
      input bit [`AXI4_WSTRB_WIDTH-1:0] addr, input bit [2:0] size);
  extern function automatic bit [`AXI4_ADDR_WIDTH-1:0] calc_addr(
      input bit [`AXI4_WSTRB_WIDTH-1:0] addr, input bit [2:0] size, input bit [1:0] burst);
  extern task automatic init();
  extern task automatic write(
      input bit [`AXI4_ID_WIDTH-1:0] id, input bit [`AXI4_ADDR_WIDTH-1:0] addr, input bit [7:0] len,
      input bit [2:0] size, input bit [1:0] burst, input bit [`AXI4_DATA_WIDTH-1:0] data[$]);

  extern task automatic read(input bit [`AXI4_ID_WIDTH-1:0] id,
                             input bit [`AXI4_ADDR_WIDTH-1:0] addr, input bit [7:0] len,
                             input bit [2:0] size, input bit [1:0] burst);
  // extern task automatic wr_rd_check(input bit [31:0] addr, string name, input bit [63:0] data,
  //                                   input Helper::cmp_t cmp_type,
  //                                   input Helper::log_lev_t log_level = Helper::NORM);
  extern task automatic wr_check(
      input bit [`AXI4_ID_WIDTH-1:0] id, input bit [`AXI4_ADDR_WIDTH-1:0] addr, input bit [7:0] len,
      input bit [2:0] size, input bit [1:0] burst, input bit [`AXI4_DATA_WIDTH-1:0] data[$],
      input bit [`AXI4_DATA_WIDTH-1:0] ref_data[$], input Helper::cmp_t cmp_type,
      input Helper::log_lev_t log_level = Helper::NORM);

  extern task automatic rd_check(
      input bit [`AXI4_ID_WIDTH-1:0] id, input bit [`AXI4_ADDR_WIDTH-1:0] addr, input bit [7:0] len,
      input bit [2:0] size, input bit [1:0] burst, input bit [`AXI4_DATA_WIDTH-1:0] ref_data[$],
      input Helper::cmp_t cmp_type, input Helper::log_lev_t log_level = Helper::NORM);
endclass

function AXI4Master::new(string name, virtual axi4_if.master axi4);
  super.new();
  this.name    = name;
  this.rd_data = {};
  this.wr_data = {};
  this.axi4    = axi4;
endfunction

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
    input bit [`AXI4_WSTRB_WIDTH-1:0] addr, input bit [2:0] size);

  bit [`AXI4_WSTRB_WIDTH-1:0] align_strb = '0;
  int                         ofset = addr % `AXI4_WSTRB_WIDTH;
  unique case (size)
    `AXI4_BURST_SIZE_1BYTE:  align_strb = {1{1'b1}};
    `AXI4_BURST_SIZE_2BYTES: align_strb = {2{1'b1}};
    `AXI4_BURST_SIZE_4BYTES: align_strb = {4{1'b1}};
    `AXI4_BURST_SIZE_8BYTES: align_strb = {8{1'b1}};
    default:                 align_strb = '0;
  endcase

  return align_strb << ofset;
endfunction

function automatic bit [`AXI4_ADDR_WIDTH-1:0] AXI4Master::calc_addr(
    input bit [`AXI4_WSTRB_WIDTH-1:0] addr, input bit [2:0] size, input bit [1:0] burst);

  int ofset;
  unique case (burst)
    `AXI4_BURST_TYPE_FIXED: return addr;
    `AXI4_BURST_TYPE_INCR: begin
      ofset = addr % `AXI4_WSTRB_WIDTH;
      if ((ofset + (1 << size)) <= `AXI4_WSTRB_WIDTH) begin
        return addr + (1 << size);
      end else begin
        return addr + `AXI4_WSTRB_WIDTH - (1 << size);  // TODO: right?
      end
    end
    `AXI4_BURST_TYPE_WRAP: begin
      $display("no support now");
      return addr;
    end
    `AXI4_BURST_TYPE_RESV: begin
      $display("error burst type");
      return addr;
    end
  endcase

endfunction


task automatic AXI4Master::write(
    input bit [`AXI4_ID_WIDTH-1:0] id, input bit [`AXI4_ADDR_WIDTH-1:0] addr, input bit [7:0] len,
    input bit [2:0] size, input bit [1:0] burst, input bit [`AXI4_DATA_WIDTH-1:0] data[$]);

  bit [ `AXI4_ADDR_WIDTH-1:0] tmp_addr;
  bit [`AXI4_WSTRB_WIDTH-1:0] tmp_strb;

  // aw channel
  @(posedge this.axi4.aclk);
  #`REGISTER_DELAY;
  this.axi4.awid    = id;
  this.axi4.awaddr  = addr;
  this.axi4.awlen   = len;
  this.axi4.awsize  = size;
  this.axi4.awburst = burst;
  this.axi4.awvalid = 1'b1;

  @(posedge this.axi4.aclk);
  while (~this.axi4.awready) begin
    @(posedge this.axi4.aclk);
  end
  #`REGISTER_DELAY;
  // $display("%t aw trigger", $time);
  this.axi4.awid    = '0;
  this.axi4.awaddr  = 'x;
  this.axi4.awlen   = '0;
  this.axi4.awsize  = `AXI4_BURST_SIZE_1BYTE;
  this.axi4.awburst = `AXI4_BURST_TYPE_FIXED;
  this.axi4.awvalid = '0;
  @(negedge this.axi4.aclk);
  #`REGISTER_DELAY;
  // w burst channel
  tmp_addr = addr;
  for (int i = 0; i < len + 1'd1; i++) begin
    this.axi4.wdata  = data.pop_front();
    this.axi4.wstrb  = this.calc_strb(tmp_addr, size);
    tmp_addr         = this.calc_addr(tmp_addr, size, burst);
    this.axi4.wlast  = i == len;
    this.axi4.wvalid = 1'b1;
    @(posedge this.axi4.aclk);
    while (~this.axi4.wready) begin
      @(posedge this.axi4.aclk);
    end
    #`REGISTER_DELAY;
    // $display("%t w burst trigger", $time);
  end

  this.axi4.wdata  = 'x;
  this.axi4.wstrb  = '0;
  this.axi4.wlast  = '0;
  this.axi4.wvalid = '0;
  @(negedge this.axi4.aclk);

  // b channel
  this.axi4.bready = 1'b1;
  @(posedge this.axi4.aclk);
  while (~this.axi4.bvalid) begin
    @(posedge this.axi4.aclk);
  end

  if (this.axi4.bid != id) begin
    $error("%t [wr mismatch id] awid is %d, bid: %d", $time, id, this.axi4.bid);
  end else begin
    unique case (this.axi4.bresp)
      `AXI4_RESP_OKAY: begin
      end
      `AXI4_RESP_EXOKAY:       $display("%t EXOKAY", $time);
      `AXI4_RESP_SLAVE_ERROR:  $display("%t SLVERR", $time);
      `AXI4_RESP_DECODE_ERROR: $display("%t DECERR", $time);
    endcase
  end
  #`REGISTER_DELAY;
  this.axi4.bready = 1'b0;
  @(negedge this.axi4.aclk);
endtask

task automatic AXI4Master::read(input bit [`AXI4_ID_WIDTH-1:0] id,
                                input bit [`AXI4_ADDR_WIDTH-1:0] addr, input bit [7:0] len,
                                input bit [2:0] size, input bit [1:0] burst);
  bit [ `AXI4_ADDR_WIDTH-1:0] tmp_addr;
  bit [`AXI4_WSTRB_WIDTH-1:0] tmp_strb;
  bit [ `AXI4_DATA_WIDTH-1:0] tmp_mask;
  this.rd_data = {};
  // ar channel
  @(posedge this.axi4.aclk);
  #`REGISTER_DELAY;
  this.axi4.arid    = id;
  this.axi4.araddr  = addr;
  this.axi4.arlen   = len;
  this.axi4.arsize  = size;
  this.axi4.arburst = burst;
  this.axi4.arvalid = 1'b1;

  @(posedge this.axi4.aclk);
  while (~this.axi4.arready) begin
    @(posedge this.axi4.aclk);
  end
  #`REGISTER_DELAY;
  // $display("%t ar trigger", $time);
  this.axi4.arid    = '0;
  this.axi4.araddr  = 'x;
  this.axi4.arlen   = '0;
  this.axi4.arsize  = `AXI4_BURST_SIZE_1BYTE;
  this.axi4.arburst = `AXI4_BURST_TYPE_FIXED;
  this.axi4.arvalid = '0;
  @(negedge this.axi4.aclk);

  // r burst channel
  tmp_addr = addr;
  @(posedge this.axi4.aclk);
  #`REGISTER_DELAY;
  this.axi4.rready = 1'b1;
  for (int i = 0; i < len + 1'd1; i++) begin
    @(posedge this.axi4.aclk);
    while (~this.axi4.rvalid) begin
      @(posedge this.axi4.aclk);
    end
    tmp_strb = this.calc_strb(tmp_addr, size);
    for (int j = 0; j < `AXI4_WSTRB_WIDTH; j++) begin
      tmp_mask[j*8+:8] = {8{tmp_strb[j]}};
    end
    // $display("%t: this.axi4.rdata: %h", $time, this.axi4.rdata);
    this.rd_data.push_back(this.axi4.rdata & tmp_mask);
    if (this.axi4.rid != id) begin
      $error("%t [rd mismatch id] arid is %d, rid: %d", $time, id, this.axi4.rid);
    end

    if (i == len && ~axi4.rlast) begin
      $error("%t [rd error last]", $time, id);
    end else begin
      @(negedge this.axi4.aclk);
      tmp_addr = this.calc_addr(tmp_addr, size, burst);
    end
    #`REGISTER_DELAY;
  end

  this.axi4.rready = 1'b0;
  @(negedge this.axi4.aclk);
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
  bit [ `AXI4_DATA_WIDTH-1:0] filter_ref_data[$] = {};
  bit [ `AXI4_ADDR_WIDTH-1:0] nxt_addr;
  bit [`AXI4_WSTRB_WIDTH-1:0] ofset;

  this.read(id, addr, len, size, burst);

  nxt_addr = addr;
  foreach (ref_data[i]) begin
    ofset = nxt_addr % `AXI4_WSTRB_WIDTH;

    unique case (size)
      `AXI4_BURST_SIZE_1BYTE: begin
        unique case (ofset[2:0])
          3'b000: filter_ref_data[i] = {56'b0, ref_data[i][7:0]};
          3'b001: filter_ref_data[i] = {48'b0, ref_data[i][15:8], 8'b0};
          3'b010: filter_ref_data[i] = {40'b0, ref_data[i][23:16], 16'b0};
          3'b011: filter_ref_data[i] = {32'b0, ref_data[i][31:24], 24'b0};
          3'b100: filter_ref_data[i] = {24'b0, ref_data[i][39:32], 32'b0};
          3'b101: filter_ref_data[i] = {16'b0, ref_data[i][47:40], 40'b0};
          3'b110: filter_ref_data[i] = {8'b0, ref_data[i][55:48], 48'b0};
          3'b111: filter_ref_data[i] = {ref_data[i][63:56], 56'b0};
        endcase
      end
      `AXI4_BURST_SIZE_2BYTES: begin
        unique case (ofset[2:1])
          2'b00: filter_ref_data[i] = {48'b0, ref_data[i][15:0]};
          2'b01: filter_ref_data[i] = {32'b0, ref_data[i][31:16], 16'b0};
          2'b10: filter_ref_data[i] = {16'b0, ref_data[i][47:32], 32'b0};
          2'b11: filter_ref_data[i] = {ref_data[i][63:48], 48'b0};
        endcase
      end
      `AXI4_BURST_SIZE_4BYTES: begin
        unique case (ofset[2])
          1'b0: filter_ref_data[i] = {32'b0, ref_data[i][31:0]};
          1'b1: filter_ref_data[i] = {ref_data[i][63:32], 32'b0};
        endcase
      end
      `AXI4_BURST_SIZE_8BYTES: filter_ref_data[i] = ref_data[i][63:0];
      default: begin
        filter_ref_data[i] = ref_data[i];
        $display("no support now");
      end
    endcase

    nxt_addr = this.calc_addr(nxt_addr, size, burst);
  end

  // foreach (this.rd_data[i]) begin
  // $display("rd data: %h", this.rd_data[i]);
  // end
  Helper::check_queue(name, this.rd_data, filter_ref_data, cmp_type, log_level);
endtask
