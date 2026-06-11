@echo off
rem svcheck — SV/UVM compile gate (pyslang). Usage: svcheck file.sv [...]
set PYTHONIOENCODING=utf-8
python "%~dp0svcheck.py" %*
