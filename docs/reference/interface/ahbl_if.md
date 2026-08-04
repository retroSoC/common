# ahbl_if

| Property | Value |
| --- | --- |
| Kind | `interface` |
| RTL source | [`rtl/interface/ahbl_if.sv`](../../../rtl/interface/ahbl_if.sv) |
| Availability | SystemVerilog integration API |

## Summary

Typed AHB-Lite interface with master and slave modports.

## Functional Behavior

Typed AHB-Lite interface with master and slave modports. It groups protocol signals and constrains endpoint direction with the declared modports; it does not implement protocol state or drive behavior itself.

## Suitable Applications

Use to connect compatible SystemVerilog RTL or class-based verification components without duplicating a port bundle.

## Parameters

This unit has no configurable parameters.

## Interface Definition

```systemverilog
interface ahbl_if (
    input logic hclk,
    input logic hresetn
);

  logic [31:0] haddr;
  logic        hwrite;
  logic [ 2:0] hsize;
  logic [ 2:0] hburst;
  logic [ 3:0] hprot;
  logic [ 1:0] htrans;
  logic        hmastlock;
  logic [31:0] hwdata;
  logic        hready;
  logic        hresp;
  logic [31:0] hrdata;

  modport slave(
      input hclk,
      input hresetn,

      input haddr,
      input hwrite,
      input hsize,
      input hburst,
      input hprot,
      input htrans,
      input hmastlock,
      input hwdata,
      output hready,
      output hresp,
      output hrdata
  );

  modport master(
      input hclk,
      input hresetn,

      output haddr,
      output hwrite,
      output hsize,
      output hburst,
      output hprot,
      output htrans,
      output hmastlock,
      output hwdata,
      input hready,
      input hresp,
      input hrdata
  );

endinterface
```


### Port Summary

| Signal | Direction | Declaration |
| --- | --- | --- |
| `hclk` | `input` | `input logic hclk` |
| `hresetn` | `input` | `input logic hresetn` |

## Integration and Use

Connect the correct modport for each role. The connected logic remains responsible for all protocol timing and reset behavior.

```systemverilog
ahbl_if ahbl_if_i(.hclk(hclk), .hresetn(hresetn));
// Example: consumer u_consumer (.bus_i(ahbl_if_i.slave));
```

## Dependencies and Verification

The linked RTL source is the implementation authority and contains local assertions for unsupported
parameter combinations. See [`docs/design.md`](../../design.md) for repository-wide CDC, reset,
stream, and storage contracts, and [`docs/verification.md`](../../verification.md) for the
verification matrix.
