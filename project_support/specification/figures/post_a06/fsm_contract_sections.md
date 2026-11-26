### 10.1 Modes and state transitions

These are the exact explicit enum controllers introduced by the cluster. Waiting states hold until the stated handshake/completion. Diagrams show event order, not numeric latency. Native queue/flag lifecycles and retained retirement are specified separately; do not invent enum states for them. / Đây là các FSM enum thực; chờ đúng handshake/completion, không đặt latency giả.

#### CMO-CONTROLLER

Retain one hart command from acceptance through CCU preparation, optional LLC service and terminal completion. Every unspecified guard holds the state; errors are retained until the CPU response. FENCE.I bypasses LLC-to-DRAM service after preparation.

![m_vlsit_riscv_cmo_controller FSM](../../../../doc/specification/figures/post_a06/figures/post_a06/CMO_CONTROLLER.svg)

```json
{"page_name":"CMO_CONTROLLER","out_name":"CMO_CONTROLLER.drawio","function":"CMO_CONTROLLER","initial":"ENUM_ST_CMO_IDLE","state_pattern":"^[A-Z][A-Z0-9_]+$","states":[{"name":"ENUM_ST_CMO_IDLE"},{"name":"ENUM_ST_CMO_BEGIN"},{"name":"ENUM_ST_CMO_PREPARE"},{"name":"ENUM_ST_CMO_MAINT_REQ"},{"name":"ENUM_ST_CMO_MAINT_WAIT"},{"name":"ENUM_ST_CMO_FINISH_REQ"},{"name":"ENUM_ST_CMO_FINISH_WAIT"},{"name":"ENUM_ST_CMO_RESP"}],"transitions":[{"src":"ENUM_ST_CMO_IDLE","dst":"ENUM_ST_CMO_BEGIN","label":"w_cmd_take"},{"src":"ENUM_ST_CMO_BEGIN","dst":"ENUM_ST_CMO_PREPARE","label":"i_ccu_begin_ready"},{"src":"ENUM_ST_CMO_PREPARE","dst":"ENUM_ST_CMO_FINISH_REQ","label":"w_prepare_take and (prepare error or FENCE.I)"},{"src":"ENUM_ST_CMO_PREPARE","dst":"ENUM_ST_CMO_MAINT_REQ","label":"w_prepare_take and successful CBO"},{"src":"ENUM_ST_CMO_MAINT_REQ","dst":"ENUM_ST_CMO_FINISH_REQ","label":"i_maint_ready and i_maint_done"},{"src":"ENUM_ST_CMO_MAINT_REQ","dst":"ENUM_ST_CMO_MAINT_WAIT","label":"i_maint_ready and not i_maint_done"},{"src":"ENUM_ST_CMO_MAINT_WAIT","dst":"ENUM_ST_CMO_FINISH_REQ","label":"i_maint_done"},{"src":"ENUM_ST_CMO_FINISH_REQ","dst":"ENUM_ST_CMO_RESP","label":"i_ccu_finish_ready and i_ccu_finish_done"},{"src":"ENUM_ST_CMO_FINISH_REQ","dst":"ENUM_ST_CMO_FINISH_WAIT","label":"i_ccu_finish_ready and not i_ccu_finish_done"},{"src":"ENUM_ST_CMO_FINISH_WAIT","dst":"ENUM_ST_CMO_RESP","label":"i_ccu_finish_done"},{"src":"ENUM_ST_CMO_RESP","dst":"ENUM_ST_CMO_IDLE","label":"next edge after one-cycle response"}],"layout":{"margin":50}}
```

[Editable draw.io](../../../../doc/specification/figures/post_a06/figures/post_a06/CMO_CONTROLLER.drawio) · [Figure source](../../../../doc/specification/figures/post_a06/figures/post_a06/CMO_CONTROLLER.json).

| Transition | Current state | Guard / event | Next state |
|---|---|---|---|
| T01 | `ENUM_ST_CMO_IDLE` | w_cmd_take | `ENUM_ST_CMO_BEGIN` |
| T02 | `ENUM_ST_CMO_BEGIN` | i_ccu_begin_ready | `ENUM_ST_CMO_PREPARE` |
| T03 | `ENUM_ST_CMO_PREPARE` | w_prepare_take and (prepare error or FENCE.I) | `ENUM_ST_CMO_FINISH_REQ` |
| T04 | `ENUM_ST_CMO_PREPARE` | w_prepare_take and successful CBO | `ENUM_ST_CMO_MAINT_REQ` |
| T05 | `ENUM_ST_CMO_MAINT_REQ` | i_maint_ready and i_maint_done | `ENUM_ST_CMO_FINISH_REQ` |
| T06 | `ENUM_ST_CMO_MAINT_REQ` | i_maint_ready and not i_maint_done | `ENUM_ST_CMO_MAINT_WAIT` |
| T07 | `ENUM_ST_CMO_MAINT_WAIT` | i_maint_done | `ENUM_ST_CMO_FINISH_REQ` |
| T08 | `ENUM_ST_CMO_FINISH_REQ` | i_ccu_finish_ready and i_ccu_finish_done | `ENUM_ST_CMO_RESP` |
| T09 | `ENUM_ST_CMO_FINISH_REQ` | i_ccu_finish_ready and not i_ccu_finish_done | `ENUM_ST_CMO_FINISH_WAIT` |
| T10 | `ENUM_ST_CMO_FINISH_WAIT` | i_ccu_finish_done | `ENUM_ST_CMO_RESP` |
| T11 | `ENUM_ST_CMO_RESP` | next edge after one-cycle response | `ENUM_ST_CMO_IDLE` |

All unspecified guards hold the current legal state in the full FSM. Reset enters `ENUM_ST_CMO_IDLE`; a phase-view entry is not a new hardware reset state. Invalid-encoding behavior follows the source and is not a normal software recovery path. / Điều kiện chưa thỏa giữ state theo FSM đầy đủ; điểm vào phase không phải reset state mới.

#### CCU-CONTEXT

One instance of this state lifecycle exists per transaction slot, not one global serialized CCU. Allocation selects DIR_REQ for a root, OWNER for a victim child, or GNT for an immediately rejected request. Parent wakeup on child completion is an inter-context transition. Matching tag/phase guards apply to every phase handshake. COMMIT/ABORT errors retain the context; no phase timeout exists.

![m_vlsit_riscv_coh_fabric FSM](../../../../doc/specification/figures/post_a06/figures/post_a06/CCU_CONTEXT.svg)

