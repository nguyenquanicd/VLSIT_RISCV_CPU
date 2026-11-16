<!-- ARCHITECTURE -->
### 5.1 Overview and block responsibilities

The current implementation is the AXI-only profile. Two or four CVA6 harts have private instruction caches and modified HPDcache write-back D-caches. The cluster makes D-cache ownership coherent with a shared directory and tagged two-phase probes. The instruction caches are not snooped: software must arrange local `FENCE.I` on each hart that will execute modified code. Culsans is an architectural reference; the active CCU is the new VLSIT fabric, not an unchanged Culsans integration.

Phiên bản hiện tại là profile AXI. Hai/bốn hart có I-cache riêng và HPDcache D-cache write-back đã sửa. CCU VLSIT quản lý coherence của D-cache bằng directory và probe có tag. I-cache không snoop; phần mềm phải thực hiện `FENCE.I` tại từng hart chạy code mới. Không mô tả CCU mới là RTL Culsans reuse nguyên trạng.

| Component group | Responsibility | State/data owner | Boundary |
|---|---|---|---|
| Structural TOP | Connect the core and external memory width conversion | No independent execution state | Boot, IRQ/debug, control AXI4-Lite, MMIO AXI4, memory AXI4+ATOP |
| CPU tile array | Execute instructions and route per-hart requests/events | Native pipeline, MMU, I-cache and HPDcache | Per-hart AXI, tagged ownership/probe/query/lock, retirement maintenance |
| CCU | Serialize conflicting line ownership while allowing independent contexts | Directory, transaction metadata, probe phase/ACKs and locks | Custom tagged ownership/PREPARE/COMMIT/ABORT interfaces |
| Data routing | Apply shared PMA/router regions and preserve AXI response identity | Native route/mux outstanding transaction state | Cached memory, normal-uncached bypass and separate MMIO |
| Maintenance service | Join retirement, CCU preparation and LLC terminal result | Selected instruction metadata, retained tag and error | Hart command/completion, CCU begin/prepare/finish, LLC command/done |
| LLC | Cache shared memory and implement the approved memory-visibility service | Tag/data arrays, pending descriptors and writeback/refill queues | Upstream AXI, memory AXI, RegBus service, per-line maintenance |
| CSR/PMU | Configure observation, snapshot counters and expose causes | Generated controls, counters/snapshots, sticky IRQ and fatal record | AXI4-Lite and level interrupts |

The source hierarchy and all component interfaces are specified in Section 14. An instantiated component is not automatically a functionally verified component. Section 15 names the activated test scope.

### 5.2 Block diagram

<!-- TOP_FIGURE -->

Each component diagram is embedded beside its Section 14 contract, with its editable two-tab draw.io and JSON source. Containment diagrams show real source-referenced children; leaf diagrams show only the leaf boundary. They do not add fictitious internal modules. The request/data-flow relationships that are not evident from containment are stated explicitly below and in each component contract.

Mỗi component có sơ đồ trong Section 14, kèm draw.io chỉnh sửa được và JSON. Hình phân cấp không tự suy ra liên kết dữ liệu; các luồng được mô tả riêng dưới đây. Diagram không thay bằng chứng mô phỏng.

### 5.3 Transaction and dataflow

| Flow | Ordered control/data path | Completion and backpressure |
|---|---|---|
| Private read hit | CPU → HPDcache tag/data lookup → native CPU response | No CCU transaction for an already permitted hit; array/resource conflicts can still stall it |
| Read miss | HPDcache MSHR → ownership request → CCU directory/probes → grant → native AXI refill → tag/data publication → CPU response | No refill before legal permission; failed grant/refill cannot install a valid owned line |
| Shared write | CPU store/atomic → ownership upgrade → peer PREPARE → dirty-owner writeback if required → COMMIT/invalidation → grant → local update | Same-line CPU/probe exclusion survives through terminal phase; store E→M may be silent locally |
| Dirty-owner sharing | Requester asks for a shared copy → CCU identifies recorded owner → owner writes back through its existing AXI path into LLC → matching successful B → terminal transition → requester refill | CCU does not transport a 128-bit data payload; owner writeback is the data path |
| Directory victim | Parent reserves set → victim child probes old holders → preserves dirty data → terminal child completion → parent publishes replacement | A reserved credit admits the child; a locked victim makes parent cancel its reservation before retry |
| Ordinary dirty L1 eviction | Capture victim data/tag/context → native AW/W → wait for matching B → replace/refill only on success | B error retains victim/controller context and reset-only fatal IRQ; W1C cannot resume it |
| CBO | Retirement head → arbiter → controller → CCU PREPARE/owner writeback → LLC per-line operation → COMMIT or ABORT ACKs → CPU retire or precise trap | Instruction metadata is retained; no completion on request acceptance alone |
| FENCE.I | Drain older stores → scan/clean local dirty lines into LLC with CCU protection → local fetch/I-cache synchronization → retirement | No mandatory LLC-to-DRAM clean; failed L1-to-LLC B waits for ABORT then cause 24 |
| Device access | CPU PMA classification → per-hart route → MMIO mux → external SoC peripheral fabric → B/R → originating hart | No directory/LLC access for MMIO; external fabric owns peripheral decode |
| PMU snapshot | Native event taps → packing/selection → enabled counters → common snapshot edge → stable CSR low/high reads | Explicit snapshot command; reading low alone does not create a snapshot |
| Fatal diagnostic | Matching failed ordinary L1 B or non-maintenance LLC B → first-fault capture → RO CSR + level fault IRQ | Retain first payload to reset; later errors set multiple without overwriting |

