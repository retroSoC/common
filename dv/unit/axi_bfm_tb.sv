// Copyright (c) 2026 Yuchi Miao <miaoyuchi@ict.ac.cn>
// SPDX-License-Identifier: MulanPSL-2.0

`include "axi4_define.svh"

module axi_bfm_tb;
  logic aclk = 1'b0;
  logic aresetn = 1'b0;
  axi4_if axi4 (.*);
  AXI4Master                        master;

  logic                             r_write_active;
  logic      [  `AXI4_ID_WIDTH-1:0] r_write_id;
  logic      [                 7:0] r_write_len;
  logic      [                 7:0] r_write_count;
  logic                             r_read_active;
  logic      [  `AXI4_ID_WIDTH-1:0] r_read_id;
  logic      [                 7:0] r_read_len;
  logic      [                 7:0] r_read_count;
  logic      [                 2:0] r_read_size;
  logic      [                 1:0] r_read_burst;
  logic      [`AXI4_ADDR_WIDTH-1:0] r_read_base;
  logic      [`AXI4_ADDR_WIDTH-1:0] r_read_addr;
  int                               r_write_beats;

  always #5 aclk = !aclk;

  function automatic logic [`AXI4_ADDR_WIDTH-1:0] next_addr(
      input logic [`AXI4_ADDR_WIDTH-1:0] current_addr, input logic [`AXI4_ADDR_WIDTH-1:0] base_addr,
      input logic [7:0] len, input logic [2:0] size, input logic [1:0] burst);
    longint unsigned beat_bytes;
    longint unsigned burst_bytes;
    longint unsigned wrap_base;
    longint unsigned candidate;
    longint unsigned current_value;
    longint unsigned base_value;
    longint unsigned beat_count;

    current_value = 64'(current_addr);
    base_value    = 64'(base_addr);
    beat_count    = 64'(len) + 64'd1;
    beat_bytes    = 64'd1 << size;
    case (burst)
      `AXI4_BURST_TYPE_FIXED: next_addr = current_addr;
      `AXI4_BURST_TYPE_INCR:  next_addr = `AXI4_ADDR_WIDTH'(current_value + beat_bytes);
      `AXI4_BURST_TYPE_WRAP: begin
        burst_bytes = beat_bytes * beat_count;
        wrap_base = (base_value / burst_bytes) * burst_bytes;
        candidate = current_value + beat_bytes;
        next_addr = `AXI4_ADDR_WIDTH'((candidate >= wrap_base + burst_bytes) ? wrap_base : candidate);
      end
      default:                next_addr = current_addr;
    endcase
  endfunction

  always_ff @(posedge aclk or negedge aresetn) begin
    if (!aresetn) begin
      axi4.awready   <= 1'b0;
      axi4.wready    <= 1'b0;
      axi4.bid       <= '0;
      axi4.bresp     <= `AXI4_RESP_OKAY;
      axi4.buser     <= '0;
      axi4.bvalid    <= 1'b0;
      axi4.arready   <= 1'b0;
      axi4.rid       <= '0;
      axi4.rdata     <= '0;
      axi4.rresp     <= `AXI4_RESP_OKAY;
      axi4.rlast     <= 1'b0;
      axi4.ruser     <= '0;
      axi4.rvalid    <= 1'b0;
      r_write_active <= 1'b0;
      r_write_id     <= '0;
      r_write_len    <= '0;
      r_write_count  <= '0;
      r_read_active  <= 1'b0;
      r_read_id      <= '0;
      r_read_len     <= '0;
      r_read_count   <= '0;
      r_read_size    <= '0;
      r_read_burst   <= '0;
      r_read_base    <= '0;
      r_read_addr    <= '0;
      r_write_beats  <= 0;
    end else begin
      // Alternating ready values exercise master valid stability under stalls.
      axi4.awready <= !axi4.awready;
      axi4.wready  <= !axi4.wready;
      axi4.arready <= !axi4.arready;

      if (axi4.awvalid && axi4.awready) begin
        if (r_write_active) $fatal(1, "slave accepted overlapping AW");
        r_write_active <= 1'b1;
        r_write_id     <= axi4.awid;
        r_write_len    <= axi4.awlen;
        r_write_count  <= '0;
      end
      if (axi4.wvalid && axi4.wready) begin
        if (!r_write_active) $fatal(1, "slave accepted W without AW");
        if (axi4.wlast != (r_write_count == r_write_len)) $fatal(1, "BFM WLAST mismatch");
        if (axi4.wstrb != '1) $fatal(1, "BFM full-width write strobe mismatch");
        r_write_beats <= r_write_beats + 1;
        if (r_write_count == r_write_len) begin
          r_write_active <= 1'b0;
          axi4.bid       <= r_write_id;
          axi4.bresp     <= `AXI4_RESP_OKAY;
          axi4.bvalid    <= 1'b1;
        end else begin
          r_write_count <= r_write_count + 1'b1;
        end
      end
      if (axi4.bvalid && axi4.bready) axi4.bvalid <= 1'b0;

      if (axi4.arvalid && axi4.arready && !r_read_active && !axi4.rvalid) begin
        r_read_active <= 1'b1;
        r_read_id     <= axi4.arid;
        r_read_len    <= axi4.arlen;
        r_read_count  <= '0;
        r_read_size   <= axi4.arsize;
        r_read_burst  <= axi4.arburst;
        r_read_base   <= axi4.araddr;
        r_read_addr   <= axi4.araddr;
        axi4.rid      <= axi4.arid;
        axi4.rdata    <= {32'b0, axi4.araddr};
        axi4.rresp    <= `AXI4_RESP_OKAY;
        axi4.rlast    <= axi4.arlen == '0;
        axi4.rvalid   <= 1'b1;
      end else if (axi4.rvalid && axi4.rready) begin
        if (r_read_count == r_read_len) begin
          axi4.rvalid   <= 1'b0;
          axi4.rlast    <= 1'b0;
          r_read_active <= 1'b0;
        end else begin
          r_read_count <= r_read_count + 1'b1;
          r_read_addr <= next_addr(r_read_addr, r_read_base, r_read_len, r_read_size, r_read_burst);
          axi4.rid <= r_read_id;
          axi4.rdata <= {
            32'b0, next_addr(r_read_addr, r_read_base, r_read_len, r_read_size, r_read_burst)
          };
          axi4.rlast <= r_read_count + 1'b1 == r_read_len;
        end
      end
    end
  end

  task automatic expect_read(input logic [`AXI4_DATA_WIDTH-1:0] expected[$]);
    if (master.rd_data.size() != expected.size()) $fatal(1, "read beat count mismatch");
    foreach (expected[beat_idx]) begin
      if (master.rd_data[beat_idx] != expected[beat_idx]) begin
        $fatal(1, "read beat %0d mismatch: got %h expected %h", beat_idx, master.rd_data[beat_idx],
               expected[beat_idx]);
      end
    end
  endtask

  initial begin
    logic [`AXI4_DATA_WIDTH-1:0] write_data[$];
    logic [`AXI4_DATA_WIDTH-1:0] expected  [$];

    repeat (3) @(posedge aclk);
    aresetn = 1'b1;
    master  = new("axi_bfm", axi4);
    master.init();

    write_data = {};
    for (int unsigned beat_idx = 0; beat_idx < 4; beat_idx++) begin
      write_data.push_back(64'h1000 + 64'(beat_idx));
    end
    master.write(4'h1, 32'h0000_0100, 8'd3, `AXI4_BURST_SIZE_8BYTES, `AXI4_BURST_TYPE_INCR,
                 write_data);
    if (r_write_beats != 4) $fatal(1, "write burst was not fully delivered");

    master.read(4'h2, 32'h0000_0100, 8'd3, `AXI4_BURST_SIZE_8BYTES, `AXI4_BURST_TYPE_INCR);
    expected = {};
    expected.push_back(64'h100);
    expected.push_back(64'h108);
    expected.push_back(64'h110);
    expected.push_back(64'h118);
    expect_read(expected);

    master.read(4'h3, 32'h0000_0130, 8'd3, `AXI4_BURST_SIZE_8BYTES, `AXI4_BURST_TYPE_WRAP);
    expected = {};
    expected.push_back(64'h130);
    expected.push_back(64'h138);
    expected.push_back(64'h120);
    expected.push_back(64'h128);
    expect_read(expected);

    master.read(4'h4, 32'h0000_0200, 8'd1, `AXI4_BURST_SIZE_8BYTES, `AXI4_BURST_TYPE_FIXED);
    expected = {};
    expected.push_back(64'h200);
    expected.push_back(64'h200);
    expect_read(expected);

    $display("[PASS] axi_bfm_tb");
    $finish;
  end
endmodule
