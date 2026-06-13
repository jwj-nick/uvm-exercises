//============================================================================
// scoreboard.sv — 참조 모델(queue)로 기대값 계산·비교
//   FIFO의 골든 모델 = SV queue. write→push_back, read→pop_front 후 dout과 비교.
//   (UVM의 scoreboard + analysis_export에 해당. ★M3에서 Nick이 직접 설계할 패턴)
//============================================================================
class scoreboard;
  mailbox #(fifo_txn) mon2sb;
  bit [7:0]    ref_q[$];          // 참조 FIFO 모델
  int unsigned passed, failed;

  function new(mailbox #(fifo_txn) mon2sb);
    this.mon2sb = mon2sb;
  endfunction

  task run();
    forever begin
      fifo_txn m;
      mon2sb.get(m);
      if (m.op == fifo_txn::WRITE) begin
        ref_q.push_back(m.data);             // 모델에 push
      end else begin                          // READ
        if (ref_q.size() == 0) begin
          $error("[SB] read 관측됐는데 참조모델이 비어있음");
          failed++;
        end else begin
          bit [7:0] exp = ref_q.pop_front();  // 모델에서 pop = 기대값
          if (exp === m.data) passed++;
          else begin
            $error("[SB] mismatch exp=%0h got=%0h", exp, m.data);
            failed++;
          end
        end
      end
    end
  endtask

  function void report();
    $display("[SB] passed=%0d failed=%0d ref_remaining=%0d",
             passed, failed, ref_q.size());
    if (failed == 0) $display("[SB] *** M1 SELF-CHECK PASS ***");
  endfunction
endclass
