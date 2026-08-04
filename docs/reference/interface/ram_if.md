# ram_if

| Property | Value |
| --- | --- |
| Kind | `interface` |
| RTL source | [`rtl/interface/ram_if.sv`](../../../rtl/interface/ram_if.sv) |
| Availability | SystemVerilog integration API |

## Summary

Simple RAM request/response interface with master and slave modports.

## Functional Behavior

Simple RAM request/response interface with master and slave modports. It groups protocol signals and constrains endpoint direction with the declared modports; it does not implement protocol state or drive behavior itself.

## Suitable Applications

Use to connect compatible SystemVerilog RTL or class-based verification components without duplicating a port bundle.

## Parameters

This unit has no configurable parameters.

## Interface Definition

```systemverilog
interface ram_if ();
  logic [14:0] addr;
  logic [31:0] wdata;
  logic [ 3:0] wstrb;
  logic [31:0] rdata;

  modport slave(input addr, input wdata, input wstrb, output rdata);
  modport master(output addr, output wdata, output wstrb, input rdata);

endinterface
```


## Integration and Use

Connect the correct modport for each role. The connected logic remains responsible for all protocol timing and reset behavior.

```systemverilog
ram_if ram_if_i();
// Example: consumer u_consumer (.bus_i(ram_if_i.slave));
```

## Dependencies and Verification

The linked RTL source is the implementation authority and contains local assertions for unsupported
parameter combinations. See [`docs/design.md`](../../design.md) for repository-wide CDC, reset,
stream, and storage contracts, and [`docs/verification.md`](../../verification.md) for the
verification matrix.
