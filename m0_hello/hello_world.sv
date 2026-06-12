//============================================================================
// hello_world.sv — UVM "Hello World" (입문자용 line-by-line 주석)
//----------------------------------------------------------------------------
// 목적: ① svcheck 컴파일 게이트의 동작 확인용 예제
//       ② DSim 시뮬레이터가 오면 실제로 돌려 "UVM_INFO ... Hello UVM" 출력 확인
// Nick은 Verilog 20년이지만 UVM은 처음 → UVM 고유 구문에 집중해 설명한다.
// (RTL 상식인 module/initial/#10ns 등은 설명 생략)
//============================================================================

// [A] UVM 매크로 정의를 가져온다.
//   `uvm_component_utils(...)` 같은 매크로(`로 시작하는 것)들의 "정의"가 이 파일에 있다.
//   매크로는 컴파일 전(preprocess) 단계에서 펼쳐지므로, import가 아니라 `include로 넣는다.
//   (uvm_macros.svh 의 위치는 svcheck가 -I 옵션으로 알려준다 → uvm-core/src)
`include "uvm_macros.svh"

// [B] 최상위 module. 시뮬레이터가 실행을 시작하는 진입점(top).
//   UVM 테스트도 결국 어떤 module 안에서 출발한다 — 이게 그 껍데기다.
module hello_top;

  // [C] UVM 라이브러리의 모든 class/타입(uvm_test, uvm_info 등)을 이 스코프로 가져온다.
  //   UVM은 uvm_pkg 라는 package 안에 들어 있다 → import 해야 uvm_test 등을 이름만으로 쓴다.
  //   ([A]의 `include 는 "매크로", [C]의 import 는 "class/타입" — 둘 다 필요하고 역할이 다르다.)
  import uvm_pkg::*;

  //--------------------------------------------------------------------------
  // [D] 나의 첫 UVM 테스트 class.
  //   - `extends uvm_test` : UVM이 정한 "테스트" 베이스 클래스를 상속.
  //     uvm_test를 상속해야 run_test()가 이 클래스를 테스트로 인식·실행한다.
  //   (실무에선 보통 test class를 package나 별도 파일에 두지만, hello에선 단순하게 module 안에 둔다.)
  //--------------------------------------------------------------------------
  class hello_test extends uvm_test;

    // [E] ★factory 등록 매크로. UVM에서 가장 중요한 한 줄 중 하나.
    //   이 매크로가 hello_test를 UVM "factory"에 등록해 →
    //     ① 이름/타입으로 객체를 생성할 수 있게 하고(`type_id::create`)
    //     ② 나중에 다른 테스트로 교체(override)할 수 있게 한다.
    //   component(시뮬 내내 사는 구조물)는 _component_utils, 데이터는 _object_utils 를 쓴다.
    //   ※ 이 줄을 빠뜨리면 +UVM_TESTNAME=hello_test 로 이 테스트를 못 찾는다.
    `uvm_component_utils(hello_test)

    // [F] 생성자(constructor). UVM component의 new는 시그니처가 고정이다:
    //   (string name, uvm_component parent)
    //   - name   : 이 객체의 이름(로그·계층 경로에 쓰임)
    //   - parent : UVM 계층 트리에서의 부모. test는 최상위라 parent=null 기본값.
    //   super.new(...) 로 부모(uvm_test)의 생성자를 먼저 호출해야 한다.
    function new(string name = "hello_test", uvm_component parent = null);
      super.new(name, parent);
    endfunction

    // [G] ★run_phase — 실제로 "시간이 흐르는" 동안 할 일을 적는 곳.
    //   UVM은 실행을 여러 phase(build→connect→...→run→...)로 나누는데,
    //   run_phase 만이 task(시간 소비 가능)이고 나머지는 function(0 time)이다.
    //   UVM이 정해진 순서에 맞춰 이 메서드를 "불러준다"(내가 호출하지 않는다).
    task run_phase(uvm_phase phase);

      // [G-1] ★objection 들기(raise). "아직 테스트 끝내지 마세요" 신호.
      //   UVM은 살아있는 objection이 하나도 없으면 run_phase를 즉시 끝내버린다.
      //   → raise를 안 하면 아래 #10ns 도 못 가보고 테스트가 0초에 끝난다.
      phase.raise_objection(this, "hello");

      // [G-2] 로그 출력. $display 대신 UVM 매크로를 쓴다.
      //   인자: (메시지ID, 메시지내용, verbosity레벨)
      //   - "HELLO"   : 메시지 ID(필터·grep 단위)
      //   - UVM_LOW   : 중요도. 낮을수록 "거의 항상 보임"(=중요). 기본 임계값에서도 출력됨.
      //   출력 형태:  UVM_INFO hello_world.sv(line) @ 0: ... [HELLO] Hello UVM from the home lab!
      `uvm_info("HELLO", "Hello UVM from the home lab!", UVM_LOW)

      // [G-3] 시간을 10ns 흘린다(시뮬레이터에서만 의미. 컴파일 게이트는 시간 안 봄).
      //   "run_phase가 시간을 소비하는 task"임을 보여주는 최소 동작.
      #10ns;

      // [G-4] ★objection 내리기(drop). "내 할 일 끝났어요."
      //   모든 objection이 drop되면 run_phase가 종료된다. raise/drop은 반드시 짝.
      //   (drop을 빠뜨리면 테스트가 영원히 안 끝나 timeout으로만 죽는다.)
      phase.drop_objection(this, "hello done");

    endtask

  endclass

  // [H] ★시뮬레이션 시작점. UVM 전체를 가동하는 단 한 줄.
  //   run_test("hello_test") 가 하는 일:
  //     ① factory에서 "hello_test" 타입을 찾아 객체 생성
  //     ② UVM 계층의 최상위(uvm_top) 아래에 붙임
  //     ③ phase 머신을 돌려 build→...→run_phase→...→final 순서로 실행
  //   인자로 이름을 주는 대신 명령행 +UVM_TESTNAME=hello_test 로도 선택할 수 있다.
  initial run_test("hello_test");

endmodule
