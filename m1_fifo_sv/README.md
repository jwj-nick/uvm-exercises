<!-- filename: m1_fifo_sv/README.md · created 2026-06-12 -->
# M1 — sync FIFO + 순수 SystemVerilog TB

> UVM 없이 class 기반 TB를 직접 짜는 단계. M2에서 이걸 UVM으로 이주한다.
> Track C 챕터: https://jwj-nick.github.io/uvm-drill/#/c/lab/m1-fifo-sv

## 파일 구성 (빌드 순서)
| 파일 | 역할 | 누가 |
|---|---|---|
| `rtl/sync_fifo.sv` | DUT (parameterized sync FIFO) | NCC 초안 ✅ → Nick 리뷰 |
| `tb/fifo_if.sv` | interface (DUT 핀 묶음) | NCC 골격 → Nick 리뷰 |
| `tb/transaction.sv` | 트랜잭션 class (op/data) | **Nick 설계** |
| `tb/generator.sv` | 랜덤 생성 → mailbox | Nick (NCC 보조) |
| `tb/driver.sv` | transaction → DUT 핀 구동 | Nick (NCC 보조) |
| `tb/monitor.sv` | DUT 관측 → scoreboard | Nick (NCC 보조) |
| `tb/scoreboard.sv` | 참조 모델(queue)로 비교 | **Nick 설계** |
| `tb/environment.sv` | 컴포넌트 생성 + mailbox 연결 | NCC 골격 → Nick |
| `tb/fifo_tb_top.sv` | clk/rst + 실행 | NCC 골격 |

## 컴파일 게이트
```bat
run.bat        :: svcheck --no-uvm 로 전체 컴파일 (TB 채울 때마다 통과 확인)
```
실행(시뮬)은 Layer 2(Vivado xsim/회사 VCS) 정해지면 추가.

## 설계 결정 (확정 2026-06-12)
- **A. reset:** synchronous, active-low (`rst_n`)
- **B. full/empty 시 write/read:** 무시(drop) — overflow/underflow 에러 안 냄
- **C. read 타이밍:** **FWFT** — !empty면 head가 항상 `dout`에 노출, `rd_en`은 pop만

## 진행
- [x] DUT (sync_fifo.sv, FWFT) — svcheck PASS
- [ ] interface → transaction → generator → driver → monitor → scoreboard → env → top (하나씩, 매번 svcheck)
