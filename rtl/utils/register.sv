// Copyright (c) 2023-2025 Yuchi Miao <miaoyuchi@ict.ac.cn>
// common is licensed under Mulan PSL v2.
// You can use this software according to the terms and conditions of the Mulan PSL v2.
// You may obtain a copy of Mulan PSL v2 at:
//             http://license.coscl.org.cn/MulanPSL2
// THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
// EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
// MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
// See the Mulan PSL v2 for more details.

`include "config.svh"

module dff #(
    parameter int DATA_WIDTH = 1
) (
    input  logic                  clk_i,
    input  logic [DATA_WIDTH-1:0] dat_i,
    output logic [DATA_WIDTH-1:0] dat_o
);

  always_ff @(posedge clk_i) begin
    dat_o <= #`REGISTER_DELAY dat_i;
  end
endmodule

module dffr #(
    parameter int DATA_WIDTH = 1
) (
    input  logic                  clk_i,
    input  logic                  rst_n_i,
    input  logic [DATA_WIDTH-1:0] dat_i,
    output logic [DATA_WIDTH-1:0] dat_o
);

  always_ff @(posedge clk_i, negedge rst_n_i) begin
    if (~rst_n_i) begin
      dat_o <= #`REGISTER_DELAY '0;
    end else begin
      dat_o <= #`REGISTER_DELAY dat_i;
    end
  end
endmodule

module ndffr #(
    parameter int DATA_WIDTH = 1
) (
    input  logic                  clk_i,
    input  logic                  rst_n_i,
    input  logic [DATA_WIDTH-1:0] dat_i,
    output logic [DATA_WIDTH-1:0] dat_o
);

  always_ff @(negedge clk_i, negedge rst_n_i) begin
    if (~rst_n_i) begin
      dat_o <= #`REGISTER_DELAY '0;
    end else begin
      dat_o <= #`REGISTER_DELAY dat_i;
    end
  end
endmodule

module dffrh #(
    parameter int DATA_WIDTH = 1
) (
    input  logic                  clk_i,
    input  logic                  rst_n_i,
    input  logic [DATA_WIDTH-1:0] dat_i,
    output logic [DATA_WIDTH-1:0] dat_o
);

  always_ff @(posedge clk_i, negedge rst_n_i) begin
    if (~rst_n_i) begin
      dat_o <= #`REGISTER_DELAY '1;
    end else begin
      dat_o <= #`REGISTER_DELAY dat_i;
    end
  end
endmodule

module dffrc #(
    parameter int                    DATA_WIDTH = 1,
    parameter logic [DATA_WIDTH-1:0] RESET_VAL  = '0
) (
    input  logic                  clk_i,
    input  logic                  rst_n_i,
    input  logic [DATA_WIDTH-1:0] dat_i,
    output logic [DATA_WIDTH-1:0] dat_o
);

  always_ff @(posedge clk_i, negedge rst_n_i) begin
    if (~rst_n_i) begin
      dat_o <= #`REGISTER_DELAY RESET_VAL;
    end else begin
      dat_o <= #`REGISTER_DELAY dat_i;
    end
  end
endmodule

module dffsr #(
    parameter int DATA_WIDTH = 1
) (
    input  logic                  clk_i,
    input  logic                  rst_n_i,
    input  logic [DATA_WIDTH-1:0] dat_i,
    output logic [DATA_WIDTH-1:0] dat_o
);

  always_ff @(posedge clk_i) begin
    if (~rst_n_i) begin
      dat_o <= #`REGISTER_DELAY '0;
    end else begin
      dat_o <= #`REGISTER_DELAY dat_i;
    end
  end
endmodule

module dffl #(
    parameter int DATA_WIDTH = 1
) (
    input  logic                  clk_i,
    input  logic                  en_i,
    input  logic [DATA_WIDTH-1:0] dat_i,
    output logic [DATA_WIDTH-1:0] dat_o
);

  always_ff @(posedge clk_i) begin
    if (en_i) begin
      dat_o <= #`REGISTER_DELAY dat_i;
    end
  end

`ifndef SV_ASSRT_DISABLE
  xchecker #(
      .DATA_WIDTH(1)
  ) u_xchecker (
      clk_i,
      en_i
  );
`endif

endmodule

module dffer #(
    parameter int DATA_WIDTH = 1
) (
    input  logic                  clk_i,
    input  logic                  rst_n_i,
    input  logic                  en_i,
    input  logic [DATA_WIDTH-1:0] dat_i,
    output logic [DATA_WIDTH-1:0] dat_o
);

  always_ff @(posedge clk_i, negedge rst_n_i) begin
    if (~rst_n_i) begin
      dat_o <= #`REGISTER_DELAY '0;
    end else if (en_i) begin
      dat_o <= #`REGISTER_DELAY dat_i;
    end
  end

