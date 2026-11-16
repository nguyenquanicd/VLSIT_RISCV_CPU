VERILATOR ?= C:/Tools/oss-cad-suite/bin/verilator_bin.exe
VERILATOR_ROOT ?= C:/Tools/oss-cad-suite/share/verilator
MAKE ?= C:/Users/PC/Tools/msys64/usr/bin/make.exe
TOP       ?= tb_m_vlsit_riscv_coh_fabric
BUILD_DIR ?= C:/HQuan/.test_tmp/riscv_coh_fabric
VERILATOR_CFLAGS ?= -DVL_TIME_CONTEXT
VERILATOR_LDFLAGS ?= -Wl,--defsym,_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC4EOS4_=_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC1EOS4_

.PHONY: lint sim

lint:
	$(VERILATOR) --lint-only --timing -Wall --top-module $(TOP) -f filelist.f

sim:
	VERILATOR_ROOT=$(VERILATOR_ROOT) $(VERILATOR) --cc --exe --main --timing -Wall -Wno-fatal --CFLAGS "$(VERILATOR_CFLAGS)" --LDFLAGS "$(VERILATOR_LDFLAGS)" --top-module $(TOP) -f filelist.f --Mdir $(BUILD_DIR)
	$(MAKE) -C $(BUILD_DIR) -f V$(TOP).mk -j 4
	$(BUILD_DIR)/V$(TOP).exe
