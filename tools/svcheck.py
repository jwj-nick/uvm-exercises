#!/usr/bin/env python3
"""svcheck — SV/UVM compile gate using pyslang (slang frontend).

Compiles given SystemVerilog files together with the Accellera UVM library
(uvm-core) and reports syntax/type/elaboration errors with file:line:col,
in ~1s, without a simulator. Layer-1 gate of the UVM home lab.

Usage:
  python svcheck.py file1.sv [file2.sv ...] [--no-uvm] [--warn] [extra slang args]

Options:
  --no-uvm   compile without the UVM library (plain SystemVerilog).
  --warn     enable warnings (default off — a gate cares about ERRORS;
             uvm-core's internal warnings are library noise).

Env:
  UVM_CORE_PATH  path to accellera-official/uvm-core clone
                 (default: C:/Nick/80_Toolchain/uvm-core)

Exit code: 0 = PASS (no errors), 1 = FAIL (errors), 2 = bad usage/setup.
Verified with: pyslang 11.0.0 (slang 11), uvm-core (IEEE 1800.2).
"""
import os
import sys

from pyslang.driver import Driver

UVM_CORE = os.environ.get("UVM_CORE_PATH", r"C:/Nick/80_Toolchain/uvm-core")


def main(argv):
    if not argv:
        print(__doc__)
        return 2

    use_uvm = "--no-uvm" not in argv
    warn = "--warn" in argv
    files = [a for a in argv if a not in ("--no-uvm", "--warn")]

    cmd = ["slang"]
    if use_uvm:
        uvm_src = f"{UVM_CORE}/src"
        if not os.path.isfile(f"{uvm_src}/uvm_pkg.sv"):
            print(f"[svcheck] ERROR: uvm-core not found at {UVM_CORE}")
            print("  set UVM_CORE_PATH, or:")
            print("  git clone https://github.com/accellera-official/uvm-core "
                  f"{UVM_CORE}")
            return 2
        cmd += [f"{uvm_src}/uvm_pkg.sv", "-I", uvm_src]
        # uvm-core는 라이브러리 — 그 안의 경고는 억제(Nick이 못 고치는 코드)
        cmd += ["--suppress-warnings", UVM_CORE]
    cmd += files
    cmd += ["--single-unit"]   # 게이트 용도: 전체를 단일 compilation unit으로
    if not warn:
        cmd += ["-Wnone"]      # 기본: 에러만. --warn으로 켜기

    driver = Driver()
    driver.addStandardArgs()
    line = " ".join(f'"{c}"' if (" " in c) else c for c in cmd)
    if not driver.parseCommandLine(line):
        print("[svcheck] FAIL (bad command line)")
        return 1
    if not driver.processOptions():
        return 2
    parsed = driver.parseAllSources()

    compilation = driver.createCompilation()
    driver.reportCompilation(compilation, quiet=True)   # quiet=True: top-unit 목록 생략
    # 진단 텍스트(에러/경고의 file:line:col)를 사람이 보게 출력
    diag = driver.textDiagClient.getString()
    if diag.strip():
        print(diag.rstrip())

    errs = driver.diagEngine.numErrors
    warns = driver.diagEngine.numWarnings
    ok = parsed and errs == 0
    print(f"[svcheck] {'PASS' if ok else 'FAIL'} (errors={errs}, warnings={warns})")
    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