`ifndef SV_ASSRT_DISABLE
  xchecker #(
      .DATA_WIDTH(1)
  ) u_xchecker (
      clk_i,
      en_i
  );
`endif

endmodule

module dfferh #(
    parameter int DATA_WIDTH = 1
) (
    input  logic                  clk_i,
    input  logic                  rst_n_i,
    input  logic                  en_i,
    input  logic [DATA_WIDTH-1:0] dat_i,
    output logic [DATA_WIDTH-1:0] dat_o
);

  always_ff @(posedge clk_i, negedge rst_n_i) begin
    if (~rst_n_i) begin
      dat_o <= #`REGISTER_DELAY '1;
    end else if (en_i) begin
      dat_o <= #`REGISTER_DELAY dat_i;
    end
  end

`ifndef SV_ASSRT_DISABLE
  xchecker #(
      .DATA_WIDTH(1)
  ) u_xchecker (
      clk_i,
      en_i
  );
`endif

endmodule

module dfferc #(
    parameter int                    DATA_WIDTH = 1,
    parameter logic [DATA_WIDTH-1:0] RESET_VAL  = '0
) (
    input  logic                  clk_i,
    input  logic                  rst_n_i,
    input  logic                  en_i,
    input  logic [DATA_WIDTH-1:0] dat_i,
    output logic [DATA_WIDTH-1:0] dat_o
);

  always_ff @(posedge clk_i, negedge rst_n_i) begin
    if (~rst_n_i) begin
      dat_o <= #`REGISTER_DELAY RESET_VAL;
    end else if (en_i) begin
      dat_o <= #`REGISTER_DELAY dat_i;
    end
  end

`ifndef SV_ASSRT_DISABLE
  xchecker #(
      .DATA_WIDTH(1)
  ) u_xchecker (
      clk_i,
      en_i
  );
`endif

endmodule

module dffercn #(
    parameter type     REG_TYPE,
    parameter REG_TYPE RESET_VAL = '0
) (
    input  logic    clk_i,
    input  logic    rst_n_i,
    input  logic    en_i,
    input  REG_TYPE dat_i,
    output REG_TYPE dat_o
);

  always_ff @(posedge clk_i, negedge rst_n_i) begin
    if (~rst_n_i) begin
      dat_o <= #`REGISTER_DELAY RESET_VAL;
    end else if (en_i) begin
      dat_o <= #`REGISTER_DELAY dat_i;
    end
  end

`ifndef SV_ASSRT_DISABLE
  xchecker #(
      .DATA_WIDTH(1)
  ) u_xchecker (
      clk_i,
      en_i
  );
`endif

endmodule

module dffesr #(
    parameter int DATA_WIDTH = 1
) (
    input  logic                  clk_i,
    input  logic                  rst_n_i,
    input  logic                  en_i,
    input  logic [DATA_WIDTH-1:0] dat_i,
    output logic [DATA_WIDTH-1:0] dat_o
);

  always_ff @(posedge clk_i) begin
    if (~rst_n_i) begin
      dat_o <= #`REGISTER_DELAY '0;
    end else if (en_i) begin
      dat_o <= #`REGISTER_DELAY dat_i;
    end
  end

`ifndef SV_ASSRT_DISABLE
  xchecker #(
      .DATA_WIDTH(1)
  ) u_xchecker (
      clk_i,
      en_i
  );
`endif

endmodule

module dfferm #(
    parameter int                  DATA_NUM   = 2,
    parameter int                  DATA_WIDTH = 1,
    parameter     [DATA_WIDTH-1:0] INIT_VAL   = '1
) (
    input  logic                  clk_i,
    input  logic                  rst_n_i,
    input  logic [  DATA_NUM-1:0] en_i,
    input  logic [DATA_WIDTH-1:0] dat_i  [0:DATA_NUM-1],
    output logic [DATA_WIDTH-1:0] dat_o  [0:DATA_NUM-1]
);

  for (genvar i = 0; i < DATA_NUM; i++) begin : DFFERM_BLOCK
    if (i == 0) begin: DFFERM_FIRST_BLOCK
      always_ff @(posedge clk_i, negedge rst_n_i) begin
        if (~rst_n_i) begin
          dat_o[i] <= #`REGISTER_DELAY INIT_VAL;
        end else if (en_i[i]) begin
          dat_o[i] <= #`REGISTER_DELAY dat_i[i];
        end
      end
    end else begin: DFFERM_OTHER_BLOCK
      always_ff @(posedge clk_i, negedge rst_n_i) begin
        if (~rst_n_i) begin
          dat_o[i] <= #`REGISTER_DELAY '0;
        end else if (en_i[i]) begin
          dat_o[i] <= #`REGISTER_DELAY dat_i[i];
        end
      end
    end

`ifndef SV_ASSRT_DISABLE
    xchecker #(
        .DATA_WIDTH(1)
    ) u_xchecker (
        clk_i,
        en_i[i]
    );
`endif
  end

endmodule