The table specifies ordering, not a fixed number of cycles. A request handshake reserves work; completion is a separate obligation whenever the interface has an ACK/done/result.

Luồng dirty data đi qua AXI hiện có của owner đến LLC, không đi qua payload của CCU. Mọi thao tác có completion phải chờ completion thật, không hoàn tất ngay khi nhận request. Các bước trên xác định thứ tự, không đặt latency chưa đo.

### 5.4 Invariants

1. A physical line may have one writer or multiple shared readers, never conflicting writers. Native E may become M silently; directory metadata is refined by actual PREPARE observations.
2. A conservative extra holder is reconciled by validated absence. A false-negative holder is unsafe. Directory publication occurs only after the required terminal operation succeeds.
3. Dirty data/tag/descriptor identity remains recoverable until its matching successful AXI B. A write address or last W beat is not proof of successful writeback.
4. Context tag, physical line, phase and destination hart remain associated through stalls, error handling and tag reuse. Invalid responses cannot complete an unrelated transaction.
5. Root allocation preserves a victim escape credit. A requester cannot wait for another context while retaining the set reservation that prevents that context from completing.
6. PREPARE, COMMIT and ABORT have no ACK timeout. Safety is maintained by retention; eventual progress requires eventual legal responses or reset.
7. After acceptance of a retirement-blocking maintenance command, interrupt/debug entry is deferred to its terminal completion. Cache/probe/AXI work remains enabled so the command can finish.
8. Reset is the only recovery for ordinary fatal dirty-eviction retention. The fault record does not undo an externally visible write or make in-flight reset safe.

### 5.5 Component provenance

`NEW` means VLSIT logic designed for this cluster; `MODIFY` means a licensed native local copy with recorded changes; `REUSE` means a pristine upstream source; `GENERATED` means byte-exact CSR tool output. Native names are deliberately preserved inside licensed components. The VLSIT coding rule applies to new wrappers/components, not as an instruction to rename pristine reuse. A source-file classification does not imply that every conditional module/branch in that file elaborates in the selected profile.

NEW là logic mới; MODIFY là bản native có sửa và history; REUSE giữ nguyên source; GENERATED là output generator không sửa tay. Không đánh đồng có tên trong filelist với đã instantiate hoặc đã kích hoạt trong mô phỏng.

<!-- INTERFACES -->
### 6.1 Interface inventory

All current external interfaces share `i_clk_cluster`. The SoC supplies asynchronous reset assertion and synchronized deassertion at `i_rst_n_cluster`. There is no APB port in the current cluster.

| Interface | Cluster role | Payload / identity | State owner and use |
|---|---|---|---|
| AXI4-Lite control | Subordinate | 32-bit address/data; independent read and write channels | Decoder queues → generated CSR or native LLC RegBus service |
| AXI4 MMIO | Manager | 64-bit address/data, 6-bit extended ID | Per-hart routing/mux; external fabric decodes peripherals |
| AXI4+ATOP memory | Manager | 64-bit address; 7-bit ID; 32/64/128/256-bit external data parameter | Native LLC/bypass/mux/width-converter association; SoC supplies atomic service |
| Boot | Input | Shared 64-bit boot address; zero-based hart IDs are internally assigned | Held stable through reset release under SoC integration contract |
| Per-hart interrupts | Inputs | Fixed four-slot vectors; only active harts are used | CVA6 privilege/trap logic; external interrupt controllers are SoC-owned |
| Debug | Per-hart request/status | External DM requests; hart reports debug mode | Native CVA6; no integrated JTAG/DMI DM/DTM |
| PMU/fatal IRQ | Level outputs | Aggregate PMU pending; reset-only fatal retention | PMU raw/enabled cause and fatal cache state respectively |

