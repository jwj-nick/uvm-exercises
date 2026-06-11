#!/usr/bin/env python3
"""svcheck — SV/UVM compile gate using pyslang (slang frontend).

Compiles given SystemVerilog files together with the Accellera UVM library
(uvm-core) and reports syntax/type/elaboration errors in ~1s, without a
simulator. Layer-1 gate of the UVM home lab.

Usage:
  python svcheck.py file1.sv [file2.sv ...] [--no-uvm] [extra slang args]

Env:
  UVM_CORE_PATH  path to accellera-official/uvm-core clone
                 (default: C:/Nick/80_Toolchain/uvm-core)

Verified with: pyslang 11.0.0 (slang 11), uvm-core 2020.3.1+ (1800.2)
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
    args = [a for a in argv if a != "--no-uvm"]

    cmd = ["slang"]
    if use_uvm:
        uvm_src = f"{UVM_CORE}/src"
        if not os.path.isfile(f"{uvm_src}/uvm_pkg.sv"):
            print(f"[svcheck] ERROR: uvm-core not found at {UVM_CORE}")
            print("  git clone https://github.com/accellera-official/uvm-core "
                  f"{UVM_CORE}")
            return 2
        cmd += [f"{uvm_src}/uvm_pkg.sv", "-I", uvm_src]
    cmd += args
    # 컴파일 게이트 용도 — 전체를 단일 compilation unit으로
    cmd += ["--single-unit"]

    driver = Driver()
    driver.addStandardArgs()
    if not driver.parseCommandLine(
            " ".join(f'"{c}"' if " " in c else c for c in cmd)):
        return 1
    if not driver.processOptions():
        return 1
    if not driver.parseAllSources():
        print("[svcheck] FAIL (parse errors)")
        return 1

    compilation = driver.createCompilation()
    driver.reportCompilation(compilation, quiet=False)
    errs = driver.diagEngine.numErrors
    print(f"[svcheck] {'PASS' if errs == 0 else 'FAIL'} "
          f"(errors={errs}, warnings={driver.diagEngine.numWarnings})")
    return 0 if errs == 0 else 1


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
