# Validation / Kiem chung

| Test | Result | Cycles | Evidence |
|---|---|---:|---|
| A-06 CPU 2h l1 B=2 | PASS | 5222 | [log](../../../rtl/reports/fault_record_a06/simulation_2h_l1_error2.log) |
| A-06 CPU 2h l1 B=3 | PASS | 5222 | [log](../../../rtl/reports/fault_record_a06/simulation_2h_l1_error3.log) |
| A-06 CPU 2h llc B=2 | PASS | 1382 | [log](../../../rtl/reports/fault_record_a06/simulation_2h_llc_error2.log) |
| A-06 CPU 2h llc B=3 | PASS | 1382 | [log](../../../rtl/reports/fault_record_a06/simulation_2h_llc_error3.log) |
| A-06 CPU 2h highest-hart-first B response | PASS | 5290 | [log](../../../rtl/reports/fault_record_a06/simulation_2h_l1_error2_reverse.log) |
| A-05 CPU 2h dirty_eviction | PASS | 2398 | [log](../../../rtl/reports/ccu_victim_escape/simulation_2h_2slots_dirty_eviction.log) |
| A-05 CPU 2h clean_eviction | PASS | 2186 | [log](../../../rtl/reports/ccu_victim_escape/simulation_2h_2slots_clean_eviction.log) |
| A-05 CPU 2h amo_refill_error | PASS | 1797 | [log](../../../rtl/reports/ccu_victim_escape/simulation_2h_2slots_amo_refill_error.log) |
| A-05 CPU 2h lr_refill_error | PASS | 1797 | [log](../../../rtl/reports/ccu_victim_escape/simulation_2h_2slots_lr_refill_error.log) |
| A-04 CPU 2h dirty_eviction | PASS | 2346 | [log](../../../rtl/reports/directory_holder_lifecycle/simulation_2h_dirty_eviction.log) |
| A-04 CPU 2h clean_eviction | PASS | 2210 | [log](../../../rtl/reports/directory_holder_lifecycle/simulation_2h_clean_eviction.log) |
| A-04 CPU 2h amo_refill_error | PASS | 1769 | [log](../../../rtl/reports/directory_holder_lifecycle/simulation_2h_amo_refill_error.log) |
| A-04 CPU 2h lr_refill_error | PASS | 1769 | [log](../../../rtl/reports/directory_holder_lifecycle/simulation_2h_lr_refill_error.log) |
| A-03 CPU 2h B=0 | PASS | 1274 | [log](../../../rtl/reports/l1_eviction_retention/simulation_2h_error0.log) |
| A-03 CPU 2h B=2 | PASS | 2638 | [log](../../../rtl/reports/l1_eviction_retention/simulation_2h_error2.log) |
| A-03 CPU 2h B=3 | PASS | 2638 | [log](../../../rtl/reports/l1_eviction_retention/simulation_2h_error3.log) |
| Atomic CPU 2h success | PASS | 2872 | [log](../../../rtl/reports/atomic_coherence/simulation_2h_success.log) |
| Atomic CPU 2h lrsc_contention | PASS | 3270 | [log](../../../rtl/reports/atomic_coherence/simulation_2h_lrsc_contention.log) |
| Atomic CPU 2h amo_fault | PASS | 542 | [log](../../../rtl/reports/atomic_coherence/simulation_2h_amo_fault.log) |
| Atomic CPU 2h lr_fault | PASS | 542 | [log](../../../rtl/reports/atomic_coherence/simulation_2h_lr_fault.log) |
| Atomic CPU 2h owner_fault | PASS | 716 | [log](../../../rtl/reports/atomic_coherence/simulation_2h_owner_fault.log) |
| CBO CPU 2h error=0 | PASS | 724 | [log](../../../rtl/reports/cmo_end_to_end/simulation_2h_error0.log) |
| CBO CPU 2h error=0_load_first | PASS | 726 | [log](../../../rtl/reports/cmo_end_to_end/simulation_2h_error0_load_first.log) |
| FENCE.I CPU 2h error=0 | PASS | 938 | [log](../../../rtl/reports/fence_i_end_to_end/simulation_2h_error0.log) |
| FENCE.I CPU 2h error=0_supervisor | PASS | 1063 | [log](../../../rtl/reports/fence_i_end_to_end/simulation_2h_error0_supervisor.log) |
| CBO CPU 2h error=1 | PASS | 603 | [log](../../../rtl/reports/cmo_end_to_end/simulation_2h_error1.log) |
| CBO CPU 2h error=1_load_first | PASS | 605 | [log](../../../rtl/reports/cmo_end_to_end/simulation_2h_error1_load_first.log) |
| FENCE.I CPU 2h error=1 | PASS | 1020 | [log](../../../rtl/reports/fence_i_end_to_end/simulation_2h_error1.log) |
| FENCE.I CPU 2h error=1_supervisor | PASS | 1145 | [log](../../../rtl/reports/fence_i_end_to_end/simulation_2h_error1_supervisor.log) |
| Native model directory_holder_lifecycle 2h | PASS | - | [log](../../../rtl/reports/directory_holder_lifecycle/model_2h.log) |
| Native model l1_eviction_retention 2h | PASS | - | [log](../../../rtl/reports/l1_eviction_retention/model_2h.log) |
| Native model atomic_coherence 2h | PASS | - | [log](../../../rtl/reports/atomic_coherence/model_2h.log) |
| Native model cmo_end_to_end 2h | PASS | - | [log](../../../rtl/reports/cmo_end_to_end/model_2h.log) |
| Native model fence_i_end_to_end 2h | PASS | - | [log](../../../rtl/reports/fence_i_end_to_end/model_2h.log) |
| Native model fault_record_a06 2h | PASS | - | [log](../../../rtl/reports/fault_record_a06/model_2h.log) |
| Native A-05 model 2h | PASS | - | [log](../../../rtl/reports/ccu_victim_escape/model_2h_2slots.log) |
| Production TOP lint 2h | PASS | - | [log](../../../rtl/reports/full_integration/top_lint_2h_20261116_033110.log) |
| Completed directory_holder_lifecycle driver 2h | PASS | - | [log](../../../rtl/reports/directory_holder_lifecycle/regression_driver_2h.log) |
| Completed ccu_victim_escape driver 2h | PASS | - | [log](../../../rtl/reports/ccu_victim_escape/regression_driver_2h.log) |
| Completed fault_record_a06 driver 2h | PASS | - | [log](../../../rtl/reports/fault_record_a06/regression_driver_2h.log) |
| A-06 model/bench/program compatibility 2h | PASS | - | [log](../../../rtl/reports/fault_record_a06/model_inputs_A-06_2h.json) |
| A-05 model/bench/program compatibility 2h | PASS | - | [log](../../../rtl/reports/fault_record_a06/model_inputs_A-05_2h.json) |
| A-04 model/bench/program compatibility 2h | PASS | - | [log](../../../rtl/reports/fault_record_a06/model_inputs_A-04_2h.json) |
| First fatal unit 2 active harts | PASS | - | [log](../../../rtl/reports/fault_record_a06/unit/simulation_2h_error0.log) |
| Native fault unit 2h | PASS | - | [log](../../../rtl/reports/fault_record_a06/unit/model_2h.log) |
| A-06 CPU 4h l1 B=2 | PASS | 8094 | [log](../../../rtl/reports/fault_record_a06/simulation_4h_l1_error2.log) |
| A-06 CPU 4h l1 B=3 | PASS | 8094 | [log](../../../rtl/reports/fault_record_a06/simulation_4h_l1_error3.log) |
| A-06 CPU 4h llc B=2 | PASS | 1650 | [log](../../../rtl/reports/fault_record_a06/simulation_4h_llc_error2.log) |
| A-06 CPU 4h llc B=3 | PASS | 1650 | [log](../../../rtl/reports/fault_record_a06/simulation_4h_llc_error3.log) |
| A-06 CPU 4h highest-hart-first B response | PASS | 8222 | [log](../../../rtl/reports/fault_record_a06/simulation_4h_l1_error2_reverse.log) |
| A-05 CPU 4h dirty_eviction | PASS | 3006 | [log](../../../rtl/reports/ccu_victim_escape/simulation_4h_2slots_dirty_eviction.log) |
| A-05 CPU 4h clean_eviction | PASS | 2826 | [log](../../../rtl/reports/ccu_victim_escape/simulation_4h_2slots_clean_eviction.log) |
| A-05 CPU 4h amo_refill_error | PASS | 2401 | [log](../../../rtl/reports/ccu_victim_escape/simulation_4h_2slots_amo_refill_error.log) |
| A-05 CPU 4h lr_refill_error | PASS | 2401 | [log](../../../rtl/reports/ccu_victim_escape/simulation_4h_2slots_lr_refill_error.log) |
| A-04 CPU 4h dirty_eviction | PASS | 2746 | [log](../../../rtl/reports/directory_holder_lifecycle/simulation_4h_dirty_eviction.log) |
| A-04 CPU 4h clean_eviction | PASS | 2574 | [log](../../../rtl/reports/directory_holder_lifecycle/simulation_4h_clean_eviction.log) |
| A-04 CPU 4h amo_refill_error | PASS | 2093 | [log](../../../rtl/reports/directory_holder_lifecycle/simulation_4h_amo_refill_error.log) |
| A-04 CPU 4h lr_refill_error | PASS | 2093 | [log](../../../rtl/reports/directory_holder_lifecycle/simulation_4h_lr_refill_error.log) |
| A-03 CPU 4h B=0 | PASS | 1566 | [log](../../../rtl/reports/l1_eviction_retention/simulation_4h_error0.log) |
| A-03 CPU 4h B=2 | PASS | 3214 | [log](../../../rtl/reports/l1_eviction_retention/simulation_4h_error2.log) |
| A-03 CPU 4h B=3 | PASS | 3214 | [log](../../../rtl/reports/l1_eviction_retention/simulation_4h_error3.log) |
| Atomic CPU 4h success | PASS | 3484 | [log](../../../rtl/reports/atomic_coherence/simulation_4h_success.log) |
| Atomic CPU 4h lrsc_contention | PASS | 6577 | [log](../../../rtl/reports/atomic_coherence/simulation_4h_lrsc_contention.log) |
| Atomic CPU 4h amo_fault | PASS | 558 | [log](../../../rtl/reports/atomic_coherence/simulation_4h_amo_fault.log) |
| Atomic CPU 4h lr_fault | PASS | 558 | [log](../../../rtl/reports/atomic_coherence/simulation_4h_lr_fault.log) |
| Atomic CPU 4h owner_fault | PASS | 817 | [log](../../../rtl/reports/atomic_coherence/simulation_4h_owner_fault.log) |
| CBO CPU 4h error=0 | PASS | 944 | [log](../../../rtl/reports/cmo_end_to_end/simulation_4h_error0.log) |
| CBO CPU 4h error=0_load_first | PASS | 948 | [log](../../../rtl/reports/cmo_end_to_end/simulation_4h_error0_load_first.log) |
| FENCE.I CPU 4h error=0 | PASS | 1015 | [log](../../../rtl/reports/fence_i_end_to_end/simulation_4h_error0.log) |
| FENCE.I CPU 4h error=0_supervisor | PASS | 1140 | [log](../../../rtl/reports/fence_i_end_to_end/simulation_4h_error0_supervisor.log) |
| CBO CPU 4h error=1 | PASS | 701 | [log](../../../rtl/reports/cmo_end_to_end/simulation_4h_error1.log) |
| CBO CPU 4h error=1_load_first | PASS | 705 | [log](../../../rtl/reports/cmo_end_to_end/simulation_4h_error1_load_first.log) |
| FENCE.I CPU 4h error=1 | PASS | 1163 | [log](../../../rtl/reports/fence_i_end_to_end/simulation_4h_error1.log) |
| FENCE.I CPU 4h error=1_supervisor | PASS | 1288 | [log](../../../rtl/reports/fence_i_end_to_end/simulation_4h_error1_supervisor.log) |
| Native model directory_holder_lifecycle 4h | PASS | - | [log](../../../rtl/reports/directory_holder_lifecycle/model_4h.log) |
| Native model l1_eviction_retention 4h | PASS | - | [log](../../../rtl/reports/l1_eviction_retention/model_4h.log) |
| Native model atomic_coherence 4h | PASS | - | [log](../../../rtl/reports/atomic_coherence/model_4h.log) |
| Native model cmo_end_to_end 4h | PASS | - | [log](../../../rtl/reports/cmo_end_to_end/model_4h.log) |
| Native model fence_i_end_to_end 4h | PASS | - | [log](../../../rtl/reports/fence_i_end_to_end/model_4h.log) |
| Native model fault_record_a06 4h | PASS | - | [log](../../../rtl/reports/fault_record_a06/model_4h.log) |
| Native A-05 model 4h | PASS | - | [log](../../../rtl/reports/ccu_victim_escape/model_4h_2slots.log) |
| Production TOP lint 4h | PASS | - | [log](../../../rtl/reports/full_integration/top_lint_4h_20261116_033110.log) |
| Completed directory_holder_lifecycle driver 4h | PASS | - | [log](../../../rtl/reports/directory_holder_lifecycle/regression_driver_4h.log) |
| Completed ccu_victim_escape driver 4h | PASS | - | [log](../../../rtl/reports/ccu_victim_escape/regression_driver_4h.log) |
| Completed fault_record_a06 driver 4h | PASS | - | [log](../../../rtl/reports/fault_record_a06/regression_driver_4h.log) |
| A-06 model/bench/program compatibility 4h | PASS | - | [log](../../../rtl/reports/fault_record_a06/model_inputs_A-06_4h.json) |
| A-05 model/bench/program compatibility 4h | PASS | - | [log](../../../rtl/reports/fault_record_a06/model_inputs_A-05_4h.json) |
| A-04 model/bench/program compatibility 4h | PASS | - | [log](../../../rtl/reports/fault_record_a06/model_inputs_A-04_4h.json) |
| First fatal unit 4 active harts | PASS | - | [log](../../../rtl/reports/fault_record_a06/unit/simulation_4h_error0.log) |
| Native fault unit 4h | PASS | - | [log](../../../rtl/reports/fault_record_a06/unit/model_4h.log) |
| CSR group routing/base mode 0 | PASS | - | [log](../../../rtl/reports/fault_record_a06/map_mode0/simulation_4h_error0.log) |
| Native CSR routing mode 0 | PASS | - | [log](../../../rtl/reports/fault_record_a06/map_mode0/model_4h.log) |
| CSR group routing/base mode 1 | PASS | - | [log](../../../rtl/reports/fault_record_a06/map_mode1/simulation_4h_error0.log) |
| Native CSR routing mode 1 | PASS | - | [log](../../../rtl/reports/fault_record_a06/map_mode1/model_4h.log) |
| CSR group routing/base mode 2 | PASS | - | [log](../../../rtl/reports/fault_record_a06/map_mode2/simulation_4h_error0.log) |
| Native CSR routing mode 2 | PASS | - | [log](../../../rtl/reports/fault_record_a06/map_mode2/model_4h.log) |
| First-fault overwrite mutant caught | PASS | - | [log](../../../rtl/reports/fault_record_a06/unit_mutant/mutation_result.txt) |
| Canonical CSR workbook/generator byte identity | PASS | - | [log](../../../rtl/reports/fault_record_a06/csr_verify.log) |
