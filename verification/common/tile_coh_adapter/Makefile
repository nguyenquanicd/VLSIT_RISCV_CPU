VERILATOR ?= C:/Tools/oss-cad-suite/bin/verilator_bin.exe
VERILATOR_ROOT ?= C:/Tools/oss-cad-suite/share/verilator
MAKE ?= C:/Users/PC/Tools/msys64/usr/bin/make.exe
TOP ?= tb_m_vlsit_riscv_tile_coh_adapter
BUILD_DIR ?= C:/HQuan/.test_tmp/riscv_tile_coh_adapter
VERILATOR_CFLAGS ?= -DVL_TIME_CONTEXT
VERILATOR_LDFLAGS ?= -Wl,--defsym,_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC4EOS4_=_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcEEC1EOS4_

.PHONY: lint sim

lint:
	$(VERILATOR) --lint-only --timing -Wall --top-module $(TOP) -f filelist.f

sim:
	powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\build_and_run.ps1 -BuildDir "$(BUILD_DIR)"
