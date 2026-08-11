# axi4_stream_if

| Property | Value |
| --- | --- |
| Kind | `interface` |
| RTL source | [`rtl/interface/axi4_stream_if.sv`](../../../rtl/interface/axi4_stream_if.sv) |
| Availability | SystemVerilog integration API |

## Summary

Typed AXI4-Stream interface with source, sink, and monitor modports.

## Functional Behavior

Typed AXI4-Stream interface with source, sink, and monitor modports. It groups protocol signals and constrains endpoint direction with the declared modports; it does not implement protocol state or drive behavior itself.

## Suitable Applications

Use to connect compatible SystemVerilog RTL or class-based verification components without duplicating a port bundle.

## Parameters

The declaration below is canonical; retain the RTL-enforced parameter range.

| Parameter | Declaration |
| --- | --- |
| `DATA_WIDTH` | `parameter int DATA_WIDTH = 32` |
| `ID_WIDTH` | `parameter int ID_WIDTH   = 1` |
| `DEST_WIDTH` | `parameter int DEST_WIDTH = 1` |
| `USER_WIDTH` | `parameter int USER_WIDTH = 1` |

## Interface Definition

```systemverilog
interface axi4_stream_if #(
    parameter int DATA_WIDTH = 32,
    parameter int ID_WIDTH   = 1,
    parameter int DEST_WIDTH = 1,
    parameter int USER_WIDTH = 1
) (
    input logic aclk,
    input logic aresetn
);
  localparam int KEEP_WIDTH = DATA_WIDTH / 8;

  logic [DATA_WIDTH-1:0] tdata;
  logic [KEEP_WIDTH-1:0] tkeep;
  logic [KEEP_WIDTH-1:0] tstrb;
  logic                  tlast;
  logic [  ID_WIDTH-1:0] tid;
  logic [DEST_WIDTH-1:0] tdest;
  logic [USER_WIDTH-1:0] tuser;
  logic                  tvalid;
  logic                  tready;

  modport source(
      input aclk,
      input aresetn,
      output tdata,
      output tkeep,
      output tstrb,
      output tlast,
      output tid,
      output tdest,
      output tuser,
      output tvalid,
      input tready
  );

  modport sink(
      input aclk,
      input aresetn,
      input tdata,
      input tkeep,
      input tstrb,
      input tlast,
      input tid,
      input tdest,
      input tuser,
      input tvalid,
      output tready
  );

  modport monitor(
      input aclk,
      input aresetn,
      input tdata,
      input tkeep,
      input tstrb,
      input tlast,
      input tid,
      input tdest,
      input tuser,
      input tvalid,
      input tready
  );

  initial begin
    if (DATA_WIDTH < 8 || (DATA_WIDTH % 8) != 0 || ID_WIDTH < 1 || DEST_WIDTH < 1 ||
        USER_WIDTH < 1) begin
      $fatal(1, "axi4_stream_if: invalid data, ID, destination, or user width");
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
axi4_stream_if #(
    .DATA_WIDTH(DATA_WIDTH),
    .ID_WIDTH(ID_WIDTH),
    .DEST_WIDTH(DEST_WIDTH),
    .USER_WIDTH(USER_WIDTH)
) axi4_stream_if_i(.aclk(aclk), .aresetn(aresetn));
// Example: consumer u_consumer (.bus_i(axi4_stream_if_i.slave));
```

## Dependencies and Verification

The linked RTL source is the implementation authority and contains local assertions for unsupported
parameter combinations. See [`docs/design.md`](../../design.md) for repository-wide CDC, reset,
stream, and storage contracts, and [`docs/verification.md`](../../verification.md) for the
verification matrix.