```json
{"page_name":"CCU_CONTEXT","out_name":"CCU_CONTEXT.drawio","function":"CCU_CONTEXT","initial":"ENUM_ST_IDLE","state_pattern":"^[A-Z][A-Z0-9_]+$","states":[{"name":"ENUM_ST_IDLE"},{"name":"ENUM_ST_DIR_REQ"},{"name":"ENUM_ST_DIR_WAIT"},{"name":"ENUM_ST_EVICT_ALLOC"},{"name":"ENUM_ST_EVICT_WAIT"},{"name":"ENUM_ST_OWNER"},{"name":"ENUM_ST_PREP_START"},{"name":"ENUM_ST_PREP_WAIT"},{"name":"ENUM_ST_COMMIT_START"},{"name":"ENUM_ST_COMMIT_WAIT"},{"name":"ENUM_ST_ABORT_START"},{"name":"ENUM_ST_ABORT_WAIT"},{"name":"ENUM_ST_DIR_UPDATE"},{"name":"ENUM_ST_DIR_CANCEL"},{"name":"ENUM_ST_GNT"},{"name":"ENUM_ST_GNT_WAIT"},{"name":"ENUM_ST_CMO_PREPARED"},{"name":"ENUM_ST_CMO_FINISH"},{"name":"ENUM_ST_RETRY_CANCEL"}],"transitions":[{"src":"ENUM_ST_IDLE","dst":"ENUM_ST_DIR_REQ","label":"T01: alloc root","guard":"root allocation accepted"},{"src":"ENUM_ST_IDLE","dst":"ENUM_ST_OWNER","label":"T02: alloc victim","guard":"victim child allocation accepted"},{"src":"ENUM_ST_IDLE","dst":"ENUM_ST_GNT","label":"T03: reject","guard":"rejected request allocation accepted"},{"src":"ENUM_ST_DIR_REQ","dst":"ENUM_ST_DIR_WAIT","label":"T04: lookup","guard":"selected bank lookup accepted"},{"src":"ENUM_ST_DIR_WAIT","dst":"ENUM_ST_EVICT_ALLOC","label":"T05: held victim","guard":"lookup miss and victim has holders; not CMO"},{"src":"ENUM_ST_DIR_WAIT","dst":"ENUM_ST_OWNER","label":"T06: lookup result","guard":"matching lookup; no held-victim service needed"},{"src":"ENUM_ST_EVICT_ALLOC","dst":"ENUM_ST_RETRY_CANCEL","label":"T07: victim busy","guard":"victim line already locked by another context"},{"src":"ENUM_ST_RETRY_CANCEL","dst":"ENUM_ST_DIR_REQ","label":"T08: cancel retry","guard":"matching owner CANCEL accepted"},{"src":"ENUM_ST_EVICT_ALLOC","dst":"ENUM_ST_EVICT_WAIT","label":"T09: alloc child","guard":"matching victim child allocated"},{"src":"ENUM_ST_EVICT_WAIT","dst":"ENUM_ST_DIR_UPDATE","label":"T10: child commit","guard":"child COMMIT completes"},{"src":"ENUM_ST_EVICT_WAIT","dst":"ENUM_ST_DIR_CANCEL","label":"T11: child abort","guard":"child ABORT completes"},{"src":"ENUM_ST_OWNER","dst":"ENUM_ST_PREP_START","label":"T12: owner capture","guard":"matching owner metadata captured"},{"src":"ENUM_ST_PREP_START","dst":"ENUM_ST_PREP_WAIT","label":"T13: prepare start","guard":"matching PREPARE phase accepted"},{"src":"ENUM_ST_PREP_WAIT","dst":"ENUM_ST_CMO_PREPARED","label":"T14: CMO prepared","guard":"all PREPARE responses; source is CMO"},{"src":"ENUM_ST_PREP_WAIT","dst":"ENUM_ST_ABORT_START","label":"T15: prepare error","guard":"PREPARE complete with error or missing dirty obligation"},{"src":"ENUM_ST_PREP_WAIT","dst":"ENUM_ST_COMMIT_START","label":"T16: prepare OK","guard":"PREPARE complete and dirty obligation satisfied"},{"src":"ENUM_ST_CMO_PREPARED","dst":"ENUM_ST_CMO_FINISH","label":"T17: CMO report","guard":"i_ccu_prepare_ready"},{"src":"ENUM_ST_CMO_FINISH","dst":"ENUM_ST_COMMIT_START","label":"T18: finish commit","guard":"matching finish accepted; commit and no retained error"},{"src":"ENUM_ST_CMO_FINISH","dst":"ENUM_ST_ABORT_START","label":"T19: finish abort","guard":"matching finish accepted; abort or retained error"},{"src":"ENUM_ST_COMMIT_START","dst":"ENUM_ST_COMMIT_WAIT","label":"T20: commit start","guard":"matching COMMIT phase accepted"},{"src":"ENUM_ST_COMMIT_WAIT","dst":"ENUM_ST_IDLE","label":"T21: victim release","guard":"victim COMMIT ACKs and immediate release"},{"src":"ENUM_ST_COMMIT_WAIT","dst":"ENUM_ST_GNT_WAIT","label":"T22: victim hold","guard":"victim COMMIT ACKs; deferred release"},{"src":"ENUM_ST_COMMIT_WAIT","dst":"ENUM_ST_DIR_CANCEL","label":"T23: CMO cancel","guard":"CMO COMMIT ACKs; no directory hit"},{"src":"ENUM_ST_COMMIT_WAIT","dst":"ENUM_ST_DIR_UPDATE","label":"T24: publish","guard":"root COMMIT ACKs; publish metadata"},{"src":"ENUM_ST_ABORT_START","dst":"ENUM_ST_ABORT_WAIT","label":"T25: abort start","guard":"matching ABORT phase accepted"},{"src":"ENUM_ST_ABORT_WAIT","dst":"ENUM_ST_IDLE","label":"T26: victim release","guard":"victim ABORT ACKs and immediate release"},{"src":"ENUM_ST_ABORT_WAIT","dst":"ENUM_ST_GNT_WAIT","label":"T27: victim hold","guard":"victim ABORT ACKs; deferred release"},{"src":"ENUM_ST_ABORT_WAIT","dst":"ENUM_ST_DIR_CANCEL","label":"T28: cancel owner","guard":"root ABORT ACKs and reservation retained"},{"src":"ENUM_ST_ABORT_WAIT","dst":"ENUM_ST_GNT","label":"T29: error grant","guard":"root ABORT ACKs without reservation"},{"src":"ENUM_ST_DIR_UPDATE","dst":"ENUM_ST_GNT","label":"T30: update","guard":"matching bank UPDATE accepted"},{"src":"ENUM_ST_DIR_CANCEL","dst":"ENUM_ST_GNT","label":"T31: cancel","guard":"no reservation or matching CANCEL accepted"},{"src":"ENUM_ST_GNT","dst":"ENUM_ST_GNT_WAIT","label":"T32: grant load","guard":"matching CPU grant loaded"},{"src":"ENUM_ST_GNT","dst":"ENUM_ST_IDLE","label":"T33: CMO release","guard":"CMO response release accepted"},{"src":"ENUM_ST_GNT_WAIT","dst":"ENUM_ST_IDLE","label":"T34: release","guard":"matching release accepted"}],"layout":{"margin":50,"node_gap":220,"rank_gap":220,"max_columns":4}}
```

