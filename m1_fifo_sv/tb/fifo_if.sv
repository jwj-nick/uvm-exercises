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

  // TB 관점 clocking block — driver는 출력 구동, monitor는 입력 샘플
  clocking cb @(posedge clk);
    default input #1step output #0;
    output rst_n, wr_en, din, rd_en;
    input  dout, full, empty;
  endclocking

  modport tb  (clocking cb);
  modport dut (input  clk, rst_n, wr_en, din, rd_en,
               output dout, full, empty);
endinterface
