// Copyright (c) 2026 Yuchi Miao <miaoyuchi@ict.ac.cn>
// SPDX-License-Identifier: MulanPSL-2.0

module register_tb;
  logic       clk;
  logic       rst_n;
  logic       en;
  logic [3:0] dat_i;

  logic [3:0] dff_o;
  logic [3:0] dffr_o;
  logic [3:0] ndffr_o;
  logic [3:0] ndffer_o;
  logic [3:0] dffrh_o;
  logic [3:0] dffrc_o;
  logic [3:0] dffsr_o;
  logic [3:0] dffsrc_o;
  logic [3:0] dffl_o;
  logic [3:0] dffer_o;
  logic [3:0] dfferh_o;
  logic [3:0] dfferc_o;
  logic [3:0] dffercn_o;
  logic [3:0] dffesr_o;
  logic [3:0] dffesrc_o;
  logic [3:0] dfferm_o             [0:2];
  logic [3:0] dffsrc_before_reset;
  logic [3:0] dffesrc_before_reset;

  dff #(
      .DATA_WIDTH(4)
  ) u_dff (
      .clk_i(clk),
      .dat_i(dat_i),
      .dat_o(dff_o)
  );
  dffr #(
      .DATA_WIDTH(4)
  ) u_dffr (
      .clk_i  (clk),
      .rst_n_i(rst_n),
      .dat_i  (dat_i),
      .dat_o  (dffr_o)
  );
  ndffr #(
      .DATA_WIDTH(4)
  ) u_ndffr (
      .clk_i  (clk),
      .rst_n_i(rst_n),
      .dat_i  (dat_i),
      .dat_o  (ndffr_o)
  );
  ndffer #(
      .DATA_WIDTH(4)
  ) u_ndffer (
      .clk_i  (clk),
      .rst_n_i(rst_n),
      .en_i   (en),
      .dat_i  (dat_i),
      .dat_o  (ndffer_o)
  );
  dffrh #(
      .DATA_WIDTH(4)
  ) u_dffrh (
      .clk_i  (clk),
      .rst_n_i(rst_n),
      .dat_i  (dat_i),
      .dat_o  (dffrh_o)
  );
  dffrc #(
      .DATA_WIDTH(4),
      .RESET_VAL (4'hA)
  ) u_dffrc (
      .clk_i  (clk),
      .rst_n_i(rst_n),
      .dat_i  (dat_i),
      .dat_o  (dffrc_o)
  );
  dffsr #(
      .DATA_WIDTH(4)
  ) u_dffsr (
      .clk_i  (clk),
      .rst_n_i(rst_n),
      .dat_i  (dat_i),
      .dat_o  (dffsr_o)
  );
  dffsrc #(
      .DATA_WIDTH(4),
      .RESET_VAL (4'hB)
  ) u_dffsrc (
      .clk_i  (clk),
      .rst_n_i(rst_n),
      .dat_i  (dat_i),
      .dat_o  (dffsrc_o)
  );
  dffl #(
      .DATA_WIDTH(4)
  ) u_dffl (
      .clk_i(clk),
      .en_i (en),
      .dat_i(dat_i),
      .dat_o(dffl_o)
  );
  dffer #(
      .DATA_WIDTH(4)
  ) u_dffer (
      .clk_i  (clk),
      .rst_n_i(rst_n),
      .en_i   (en),
      .dat_i  (dat_i),
      .dat_o  (dffer_o)
  );
  dfferh #(
      .DATA_WIDTH(4)
  ) u_dfferh (
      .clk_i  (clk),
      .rst_n_i(rst_n),
      .en_i   (en),
      .dat_i  (dat_i),
      .dat_o  (dfferh_o)
  );
  dfferc #(
      .DATA_WIDTH(4),
      .RESET_VAL (4'hC)
  ) u_dfferc (
      .clk_i  (clk),
      .rst_n_i(rst_n),
      .en_i   (en),
      .dat_i  (dat_i),
      .dat_o  (dfferc_o)
  );
  dffercn #(
      .REG_TYPE (logic [3:0]),
      .RESET_VAL(4'hD)
  ) u_dffercn (
      .clk_i  (clk),
      .rst_n_i(rst_n),
      .en_i   (en),
      .dat_i  (dat_i),
      .dat_o  (dffercn_o)
  );
  dffesr #(
      .DATA_WIDTH(4)
  ) u_dffesr (
      .clk_i  (clk),
      .rst_n_i(rst_n),
      .en_i   (en),
      .dat_i  (dat_i),
      .dat_o  (dffesr_o)
  );
  dffesrc #(
      .DATA_WIDTH(4),
      .RESET_VAL (4'hE)
  ) u_dffesrc (
      .clk_i  (clk),
      .rst_n_i(rst_n),
      .en_i   (en),
      .dat_i  (dat_i),
      .dat_o  (dffesrc_o)
  );
  dfferm #(
      .DATA_NUM  (3),
      .DATA_WIDTH(4),
      .INIT_VAL  (4'hF)
  ) u_dfferm (
      .clk_i  (clk),
      .rst_n_i(rst_n),
      .en_i   ({en, 1'b0, en}),
      .dat_i  ('{4'h1, 4'h2, 4'h3}),
      .dat_o  (dfferm_o)
  );

  always #5 clk = ~clk;

  task automatic check_async_reset;
    begin
      #1;
      if (dffr_o !== 4'h0 || ndffr_o !== 4'h0 || ndffer_o !== 4'h0 ||
          dffrh_o !== 4'hF || dffrc_o !== 4'hA || dffer_o !== 4'h0 ||
          dfferh_o !== 4'hF || dfferc_o !== 4'hC || dffercn_o !== 4'hD ||
          dfferm_o[0] !== 4'hF || dfferm_o[1] !== 4'h0 || dfferm_o[2] !== 4'h0) begin
        $fatal(1, "asynchronous reset values are incorrect");
      end
    end
  endtask

  initial begin
    clk   = 1'b0;
    rst_n = 1'b1;
    en    = 1'b0;
    dat_i = 4'h0;
    #1;
    rst_n = 1'b0;
    check_async_reset();

    dat_i = 4'h5;
    repeat (2) @(posedge clk);
    if (dffsr_o !== 4'h0 || dffsrc_o !== 4'hB || dffesr_o !== 4'h0 || dffesrc_o !== 4'hE) begin
      $fatal(1, "synchronous reset values are incorrect");
    end

    @(negedge clk);
    rst_n = 1'b1;
    en    = 1'b0;
    dat_i = 4'h6;
    @(posedge clk);
    #1;
    if (dffer_o !== 4'h0 || ndffer_o !== 4'h0 || dffesrc_o !== 4'hE) begin
      $fatal(1, "disabled registers did not retain their values");
    end

    @(negedge clk);
    en    = 1'b1;
    dat_i = 4'h7;
    @(posedge clk);
    #1;
    if (dff_o !== 4'h7 || dffr_o !== 4'h7 || dffl_o !== 4'h7 || dffer_o !== 4'h7 ||
        dfferc_o !== 4'h7 || dffercn_o !== 4'h7 || dffesr_o !== 4'h7 ||
        dffesrc_o !== 4'h7) begin
      $fatal(1, "enabled rising-edge registers did not update");
    end

    @(negedge clk);
    dat_i = 4'h8;
    @(negedge clk);
    #1;
    if (ndffr_o !== 4'h8 || ndffer_o !== 4'h8) begin
      $fatal(1, "falling-edge registers did not update");
    end

    @(negedge clk);
    dffsrc_before_reset  = dffsrc_o;
    dffesrc_before_reset = dffesrc_o;
    rst_n                = 1'b0;
    #1;
    if (dffsrc_o !== dffsrc_before_reset || dffesrc_o !== dffesrc_before_reset) begin
      $fatal(1, "synchronous reset changed outputs asynchronously");
    end
    @(posedge clk);
    #1;
    if (dffsrc_o !== 4'hB || dffesrc_o !== 4'hE) begin
      $fatal(1, "synchronous reset values are incorrect after assertion");
    end

    $display("[PASS] register_tb");
    $finish;
  end
endmodule