[Editable draw.io](../../../../doc/specification/figures/post_a06/figures/post_a06/CCU_CONTEXT.drawio) · [Figure source](../../../../doc/specification/figures/post_a06/figures/post_a06/CCU_CONTEXT.json).

| Transition | Current state | Guard / event | Next state |
|---|---|---|---|
| T01 | `ENUM_ST_IDLE` | root allocation accepted | `ENUM_ST_DIR_REQ` |
| T02 | `ENUM_ST_IDLE` | victim child allocation accepted | `ENUM_ST_OWNER` |
| T03 | `ENUM_ST_IDLE` | rejected request allocation accepted | `ENUM_ST_GNT` |
| T04 | `ENUM_ST_DIR_REQ` | selected bank lookup accepted | `ENUM_ST_DIR_WAIT` |
| T05 | `ENUM_ST_DIR_WAIT` | lookup miss and victim has holders; not CMO | `ENUM_ST_EVICT_ALLOC` |
| T06 | `ENUM_ST_DIR_WAIT` | matching lookup; no held-victim service needed | `ENUM_ST_OWNER` |
| T07 | `ENUM_ST_EVICT_ALLOC` | victim line already locked by another context | `ENUM_ST_RETRY_CANCEL` |
| T08 | `ENUM_ST_RETRY_CANCEL` | matching owner CANCEL accepted | `ENUM_ST_DIR_REQ` |
| T09 | `ENUM_ST_EVICT_ALLOC` | matching victim child allocated | `ENUM_ST_EVICT_WAIT` |
| T10 | `ENUM_ST_EVICT_WAIT` | child COMMIT completes | `ENUM_ST_DIR_UPDATE` |
| T11 | `ENUM_ST_EVICT_WAIT` | child ABORT completes | `ENUM_ST_DIR_CANCEL` |
| T12 | `ENUM_ST_OWNER` | matching owner metadata captured | `ENUM_ST_PREP_START` |
| T13 | `ENUM_ST_PREP_START` | matching PREPARE phase accepted | `ENUM_ST_PREP_WAIT` |
| T14 | `ENUM_ST_PREP_WAIT` | all PREPARE responses; source is CMO | `ENUM_ST_CMO_PREPARED` |
| T15 | `ENUM_ST_PREP_WAIT` | PREPARE complete with error or missing dirty obligation | `ENUM_ST_ABORT_START` |
| T16 | `ENUM_ST_PREP_WAIT` | PREPARE complete and dirty obligation satisfied | `ENUM_ST_COMMIT_START` |
| T17 | `ENUM_ST_CMO_PREPARED` | i_ccu_prepare_ready | `ENUM_ST_CMO_FINISH` |
| T18 | `ENUM_ST_CMO_FINISH` | matching finish accepted; commit and no retained error | `ENUM_ST_COMMIT_START` |
| T19 | `ENUM_ST_CMO_FINISH` | matching finish accepted; abort or retained error | `ENUM_ST_ABORT_START` |
| T20 | `ENUM_ST_COMMIT_START` | matching COMMIT phase accepted | `ENUM_ST_COMMIT_WAIT` |
| T21 | `ENUM_ST_COMMIT_WAIT` | victim COMMIT ACKs and immediate release | `ENUM_ST_IDLE` |
| T22 | `ENUM_ST_COMMIT_WAIT` | victim COMMIT ACKs; deferred release | `ENUM_ST_GNT_WAIT` |
| T23 | `ENUM_ST_COMMIT_WAIT` | CMO COMMIT ACKs; no directory hit | `ENUM_ST_DIR_CANCEL` |
| T24 | `ENUM_ST_COMMIT_WAIT` | root COMMIT ACKs; publish metadata | `ENUM_ST_DIR_UPDATE` |
| T25 | `ENUM_ST_ABORT_START` | matching ABORT phase accepted | `ENUM_ST_ABORT_WAIT` |
| T26 | `ENUM_ST_ABORT_WAIT` | victim ABORT ACKs and immediate release | `ENUM_ST_IDLE` |
| T27 | `ENUM_ST_ABORT_WAIT` | victim ABORT ACKs; deferred release | `ENUM_ST_GNT_WAIT` |
| T28 | `ENUM_ST_ABORT_WAIT` | root ABORT ACKs and reservation retained | `ENUM_ST_DIR_CANCEL` |
| T29 | `ENUM_ST_ABORT_WAIT` | root ABORT ACKs without reservation | `ENUM_ST_GNT` |
| T30 | `ENUM_ST_DIR_UPDATE` | matching bank UPDATE accepted | `ENUM_ST_GNT` |
| T31 | `ENUM_ST_DIR_CANCEL` | no reservation or matching CANCEL accepted | `ENUM_ST_GNT` |
| T32 | `ENUM_ST_GNT` | matching CPU grant loaded | `ENUM_ST_GNT_WAIT` |
| T33 | `ENUM_ST_GNT` | CMO response release accepted | `ENUM_ST_IDLE` |
| T34 | `ENUM_ST_GNT_WAIT` | matching release accepted | `ENUM_ST_IDLE` |

All unspecified guards hold the current legal state in the full FSM. Reset enters `ENUM_ST_IDLE`; a phase-view entry is not a new hardware reset state. Invalid-encoding behavior follows the source and is not a normal software recovery path. / Điều kiện chưa thỏa giữ state theo FSM đầy đủ; điểm vào phase không phải reset state mới.

#### HPD-PROBE

Lookup and any required dirty writeback belong to PREPARE. Actual metadata changes occur only at a validated COMMIT. A malformed terminal request returns ERR_RSP and resumes TERMINAL_WAIT rather than discarding the legitimate prepared context. Absence remains I without line allocation.

![m_vlsit_riscv_hpd_probe_engine FSM](../../../../doc/specification/figures/post_a06/figures/post_a06/HPD_PROBE.svg)

