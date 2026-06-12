//============================================================================
// transaction.sv — FIFO 트랜잭션 (순수 SV class)
//   NCC 초안 (2026-06-12). ★Nick 설계 확인 대상 — 필드/제약이 적절한가?
//============================================================================
class fifo_txn;
  typedef enum { WRITE, READ } op_e;

  rand op_e         op;            // 이번 트랜잭션이 write냐 read냐
  rand bit [7:0]    data;          // WRITE일 때 넣을 값 (READ면 무시)

  // ★DECISION: write/read 비율 — 기본 50:50 (FIFO를 채우고 비우게)
  constraint c_mix { op dist { WRITE := 1, READ := 1 }; }

  function string convert2string();
    return $sformatf("%-5s data=%0h", op.name(), data);
  endfunction
endclass
