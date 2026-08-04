# component_math_pkg

| Property | Value |
| --- | --- |
| Kind | `package` |
| RTL source | [`rtl/base/component_math_pkg.sv`](../../../rtl/base/component_math_pkg.sv) |
| Availability | SystemVerilog integration API |

## Summary

Compile-time arithmetic helpers for parameterized components.

## Functional Behavior

Compile-time arithmetic helpers for parameterized components. It is a self-contained base primitive with the behavior and parameter checks implemented in the linked RTL source.

## Suitable Applications

Use as a structured building block for control, encoding, ECC, hashing, masking, replacement, or observability logic.

## Parameters

The package declaration below is canonical for exported types, constants, and functions.

## Interface Definition

```systemverilog
package component_math_pkg;
  function automatic int unsigned ceil_divide(input int unsigned numerator,
                                              input int unsigned denominator);
    if (denominator == 0) begin
      $fatal(1, "ceil_divide: denominator must be non-zero");
    end
    return (numerator / denominator) + ((numerator % denominator) != 0);
  endfunction

  function automatic int unsigned index_bits(input int unsigned item_count);
    return (item_count > 1) ? $clog2(item_count) : 1;
  endfunction

  function automatic int unsigned counter_bits(input int unsigned maximum);
    return index_bits(maximum + 1);
  endfunction

  function automatic bit power_of_two(input int unsigned value);
    return (value != 0) && ((value & (value - 1)) == 0);
  endfunction
endpackage
```


## Integration and Use

Honor validity/error outputs and parameter constraints. Combinational cells do not provide timing isolation or CDC protection.

```systemverilog
import component_math_pkg::*;
// Use exported types, constants, or functions here.
```

## Dependencies and Verification

The linked RTL source is the implementation authority and contains local assertions for unsupported
parameter combinations. See [`docs/design.md`](../../design.md) for repository-wide CDC, reset,
stream, and storage contracts, and [`docs/verification.md`](../../verification.md) for the
verification matrix.
