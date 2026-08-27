// Copyright (c) 2026 Yuchi Miao <miaoyuchi@ict.ac.cn>
// SPDX-License-Identifier: MulanPSL-2.0

// Elastic register slice for all five independent AXI4 channels.
// flush_i cancels buffered transactions without creating a handshake.
module axi4_regslice #(
    parameter int ADDR_WIDTH = 32,
    parameter int DATA_WIDTH = 32,
    parameter int ID_WIDTH   = 1,
    parameter int USER_WIDTH = 1,
    parameter bit BYPASS     = 1'b0
) (
    input logic          clk_i,
    input logic          rst_n_i,
    input logic          flush_i,
          axi4_if.slave  slv,
          axi4_if.master mst
);
  localparam int STRB_WIDTH = DATA_WIDTH / 8;
  localparam int AW_WIDTH = ID_WIDTH + ADDR_WIDTH + 8 + 3 + 2 + 1 + 4 + 3 + 4 + 4 + USER_WIDTH;
  localparam int W_WIDTH = DATA_WIDTH + STRB_WIDTH + 1 + USER_WIDTH;
  localparam int B_WIDTH = ID_WIDTH + 2 + USER_WIDTH;
  localparam int AR_WIDTH = AW_WIDTH;
  localparam int R_WIDTH = ID_WIDTH + DATA_WIDTH + 2 + 1 + USER_WIDTH;

  logic [AW_WIDTH-1:0] s_aw_in, s_aw_out;
  logic [W_WIDTH-1:0] s_w_in, s_w_out;
  logic [B_WIDTH-1:0] s_b_in, s_b_out;
  logic [AR_WIDTH-1:0] s_ar_in, s_ar_out;
  logic [R_WIDTH-1:0] s_r_in, s_r_out;

  assign s_aw_in = {
    slv.awid,
    slv.awaddr,
    slv.awlen,
    slv.awsize,
    slv.awburst,
    slv.awlock,
    slv.awcache,
    slv.awprot,
    slv.awqos,
    slv.awregion,
    slv.awuser
  };
  assign {mst.awid, mst.awaddr, mst.awlen, mst.awsize, mst.awburst, mst.awlock, mst.awcache,
          mst.awprot, mst.awqos, mst.awregion, mst.awuser} = s_aw_out;

  spill_register #(
      .DATA_WIDTH(AW_WIDTH),
      .BYPASS    (BYPASS)
  ) u_aw_spill_register (
      .clk_i  (clk_i),
      .rst_n_i(rst_n_i),
      .flush_i(flush_i),
      .valid_i(slv.awvalid),
      .ready_o(slv.awready),
      .data_i (s_aw_in),
      .valid_o(mst.awvalid),
      .ready_i(mst.awready),
      .data_o (s_aw_out)
  );

  assign s_w_in = {slv.wdata, slv.wstrb, slv.wlast, slv.wuser};
  assign {mst.wdata, mst.wstrb, mst.wlast, mst.wuser} = s_w_out;

  spill_register #(
      .DATA_WIDTH(W_WIDTH),
      .BYPASS    (BYPASS)
  ) u_w_spill_register (
      .clk_i  (clk_i),
      .rst_n_i(rst_n_i),
      .flush_i(flush_i),
      .valid_i(slv.wvalid),
      .ready_o(slv.wready),
      .data_i (s_w_in),
      .valid_o(mst.wvalid),
      .ready_i(mst.wready),
      .data_o (s_w_out)
  );

  assign s_b_in                          = {mst.bid, mst.bresp, mst.buser};
  assign {slv.bid, slv.bresp, slv.buser} = s_b_out;

  spill_register #(
      .DATA_WIDTH(B_WIDTH),
      .BYPASS    (BYPASS)
  ) u_b_spill_register (
      .clk_i  (clk_i),
      .rst_n_i(rst_n_i),
      .flush_i(flush_i),
      .valid_i(mst.bvalid),
      .ready_o(mst.bready),
      .data_i (s_b_in),
      .valid_o(slv.bvalid),
      .ready_i(slv.bready),
      .data_o (s_b_out)
  );

  assign s_ar_in = {
    slv.arid,
    slv.araddr,
    slv.arlen,
    slv.arsize,
    slv.arburst,
    slv.arlock,
    slv.arcache,
    slv.arprot,
    slv.arqos,
    slv.arregion,
    slv.aruser
  };
  assign {mst.arid, mst.araddr, mst.arlen, mst.arsize, mst.arburst, mst.arlock, mst.arcache,
          mst.arprot, mst.arqos, mst.arregion, mst.aruser} = s_ar_out;

  spill_register #(
      .DATA_WIDTH(AR_WIDTH),
      .BYPASS    (BYPASS)
  ) u_ar_spill_register (
      .clk_i  (clk_i),
      .rst_n_i(rst_n_i),
      .flush_i(flush_i),
      .valid_i(slv.arvalid),
      .ready_o(slv.arready),
      .data_i (s_ar_in),
      .valid_o(mst.arvalid),
      .ready_i(mst.arready),
      .data_o (s_ar_out)
  );

  assign s_r_in = {mst.rid, mst.rdata, mst.rresp, mst.rlast, mst.ruser};
  assign {slv.rid, slv.rdata, slv.rresp, slv.rlast, slv.ruser} = s_r_out;

  spill_register #(
      .DATA_WIDTH(R_WIDTH),
      .BYPASS    (BYPASS)
  ) u_r_spill_register (
      .clk_i  (clk_i),
      .rst_n_i(rst_n_i),
      .flush_i(flush_i),
      .valid_i(mst.rvalid),
      .ready_o(mst.rready),
      .data_i (s_r_in),
      .valid_o(slv.rvalid),
      .ready_i(slv.rready),
      .data_o (s_r_out)
  );

  initial begin
    if (ADDR_WIDTH < 1 || DATA_WIDTH < 8 || (DATA_WIDTH % 8) != 0 || ID_WIDTH < 1 ||
        USER_WIDTH < 1) begin
      $fatal(1, "axi4_regslice: invalid interface geometry");
    end
  end
endmodule
