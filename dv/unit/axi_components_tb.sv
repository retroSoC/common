// Copyright (c) 2026 Yuchi Miao <miaoyuchi@ict.ac.cn>
// SPDX-License-Identifier: MulanPSL-2.0

module axi_components_tb;
  logic clk = 1'b0;
  logic rst_n = 1'b0;

  axi4_if #(
      .ADDR_WIDTH(32),
      .DATA_WIDTH(32),
      .ID_WIDTH  (1),
      .USER_WIDTH(1)
  ) slv_axi (
      .aclk   (clk),
      .aresetn(rst_n)
  );
  axi4_if #(
      .ADDR_WIDTH(32),
      .DATA_WIDTH(32),
      .ID_WIDTH  (1),
      .USER_WIDTH(1)
  ) mst_axi (
      .aclk   (clk),
      .aresetn(rst_n)
  );
  axi4_stream_if #(
      .DATA_WIDTH(32),
      .ID_WIDTH  (1),
      .DEST_WIDTH(1),
      .USER_WIDTH(1)
  ) sink_axis (
      .aclk   (clk),
      .aresetn(rst_n)
  );
  axi4_stream_if #(
      .DATA_WIDTH(32),
      .ID_WIDTH  (1),
      .DEST_WIDTH(1),
      .USER_WIDTH(1)
  ) source_axis (
      .aclk   (clk),
      .aresetn(rst_n)
  );

  always #5 clk = ~clk;

  axi4_regslice u_axi4_regslice (
      .clk_i  (clk),
      .rst_n_i(rst_n),
      .flush_i(1'b0),
      .slv    (slv_axi),
      .mst    (mst_axi)
  );

  axi4_stream_regslice u_axi4_stream_regslice (
      .clk_i  (clk),
      .rst_n_i(rst_n),
      .flush_i(1'b0),
      .sink   (sink_axis),
      .source (source_axis)
  );

  initial begin
    slv_axi.awid       = '0;
    slv_axi.awaddr     = '0;
    slv_axi.awlen      = '0;
    slv_axi.awsize     = '0;
    slv_axi.awburst    = '0;
    slv_axi.awlock     = '0;
    slv_axi.awcache    = '0;
    slv_axi.awprot     = '0;
    slv_axi.awqos      = '0;
    slv_axi.awregion   = '0;
    slv_axi.awuser     = '0;
    slv_axi.awvalid    = 1'b0;
    slv_axi.wdata      = '0;
    slv_axi.wstrb      = '0;
    slv_axi.wlast      = 1'b0;
    slv_axi.wuser      = '0;
    slv_axi.wvalid     = 1'b0;
    slv_axi.bready     = 1'b0;
    slv_axi.arid       = '0;
    slv_axi.araddr     = '0;
    slv_axi.arlen      = '0;
    slv_axi.arsize     = '0;
    slv_axi.arburst    = '0;
    slv_axi.arlock     = '0;
    slv_axi.arcache    = '0;
    slv_axi.arprot     = '0;
    slv_axi.arqos      = '0;
    slv_axi.arregion   = '0;
    slv_axi.aruser     = '0;
    slv_axi.arvalid    = 1'b0;
    slv_axi.rready     = 1'b0;
    mst_axi.awready    = 1'b0;
    mst_axi.wready     = 1'b0;
    mst_axi.bid        = '0;
    mst_axi.bresp      = '0;
    mst_axi.buser      = '0;
    mst_axi.bvalid     = 1'b0;
    mst_axi.arready    = 1'b0;
    mst_axi.rid        = '0;
    mst_axi.rdata      = '0;
    mst_axi.rresp      = '0;
    mst_axi.rlast      = 1'b0;
    mst_axi.ruser      = '0;
    mst_axi.rvalid     = 1'b0;
    sink_axis.tdata    = '0;
    sink_axis.tkeep    = '0;
    sink_axis.tstrb    = '0;
    sink_axis.tlast    = 1'b0;
    sink_axis.tid      = '0;
    sink_axis.tdest    = '0;
    sink_axis.tuser    = '0;
    sink_axis.tvalid   = 1'b0;
    source_axis.tready = 1'b0;

    repeat (3) @(posedge clk);
    rst_n = 1'b1;
    @(negedge clk);

    sink_axis.tdata  = 32'h1234_5678;
    sink_axis.tkeep  = 4'hF;
    sink_axis.tstrb  = 4'hF;
    sink_axis.tlast  = 1'b1;
    sink_axis.tvalid = 1'b1;
    do @(posedge clk); while (!sink_axis.tready);
    @(negedge clk);
    sink_axis.tvalid = 1'b0;
    repeat (2) @(posedge clk);
    if (!source_axis.tvalid || source_axis.tdata != 32'h1234_5678 || !source_axis.tlast) begin
      $fatal(1, "AXI4-Stream register slice did not retain stalled payload");
    end
    @(negedge clk);
    source_axis.tready = 1'b1;
    @(posedge clk);
    @(negedge clk);
    source_axis.tready = 1'b0;

    slv_axi.araddr     = 32'h4000_0040;
    slv_axi.arlen      = 8'd3;
    slv_axi.arsize     = 3'd2;
    slv_axi.arburst    = 2'b01;
    slv_axi.arvalid    = 1'b1;
    do @(posedge clk); while (!slv_axi.arready);
    @(negedge clk);
    slv_axi.arvalid = 1'b0;
    repeat (2) @(posedge clk);
    if (!mst_axi.arvalid || mst_axi.araddr != 32'h4000_0040 || mst_axi.arlen != 8'd3) begin
      $fatal(1, "AXI4 register slice did not retain stalled address payload");
    end
    @(negedge clk);
    mst_axi.arready = 1'b1;
    @(posedge clk);

    $display("[PASS] axi_components_tb");
    $finish;
  end
endmodule
