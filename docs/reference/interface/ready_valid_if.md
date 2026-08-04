# ready_valid_if

| Property | Value |
| --- | --- |
| Kind | `interface` |
| RTL source | [`rtl/interface/ready_valid_if.sv`](../../../rtl/interface/ready_valid_if.sv) |
| Availability | SystemVerilog integration API |

## Summary

Typed ready/valid interface with source, sink, and monitor modports.

## Functional Behavior

Typed ready/valid interface with source, sink, and monitor modports. It groups protocol signals and constrains endpoint direction with the declared modports; it does not implement protocol state or drive behavior itself.

## Suitable Applications

Use to connect compatible SystemVerilog RTL or class-based verification components without duplicating a port bundle.

## Parameters

The declaration below is canonical; retain the RTL-enforced parameter range.

| Parameter | Declaration |
| --- | --- |
| `DATA_WIDTH` | `parameter int DATA_WIDTH = 32` |

## Interface Definition

```systemverilog
interface ready_valid_if #(
    parameter int DATA_WIDTH = 32
) (
    input logic clk_i
);
  logic [DATA_WIDTH-1:0] data;
  logic                  valid;
  logic                  ready;

  modport source(output data, valid, input ready);
  modport sink(input data, valid, output ready);
  modport monitor(input data, valid, ready);

`ifndef SV_ASSRT_DISABLE
  property stable_while_stalled;
    @(posedge clk_i) valid && !ready |=> valid && $stable(
        data
    );
  endproperty
  assert property (stable_while_stalled)
  else $error("ready_valid_if: source changed data while stalled");
`endif

  initial begin
    if (DATA_WIDTH < 1) $fatal(1, "ready_valid_if: DATA_WIDTH must be positive");
  end
endinterface
```


### Port Summary

| Signal | Direction | Declaration |
| --- | --- | --- |
| `clk_i` | `input` | `input logic clk_i` |

## Integration and Use

Connect the correct modport for each role. The connected logic remains responsible for all protocol timing and reset behavior.

```systemverilog
ready_valid_if #(
    .DATA_WIDTH(DATA_WIDTH)
) ready_valid_if_i(.clk_i(clk_i));
// Example: consumer u_consumer (.bus_i(ready_valid_if_i.slave));
```

## Dependencies and Verification

The linked RTL source is the implementation authority and contains local assertions for unsupported
parameter combinations. See [`docs/design.md`](../../design.md) for repository-wide CDC, reset,
stream, and storage contracts, and [`docs/verification.md`](../../verification.md) for the
verification matrix.
