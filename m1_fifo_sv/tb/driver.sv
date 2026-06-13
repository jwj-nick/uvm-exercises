//============================================================================
// driver.sv — 트랜잭션을 DUT 핀으로 구동 (clocking block 통해)
//   (UVM의 driver에 해당. M2에서 uvm_driver + seq_item_port로 이주)
//============================================================================
class driver;
  virtual fifo_if vif;
  mailbox #(fifo_txn) gen2drv;

  function new(virtual fifo_if vif, mailbox #(fifo_txn) gen2drv);
    this.vif     = vif;
    this.gen2drv = gen2drv;
  endfunction

  task run();
    // idle 기본값
    vif.cb.wr_en <= 1'b0;
    vif.cb.rd_en <= 1'b0;
    vif.cb.din   <= '0;
    forever begin
      fifo_txn t;
      gen2drv.get(t);                 // mailbox에서 하나 꺼냄
      @(vif.cb);
      if (t.op == fifo_txn::WRITE) begin
        vif.cb.wr_en <= 1'b1;
        vif.cb.din   <= t.data;
        vif.cb.rd_en <= 1'b0;
      end else begin                  // READ
        vif.cb.rd_en <= 1'b1;
        vif.cb.wr_en <= 1'b0;
      end
      @(vif.cb);                      // 1클럭 구동
      vif.cb.wr_en <= 1'b0;
      vif.cb.rd_en <= 1'b0;
    end
  endtask
endclass
