# RTL Style

Use four-space indentation and the checked `.verible-format` configuration.
Ports use direction suffixes (`_i`, `_o`, `_io`), sequential state uses `r_`,
and combinational nets use `s_`. Prefer named module ports for new code.

All branches in combinational logic assign defaults before conditional updates.
Use `always_ff` for state and `always_comb` for combinational functions. New
parameters must be typed and have a documented legal range.
