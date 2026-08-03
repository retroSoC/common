// Copyright (c) 2023-2026 Yuchi Miao <miaoyuchi@ict.ac.cn>
// SPDX-License-Identifier: MulanPSL-2.0

module memory_tb;
  logic        clk = 0;
  logic        write_enable;
  logic        read_enable;
  logic [ 1:0] address;
  logic [15:0] write_data;
  logic [15:0] read_data;
  logic        tech_en_n;
  logic        tech_we_n;
  logic [ 1:0] tech_address;
  logic [15:0] tech_write_data;
  logic [15:0] tech_read_data;
  logic [ 1:0] byte_mask_n;
  logic        bounded_write_enable;
  logic        bounded_read_enable;
  logic [ 1:0] bounded_address;
  logic [ 7:0] bounded_write_data;
  logic [ 7:0] bounded_read_data;
  always #5 clk = !clk;

  sync_memory #(
      .DATA_WIDTH(16),
      .DEPTH     (4)
  ) u_memory (
      .clk_i         (clk),
      .write_enable_i(write_enable),
      .read_enable_i (read_enable),
      .addr_i        (address),
      .write_data_i  (write_data),
      .read_data_o   (read_data)
  );
  tech_ram_bm #(
      .BIT_WIDTH (16),
      .WORD_DEPTH(4)
  ) u_tech_memory (
      .clk_i (clk),
      .en_i  (tech_en_n),
      .wen_i (tech_we_n),
      .bm_i  (byte_mask_n),
      .addr_i(tech_address),
      .dat_i (tech_write_data),
      .dat_o (tech_read_data)
  );
  sync_memory #(
      .DATA_WIDTH(8),
      .DEPTH     (3),
      .ADDR_WIDTH(2)
  ) u_bounded_memory (
      .clk_i         (clk),
      .write_enable_i(bounded_write_enable),
      .read_enable_i (bounded_read_enable),
      .addr_i        (bounded_address),
      .write_data_i  (bounded_write_data),
      .read_data_o   (bounded_read_data)
  );

  initial begin
    write_enable         = 0;
    read_enable          = 0;
    address              = 0;
    write_data           = 0;
    tech_en_n            = 1;
    tech_we_n            = 1;
    tech_address         = 0;
    tech_write_data      = 0;
    byte_mask_n          = 2'b11;
    bounded_write_enable = 0;
    bounded_read_enable  = 0;
    bounded_address      = 0;
    bounded_write_data   = 0;
    @(negedge clk);
    address      = 2;
    write_data   = 16'hcafe;
    write_enable = 1;
    @(negedge clk);
    write_enable = 0;
    read_enable  = 1;
    @(negedge clk);
    #1;
    if (read_data != 16'hcafe) $fatal(1, "sync_memory read mismatch");

    tech_address    = 1;
    tech_write_data = 16'h1234;
    tech_en_n       = 0;
    tech_we_n       = 0;
    byte_mask_n     = 2'b00;
    @(negedge clk);
    tech_we_n = 1;
    @(negedge clk);
    #1;
    if (tech_read_data != 16'h1234) $fatal(1, "tech memory read mismatch");
    tech_write_data = 16'habcd;
    tech_we_n       = 0;
    byte_mask_n     = 2'b10;
    @(negedge clk);
    tech_we_n = 1;
    @(negedge clk);
    #1;
    if (tech_read_data != 16'h12cd) $fatal(1, "byte write mismatch");
    bounded_address      = 2;
    bounded_write_data   = 8'h7e;
    bounded_write_enable = 1;
    @(negedge clk);
    bounded_write_enable = 0;
    bounded_read_enable  = 1;
    @(negedge clk);
    if (bounded_read_data != 8'h7e) $fatal(1, "non-power-of-two depth access mismatch");
    $display("[PASS] memory_tb");
    $finish;
  end
endmodule
