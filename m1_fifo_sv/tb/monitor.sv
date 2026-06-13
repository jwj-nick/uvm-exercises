//============================================================================
// monitor.sv — DUT 관측 → scoreboard로 전달
//   FWFT: read가 수락되면 같은 사이클 dout=head가 유효.
//   "실제 수락된"(full/empty로 drop 안 된) 트랜잭션만 관측한다.
//   (UVM의 monitor + analysis_port에 해당)
//============================================================================
class monitor;
  virtual fifo_if vif;
  mailbox #(fifo_txn) mon2sb;

  function new(virtual fifo_if vif, mailbox #(fifo_txn) mon2sb);
    this.vif    = vif;
    this.mon2sb = mon2sb;
  endfunction

  task run();
    forever begin
      @(vif.mon_cb);
      // 실제 수락된 write (full이면 drop → 관측 안 함)
      if (vif.mon_cb.wr_en && !vif.mon_cb.full) begin
        fifo_txn t = new();
        t.op   = fifo_txn::WRITE;
        t.data = vif.mon_cb.din;
        mon2sb.put(t);
      end
      // 실제 수락된 read (empty면 drop) — FWFT라 head가 dout에 보임
      if (vif.mon_cb.rd_en && !vif.mon_cb.empty) begin
        fifo_txn t = new();
        t.op   = fifo_txn::READ;
        t.data = vif.mon_cb.dout;     // 관측된 출력값
        mon2sb.put(t);
      end
    end
  endtask
endclass