The ACE external profile is deferred and has no implemented current TOP. Do not connect an external coherent DMA agent to the AXI memory boundary and assume snoop service. Internal tagged two-phase interfaces are custom source-defined channels; their semantic relationship to the earlier ACE-subset architecture must not be advertised as literal AC/CR/CD wire compatibility without a separate mapping review.

Profile ACE ngoài được hoãn. AXI ngoài không snoop cache. Các kênh tagged PREPARE/COMMIT/ABORT hiện tại là interface nội bộ có định nghĩa riêng; không tuyên bố chúng tương thích chân ACE chỉ từ tên kiến trúc ban đầu.

<!-- INTERNAL_INTERFACES -->
### 6.3 Internal interface contracts

| Interface | Initiator → service | Payload and qualifiers | Retained obligation / failure |
|---|---|---|---|
| Ownership request/grant | HPDcache/tile → CCU → requesting tile | Native source request ID, physical line, access kind; grant permission/error | Request/grant stable through ready stalls; refill/atomic update waits for a legal matching grant |
| Busy/line query | Tile adapter → native HPDcache | Physical line compared with MSHR, refill, pipeline and atomic/victim activity | Query does not reserve or modify cache data; actual probe admission and array ownership are separate |
| Tagged probe | Scheduler → selected hart | Slot tag, line, phase, target MESI, writeback enable; response state/error/writeback result | One active service per cache; prepared identity remains through matching COMMIT/ABORT |
| Directory lookup | Bank arbiter → directory | Tag/source, physical line, set/bank and access intent | Response/reservation belongs to that tag; held victim requires replacement service |
| Directory UPDATE/CANCEL | Context owner → reserved set | Matching tag/reservation and committed holder/owner/state | Owner CANCEL must remain eligible while another UPDATE is blocked |
| Owner writeback | Probe/flush controller → native AXI → LLC | Origin-tagged descriptor, way/set/data/ID; matching accepted B | Keep dirty state/data on error; source-specific ACK determines precise versus fatal handling |
| Retirement CMO | CVA6 hart → arbiter/controller → hart | Operation, physical line, effective VA, PC and selected hart | Accepted instruction cannot be lost by interrupt/debug/flush; response only after terminal cleanup |
| CCU CMO service | Controller ↔ fabric | Begin request, prepared tag/error, retained finish commit/abort and done | Controller waits for preparation; finish done means terminal ACKs/context service completed |
| Native LLC per-line service | Controller → LLC | Operation and 52-bit 16-byte physical line index; valid/ready, done/error | One retained service descriptor; dirty/tag transition waits for successful B |
| Native LLC software service | AXI4-Lite bridge → RegBus | Native offset, write direction/data/strobes; request valid/response ready/data/error | Hold request until ready and then AXI response until consumed; runtime SPM writes rejected |
| Event taps | CVA6/HPDcache/LLC/CCU → PMU | Source catalog indicators or explicit occurrence counts | Source units are preserved; count unavailable/reserved selections as zero |
| Fatal record event | Accepted L1/LLC failed writeback → record | Exact victim address, source, raw response; hart valid only for L1 | Event pulse, not sticky IRQ level; later events cannot replace first payload |

Section 14 lists the exact declarations at every component boundary, preserving native type parameters where applicable. Interface names in this table describe bundles rather than new invented RTL ports. Request and response directions can differ within the same bundle. All stateful channels follow the appropriate source-defined ready/valid or pulse-completion contract; there is no universal ACK-ready signal.

### 6.4 Interrupt and debug obligations

`o_int_pmu` is the level reduction of enabled raw overflow causes. Software clears handled causes through the generated CSR's documented priority rules. `o_int_fault` includes retained fatal ordinary cache writeback state and cannot be recovered by diagnostic W1C. External per-hart IRQ/debug inputs are wired to native CVA6 but their full operational qualification remains open. Once CMO is accepted, selected interrupt/debug deferral policy A applies until success or a precise terminal error; a missing downstream response may therefore defer that hart indefinitely.

IRQ PMU có thể xóa qua CSR theo đúng priority. Fault fatal chỉ phục hồi bằng reset. Trì hoãn IRQ/debug khi CMO đã nhận là quyết định đã duyệt; không được hứa bound hữu hạn khi chính sách ACK không timeout.

