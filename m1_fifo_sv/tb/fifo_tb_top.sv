//============================================================================
// fifo_tb_top.sv — 최상위: clk/rst 생성 + DUT·interface 연결 + env 실행
//   (UVM의 top module + run_test()에 해당. M2에서 run_test로 이주)
//============================================================================
module fifo_tb_top;

  // clock
  bit clk = 1'b0;
  always #5 clk = ~clk;            // 10ns 주기

  // interface
  fifo_if #(.WIDTH(8)) fif (.clk(clk));

  // DUT
  sync_fifo #(.WIDTH(8), .DEPTH(16)) dut (
    .clk   (fif.clk),
    .rst_n (fif.rst_n),
    .wr_en (fif.wr_en),
    .din   (fif.din),
    .rd_en (fif.rd_en),
    .dout  (fif.dout),
    .full  (fif.full),
    .empty (fif.empty)
  );

  environment env;

  initial begin
    // reset (driver가 wr_en/rd_en/din 소유 → 여기선 rst_n만)
    fif.rst_n = 1'b0;
    repeat (2) @(posedge clk);
    fif.rst_n = 1'b1;

    env = new(fif, 100);           // 100 트랜잭션
    env.run();

    $finish;
  end

  // 안전 타임아웃
  initial begin
    #100000;
    $display("[TOP] timeout");
    $finish;
  end

endmodule
