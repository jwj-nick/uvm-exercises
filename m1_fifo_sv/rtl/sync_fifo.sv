//============================================================================
// sync_fifo.sv — M1 DUT: parameterized synchronous FIFO
//   NCC 초안 (2026-06-12). Nick 리뷰 대상 — ★DESIGN DECISION 주석 확인 바람.
//============================================================================
module sync_fifo #(
  parameter int WIDTH = 8,
  parameter int DEPTH = 16              // power of 2 권장 (포인터 wrap 단순)
)(
  input  logic             clk,
  input  logic             rst_n,       // ★DECISION A: synchronous, active-low reset
  // write side
  input  logic             wr_en,
  input  logic [WIDTH-1:0] din,
  // read side
  input  logic             rd_en,
  output logic [WIDTH-1:0] dout,
  // status
  output logic             full,
  output logic             empty
);

  localparam int AW = $clog2(DEPTH);

  logic [WIDTH-1:0] mem [DEPTH];
  logic [AW:0]      wr_ptr, rd_ptr;      // MSB 1비트 추가 → full/empty 구분용

  // ★DECISION B: full일 때 write / empty일 때 read = "무시(drop)". (error 아님)
  wire do_wr = wr_en && !full;
  wire do_rd = rd_en && !empty;

  // 포인터 + 메모리 write
  always_ff @(posedge clk) begin
    if (!rst_n) begin
      wr_ptr <= '0;
      rd_ptr <= '0;
    end else begin
      if (do_wr) begin
        mem[wr_ptr[AW-1:0]] <= din;
        wr_ptr <= wr_ptr + 1'b1;
      end
      if (do_rd) begin
        rd_ptr <= rd_ptr + 1'b1;
      end
    end
  end

  // ★DECISION C: "standard synchronous read" — rd_en 친 다음 클럭에 dout 유효 (registered).
  //   (대안: first-word-fall-through(FWFT) = empty 아니면 head가 항상 dout에 보임)
  always_ff @(posedge clk) begin
    if (do_rd) dout <= mem[rd_ptr[AW-1:0]];
  end

  assign full  = (wr_ptr[AW] != rd_ptr[AW]) &&
                 (wr_ptr[AW-1:0] == rd_ptr[AW-1:0]);
  assign empty = (wr_ptr == rd_ptr);

endmodule