```json
{"page_name":"HPD_PROBE","out_name":"HPD_PROBE.drawio","function":"HPD_PROBE","initial":"ENUM_ST_IDLE","state_pattern":"^[A-Z][A-Z0-9_]+$","states":[{"name":"ENUM_ST_IDLE"},{"name":"ENUM_ST_LOOKUP_REQ"},{"name":"ENUM_ST_LOOKUP_WAIT"},{"name":"ENUM_ST_FLUSH_REQ"},{"name":"ENUM_ST_FLUSH_WAIT"},{"name":"ENUM_ST_PREPARE_RSP"},{"name":"ENUM_ST_TERMINAL_WAIT"},{"name":"ENUM_ST_UPDATE_REQ"},{"name":"ENUM_ST_TERMINAL_RSP"},{"name":"ENUM_ST_ERR_RSP"},{"name":"ENUM_ST_STRAY_RSP"}],"transitions":[{"src":"ENUM_ST_IDLE","dst":"ENUM_ST_LOOKUP_REQ","label":"accepted PREPARE"},{"src":"ENUM_ST_IDLE","dst":"ENUM_ST_STRAY_RSP","label":"accepted non-PREPARE without context"},{"src":"ENUM_ST_STRAY_RSP","dst":"ENUM_ST_IDLE","label":"response consumed"},{"src":"ENUM_ST_LOOKUP_REQ","dst":"ENUM_ST_LOOKUP_WAIT","label":"lookup accepted"},{"src":"ENUM_ST_LOOKUP_WAIT","dst":"ENUM_ST_FLUSH_REQ","label":"lookup matches dirty M hit; writeback enabled"},{"src":"ENUM_ST_LOOKUP_WAIT","dst":"ENUM_ST_PREPARE_RSP","label":"lookup error, absence, or no writeback required"},{"src":"ENUM_ST_FLUSH_REQ","dst":"ENUM_ST_FLUSH_WAIT","label":"native flush accepted"},{"src":"ENUM_ST_FLUSH_WAIT","dst":"ENUM_ST_PREPARE_RSP","label":"native flush ACK received"},{"src":"ENUM_ST_PREPARE_RSP","dst":"ENUM_ST_TERMINAL_WAIT","label":"PREPARE response consumed"},{"src":"ENUM_ST_TERMINAL_WAIT","dst":"ENUM_ST_ERR_RSP","label":"terminal tag/line/target/phase mismatch or bad COMMIT"},{"src":"ENUM_ST_TERMINAL_WAIT","dst":"ENUM_ST_TERMINAL_RSP","label":"matching ABORT or COMMIT of validated absence"},{"src":"ENUM_ST_TERMINAL_WAIT","dst":"ENUM_ST_UPDATE_REQ","label":"matching good COMMIT of actual hit"},{"src":"ENUM_ST_UPDATE_REQ","dst":"ENUM_ST_TERMINAL_RSP","label":"state update accepted"},{"src":"ENUM_ST_ERR_RSP","dst":"ENUM_ST_TERMINAL_WAIT","label":"error response consumed; retain prepared context"},{"src":"ENUM_ST_TERMINAL_RSP","dst":"ENUM_ST_IDLE","label":"terminal response consumed"}],"layout":{"margin":50}}
```

[Editable draw.io](../../../../doc/specification/figures/post_a06/figures/post_a06/HPD_PROBE.drawio) · [Figure source](../../../../doc/specification/figures/post_a06/figures/post_a06/HPD_PROBE.json).

| Transition | Current state | Guard / event | Next state |
|---|---|---|---|
| T01 | `ENUM_ST_IDLE` | accepted PREPARE | `ENUM_ST_LOOKUP_REQ` |
| T02 | `ENUM_ST_IDLE` | accepted non-PREPARE without context | `ENUM_ST_STRAY_RSP` |
| T03 | `ENUM_ST_STRAY_RSP` | response consumed | `ENUM_ST_IDLE` |
| T04 | `ENUM_ST_LOOKUP_REQ` | lookup accepted | `ENUM_ST_LOOKUP_WAIT` |
| T05 | `ENUM_ST_LOOKUP_WAIT` | lookup matches dirty M hit; writeback enabled | `ENUM_ST_FLUSH_REQ` |
| T06 | `ENUM_ST_LOOKUP_WAIT` | lookup error, absence, or no writeback required | `ENUM_ST_PREPARE_RSP` |
| T07 | `ENUM_ST_FLUSH_REQ` | native flush accepted | `ENUM_ST_FLUSH_WAIT` |
| T08 | `ENUM_ST_FLUSH_WAIT` | native flush ACK received | `ENUM_ST_PREPARE_RSP` |
| T09 | `ENUM_ST_PREPARE_RSP` | PREPARE response consumed | `ENUM_ST_TERMINAL_WAIT` |
| T10 | `ENUM_ST_TERMINAL_WAIT` | terminal tag/line/target/phase mismatch or bad COMMIT | `ENUM_ST_ERR_RSP` |
| T11 | `ENUM_ST_TERMINAL_WAIT` | matching ABORT or COMMIT of validated absence | `ENUM_ST_TERMINAL_RSP` |
| T12 | `ENUM_ST_TERMINAL_WAIT` | matching good COMMIT of actual hit | `ENUM_ST_UPDATE_REQ` |
| T13 | `ENUM_ST_UPDATE_REQ` | state update accepted | `ENUM_ST_TERMINAL_RSP` |
| T14 | `ENUM_ST_ERR_RSP` | error response consumed; retain prepared context | `ENUM_ST_TERMINAL_WAIT` |
| T15 | `ENUM_ST_TERMINAL_RSP` | terminal response consumed | `ENUM_ST_IDLE` |

All unspecified guards hold the current legal state in the full FSM. Reset enters `ENUM_ST_IDLE`; a phase-view entry is not a new hardware reset state. Invalid-encoding behavior follows the source and is not a normal software recovery path. / Điều kiện chưa thỏa giữ state theo FSM đầy đủ; điểm vào phase không phải reset state mới.

#### AXIL-REGBUS

Independent AXI address/data/read queues are separate from this service FSM. Local invalid-access responses do not enter RegBus request states. B/R responses have independent valid registers and remain stable until consumed.

![m_vlsit_axil_reg_bridge FSM](../../../../doc/specification/figures/post_a06/figures/post_a06/AXIL_REGBUS.svg)

```json
{"page_name":"AXIL_REGBUS","out_name":"AXIL_REGBUS.drawio","function":"AXIL_REGBUS","initial":"ENUM_ST_IDLE","state_pattern":"^[A-Z][A-Z0-9_]+$","states":[{"name":"ENUM_ST_IDLE"},{"name":"ENUM_ST_WR_REQ"},{"name":"ENUM_ST_RD_REQ"}],"transitions":[{"src":"ENUM_ST_IDLE","dst":"ENUM_ST_WR_REQ","label":"selected legal complete write"},{"src":"ENUM_ST_IDLE","dst":"ENUM_ST_RD_REQ","label":"selected legal queued read"},{"src":"ENUM_ST_WR_REQ","dst":"ENUM_ST_IDLE","label":"RegBus request and response ready"},{"src":"ENUM_ST_RD_REQ","dst":"ENUM_ST_IDLE","label":"RegBus request and response ready"}],"layout":{"margin":50}}
```