<!-- WORKING_FLOWS -->
### 10.5 End-to-end working flows and storage ownership

#### 10.5.1 Cache hit, miss, refill and upgrade

1. CPU translation/PMA identifies the operation's physical class. A permitted L1 hit reads/writes native arrays. E→M is a local dirty transition; S→M needs ownership upgrade.
2. A miss captures its source identity in an MSHR. The miss-request FSM requests CCU permission before issuing external refill traffic. A denied or mismatched grant returns an error, not a speculative install.
3. CCU allocates a context, reserves/looks up the directory set and identifies potential holders. Recorded holder metadata is conservative; PREPARE checks actual state and absence.
4. If an owner is dirty and the operation requires clean/shared visibility, that owner's native flush path reads the real SRAM data and writes it to LLC over AXI. PREPARE waits for the matching B outcome.
5. COMMIT publishes permitted state and holder changes only after all required successful observations. ABORT preserves the old recoverable state. A requester grant uses retained request identity.
6. After permission, native refill writes data and then valid/exclusive metadata only under the error contract. An unsuccessful refill may leave a conservative extra directory holder; a later valid PREPARE-I reconciles it without creating a cache line.

Cache hit không có nghĩa luôn chạy song song với probe: CPU hit khác line chỉ tiếp tục nếu không tranh chấp tag/data array, replay, refill hoặc flush. Miss có thể chờ ownership và dữ liệu owner trước khi bắt đầu refill. Không dùng số transaction context để suy ra IPC tăng tương ứng.

#### 10.5.2 Ordinary eviction and asynchronous fatal error

1. Choose/capture a dirty victim and retain its original tag/way/set and data.
2. Send native writeback AW/W while preserving descriptor identity.
3. On accepted matching B=OKAY, permit the replacement/refill/tag transition.
4. On failed B, preserve victim SRAM/tag/context and assert retained fatal status; drain already issued responses but do not retry or free the failed controller context automatically.
5. Capture first-fault metadata from the real transaction. LLC reconstructs the victim address from the evicted tag plus retained set index, not the incoming refill address. Shared LLC does not invent a hart owner.
6. Firmware reads diagnostics before SoC-controlled recovery/reset. In-flight external traffic must be handled by the SoC reset contract; the record alone provides no recovery mechanism.

#### 10.5.3 CBO retirement, success and precise fault

1. A decoded/translated CBO reaches retirement head with PC/effective VA/line/op retained. Older LSU stores and native cache activity drain to the approved point.
2. The arbiter accepts exactly one selected hart command and retains its completion destination. Interrupt/debug entry for that active operation is deferred.
3. The controller allocates/prepares a CCU context. Native cache PREPARE and owner writeback preserve the original data on failure.
4. On successful preparation, issue the requested per-line native LLC maintenance. When memory visibility is required, completion waits for actual downstream writeback B.
5. Select COMMIT on success or ABORT on error. Keep context/locks until all expected terminal ACKs and cleanup complete.
6. Return the final result to the selected hart. Success retires the CBO; failure takes the approved precise synchronous trap before that instruction retires. Younger architectural effects remain blocked.

#### 10.5.4 FENCE.I clean-to-LLC and cause 24

1. Retain the fence at retirement and drain prior stores. The local cache's scan/flush progress must not be confused with a completed instruction.
2. Clean local dirty data into shared LLC with directory/owner exclusion. This operation does not require writing LLC contents out to DRAM.
3. For each failed L1-to-LLC B preserve dirty state, perform required ABORT and wait for all ACKs. Then trap at the fence PC with custom cause 24 and aligned physical line value under DEC-031; do not retire or perform success-only fetch synchronization.
4. Only after successful clean completion invalidate/synchronize local I-cache/fetch state and retire. Other harts need their own software-triggered `FENCE.I` before executing modified instructions.

#### 10.5.5 Atomic execution and reservation

Cached AMO/LR-SC executes in native L1 with CCU-protected ownership/reservation semantics. A shared LR does not acquire permanent write ownership; SC/AMO must obtain the required exclusive permission and preserve reservation/probe interactions. The result is the old value or architectural SC success/failure, not an arbitrary AXI response. Cached tests cannot qualify normal-uncached atomics: the latter retain the approved AXI4+ATOP/locking transport and require a SoC atomic-capable target. A response filter that returns SLVERR is not an atomic implementation.

