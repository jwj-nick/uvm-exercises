//============================================================================
// environment.sv — 컴포넌트 생성 + mailbox 연결 + 실행
//   (UVM의 env에 해당. M2에서 uvm_env + build/connect_phase로 이주)
//============================================================================
class environment;
  virtual fifo_if vif;
  generator  gen;
  driver     drv;
  monitor    mon;
  scoreboard sb;
  mailbox #(fifo_txn) gen2drv;
  mailbox #(fifo_txn) mon2sb;
  int unsigned num;

  function new(virtual fifo_if vif, int unsigned num = 100);
    this.vif = vif;
    this.num = num;
    gen2drv  = new();              // 컴포넌트 연결용 mailbox
    mon2sb   = new();
    gen = new(gen2drv, num);
    drv = new(vif, gen2drv);
    mon = new(vif, mon2sb);
    sb  = new(mon2sb);
  endfunction

  task run();
    fork                          // driver/monitor/scoreboard는 백그라운드로
      drv.run();
      mon.run();
      sb.run();
    join_none
    gen.run();                    // generator가 num개 다 넣으면 반환
    repeat (20) @(vif.cb);        // drain — 파이프라인에 남은 것 처리 시간
    sb.report();
  endtask
endclass
