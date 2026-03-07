// Copyright (c) 2023-2026 Yuchi Miao <miaoyuchi@ict.ac.cn>
// common is licensed under Mulan PSL v2.
// You can use this software according to the terms and conditions of the Mulan PSL v2.
// You may obtain a copy of Mulan PSL v2 at:
//             http://license.coscl.org.cn/MulanPSL2
// THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
// EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
// MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
// See the Mulan PSL v2 for more details.

// this file only include digital IO's behavioral model, for ASIC tape-out need to reimplement those models
// oen_i: high active
module tri_pdu_pad_h (
    input  logic i_i,
    input  logic oen_i,
    input  logic ren_i,
    output logic c_o,
    inout  wire  pad_io
);

`ifdef TRI_PDU_PAD_H_BACKEND
  $error("need to instantiate specific technology cell in this block and remove this statement");
`else
  assign pad_io = oen_i ? i_i : 1'bz;
  assign c_o    = pad_io;
`endif

endmodule

module tri_pdu_pad_v (
    input  logic i_i,
    input  logic oen_i,
    input  logic ren_i,
    output logic c_o,
    inout  wire  pad_io
);

`ifdef TRI_PDU_PAD_V_BACKEND
  $error("need to instantiate specific technology cell in this block and remove this statement");
`else
  assign pad_io = oen_i ? i_i : 1'bz;
  assign c_o    = pad_io;
`endif

endmodule

module tri_pd_pad_h (
    input  logic i_i,
    input  logic oen_i,
    input  logic ren_i,
    output logic c_o,
    inout  wire  pad_io
);

`ifdef TRI_PD_PAD_H_BACKEND
  $error("need to instantiate specific technology cell in this block and remove this statement");
`else
  assign pad_io = oen_i ? i_i : 1'bz;
  assign c_o    = pad_io;
`endif

endmodule

module tri_pd_pad_v (
    input  logic i_i,
    input  logic oen_i,
    input  logic ren_i,
    output logic c_o,
    inout  wire  pad_io
);

`ifdef TRI_PD_PAD_V_BACKEND
  $error("need to instantiate specific technology cell in this block and remove this statement");
`else
  assign pad_io = oen_i ? i_i : 1'bz;
  assign c_o    = pad_io;
`endif

endmodule

module tri_pu_pad_h (
    input  logic i_i,
    input  logic oen_i,
    input  logic ren_i,
    output logic c_o,
    inout  wire  pad_io
);

`ifdef TRI_PU_PAD_H_BACKEND
  $error("need to instantiate specific technology cell in this block and remove this statement");
`else
  assign pad_io = oen_i ? i_i : 1'bz;
  assign c_o    = pad_io;
`endif

endmodule

module tri_pu_pad_v (
    input  logic i_i,
    input  logic oen_i,
    input  logic ren_i,
    output logic c_o,
    inout  wire  pad_io
);

`ifdef TRI_PU_PAD_V_BACKEND
  $error("need to instantiate specific technology cell in this block and remove this statement");
`else
  assign pad_io = oen_i ? i_i : 1'bz;
  assign c_o    = pad_io;
`endif

endmodule

module osc_pad_h (
    input  logic ds0_i,   // driver strength
    input  logic ds1_i,   // driver strength
    input  logic en_i,
    input  logic xin_i,
    output logic xout_o,
    output logic xc_o
);

`ifdef OSC_PAD_H_BACKEND
  $error("need to instantiate specific technology cell in this block and remove this statement");
`else
  assign xout_o = en_i ? xin_i : 1'b0;
  assign xc_o   = en_i ? xin_i : 1'b0;
`endif

endmodule

module osc_pad_v (
    input  logic ds0_i,   // driver strength
    input  logic ds1_i,   // driver strength
    input  logic en_i,
    input  logic xin_i,
    output logic xout_o,
    output logic xc_o
);

`ifdef OSC_PAD_V_BACKEND
  $error("need to instantiate specific technology cell in this block and remove this statement");
`else
  assign xout_o = en_i ? xin_i : 1'b0;
  assign xc_o   = en_i ? xin_i : 1'b0;
`endif

endmodule
