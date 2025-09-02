`ifndef __APB4_IF_VH__
`define __APB4_IF_VH__

`define APB_ADDR_WIDTH 32
`define APB_DATA_WIDTH 32

`define apb4_slave_if(prefix) \
  input                              prefix``_pclk,    \
  input                              prefix``_presetn, \
  input  [  `APB_ADDR_WIDTH-1:0]     prefix``_paddr,   \
  input  [                 2:0]      prefix``_pprot,   \
  input                              prefix``_psel,    \
  input                              prefix``_penable, \
  input                              prefix``_pwrite,  \
  input  [  `APB_DATA_WIDTH-1:0]     prefix``_pwdata,  \
  input  [`APB_DATA_WIDTH/8-1:0]     prefix``_pstrb,   \
  output                             prefix``_pready,  \
  output reg [  `APB_DATA_WIDTH-1:0] prefix``_prdata,  \
  output                             prefix``_pslverr

`define apb4_slave_if2wire(if_prefix, wire_prefix) \
  logic                         wire_prefix``_pclk    = if_prefix``.pclk;    \
  logic                         wire_prefix``_presetn = if_prefix``.presetn; \
  logic [  `APB_ADDR_WIDTH-1:0] wire_prefix``_paddr   = if_prefix``.paddr;   \
  logic [                  2:0] wire_prefix``_pprot   = if_prefix``.pprot;   \
  logic                         wire_prefix``_psel    = if_prefix``.psel;    \
  logic                         wire_prefix``_penable = if_prefix``.penable; \
  logic                         wire_prefix``_pwrite  = if_prefix``.pwrite;  \
  logic [  `APB_DATA_WIDTH-1:0] wire_prefix``_pwdata  = if_prefix``.pwdata;  \
  logic [`APB_DATA_WIDTH/8-1:0] wire_prefix``_pstrb   = if_prefix``.pstrb;   \
  logic                         wire_prefix``_pready; \
  logic [  `APB_DATA_WIDTH-1:0] wire_prefix``_prdata; \
  logic                         wire_prefix``_pslver; \
  assign if_prefix``.pready  = wire_prefix``_pready; \
  assign if_prefix``.prdata  = wire_prefix``_prdata; \
  assign if_prefix``.pslverr = wire_prefix``_pslverr

`endif
