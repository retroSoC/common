# common_cells Coverage

This repository reimplements the active functionality in PULP common_cells
commit `63b7c50d43e462b59506f69d341ff1e40202866d` as self-contained common RTL.
The normative source-to-component table is
`licenses/pulp_common_cells_manifest.tsv`.

`covered` means an existing common component already provides the behavior.
`extended` means an existing family gained the missing behavior. `new` means a
newly named common component provides the capability. Deprecated PULP aliases,
testbench sources, and external technology-cell wrappers are intentionally not
ported: they would violate common's no-external-dependency and no-upstream-name
constraints.

All derived files preserve their original upstream license notice. Run
`make license-check` to verify the manifest, notices, and file headers together.
