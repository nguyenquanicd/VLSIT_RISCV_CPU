#!/bin/bash
# Plan v2 (F1+F2+F3) full regression: builds, RV32/64-bit testbench, negative run, existing suites.
cd /c/HQuan/102_MyGithub/VLSIT_RISCV_CPU/verification/rv32_profile
OUT=../coherence_fix/v2_summary.txt; : > $OUT
R='"tc": "[^"]*".*"verdict": "[A-Z]*", "passed": [0-9]*, "failed": [0-9-]*'
for c in "2 32" "4 32" "2 64" "4 64"; do set -- $c; python run.py build --harts $1 --xlen $2 --jobs 3 > build_fix3_rv$2_$1h.log 2>&1; echo "BUILD rv$2 $1h: $(tail -n1 build_fix3_rv$2_$1h.log)" >> $OUT; done
python run.py build --harts 4 --xlen 64 --base-64 --jobs 3 > build_fix3_base64_4h.log 2>&1; echo "BUILD base64 4h: $(tail -n1 build_fix3_base64_4h.log)" >> $OUT
python run.py run TC-01 TC-02 TC-03 TC-04 TC-05 TC-06 TC-07 TC-08 TC-09 TC-10 --harts 2 2>&1 | grep -o "$R" >> $OUT
python run.py run TC-01 TC-02 TC-03 TC-04 TC-05 TC-06 TC-07 TC-08 TC-09 TC-10 --harts 4 2>&1 | grep -o "$R" >> $OUT
for p in 2 3; do TC07_PART=$p python run.py run TC-07 --harts 4 --tag TC-07_rv32_4h_v2_part$p 2>&1 | grep -o "$R" | sed "s/^/PART$p /" >> $OUT; done
python run.py run TC-04 TC-05 TC-06 TC-07 TC-09 TC-10 --harts 2 --xlen 64 2>&1 | grep -o "$R" >> $OUT
python run.py run TC-04 TC-05 TC-06 TC-07 TC-09 TC-10 --harts 4 --xlen 64 2>&1 | grep -o "$R" >> $OUT
for p in 2 3; do TC07_PART=$p python run.py run TC-07 --harts 4 --xlen 64 --tag TC-07_rv64_4h_v2_part$p 2>&1 | grep -o "$R" | sed "s/^/PART$p /" >> $OUT; done
python run.py run TC-07 --harts 4 --xlen 64 --base-64 --tag TC-07_rv64_4h_v2_base_neg 2>&1 | grep -o "$R" | sed "s/^/BASE-NEG /" >> $OUT
echo "SVA hits:" >> $OUT; for d in runs/TC-0[1-9]_rv32_4h_p0 runs/TC-10_rv32_4h_p0 runs/TC-0[4-7]_rv64_4h_p0 runs/TC-07_rv64_4h_v2_base_neg; do echo "$d $(grep 'A46\|A47' $d/sim.log | awk '{print $1,$2,$3}' | tr '\n' ' ')" >> $OUT; done
cd ../coherence_fix
for h in 2 4; do
  (cd atomic_end_to_end && python run.py --harts $h --case success --jobs 3 > ../v2_atomic_${h}h_success.out 2>&1)
  for c in lrsc_contention amo_fault lr_fault owner_fault; do (cd atomic_end_to_end && python run.py --harts $h --case $c --run-only > ../v2_atomic_${h}h_$c.out 2>&1); done
  (cd cmo_end_to_end && python run.py --harts $h --error 0 --jobs 3 > ../v2_cmo_${h}h_e0.out 2>&1)
  (cd cmo_end_to_end && python run.py --harts $h --error 1 --run-only > ../v2_cmo_${h}h_e1.out 2>&1)
  (cd cmo_end_to_end && python run.py --harts $h --error 0 --load-first --run-only > ../v2_cmo_${h}h_e0_lf.out 2>&1)
  (cd cmo_end_to_end && python run.py --harts $h --error 1 --load-first --run-only > ../v2_cmo_${h}h_e1_lf.out 2>&1)
  (cd fence_i_end_to_end && python run.py --harts $h --error 0 --jobs 3 > ../v2_fence_${h}h_e0.out 2>&1)
  (cd fence_i_end_to_end && python run.py --harts $h --error 1 --run-only > ../v2_fence_${h}h_e1.out 2>&1)
  (cd fence_i_end_to_end && python run.py --harts $h --error 0 --supervisor --run-only > ../v2_fence_${h}h_e0_s.out 2>&1)
  (cd fence_i_end_to_end && python run.py --harts $h --error 1 --supervisor --run-only > ../v2_fence_${h}h_e1_s.out 2>&1)
  (cd directory_holder_end_to_end && python run.py --harts $h --case dirty_eviction --jobs 3 > ../v2_holder_${h}h_dirty.out 2>&1)
  for c in clean_eviction amo_refill_error lr_refill_error; do (cd directory_holder_end_to_end && python run.py --harts $h --case $c --run-only > ../v2_holder_${h}h_$c.out 2>&1); done
done
echo "SUITES:" >> v2_summary.txt; for f in v2_*.out; do echo "$f | $(grep -E 'PASS:|FAIL|Fatal|Error' $f | tail -1 | cut -c1-100)" >> v2_summary.txt; done
echo V2_DONE >> v2_summary.txt
