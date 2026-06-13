//============================================================================
// fifo_if.sv — DUT 핀을 묶는 interface (+ TB용 clocking block)
//   NCC 골격 (2026-06-12). M2에서 virtual interface로 그대로 재사용된다.
//============================================================================
interface fifo_if #(parameter int WIDTH = 8) (input logic clk);
  logic             rst_n;
  logic             wr_en;
  logic [WIDTH-1:0] din;
  logic             rd_en;
  logic [WIDTH-1:0] dout;
  logic             full;
  logic             empty;

  // driver 관점 clocking — TB가 자극 구동, 상태 샘플
  clocking cb @(posedge clk);
    default input #1step output #0;
    output rst_n, wr_en, din, rd_en;
    input  dout, full, empty;
  endclocking

  // monitor 관점 clocking — 모든 신호를 입력으로 샘플(관측 전용)
  clocking mon_cb @(posedge clk);
    default input #1step;
    input rst_n, wr_en, din, rd_en, dout, full, empty;
  endclocking

  modport tb  (clocking cb);
  modport mon (clocking mon_cb);
  modport dut (input  clk, rst_n, wr_en, din, rd_en,
               output dout, full, empty);
endinterface