[Editable draw.io](../../../../doc/specification/figures/post_a06/figures/post_a06/AXIL_REGBUS.drawio) · [Figure source](../../../../doc/specification/figures/post_a06/figures/post_a06/AXIL_REGBUS.json).

| Transition | Current state | Guard / event | Next state |
|---|---|---|---|
| T01 | `ENUM_ST_IDLE` | selected legal complete write | `ENUM_ST_WR_REQ` |
| T02 | `ENUM_ST_IDLE` | selected legal queued read | `ENUM_ST_RD_REQ` |
| T03 | `ENUM_ST_WR_REQ` | RegBus request and response ready | `ENUM_ST_IDLE` |
| T04 | `ENUM_ST_RD_REQ` | RegBus request and response ready | `ENUM_ST_IDLE` |

All unspecified guards hold the current legal state in the full FSM. Reset enters `ENUM_ST_IDLE`; a phase-view entry is not a new hardware reset state. Invalid-encoding behavior follows the source and is not a normal software recovery path. / Điều kiện chưa thỏa giữ state theo FSM đầy đủ; điểm vào phase không phải reset state mới.

#### HPD-MISS-PERMISSION

Native miss-request controller extended for permission-before-refill. The request ID, line and requested permission remain retained while CCU is stalled. OWN_ERROR returns a precise synthetic failed response rather than issuing a memory read. Refill data acceptance and directory publication are a separate native controller, not hidden in the OWN_WAIT transition.

![hpdcache_miss_handler FSM](../../../../doc/specification/figures/post_a06/figures/post_a06/HPD_MISS_PERMISSION.svg)

```json
{"page_name":"HPD_MISS_PERMISSION","out_name":"HPD_MISS_PERMISSION.drawio","function":"HPD_MISS_PERMISSION","initial":"MISS_REQ_IDLE","state_pattern":"^[A-Z][A-Z0-9_]+$","states":[{"name":"MISS_REQ_IDLE"},{"name":"MISS_REQ_OWN_REQ"},{"name":"MISS_REQ_OWN_WAIT"},{"name":"MISS_REQ_SEND"},{"name":"MISS_REQ_OWN_ERROR"}],"transitions":[{"src":"MISS_REQ_IDLE","dst":"MISS_REQ_OWN_REQ","label":"MSHR allocation accepted"},{"src":"MISS_REQ_OWN_REQ","dst":"MISS_REQ_OWN_WAIT","label":"coh_own_req_ready_i"},{"src":"MISS_REQ_OWN_WAIT","dst":"MISS_REQ_SEND","label":"matching valid grant; no error; legal permission"},{"src":"MISS_REQ_OWN_WAIT","dst":"MISS_REQ_OWN_ERROR","label":"grant received but mismatch, error or illegal permission"},{"src":"MISS_REQ_SEND","dst":"MISS_REQ_IDLE","label":"mem_req_ready_i"},{"src":"MISS_REQ_OWN_ERROR","dst":"MISS_REQ_IDLE","label":"failed response consumed with last"}],"layout":{"margin":50}}
```

[Editable draw.io](../../../../doc/specification/figures/post_a06/figures/post_a06/HPD_MISS_PERMISSION.drawio) · [Figure source](../../../../doc/specification/figures/post_a06/figures/post_a06/HPD_MISS_PERMISSION.json).

| Transition | Current state | Guard / event | Next state |
|---|---|---|---|
| T01 | `MISS_REQ_IDLE` | MSHR allocation accepted | `MISS_REQ_OWN_REQ` |
| T02 | `MISS_REQ_OWN_REQ` | coh_own_req_ready_i | `MISS_REQ_OWN_WAIT` |
| T03 | `MISS_REQ_OWN_WAIT` | matching valid grant; no error; legal permission | `MISS_REQ_SEND` |
| T04 | `MISS_REQ_OWN_WAIT` | grant received but mismatch, error or illegal permission | `MISS_REQ_OWN_ERROR` |
| T05 | `MISS_REQ_SEND` | mem_req_ready_i | `MISS_REQ_IDLE` |
| T06 | `MISS_REQ_OWN_ERROR` | failed response consumed with last | `MISS_REQ_IDLE` |

All unspecified guards hold the current legal state in the full FSM. Reset enters `MISS_REQ_IDLE`; a phase-view entry is not a new hardware reset state. Invalid-encoding behavior follows the source and is not a normal software recovery path. / Điều kiện chưa thỏa giữ state theo FSM đầy đủ; điểm vào phase không phải reset state mới.

#### HPD-FLUSH-CAPTURE

Native SRAM capture/sending FSM; returning to FLUSH_IDLE means payload capture is complete, not that AXI B succeeded. Retained flush descriptors and accepted matching B independently determine the origin-tagged completion ACK. Dirty-tag/state mutation waits for that ACK under the cluster contract.

![hpdcache_flush FSM](../../../../doc/specification/figures/post_a06/figures/post_a06/HPD_FLUSH_CAPTURE.svg)

```json
{"page_name":"HPD_FLUSH_CAPTURE","out_name":"HPD_FLUSH_CAPTURE.drawio","function":"HPD_FLUSH_CAPTURE","initial":"FLUSH_IDLE","state_pattern":"^[A-Z][A-Z0-9_]+$","states":[{"name":"FLUSH_IDLE"},{"name":"FLUSH_SEND"}],"transitions":[{"src":"FLUSH_IDLE","dst":"FLUSH_SEND","label":"flush_alloc_i and flush_alloc_ready_o; read first word"},{"src":"FLUSH_SEND","dst":"FLUSH_IDLE","label":"flush_resizer_wok and flush_eol"}],"layout":{"margin":50}}
```

[Editable draw.io](../../../../doc/specification/figures/post_a06/figures/post_a06/HPD_FLUSH_CAPTURE.drawio) · [Figure source](../../../../doc/specification/figures/post_a06/figures/post_a06/HPD_FLUSH_CAPTURE.json).

| Transition | Current state | Guard / event | Next state |
|---|---|---|---|
| T01 | `FLUSH_IDLE` | flush_alloc_i and flush_alloc_ready_o; read first word | `FLUSH_SEND` |
| T02 | `FLUSH_SEND` | flush_resizer_wok and flush_eol | `FLUSH_IDLE` |

All unspecified guards hold the current legal state in the full FSM. Reset enters `FLUSH_IDLE`; a phase-view entry is not a new hardware reset state. Invalid-encoding behavior follows the source and is not a normal software recovery path. / Điều kiện chưa thỏa giữ state theo FSM đầy đủ; điểm vào phase không phải reset state mới.

#### CCU-LOOKUP-VICTIM

Readable phase view of the same per-context CCU FSM, not an additional controller. Entry is ENUM_ST_IDLE. The underlying reset is ENUM_ST_IDLE; omitted transitions continue in the other views/full graph. Original T numbers preserve full-graph identity.

