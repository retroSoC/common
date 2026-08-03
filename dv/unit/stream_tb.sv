// Copyright (c) 2023-2026 Yuchi Miao <miaoyuchi@ict.ac.cn>
// SPDX-License-Identifier: MulanPSL-2.0

module stream_tb;
  logic             clk = 0;
  logic             rst_n = 0;
  logic             flush;
  logic             in_valid;
  logic             in_ready;
  logic [ 7:0]      in_data;
  logic             out_valid;
  logic             out_ready;
  logic [ 7:0]      out_data;
  logic [ 1:0]      select;
  logic [ 3:0]      selected_valid;
  logic [ 3:0]      selected_ready;
  logic [ 3:0][7:0] selected_data;
  logic             mux_valid;
  logic             mux_ready;
  logic [ 7:0]      mux_data;
  logic [ 1:0]      route_select;
  logic             route_valid;
  logic             route_ready;
  logic [ 7:0]      route_data;
  logic [ 3:0]      routed_valid;
  logic [ 3:0]      routed_ready;
  logic [ 3:0][7:0] routed_data;
  logic [ 3:0]      replica_enable;
  logic [ 3:0]      replica_valid;
  logic [ 3:0]      replica_ready;
  logic [ 3:0][7:0] replica_data;
  logic             replica_input_ready;
  logic [ 3:0]      collect_valid;
  logic [ 3:0]      collect_ready;
  logic [ 3:0][7:0] collect_data;
  logic [ 3:0]      collect_enable;
  logic             collect_output_valid;
  logic             collect_output_ready;
  logic [31:0]      collect_output_data;
  logic             credit_valid;
  logic             credit_ready;
  logic [ 7:0]      credit_data;
  logic             credit_output_valid;
  logic             credit_output_ready;
  logic [ 7:0]      credit_output_data;
  logic             credit_release;
  logic [ 1:0]      credits;
  int               replica_transfers    [4];
  always #5 clk = !clk;

  always @(posedge clk) begin
    for (int port_idx = 0; port_idx < 4; port_idx++) begin
      if (replica_valid[port_idx] && replica_ready[port_idx]) replica_transfers[port_idx]++;
    end
  end

  stream_buffer #(
      .DATA_WIDTH(8)
  ) u_buffer (
      .clk_i      (clk),
      .rst_n_i    (rst_n),
      .flush_i    (flush),
      .in_valid_i (in_valid),
      .in_ready_o (in_ready),
      .in_data_i  (in_data),
      .out_valid_o(out_valid),
      .out_ready_i(out_ready),
      .out_data_o (out_data)
  );
  stream_selector #(
      .DATA_WIDTH(8),
      .PORTS     (4)
  ) u_selector (
      .select_i   (select),
      .in_valid_i (selected_valid),
      .in_ready_o (selected_ready),
      .in_data_i  (selected_data),
      .out_valid_o(mux_valid),
      .out_ready_i(mux_ready),
      .out_data_o (mux_data)
  );
  stream_router #(
      .DATA_WIDTH(8),
      .PORTS     (4)
  ) u_router (
      .select_i   (route_select),
      .in_valid_i (route_valid),
      .in_ready_o (route_ready),
      .in_data_i  (route_data),
      .out_valid_o(routed_valid),
      .out_ready_i(routed_ready),
      .out_data_o (routed_data)
  );
  stream_replicator #(
      .DATA_WIDTH(8),
      .PORTS     (4)
  ) u_replicator (
      .clk_i      (clk),
      .rst_n_i    (rst_n),
      .flush_i    (flush),
      .in_valid_i (route_valid),
      .in_ready_o (replica_input_ready),
      .in_data_i  (route_data),
      .enable_i   (replica_enable),
      .out_valid_o(replica_valid),
      .out_ready_i(replica_ready),
      .out_data_o (replica_data)
  );
  stream_collector #(
      .DATA_WIDTH(8),
      .PORTS     (4)
  ) u_collector (
      .in_valid_i (collect_valid),
      .in_ready_o (collect_ready),
      .in_data_i  (collect_data),
      .enable_i   (collect_enable),
      .out_valid_o(collect_output_valid),
      .out_ready_i(collect_output_ready),
      .out_data_o (collect_output_data)
  );
  stream_credit_limiter #(
      .DATA_WIDTH (8),
      .MAX_CREDITS(2)
  ) u_credit_limiter (
      .clk_i      (clk),
      .rst_n_i    (rst_n),
      .flush_i    (flush),
      .release_i  (credit_release),
      .in_valid_i (credit_valid),
      .in_ready_o (credit_ready),
      .in_data_i  (credit_data),
      .out_valid_o(credit_output_valid),
      .out_ready_i(credit_output_ready),
      .out_data_o (credit_output_data),
      .credit_o   (credits)
  );

  initial begin
    flush                = 0;
    in_valid             = 0;
    in_data              = 0;
    out_ready            = 0;
    select               = 2;
    selected_valid       = 4'b0100;
    selected_data[0]     = 8'h10;
    selected_data[1]     = 8'h20;
    selected_data[2]     = 8'h30;
    selected_data[3]     = 8'h40;
    mux_ready            = 1;
    route_select         = 1;
    route_valid          = 1;
    route_data           = 8'h5a;
    routed_ready         = 4'b0010;
    replica_enable       = 4'b1011;
    replica_ready        = '0;
    collect_valid        = 4'b0101;
    collect_data[0]      = 8'h01;
    collect_data[1]      = 8'h02;
    collect_data[2]      = 8'h03;
    collect_data[3]      = 8'h04;
    collect_enable       = 4'b0101;
    collect_output_ready = 1;
    credit_valid         = 0;
    credit_data          = 8'hc3;
    credit_output_ready  = 1;
    credit_release       = 0;
    for (int port_idx = 0; port_idx < 4; port_idx++) begin
      replica_transfers[port_idx] = 0;
    end
    repeat (2) @(negedge clk);
    rst_n = 1;
    #1;
    if (!mux_valid || mux_data != 8'h30 || selected_ready != 4'b0100) $fatal(1, "selector failed");
    if (!route_ready || routed_valid != 4'b0010 || routed_data[1] != 8'h5a)
      $fatal(1, "router failed");
    if (!replica_input_ready || replica_valid != '0) $fatal(1, "replicator idle contract failed");
    if (!collect_output_valid || collect_ready != 4'b0101 || collect_output_data != 32'h0403_0201)
      $fatal(1, "collector failed");

    // Targets may consume the stored word in different cycles. Changing the
    // live input and enable mask after acceptance must not affect the item.
    route_data     = 8'h5a;
    route_valid    = 1;
    replica_enable = 4'b1011;
    @(negedge clk);
    route_valid = 0;
    #1;
    if (replica_valid != 4'b1011 || replica_data[3] != 8'h5a || replica_input_ready)
      $fatal(1, "replicator did not retain accepted word");
    route_data     = 8'hee;
    replica_enable = '0;
    replica_ready  = 4'b0010;
    @(negedge clk);
    #1;
    if (replica_valid != 4'b1001 || replica_data[0] != 8'h5a || replica_transfers[1] != 1)
      $fatal(1, "replicator did not retire first target exactly once");
    replica_ready = 4'b1000;
    @(negedge clk);
    #1;
    if (replica_valid != 4'b0001 || replica_transfers[3] != 1)
      $fatal(1, "replicator did not preserve pending targets");
    replica_ready = 4'b0001;
    @(negedge clk);
    #1;
    if (replica_valid != '0 || !replica_input_ready || replica_transfers[0] != 1 ||
        replica_transfers[2] != 0 || replica_transfers[3] != 1)
      $fatal(1, "replicator exact-once contract failed");
    @(negedge clk);
    credit_valid = 1;
    @(negedge clk);
    credit_valid = 0;
    #1;
    if (credits != 1 || credit_output_data != 8'hc3) $fatal(1, "credit limiter failed");
    @(negedge clk);
    in_data  = 8'hab;
    in_valid = 1;
    @(negedge clk);
    in_valid = 0;
    #1;
    if (!out_valid || out_data != 8'hab) $fatal(1, "stream buffer did not retain word");
    out_ready = 1;
    @(negedge clk);
    #1;
    if (out_valid) $fatal(1, "stream buffer did not drain");
    flush    = 1;
    in_valid = 1;
    #1;
    if (in_ready || out_valid) $fatal(1, "flush handshake contract failed");
    $display("[PASS] stream_tb");
    $finish;
  end
endmodule