#### 10.5.6 Directory replacement and escape progress

A root requires enough free slots to preserve a victim child credit. The parent may reserve a set while selecting its directory victim. If another context already locks that victim line, the parent releases its own reservation with CANCEL and retries rather than blocking the other transaction's UPDATE. Once child service starts, child/tag and parent association must survive PREPARE/COMMIT/ABORT and delayed grant release. At default N=8 at most seven roots are admitted; a full-context directed pass does not prove every possible wait-for cycle absent.

#### 10.5.7 PMU measurement path

Native event expressions retain their real units. Per-hart indicators are summed across active harts for aggregate scope; CCU transaction counts preserve simultaneous occurrences, while stall/full indicators count active cycles. A per-hart OR-reduced native category cannot be relabeled as exact multi-issue instruction count. Counters update modulo their configured width. Snapshot captures the pre-edge live bank on one edge and remains stable until the next command/reset; increments on that edge affect the subsequent live value. Software uses explicit snapshot/done and then low/high words. Use independently validated architectural `instret` and `cycle` when reporting IPC.

### 10.6 Native non-enum lifecycles

| Lifecycle | Retained state | Legal advance | Error / stall |
|---|---|---|---|
| LLC per-line service | `maint_pending_q`, `maint_busy_q`, retained descriptor | Accept valid/ready; enqueue descriptor; terminal done clears busy | No premature tag/dirty update; failed writeback preserves data |
| L1 flush completion | Descriptor valid, origin, line/ID and B association | SRAM capture FSM can finish before B; only matching B creates completion ACK | Invalid B/ID is diagnostic; ordinary failure retains fatal state |
| Retirement maintenance | Retained PC/VA/op, active command/completion/error | Issue once; consume terminal result; retire or trap | No interrupt/debug flush may discard accepted work |
| Probe scheduler | Per-hart request/active/ACK and phase-owner flags | Request handshake → matching response → ACK consumption; terminal phase releases owner | Hold payload on stall; mismatch drains diagnostic without completing context |
| CSR queues | Independent AW/W/read entries and response valid bits | Complete queued write/read selected; response consumed | Stable B/R under backpressure; preserve documented hardware/software priority |
| First-fatal record | Valid, payload and multiple | First event captures; later events set multiple; reset clears | No software-clear transition |

These are stateful contracts even when there is no enum variable. They are not new RTL modules or invented state names. Native optional ECC/scrub, MMU, FPU and protocol helper FSMs retain their source-owned behavior; conditional branch qualification remains a Section 15 integration task.

Các lifecycle trên có trạng thái lưu giữ dù không dùng enum. Không tạo state giả để làm sơ đồ. Các nhánh native tùy chọn phải được verify theo cấu hình thực, không mặc nhiên PASS vì file được compile.

<!-- ERRORS -->
## 12. Error handling and recovery

| Error class | Architectural/software result | Data/state preservation | Recovery |
|---|---|---|---|
| CBO preparation or LLC maintenance failure | Precise synchronous failure before CBO retirement, approved Store/AMO access-fault path | Keep original recoverable dirty metadata; complete ABORT ACKs first | Software trap handler; retry only after platform handles the cause |
| FENCE.I L1-to-LLC writeback failure | Custom synchronous cause 24 at the fence PC; physical aligned failing line under DEC-031 | Failed dirty line/directory state preserved; no success-only I-cache completion | Trap handler and platform-specific repair/retry |
| Cached atomic permission/refill/owner failure | Native precise architectural error with original request identity | No false valid/exclusive installation or conflicting ownership | Native trap handling; reservation rules preserved |
| Ordinary L1 dirty eviction failed B | Sticky fatal IRQ and first-fault source/address/raw response with exact hart | Hold victim data/tag/context; drain issued responses; no automatic retry | Reset-only fatal recovery contract |
| Non-maintenance LLC failed writeback B | Sticky fatal state and first-fault source/address/raw response; `hart_valid=0` | Keep dirty victim and descriptor; do not publish destructive replacement/clean state | Reset-only fatal recovery contract |
| Invalid probe/ACK/update/cancel identity | Separate sticky diagnostic status, W1C under its defined CSR rules | Do not let malformed work complete/release an unrelated context | Drain/reject only as defined by source; retained legitimate context remains |
| Invalid control or memory access | Source-specific AXI error response | Do not issue unsupported work or alias another CSR bank | Firmware corrects address/operation; not a cache recovery command |
| Missing legal downstream B/R/phase ACK | No timeout fabricated | Hold association/lock/context; drain other legal work where resources permit | Eventual legal response or SoC reset |

