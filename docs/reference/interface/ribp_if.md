# ribp_if

| Property | Value |
| --- | --- |
| Kind | `interface` |
| RTL source | [`rtl/interface/ribp_if.sv`](../../../rtl/interface/ribp_if.sv) |
| Availability | SystemVerilog integration API |

## Summary

RIBP request/response interface with response-error signaling.

## Functional Behavior

RIBP request/response interface with response-error signaling. It groups protocol signals and constrains endpoint direction with the declared modports; it does not implement protocol state or drive behavior itself.

## Suitable Applications

Use to connect compatible SystemVerilog RTL or class-based verification components without duplicating a port bundle.

## Parameters

This unit has no configurable parameters.

## Interface Definition

```systemverilog
interface ribp_if ();
  logic        valid;
  logic [31:0] addr;
  logic [31:0] wdata;
  logic [ 3:0] wstrb;
  logic [31:0] rdata;
  logic        ready;
  logic        resp_err;

  modport slave(
      input valid,
      input addr,
      input wdata,
      input wstrb,
      output rdata,
      output ready,
      output resp_err
  );
  modport master(
      output valid,
      output addr,
      output wdata,
      output wstrb,
      input rdata,
      input ready,
      input resp_err
  );

endinterface
```


## Integration and Use

Connect the correct modport for each role. The connected logic remains responsible for all protocol timing and reset behavior.

```systemverilog
ribp_if ribp_if_i();
// Example: consumer u_consumer (.bus_i(ribp_if_i.slave));
```

## Dependencies and Verification

The linked RTL source is the implementation authority and contains local assertions for unsupported
parameter combinations. See [`docs/design.md`](../../design.md) for repository-wide CDC, reset,
stream, and storage contracts, and [`docs/verification.md`](../../verification.md) for the
verification matrix.
