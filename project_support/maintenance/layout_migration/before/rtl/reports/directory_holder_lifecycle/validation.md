# Validation / Kiểm chứng

| Test | Result | Cycles | Log |
|---|---|---:|---|
| Holder lifecycle 2h dirty_eviction | PASS | 2346 | [log](../../../rtl/reports/directory_holder_lifecycle/simulation_2h_dirty_eviction.log) |
| Holder lifecycle 2h clean_eviction | PASS | 2210 | [log](../../../rtl/reports/directory_holder_lifecycle/simulation_2h_clean_eviction.log) |
| Holder lifecycle 2h amo_refill_error | PASS | 1769 | [log](../../../rtl/reports/directory_holder_lifecycle/simulation_2h_amo_refill_error.log) |
| Holder lifecycle 2h lr_refill_error | PASS | 1769 | [log](../../../rtl/reports/directory_holder_lifecycle/simulation_2h_lr_refill_error.log) |
| L1 eviction 2h B=0 | PASS | 1274 | [log](../../../rtl/reports/l1_eviction_retention/simulation_2h_error0.log) |
| L1 eviction 2h B=2 | PASS | 2638 | [log](../../../rtl/reports/l1_eviction_retention/simulation_2h_error2.log) |
| L1 eviction 2h B=3 | PASS | 2638 | [log](../../../rtl/reports/l1_eviction_retention/simulation_2h_error3.log) |
| Atomic 2h success | PASS | 2872 | [log](../../../rtl/reports/atomic_coherence/simulation_2h_success.log) |
| Atomic 2h lrsc_contention | PASS | 3270 | [log](../../../rtl/reports/atomic_coherence/simulation_2h_lrsc_contention.log) |
| Atomic 2h amo_fault | PASS | 542 | [log](../../../rtl/reports/atomic_coherence/simulation_2h_amo_fault.log) |
| Atomic 2h lr_fault | PASS | 542 | [log](../../../rtl/reports/atomic_coherence/simulation_2h_lr_fault.log) |
| Atomic 2h owner_fault | PASS | 716 | [log](../../../rtl/reports/atomic_coherence/simulation_2h_owner_fault.log) |
| CBO 2h error=0 | PASS | 724 | [log](../../../rtl/reports/cmo_end_to_end/simulation_2h_error0.log) |
| CBO 2h error=0_load_first | PASS | 726 | [log](../../../rtl/reports/cmo_end_to_end/simulation_2h_error0_load_first.log) |
| FENCE.I 2h error=0 | PASS | 938 | [log](../../../rtl/reports/fence_i_end_to_end/simulation_2h_error0.log) |
| FENCE.I 2h error=0_supervisor | PASS | 1063 | [log](../../../rtl/reports/fence_i_end_to_end/simulation_2h_error0_supervisor.log) |
| CBO 2h error=1 | PASS | 603 | [log](../../../rtl/reports/cmo_end_to_end/simulation_2h_error1.log) |
| CBO 2h error=1_load_first | PASS | 605 | [log](../../../rtl/reports/cmo_end_to_end/simulation_2h_error1_load_first.log) |
| FENCE.I 2h error=1 | PASS | 1020 | [log](../../../rtl/reports/fence_i_end_to_end/simulation_2h_error1.log) |
| FENCE.I 2h error=1_supervisor | PASS | 1145 | [log](../../../rtl/reports/fence_i_end_to_end/simulation_2h_error1_supervisor.log) |
| Model directory_holder_lifecycle 2h | PASS | — | [log](../../../rtl/reports/directory_holder_lifecycle/model_2h.log) |
| Model l1_eviction_retention 2h | PASS | — | [log](../../../rtl/reports/l1_eviction_retention/model_2h.log) |
| Model atomic_coherence 2h | PASS | — | [log](../../../rtl/reports/atomic_coherence/model_2h.log) |
| Model cmo_end_to_end 2h | PASS | — | [log](../../../rtl/reports/cmo_end_to_end/model_2h.log) |
| Model fence_i_end_to_end 2h | PASS | — | [log](../../../rtl/reports/fence_i_end_to_end/model_2h.log) |
| TOP lint 2h | PASS | — | [log](../../../rtl/reports/full_integration/top_lint_2h_20261115_210046.log) |
| Completed current regression driver 2h | PASS | — | [log](../../../rtl/reports/directory_holder_lifecycle/regression_driver_2h.log) |
| Holder model/bench/program identity 2h | PASS | — | [log](../../../rtl/reports/directory_holder_lifecycle/model_inputs_2h.json) |
| Holder lifecycle 4h dirty_eviction | PASS | 2746 | [log](../../../rtl/reports/directory_holder_lifecycle/simulation_4h_dirty_eviction.log) |
| Holder lifecycle 4h clean_eviction | PASS | 2574 | [log](../../../rtl/reports/directory_holder_lifecycle/simulation_4h_clean_eviction.log) |
| Holder lifecycle 4h amo_refill_error | PASS | 2093 | [log](../../../rtl/reports/directory_holder_lifecycle/simulation_4h_amo_refill_error.log) |
| Holder lifecycle 4h lr_refill_error | PASS | 2093 | [log](../../../rtl/reports/directory_holder_lifecycle/simulation_4h_lr_refill_error.log) |
| L1 eviction 4h B=0 | PASS | 1566 | [log](../../../rtl/reports/l1_eviction_retention/simulation_4h_error0.log) |
| L1 eviction 4h B=2 | PASS | 3214 | [log](../../../rtl/reports/l1_eviction_retention/simulation_4h_error2.log) |
| L1 eviction 4h B=3 | PASS | 3214 | [log](../../../rtl/reports/l1_eviction_retention/simulation_4h_error3.log) |
| Atomic 4h success | PASS | 3484 | [log](../../../rtl/reports/atomic_coherence/simulation_4h_success.log) |
| Atomic 4h lrsc_contention | PASS | 6577 | [log](../../../rtl/reports/atomic_coherence/simulation_4h_lrsc_contention.log) |
| Atomic 4h amo_fault | PASS | 558 | [log](../../../rtl/reports/atomic_coherence/simulation_4h_amo_fault.log) |
| Atomic 4h lr_fault | PASS | 558 | [log](../../../rtl/reports/atomic_coherence/simulation_4h_lr_fault.log) |
| Atomic 4h owner_fault | PASS | 817 | [log](../../../rtl/reports/atomic_coherence/simulation_4h_owner_fault.log) |
| CBO 4h error=0 | PASS | 944 | [log](../../../rtl/reports/cmo_end_to_end/simulation_4h_error0.log) |
| CBO 4h error=0_load_first | PASS | 948 | [log](../../../rtl/reports/cmo_end_to_end/simulation_4h_error0_load_first.log) |
| FENCE.I 4h error=0 | PASS | 1015 | [log](../../../rtl/reports/fence_i_end_to_end/simulation_4h_error0.log) |
| FENCE.I 4h error=0_supervisor | PASS | 1140 | [log](../../../rtl/reports/fence_i_end_to_end/simulation_4h_error0_supervisor.log) |
| CBO 4h error=1 | PASS | 701 | [log](../../../rtl/reports/cmo_end_to_end/simulation_4h_error1.log) |
| CBO 4h error=1_load_first | PASS | 705 | [log](../../../rtl/reports/cmo_end_to_end/simulation_4h_error1_load_first.log) |
| FENCE.I 4h error=1 | PASS | 1163 | [log](../../../rtl/reports/fence_i_end_to_end/simulation_4h_error1.log) |
| FENCE.I 4h error=1_supervisor | PASS | 1288 | [log](../../../rtl/reports/fence_i_end_to_end/simulation_4h_error1_supervisor.log) |
| Model directory_holder_lifecycle 4h | PASS | — | [log](../../../rtl/reports/directory_holder_lifecycle/model_4h.log) |
| Model l1_eviction_retention 4h | PASS | — | [log](../../../rtl/reports/l1_eviction_retention/model_4h.log) |
| Model atomic_coherence 4h | PASS | — | [log](../../../rtl/reports/atomic_coherence/model_4h.log) |
| Model cmo_end_to_end 4h | PASS | — | [log](../../../rtl/reports/cmo_end_to_end/model_4h.log) |
| Model fence_i_end_to_end 4h | PASS | — | [log](../../../rtl/reports/fence_i_end_to_end/model_4h.log) |
| TOP lint 4h | PASS | — | [log](../../../rtl/reports/full_integration/top_lint_4h_20261115_210841.log) |
| Completed current regression driver 4h | PASS | — | [log](../../../rtl/reports/directory_holder_lifecycle/regression_driver_4h.log) |
| Holder model/bench/program identity 4h | PASS | — | [log](../../../rtl/reports/directory_holder_lifecycle/model_inputs_4h.json) |
| fabric_unit directed checks | PASS | — | [log](../../../rtl/reports/directory_holder_lifecycle/fabric_unit/simulation_4h_error0.log) |
| fabric_unit native model | PASS | — | [log](../../../rtl/reports/directory_holder_lifecycle/fabric_unit/model_4h.log) |
| probe_unit directed checks | PASS | — | [log](../../../rtl/reports/directory_holder_lifecycle/probe_unit/simulation_4h_error0.log) |
| probe_unit native model | PASS | — | [log](../../../rtl/reports/directory_holder_lifecycle/probe_unit/model_4h.log) |
