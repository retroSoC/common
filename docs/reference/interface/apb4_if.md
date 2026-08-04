# apb4_if

| Property | Value |
| --- | --- |
| Kind | `interface` |
| RTL source | [`rtl/interface/apb4_if.sv`](../../../rtl/interface/apb4_if.sv) |
| Availability | SystemVerilog integration API |

## Summary

Clocked APB4 interface with master and slave modports.

## Functional Behavior

Clocked APB4 interface with master and slave modports. It groups protocol signals and constrains endpoint direction with the declared modports; it does not implement protocol state or drive behavior itself.

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
interface apb4_if #(
    parameter int APB_ADDR_WIDTH = 32,
    parameter int APB_DATA_WIDTH = 32
) (
    input logic pclk,
    input logic presetn
);

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
      input pclk,
      input presetn,
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
      input pclk,
      input presetn,
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


### Port Summary

| Signal | Direction | Declaration |
| --- | --- | --- |
| `pclk` | `input` | `input logic pclk` |
| `presetn` | `input` | `input logic presetn` |

## Integration and Use

Connect the correct modport for each role. The connected logic remains responsible for all protocol timing and reset behavior.

```systemverilog
apb4_if #(
    .APB_ADDR_WIDTH(APB_ADDR_WIDTH),
    .APB_DATA_WIDTH(APB_DATA_WIDTH)
) apb4_if_i(.pclk(pclk), .presetn(presetn));
// Example: consumer u_consumer (.bus_i(apb4_if_i.slave));
```

## Dependencies and Verification

The linked RTL source is the implementation authority and contains local assertions for unsupported
parameter combinations. See [`docs/design.md`](../../design.md) for repository-wide CDC, reset,
stream, and storage contracts, and [`docs/verification.md`](../../verification.md) for the
verification matrix.
