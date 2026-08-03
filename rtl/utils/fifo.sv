// Copyright (c) 2023-2026 Yuchi Miao <miaoyuchi@ict.ac.cn>
// common is licensed under Mulan PSL v2.
// See LICENSE for the complete license text.
//
// Synchronous queue. BUFFER_DEPTH is intentionally restricted to a power of
// two: the pointer bits address the storage directly. Its asynchronous read
// semantics favor small queues; generic synthesis maps the storage to flops.
module fifo #(
    parameter int DATA_WIDTH       = 32,
    parameter int BUFFER_DEPTH     = 8,
    parameter int LOG_BUFFER_DEPTH = (BUFFER_DEPTH > 1) ? $clog2(BUFFER_DEPTH) : 1
) (
    input  logic                      clk_i,
    input  logic                      rst_n_i,
    input  logic                      flush_i,
    input  logic                      push_i,
    output logic                      full_o,
    input  logic [    DATA_WIDTH-1:0] dat_i,
    input  logic                      pop_i,
    output logic                      empty_o,
    output logic [    DATA_WIDTH-1:0] dat_o,
    output logic [LOG_BUFFER_DEPTH:0] cnt_o
);

  logic [LOG_BUFFER_DEPTH-1:0] r_read_ptr;
  logic [LOG_BUFFER_DEPTH-1:0] r_write_ptr;
  logic [  LOG_BUFFER_DEPTH:0] r_count;
  logic [      DATA_WIDTH-1:0] r_storage   [0:BUFFER_DEPTH-1];
  logic                        s_take_push;
  logic                        s_take_pop;

  initial begin
    if (DATA_WIDTH < 1 || BUFFER_DEPTH < 2 || (BUFFER_DEPTH & (BUFFER_DEPTH - 1)) != 0) begin
      $fatal(1, "fifo: BUFFER_DEPTH must be a power of two and at least two");
    end
    if (LOG_BUFFER_DEPTH != $clog2(BUFFER_DEPTH)) begin
      $fatal(1, "fifo: LOG_BUFFER_DEPTH does not match BUFFER_DEPTH");
    end
  end

  assign empty_o     = (r_count == '0);
  assign full_o      = (r_count == (LOG_BUFFER_DEPTH + 1)'(BUFFER_DEPTH));
  // A pop frees a slot on the same edge, so a full queue accepts a new word.
  assign s_take_push = push_i && (!full_o || (pop_i && !empty_o));
  assign s_take_pop  = pop_i && !empty_o;
  assign cnt_o       = r_count;
  assign dat_o       = empty_o ? '0 : r_storage[r_read_ptr];

  always_ff @(posedge clk_i or negedge rst_n_i) begin
    if (!rst_n_i) begin
      r_read_ptr  <= '0;
      r_write_ptr <= '0;
      r_count     <= '0;
    end else if (flush_i) begin
      r_read_ptr  <= '0;
      r_write_ptr <= '0;
      r_count     <= '0;
    end else begin
      if (s_take_push) begin
        r_storage[r_write_ptr] <= dat_i;
        r_write_ptr            <= r_write_ptr + 1'b1;
      end
      if (s_take_pop) begin
        r_read_ptr <= r_read_ptr + 1'b1;
      end
      case ({
        s_take_push, s_take_pop
      })
        2'b10:   r_count <= r_count + 1'b1;
        2'b01:   r_count <= r_count - 1'b1;
        default: r_count <= r_count;
      endcase
    end
  end
endmodule


// Historical streaming name retained for source compatibility. It is now a
// direct wrapper around the tested fifo rather than a separate broken memory
// implementation.
module stream_fifo #(
    parameter int DATA_WIDTH       = 32,
    parameter int BUFFER_DEPTH     = 8,
    parameter int LOG_BUFFER_DEPTH = (BUFFER_DEPTH > 1) ? $clog2(BUFFER_DEPTH) : 1
) (
    input  logic                      clk_i,
    input  logic                      rst_n_i,
    input  logic                      flush_i,
    output logic                      full_o,
    output logic                      empty_o,
    output logic [LOG_BUFFER_DEPTH:0] cnt_o,
    input  logic [    DATA_WIDTH-1:0] dat_i,
    input  logic                      push_i,
    output logic [    DATA_WIDTH-1:0] dat_o,
    input  logic                      pop_i
);

  fifo #(
      .DATA_WIDTH      (DATA_WIDTH),
      .BUFFER_DEPTH    (BUFFER_DEPTH),
      .LOG_BUFFER_DEPTH(LOG_BUFFER_DEPTH)
  ) u_fifo (
      .clk_i  (clk_i),
      .rst_n_i(rst_n_i),
      .flush_i(flush_i),
      .push_i (push_i),
      .full_o (full_o),
      .dat_i  (dat_i),
      .pop_i  (pop_i),
      .empty_o(empty_o),
      .dat_o  (dat_o),
      .cnt_o  (cnt_o)
  );
endmodule
