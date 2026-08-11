# axi4_if

| Property | Value |
| --- | --- |
| Kind | `interface` |
| RTL source | [`rtl/interface/axi4_if.sv`](../../../rtl/interface/axi4_if.sv) |
| Availability | SystemVerilog integration API |

## Summary

Typed AXI4 interface with master and slave modports.

## Functional Behavior

Typed AXI4 interface with master and slave modports. It groups protocol signals and constrains endpoint direction with the declared modports; it does not implement protocol state or drive behavior itself.

## Suitable Applications

Use to connect compatible SystemVerilog RTL or class-based verification components without duplicating a port bundle.

## Parameters

The declaration below is canonical; retain the RTL-enforced parameter range.

| Parameter | Declaration |
| --- | --- |
| `ADDR_WIDTH` | `parameter int ADDR_WIDTH = `AXI4_ADDR_WIDTH` |
| `DATA_WIDTH` | `parameter int DATA_WIDTH = `AXI4_DATA_WIDTH` |
| `ID_WIDTH` | `parameter int ID_WIDTH   = `AXI4_ID_WIDTH` |
| `USER_WIDTH` | `parameter int USER_WIDTH = `AXI4_USER_WIDTH` |

## Interface Definition

```systemverilog
interface axi4_if #(
    parameter int ADDR_WIDTH = `AXI4_ADDR_WIDTH,
    parameter int DATA_WIDTH = `AXI4_DATA_WIDTH,
    parameter int ID_WIDTH   = `AXI4_ID_WIDTH,
    parameter int USER_WIDTH = `AXI4_USER_WIDTH
) (
    input logic aclk,
    input logic aresetn
);
  localparam int STRB_WIDTH = DATA_WIDTH / 8;

  logic [  ID_WIDTH-1:0] awid;
  logic [ADDR_WIDTH-1:0] awaddr;
  logic [           7:0] awlen;
  logic [           2:0] awsize;
  logic [           1:0] awburst;
  logic                  awlock;
  logic [           3:0] awcache;
  logic [           2:0] awprot;
  logic [           3:0] awqos;
  logic [           3:0] awregion;
  logic [USER_WIDTH-1:0] awuser;
  logic                  awvalid;
  logic                  awready;

  logic [DATA_WIDTH-1:0] wdata;
  logic [STRB_WIDTH-1:0] wstrb;
  logic                  wlast;
  logic [USER_WIDTH-1:0] wuser;
  logic                  wvalid;
  logic                  wready;

  logic [  ID_WIDTH-1:0] bid;
  logic [           1:0] bresp;
  logic [USER_WIDTH-1:0] buser;
  logic                  bvalid;
  logic                  bready;

  logic [  ID_WIDTH-1:0] arid;
  logic [ADDR_WIDTH-1:0] araddr;
  logic [           7:0] arlen;
  logic [           2:0] arsize;
  logic [           1:0] arburst;
  logic                  arlock;
  logic [           3:0] arcache;
  logic [           2:0] arprot;
  logic [           3:0] arqos;
  logic [           3:0] arregion;
  logic [USER_WIDTH-1:0] aruser;
  logic                  arvalid;
  logic                  arready;

  logic [  ID_WIDTH-1:0] rid;
  logic [DATA_WIDTH-1:0] rdata;
  logic [           1:0] rresp;
  logic                  rlast;
  logic [USER_WIDTH-1:0] ruser;
  logic                  rvalid;
  logic                  rready;

  modport slave(
      input aclk,
      input aresetn,

      input awid,
      input awaddr,
      input awlen,
      input awsize,
      input awburst,
      input awlock,
      input awcache,
      input awprot,
      input awqos,
      input awregion,
      input awuser,
      input awvalid,
      output awready,

      input wdata,
      input wstrb,
      input wlast,
      input wuser,
      input wvalid,
      output wready,

      output bid,
      output bresp,
      output buser,
      output bvalid,
      input bready,

      input arid,
      input araddr,
      input arlen,
      input arsize,
      input arburst,
      input arlock,
      input arcache,
      input arprot,
      input arqos,
      input arregion,
      input aruser,
      input arvalid,
      output arready,

      output rid,
      output rdata,
      output rresp,
      output rlast,
      output ruser,
      output rvalid,
      input rready
  );

  modport master(
      input aclk,
      input aresetn,

      output awid,
      output awaddr,
      output awlen,
      output awsize,
      output awburst,
      output awlock,
      output awcache,
      output awprot,
      output awqos,
      output awregion,
      output awuser,
      output awvalid,
      input awready,

      output wdata,
      output wstrb,
      output wlast,
      output wuser,
      output wvalid,
      input wready,

      input bid,
      input bresp,
      input buser,
      input bvalid,
      output bready,

      output arid,
      output araddr,
      output arlen,
      output arsize,
      output arburst,
      output arlock,
      output arcache,
      output arprot,
      output arqos,
      output arregion,
      output aruser,
      output arvalid,
      input arready,

      input rid,
      input rdata,
      input rresp,
      input rlast,
      input ruser,
      input rvalid,
      output rready
  );

  initial begin
    if (ADDR_WIDTH < 1 || DATA_WIDTH < 8 || (DATA_WIDTH % 8) != 0 || ID_WIDTH < 1 ||
        USER_WIDTH < 1) begin
      $fatal(1, "axi4_if: invalid address, data, ID, or user width");
    end
  end

endinterface
```


### Port Summary

| Signal | Direction | Declaration |
| --- | --- | --- |
| `aclk` | `input` | `input logic aclk` |
| `aresetn` | `input` | `input logic aresetn` |

## Integration and Use

Connect the correct modport for each role. The connected logic remains responsible for all protocol timing and reset behavior.

```systemverilog
axi4_if #(
    .ADDR_WIDTH(ADDR_WIDTH),
    .DATA_WIDTH(DATA_WIDTH),
    .ID_WIDTH(ID_WIDTH),
    .USER_WIDTH(USER_WIDTH)
) axi4_if_i(.aclk(aclk), .aresetn(aresetn));
// Example: consumer u_consumer (.bus_i(axi4_if_i.slave));
```

## Dependencies and Verification

The linked RTL source is the implementation authority and contains local assertions for unsupported
parameter combinations. See [`docs/design.md`](../../design.md) for repository-wide CDC, reset,
stream, and storage contracts, and [`docs/verification.md`](../../verification.md) for the
verification matrix.