![m_vlsit_riscv_coh_fabric FSM](../../../../doc/specification/figures/post_a06/figures/post_a06/CCU_LOOKUP_VICTIM.svg)

```json
{"page_name":"CCU_LOOKUP_VICTIM","out_name":"CCU_LOOKUP_VICTIM.drawio","function":"CCU_LOOKUP_VICTIM","initial":"ENUM_ST_IDLE","state_pattern":"^[A-Z][A-Z0-9_]+$","states":[{"name":"ENUM_ST_DIR_CANCEL"},{"name":"ENUM_ST_DIR_REQ"},{"name":"ENUM_ST_DIR_UPDATE"},{"name":"ENUM_ST_DIR_WAIT"},{"name":"ENUM_ST_EVICT_ALLOC"},{"name":"ENUM_ST_EVICT_WAIT"},{"name":"ENUM_ST_GNT"},{"name":"ENUM_ST_IDLE"},{"name":"ENUM_ST_OWNER"},{"name":"ENUM_ST_PREP_START"},{"name":"ENUM_ST_RETRY_CANCEL"}],"transitions":[{"src":"ENUM_ST_IDLE","dst":"ENUM_ST_DIR_REQ","label":"T01: alloc root","guard":"root allocation accepted"},{"src":"ENUM_ST_IDLE","dst":"ENUM_ST_OWNER","label":"T02: alloc victim","guard":"victim child allocation accepted"},{"src":"ENUM_ST_IDLE","dst":"ENUM_ST_GNT","label":"T03: reject","guard":"rejected request allocation accepted"},{"src":"ENUM_ST_DIR_REQ","dst":"ENUM_ST_DIR_WAIT","label":"T04: lookup","guard":"selected bank lookup accepted"},{"src":"ENUM_ST_DIR_WAIT","dst":"ENUM_ST_EVICT_ALLOC","label":"T05: held victim","guard":"lookup miss and victim has holders; not CMO"},{"src":"ENUM_ST_DIR_WAIT","dst":"ENUM_ST_OWNER","label":"T06: lookup result","guard":"matching lookup; no held-victim service needed"},{"src":"ENUM_ST_EVICT_ALLOC","dst":"ENUM_ST_RETRY_CANCEL","label":"T07: victim busy","guard":"victim line already locked by another context"},{"src":"ENUM_ST_RETRY_CANCEL","dst":"ENUM_ST_DIR_REQ","label":"T08: cancel retry","guard":"matching owner CANCEL accepted"},{"src":"ENUM_ST_EVICT_ALLOC","dst":"ENUM_ST_EVICT_WAIT","label":"T09: alloc child","guard":"matching victim child allocated"},{"src":"ENUM_ST_EVICT_WAIT","dst":"ENUM_ST_DIR_UPDATE","label":"T10: child commit","guard":"child COMMIT completes"},{"src":"ENUM_ST_EVICT_WAIT","dst":"ENUM_ST_DIR_CANCEL","label":"T11: child abort","guard":"child ABORT completes"},{"src":"ENUM_ST_OWNER","dst":"ENUM_ST_PREP_START","label":"T12: owner capture","guard":"matching owner metadata captured"},{"src":"ENUM_ST_DIR_UPDATE","dst":"ENUM_ST_GNT","label":"T30: update","guard":"matching bank UPDATE accepted"},{"src":"ENUM_ST_DIR_CANCEL","dst":"ENUM_ST_GNT","label":"T31: cancel","guard":"no reservation or matching CANCEL accepted"},{"src":"ENUM_ST_GNT","dst":"ENUM_ST_IDLE","label":"T33: CMO release","guard":"CMO response release accepted"}],"layout":{"margin":50,"node_gap":220,"rank_gap":220,"max_columns":3}}
```

[Editable draw.io](../../../../doc/specification/figures/post_a06/figures/post_a06/CCU_LOOKUP_VICTIM.drawio) · [Figure source](../../../../doc/specification/figures/post_a06/figures/post_a06/CCU_LOOKUP_VICTIM.json).

| Transition | Current state | Guard / event | Next state |
|---|---|---|---|
| T01 | `ENUM_ST_IDLE` | root allocation accepted | `ENUM_ST_DIR_REQ` |
| T02 | `ENUM_ST_IDLE` | victim child allocation accepted | `ENUM_ST_OWNER` |
| T03 | `ENUM_ST_IDLE` | rejected request allocation accepted | `ENUM_ST_GNT` |
| T04 | `ENUM_ST_DIR_REQ` | selected bank lookup accepted | `ENUM_ST_DIR_WAIT` |
| T05 | `ENUM_ST_DIR_WAIT` | lookup miss and victim has holders; not CMO | `ENUM_ST_EVICT_ALLOC` |
| T06 | `ENUM_ST_DIR_WAIT` | matching lookup; no held-victim service needed | `ENUM_ST_OWNER` |
| T07 | `ENUM_ST_EVICT_ALLOC` | victim line already locked by another context | `ENUM_ST_RETRY_CANCEL` |
| T08 | `ENUM_ST_RETRY_CANCEL` | matching owner CANCEL accepted | `ENUM_ST_DIR_REQ` |
| T09 | `ENUM_ST_EVICT_ALLOC` | matching victim child allocated | `ENUM_ST_EVICT_WAIT` |
| T10 | `ENUM_ST_EVICT_WAIT` | child COMMIT completes | `ENUM_ST_DIR_UPDATE` |
| T11 | `ENUM_ST_EVICT_WAIT` | child ABORT completes | `ENUM_ST_DIR_CANCEL` |
| T12 | `ENUM_ST_OWNER` | matching owner metadata captured | `ENUM_ST_PREP_START` |
| T30 | `ENUM_ST_DIR_UPDATE` | matching bank UPDATE accepted | `ENUM_ST_GNT` |
| T31 | `ENUM_ST_DIR_CANCEL` | no reservation or matching CANCEL accepted | `ENUM_ST_GNT` |
| T33 | `ENUM_ST_GNT` | CMO response release accepted | `ENUM_ST_IDLE` |

All unspecified guards hold the current legal state in the full FSM. Reset enters `ENUM_ST_IDLE`; a phase-view entry is not a new hardware reset state. Invalid-encoding behavior follows the source and is not a normal software recovery path. / Điều kiện chưa thỏa giữ state theo FSM đầy đủ; điểm vào phase không phải reset state mới.

#### CCU-PREPARE-CMO

Readable phase view of the same per-context CCU FSM, not an additional controller. Entry is ENUM_ST_PREP_START. The underlying reset is ENUM_ST_IDLE; omitted transitions continue in the other views/full graph. Original T numbers preserve full-graph identity.

