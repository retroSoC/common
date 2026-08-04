# secded_layout_pkg

| Property | Value |
| --- | --- |
| Kind | `package` |
| RTL source | [`rtl/base/ecc_secded.sv`](../../../rtl/base/ecc_secded.sv) |
| Availability | SystemVerilog integration API |

## Summary

Shared SECDED codeword-layout helpers.

## Functional Behavior

Shared SECDED codeword-layout helpers. It is a self-contained base primitive with the behavior and parameter checks implemented in the linked RTL source.

## Suitable Applications

Use as a structured building block for control, encoding, ECC, hashing, masking, replacement, or observability logic.

## Parameters

The package declaration below is canonical for exported types, constants, and functions.

## Interface Definition

```systemverilog
package secded_layout_pkg;
  function automatic integer check_bits_for(input integer data_width);
    integer check_bits;
    begin
      check_bits = 0;
      while ((1 << check_bits) < (data_width + check_bits + 1)) begin
        check_bits++;
      end
      check_bits_for = check_bits;
    end
  endfunction

  function automatic logic is_check_position(input int position);
    begin
      is_check_position = (position > 0) && ((position & (position - 1)) == 0);
    end
  endfunction
endpackage
```


## Integration and Use

Honor validity/error outputs and parameter constraints. Combinational cells do not provide timing isolation or CDC protection.

```systemverilog
import secded_layout_pkg::*;
// Use exported types, constants, or functions here.
```

## Dependencies and Verification

The linked RTL source is the implementation authority and contains local assertions for unsupported
parameter combinations. See [`docs/design.md`](../../design.md) for repository-wide CDC, reset,
stream, and storage contracts, and [`docs/verification.md`](../../verification.md) for the
verification matrix.
