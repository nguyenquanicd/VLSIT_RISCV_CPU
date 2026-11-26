#!/bin/bash
cd "$(dirname "$0")"
(cd atomic_end_to_end && python run.py --harts 2 --case success --jobs 2 > ../suite_atomic_2h_success.out 2>&1)
for c in lrsc_contention amo_fault lr_fault owner_fault; do (cd atomic_end_to_end && python run.py --harts 2 --case $c --run-only > ../suite_atomic_2h_$c.out 2>&1); done
(cd directory_holder_end_to_end && python run.py --harts 4 --case dirty_eviction --jobs 2 > ../suite_holder_4h_dirty.out 2>&1)
for c in clean_eviction amo_refill_error lr_refill_error; do (cd directory_holder_end_to_end && python run.py --harts 4 --case $c --run-only > ../suite_holder_4h_$c.out 2>&1); done
cd ../rv32_profile
VLSIT_TB_TRACE_DEPTH=99 python run.py build --harts 4 --jobs 3 > build_rv32_4h_t99.log 2>&1
VLSIT_TB_TRACE_DEPTH=99 python run.py run TC-07 --harts 4 --timeout 3000 --tag TC-07_rv32_4h_fix_deep > /dev/null 2>&1
echo REST_DONE
