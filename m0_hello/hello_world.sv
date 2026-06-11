// M0 — UVM hello world: 컴파일 게이트(svcheck) + 시뮬레이터 smoke test 겸용
`include "uvm_macros.svh"

module hello_top;
  import uvm_pkg::*;

  class hello_test extends uvm_test;
    `uvm_component_utils(hello_test)

    function new(string name = "hello_test", uvm_component parent = null);
      super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
      phase.raise_objection(this, "hello");
      `uvm_info("HELLO", "Hello UVM from the home lab!", UVM_LOW)
      #10ns;
      phase.drop_objection(this, "hello done");
    endtask
  endclass

  initial run_test("hello_test");
endmodule
