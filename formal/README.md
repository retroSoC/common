# Formal Checks

The formal targets use SymbiYosys prove mode with open-source Yosys and
Bitwuzla. They cover queue bounds and arbiter one-hot/fair-progress safety
invariants. Run all checked targets with `make formal`.

Formal checks complement, rather than replace, the asynchronous simulation
tests. CDC metastability itself is not digitally provable and remains a
structural-review concern.