![m_vlsit_riscv_coh_fabric FSM](../../../../doc/specification/figures/post_a06/figures/post_a06/CCU_PREPARE_CMO.svg)

```json
{"page_name":"CCU_PREPARE_CMO","out_name":"CCU_PREPARE_CMO.drawio","function":"CCU_PREPARE_CMO","initial":"ENUM_ST_PREP_START","state_pattern":"^[A-Z][A-Z0-9_]+$","states":[{"name":"ENUM_ST_ABORT_START"},{"name":"ENUM_ST_CMO_FINISH"},{"name":"ENUM_ST_CMO_PREPARED"},{"name":"ENUM_ST_COMMIT_START"},{"name":"ENUM_ST_PREP_START"},{"name":"ENUM_ST_PREP_WAIT"}],"transitions":[{"src":"ENUM_ST_PREP_START","dst":"ENUM_ST_PREP_WAIT","label":"T13: prepare start","guard":"matching PREPARE phase accepted"},{"src":"ENUM_ST_PREP_WAIT","dst":"ENUM_ST_CMO_PREPARED","label":"T14: CMO prepared","guard":"all PREPARE responses; source is CMO"},{"src":"ENUM_ST_PREP_WAIT","dst":"ENUM_ST_ABORT_START","label":"T15: prepare error","guard":"PREPARE complete with error or missing dirty obligation"},{"src":"ENUM_ST_PREP_WAIT","dst":"ENUM_ST_COMMIT_START","label":"T16: prepare OK","guard":"PREPARE complete and dirty obligation satisfied"},{"src":"ENUM_ST_CMO_PREPARED","dst":"ENUM_ST_CMO_FINISH","label":"T17: CMO report","guard":"i_ccu_prepare_ready"},{"src":"ENUM_ST_CMO_FINISH","dst":"ENUM_ST_COMMIT_START","label":"T18: finish commit","guard":"matching finish accepted; commit and no retained error"},{"src":"ENUM_ST_CMO_FINISH","dst":"ENUM_ST_ABORT_START","label":"T19: finish abort","guard":"matching finish accepted; abort or retained error"}],"layout":{"margin":50,"node_gap":220,"rank_gap":220,"max_columns":3}}
```

[Editable draw.io](../../../../doc/specification/figures/post_a06/figures/post_a06/CCU_PREPARE_CMO.drawio) · [Figure source](../../../../doc/specification/figures/post_a06/figures/post_a06/CCU_PREPARE_CMO.json).

| Transition | Current state | Guard / event | Next state |
|---|---|---|---|
| T13 | `ENUM_ST_PREP_START` | matching PREPARE phase accepted | `ENUM_ST_PREP_WAIT` |
| T14 | `ENUM_ST_PREP_WAIT` | all PREPARE responses; source is CMO | `ENUM_ST_CMO_PREPARED` |
| T15 | `ENUM_ST_PREP_WAIT` | PREPARE complete with error or missing dirty obligation | `ENUM_ST_ABORT_START` |
| T16 | `ENUM_ST_PREP_WAIT` | PREPARE complete and dirty obligation satisfied | `ENUM_ST_COMMIT_START` |
| T17 | `ENUM_ST_CMO_PREPARED` | i_ccu_prepare_ready | `ENUM_ST_CMO_FINISH` |
| T18 | `ENUM_ST_CMO_FINISH` | matching finish accepted; commit and no retained error | `ENUM_ST_COMMIT_START` |
| T19 | `ENUM_ST_CMO_FINISH` | matching finish accepted; abort or retained error | `ENUM_ST_ABORT_START` |

All unspecified guards hold the current legal state in the full FSM. Reset enters `ENUM_ST_IDLE`; a phase-view entry is not a new hardware reset state. Invalid-encoding behavior follows the source and is not a normal software recovery path. / Điều kiện chưa thỏa giữ state theo FSM đầy đủ; điểm vào phase không phải reset state mới.

#### CCU-COMMIT-RELEASE

Readable phase view of the same per-context CCU FSM, not an additional controller. Entry is ENUM_ST_COMMIT_START. The underlying reset is ENUM_ST_IDLE; omitted transitions continue in the other views/full graph. Original T numbers preserve full-graph identity.

![m_vlsit_riscv_coh_fabric FSM](../../../../doc/specification/figures/post_a06/figures/post_a06/CCU_COMMIT_RELEASE.svg)

```json
{"page_name":"CCU_COMMIT_RELEASE","out_name":"CCU_COMMIT_RELEASE.drawio","function":"CCU_COMMIT_RELEASE","initial":"ENUM_ST_COMMIT_START","state_pattern":"^[A-Z][A-Z0-9_]+$","states":[{"name":"ENUM_ST_COMMIT_START"},{"name":"ENUM_ST_COMMIT_WAIT"},{"name":"ENUM_ST_DIR_CANCEL"},{"name":"ENUM_ST_DIR_UPDATE"},{"name":"ENUM_ST_GNT"},{"name":"ENUM_ST_GNT_WAIT"},{"name":"ENUM_ST_IDLE"}],"transitions":[{"src":"ENUM_ST_COMMIT_START","dst":"ENUM_ST_COMMIT_WAIT","label":"T20: commit start","guard":"matching COMMIT phase accepted"},{"src":"ENUM_ST_COMMIT_WAIT","dst":"ENUM_ST_IDLE","label":"T21: victim release","guard":"victim COMMIT ACKs and immediate release"},{"src":"ENUM_ST_COMMIT_WAIT","dst":"ENUM_ST_GNT_WAIT","label":"T22: victim hold","guard":"victim COMMIT ACKs; deferred release"},{"src":"ENUM_ST_COMMIT_WAIT","dst":"ENUM_ST_DIR_CANCEL","label":"T23: CMO cancel","guard":"CMO COMMIT ACKs; no directory hit"},{"src":"ENUM_ST_COMMIT_WAIT","dst":"ENUM_ST_DIR_UPDATE","label":"T24: publish","guard":"root COMMIT ACKs; publish metadata"},{"src":"ENUM_ST_DIR_UPDATE","dst":"ENUM_ST_GNT","label":"T30: update","guard":"matching bank UPDATE accepted"},{"src":"ENUM_ST_DIR_CANCEL","dst":"ENUM_ST_GNT","label":"T31: cancel","guard":"no reservation or matching CANCEL accepted"},{"src":"ENUM_ST_GNT","dst":"ENUM_ST_GNT_WAIT","label":"T32: grant load","guard":"matching CPU grant loaded"},{"src":"ENUM_ST_GNT","dst":"ENUM_ST_IDLE","label":"T33: CMO release","guard":"CMO response release accepted"},{"src":"ENUM_ST_GNT_WAIT","dst":"ENUM_ST_IDLE","label":"T34: release","guard":"matching release accepted"}],"layout":{"margin":50,"node_gap":220,"rank_gap":220,"max_columns":3}}
```

