# apb4_pure_if

| Property | Value |
| --- | --- |
| Kind | `interface` |
| RTL source | [`rtl/interface/apb4_pure_if.sv`](../../../rtl/interface/apb4_pure_if.sv) |
| Availability | SystemVerilog integration API |

## Summary

Clockless APB4 signal interface with master and slave modports.

## Functional Behavior

Clockless APB4 signal interface with master and slave modports. It groups protocol signals and constrains endpoint direction with the declared modports; it does not implement protocol state or drive behavior itself.

## Suitable Applications

Use to connect compatible SystemVerilog RTL or class-based verification components without duplicating a port bundle.

## Parameters

The declaration below is canonical; retain the RTL-enforced parameter range.

| Parameter | Declaration |
| --- | --- |
| `APB_ADDR_WIDTH` | `parameter int APB_ADDR_WIDTH = 32` |
| `APB_DATA_WIDTH` | `parameter int APB_DATA_WIDTH = 32` |

## Interface Definition

```systemverilog
interface apb4_pure_if #(
    parameter int APB_ADDR_WIDTH = 32,
    parameter int APB_DATA_WIDTH = 32
) ();

  logic [  APB_ADDR_WIDTH-1:0] paddr;
  logic [                 2:0] pprot;
  logic                        psel;
  logic                        penable;
  logic                        pwrite;
  logic [  APB_DATA_WIDTH-1:0] pwdata;
  logic [APB_DATA_WIDTH/8-1:0] pstrb;
  logic                        pready;
  logic [  APB_DATA_WIDTH-1:0] prdata;
  logic                        pslverr;

  modport slave(
      input paddr,
      input pprot,
      input psel,
      input penable,
      input pwrite,
      input pwdata,
      input pstrb,
      output pready,
      output prdata,
      output pslverr
  );

  modport master(
      output paddr,
      output pprot,
      output psel,
      output penable,
      output pwrite,
      output pwdata,
      output pstrb,
      input pready,
      input prdata,
      input pslverr
  );

endinterface
```


## Integration and Use

Connect the correct modport for each role. The connected logic remains responsible for all protocol timing and reset behavior.

```systemverilog
apb4_pure_if #(
    .APB_ADDR_WIDTH(APB_ADDR_WIDTH),
    .APB_DATA_WIDTH(APB_DATA_WIDTH)
) apb4_pure_if_i();
// Example: consumer u_consumer (.bus_i(apb4_pure_if_i.slave));
```

## Dependencies and Verification

The linked RTL source is the implementation authority and contains local assertions for unsupported
parameter combinations. See [`docs/design.md`](../../design.md) for repository-wide CDC, reset,
stream, and storage contracts, and [`docs/verification.md`](../../verification.md) for the
verification matrix.
