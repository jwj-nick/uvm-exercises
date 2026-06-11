# uvm-exercises

> 🚧 **Building in public** — 집에서, 상용 EDA 없이 UVM을 실습하기 위한 예제 + 도구 모음.
> [UVM Lab](https://jwj-nick.github.io/uvm-drill/) (markdown 학습 사이트)의 실습 트랙입니다.

## 무엇인가

"집에 시뮬레이터가 없어서 UVM 실습을 못 한다"를 깨기 위한 레포입니다. 검증 작업을 3개 층으로 나눕니다:

| Layer | 도구 | 가능한 것 | 비용 |
|---|---|---|---|
| **1. 컴파일 게이트** | [slang](https://github.com/MikePopoloski/slang)/pyslang (오픈소스) | 문법·타입·elaboration 검사 (1초, UVM 라이브러리 포함) | 무료, `pip install` |
| **2. 시뮬레이션** | Altair DSim Free / Questa Starter | 실행·파형·randomize | 무료 라이선스 |
| 3. (회사/학교) | VCS·Xcelium·Questa | regression·coverage closure | 상용 |

Layer 1만으로도 **"문법적으로 완벽한" UVM 코드를 작성하는 루프**가 돌아갑니다 — 시뮬레이터는 동작 확인 시점에만 필요합니다.

## Quick Start (Layer 1)

```bat
pip install pyslang
git clone https://github.com/accellera-official/uvm-core C:/Nick/80_Toolchain/uvm-core
:: (다른 경로면 UVM_CORE_PATH 환경변수로 지정)

tools\svcheck.bat m0_hello\hello_world.sv
:: → [svcheck] PASS (errors=0, ...)
```

`tools/svcheck.py` = pyslang 기반 컴파일 게이트. Accellera 공식 UVM 소스(uvm-core)와 함께 컴파일해 UVM 코드의 오타·타입 오류·elaboration 에러를 즉시 잡습니다.

## 마일스톤 (예정)

| M | DUT | TB | 상태 |
|---|---|---|---|
| M0 | — | UVM hello world + svcheck 게이트 | ✅ |
| M1 | sync FIFO | 순수 SV class TB (generator/driver/monitor/scoreboard + mailbox) | ⬜ |
| M2 | 동일 FIFO | M1 TB의 UVM 이주 | ⬜ |
| M3 | RLE 인코더 | full UVM env (agent + scoreboard + coverage) | ⬜ |
| M4 | M3 + APB config reg | + RAL | ⬜ |

각 마일스톤의 설계 배경은 [UVM Lab](https://jwj-nick.github.io/uvm-drill/) 챕터들과 연결됩니다.

## 검증 환경 (실측)

- Windows 11 · Python 3.14 · **pyslang 11.0.0** · uvm-core (IEEE 1800.2) — `--single-unit` 옵션으로 PASS
- DSim Free Individual: (라이선스 확보 후 갱신 예정)

## License

MIT (예제 코드). UVM 라이브러리는 [Accellera uvm-core](https://github.com/accellera-official/uvm-core) (Apache-2.0)를 별도로 받아 사용합니다.
