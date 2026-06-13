//============================================================================
// generator.sv — 랜덤 트랜잭션 생성 → mailbox로 전달
//   (UVM의 sequence에 해당. M2에서 uvm_sequence로 이주)
//============================================================================
class generator;
  mailbox #(fifo_txn) gen2drv;
  int unsigned num;

  function new(mailbox #(fifo_txn) gen2drv, int unsigned num = 100);
    this.gen2drv = gen2drv;
    this.num     = num;
  endfunction

  task run();
    repeat (num) begin
      fifo_txn t = new();
      if (!t.randomize())
        $error("[GEN] randomize 실패");
      gen2drv.put(t);          // mailbox에 넣음 (driver가 가져감)
    end
  endtask
endclass
