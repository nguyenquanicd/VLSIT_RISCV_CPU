#!/bin/bash
# Reruns the existing 64-bit suites (copies) against rtl/coherence_fix/filelist chain. Output: reports/, build/.
cd "$(dirname "$0")"
P=python
for h in 2 4; do
  (cd atomic_end_to_end && $P run.py --harts $h --case success > ../suite_atomic_${h}h_success.out 2>&1)
  for c in lrsc_contention amo_fault lr_fault owner_fault; do (cd atomic_end_to_end && $P run.py --harts $h --case $c --run-only > ../suite_atomic_${h}h_$c.out 2>&1); done
  (cd cmo_end_to_end && $P run.py --harts $h --error 0 > ../suite_cmo_${h}h_e0.out 2>&1)
  (cd cmo_end_to_end && $P run.py --harts $h --error 1 --run-only > ../suite_cmo_${h}h_e1.out 2>&1)
  (cd cmo_end_to_end && $P run.py --harts $h --error 0 --load-first --run-only > ../suite_cmo_${h}h_e0_lf.out 2>&1)
  (cd cmo_end_to_end && $P run.py --harts $h --error 1 --load-first --run-only > ../suite_cmo_${h}h_e1_lf.out 2>&1)
  (cd fence_i_end_to_end && $P run.py --harts $h --error 0 > ../suite_fence_${h}h_e0.out 2>&1)
  (cd fence_i_end_to_end && $P run.py --harts $h --error 1 --run-only > ../suite_fence_${h}h_e1.out 2>&1)
  (cd fence_i_end_to_end && $P run.py --harts $h --error 0 --supervisor --run-only > ../suite_fence_${h}h_e0_s.out 2>&1)
  (cd fence_i_end_to_end && $P run.py --harts $h --error 1 --supervisor --run-only > ../suite_fence_${h}h_e1_s.out 2>&1)
  (cd directory_holder_end_to_end && $P run.py --harts $h --case dirty_eviction > ../suite_holder_${h}h_dirty.out 2>&1)
  for c in clean_eviction amo_refill_error lr_refill_error; do (cd directory_holder_end_to_end && $P run.py --harts $h --case $c --run-only > ../suite_holder_${h}h_$c.out 2>&1); done
done
echo SUITES_DONE
