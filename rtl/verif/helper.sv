// Copyright (c) 2023-2025 Yuchi Miao <miaoyuchi@ict.ac.cn>
// common is licensed under Mulan PSL v2.
// You can use this software according to the terms and conditions of the Mulan PSL v2.
// You may obtain a copy of Mulan PSL v2 at:
//             http://license.coscl.org.cn/MulanPSL2
// THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
// EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
// MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
// See the Mulan PSL v2 for more details.

class Helper;
  typedef enum {
    NORM  = 0,
    INFO,
    DEBUG,
    WARN,
    ERR
  } log_lev_t;

  typedef enum {
    EQUL,
    NEQU,
    GREA,
    LESS,
    GREQ,
    LESQ
  } cmp_t;

  localparam DATA_WIDTH = 64;
  static string name       = "sv_helper";
  static int    all_num    = 0;
  static int    failed_num = 0;

  static function void start_banner();
    $display("$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$");
    $display("$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$");

    $display("           __                        __                                ______  _______    ");
    $display("          /  |                      /  |                              /      |/       \\  ");
    $display("  _______ $$ | __    __   _______  _$$ |_     ______    ______        $$$$$$/ $$$$$$$  |  ");
    $display(" /       |$$ |/  |  /  | /       |/ $$   |   /      \\  /      \\         $$ |  $$ |__$$ |");
    $display("/$$$$$$$/ $$ |$$ |  $$ |/$$$$$$$/ $$$$$$/   /$$$$$$  |/$$$$$$  |        $$ |  $$    $$/   ");
    $display("$$ |      $$ |$$ |  $$ |$$      \\   $$ | __ $$    $$ |$$ |  $$/         $$ |  $$$$$$$/   ");
    $display("$$ \\_____ $$ |$$ \\__$$ | $$$$$$  |  $$ |/  |$$$$$$$$/ $$ |             _$$ |_ $$ |      ");
    $display("$$       |$$ |$$    $$/ /     $$/   $$  $$/ $$       |$$ |            / $$   |$$ |        ");
    $display(" $$$$$$$/ $$/  $$$$$$/  $$$$$$$/     $$$$/   $$$$$$$/ $$/             $$$$$$/ $$/         ");
    $display("");
    $display("");
    $display("");
  endfunction

  static function void end_banner();
    test_summary();
    $display("$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$");
    $display("$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$");
  endfunction

  static function void test_summary();
    $display("=== [ALL TEST]: %0d [FAILED TEST]: %0d [PASS TEST]: %0d === ", all_num, failed_num,
             all_num - failed_num);
  endfunction

  static task print(input string info, input log_lev_t log_lev = INFO);
    if (log_lev > NORM) begin
      $display("%t [%s] %s", $time, log_lev, info);
    end
  endtask

  static task check(input string name, input bit [DATA_WIDTH-1:0] actual, expected,
                    input cmp_t cmp_type, input log_lev_t log_lev = INFO);
    if (log_lev > NORM) begin
      $display("%t [%s] checking [%15s] type: %s actual: %h, expected: %h", $time, log_lev, name,
               cmp_type, actual, expected);
    end

    all_num++;
    if (cmp_type == EQUL) begin
      if (actual != expected) begin
        failed_num++;
        err_msg(name, actual, expected, cmp_type);
      end
    end else if (cmp_type == NEQU) begin
      if (actual == expected) begin
        failed_num++;
        err_msg(name, actual, expected, cmp_type);
      end
    end else if (cmp_type == GREA) begin
      if (actual <= expected) begin
        failed_num++;
        err_msg(name, actual, expected, cmp_type);
      end
    end else if (cmp_type == LESS) begin
      if (actual >= expected) begin
        failed_num++;
        err_msg(name, actual, expected, cmp_type);
      end
    end else if (cmp_type == GREQ) begin
      if (actual < expected) begin
        failed_num++;
        err_msg(name, actual, expected, cmp_type);
      end
    end else if (cmp_type == LESQ) begin
      if (actual > expected) begin
        failed_num++;
        err_msg(name, actual, expected, cmp_type);
      end
    end
  endtask

  // NOTE: actual hardware encode
  static task check_queue(input string name, input bit [DATA_WIDTH-1:0] actual[$], expected[$],
                          input cmp_t cmp_type, input log_lev_t log_lev = INFO);
    foreach (actual[i]) begin
      check(name, actual[i], expected[i], cmp_type, log_lev);
    end
  endtask

  static task err_msg(input string name, input bit [DATA_WIDTH-1:0] actual, expected,
                      input cmp_t cmp_type);
    $display("%t [ERROR] [%15s] type: %s actual: %h, expected: %h", $time, name, cmp_type, actual,
             expected);
  endtask
endclass
