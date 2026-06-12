@echo off
rem M1 — 순수 SV FIFO TB 컴파일 게이트 (UVM 없음 → --no-uvm)
rem TB 파일을 채울 때마다 아래 목록에 추가한다.
set PYTHONIOENCODING=utf-8
python "%~dp0..\tools\svcheck.py" --no-uvm ^
  "%~dp0rtl\sync_fifo.sv" ^
  "%~dp0tb\fifo_if.sv" ^
  "%~dp0tb\transaction.sv" ^
  "%~dp0tb\generator.sv" ^
  "%~dp0tb\driver.sv" ^
  "%~dp0tb\monitor.sv" ^
  "%~dp0tb\scoreboard.sv" ^
  "%~dp0tb\environment.sv" ^
  "%~dp0tb\fifo_tb_top.sv"