DEC-039 retains the first fatal ordinary writeback record to reset. Later independent events set `multiple`; simultaneous priority is lowest active L1 hart then LLC. DEC-040 gives valid hart attribution only to L1. An LLC record with zero hart bits and `hart_valid=0` does not implicate hart 0. Precise atomic/CBO/FENCE errors do not automatically populate the ordinary fatal record. The workbook is authoritative for field layout and software access.

Diagnostic W1C does not clear a fatal dirty-cache condition or release retained cache/CCU state. Successful response draining does not imply the interrupted workload can continue after fatal retention. Hot reset with in-flight external traffic remains a SoC integration obligation.

Lỗi precise chỉ báo sau cleanup/ABORT đúng thứ tự; lỗi eviction thông thường là fatal bất đồng bộ và giữ dữ liệu đến reset. Không dùng W1C để giả phục hồi cache. Không suy ra LLC hart owner từ giá trị zero.

<!-- PERFORMANCE -->
## 13. Performance, power, and area

No FCLK, area, power or IPC target has been supplied with a library/corner, SRAM and workload. Logical concurrency is not a PPA guarantee. Report measured cycles and assumptions before comparing configurations.

| Case | Critical work and serialization | Worst-case interpretation |
|---|---|---|
| Permitted private hit | Native tag/data access; no CCU ownership transaction | Array conflict, replay/flush/atomic activity may stall it; no guaranteed hit-under-all-probes |
| Cold clean miss | Permission request, bank lookup, optional holder probes, AXI refill | Sum of control and refill service plus queueing; not merely DRAM latency |
| Shared upgrade | Line lock and peer invalidation/terminal ACKs before write | Cost grows with the slowest required holder, resource contention and terminal service |
| Dirty-owner transfer | Owner SRAM capture, AXI writeback into LLC, matching B, terminal transition, requester refill | No grant on AW/W acceptance; stalled owner B blocks that line/context |
| Ordinary dirty replacement | One resident native replacement context waits for B before refill | A-03 correctness-first controller pause includes B round trip; failed B can stop that cache controller to reset |
| Directory capacity conflict | Eight-way victim selection, victim context, holder service, parent update | N=8 has seven root credits; selected victim locked elsewhere requires cancel/relookup |
| Probe throughput | One active service per cache; prepared owner association spans terminal phase | More CCU contexts cannot bypass one cache's array/probe bottleneck |
| Four directory banks | Independent eligible requests may use different banks | Same-bank/set/reservation conflicts serialize; four banks do not guarantee four grants per cycle |
| Full memory/response queues | Native mux/LLC/adapter backpressure preserves ordering | Arbitrary external stall produces no finite global latency bound |
| Missing ACK / fatal error | Retain safe state rather than infer completion | Worst-case latency is unbounded by approved policy; interrupt/debug can be deferred for the active CMO |
| Wider external memory | More payload bits per accepted beat; internal LLC remains 64-bit | Does not widen the CPU datapath or eliminate bank/ownership/packing bottlenecks; TOP width matrix not yet functionally closed |
| PMU measurement | Event IDs/scopes/units and snapshot window must be correct | Current PMU integration is not yet a validated source of IPC/bandwidth claims |

For a bounded environment, express a miss/service time as measured components rather than inventing cycle constants:

$$T_{miss}=T_{queue}+T_{permission}+T_{owner\,writeback}+T_{terminal}+T_{refill}+T_{publication}.$$

Some terms are absent for a private clean case and some can overlap; report the observed critical path, not the sum as an unconditional equality of independent pipeline stages. For useful work over an agreed measurement window:

$$IPC=\frac{\Delta instret}{\Delta cycle},\qquad BW=\frac{bytes\ transferred}{elapsed\ time}.$$

Use actual retired instructions, not an OR-reduced load/store category. Measure 2/4 harts, hit/miss/shared/dirty/conflict mixes and stalls separately. Fault/error recovery cases describe lost progress, not peak throughput. Power gating, retention and DVFS are excluded; native WFI and technology-approved clock gating still need SoC qualification.

Chưa có cơ sở tuyên bố IPC, tần số hoặc công suất đạt mục tiêu. Phải đo đúng workload, SRAM/library/corner và điều kiện backpressure. Thêm context/bank/bit bus không tự bảo đảm throughput tăng tương ứng. ACK mất làm worst case không có bound hữu hạn theo quyết định đã duyệt.