[Editable draw.io](../../../../doc/specification/figures/post_a06/figures/post_a06/CCU_COMMIT_RELEASE.drawio) · [Figure source](../../../../doc/specification/figures/post_a06/figures/post_a06/CCU_COMMIT_RELEASE.json).

| Transition | Current state | Guard / event | Next state |
|---|---|---|---|
| T20 | `ENUM_ST_COMMIT_START` | matching COMMIT phase accepted | `ENUM_ST_COMMIT_WAIT` |
| T21 | `ENUM_ST_COMMIT_WAIT` | victim COMMIT ACKs and immediate release | `ENUM_ST_IDLE` |
| T22 | `ENUM_ST_COMMIT_WAIT` | victim COMMIT ACKs; deferred release | `ENUM_ST_GNT_WAIT` |
| T23 | `ENUM_ST_COMMIT_WAIT` | CMO COMMIT ACKs; no directory hit | `ENUM_ST_DIR_CANCEL` |
| T24 | `ENUM_ST_COMMIT_WAIT` | root COMMIT ACKs; publish metadata | `ENUM_ST_DIR_UPDATE` |
| T30 | `ENUM_ST_DIR_UPDATE` | matching bank UPDATE accepted | `ENUM_ST_GNT` |
| T31 | `ENUM_ST_DIR_CANCEL` | no reservation or matching CANCEL accepted | `ENUM_ST_GNT` |
| T32 | `ENUM_ST_GNT` | matching CPU grant loaded | `ENUM_ST_GNT_WAIT` |
| T33 | `ENUM_ST_GNT` | CMO response release accepted | `ENUM_ST_IDLE` |
| T34 | `ENUM_ST_GNT_WAIT` | matching release accepted | `ENUM_ST_IDLE` |

All unspecified guards hold the current legal state in the full FSM. Reset enters `ENUM_ST_IDLE`; a phase-view entry is not a new hardware reset state. Invalid-encoding behavior follows the source and is not a normal software recovery path. / Điều kiện chưa thỏa giữ state theo FSM đầy đủ; điểm vào phase không phải reset state mới.

#### CCU-ABORT-RELEASE

Readable phase view of the same per-context CCU FSM, not an additional controller. Entry is ENUM_ST_ABORT_START. The underlying reset is ENUM_ST_IDLE; omitted transitions continue in the other views/full graph. Original T numbers preserve full-graph identity.

![m_vlsit_riscv_coh_fabric FSM](../../../../doc/specification/figures/post_a06/figures/post_a06/CCU_ABORT_RELEASE.svg)

```json
{"page_name":"CCU_ABORT_RELEASE","out_name":"CCU_ABORT_RELEASE.drawio","function":"CCU_ABORT_RELEASE","initial":"ENUM_ST_ABORT_START","state_pattern":"^[A-Z][A-Z0-9_]+$","states":[{"name":"ENUM_ST_ABORT_START"},{"name":"ENUM_ST_ABORT_WAIT"},{"name":"ENUM_ST_DIR_CANCEL"},{"name":"ENUM_ST_GNT"},{"name":"ENUM_ST_GNT_WAIT"},{"name":"ENUM_ST_IDLE"}],"transitions":[{"src":"ENUM_ST_ABORT_START","dst":"ENUM_ST_ABORT_WAIT","label":"T25: abort start","guard":"matching ABORT phase accepted"},{"src":"ENUM_ST_ABORT_WAIT","dst":"ENUM_ST_IDLE","label":"T26: victim release","guard":"victim ABORT ACKs and immediate release"},{"src":"ENUM_ST_ABORT_WAIT","dst":"ENUM_ST_GNT_WAIT","label":"T27: victim hold","guard":"victim ABORT ACKs; deferred release"},{"src":"ENUM_ST_ABORT_WAIT","dst":"ENUM_ST_DIR_CANCEL","label":"T28: cancel owner","guard":"root ABORT ACKs and reservation retained"},{"src":"ENUM_ST_ABORT_WAIT","dst":"ENUM_ST_GNT","label":"T29: error grant","guard":"root ABORT ACKs without reservation"},{"src":"ENUM_ST_DIR_CANCEL","dst":"ENUM_ST_GNT","label":"T31: cancel","guard":"no reservation or matching CANCEL accepted"},{"src":"ENUM_ST_GNT","dst":"ENUM_ST_GNT_WAIT","label":"T32: grant load","guard":"matching CPU grant loaded"},{"src":"ENUM_ST_GNT","dst":"ENUM_ST_IDLE","label":"T33: CMO release","guard":"CMO response release accepted"},{"src":"ENUM_ST_GNT_WAIT","dst":"ENUM_ST_IDLE","label":"T34: release","guard":"matching release accepted"}],"layout":{"margin":50,"node_gap":220,"rank_gap":220,"max_columns":3}}
```

[Editable draw.io](../../../../doc/specification/figures/post_a06/figures/post_a06/CCU_ABORT_RELEASE.drawio) · [Figure source](../../../../doc/specification/figures/post_a06/figures/post_a06/CCU_ABORT_RELEASE.json).

| Transition | Current state | Guard / event | Next state |
|---|---|---|---|
| T25 | `ENUM_ST_ABORT_START` | matching ABORT phase accepted | `ENUM_ST_ABORT_WAIT` |
| T26 | `ENUM_ST_ABORT_WAIT` | victim ABORT ACKs and immediate release | `ENUM_ST_IDLE` |
| T27 | `ENUM_ST_ABORT_WAIT` | victim ABORT ACKs; deferred release | `ENUM_ST_GNT_WAIT` |
| T28 | `ENUM_ST_ABORT_WAIT` | root ABORT ACKs and reservation retained | `ENUM_ST_DIR_CANCEL` |
| T29 | `ENUM_ST_ABORT_WAIT` | root ABORT ACKs without reservation | `ENUM_ST_GNT` |
| T31 | `ENUM_ST_DIR_CANCEL` | no reservation or matching CANCEL accepted | `ENUM_ST_GNT` |
| T32 | `ENUM_ST_GNT` | matching CPU grant loaded | `ENUM_ST_GNT_WAIT` |
| T33 | `ENUM_ST_GNT` | CMO response release accepted | `ENUM_ST_IDLE` |
| T34 | `ENUM_ST_GNT_WAIT` | matching release accepted | `ENUM_ST_IDLE` |

All unspecified guards hold the current legal state in the full FSM. Reset enters `ENUM_ST_IDLE`; a phase-view entry is not a new hardware reset state. Invalid-encoding behavior follows the source and is not a normal software recovery path. / Điều kiện chưa thỏa giữ state theo FSM đầy đủ; điểm vào phase không phải reset state mới.
