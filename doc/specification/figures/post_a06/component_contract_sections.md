#### 14.4.1 `m_csr_async_fifo` — GENERATED

Source: [rtl/common/vlsit/csr/RTL/models/m_csr_async_fifo.sv](../../rtl/vlsit/csr_generated/RTL/models/m_csr_async_fifo.sv). Selected production source: **True**.

**Function.** Provide the generator's optional dual-clock request/response FIFO implementation.

**Working/data flow.** Maintain binary/Gray pointers, synchronize pointers across the two domains and expose full/empty-qualified transfers in asynchronous configurations.

**State and storage ownership.** Payload memory, pointers and synchronizer state.

**Safety, timing and error constraints.** The current cluster ties CSR clocks to the same cluster domain; optional asynchronous generator branches are not evidence of a required cluster CDC path. Do not claim CDC qualification from TOP lint.

**Verification boundary.** Generated collateral is included; asynchronous configuration is outside current cluster functional evidence.

The figure shows actual child composition; a leaf shows its own boundary. It does not invent intermediate RTL modules. / Hình thể hiện phân cấp source; leaf chỉ có symbol ranh giới, không tạo module giả.

![m_csr_async_fifo composition](figures/post_a06/m_csr_async_fifo.svg)

```json
{"page_name":"BLOCK_DIAGRAM","out_name":"m_csr_async_fifo.drawio","layout":{"gap_h":120,"gap_v":110,"margin":80,"block_h":60},"top":{"frame_label":["Component composition","(m_csr_async_fifo)"]},"frame_row":["m_csr_async_fifo","Provide the generator's optional dual-clock request/response FIFO implementation.","rtl/common/vlsit/csr/RTL/models/m_csr_async_fifo.sv"],"frame_interfaces":["IN","OUT"],"blocks":[{"key":"B0","label":["component_boundary","(m_csr_async_fifo)"],"width":220,"row":0,"col":0,"row_name":"component_boundary (m_csr_async_fifo)","function":"Provide the generator's optional dual-clock request/response FIFO implementation.","source":"GENERATED; rtl/common/vlsit/csr/RTL/models/m_csr_async_fifo.sv"}],"connectors":[],"externals":[{"id":"IN","block":"B0","side":"L","dir":"in","pos":0,"text":["IN","ports"]},{"id":"OUT","block":"B0","side":"R","dir":"out","pos":0,"text":["OUT","ports"]}],"interfaces":[{"id":"IN","name":"Parent in ports","category":"custom","active":"in","signals":"i_clk_wr, i_rst_n_wr, i_w_valid, i_w_data, i_clk_rd, i_rst_n_rd, i_r_ready"},{"id":"OUT","name":"Parent out ports","category":"custom","active":"out","signals":"o_w_ready, o_r_valid, o_r_data"}],"nets":[],"legend_note":"A single boundary symbol denotes a leaf: internal equations/registers are described in its function/dataflow contract, not invented child modules. NEW/MODIFY/REUSE/GENERATED provenance is listed in the block table. Clock/reset follow the common synchronous contract. Complete parent port declarations are in the component section.","library_sha256":"15DFB183E267D2A94F8CAB316E01EB3D2E9D2F9C006DC816790A394F4123506C"}
```

[Editable draw.io](figures/post_a06/m_csr_async_fifo.drawio) · [Figure source](figures/post_a06/m_csr_async_fifo.json).

**Interface contract.** All synchronous ports use the common cluster clock; the probe engine cache clock is the same domain in this cluster. A valid/ready payload is accepted only on the corresponding handshake and held through backpressure. Pulsed completion/ACK interfaces are described by the operation/FSM contract; they must not be treated as independent ready/valid channels.

| Direction | Exact source declaration |
|---|---|
| input | `wire i_clk_wr` |
| input | `wire i_rst_n_wr` |
| input | `wire i_w_valid` |
| output | `logic o_w_ready` |
| input | `wire [PARA_DATA_W-1:0] i_w_data` |
| input | `wire i_clk_rd` |
| input | `wire i_rst_n_rd` |
| output | `logic o_r_valid` |
| input | `wire i_r_ready` |
| output | `logic [PARA_DATA_W-1:0] o_r_data` |

**FSM:** No new enum controller is declared by this module. Its combinational mapping, queue/valid-bit lifecycle, or instantiated child FSMs implement the behavior above. This is not a claim that the entire subtree is stateless.

#### 14.4.2 `m_csr_sync_fifo` — GENERATED

Source: [rtl/common/vlsit/csr/RTL/models/m_csr_sync_fifo.sv](../../rtl/vlsit/csr_generated/RTL/models/m_csr_sync_fifo.sv). Selected production source: **True**.

**Function.** Provide the generated CSR's synchronous queued request/response storage.

**Working/data flow.** Accept a write only when space exists, expose the oldest payload when nonempty and advance read/write/count state on actual handshakes.

**State and storage ownership.** Fixed-depth payload array, pointers and count.

**Safety, timing and error constraints.** Simultaneous enqueue/dequeue and response stalls must preserve ordering. The cluster uses the synchronous CSR path; asynchronous models remain generator collateral.

**Verification boundary.** Exercised by A-06 AXI4-Lite operations; exhaustive standalone FIFO parameter coverage is not claimed.

The figure shows actual child composition; a leaf shows its own boundary. It does not invent intermediate RTL modules. / Hình thể hiện phân cấp source; leaf chỉ có symbol ranh giới, không tạo module giả.

![m_csr_sync_fifo composition](figures/post_a06/m_csr_sync_fifo.svg)

```json
{"page_name":"BLOCK_DIAGRAM","out_name":"m_csr_sync_fifo.drawio","layout":{"gap_h":120,"gap_v":110,"margin":80,"block_h":60},"top":{"frame_label":["Component composition","(m_csr_sync_fifo)"]},"frame_row":["m_csr_sync_fifo","Provide the generated CSR's synchronous queued request/response storage.","rtl/common/vlsit/csr/RTL/models/m_csr_sync_fifo.sv"],"frame_interfaces":["IN","OUT"],"blocks":[{"key":"B0","label":["component_boundary","(m_csr_sync_fifo)"],"width":220,"row":0,"col":0,"row_name":"component_boundary (m_csr_sync_fifo)","function":"Provide the generated CSR's synchronous queued request/response storage.","source":"GENERATED; rtl/common/vlsit/csr/RTL/models/m_csr_sync_fifo.sv"}],"connectors":[],"externals":[{"id":"IN","block":"B0","side":"L","dir":"in","pos":0,"text":["IN","ports"]},{"id":"OUT","block":"B0","side":"R","dir":"out","pos":0,"text":["OUT","ports"]}],"interfaces":[{"id":"IN","name":"Parent in ports","category":"custom","active":"in","signals":"i_clk_bus, i_rst_n_bus, i_w_valid, i_w_data, i_r_ready"},{"id":"OUT","name":"Parent out ports","category":"custom","active":"out","signals":"o_w_ready, o_r_valid, o_r_data"}],"nets":[],"legend_note":"A single boundary symbol denotes a leaf: internal equations/registers are described in its function/dataflow contract, not invented child modules. NEW/MODIFY/REUSE/GENERATED provenance is listed in the block table. Clock/reset follow the common synchronous contract. Complete parent port declarations are in the component section.","library_sha256":"15DFB183E267D2A94F8CAB316E01EB3D2E9D2F9C006DC816790A394F4123506C"}
```

[Editable draw.io](figures/post_a06/m_csr_sync_fifo.drawio) · [Figure source](figures/post_a06/m_csr_sync_fifo.json).

**Interface contract.** All synchronous ports use the common cluster clock; the probe engine cache clock is the same domain in this cluster. A valid/ready payload is accepted only on the corresponding handshake and held through backpressure. Pulsed completion/ACK interfaces are described by the operation/FSM contract; they must not be treated as independent ready/valid channels.

| Direction | Exact source declaration |
|---|---|
| input | `wire i_clk_bus` |
| input | `wire i_rst_n_bus` |
| input | `wire i_w_valid` |
| output | `logic o_w_ready` |
| input | `wire [PARA_DATA_W-1:0] i_w_data` |
| output | `logic o_r_valid` |
| input | `wire i_r_ready` |
| output | `logic [PARA_DATA_W-1:0] o_r_data` |

**FSM:** No new enum controller is declared by this module. Its combinational mapping, queue/valid-bit lifecycle, or instantiated child FSMs implement the behavior above. This is not a claim that the entire subtree is stateless.

#### 14.4.3 `m_vlsit_axi_llc` — NEW

Source: [rtl/common/vlsit/cache/m_vlsit_axi_llc.sv](../../rtl/vlsit/m_vlsit_axi_llc.sv). Selected production source: **True**.

**Function.** Wrap the licensed native LLC with VLSIT AXI/service/maintenance and fault-event ports.

**Working/data flow.** Translate flat ports into native AXI and RegBus records, service CPU/memory requests and forward per-line maintenance. Route native completion/error/events back to the cluster and forward a pulse plus victim address/raw B response for fatal non-maintenance writeback errors.

**State and storage ownership.** Native LLC owns tag/data SRAMs, descriptor queues and pending writeback/refill state. The wrapper changes naming/types, not cache policy.

**Safety, timing and error constraints.** Default 4 ways x 4096 lines x 2 blocks x 8 bytes = 256 KiB. The reference maintenance contract uses 16-byte lines. Larger PARA_LLC_BLOCK_NUM values are not functionally qualified. Runtime SPM is blocked.

**Verification boundary.** Native LLC units and reduced-geometry CPU tests pass; default 256-KiB system stress and native CSR BIST/flush remain open.

The figure shows actual child composition; a leaf shows its own boundary. It does not invent intermediate RTL modules. / Hình thể hiện phân cấp source; leaf chỉ có symbol ranh giới, không tạo module giả.

![m_vlsit_axi_llc composition](figures/post_a06/m_vlsit_axi_llc.svg)

```json
{"page_name":"BLOCK_DIAGRAM","out_name":"m_vlsit_axi_llc.drawio","layout":{"gap_h":120,"gap_v":110,"margin":80,"block_h":60},"top":{"frame_label":["Component composition","(m_vlsit_axi_llc)"]},"frame_row":["m_vlsit_axi_llc","Wrap the licensed native LLC with VLSIT AXI/service/maintenance and fault-event ports.","rtl/common/vlsit/cache/m_vlsit_axi_llc.sv"],"frame_interfaces":[],"blocks":[{"key":"B0","label":["u_dont_touch_axi_llc_reg_wrap","(axi_llc_reg_wrap)"],"width":340,"row":0,"col":0,"row_name":"u_dont_touch_axi_llc_reg_wrap (axi_llc_reg_wrap)","function":"Native LLC software wrapper","source":"MODIFY; rtl/common/modified/axi_llc/src/axi_llc_reg_wrap.sv"}],"connectors":[],"externals":[],"interfaces":[],"nets":[],"legend_note":"Exact source-referenced children; generate multiplicity and active branches are specified in the component text. Containment denotes hierarchy, not invented signal connectivity. NEW/MODIFY/REUSE/GENERATED provenance is listed in the block table. Clock/reset follow the common synchronous contract. Complete parent port declarations are in the component section.","library_sha256":"15DFB183E267D2A94F8CAB316E01EB3D2E9D2F9C006DC816790A394F4123506C"}
```

[Editable draw.io](figures/post_a06/m_vlsit_axi_llc.drawio) · [Figure source](figures/post_a06/m_vlsit_axi_llc.json).

**Interface contract.** All synchronous ports use the common cluster clock; the probe engine cache clock is the same domain in this cluster. A valid/ready payload is accepted only on the corresponding handshake and held through backpressure. Pulsed completion/ACK interfaces are described by the operation/FSM contract; they must not be treated as independent ready/valid channels.

| Direction | Exact source declaration |
|---|---|
| input | `wire i_clk_cluster` |
| input | `wire i_rst_n_cluster` |
| input | `wire i_test_en` |
| input | `wire [63:0] i_cached_start_addr` |
| input | `wire [63:0] i_cached_end_addr` |
| input | `wire [5:0] i_axi_cpu_awid` |
| input | `wire [5:0] i_axi_cpu_awatop` |
| input | `wire [63:0] i_axi_cpu_awaddr` |
| input | `wire [7:0] i_axi_cpu_awlen` |
| input | `wire [2:0] i_axi_cpu_awsize` |
| input | `wire [1:0] i_axi_cpu_awburst` |
| input | `wire i_axi_cpu_awlock` |
| input | `wire [3:0] i_axi_cpu_awcache` |
| input | `wire [2:0] i_axi_cpu_awprot` |
| input | `wire [3:0] i_axi_cpu_awqos` |
| input | `wire [3:0] i_axi_cpu_awregion` |
| input | `wire i_axi_cpu_awvalid` |
| output | `logic o_axi_cpu_awready` |
| input | `wire [63:0] i_axi_cpu_wdata` |
| input | `wire [7:0] i_axi_cpu_wstrb` |
| input | `wire i_axi_cpu_wlast` |
| input | `wire i_axi_cpu_wvalid` |
| output | `logic o_axi_cpu_wready` |
| output | `logic [5:0] o_axi_cpu_bid` |
| output | `logic [1:0] o_axi_cpu_bresp` |
| output | `logic o_axi_cpu_bvalid` |
| input | `wire i_axi_cpu_bready` |
| input | `wire [5:0] i_axi_cpu_arid` |
| input | `wire [63:0] i_axi_cpu_araddr` |
| input | `wire [7:0] i_axi_cpu_arlen` |
| input | `wire [2:0] i_axi_cpu_arsize` |
| input | `wire [1:0] i_axi_cpu_arburst` |
| input | `wire i_axi_cpu_arlock` |
| input | `wire [3:0] i_axi_cpu_arcache` |
| input | `wire [2:0] i_axi_cpu_arprot` |
| input | `wire [3:0] i_axi_cpu_arqos` |
| input | `wire [3:0] i_axi_cpu_arregion` |
| input | `wire i_axi_cpu_arvalid` |
| output | `logic o_axi_cpu_arready` |
| output | `logic [5:0] o_axi_cpu_rid` |
| output | `logic [63:0] o_axi_cpu_rdata` |
| output | `logic [1:0] o_axi_cpu_rresp` |
| output | `logic o_axi_cpu_rlast` |
| output | `logic o_axi_cpu_rvalid` |
| input | `wire i_axi_cpu_rready` |
| output | `logic [6:0] o_axi_mem_awid` |
| output | `logic [5:0] o_axi_mem_awatop` |
| output | `logic [63:0] o_axi_mem_awaddr` |
| output | `logic [7:0] o_axi_mem_awlen` |
| output | `logic [2:0] o_axi_mem_awsize` |
| output | `logic [1:0] o_axi_mem_awburst` |
| output | `logic o_axi_mem_awlock` |
| output | `logic [3:0] o_axi_mem_awcache` |
| output | `logic [2:0] o_axi_mem_awprot` |
| output | `logic [3:0] o_axi_mem_awqos` |
| output | `logic [3:0] o_axi_mem_awregion` |
| output | `logic o_axi_mem_awvalid` |
| input | `wire i_axi_mem_awready` |
| output | `logic [63:0] o_axi_mem_wdata` |
| output | `logic [7:0] o_axi_mem_wstrb` |
| output | `logic o_axi_mem_wlast` |
| output | `logic o_axi_mem_wvalid` |
| input | `wire i_axi_mem_wready` |
| input | `wire [6:0] i_axi_mem_bid` |
| input | `wire [1:0] i_axi_mem_bresp` |
| input | `wire i_axi_mem_bvalid` |
| output | `logic o_axi_mem_bready` |
| output | `logic [6:0] o_axi_mem_arid` |
| output | `logic [63:0] o_axi_mem_araddr` |
| output | `logic [7:0] o_axi_mem_arlen` |
| output | `logic [2:0] o_axi_mem_arsize` |
| output | `logic [1:0] o_axi_mem_arburst` |
| output | `logic o_axi_mem_arlock` |
| output | `logic [3:0] o_axi_mem_arcache` |
| output | `logic [2:0] o_axi_mem_arprot` |
| output | `logic [3:0] o_axi_mem_arqos` |
| output | `logic [3:0] o_axi_mem_arregion` |
| output | `logic o_axi_mem_arvalid` |
| input | `wire i_axi_mem_arready` |
| input | `wire [6:0] i_axi_mem_rid` |
| input | `wire [63:0] i_axi_mem_rdata` |
| input | `wire [1:0] i_axi_mem_rresp` |
| input | `wire i_axi_mem_rlast` |
| input | `wire i_axi_mem_rvalid` |
| output | `logic o_axi_mem_rready` |
| input | `wire i_maint_valid` |
| output | `logic o_maint_ready` |
| input | `wire [1:0] i_maint_op` |
| input | `wire [51:0] i_maint_pa_line` |
| output | `logic o_maint_done` |
| output | `logic o_maint_error` |
| input | `wire i_reg_req_valid` |
| input | `wire i_reg_req_wr` |
| input | `wire [6:0] i_reg_req_addr` |
| input | `wire [31:0] i_reg_req_wdata` |
| input | `wire [3:0] i_reg_req_wstrb` |
| output | `logic o_reg_rsp_ready` |
| output | `logic [31:0] o_reg_rsp_rdata` |
| output | `logic o_reg_rsp_err` |
| output | `logic o_wb_fault` |
| output | `logic o_wb_fault_event` |
| output | `logic [63:0] o_wb_fault_addr` |
| output | `logic [1:0] o_wb_fault_resp` |
| output | `logic [27:0] o_llc_events` |

**FSM:** No new enum controller is declared by this module. Its combinational mapping, queue/valid-bit lifecycle, or instantiated child FSMs implement the behavior above. This is not a claim that the entire subtree is stateless.

#### 14.4.4 `m_vlsit_axil_reg_bridge` — NEW

Source: [rtl/common/vlsit/control/m_vlsit_axil_reg_bridge.sv](../../rtl/vlsit/m_vlsit_axil_reg_bridge.sv). Selected production source: **True**.

**Function.** Translate AXI4-Lite LLC-service accesses into the pinned PULP RegBus request/response form.

**Working/data flow.** Queue AW and W independently and arbitrate a complete write against a queued read. Decode legal native LLC offsets, reject forbidden writes including runtime SPM control, hold one RegBus request until ready, then retain AXI B/R through backpressure.

**State and storage ownership.** One read and one write entry, retained RegBus request, response registers and three-state FSM.

**Safety, timing and error constraints.** A request ready handshake is the RegBus response point; no APB converter exists. WSTRB must reach the native target. Read-only/unmapped/misaligned accesses must follow this bridge's documented response, distinct from generated CSR behavior.

**Verification boundary.** Connected and lint-clean from TOP; native BIST/flush/status and concurrent software traffic still need active integration tests.

The figure shows actual child composition; a leaf shows its own boundary. It does not invent intermediate RTL modules. / Hình thể hiện phân cấp source; leaf chỉ có symbol ranh giới, không tạo module giả.

![m_vlsit_axil_reg_bridge composition](figures/post_a06/m_vlsit_axil_reg_bridge.svg)

```json
{"page_name":"BLOCK_DIAGRAM","out_name":"m_vlsit_axil_reg_bridge.drawio","layout":{"gap_h":120,"gap_v":110,"margin":80,"block_h":60},"top":{"frame_label":["Component composition","(m_vlsit_axil_reg_bridge)"]},"frame_row":["m_vlsit_axil_reg_bridge","Translate AXI4-Lite LLC-service accesses into the pinned PULP RegBus request/response form.","rtl/common/vlsit/control/m_vlsit_axil_reg_bridge.sv"],"frame_interfaces":["IN","OUT"],"blocks":[{"key":"B0","label":["component_boundary","(m_vlsit_axil_reg_bridge)"],"width":300,"row":0,"col":0,"row_name":"component_boundary (m_vlsit_axil_reg_bridge)","function":"Translate AXI4-Lite LLC-service accesses into the pinned PULP RegBus request/response form.","source":"NEW; rtl/common/vlsit/control/m_vlsit_axil_reg_bridge.sv"}],"connectors":[],"externals":[{"id":"IN","block":"B0","side":"L","dir":"in","pos":0,"text":["IN","ports"]},{"id":"OUT","block":"B0","side":"R","dir":"out","pos":0,"text":["OUT","ports"]}],"interfaces":[{"id":"IN","name":"Parent in ports","category":"custom","active":"in","signals":"i_clk_cluster, i_rst_n_cluster, i_axil_awaddr, i_axil_awprot, i_axil_awvalid, i_axil_wdata, i_axil_wstrb, i_axil_wvalid, i_axil_bready, i_axil_araddr, i_axil_arprot, i_axil_arvalid, i_axil_rready, i_reg_rsp_ready, i_reg_rsp_rdata, i_reg_rsp_err"},{"id":"OUT","name":"Parent out ports","category":"custom","active":"out","signals":"o_axil_awready, o_axil_wready, o_axil_bresp, o_axil_bvalid, o_axil_arready, o_axil_rdata, o_axil_rresp, o_axil_rvalid, o_reg_req_valid, o_reg_req_wr, o_reg_req_addr, o_reg_req_wdata, o_reg_req_wstrb"}],"nets":[],"legend_note":"A single boundary symbol denotes a leaf: internal equations/registers are described in its function/dataflow contract, not invented child modules. NEW/MODIFY/REUSE/GENERATED provenance is listed in the block table. Clock/reset follow the common synchronous contract. Complete parent port declarations are in the component section.","library_sha256":"15DFB183E267D2A94F8CAB316E01EB3D2E9D2F9C006DC816790A394F4123506C"}
```

[Editable draw.io](figures/post_a06/m_vlsit_axil_reg_bridge.drawio) · [Figure source](figures/post_a06/m_vlsit_axil_reg_bridge.json).

**Interface contract.** All synchronous ports use the common cluster clock; the probe engine cache clock is the same domain in this cluster. A valid/ready payload is accepted only on the corresponding handshake and held through backpressure. Pulsed completion/ACK interfaces are described by the operation/FSM contract; they must not be treated as independent ready/valid channels.

| Direction | Exact source declaration |
|---|---|
| input | `wire i_clk_cluster` |
| input | `wire i_rst_n_cluster` |
| input | `wire [31:0] i_axil_awaddr` |
| input | `wire [2:0] i_axil_awprot` |
| input | `wire i_axil_awvalid` |
| output | `logic o_axil_awready` |
| input | `wire [31:0] i_axil_wdata` |
| input | `wire [3:0] i_axil_wstrb` |
| input | `wire i_axil_wvalid` |
| output | `logic o_axil_wready` |
| output | `logic [1:0] o_axil_bresp` |
| output | `logic o_axil_bvalid` |
| input | `wire i_axil_bready` |
| input | `wire [31:0] i_axil_araddr` |
| input | `wire [2:0] i_axil_arprot` |
| input | `wire i_axil_arvalid` |
| output | `logic o_axil_arready` |
| output | `logic [31:0] o_axil_rdata` |
| output | `logic [1:0] o_axil_rresp` |
| output | `logic o_axil_rvalid` |
| input | `wire i_axil_rready` |
| output | `logic o_reg_req_valid` |
| output | `logic o_reg_req_wr` |
| output | `logic [6:0] o_reg_req_addr` |
| output | `logic [31:0] o_reg_req_wdata` |
| output | `logic [3:0] o_reg_req_wstrb` |
| input | `wire i_reg_rsp_ready` |
| input | `wire [31:0] i_reg_rsp_rdata` |
| input | `wire i_reg_rsp_err` |

**FSM:** [AXIL_REGBUS](#axil-regbus). See Section 10.1 for every transition and retained obligation.

#### 14.4.5 `m_vlsit_cpucl_csr` — GENERATED

Source: [rtl/common/vlsit/csr/RTL/m_vlsit_cpucl_csr.sv](../../rtl/vlsit/csr_generated/RTL/m_vlsit_cpucl_csr.sv). Selected production source: **True**.

**Function.** Implement workbook-defined AXI4-Lite PMU controls, snapshot words, IRQ/diagnostic status and read-only fatal records.

**Working/data flow.** Accept queued AXI4-Lite operations, apply byte write masks and workbook access rules, perform hardware/software field priority, and return stable registered responses. Supply configuration outputs to PMU and sample hardware read-only inputs from counters and first-fault record.

**State and storage ownership.** Generated register fields and request/response queues. All generator outputs remain byte-identical to provenance; never hand-edit generated RTL.

**Safety, timing and error constraints.** Canonical AXIL_QUEUED workbook and recorded v3.5 generator define field names and semantics. Hardware writes win for generated W1C fields. A mandatory version-at-zero rule in the newer skill conflicts with the approved existing ABI; do not silently move the control register or add a register during this documentation rewrite.

**Verification boundary.** A-06 verifies RO fault words, writes, strobes, reserved accesses and reset; active PMU/snapshot/IRQ operation remains to qualify.

The figure shows actual child composition; a leaf shows its own boundary. It does not invent intermediate RTL modules. / Hình thể hiện phân cấp source; leaf chỉ có symbol ranh giới, không tạo module giả.

![m_vlsit_cpucl_csr composition](figures/post_a06/m_vlsit_cpucl_csr.svg)

```json
{"page_name":"BLOCK_DIAGRAM","out_name":"m_vlsit_cpucl_csr.drawio","layout":{"gap_h":120,"gap_v":110,"margin":80,"block_h":60},"top":{"frame_label":["Component composition","(m_vlsit_cpucl_csr)"]},"frame_row":["m_vlsit_cpucl_csr","Implement workbook-defined AXI4-Lite PMU controls, snapshot words, IRQ/diagnostic status and read-only fatal records.","rtl/common/vlsit/csr/RTL/m_vlsit_cpucl_csr.sv"],"frame_interfaces":[],"blocks":[{"key":"B0","label":["u_axi_rd_cmd_fifo","(m_csr_async_fifo)"],"width":220,"row":0,"col":0,"row_name":"u_axi_rd_cmd_fifo (m_csr_async_fifo)","function":"Provide the generator's optional dual-clock request/response FIFO implementation.","source":"GENERATED; rtl/common/vlsit/csr/RTL/models/m_csr_async_fifo.sv"},{"key":"B1","label":["u_axi_rd_rsp_fifo","(m_csr_async_fifo)"],"width":220,"row":0,"col":1,"row_name":"u_axi_rd_rsp_fifo (m_csr_async_fifo)","function":"Provide the generator's optional dual-clock request/response FIFO implementation.","source":"GENERATED; rtl/common/vlsit/csr/RTL/models/m_csr_async_fifo.sv"},{"key":"B2","label":["u_axi_wr_cmd_fifo","(m_csr_async_fifo)"],"width":220,"row":1,"col":0,"row_name":"u_axi_wr_cmd_fifo (m_csr_async_fifo)","function":"Provide the generator's optional dual-clock request/response FIFO implementation.","source":"GENERATED; rtl/common/vlsit/csr/RTL/models/m_csr_async_fifo.sv"},{"key":"B3","label":["u_axi_wr_rsp_fifo","(m_csr_async_fifo)"],"width":220,"row":1,"col":1,"row_name":"u_axi_wr_rsp_fifo (m_csr_async_fifo)","function":"Provide the generator's optional dual-clock request/response FIFO implementation.","source":"GENERATED; rtl/common/vlsit/csr/RTL/models/m_csr_async_fifo.sv"},{"key":"B4","label":["u_axi_rd_cmd_fifo","(m_csr_sync_fifo)"],"width":200,"row":2,"col":0,"row_name":"u_axi_rd_cmd_fifo (m_csr_sync_fifo)","function":"Provide the generated CSR's synchronous queued request/response storage.","source":"GENERATED; rtl/common/vlsit/csr/RTL/models/m_csr_sync_fifo.sv"},{"key":"B5","label":["u_axi_rd_rsp_fifo","(m_csr_sync_fifo)"],"width":200,"row":2,"col":1,"row_name":"u_axi_rd_rsp_fifo (m_csr_sync_fifo)","function":"Provide the generated CSR's synchronous queued request/response storage.","source":"GENERATED; rtl/common/vlsit/csr/RTL/models/m_csr_sync_fifo.sv"},{"key":"B6","label":["u_axi_wr_cmd_fifo","(m_csr_sync_fifo)"],"width":200,"row":3,"col":0,"row_name":"u_axi_wr_cmd_fifo (m_csr_sync_fifo)","function":"Provide the generated CSR's synchronous queued request/response storage.","source":"GENERATED; rtl/common/vlsit/csr/RTL/models/m_csr_sync_fifo.sv"},{"key":"B7","label":["u_axi_wr_rsp_fifo","(m_csr_sync_fifo)"],"width":200,"row":3,"col":1,"row_name":"u_axi_wr_rsp_fifo (m_csr_sync_fifo)","function":"Provide the generated CSR's synchronous queued request/response storage.","source":"GENERATED; rtl/common/vlsit/csr/RTL/models/m_csr_sync_fifo.sv"}],"connectors":[],"externals":[],"interfaces":[],"nets":[],"legend_note":"Exact source-referenced children; generate multiplicity and active branches are specified in the component text. Containment denotes hierarchy, not invented signal connectivity. NEW/MODIFY/REUSE/GENERATED provenance is listed in the block table. Clock/reset follow the common synchronous contract. Complete parent port declarations are in the component section.","library_sha256":"15DFB183E267D2A94F8CAB316E01EB3D2E9D2F9C006DC816790A394F4123506C"}
```

[Editable draw.io](figures/post_a06/m_vlsit_cpucl_csr.drawio) · [Figure source](figures/post_a06/m_vlsit_cpucl_csr.json).

**Interface contract.** All synchronous ports use the common cluster clock; the probe engine cache clock is the same domain in this cluster. A valid/ready payload is accepted only on the corresponding handshake and held through backpressure. Pulsed completion/ACK interfaces are described by the operation/FSM contract; they must not be treated as independent ready/valid channels.

| Direction | Exact source declaration |
|---|---|
| input | `wire i_clk_axi` |
| input | `wire i_rst_n_axi` |
| input | `wire i_clk_reg` |
| input | `wire i_rst_n_reg` |
| input | `wire i_axi_awvalid` |
| output | `logic o_axi_awready` |
| input | `wire [LPARA_ADDR_W-1:0] i_axi_awaddr` |
| input | `wire [2:0] i_axi_awprot` |
| input | `wire i_axi_wvalid` |
| output | `logic o_axi_wready` |
| input | `wire [LPARA_DATA_W-1:0] i_axi_wdata` |
| input | `wire [LPARA_STRB_W-1:0] i_axi_wstrb` |
| output | `logic o_axi_bvalid` |
| input | `wire i_axi_bready` |
| output | `logic [1:0] o_axi_bresp` |
| input | `wire i_axi_arvalid` |
| output | `logic o_axi_arready` |
| input | `wire [LPARA_ADDR_W-1:0] i_axi_araddr` |
| input | `wire [2:0] i_axi_arprot` |
| output | `logic o_axi_rvalid` |
| input | `wire i_axi_rready` |
| output | `logic [LPARA_DATA_W-1:0] o_axi_rdata` |
| output | `logic [1:0] o_axi_rresp` |
| output | `logic o_pmu_ctrl_snapshot_req` |
| input | `wire i_hw_clr_pmu_ctrl_snapshot_req` |
| output | `logic o_pmu_ctrl_snapshot_done` |
| input | `wire i_hw_wdata_pmu_snap_done` |
| input | `wire i_hw_we_pmu_ctrl_snapshot_done` |
| output | `logic [31:0] o_irq_en_overflow_en` |
| output | `logic [31:0] o_irq_raw_overflow` |
| input | `wire [31:0] i_hw_wdata_irq_raw_overflow` |
| input | `wire i_hw_we_irq_raw_overflow` |
| input | `wire [31:0] i_irq_sts_overflow_pending` |
| output | `logic o_cpucl_coh_fault` |
| input | `wire i_hw_wdata_cpucl_coh_fault` |
| input | `wire i_hw_we_cpucl_coh_fault` |
| output | `logic [PARA_PMU_EVT_COUNT-1:0][15:0] o_pmu_evt_event_id` |
| output | `logic [PARA_PMU_EVT_COUNT-1:0][2:0] o_pmu_evt_scope` |
| output | `logic [PARA_PMU_EVT_COUNT-1:0] o_pmu_evt_en` |
| input | `wire [PARA_PMU_COUNT_LO_COUNT-1:0][31:0] i_pmu_count_lo_value` |
| input | `wire [PARA_PMU_COUNT_HI_COUNT-1:0][31:0] i_pmu_count_hi_value` |
| input | `wire [31:0] i_cpucl_fault_sts_value` |
| input | `wire [31:0] i_cpucl_fault_info_value` |
| input | `wire [31:0] i_cpucl_fault_lo_value` |
| input | `wire [31:0] i_cpucl_fault_hi_value` |

**FSM:** No new enum controller is declared by this module. Its combinational mapping, queue/valid-bit lifecycle, or instantiated child FSMs implement the behavior above. This is not a claim that the entire subtree is stateless.

#### 14.4.6 `m_vlsit_pmu_aggregate` — NEW

Source: [rtl/common/vlsit/pmu/m_vlsit_pmu_aggregate.sv](../../rtl/vlsit/m_vlsit_pmu_aggregate.sv). Selected production source: **True**.

**Function.** Sum the same event indicator across active harts without discarding simultaneous occurrences.

**Working/data flow.** Mask inactive harts and add the selected bit from each active hart into a three-bit count for every per-hart catalog position.

**State and storage ownership.** Combinational sums; counter storage is downstream.

**Safety, timing and error constraints.** Four simultaneous hart indicators produce four, not one. This cannot recover multiplicity already lost inside one native source indicator.

**Verification boundary.** RTL is present and linted; independent source-to-counter checks are pending.

The figure shows actual child composition; a leaf shows its own boundary. It does not invent intermediate RTL modules. / Hình thể hiện phân cấp source; leaf chỉ có symbol ranh giới, không tạo module giả.

![m_vlsit_pmu_aggregate composition](figures/post_a06/m_vlsit_pmu_aggregate.svg)

```json
{"page_name":"BLOCK_DIAGRAM","out_name":"m_vlsit_pmu_aggregate.drawio","layout":{"gap_h":120,"gap_v":110,"margin":80,"block_h":60},"top":{"frame_label":["Component composition","(m_vlsit_pmu_aggregate)"]},"frame_row":["m_vlsit_pmu_aggregate","Sum the same event indicator across active harts without discarding simultaneous occurrences.","rtl/common/vlsit/pmu/m_vlsit_pmu_aggregate.sv"],"frame_interfaces":["IN","OUT"],"blocks":[{"key":"B0","label":["component_boundary","(m_vlsit_pmu_aggregate)"],"width":280,"row":0,"col":0,"row_name":"component_boundary (m_vlsit_pmu_aggregate)","function":"Sum the same event indicator across active harts without discarding simultaneous occurrences.","source":"NEW; rtl/common/vlsit/pmu/m_vlsit_pmu_aggregate.sv"}],"connectors":[],"externals":[{"id":"IN","block":"B0","side":"L","dir":"in","pos":0,"text":["IN","ports"]},{"id":"OUT","block":"B0","side":"R","dir":"out","pos":0,"text":["OUT","ports"]}],"interfaces":[{"id":"IN","name":"Parent in ports","category":"custom","active":"in","signals":"i_hart_active, i_hart_evt"},{"id":"OUT","name":"Parent out ports","category":"custom","active":"out","signals":"o_evt_cnt"}],"nets":[],"legend_note":"A single boundary symbol denotes a leaf: internal equations/registers are described in its function/dataflow contract, not invented child modules. NEW/MODIFY/REUSE/GENERATED provenance is listed in the block table. Clock/reset follow the common synchronous contract. Complete parent port declarations are in the component section.","library_sha256":"15DFB183E267D2A94F8CAB316E01EB3D2E9D2F9C006DC816790A394F4123506C"}
```

[Editable draw.io](figures/post_a06/m_vlsit_pmu_aggregate.drawio) · [Figure source](figures/post_a06/m_vlsit_pmu_aggregate.json).

**Interface contract.** All synchronous ports use the common cluster clock; the probe engine cache clock is the same domain in this cluster. A valid/ready payload is accepted only on the corresponding handshake and held through backpressure. Pulsed completion/ACK interfaces are described by the operation/FSM contract; they must not be treated as independent ready/valid channels.

| Direction | Exact source declaration |
|---|---|
| input | `wire [PARA_CPU_NUM-1:0] i_hart_active` |
| input | `wire [PARA_CPU_NUM-1:0][LPARA_HART_EVT_NUM-1:0] i_hart_evt` |
| output | `logic [LPARA_HART_EVT_NUM-1:0][2:0] o_evt_cnt` |

**FSM:** No new enum controller is declared by this module. Its combinational mapping, queue/valid-bit lifecycle, or instantiated child FSMs implement the behavior above. This is not a claim that the entire subtree is stateless.

#### 14.4.7 `m_vlsit_pmu_cluster_evt` — NEW

Source: [rtl/common/vlsit/pmu/m_vlsit_pmu_cluster_evt.sv](../../rtl/vlsit/m_vlsit_pmu_cluster_evt.sv). Selected production source: **True**.

**Function.** Pack LLC single-bit indicators and CCU three-bit same-cycle occurrence counts into cluster event slots.

**Working/data flow.** Zero-extend each LLC indicator and preserve each CCU count without OR-reducing it. Place LLC slots before the twelve CCU event slots according to the catalog.

**State and storage ownership.** Combinational mapping.

**Safety, timing and error constraints.** Transaction events and stall-cycle events have different units. A single-bit LLC signal may indicate one source event or activity; software meaning must agree with the actual tap.

**Verification boundary.** CCU count tap units exist; complete native LLC event semantics and software readout remain unqualified.

The figure shows actual child composition; a leaf shows its own boundary. It does not invent intermediate RTL modules. / Hình thể hiện phân cấp source; leaf chỉ có symbol ranh giới, không tạo module giả.

![m_vlsit_pmu_cluster_evt composition](figures/post_a06/m_vlsit_pmu_cluster_evt.svg)

```json
{"page_name":"BLOCK_DIAGRAM","out_name":"m_vlsit_pmu_cluster_evt.drawio","layout":{"gap_h":120,"gap_v":110,"margin":80,"block_h":60},"top":{"frame_label":["Component composition","(m_vlsit_pmu_cluster_evt)"]},"frame_row":["m_vlsit_pmu_cluster_evt","Pack LLC single-bit indicators and CCU three-bit same-cycle occurrence counts into cluster event slots.","rtl/common/vlsit/pmu/m_vlsit_pmu_cluster_evt.sv"],"frame_interfaces":["IN","OUT"],"blocks":[{"key":"B0","label":["component_boundary","(m_vlsit_pmu_cluster_evt)"],"width":300,"row":0,"col":0,"row_name":"component_boundary (m_vlsit_pmu_cluster_evt)","function":"Pack LLC single-bit indicators and CCU three-bit same-cycle occurrence counts into cluster event slots.","source":"NEW; rtl/common/vlsit/pmu/m_vlsit_pmu_cluster_evt.sv"}],"connectors":[],"externals":[{"id":"IN","block":"B0","side":"L","dir":"in","pos":0,"text":["IN","ports"]},{"id":"OUT","block":"B0","side":"R","dir":"out","pos":0,"text":["OUT","ports"]}],"interfaces":[{"id":"IN","name":"Parent in ports","category":"custom","active":"in","signals":"i_llc_evt, i_ccu_evt_count"},{"id":"OUT","name":"Parent out ports","category":"custom","active":"out","signals":"o_cluster_evt_count"}],"nets":[],"legend_note":"A single boundary symbol denotes a leaf: internal equations/registers are described in its function/dataflow contract, not invented child modules. NEW/MODIFY/REUSE/GENERATED provenance is listed in the block table. Clock/reset follow the common synchronous contract. Complete parent port declarations are in the component section.","library_sha256":"15DFB183E267D2A94F8CAB316E01EB3D2E9D2F9C006DC816790A394F4123506C"}
```

[Editable draw.io](figures/post_a06/m_vlsit_pmu_cluster_evt.drawio) · [Figure source](figures/post_a06/m_vlsit_pmu_cluster_evt.json).

**Interface contract.** All synchronous ports use the common cluster clock; the probe engine cache clock is the same domain in this cluster. A valid/ready payload is accepted only on the corresponding handshake and held through backpressure. Pulsed completion/ACK interfaces are described by the operation/FSM contract; they must not be treated as independent ready/valid channels.

| Direction | Exact source declaration |
|---|---|
| input | `wire [27:0] i_llc_evt` |
| input | `wire [11:0][2:0] i_ccu_evt_count` |
| output | `logic [LPARA_CLUSTER_EVT_NUM-1:0][2:0] o_cluster_evt_count` |

**FSM:** No new enum controller is declared by this module. Its combinational mapping, queue/valid-bit lifecycle, or instantiated child FSMs implement the behavior above. This is not a claim that the entire subtree is stateless.

#### 14.4.8 `m_vlsit_pmu_counter_bank` — NEW

Source: [rtl/common/vlsit/pmu/m_vlsit_pmu_counter_bank.sv](../../rtl/vlsit/m_vlsit_pmu_counter_bank.sv). Selected production source: **True**.

**Function.** Accumulate enabled event occurrence counts modulo the configured counter width and emit carry/overflow events.

**Working/data flow.** Zero-extend the current value and event count, compute a width-plus-one sum, update an enabled nonzero count on the clock edge and expose the carry as the corresponding overflow event.

**State and storage ownership.** PARA_PMU_CNT_NUM live counters, each 32 or 64 bits.

**Safety, timing and error constraints.** Counts wrap modulo 2^W; saturation is not implemented. Carries can coincide with software IRQ clear or snapshot and need explicit integration tests.

**Verification boundary.** Connected/linted; true wrap, enable, multiplicity and same-edge snapshot tests remain pending.

The figure shows actual child composition; a leaf shows its own boundary. It does not invent intermediate RTL modules. / Hình thể hiện phân cấp source; leaf chỉ có symbol ranh giới, không tạo module giả.

![m_vlsit_pmu_counter_bank composition](figures/post_a06/m_vlsit_pmu_counter_bank.svg)

```json
{"page_name":"BLOCK_DIAGRAM","out_name":"m_vlsit_pmu_counter_bank.drawio","layout":{"gap_h":120,"gap_v":110,"margin":80,"block_h":60},"top":{"frame_label":["Component composition","(m_vlsit_pmu_counter_bank)"]},"frame_row":["m_vlsit_pmu_counter_bank","Accumulate enabled event occurrence counts modulo the configured counter width and emit carry/overflow events.","rtl/common/vlsit/pmu/m_vlsit_pmu_counter_bank.sv"],"frame_interfaces":["IN","OUT"],"blocks":[{"key":"B0","label":["component_boundary","(m_vlsit_pmu_counter_bank)"],"width":300,"row":0,"col":0,"row_name":"component_boundary (m_vlsit_pmu_counter_bank)","function":"Accumulate enabled event occurrence counts modulo the configured counter width and emit carry/overflow events.","source":"NEW; rtl/common/vlsit/pmu/m_vlsit_pmu_counter_bank.sv"}],"connectors":[],"externals":[{"id":"IN","block":"B0","side":"L","dir":"in","pos":0,"text":["IN","ports"]},{"id":"OUT","block":"B0","side":"R","dir":"out","pos":0,"text":["OUT","ports"]}],"interfaces":[{"id":"IN","name":"Parent in ports","category":"custom","active":"in","signals":"i_clk_cluster, i_rst_n_cluster, i_pmu_cnt_en, i_evt_cnt"},{"id":"OUT","name":"Parent out ports","category":"custom","active":"out","signals":"o_pmu_cnt_val, o_pmu_cnt_ovf"}],"nets":[],"legend_note":"A single boundary symbol denotes a leaf: internal equations/registers are described in its function/dataflow contract, not invented child modules. NEW/MODIFY/REUSE/GENERATED provenance is listed in the block table. Clock/reset follow the common synchronous contract. Complete parent port declarations are in the component section.","library_sha256":"15DFB183E267D2A94F8CAB316E01EB3D2E9D2F9C006DC816790A394F4123506C"}
```

[Editable draw.io](figures/post_a06/m_vlsit_pmu_counter_bank.drawio) · [Figure source](figures/post_a06/m_vlsit_pmu_counter_bank.json).

**Interface contract.** All synchronous ports use the common cluster clock; the probe engine cache clock is the same domain in this cluster. A valid/ready payload is accepted only on the corresponding handshake and held through backpressure. Pulsed completion/ACK interfaces are described by the operation/FSM contract; they must not be treated as independent ready/valid channels.

| Direction | Exact source declaration |
|---|---|
| input | `wire i_clk_cluster` |
| input | `wire i_rst_n_cluster` |
| input | `wire [PARA_PMU_CNT_NUM-1:0] i_pmu_cnt_en` |
| input | `wire [PARA_PMU_CNT_NUM-1:0][LPARA_EVT_COUNT_W-1:0] i_evt_cnt` |
| output | `logic [PARA_PMU_CNT_NUM-1:0][PARA_PMU_CNT_W-1:0] o_pmu_cnt_val` |
| output | `logic [PARA_PMU_CNT_NUM-1:0] o_pmu_cnt_ovf` |

**FSM:** No new enum controller is declared by this module. Its combinational mapping, queue/valid-bit lifecycle, or instantiated child FSMs implement the behavior above. This is not a claim that the entire subtree is stateless.

#### 14.4.9 `m_vlsit_pmu_event_select` — NEW

Source: [rtl/common/vlsit/pmu/m_vlsit_pmu_event_select.sv](../../rtl/vlsit/m_vlsit_pmu_event_select.sv). Selected production source: **True**.

**Function.** Decode each software event ID and scope into an occurrence count for one counter.

**Working/data flow.** For per-hart scope select an existing active hart; for aggregate scope select the precomputed active-hart sum; for cluster scope select LLC/CCU slots. Unknown IDs, absent harts and unsupported source/scope pairs yield zero.

**State and storage ownership.** Combinational selector; programming fields are stored in generated CSR.

**Safety, timing and error constraints.** Do not interpret scope values as unrestricted array indices. Keep software catalog ranges synchronized with native sources and reserved IDs.

**Verification boundary.** TOP lint only for full software use; boundary ID/scope and invalid-selection tests are required.

The figure shows actual child composition; a leaf shows its own boundary. It does not invent intermediate RTL modules. / Hình thể hiện phân cấp source; leaf chỉ có symbol ranh giới, không tạo module giả.

![m_vlsit_pmu_event_select composition](figures/post_a06/m_vlsit_pmu_event_select.svg)

```json
{"page_name":"BLOCK_DIAGRAM","out_name":"m_vlsit_pmu_event_select.drawio","layout":{"gap_h":120,"gap_v":110,"margin":80,"block_h":60},"top":{"frame_label":["Component composition","(m_vlsit_pmu_event_select)"]},"frame_row":["m_vlsit_pmu_event_select","Decode each software event ID and scope into an occurrence count for one counter.","rtl/common/vlsit/pmu/m_vlsit_pmu_event_select.sv"],"frame_interfaces":["IN","OUT"],"blocks":[{"key":"B0","label":["component_boundary","(m_vlsit_pmu_event_select)"],"width":300,"row":0,"col":0,"row_name":"component_boundary (m_vlsit_pmu_event_select)","function":"Decode each software event ID and scope into an occurrence count for one counter.","source":"NEW; rtl/common/vlsit/pmu/m_vlsit_pmu_event_select.sv"}],"connectors":[],"externals":[{"id":"IN","block":"B0","side":"L","dir":"in","pos":0,"text":["IN","ports"]},{"id":"OUT","block":"B0","side":"R","dir":"out","pos":0,"text":["OUT","ports"]}],"interfaces":[{"id":"IN","name":"Parent in ports","category":"custom","active":"in","signals":"i_hart_active, i_hart_evt, i_hart_agg_evt_count, i_cluster_evt_count, i_pmu_evt_id, i_pmu_evt_scope"},{"id":"OUT","name":"Parent out ports","category":"custom","active":"out","signals":"o_pmu_evt_count"}],"nets":[],"legend_note":"A single boundary symbol denotes a leaf: internal equations/registers are described in its function/dataflow contract, not invented child modules. NEW/MODIFY/REUSE/GENERATED provenance is listed in the block table. Clock/reset follow the common synchronous contract. Complete parent port declarations are in the component section.","library_sha256":"15DFB183E267D2A94F8CAB316E01EB3D2E9D2F9C006DC816790A394F4123506C"}
```

[Editable draw.io](figures/post_a06/m_vlsit_pmu_event_select.drawio) · [Figure source](figures/post_a06/m_vlsit_pmu_event_select.json).

**Interface contract.** All synchronous ports use the common cluster clock; the probe engine cache clock is the same domain in this cluster. A valid/ready payload is accepted only on the corresponding handshake and held through backpressure. Pulsed completion/ACK interfaces are described by the operation/FSM contract; they must not be treated as independent ready/valid channels.

| Direction | Exact source declaration |
|---|---|
| input | `wire [PARA_CPU_NUM-1:0] i_hart_active` |
| input | `wire [PARA_CPU_NUM-1:0][LPARA_HART_EVT_NUM-1:0] i_hart_evt` |
| input | `wire [LPARA_HART_EVT_NUM-1:0][2:0] i_hart_agg_evt_count` |
| input | `wire [LPARA_CLUSTER_EVT_NUM-1:0][2:0] i_cluster_evt_count` |
| input | `wire [PARA_PMU_CNT_NUM-1:0][15:0] i_pmu_evt_id` |
| input | `wire [PARA_PMU_CNT_NUM-1:0][2:0] i_pmu_evt_scope` |
| output | `logic [PARA_PMU_CNT_NUM-1:0][2:0] o_pmu_evt_count` |

**FSM:** No new enum controller is declared by this module. Its combinational mapping, queue/valid-bit lifecycle, or instantiated child FSMs implement the behavior above. This is not a claim that the entire subtree is stateless.

#### 14.4.10 `m_vlsit_pmu_hart_evt` — NEW

Source: [rtl/common/vlsit/pmu/m_vlsit_pmu_hart_evt.sv](../../rtl/vlsit/m_vlsit_pmu_hart_evt.sv). Selected production source: **True**.

**Function.** Pack CVA6 and HPDcache source indicators into a stable per-hart catalog order.

**Working/data flow.** Concatenate 22 CVA6 and 16 HPDcache source bits for each active hart; preserve each source's pulse/level meaning for the selector.

**State and storage ownership.** Combinational packing only.

**Safety, timing and error constraints.** A source indicator may mean active cycles rather than instruction occurrences. OR-reduced native event sources must not be advertised as arbitrary multi-issue popcounts.

**Verification boundary.** Source wiring inspected and hierarchy linted; complete event-by-event functional mapping is pending.

The figure shows actual child composition; a leaf shows its own boundary. It does not invent intermediate RTL modules. / Hình thể hiện phân cấp source; leaf chỉ có symbol ranh giới, không tạo module giả.

![m_vlsit_pmu_hart_evt composition](figures/post_a06/m_vlsit_pmu_hart_evt.svg)

```json
{"page_name":"BLOCK_DIAGRAM","out_name":"m_vlsit_pmu_hart_evt.drawio","layout":{"gap_h":120,"gap_v":110,"margin":80,"block_h":60},"top":{"frame_label":["Component composition","(m_vlsit_pmu_hart_evt)"]},"frame_row":["m_vlsit_pmu_hart_evt","Pack CVA6 and HPDcache source indicators into a stable per-hart catalog order.","rtl/common/vlsit/pmu/m_vlsit_pmu_hart_evt.sv"],"frame_interfaces":["IN","OUT"],"blocks":[{"key":"B0","label":["component_boundary","(m_vlsit_pmu_hart_evt)"],"width":260,"row":0,"col":0,"row_name":"component_boundary (m_vlsit_pmu_hart_evt)","function":"Pack CVA6 and HPDcache source indicators into a stable per-hart catalog order.","source":"NEW; rtl/common/vlsit/pmu/m_vlsit_pmu_hart_evt.sv"}],"connectors":[],"externals":[{"id":"IN","block":"B0","side":"L","dir":"in","pos":0,"text":["IN","ports"]},{"id":"OUT","block":"B0","side":"R","dir":"out","pos":0,"text":["OUT","ports"]}],"interfaces":[{"id":"IN","name":"Parent in ports","category":"custom","active":"in","signals":"i_cva6_evt, i_hpdcache_evt"},{"id":"OUT","name":"Parent out ports","category":"custom","active":"out","signals":"o_hart_evt"}],"nets":[],"legend_note":"A single boundary symbol denotes a leaf: internal equations/registers are described in its function/dataflow contract, not invented child modules. NEW/MODIFY/REUSE/GENERATED provenance is listed in the block table. Clock/reset follow the common synchronous contract. Complete parent port declarations are in the component section.","library_sha256":"15DFB183E267D2A94F8CAB316E01EB3D2E9D2F9C006DC816790A394F4123506C"}
```

[Editable draw.io](figures/post_a06/m_vlsit_pmu_hart_evt.drawio) · [Figure source](figures/post_a06/m_vlsit_pmu_hart_evt.json).

**Interface contract.** All synchronous ports use the common cluster clock; the probe engine cache clock is the same domain in this cluster. A valid/ready payload is accepted only on the corresponding handshake and held through backpressure. Pulsed completion/ACK interfaces are described by the operation/FSM contract; they must not be treated as independent ready/valid channels.

| Direction | Exact source declaration |
|---|---|
| input | `wire [PARA_CPU_NUM-1:0][LPARA_CVA6_EVT_NUM-1:0] i_cva6_evt` |
| input | `wire [PARA_CPU_NUM-1:0][LPARA_HPD_EVT_NUM-1:0] i_hpdcache_evt` |
| output | `logic [PARA_CPU_NUM-1:0][LPARA_HART_EVT_NUM-1:0] o_hart_evt` |

**FSM:** No new enum controller is declared by this module. Its combinational mapping, queue/valid-bit lifecycle, or instantiated child FSMs implement the behavior above. This is not a claim that the entire subtree is stateless.

#### 14.4.11 `m_vlsit_pmu_irq` — NEW

Source: [rtl/common/vlsit/pmu/m_vlsit_pmu_irq.sv](../../rtl/vlsit/m_vlsit_pmu_irq.sv). Selected production source: **True**.

**Function.** Merge newly overflowing counters into retained raw causes and drive one aggregate level interrupt.

**Working/data flow.** Compute pending as raw AND enable. If any new overflow occurs, reload the hardware update word with old raw causes OR new causes. Generated W1C fields apply their documented hardware-first priority.

**State and storage ownership.** No local flops; raw causes/enables are stored by generated CSR.

**Safety, timing and error constraints.** A new overflow in one counter can coincide with software clearing a different counter; test the actual full-word reload priority. Do not silently promise independent bitwise clear/set semantics that the generated field cannot provide.

**Verification boundary.** Connected/linted; overflow/W1C/new-event collision and masked IRQ behavior need active tests.

The figure shows actual child composition; a leaf shows its own boundary. It does not invent intermediate RTL modules. / Hình thể hiện phân cấp source; leaf chỉ có symbol ranh giới, không tạo module giả.

![m_vlsit_pmu_irq composition](figures/post_a06/m_vlsit_pmu_irq.svg)

```json
{"page_name":"BLOCK_DIAGRAM","out_name":"m_vlsit_pmu_irq.drawio","layout":{"gap_h":120,"gap_v":110,"margin":80,"block_h":60},"top":{"frame_label":["Component composition","(m_vlsit_pmu_irq)"]},"frame_row":["m_vlsit_pmu_irq","Merge newly overflowing counters into retained raw causes and drive one aggregate level interrupt.","rtl/common/vlsit/pmu/m_vlsit_pmu_irq.sv"],"frame_interfaces":["IN","OUT"],"blocks":[{"key":"B0","label":["component_boundary","(m_vlsit_pmu_irq)"],"width":220,"row":0,"col":0,"row_name":"component_boundary (m_vlsit_pmu_irq)","function":"Merge newly overflowing counters into retained raw causes and drive one aggregate level interrupt.","source":"NEW; rtl/common/vlsit/pmu/m_vlsit_pmu_irq.sv"}],"connectors":[],"externals":[{"id":"IN","block":"B0","side":"L","dir":"in","pos":0,"text":["IN","ports"]},{"id":"OUT","block":"B0","side":"R","dir":"out","pos":0,"text":["OUT","ports"]}],"interfaces":[{"id":"IN","name":"Parent in ports","category":"custom","active":"in","signals":"i_irq_raw, i_irq_en, i_pmu_cnt_ovf"},{"id":"OUT","name":"Parent out ports","category":"custom","active":"out","signals":"o_irq_raw_wdata, o_irq_raw_we, o_irq_pending, o_int_pmu"}],"nets":[],"legend_note":"A single boundary symbol denotes a leaf: internal equations/registers are described in its function/dataflow contract, not invented child modules. NEW/MODIFY/REUSE/GENERATED provenance is listed in the block table. Clock/reset follow the common synchronous contract. Complete parent port declarations are in the component section.","library_sha256":"15DFB183E267D2A94F8CAB316E01EB3D2E9D2F9C006DC816790A394F4123506C"}
```

[Editable draw.io](figures/post_a06/m_vlsit_pmu_irq.drawio) · [Figure source](figures/post_a06/m_vlsit_pmu_irq.json).

**Interface contract.** All synchronous ports use the common cluster clock; the probe engine cache clock is the same domain in this cluster. A valid/ready payload is accepted only on the corresponding handshake and held through backpressure. Pulsed completion/ACK interfaces are described by the operation/FSM contract; they must not be treated as independent ready/valid channels.

| Direction | Exact source declaration |
|---|---|
| input | `wire [LPARA_IRQ_FIELD_W-1:0] i_irq_raw` |
| input | `wire [LPARA_IRQ_FIELD_W-1:0] i_irq_en` |
| input | `wire [PARA_PMU_CNT_NUM-1:0] i_pmu_cnt_ovf` |
| output | `logic [LPARA_IRQ_FIELD_W-1:0] o_irq_raw_wdata` |
| output | `logic o_irq_raw_we` |
| output | `logic [LPARA_IRQ_FIELD_W-1:0] o_irq_pending` |
| output | `logic o_int_pmu` |

**FSM:** No new enum controller is declared by this module. Its combinational mapping, queue/valid-bit lifecycle, or instantiated child FSMs implement the behavior above. This is not a claim that the entire subtree is stateless.

#### 14.4.12 `m_vlsit_pmu_snapshot` — NEW

Source: [rtl/common/vlsit/pmu/m_vlsit_pmu_snapshot.sv](../../rtl/vlsit/m_vlsit_pmu_snapshot.sv). Selected production source: **True**.

**Function.** Capture every live counter atomically and expose stable software low/high read words.

**Working/data flow.** When the hardware observes the stored snapshot request, capture all live values on that edge, request clearing the command and set sticky done through generated CSR. Retain the captured image until the next command or reset. A 32-bit counter profile drives zero in each high word.

**State and storage ownership.** One full-width snapshot register per counter.

**Safety, timing and error constraints.** Software uses the explicit snapshot command; there is no read-low auto-snapshot feature. The captured value is the pre-edge live counter value under nonblocking sequential semantics; concurrent increments belong to the next live value.

**Verification boundary.** RTL inspected and linted; software-visible command/done/stability tests are pending.

The figure shows actual child composition; a leaf shows its own boundary. It does not invent intermediate RTL modules. / Hình thể hiện phân cấp source; leaf chỉ có symbol ranh giới, không tạo module giả.

![m_vlsit_pmu_snapshot composition](figures/post_a06/m_vlsit_pmu_snapshot.svg)

```json
{"page_name":"BLOCK_DIAGRAM","out_name":"m_vlsit_pmu_snapshot.drawio","layout":{"gap_h":120,"gap_v":110,"margin":80,"block_h":60},"top":{"frame_label":["Component composition","(m_vlsit_pmu_snapshot)"]},"frame_row":["m_vlsit_pmu_snapshot","Capture every live counter atomically and expose stable software low/high read words.","rtl/common/vlsit/pmu/m_vlsit_pmu_snapshot.sv"],"frame_interfaces":["IN","OUT"],"blocks":[{"key":"B0","label":["component_boundary","(m_vlsit_pmu_snapshot)"],"width":260,"row":0,"col":0,"row_name":"component_boundary (m_vlsit_pmu_snapshot)","function":"Capture every live counter atomically and expose stable software low/high read words.","source":"NEW; rtl/common/vlsit/pmu/m_vlsit_pmu_snapshot.sv"}],"connectors":[],"externals":[{"id":"IN","block":"B0","side":"L","dir":"in","pos":0,"text":["IN","ports"]},{"id":"OUT","block":"B0","side":"R","dir":"out","pos":0,"text":["OUT","ports"]}],"interfaces":[{"id":"IN","name":"Parent in ports","category":"custom","active":"in","signals":"i_clk_cluster, i_rst_n_cluster, i_snapshot_req, i_pmu_cnt_val"},{"id":"OUT","name":"Parent out ports","category":"custom","active":"out","signals":"o_pmu_cnt_lo_value, o_pmu_cnt_hi_value, o_snapshot_req_clear, o_snapshot_done_wdata, o_snapshot_done_we"}],"nets":[],"legend_note":"A single boundary symbol denotes a leaf: internal equations/registers are described in its function/dataflow contract, not invented child modules. NEW/MODIFY/REUSE/GENERATED provenance is listed in the block table. Clock/reset follow the common synchronous contract. Complete parent port declarations are in the component section.","library_sha256":"15DFB183E267D2A94F8CAB316E01EB3D2E9D2F9C006DC816790A394F4123506C"}
```

[Editable draw.io](figures/post_a06/m_vlsit_pmu_snapshot.drawio) · [Figure source](figures/post_a06/m_vlsit_pmu_snapshot.json).

**Interface contract.** All synchronous ports use the common cluster clock; the probe engine cache clock is the same domain in this cluster. A valid/ready payload is accepted only on the corresponding handshake and held through backpressure. Pulsed completion/ACK interfaces are described by the operation/FSM contract; they must not be treated as independent ready/valid channels.

| Direction | Exact source declaration |
|---|---|
| input | `wire i_clk_cluster` |
| input | `wire i_rst_n_cluster` |
| input | `wire i_snapshot_req` |
| input | `wire [PARA_PMU_CNT_NUM-1:0][PARA_PMU_CNT_W-1:0] i_pmu_cnt_val` |
| output | `logic [PARA_PMU_CNT_NUM-1:0][LPARA_CSR_WORD_W-1:0] o_pmu_cnt_lo_value` |
| output | `logic [PARA_PMU_CNT_NUM-1:0][LPARA_CSR_WORD_W-1:0] o_pmu_cnt_hi_value` |
| output | `logic o_snapshot_req_clear` |
| output | `logic o_snapshot_done_wdata` |
| output | `logic o_snapshot_done_we` |

**FSM:** No new enum controller is declared by this module. Its combinational mapping, queue/valid-bit lifecycle, or instantiated child FSMs implement the behavior above. This is not a claim that the entire subtree is stateless.

#### 14.4.13 `m_vlsit_riscv_addr_decode` — NEW

Source: [rtl/common/vlsit/address_map/m_vlsit_riscv_addr_decode.sv](../../rtl/vlsit/m_vlsit_riscv_addr_decode.sv). Selected production source: **True**.

**Function.** Classify a complete physical access against a shared compile-time region table.

**Working/data flow.** Validate region alignment/size/type/non-overlap; compare the full requested address window, not only its first byte. Return matched region index/class or an error. Classes distinguish cacheable normal memory, normal uncached memory and device MMIO.

**State and storage ownership.** Combinational decode; no outstanding transaction state.

**Safety, timing and error constraints.** An access crossing the selected region boundary must not acquire the attributes of only its starting byte. Unmapped/invalid/reserved configurations fail closed. MMIO atomic operations are not silently forwarded as ordinary accesses.

**Verification boundary.** Classifier and classifier/router leaf tests pass; CPU-originated MMIO/normal-uncached behavior remains unqualified.

The figure shows actual child composition; a leaf shows its own boundary. It does not invent intermediate RTL modules. / Hình thể hiện phân cấp source; leaf chỉ có symbol ranh giới, không tạo module giả.

![m_vlsit_riscv_addr_decode composition](figures/post_a06/m_vlsit_riscv_addr_decode.svg)

```json
{"page_name":"BLOCK_DIAGRAM","out_name":"m_vlsit_riscv_addr_decode.drawio","layout":{"gap_h":120,"gap_v":110,"margin":80,"block_h":60},"top":{"frame_label":["Component composition","(m_vlsit_riscv_addr_decode)"]},"frame_row":["m_vlsit_riscv_addr_decode","Classify a complete physical access against a shared compile-time region table.","rtl/common/vlsit/address_map/m_vlsit_riscv_addr_decode.sv"],"frame_interfaces":["IN","OUT"],"blocks":[{"key":"B0","label":["component_boundary","(m_vlsit_riscv_addr_decode)"],"width":320,"row":0,"col":0,"row_name":"component_boundary (m_vlsit_riscv_addr_decode)","function":"Classify a complete physical access against a shared compile-time region table.","source":"NEW; rtl/common/vlsit/address_map/m_vlsit_riscv_addr_decode.sv"}],"connectors":[],"externals":[{"id":"IN","block":"B0","side":"L","dir":"in","pos":0,"text":["IN","ports"]},{"id":"OUT","block":"B0","side":"R","dir":"out","pos":0,"text":["OUT","ports"]}],"interfaces":[{"id":"IN","name":"Parent in ports","category":"custom","active":"in","signals":"i_phys_addr, i_access_bytes, i_atomic"},{"id":"OUT","name":"Parent out ports","category":"custom","active":"out","signals":"o_config_valid, o_region_match, o_region_idx, o_region_type, o_access_err"}],"nets":[],"legend_note":"A single boundary symbol denotes a leaf: internal equations/registers are described in its function/dataflow contract, not invented child modules. NEW/MODIFY/REUSE/GENERATED provenance is listed in the block table. Clock/reset follow the common synchronous contract. Complete parent port declarations are in the component section.","library_sha256":"15DFB183E267D2A94F8CAB316E01EB3D2E9D2F9C006DC816790A394F4123506C"}
```

[Editable draw.io](figures/post_a06/m_vlsit_riscv_addr_decode.drawio) · [Figure source](figures/post_a06/m_vlsit_riscv_addr_decode.json).

**Interface contract.** All synchronous ports use the common cluster clock; the probe engine cache clock is the same domain in this cluster. A valid/ready payload is accepted only on the corresponding handshake and held through backpressure. Pulsed completion/ACK interfaces are described by the operation/FSM contract; they must not be treated as independent ready/valid channels.

| Direction | Exact source declaration |
|---|---|
| input | `wire [63:0] i_phys_addr` |
| input | `wire [11:0] i_access_bytes` |
| input | `wire i_atomic` |
| output | `logic o_config_valid` |
| output | `logic o_region_match` |
| output | `logic [3:0] o_region_idx` |
| output | `logic [1:0] o_region_type` |
| output | `logic o_access_err` |

**FSM:** No new enum controller is declared by this module. Its combinational mapping, queue/valid-bit lifecycle, or instantiated child FSMs implement the behavior above. This is not a claim that the entire subtree is stateless.

#### 14.4.14 `m_vlsit_riscv_axi_dw_adapter` — NEW

Source: [rtl/non_coherence_cluster/m_vlsit_riscv_axi_dw_adapter.sv](../../rtl/vlsit/m_vlsit_riscv_axi_dw_adapter.sv). Selected production source: **True**.

**Function.** Convert the fixed 64-bit memory-side LLC bus to synthesis-selected external AXI data width.

**Working/data flow.** Pack VLSIT fields into the pinned native width-converter records. Split or merge W/R transfers while preserving addresses, sizes, IDs, strobes, last and response/ATOP metadata. Return data to the original LLC request context.

**State and storage ownership.** Native converter read/write packing and outstanding-transfer buffers.

**Safety, timing and error constraints.** Supported declared external widths are 32, 64, 128 and 256 bits, selected before synthesis. Metadata passage does not prove an atomic target executes the requested operation.

**Verification boundary.** Four leaf-width tests pass. Only 64-bit external memory is exercised by the current real CPU regression.

The figure shows actual child composition; a leaf shows its own boundary. It does not invent intermediate RTL modules. / Hình thể hiện phân cấp source; leaf chỉ có symbol ranh giới, không tạo module giả.

![m_vlsit_riscv_axi_dw_adapter composition](figures/post_a06/m_vlsit_riscv_axi_dw_adapter.svg)

```json
{"page_name":"BLOCK_DIAGRAM","out_name":"m_vlsit_riscv_axi_dw_adapter.drawio","layout":{"gap_h":120,"gap_v":110,"margin":80,"block_h":60},"top":{"frame_label":["Component composition","(m_vlsit_riscv_axi_dw_adapter)"]},"frame_row":["m_vlsit_riscv_axi_dw_adapter","Convert the fixed 64-bit memory-side LLC bus to synthesis-selected external AXI data width.","rtl/non_coherence_cluster/m_vlsit_riscv_axi_dw_adapter.sv"],"frame_interfaces":[],"blocks":[{"key":"B0","label":["u_dont_touch_axi_dw_converter","(axi_dw_converter)"],"width":340,"row":0,"col":0,"row_name":"u_dont_touch_axi_dw_converter (axi_dw_converter)","function":"Native component","source":"REUSE; rtl/common/third_party/axi_llc_locked/axi/src/axi_dw_converter.sv"}],"connectors":[],"externals":[],"interfaces":[],"nets":[],"legend_note":"Exact source-referenced children; generate multiplicity and active branches are specified in the component text. Containment denotes hierarchy, not invented signal connectivity. NEW/MODIFY/REUSE/GENERATED provenance is listed in the block table. Clock/reset follow the common synchronous contract. Complete parent port declarations are in the component section.","library_sha256":"15DFB183E267D2A94F8CAB316E01EB3D2E9D2F9C006DC816790A394F4123506C"}
```

[Editable draw.io](figures/post_a06/m_vlsit_riscv_axi_dw_adapter.drawio) · [Figure source](figures/post_a06/m_vlsit_riscv_axi_dw_adapter.json).

**Interface contract.** All synchronous ports use the common cluster clock; the probe engine cache clock is the same domain in this cluster. A valid/ready payload is accepted only on the corresponding handshake and held through backpressure. Pulsed completion/ACK interfaces are described by the operation/FSM contract; they must not be treated as independent ready/valid channels.

| Direction | Exact source declaration |
|---|---|
| input | `wire i_clk_cluster` |
| input | `wire i_rst_n_cluster` |
| input | `wire [LPARA_AXI_ID_W-1:0] i_axi_llc_awid` |
| input | `wire [5:0] i_axi_llc_awatop` |
| input | `wire [LPARA_AXI_ADDR_W-1:0] i_axi_llc_awaddr` |
| input | `wire [7:0] i_axi_llc_awlen` |
| input | `wire [2:0] i_axi_llc_awsize` |
| input | `wire [1:0] i_axi_llc_awburst` |
| input | `wire i_axi_llc_awlock` |
| input | `wire [3:0] i_axi_llc_awcache` |
| input | `wire [2:0] i_axi_llc_awprot` |
| input | `wire [3:0] i_axi_llc_awqos` |
| input | `wire [3:0] i_axi_llc_awregion` |
| input | `wire i_axi_llc_awvalid` |
| output | `logic o_axi_llc_awready` |
| input | `wire [LPARA_AXI_LLC_DATA_W-1:0] i_axi_llc_wdata` |
| input | `wire [LPARA_AXI_LLC_DATA_W/8-1:0] i_axi_llc_wstrb` |
| input | `wire i_axi_llc_wlast` |
| input | `wire i_axi_llc_wvalid` |
| output | `logic o_axi_llc_wready` |
| output | `logic [LPARA_AXI_ID_W-1:0] o_axi_llc_bid` |
| output | `logic [1:0] o_axi_llc_bresp` |
| output | `logic o_axi_llc_bvalid` |
| input | `wire i_axi_llc_bready` |
| input | `wire [LPARA_AXI_ID_W-1:0] i_axi_llc_arid` |
| input | `wire [LPARA_AXI_ADDR_W-1:0] i_axi_llc_araddr` |
| input | `wire [7:0] i_axi_llc_arlen` |
| input | `wire [2:0] i_axi_llc_arsize` |
| input | `wire [1:0] i_axi_llc_arburst` |
| input | `wire i_axi_llc_arlock` |
| input | `wire [3:0] i_axi_llc_arcache` |
| input | `wire [2:0] i_axi_llc_arprot` |
| input | `wire [3:0] i_axi_llc_arqos` |
| input | `wire [3:0] i_axi_llc_arregion` |
| input | `wire i_axi_llc_arvalid` |
| output | `logic o_axi_llc_arready` |
| output | `logic [LPARA_AXI_ID_W-1:0] o_axi_llc_rid` |
| output | `logic [LPARA_AXI_LLC_DATA_W-1:0] o_axi_llc_rdata` |
| output | `logic [1:0] o_axi_llc_rresp` |
| output | `logic o_axi_llc_rlast` |
| output | `logic o_axi_llc_rvalid` |
| input | `wire i_axi_llc_rready` |
| output | `logic [LPARA_AXI_ID_W-1:0] o_axi_mem_awid` |
| output | `logic [5:0] o_axi_mem_awatop` |
| output | `logic [LPARA_AXI_ADDR_W-1:0] o_axi_mem_awaddr` |
| output | `logic [7:0] o_axi_mem_awlen` |
| output | `logic [2:0] o_axi_mem_awsize` |
| output | `logic [1:0] o_axi_mem_awburst` |
| output | `logic o_axi_mem_awlock` |
| output | `logic [3:0] o_axi_mem_awcache` |
| output | `logic [2:0] o_axi_mem_awprot` |
| output | `logic [3:0] o_axi_mem_awqos` |
| output | `logic [3:0] o_axi_mem_awregion` |
| output | `logic o_axi_mem_awvalid` |
| input | `wire i_axi_mem_awready` |
| output | `logic [PARA_AXI_MEM_DATA_W-1:0] o_axi_mem_wdata` |
| output | `logic [PARA_AXI_MEM_DATA_W/8-1:0] o_axi_mem_wstrb` |
| output | `logic o_axi_mem_wlast` |
| output | `logic o_axi_mem_wvalid` |
| input | `wire i_axi_mem_wready` |
| input | `wire [LPARA_AXI_ID_W-1:0] i_axi_mem_bid` |
| input | `wire [1:0] i_axi_mem_bresp` |
| input | `wire i_axi_mem_bvalid` |
| output | `logic o_axi_mem_bready` |
| output | `logic [LPARA_AXI_ID_W-1:0] o_axi_mem_arid` |
| output | `logic [LPARA_AXI_ADDR_W-1:0] o_axi_mem_araddr` |
| output | `logic [7:0] o_axi_mem_arlen` |
| output | `logic [2:0] o_axi_mem_arsize` |
| output | `logic [1:0] o_axi_mem_arburst` |
| output | `logic o_axi_mem_arlock` |
| output | `logic [3:0] o_axi_mem_arcache` |
| output | `logic [2:0] o_axi_mem_arprot` |
| output | `logic [3:0] o_axi_mem_arqos` |
| output | `logic [3:0] o_axi_mem_arregion` |
| output | `logic o_axi_mem_arvalid` |
| input | `wire i_axi_mem_arready` |
| input | `wire [LPARA_AXI_ID_W-1:0] i_axi_mem_rid` |
| input | `wire [PARA_AXI_MEM_DATA_W-1:0] i_axi_mem_rdata` |
| input | `wire [1:0] i_axi_mem_rresp` |
| input | `wire i_axi_mem_rlast` |
| input | `wire i_axi_mem_rvalid` |
| output | `logic o_axi_mem_rready` |

**FSM:** No new enum controller is declared by this module. Its combinational mapping, queue/valid-bit lifecycle, or instantiated child FSMs implement the behavior above. This is not a claim that the entire subtree is stateless.

#### 14.4.15 `m_vlsit_riscv_axi_mem_mux` — NEW

Source: [rtl/common/vlsit/interconnect/m_vlsit_riscv_axi_mem_mux.sv](../../rtl/vlsit/m_vlsit_riscv_axi_mem_mux.sv). Selected production source: **True**.

**Function.** Arbitrate per-hart memory traffic while preserving source identity and response routing.

**Working/data flow.** Pack native AXI requests, mask inactive hart slots, arbitrate accepted requests and extend IDs with source identity. Route B/R responses back by the retained encoded source. Preserve AWATOP and write payload/last semantics.

**State and storage ownership.** Native AXI mux/ordering registers; does not execute atomics or store cache lines.

**Safety, timing and error constraints.** A source ID extension is not a coherence grant. Upstream cached atomics use the L1/CCU path; uncached ATOP still needs a functional SoC atomic target.

**Verification boundary.** 2/4-hart leaf transport tests plus CPU memory traffic pass. Uncached atomic execution is not demonstrated by metadata forwarding.

The figure shows actual child composition; a leaf shows its own boundary. It does not invent intermediate RTL modules. / Hình thể hiện phân cấp source; leaf chỉ có symbol ranh giới, không tạo module giả.

![m_vlsit_riscv_axi_mem_mux composition](figures/post_a06/m_vlsit_riscv_axi_mem_mux.svg)

```json
{"page_name":"BLOCK_DIAGRAM","out_name":"m_vlsit_riscv_axi_mem_mux.drawio","layout":{"gap_h":120,"gap_v":110,"margin":80,"block_h":60},"top":{"frame_label":["Component composition","(m_vlsit_riscv_axi_mem_mux)"]},"frame_row":["m_vlsit_riscv_axi_mem_mux","Arbitrate per-hart memory traffic while preserving source identity and response routing.","rtl/common/vlsit/interconnect/m_vlsit_riscv_axi_mem_mux.sv"],"frame_interfaces":[],"blocks":[{"key":"B0","label":["u_dont_touch_axi_mux","(axi_mux)"],"width":240,"row":0,"col":0,"row_name":"u_dont_touch_axi_mux (axi_mux)","function":"Native component","source":"REUSE; rtl/common/third_party/axi_llc_locked/axi/src/axi_mux.sv"}],"connectors":[],"externals":[],"interfaces":[],"nets":[],"legend_note":"Exact source-referenced children; generate multiplicity and active branches are specified in the component text. Containment denotes hierarchy, not invented signal connectivity. NEW/MODIFY/REUSE/GENERATED provenance is listed in the block table. Clock/reset follow the common synchronous contract. Complete parent port declarations are in the component section.","library_sha256":"15DFB183E267D2A94F8CAB316E01EB3D2E9D2F9C006DC816790A394F4123506C"}
```

[Editable draw.io](figures/post_a06/m_vlsit_riscv_axi_mem_mux.drawio) · [Figure source](figures/post_a06/m_vlsit_riscv_axi_mem_mux.json).

**Interface contract.** All synchronous ports use the common cluster clock; the probe engine cache clock is the same domain in this cluster. A valid/ready payload is accepted only on the corresponding handshake and held through backpressure. Pulsed completion/ACK interfaces are described by the operation/FSM contract; they must not be treated as independent ready/valid channels.

| Direction | Exact source declaration |
|---|---|
| input | `wire i_clk_cluster` |
| input | `wire i_rst_n_cluster` |
| input | `wire [3:0][3:0] i_axi_src_awid` |
| input | `wire [3:0][5:0] i_axi_src_awatop` |
| input | `wire [3:0][63:0] i_axi_src_awaddr` |
| input | `wire [3:0][7:0] i_axi_src_awlen` |
| input | `wire [3:0][2:0] i_axi_src_awsize` |
| input | `wire [3:0][1:0] i_axi_src_awburst` |
| input | `wire [3:0] i_axi_src_awlock` |
| input | `wire [3:0][3:0] i_axi_src_awcache` |
| input | `wire [3:0][2:0] i_axi_src_awprot` |
| input | `wire [3:0][3:0] i_axi_src_awqos` |
| input | `wire [3:0][3:0] i_axi_src_awregion` |
| input | `wire [3:0] i_axi_src_awvalid` |
| output | `logic [3:0] o_axi_src_awready` |
| input | `wire [3:0][63:0] i_axi_src_wdata` |
| input | `wire [3:0][7:0] i_axi_src_wstrb` |
| input | `wire [3:0] i_axi_src_wlast` |
| input | `wire [3:0] i_axi_src_wvalid` |
| output | `logic [3:0] o_axi_src_wready` |
| output | `logic [3:0][3:0] o_axi_src_bid` |
| output | `logic [3:0][1:0] o_axi_src_bresp` |
| output | `logic [3:0] o_axi_src_bvalid` |
| input | `wire [3:0] i_axi_src_bready` |
| input | `wire [3:0][3:0] i_axi_src_arid` |
| input | `wire [3:0][63:0] i_axi_src_araddr` |
| input | `wire [3:0][7:0] i_axi_src_arlen` |
| input | `wire [3:0][2:0] i_axi_src_arsize` |
| input | `wire [3:0][1:0] i_axi_src_arburst` |
| input | `wire [3:0] i_axi_src_arlock` |
| input | `wire [3:0][3:0] i_axi_src_arcache` |
| input | `wire [3:0][2:0] i_axi_src_arprot` |
| input | `wire [3:0][3:0] i_axi_src_arqos` |
| input | `wire [3:0][3:0] i_axi_src_arregion` |
| input | `wire [3:0] i_axi_src_arvalid` |
| output | `logic [3:0] o_axi_src_arready` |
| output | `logic [3:0][3:0] o_axi_src_rid` |
| output | `logic [3:0][63:0] o_axi_src_rdata` |
| output | `logic [3:0][1:0] o_axi_src_rresp` |
| output | `logic [3:0] o_axi_src_rlast` |
| output | `logic [3:0] o_axi_src_rvalid` |
| input | `wire [3:0] i_axi_src_rready` |
| output | `logic [5:0] o_axi_llc_awid` |
| output | `logic [5:0] o_axi_llc_awatop` |
| output | `logic [63:0] o_axi_llc_awaddr` |
| output | `logic [7:0] o_axi_llc_awlen` |
| output | `logic [2:0] o_axi_llc_awsize` |
| output | `logic [1:0] o_axi_llc_awburst` |
| output | `logic o_axi_llc_awlock` |
| output | `logic [3:0] o_axi_llc_awcache` |
| output | `logic [2:0] o_axi_llc_awprot` |
| output | `logic [3:0] o_axi_llc_awqos` |
| output | `logic [3:0] o_axi_llc_awregion` |
| output | `logic o_axi_llc_awvalid` |
| input | `wire i_axi_llc_awready` |
| output | `logic [63:0] o_axi_llc_wdata` |
| output | `logic [7:0] o_axi_llc_wstrb` |
| output | `logic o_axi_llc_wlast` |
| output | `logic o_axi_llc_wvalid` |
| input | `wire i_axi_llc_wready` |
| input | `wire [5:0] i_axi_llc_bid` |
| input | `wire [1:0] i_axi_llc_bresp` |
| input | `wire i_axi_llc_bvalid` |
| output | `logic o_axi_llc_bready` |
| output | `logic [5:0] o_axi_llc_arid` |
| output | `logic [63:0] o_axi_llc_araddr` |
| output | `logic [7:0] o_axi_llc_arlen` |
| output | `logic [2:0] o_axi_llc_arsize` |
| output | `logic [1:0] o_axi_llc_arburst` |
| output | `logic o_axi_llc_arlock` |
| output | `logic [3:0] o_axi_llc_arcache` |
| output | `logic [2:0] o_axi_llc_arprot` |
| output | `logic [3:0] o_axi_llc_arqos` |
| output | `logic [3:0] o_axi_llc_arregion` |
| output | `logic o_axi_llc_arvalid` |
| input | `wire i_axi_llc_arready` |
| input | `wire [5:0] i_axi_llc_rid` |
| input | `wire [63:0] i_axi_llc_rdata` |
| input | `wire [1:0] i_axi_llc_rresp` |
| input | `wire i_axi_llc_rlast` |
| input | `wire i_axi_llc_rvalid` |
| output | `logic o_axi_llc_rready` |

**FSM:** No new enum controller is declared by this module. Its combinational mapping, queue/valid-bit lifecycle, or instantiated child FSMs implement the behavior above. This is not a claim that the entire subtree is stateless.

#### 14.4.16 `m_vlsit_riscv_axi_mmio` — NEW

Source: [rtl/common/vlsit/interconnect/m_vlsit_riscv_axi_mmio.sv](../../rtl/vlsit/m_vlsit_riscv_axi_mmio.sv). Selected production source: **True**.

**Function.** Provide a separate non-coherent AXI4 device egress for active harts.

**Working/data flow.** Pack each hart's selected device request, arbitrate through the native mux and return B/R by hart-extended ID. The external SoC fabric performs peripheral address decoding after the cluster selects this egress.

**State and storage ownership.** Mux transaction/ID state; no device register file or duplicate peripheral address map.

**Safety, timing and error constraints.** The egress data width is fixed at 64 bits in this profile. It does not acquire MESI ownership or bypass an unsupported atomic into a device.

**Verification boundary.** TOP lint establishes connection. No complete CPU-to-device model program campaign has been found; classify peripheral behavior as unqualified.

The figure shows actual child composition; a leaf shows its own boundary. It does not invent intermediate RTL modules. / Hình thể hiện phân cấp source; leaf chỉ có symbol ranh giới, không tạo module giả.

![m_vlsit_riscv_axi_mmio composition](figures/post_a06/m_vlsit_riscv_axi_mmio.svg)

```json
{"page_name":"BLOCK_DIAGRAM","out_name":"m_vlsit_riscv_axi_mmio.drawio","layout":{"gap_h":120,"gap_v":110,"margin":80,"block_h":60},"top":{"frame_label":["Component composition","(m_vlsit_riscv_axi_mmio)"]},"frame_row":["m_vlsit_riscv_axi_mmio","Provide a separate non-coherent AXI4 device egress for active harts.","rtl/common/vlsit/interconnect/m_vlsit_riscv_axi_mmio.sv"],"frame_interfaces":[],"blocks":[{"key":"B0","label":["u_dont_touch_axi_mux","(axi_mux)"],"width":240,"row":0,"col":0,"row_name":"u_dont_touch_axi_mux (axi_mux)","function":"Native component","source":"REUSE; rtl/common/third_party/axi_llc_locked/axi/src/axi_mux.sv"}],"connectors":[],"externals":[],"interfaces":[],"nets":[],"legend_note":"Exact source-referenced children; generate multiplicity and active branches are specified in the component text. Containment denotes hierarchy, not invented signal connectivity. NEW/MODIFY/REUSE/GENERATED provenance is listed in the block table. Clock/reset follow the common synchronous contract. Complete parent port declarations are in the component section.","library_sha256":"15DFB183E267D2A94F8CAB316E01EB3D2E9D2F9C006DC816790A394F4123506C"}
```

[Editable draw.io](figures/post_a06/m_vlsit_riscv_axi_mmio.drawio) · [Figure source](figures/post_a06/m_vlsit_riscv_axi_mmio.json).

**Interface contract.** All synchronous ports use the common cluster clock; the probe engine cache clock is the same domain in this cluster. A valid/ready payload is accepted only on the corresponding handshake and held through backpressure. Pulsed completion/ACK interfaces are described by the operation/FSM contract; they must not be treated as independent ready/valid channels.

| Direction | Exact source declaration |
|---|---|
| input | `wire i_clk_cluster` |
| input | `wire i_rst_n_cluster` |
| input | `wire [3:0][3:0] i_axi_src_awid` |
| input | `wire [3:0][63:0] i_axi_src_awaddr` |
| input | `wire [3:0][7:0] i_axi_src_awlen` |
| input | `wire [3:0][2:0] i_axi_src_awsize` |
| input | `wire [3:0][1:0] i_axi_src_awburst` |
| input | `wire [3:0] i_axi_src_awlock` |
| input | `wire [3:0][3:0] i_axi_src_awcache` |
| input | `wire [3:0][2:0] i_axi_src_awprot` |
| input | `wire [3:0][3:0] i_axi_src_awqos` |
| input | `wire [3:0][3:0] i_axi_src_awregion` |
| input | `wire [3:0] i_axi_src_awvalid` |
| output | `logic [3:0] o_axi_src_awready` |
| input | `wire [3:0][63:0] i_axi_src_wdata` |
| input | `wire [3:0][7:0] i_axi_src_wstrb` |
| input | `wire [3:0] i_axi_src_wlast` |
| input | `wire [3:0] i_axi_src_wvalid` |
| output | `logic [3:0] o_axi_src_wready` |
| output | `logic [3:0][3:0] o_axi_src_bid` |
| output | `logic [3:0][1:0] o_axi_src_bresp` |
| output | `logic [3:0] o_axi_src_bvalid` |
| input | `wire [3:0] i_axi_src_bready` |
| input | `wire [3:0][3:0] i_axi_src_arid` |
| input | `wire [3:0][63:0] i_axi_src_araddr` |
| input | `wire [3:0][7:0] i_axi_src_arlen` |
| input | `wire [3:0][2:0] i_axi_src_arsize` |
| input | `wire [3:0][1:0] i_axi_src_arburst` |
| input | `wire [3:0] i_axi_src_arlock` |
| input | `wire [3:0][3:0] i_axi_src_arcache` |
| input | `wire [3:0][2:0] i_axi_src_arprot` |
| input | `wire [3:0][3:0] i_axi_src_arqos` |
| input | `wire [3:0][3:0] i_axi_src_arregion` |
| input | `wire [3:0] i_axi_src_arvalid` |
| output | `logic [3:0] o_axi_src_arready` |
| output | `logic [3:0][3:0] o_axi_src_rid` |
| output | `logic [3:0][63:0] o_axi_src_rdata` |
| output | `logic [3:0][1:0] o_axi_src_rresp` |
| output | `logic [3:0] o_axi_src_rlast` |
| output | `logic [3:0] o_axi_src_rvalid` |
| input | `wire [3:0] i_axi_src_rready` |
| output | `logic [5:0] o_axi_mmio_awid` |
| output | `logic [63:0] o_axi_mmio_awaddr` |
| output | `logic [7:0] o_axi_mmio_awlen` |
| output | `logic [2:0] o_axi_mmio_awsize` |
| output | `logic [1:0] o_axi_mmio_awburst` |
| output | `logic o_axi_mmio_awlock` |
| output | `logic [3:0] o_axi_mmio_awcache` |
| output | `logic [2:0] o_axi_mmio_awprot` |
| output | `logic [3:0] o_axi_mmio_awqos` |
| output | `logic [3:0] o_axi_mmio_awregion` |
| output | `logic o_axi_mmio_awvalid` |
| input | `wire i_axi_mmio_awready` |
| output | `logic [63:0] o_axi_mmio_wdata` |
| output | `logic [7:0] o_axi_mmio_wstrb` |
| output | `logic o_axi_mmio_wlast` |
| output | `logic o_axi_mmio_wvalid` |
| input | `wire i_axi_mmio_wready` |
| input | `wire [5:0] i_axi_mmio_bid` |
| input | `wire [1:0] i_axi_mmio_bresp` |
| input | `wire i_axi_mmio_bvalid` |
| output | `logic o_axi_mmio_bready` |
| output | `logic [5:0] o_axi_mmio_arid` |
| output | `logic [63:0] o_axi_mmio_araddr` |
| output | `logic [7:0] o_axi_mmio_arlen` |
| output | `logic [2:0] o_axi_mmio_arsize` |
| output | `logic [1:0] o_axi_mmio_arburst` |
| output | `logic o_axi_mmio_arlock` |
| output | `logic [3:0] o_axi_mmio_arcache` |
| output | `logic [2:0] o_axi_mmio_arprot` |
| output | `logic [3:0] o_axi_mmio_arqos` |
| output | `logic [3:0] o_axi_mmio_arregion` |
| output | `logic o_axi_mmio_arvalid` |
| input | `wire i_axi_mmio_arready` |
| input | `wire [5:0] i_axi_mmio_rid` |
| input | `wire [63:0] i_axi_mmio_rdata` |
| input | `wire [1:0] i_axi_mmio_rresp` |
| input | `wire i_axi_mmio_rlast` |
| input | `wire i_axi_mmio_rvalid` |
| output | `logic o_axi_mmio_rready` |

**FSM:** No new enum controller is declared by this module. Its combinational mapping, queue/valid-bit lifecycle, or instantiated child FSMs implement the behavior above. This is not a claim that the entire subtree is stateless.

#### 14.4.17 `m_vlsit_riscv_axi_route` — NEW

Source: [rtl/common/vlsit/interconnect/m_vlsit_riscv_axi_route.sv](../../rtl/vlsit/m_vlsit_riscv_axi_route.sv). Selected production source: **True**.

**Function.** Route one tile's AXI transactions to cached memory, normal-uncached bypass, device MMIO or a local error responder.

**Working/data flow.** Use the captured AW/AR classification and transaction attributes to select a downstream path. Retain write-path association across AW/W skew and return B/R to the originating tile. Unsupported/unmapped requests go to the native DECERR responder rather than being dropped.

**State and storage ownership.** Native AXI demultiplexer/ordering state and outstanding-route association.

**Safety, timing and error constraints.** AW and W are independent channels but W belongs to an accepted address stream. Normal-uncached and MMIO are distinct classes. Preserve ID and ATOP semantics on the supported memory path.

**Verification boundary.** Route leaf tests and cacheable CPU traffic exist; full external MMIO/uncached/error campaigns are pending.

The figure shows actual child composition; a leaf shows its own boundary. It does not invent intermediate RTL modules. / Hình thể hiện phân cấp source; leaf chỉ có symbol ranh giới, không tạo module giả.

![m_vlsit_riscv_axi_route composition](figures/post_a06/m_vlsit_riscv_axi_route.svg)

```json
{"page_name":"BLOCK_DIAGRAM","out_name":"m_vlsit_riscv_axi_route.drawio","layout":{"gap_h":120,"gap_v":110,"margin":80,"block_h":60},"top":{"frame_label":["Component composition","(m_vlsit_riscv_axi_route)"]},"frame_row":["m_vlsit_riscv_axi_route","Route one tile's AXI transactions to cached memory, normal-uncached bypass, device MMIO or a local error responder.","rtl/common/vlsit/interconnect/m_vlsit_riscv_axi_route.sv"],"frame_interfaces":[],"blocks":[{"key":"B0","label":["u_dont_touch_axi_demux","(axi_demux)"],"width":260,"row":0,"col":0,"row_name":"u_dont_touch_axi_demux (axi_demux)","function":"Native component","source":"REUSE; rtl/common/third_party/axi_llc_locked/axi/src/axi_demux.sv"},{"key":"B1","label":["u_dont_touch_axi_err_slv","(axi_err_slv)"],"width":280,"row":1,"col":0,"row_name":"u_dont_touch_axi_err_slv (axi_err_slv)","function":"Native component","source":"REUSE; rtl/common/third_party/axi_llc_locked/axi/src/axi_err_slv.sv"}],"connectors":[],"externals":[],"interfaces":[],"nets":[],"legend_note":"Exact source-referenced children; generate multiplicity and active branches are specified in the component text. Containment denotes hierarchy, not invented signal connectivity. NEW/MODIFY/REUSE/GENERATED provenance is listed in the block table. Clock/reset follow the common synchronous contract. Complete parent port declarations are in the component section.","library_sha256":"15DFB183E267D2A94F8CAB316E01EB3D2E9D2F9C006DC816790A394F4123506C"}
```

[Editable draw.io](figures/post_a06/m_vlsit_riscv_axi_route.drawio) · [Figure source](figures/post_a06/m_vlsit_riscv_axi_route.json).

**Interface contract.** All synchronous ports use the common cluster clock; the probe engine cache clock is the same domain in this cluster. A valid/ready payload is accepted only on the corresponding handshake and held through backpressure. Pulsed completion/ACK interfaces are described by the operation/FSM contract; they must not be treated as independent ready/valid channels.

| Direction | Exact source declaration |
|---|---|
| input | `wire i_clk_cluster` |
| input | `wire i_rst_n_cluster` |
| input | `wire [3:0] i_awid` |
| input | `wire [5:0] i_awatop` |
| input | `wire [63:0] i_awaddr` |
| input | `wire [7:0] i_awlen` |
| input | `wire [2:0] i_awsize` |
| input | `wire [1:0] i_awburst` |
| input | `wire i_awlock` |
| input | `wire [3:0] i_awcache` |
| input | `wire [2:0] i_awprot` |
| input | `wire [3:0] i_awqos` |
| input | `wire [3:0] i_awregion` |
| input | `wire i_awvalid` |
| output | `logic o_awready` |
| input | `wire i_aw_region_match` |
| input | `wire [1:0] i_aw_region_type` |
| input | `wire i_aw_region_err` |
| input | `wire [63:0] i_wdata` |
| input | `wire [7:0] i_wstrb` |
| input | `wire i_wlast` |
| input | `wire i_wvalid` |
| output | `logic o_wready` |
| output | `logic [3:0] o_bid` |
| output | `logic [1:0] o_bresp` |
| output | `logic o_bvalid` |
| input | `wire i_bready` |
| input | `wire [3:0] i_arid` |
| input | `wire [63:0] i_araddr` |
| input | `wire [7:0] i_arlen` |
| input | `wire [2:0] i_arsize` |
| input | `wire [1:0] i_arburst` |
| input | `wire i_arlock` |
| input | `wire [3:0] i_arcache` |
| input | `wire [2:0] i_arprot` |
| input | `wire [3:0] i_arqos` |
| input | `wire [3:0] i_arregion` |
| input | `wire i_arvalid` |
| output | `logic o_arready` |
| input | `wire i_ar_region_match` |
| input | `wire [1:0] i_ar_region_type` |
| input | `wire i_ar_region_err` |
| output | `logic [3:0] o_rid` |
| output | `logic [63:0] o_rdata` |
| output | `logic [1:0] o_rresp` |
| output | `logic o_rlast` |
| output | `logic o_rvalid` |
| input | `wire i_rready` |
| output | `logic [3:0] o_mem_awid` |
| output | `logic [5:0] o_mem_awatop` |
| output | `logic [63:0] o_mem_awaddr` |
| output | `logic [7:0] o_mem_awlen` |
| output | `logic [2:0] o_mem_awsize` |
| output | `logic [1:0] o_mem_awburst` |
| output | `logic o_mem_awlock` |
| output | `logic [3:0] o_mem_awcache` |
| output | `logic [2:0] o_mem_awprot` |
| output | `logic [3:0] o_mem_awqos` |
| output | `logic [3:0] o_mem_awregion` |
| output | `logic [1:0] o_mem_aw_route_class` |
| output | `logic o_mem_awvalid` |
| input | `wire i_mem_awready` |
| output | `logic [63:0] o_mem_wdata` |
| output | `logic [7:0] o_mem_wstrb` |
| output | `logic o_mem_wlast` |
| output | `logic o_mem_wvalid` |
| input | `wire i_mem_wready` |
| input | `wire [3:0] i_mem_bid` |
| input | `wire [1:0] i_mem_bresp` |
| input | `wire i_mem_bvalid` |
| output | `logic o_mem_bready` |
| output | `logic [3:0] o_mem_arid` |
| output | `logic [63:0] o_mem_araddr` |
| output | `logic [7:0] o_mem_arlen` |
| output | `logic [2:0] o_mem_arsize` |
| output | `logic [1:0] o_mem_arburst` |
| output | `logic o_mem_arlock` |
| output | `logic [3:0] o_mem_arcache` |
| output | `logic [2:0] o_mem_arprot` |
| output | `logic [3:0] o_mem_arqos` |
| output | `logic [3:0] o_mem_arregion` |
| output | `logic [1:0] o_mem_ar_route_class` |
| output | `logic o_mem_arvalid` |
| input | `wire i_mem_arready` |
| input | `wire [3:0] i_mem_rid` |
| input | `wire [63:0] i_mem_rdata` |
| input | `wire [1:0] i_mem_rresp` |
| input | `wire i_mem_rlast` |
| input | `wire i_mem_rvalid` |
| output | `logic o_mem_rready` |
| output | `logic [3:0] o_mmio_awid` |
| output | `logic [63:0] o_mmio_awaddr` |
| output | `logic [7:0] o_mmio_awlen` |
| output | `logic [2:0] o_mmio_awsize` |
| output | `logic [1:0] o_mmio_awburst` |
| output | `logic o_mmio_awlock` |
| output | `logic [3:0] o_mmio_awcache` |
| output | `logic [2:0] o_mmio_awprot` |
| output | `logic [3:0] o_mmio_awqos` |
| output | `logic [3:0] o_mmio_awregion` |
| output | `logic o_mmio_awvalid` |
| input | `wire i_mmio_awready` |
| output | `logic [63:0] o_mmio_wdata` |
| output | `logic [7:0] o_mmio_wstrb` |
| output | `logic o_mmio_wlast` |
| output | `logic o_mmio_wvalid` |
| input | `wire i_mmio_wready` |
| input | `wire [3:0] i_mmio_bid` |
| input | `wire [1:0] i_mmio_bresp` |
| input | `wire i_mmio_bvalid` |
| output | `logic o_mmio_bready` |
| output | `logic [3:0] o_mmio_arid` |
| output | `logic [63:0] o_mmio_araddr` |
| output | `logic [7:0] o_mmio_arlen` |
| output | `logic [2:0] o_mmio_arsize` |
| output | `logic [1:0] o_mmio_arburst` |
| output | `logic o_mmio_arlock` |
| output | `logic [3:0] o_mmio_arcache` |
| output | `logic [2:0] o_mmio_arprot` |
| output | `logic [3:0] o_mmio_arqos` |
| output | `logic [3:0] o_mmio_arregion` |
| output | `logic o_mmio_arvalid` |
| input | `wire i_mmio_arready` |
| input | `wire [3:0] i_mmio_rid` |
| input | `wire [63:0] i_mmio_rdata` |
| input | `wire [1:0] i_mmio_rresp` |
| input | `wire i_mmio_rlast` |
| input | `wire i_mmio_rvalid` |
| output | `logic o_mmio_rready` |
| output | `logic o_aw_local_err_event` |
| output | `logic o_ar_local_err_event` |

**FSM:** No new enum controller is declared by this module. Its combinational mapping, queue/valid-bit lifecycle, or instantiated child FSMs implement the behavior above. This is not a claim that the entire subtree is stateless.

#### 14.4.18 `m_vlsit_riscv_axil_decode` — NEW

Source: [rtl/common/vlsit/control/m_vlsit_riscv_axil_decode.sv](../../rtl/vlsit/m_vlsit_riscv_axil_decode.sv). Selected production source: **True**.

**Function.** Decode one external AXI4-Lite control port into cluster CSR and LLC service targets.

**Working/data flow.** Capture independent AW/W and read requests. Validate aligned base/window, route full relative CSR offsets or subtract the LLC target base, and retain target association until its B/R is consumed. Reject accesses outside the control aperture locally.

**State and storage ownership.** Independent queued write/read payload and response/target state.

**Safety, timing and error constraints.** Use the approved 4-KiB group spacing and 24-KiB total aperture. Do not truncate CSR offsets to 12 bits and alias PMU/fault banks. Maximum legal 32-bit base is 0xFFFFA000.

**Verification boundary.** A-06 native CPU CSR accesses plus nonzero/max/invalid-base map units pass; map-cookie checks do not verify the LLC service's side effects.

The figure shows actual child composition; a leaf shows its own boundary. It does not invent intermediate RTL modules. / Hình thể hiện phân cấp source; leaf chỉ có symbol ranh giới, không tạo module giả.

![m_vlsit_riscv_axil_decode composition](figures/post_a06/m_vlsit_riscv_axil_decode.svg)

```json
{"page_name":"BLOCK_DIAGRAM","out_name":"m_vlsit_riscv_axil_decode.drawio","layout":{"gap_h":120,"gap_v":110,"margin":80,"block_h":60},"top":{"frame_label":["Component composition","(m_vlsit_riscv_axil_decode)"]},"frame_row":["m_vlsit_riscv_axil_decode","Decode one external AXI4-Lite control port into cluster CSR and LLC service targets.","rtl/common/vlsit/control/m_vlsit_riscv_axil_decode.sv"],"frame_interfaces":["IN","OUT"],"blocks":[{"key":"B0","label":["component_boundary","(m_vlsit_riscv_axil_decode)"],"width":320,"row":0,"col":0,"row_name":"component_boundary (m_vlsit_riscv_axil_decode)","function":"Decode one external AXI4-Lite control port into cluster CSR and LLC service targets.","source":"NEW; rtl/common/vlsit/control/m_vlsit_riscv_axil_decode.sv"}],"connectors":[],"externals":[{"id":"IN","block":"B0","side":"L","dir":"in","pos":0,"text":["IN","ports"]},{"id":"OUT","block":"B0","side":"R","dir":"out","pos":0,"text":["OUT","ports"]}],"interfaces":[{"id":"IN","name":"Parent in ports","category":"custom","active":"in","signals":"i_clk_cluster, i_rst_n_cluster, i_axil_awaddr, i_axil_awprot, i_axil_awvalid, i_axil_wdata, i_axil_wstrb, i_axil_wvalid, i_axil_bready, i_axil_araddr, i_axil_arprot, i_axil_arvalid, i_axil_rready, i_axil_target_awready, i_axil_target_wready, i_axil_target_bresp, i_axil_target_bvalid, i_axil_target_arready, i_axil_target_rdata, i_axil_target_rresp, i_axil_target_rvalid"},{"id":"OUT","name":"Parent out ports","category":"custom","active":"out","signals":"o_axil_awready, o_axil_wready, o_axil_bresp, o_axil_bvalid, o_axil_arready, o_axil_rdata, o_axil_rresp, o_axil_rvalid, o_axil_target_awaddr, o_axil_target_awprot, o_axil_target_awvalid, o_axil_target_wdata, o_axil_target_wstrb, o_axil_target_wvalid, o_axil_target_bready, o_axil_target_araddr, o_axil_target_arprot, o_axil_target_arvalid, o_axil_target_rready"}],"nets":[],"legend_note":"A single boundary symbol denotes a leaf: internal equations/registers are described in its function/dataflow contract, not invented child modules. NEW/MODIFY/REUSE/GENERATED provenance is listed in the block table. Clock/reset follow the common synchronous contract. Complete parent port declarations are in the component section.","library_sha256":"15DFB183E267D2A94F8CAB316E01EB3D2E9D2F9C006DC816790A394F4123506C"}
```

[Editable draw.io](figures/post_a06/m_vlsit_riscv_axil_decode.drawio) · [Figure source](figures/post_a06/m_vlsit_riscv_axil_decode.json).

**Interface contract.** All synchronous ports use the common cluster clock; the probe engine cache clock is the same domain in this cluster. A valid/ready payload is accepted only on the corresponding handshake and held through backpressure. Pulsed completion/ACK interfaces are described by the operation/FSM contract; they must not be treated as independent ready/valid channels.

| Direction | Exact source declaration |
|---|---|
| input | `wire i_clk_cluster` |
| input | `wire i_rst_n_cluster` |
| input | `wire [31:0] i_axil_awaddr` |
| input | `wire [2:0] i_axil_awprot` |
| input | `wire i_axil_awvalid` |
| output | `logic o_axil_awready` |
| input | `wire [31:0] i_axil_wdata` |
| input | `wire [3:0] i_axil_wstrb` |
| input | `wire i_axil_wvalid` |
| output | `logic o_axil_wready` |
| output | `logic [1:0] o_axil_bresp` |
| output | `logic o_axil_bvalid` |
| input | `wire i_axil_bready` |
| input | `wire [31:0] i_axil_araddr` |
| input | `wire [2:0] i_axil_arprot` |
| input | `wire i_axil_arvalid` |
| output | `logic o_axil_arready` |
| output | `logic [31:0] o_axil_rdata` |
| output | `logic [1:0] o_axil_rresp` |
| output | `logic o_axil_rvalid` |
| input | `wire i_axil_rready` |
| output | `logic [1:0][31:0] o_axil_target_awaddr` |
| output | `logic [1:0][2:0] o_axil_target_awprot` |
| output | `logic [1:0] o_axil_target_awvalid` |
| input | `wire [1:0] i_axil_target_awready` |
| output | `logic [1:0][31:0] o_axil_target_wdata` |
| output | `logic [1:0][3:0] o_axil_target_wstrb` |
| output | `logic [1:0] o_axil_target_wvalid` |
| input | `wire [1:0] i_axil_target_wready` |
| input | `wire [1:0][1:0] i_axil_target_bresp` |
| input | `wire [1:0] i_axil_target_bvalid` |
| output | `logic [1:0] o_axil_target_bready` |
| output | `logic [1:0][31:0] o_axil_target_araddr` |
| output | `logic [1:0][2:0] o_axil_target_arprot` |
| output | `logic [1:0] o_axil_target_arvalid` |
| input | `wire [1:0] i_axil_target_arready` |
| input | `wire [1:0][31:0] i_axil_target_rdata` |
| input | `wire [1:0][1:0] i_axil_target_rresp` |
| input | `wire [1:0] i_axil_target_rvalid` |
| output | `logic [1:0] o_axil_target_rready` |

**FSM:** No new enum controller is declared by this module. Its combinational mapping, queue/valid-bit lifecycle, or instantiated child FSMs implement the behavior above. This is not a claim that the entire subtree is stateless.

#### 14.4.19 `m_vlsit_riscv_cache_line_locks` — NEW

Source: [rtl/common/vlsit/coherence/m_vlsit_riscv_cache_line_locks.sv](../../rtl/vlsit/m_vlsit_riscv_cache_line_locks.sv). Selected production source: **True**.

**Function.** Track line exclusion by transaction tag and answer CPU access, victim and probe lock queries.

**Working/data flow.** Allocate or update a lock only for its owning tag, compare query line addresses against valid entries, and release only a matching terminal owner. Raise a protocol diagnostic for conflicting operations without corrupting existing locks.

**State and storage ownership.** One valid/tag/physical-line association per supported context.

**Safety, timing and error constraints.** A tag reused after release must not inherit an earlier line. Locks are control metadata, not cache data storage. Missing terminal ACK keeps the lock according to the no-timeout policy.

**Verification boundary.** Lock lifetime, duplicate/conflict and terminal-release units are available; formal concurrency checks remain open.

The figure shows actual child composition; a leaf shows its own boundary. It does not invent intermediate RTL modules. / Hình thể hiện phân cấp source; leaf chỉ có symbol ranh giới, không tạo module giả.

![m_vlsit_riscv_cache_line_locks composition](figures/post_a06/m_vlsit_riscv_cache_line_locks.svg)

```json
{"page_name":"BLOCK_DIAGRAM","out_name":"m_vlsit_riscv_cache_line_locks.drawio","layout":{"gap_h":120,"gap_v":110,"margin":80,"block_h":60},"top":{"frame_label":["Component composition","(m_vlsit_riscv_cache_line_locks)"]},"frame_row":["m_vlsit_riscv_cache_line_locks","Track line exclusion by transaction tag and answer CPU access, victim and probe lock queries.","rtl/common/vlsit/coherence/m_vlsit_riscv_cache_line_locks.sv"],"frame_interfaces":["IN","OUT"],"blocks":[{"key":"B0","label":["component_boundary","(m_vlsit_riscv_cache_line_locks)"],"width":380,"row":0,"col":0,"row_name":"component_boundary (m_vlsit_riscv_cache_line_locks)","function":"Track line exclusion by transaction tag and answer CPU access, victim and probe lock queries.","source":"NEW; rtl/common/vlsit/coherence/m_vlsit_riscv_cache_line_locks.sv"}],"connectors":[],"externals":[{"id":"IN","block":"B0","side":"L","dir":"in","pos":0,"text":["IN","ports"]},{"id":"OUT","block":"B0","side":"R","dir":"out","pos":0,"text":["OUT","ports"]}],"interfaces":[{"id":"IN","name":"Parent in ports","category":"custom","active":"in","signals":"i_clk_cluster, i_rst_n_cluster, i_acquire_valid, i_acquire_tag, i_acquire_pa_line, i_release_valid, i_release_tag, i_release_pa_line, i_access_valid, i_access_pa_line, i_victim_valid, i_victim_pa_line"},{"id":"OUT","name":"Parent out ports","category":"custom","active":"out","signals":"o_acquire_ready, o_diag_event, o_access_locked, o_victim_locked, o_line_lock_valid, o_line_lock_pa_line"}],"nets":[],"legend_note":"A single boundary symbol denotes a leaf: internal equations/registers are described in its function/dataflow contract, not invented child modules. NEW/MODIFY/REUSE/GENERATED provenance is listed in the block table. Clock/reset follow the common synchronous contract. Complete parent port declarations are in the component section.","library_sha256":"15DFB183E267D2A94F8CAB316E01EB3D2E9D2F9C006DC816790A394F4123506C"}
```

[Editable draw.io](figures/post_a06/m_vlsit_riscv_cache_line_locks.drawio) · [Figure source](figures/post_a06/m_vlsit_riscv_cache_line_locks.json).

**Interface contract.** All synchronous ports use the common cluster clock; the probe engine cache clock is the same domain in this cluster. A valid/ready payload is accepted only on the corresponding handshake and held through backpressure. Pulsed completion/ACK interfaces are described by the operation/FSM contract; they must not be treated as independent ready/valid channels.

| Direction | Exact source declaration |
|---|---|
| input | `wire i_clk_cluster` |
| input | `wire i_rst_n_cluster` |
| input | `wire i_acquire_valid` |
| output | `logic o_acquire_ready` |
| input | `wire [LPARA_COH_TAG_W-1:0] i_acquire_tag` |
| input | `wire [51:0] i_acquire_pa_line` |
| input | `wire i_release_valid` |
| input | `wire [LPARA_COH_TAG_W-1:0] i_release_tag` |
| input | `wire [51:0] i_release_pa_line` |
| output | `logic o_diag_event` |
| input | `wire i_access_valid` |
| input | `wire [51:0] i_access_pa_line` |
| output | `logic o_access_locked` |
| input | `wire i_victim_valid` |
| input | `wire [51:0] i_victim_pa_line` |
| output | `logic o_victim_locked` |
| output | `logic [PARA_COH_TXN_NUM-1:0] o_line_lock_valid` |
| output | `logic [PARA_COH_TXN_NUM-1:0][51:0] o_line_lock_pa_line` |

**FSM:** No new enum controller is declared by this module. Its combinational mapping, queue/valid-bit lifecycle, or instantiated child FSMs implement the behavior above. This is not a claim that the entire subtree is stateless.

#### 14.4.20 `m_vlsit_riscv_cluster_axi_top` — NEW

Source: [rtl/non_coherence_cluster/m_vlsit_riscv_cluster_axi_top.sv](../../rtl/vlsit/m_vlsit_riscv_cluster_axi_top.sv). Selected production source: **True**.

**Function.** Expose one synchronous cluster boundary and adapt the fixed 64-bit LLC memory interface to the selected external data width.

**Working/data flow.** Instantiate the cluster core and the memory width adapter. Connect the core memory request/response bundle through the adapter; connect AXI4-Lite, MMIO, boot, interrupt and debug directly to the core. The TOP performs no cache or retirement decision.

**State and storage ownership.** Structural wiring only. Adapter buffering is owned by the child, not by the TOP.

**Safety, timing and error constraints.** PARA_CPU_NUM selects 2 or 4 active harts. Memory IDs are 7 bits; MMIO IDs are 6 bits. AXI4-Lite is address/data 32/32. A runtime bus-width switch is not supported.

**Verification boundary.** Fresh native TOP lint passes at 2/4 harts. CPU end-to-end tests use the 64-bit external memory profile; other advertised widths remain leaf-qualified.

The figure shows actual child composition; a leaf shows its own boundary. It does not invent intermediate RTL modules. / Hình thể hiện phân cấp source; leaf chỉ có symbol ranh giới, không tạo module giả.

![m_vlsit_riscv_cluster_axi_top composition](figures/post_a06/m_vlsit_riscv_cluster_axi_top.svg)

```json
{"page_name":"BLOCK_DIAGRAM","out_name":"m_vlsit_riscv_cluster_axi_top.drawio","layout":{"gap_h":120,"gap_v":110,"margin":80,"block_h":60},"top":{"frame_label":["Component composition","(m_vlsit_riscv_cluster_axi_top)"]},"frame_row":["m_vlsit_riscv_cluster_axi_top","Expose one synchronous cluster boundary and adapt the fixed 64-bit LLC memory interface to the selected external data width.","rtl/non_coherence_cluster/m_vlsit_riscv_cluster_axi_top.sv"],"frame_interfaces":["AXIL","MMIO","MEM"],"blocks":[{"key":"B0","label":["u_vlsit_riscv_cluster_core","(m_vlsit_riscv_cluster_core)"],"width":340,"row":0,"col":0,"row_name":"u_vlsit_riscv_cluster_core (m_vlsit_riscv_cluster_core)","function":"Integrate CPUs, coherence control, memory/MMIO routing, maintenance, shared LLC, PMU and software diagnostics.","source":"NEW; rtl/non_coherence_cluster/m_vlsit_riscv_cluster_core.sv"},{"key":"B1","label":["u_vlsit_riscv_axi_dw_adapter","(m_vlsit_riscv_axi_dw_adapter)"],"width":360,"row":1,"col":0,"row_name":"u_vlsit_riscv_axi_dw_adapter (m_vlsit_riscv_axi_dw_adapter)","function":"Convert the fixed 64-bit memory-side LLC bus to synthesis-selected external AXI data width.","source":"NEW; rtl/non_coherence_cluster/m_vlsit_riscv_axi_dw_adapter.sv"}],"connectors":[{"id":"AXI64","src":"B0","src_side":"B","dst":"B1","dst_side":"T"}],"externals":[{"id":"AXIL","block":"B0","side":"L","dir":"in","pos":0,"text":["AXIL","AXI"]},{"id":"MMIO","block":"B0","side":"R","dir":"out","pos":0,"text":["MMIO","AXI"]},{"id":"MEM","block":"B1","side":"R","dir":"out","pos":0,"text":["MEM","AXI"]}],"interfaces":[{"id":"AXI64","name":"Fixed 64-bit LLC memory interface","category":"handshake","active":"core -> adapter","signals":"w_axi_llc_awid, w_axi_llc_awatop, w_axi_llc_awaddr, w_axi_llc_awlen, w_axi_llc_awsize, w_axi_llc_awburst, w_axi_llc_awlock, w_axi_llc_awcache, w_axi_llc_awprot, w_axi_llc_awqos, w_axi_llc_awregion, w_axi_llc_awvalid, w_axi_llc_awready, w_axi_llc_wdata, w_axi_llc_wstrb, w_axi_llc_wlast, w_axi_llc_wvalid, w_axi_llc_wready, w_axi_llc_bid, w_axi_llc_bresp, w_axi_llc_bvalid, w_axi_llc_bready, w_axi_llc_arid, w_axi_llc_araddr, w_axi_llc_arlen, w_axi_llc_arsize, w_axi_llc_arburst, w_axi_llc_arlock, w_axi_llc_arcache, w_axi_llc_arprot, w_axi_llc_arqos, w_axi_llc_arregion, w_axi_llc_arvalid, w_axi_llc_arready, w_axi_llc_rid, w_axi_llc_rdata, w_axi_llc_rresp, w_axi_llc_rlast, w_axi_llc_rvalid, w_axi_llc_rready, w_axi_llc_awid, w_axi_llc_awatop, w_axi_llc_awaddr, w_axi_llc_awlen, w_axi_llc_awsize"},{"id":"AXIL","name":"AXIL boundary","category":"handshake","active":"in","signals":"i_axil_awaddr, i_axil_awprot, i_axil_awvalid, o_axil_awready, i_axil_wdata, i_axil_wstrb, i_axil_wvalid, o_axil_wready, o_axil_bresp, o_axil_bvalid, i_axil_bready, i_axil_araddr, i_axil_arprot, i_axil_arvalid, o_axil_arready, o_axil_rdata, o_axil_rresp, o_axil_rvalid, i_axil_rready"},{"id":"MMIO","name":"MMIO boundary","category":"handshake","active":"out","signals":"o_axi_mmio_awid, o_axi_mmio_awaddr, o_axi_mmio_awlen, o_axi_mmio_awsize, o_axi_mmio_awburst, o_axi_mmio_awlock, o_axi_mmio_awcache, o_axi_mmio_awprot, o_axi_mmio_awqos, o_axi_mmio_awregion, o_axi_mmio_awvalid, i_axi_mmio_awready, o_axi_mmio_wdata, o_axi_mmio_wstrb, o_axi_mmio_wlast, o_axi_mmio_wvalid, i_axi_mmio_wready, i_axi_mmio_bid, i_axi_mmio_bresp, i_axi_mmio_bvalid, o_axi_mmio_bready, o_axi_mmio_arid, o_axi_mmio_araddr, o_axi_mmio_arlen, o_axi_mmio_arsize, o_axi_mmio_arburst, o_axi_mmio_arlock, o_axi_mmio_arcache, o_axi_mmio_arprot, o_axi_mmio_arqos, o_axi_mmio_arregion, o_axi_mmio_arvalid, i_axi_mmio_arready, i_axi_mmio_rid, i_axi_mmio_rdata, i_axi_mmio_rresp, i_axi_mmio_rlast, i_axi_mmio_rvalid, o_axi_mmio_rready"},{"id":"MEM","name":"MEM boundary","category":"handshake","active":"out","signals":"o_axi_mem_awid, o_axi_mem_awatop, o_axi_mem_awaddr, o_axi_mem_awlen, o_axi_mem_awsize, o_axi_mem_awburst, o_axi_mem_awlock, o_axi_mem_awcache, o_axi_mem_awprot, o_axi_mem_awqos, o_axi_mem_awregion, o_axi_mem_awvalid, i_axi_mem_awready, o_axi_mem_wdata, o_axi_mem_wstrb, o_axi_mem_wlast, o_axi_mem_wvalid, i_axi_mem_wready, i_axi_mem_bid, i_axi_mem_bresp, i_axi_mem_bvalid, o_axi_mem_bready, o_axi_mem_arid, o_axi_mem_araddr, o_axi_mem_arlen, o_axi_mem_arsize, o_axi_mem_arburst, o_axi_mem_arlock, o_axi_mem_arcache, o_axi_mem_arprot, o_axi_mem_arqos, o_axi_mem_arregion, o_axi_mem_arvalid, i_axi_mem_arready, i_axi_mem_rid, i_axi_mem_rdata, i_axi_mem_rresp, i_axi_mem_rlast, i_axi_mem_rvalid, o_axi_mem_rready"}],"nets":[],"legend_note":"Source-grounded structural TOP. AXI64 request/response bundle joins the core and width adapter; arrow denotes request initiator, responses return on the same bundle. Boot, IRQ/debug and common clock/reset are fully listed in Section 6 rather than duplicated as unconnected pads.","library_sha256":"15DFB183E267D2A94F8CAB316E01EB3D2E9D2F9C006DC816790A394F4123506C"}
```

[Editable draw.io](figures/post_a06/m_vlsit_riscv_cluster_axi_top.drawio) · [Figure source](figures/post_a06/m_vlsit_riscv_cluster_axi_top.json).

**Interface contract.** All synchronous ports use the common cluster clock; the probe engine cache clock is the same domain in this cluster. A valid/ready payload is accepted only on the corresponding handshake and held through backpressure. Pulsed completion/ACK interfaces are described by the operation/FSM contract; they must not be treated as independent ready/valid channels.

| Direction | Exact source declaration |
|---|---|
| input | `wire i_clk_cluster` |
| input | `wire i_rst_n_cluster` |
| input | `wire [63:0] i_boot_addr` |
| input | `wire [3:0] i_int_msip` |
| input | `wire [3:0] i_int_mtip` |
| input | `wire [3:0] i_int_meip` |
| input | `wire [3:0] i_int_ssip` |
| input | `wire [3:0] i_int_stip` |
| input | `wire [3:0] i_int_seip` |
| input | `wire [3:0] i_hart_debug_req` |
| output | `logic [3:0] o_hart_debug_mode` |
| output | `logic o_int_pmu` |
| output | `logic o_int_fault` |
| input | `wire [31:0] i_axil_awaddr` |
| input | `wire [2:0] i_axil_awprot` |
| input | `wire i_axil_awvalid` |
| output | `logic o_axil_awready` |
| input | `wire [31:0] i_axil_wdata` |
| input | `wire [3:0] i_axil_wstrb` |
| input | `wire i_axil_wvalid` |
| output | `logic o_axil_wready` |
| output | `logic [1:0] o_axil_bresp` |
| output | `logic o_axil_bvalid` |
| input | `wire i_axil_bready` |
| input | `wire [31:0] i_axil_araddr` |
| input | `wire [2:0] i_axil_arprot` |
| input | `wire i_axil_arvalid` |
| output | `logic o_axil_arready` |
| output | `logic [31:0] o_axil_rdata` |
| output | `logic [1:0] o_axil_rresp` |
| output | `logic o_axil_rvalid` |
| input | `wire i_axil_rready` |
| output | `logic [5:0] o_axi_mmio_awid` |
| output | `logic [63:0] o_axi_mmio_awaddr` |
| output | `logic [7:0] o_axi_mmio_awlen` |
| output | `logic [2:0] o_axi_mmio_awsize` |
| output | `logic [1:0] o_axi_mmio_awburst` |
| output | `logic o_axi_mmio_awlock` |
| output | `logic [3:0] o_axi_mmio_awcache` |
| output | `logic [2:0] o_axi_mmio_awprot` |
| output | `logic [3:0] o_axi_mmio_awqos` |
| output | `logic [3:0] o_axi_mmio_awregion` |
| output | `logic o_axi_mmio_awvalid` |
| input | `wire i_axi_mmio_awready` |
| output | `logic [63:0] o_axi_mmio_wdata` |
| output | `logic [7:0] o_axi_mmio_wstrb` |
| output | `logic o_axi_mmio_wlast` |
| output | `logic o_axi_mmio_wvalid` |
| input | `wire i_axi_mmio_wready` |
| input | `wire [5:0] i_axi_mmio_bid` |
| input | `wire [1:0] i_axi_mmio_bresp` |
| input | `wire i_axi_mmio_bvalid` |
| output | `logic o_axi_mmio_bready` |
| output | `logic [5:0] o_axi_mmio_arid` |
| output | `logic [63:0] o_axi_mmio_araddr` |
| output | `logic [7:0] o_axi_mmio_arlen` |
| output | `logic [2:0] o_axi_mmio_arsize` |
| output | `logic [1:0] o_axi_mmio_arburst` |
| output | `logic o_axi_mmio_arlock` |
| output | `logic [3:0] o_axi_mmio_arcache` |
| output | `logic [2:0] o_axi_mmio_arprot` |
| output | `logic [3:0] o_axi_mmio_arqos` |
| output | `logic [3:0] o_axi_mmio_arregion` |
| output | `logic o_axi_mmio_arvalid` |
| input | `wire i_axi_mmio_arready` |
| input | `wire [5:0] i_axi_mmio_rid` |
| input | `wire [63:0] i_axi_mmio_rdata` |
| input | `wire [1:0] i_axi_mmio_rresp` |
| input | `wire i_axi_mmio_rlast` |
| input | `wire i_axi_mmio_rvalid` |
| output | `logic o_axi_mmio_rready` |
| output | `logic [6:0] o_axi_mem_awid` |
| output | `logic [5:0] o_axi_mem_awatop` |
| output | `logic [63:0] o_axi_mem_awaddr` |
| output | `logic [7:0] o_axi_mem_awlen` |
| output | `logic [2:0] o_axi_mem_awsize` |
| output | `logic [1:0] o_axi_mem_awburst` |
| output | `logic o_axi_mem_awlock` |
| output | `logic [3:0] o_axi_mem_awcache` |
| output | `logic [2:0] o_axi_mem_awprot` |
| output | `logic [3:0] o_axi_mem_awqos` |
| output | `logic [3:0] o_axi_mem_awregion` |
| output | `logic o_axi_mem_awvalid` |
| input | `wire i_axi_mem_awready` |
| output | `logic [PARA_AXI_MEM_DATA_W-1:0] o_axi_mem_wdata` |
| output | `logic [PARA_AXI_MEM_DATA_W/8-1:0] o_axi_mem_wstrb` |
| output | `logic o_axi_mem_wlast` |
| output | `logic o_axi_mem_wvalid` |
| input | `wire i_axi_mem_wready` |
| input | `wire [6:0] i_axi_mem_bid` |
| input | `wire [1:0] i_axi_mem_bresp` |
| input | `wire i_axi_mem_bvalid` |
| output | `logic o_axi_mem_bready` |
| output | `logic [6:0] o_axi_mem_arid` |
| output | `logic [63:0] o_axi_mem_araddr` |
| output | `logic [7:0] o_axi_mem_arlen` |
| output | `logic [2:0] o_axi_mem_arsize` |
| output | `logic [1:0] o_axi_mem_arburst` |
| output | `logic o_axi_mem_arlock` |
| output | `logic [3:0] o_axi_mem_arcache` |
| output | `logic [2:0] o_axi_mem_arprot` |
| output | `logic [3:0] o_axi_mem_arqos` |
| output | `logic [3:0] o_axi_mem_arregion` |
| output | `logic o_axi_mem_arvalid` |
| input | `wire i_axi_mem_arready` |
| input | `wire [6:0] i_axi_mem_rid` |
| input | `wire [PARA_AXI_MEM_DATA_W-1:0] i_axi_mem_rdata` |
| input | `wire [1:0] i_axi_mem_rresp` |
| input | `wire i_axi_mem_rlast` |
| input | `wire i_axi_mem_rvalid` |
| output | `logic o_axi_mem_rready` |

**FSM:** No new enum controller is declared by this module. Its combinational mapping, queue/valid-bit lifecycle, or instantiated child FSMs implement the behavior above. This is not a claim that the entire subtree is stateless.

#### 14.4.21 `m_vlsit_riscv_cluster_core` — NEW

Source: [rtl/non_coherence_cluster/m_vlsit_riscv_cluster_core.sv](../../rtl/vlsit/m_vlsit_riscv_cluster_core.sv). Selected production source: **True**.

**Function.** Integrate CPUs, coherence control, memory/MMIO routing, maintenance, shared LLC, PMU and software diagnostics.

**Working/data flow.** CPU tiles request permissions from the shared CCU. Cacheable data travels through per-hart routing, memory arbitration and LLC; normal-uncached traffic uses the approved memory-bypass path, and device traffic uses the separate MMIO path. A selected maintenance instruction uses the CMO arbiter/controller and waits for CCU plus LLC terminal completion before returning to its hart. AXI4-Lite independently selects generated CSR or native LLC service.

**State and storage ownership.** Child blocks own contexts, arrays, counters and register queues. The core adds reset-only fatal-IRQ retention and first-fault metadata association.

**Safety, timing and error constraints.** Keep raw failed B response associated with the native ID-checked L1 flush ACK. Diagnostic W1C cannot clear a fatal retained cache context. Local protocol adapters must continue draining already issued responses during fault retention.

**Verification boundary.** The latest source-consistent campaign has 58 real CPU scenarios. The presence of PMU, debug and LLC service instances does not establish functional closure of those paths.

The figure shows actual child composition; a leaf shows its own boundary. It does not invent intermediate RTL modules. / Hình thể hiện phân cấp source; leaf chỉ có symbol ranh giới, không tạo module giả.

![m_vlsit_riscv_cluster_core composition](figures/post_a06/m_vlsit_riscv_cluster_core.svg)

```json
{"page_name":"BLOCK_DIAGRAM","out_name":"m_vlsit_riscv_cluster_core.drawio","layout":{"gap_h":120,"gap_v":110,"margin":80,"block_h":60},"top":{"frame_label":["Component composition","(m_vlsit_riscv_cluster_core)"]},"frame_row":["m_vlsit_riscv_cluster_core","Integrate CPUs, coherence control, memory/MMIO routing, maintenance, shared LLC, PMU and software diagnostics.","rtl/non_coherence_cluster/m_vlsit_riscv_cluster_core.sv"],"frame_interfaces":[],"blocks":[{"key":"B0","label":["u_vlsit_axi_llc","(m_vlsit_axi_llc)"],"width":200,"row":0,"col":0,"row_name":"u_vlsit_axi_llc (m_vlsit_axi_llc)","function":"Wrap the licensed native LLC with VLSIT AXI/service/maintenance and fault-event ports.","source":"NEW; rtl/common/vlsit/cache/m_vlsit_axi_llc.sv"},{"key":"B1","label":["u_vlsit_axil_reg_bridge","(m_vlsit_axil_reg_bridge)"],"width":300,"row":0,"col":1,"row_name":"u_vlsit_axil_reg_bridge (m_vlsit_axil_reg_bridge)","function":"Translate AXI4-Lite LLC-service accesses into the pinned PULP RegBus request/response form.","source":"NEW; rtl/common/vlsit/control/m_vlsit_axil_reg_bridge.sv"},{"key":"B2","label":["u_vlsit_cpucl_csr","(m_vlsit_cpucl_csr)"],"width":220,"row":0,"col":2,"row_name":"u_vlsit_cpucl_csr (m_vlsit_cpucl_csr)","function":"Implement workbook-defined AXI4-Lite PMU controls, snapshot words, IRQ/diagnostic status and read-only fatal records.","source":"GENERATED; rtl/common/vlsit/csr/RTL/m_vlsit_cpucl_csr.sv"},{"key":"B3","label":["u_vlsit_riscv_axi_mem_mux","(m_vlsit_riscv_axi_mem_mux)"],"width":320,"row":1,"col":0,"row_name":"u_vlsit_riscv_axi_mem_mux (m_vlsit_riscv_axi_mem_mux)","function":"Arbitrate per-hart memory traffic while preserving source identity and response routing.","source":"NEW; rtl/common/vlsit/interconnect/m_vlsit_riscv_axi_mem_mux.sv"},{"key":"B4","label":["u_vlsit_riscv_axi_mmio","(m_vlsit_riscv_axi_mmio)"],"width":280,"row":1,"col":1,"row_name":"u_vlsit_riscv_axi_mmio (m_vlsit_riscv_axi_mmio)","function":"Provide a separate non-coherent AXI4 device egress for active harts.","source":"NEW; rtl/common/vlsit/interconnect/m_vlsit_riscv_axi_mmio.sv"},{"key":"B5","label":["u_vlsit_riscv_axi_route","(m_vlsit_riscv_axi_route)"],"width":300,"row":1,"col":2,"row_name":"u_vlsit_riscv_axi_route (m_vlsit_riscv_axi_route)","function":"Route one tile's AXI transactions to cached memory, normal-uncached bypass, device MMIO or a local error responder.","source":"NEW; rtl/common/vlsit/interconnect/m_vlsit_riscv_axi_route.sv"},{"key":"B6","label":["u_vlsit_riscv_axil_decode","(m_vlsit_riscv_axil_decode)"],"width":320,"row":2,"col":0,"row_name":"u_vlsit_riscv_axil_decode (m_vlsit_riscv_axil_decode)","function":"Decode one external AXI4-Lite control port into cluster CSR and LLC service targets.","source":"NEW; rtl/common/vlsit/control/m_vlsit_riscv_axil_decode.sv"},{"key":"B7","label":["u_vlsit_riscv_cmo_arbiter","(m_vlsit_riscv_cmo_arbiter)"],"width":320,"row":2,"col":1,"row_name":"u_vlsit_riscv_cmo_arbiter (m_vlsit_riscv_cmo_arbiter)","function":"Select one hart's retirement-blocking maintenance request and preserve its completion destination.","source":"NEW; rtl/common/vlsit/maintenance/m_vlsit_riscv_cmo_arbiter.sv"},{"key":"B8","label":["u_vlsit_riscv_cmo_controller","(m_vlsit_riscv_cmo_controller)"],"width":360,"row":2,"col":2,"row_name":"u_vlsit_riscv_cmo_controller (m_vlsit_riscv_cmo_controller)","function":"Sequence CCU preparation, optional per-line LLC maintenance, terminal COMMIT/ABORT and the hart completion response.","source":"NEW; rtl/common/vlsit/maintenance/m_vlsit_riscv_cmo_controller.sv"},{"key":"B9","label":["u_vlsit_riscv_cpu_tile_array","(m_vlsit_riscv_cpu_tile_array)"],"width":360,"row":3,"col":0,"row_name":"u_vlsit_riscv_cpu_tile_array (m_vlsit_riscv_cpu_tile_array)","function":"Replicate active CPU tiles and connect their ownership, query, lock and tagged-probe channels to one shared coherence tile array.","source":"NEW; rtl/common/vlsit/cpu/m_vlsit_riscv_cpu_tile_array.sv"},{"key":"B10","label":["u_vlsit_riscv_fault_record","(m_vlsit_riscv_fault_record)"],"width":340,"row":3,"col":1,"row_name":"u_vlsit_riscv_fault_record (m_vlsit_riscv_fault_record)","function":"Capture the first fatal ordinary L1 or shared LLC writeback error until reset.","source":"NEW; rtl/common/vlsit/diagnostics/m_vlsit_riscv_fault_record.sv"},{"key":"B11","label":["u_vlsit_riscv_pmu","(m_vlsit_riscv_pmu)"],"width":220,"row":3,"col":2,"row_name":"u_vlsit_riscv_pmu (m_vlsit_riscv_pmu)","function":"Integrate source event packing, scope selection, counters, atomic snapshots and aggregate overflow interrupt.","source":"NEW; rtl/common/vlsit/pmu/m_vlsit_riscv_pmu.sv"}],"connectors":[],"externals":[],"interfaces":[],"nets":[],"legend_note":"Exact source-referenced children; generate multiplicity and active branches are specified in the component text. Containment denotes hierarchy, not invented signal connectivity. NEW/MODIFY/REUSE/GENERATED provenance is listed in the block table. Clock/reset follow the common synchronous contract. Complete parent port declarations are in the component section.","library_sha256":"15DFB183E267D2A94F8CAB316E01EB3D2E9D2F9C006DC816790A394F4123506C"}
```

[Editable draw.io](figures/post_a06/m_vlsit_riscv_cluster_core.drawio) · [Figure source](figures/post_a06/m_vlsit_riscv_cluster_core.json).

**Interface contract.** All synchronous ports use the common cluster clock; the probe engine cache clock is the same domain in this cluster. A valid/ready payload is accepted only on the corresponding handshake and held through backpressure. Pulsed completion/ACK interfaces are described by the operation/FSM contract; they must not be treated as independent ready/valid channels.

| Direction | Exact source declaration |
|---|---|
| input | `wire i_clk_cluster` |
| input | `wire i_rst_n_cluster` |
| input | `wire [63:0] i_boot_addr` |
| input | `wire [3:0] i_int_msip` |
| input | `wire [3:0] i_int_mtip` |
| input | `wire [3:0] i_int_meip` |
| input | `wire [3:0] i_int_ssip` |
| input | `wire [3:0] i_int_stip` |
| input | `wire [3:0] i_int_seip` |
| input | `wire [3:0] i_hart_debug_req` |
| output | `logic [3:0] o_hart_debug_mode` |
| output | `logic o_int_pmu` |
| output | `logic o_int_fault` |
| input | `wire [31:0] i_axil_awaddr` |
| input | `wire [2:0] i_axil_awprot` |
| input | `wire i_axil_awvalid` |
| output | `logic o_axil_awready` |
| input | `wire [31:0] i_axil_wdata` |
| input | `wire [3:0] i_axil_wstrb` |
| input | `wire i_axil_wvalid` |
| output | `logic o_axil_wready` |
| output | `logic [1:0] o_axil_bresp` |
| output | `logic o_axil_bvalid` |
| input | `wire i_axil_bready` |
| input | `wire [31:0] i_axil_araddr` |
| input | `wire [2:0] i_axil_arprot` |
| input | `wire i_axil_arvalid` |
| output | `logic o_axil_arready` |
| output | `logic [31:0] o_axil_rdata` |
| output | `logic [1:0] o_axil_rresp` |
| output | `logic o_axil_rvalid` |
| input | `wire i_axil_rready` |
| output | `logic [5:0] o_axi_mmio_awid` |
| output | `logic [63:0] o_axi_mmio_awaddr` |
| output | `logic [7:0] o_axi_mmio_awlen` |
| output | `logic [2:0] o_axi_mmio_awsize` |
| output | `logic [1:0] o_axi_mmio_awburst` |
| output | `logic o_axi_mmio_awlock` |
| output | `logic [3:0] o_axi_mmio_awcache` |
| output | `logic [2:0] o_axi_mmio_awprot` |
| output | `logic [3:0] o_axi_mmio_awqos` |
| output | `logic [3:0] o_axi_mmio_awregion` |
| output | `logic o_axi_mmio_awvalid` |
| input | `wire i_axi_mmio_awready` |
| output | `logic [63:0] o_axi_mmio_wdata` |
| output | `logic [7:0] o_axi_mmio_wstrb` |
| output | `logic o_axi_mmio_wlast` |
| output | `logic o_axi_mmio_wvalid` |
| input | `wire i_axi_mmio_wready` |
| input | `wire [5:0] i_axi_mmio_bid` |
| input | `wire [1:0] i_axi_mmio_bresp` |
| input | `wire i_axi_mmio_bvalid` |
| output | `logic o_axi_mmio_bready` |
| output | `logic [5:0] o_axi_mmio_arid` |
| output | `logic [63:0] o_axi_mmio_araddr` |
| output | `logic [7:0] o_axi_mmio_arlen` |
| output | `logic [2:0] o_axi_mmio_arsize` |
| output | `logic [1:0] o_axi_mmio_arburst` |
| output | `logic o_axi_mmio_arlock` |
| output | `logic [3:0] o_axi_mmio_arcache` |
| output | `logic [2:0] o_axi_mmio_arprot` |
| output | `logic [3:0] o_axi_mmio_arqos` |
| output | `logic [3:0] o_axi_mmio_arregion` |
| output | `logic o_axi_mmio_arvalid` |
| input | `wire i_axi_mmio_arready` |
| input | `wire [5:0] i_axi_mmio_rid` |
| input | `wire [63:0] i_axi_mmio_rdata` |
| input | `wire [1:0] i_axi_mmio_rresp` |
| input | `wire i_axi_mmio_rlast` |
| input | `wire i_axi_mmio_rvalid` |
| output | `logic o_axi_mmio_rready` |
| output | `logic [6:0] o_axi_mem_awid` |
| output | `logic [5:0] o_axi_mem_awatop` |
| output | `logic [63:0] o_axi_mem_awaddr` |
| output | `logic [7:0] o_axi_mem_awlen` |
| output | `logic [2:0] o_axi_mem_awsize` |
| output | `logic [1:0] o_axi_mem_awburst` |
| output | `logic o_axi_mem_awlock` |
| output | `logic [3:0] o_axi_mem_awcache` |
| output | `logic [2:0] o_axi_mem_awprot` |
| output | `logic [3:0] o_axi_mem_awqos` |
| output | `logic [3:0] o_axi_mem_awregion` |
| output | `logic o_axi_mem_awvalid` |
| input | `wire i_axi_mem_awready` |
| output | `logic [63:0] o_axi_mem_wdata` |
| output | `logic [7:0] o_axi_mem_wstrb` |
| output | `logic o_axi_mem_wlast` |
| output | `logic o_axi_mem_wvalid` |
| input | `wire i_axi_mem_wready` |
| input | `wire [6:0] i_axi_mem_bid` |
| input | `wire [1:0] i_axi_mem_bresp` |
| input | `wire i_axi_mem_bvalid` |
| output | `logic o_axi_mem_bready` |
| output | `logic [6:0] o_axi_mem_arid` |
| output | `logic [63:0] o_axi_mem_araddr` |
| output | `logic [7:0] o_axi_mem_arlen` |
| output | `logic [2:0] o_axi_mem_arsize` |
| output | `logic [1:0] o_axi_mem_arburst` |
| output | `logic o_axi_mem_arlock` |
| output | `logic [3:0] o_axi_mem_arcache` |
| output | `logic [2:0] o_axi_mem_arprot` |
| output | `logic [3:0] o_axi_mem_arqos` |
| output | `logic [3:0] o_axi_mem_arregion` |
| output | `logic o_axi_mem_arvalid` |
| input | `wire i_axi_mem_arready` |
| input | `wire [6:0] i_axi_mem_rid` |
| input | `wire [63:0] i_axi_mem_rdata` |
| input | `wire [1:0] i_axi_mem_rresp` |
| input | `wire i_axi_mem_rlast` |
| input | `wire i_axi_mem_rvalid` |
| output | `logic o_axi_mem_rready` |

**FSM:** No new enum controller is declared by this module. Its combinational mapping, queue/valid-bit lifecycle, or instantiated child FSMs implement the behavior above. This is not a claim that the entire subtree is stateless.

#### 14.4.22 `m_vlsit_riscv_cmo_arbiter` — NEW

Source: [rtl/common/vlsit/maintenance/m_vlsit_riscv_cmo_arbiter.sv](../../rtl/vlsit/m_vlsit_riscv_cmo_arbiter.sv). Selected production source: **True**.

**Function.** Select one hart's retirement-blocking maintenance request and preserve its completion destination.

**Working/data flow.** Choose an eligible requester using the implemented arbitration pointer, latch the selected hart and instruction metadata, send one command to the controller and route terminal completion/error back to that hart. Keep other requests pending rather than duplicating an accepted instruction.

**State and storage ownership.** Selected/active request metadata and fairness pointer; no cache data.

**Safety, timing and error constraints.** Completion must use retained selection, not the current request vector. The instruction may retire or trap only after the controller's terminal result.

**Verification boundary.** Arbiter units and actual CBO/FENCE.I CPU tests pass; simultaneous maintenance plus external interrupt/debug remains to qualify.

The figure shows actual child composition; a leaf shows its own boundary. It does not invent intermediate RTL modules. / Hình thể hiện phân cấp source; leaf chỉ có symbol ranh giới, không tạo module giả.

![m_vlsit_riscv_cmo_arbiter composition](figures/post_a06/m_vlsit_riscv_cmo_arbiter.svg)

```json
{"page_name":"BLOCK_DIAGRAM","out_name":"m_vlsit_riscv_cmo_arbiter.drawio","layout":{"gap_h":120,"gap_v":110,"margin":80,"block_h":60},"top":{"frame_label":["Component composition","(m_vlsit_riscv_cmo_arbiter)"]},"frame_row":["m_vlsit_riscv_cmo_arbiter","Select one hart's retirement-blocking maintenance request and preserve its completion destination.","rtl/common/vlsit/maintenance/m_vlsit_riscv_cmo_arbiter.sv"],"frame_interfaces":["IN","OUT"],"blocks":[{"key":"B0","label":["component_boundary","(m_vlsit_riscv_cmo_arbiter)"],"width":320,"row":0,"col":0,"row_name":"component_boundary (m_vlsit_riscv_cmo_arbiter)","function":"Select one hart's retirement-blocking maintenance request and preserve its completion destination.","source":"NEW; rtl/common/vlsit/maintenance/m_vlsit_riscv_cmo_arbiter.sv"}],"connectors":[],"externals":[{"id":"IN","block":"B0","side":"L","dir":"in","pos":0,"text":["IN","ports"]},{"id":"OUT","block":"B0","side":"R","dir":"out","pos":0,"text":["OUT","ports"]}],"interfaces":[{"id":"IN","name":"Parent in ports","category":"custom","active":"in","signals":"i_clk_cluster, i_rst_n_cluster, i_req_valid, i_req_op, i_req_pa_line, i_req_vaddr, i_req_pc, i_cmo_ready, i_cmo_done, i_cmo_err"},{"id":"OUT","name":"Parent out ports","category":"custom","active":"out","signals":"o_req_ready, o_rsp_done, o_rsp_err, o_cmo_valid, o_cmo_op, o_cmo_pa_line, o_cmo_vaddr, o_cmo_pc, o_cmo_hart"}],"nets":[],"legend_note":"A single boundary symbol denotes a leaf: internal equations/registers are described in its function/dataflow contract, not invented child modules. NEW/MODIFY/REUSE/GENERATED provenance is listed in the block table. Clock/reset follow the common synchronous contract. Complete parent port declarations are in the component section.","library_sha256":"15DFB183E267D2A94F8CAB316E01EB3D2E9D2F9C006DC816790A394F4123506C"}
```

[Editable draw.io](figures/post_a06/m_vlsit_riscv_cmo_arbiter.drawio) · [Figure source](figures/post_a06/m_vlsit_riscv_cmo_arbiter.json).

**Interface contract.** All synchronous ports use the common cluster clock; the probe engine cache clock is the same domain in this cluster. A valid/ready payload is accepted only on the corresponding handshake and held through backpressure. Pulsed completion/ACK interfaces are described by the operation/FSM contract; they must not be treated as independent ready/valid channels.

| Direction | Exact source declaration |
|---|---|
| input | `wire i_clk_cluster` |
| input | `wire i_rst_n_cluster` |
| input | `wire [3:0] i_req_valid` |
| output | `logic [3:0] o_req_ready` |
| input | `wire [3:0][1:0] i_req_op` |
| input | `wire [3:0][51:0] i_req_pa_line` |
| input | `wire [3:0][63:0] i_req_vaddr` |
| input | `wire [3:0][63:0] i_req_pc` |
| output | `logic [3:0] o_rsp_done` |
| output | `logic [3:0] o_rsp_err` |
| output | `logic o_cmo_valid` |
| input | `wire i_cmo_ready` |
| output | `logic [1:0] o_cmo_op` |
| output | `logic [51:0] o_cmo_pa_line` |
| output | `logic [63:0] o_cmo_vaddr` |
| output | `logic [63:0] o_cmo_pc` |
| output | `logic [1:0] o_cmo_hart` |
| input | `wire i_cmo_done` |
| input | `wire i_cmo_err` |

**FSM:** No new enum controller is declared by this module. Its combinational mapping, queue/valid-bit lifecycle, or instantiated child FSMs implement the behavior above. This is not a claim that the entire subtree is stateless.

#### 14.4.23 `m_vlsit_riscv_cmo_controller` — NEW

Source: [rtl/common/vlsit/maintenance/m_vlsit_riscv_cmo_controller.sv](../../rtl/vlsit/m_vlsit_riscv_cmo_controller.sv). Selected production source: **True**.

**Function.** Sequence CCU preparation, optional per-line LLC maintenance, terminal COMMIT/ABORT and the hart completion response.

**Working/data flow.** Capture a command; obtain a CCU transaction; wait for PREPARE. For a successful CBO issue native LLC maintenance and wait for completion. For FENCE.I, skip LLC-to-DRAM maintenance after local dirty data reaches LLC. On any error request ABORT; otherwise request COMMIT. Wait for all terminal ACKs and context completion before responding to the CPU.

**State and storage ownership.** Retained op/hart/line/PC/VA/tag/error and eight-state FSM.

**Safety, timing and error constraints.** Support same-cycle accepted maintenance/finish completion without losing done. Do not report a precise error before ABORT ACKs. Cause 7 applies to the approved CBO path; cause 24 is the custom FENCE.I maintenance fault.

**Verification boundary.** Directed controller/metadata units and CPU CBO/FENCE.I success/error/retry cases pass.

The figure shows actual child composition; a leaf shows its own boundary. It does not invent intermediate RTL modules. / Hình thể hiện phân cấp source; leaf chỉ có symbol ranh giới, không tạo module giả.

![m_vlsit_riscv_cmo_controller composition](figures/post_a06/m_vlsit_riscv_cmo_controller.svg)

```json
{"page_name":"BLOCK_DIAGRAM","out_name":"m_vlsit_riscv_cmo_controller.drawio","layout":{"gap_h":120,"gap_v":110,"margin":80,"block_h":60},"top":{"frame_label":["Component composition","(m_vlsit_riscv_cmo_controller)"]},"frame_row":["m_vlsit_riscv_cmo_controller","Sequence CCU preparation, optional per-line LLC maintenance, terminal COMMIT/ABORT and the hart completion response.","rtl/common/vlsit/maintenance/m_vlsit_riscv_cmo_controller.sv"],"frame_interfaces":["IN","OUT"],"blocks":[{"key":"B0","label":["component_boundary","(m_vlsit_riscv_cmo_controller)"],"width":360,"row":0,"col":0,"row_name":"component_boundary (m_vlsit_riscv_cmo_controller)","function":"Sequence CCU preparation, optional per-line LLC maintenance, terminal COMMIT/ABORT and the hart completion response.","source":"NEW; rtl/common/vlsit/maintenance/m_vlsit_riscv_cmo_controller.sv"}],"connectors":[],"externals":[{"id":"IN","block":"B0","side":"L","dir":"in","pos":0,"text":["IN","ports"]},{"id":"OUT","block":"B0","side":"R","dir":"out","pos":0,"text":["OUT","ports"]}],"interfaces":[{"id":"IN","name":"Parent in ports","category":"custom","active":"in","signals":"i_clk_cluster, i_rst_n_cluster, i_cmo_valid, i_cmo_op, i_cmo_pa_line, i_cmo_vaddr, i_cmo_pc, i_cmo_hart, i_ccu_begin_ready, i_ccu_prepare_valid, i_ccu_prepare_tag, i_ccu_prepare_err, i_maint_ready, i_maint_done, i_maint_error, i_ccu_finish_ready, i_ccu_finish_done"},{"id":"OUT","name":"Parent out ports","category":"custom","active":"out","signals":"o_cmo_ready, o_cmo_done, o_cmo_error, o_cmo_vaddr, o_cmo_pc, o_cmo_hart, o_ccu_begin_valid, o_ccu_begin_op, o_ccu_begin_pa_line, o_ccu_begin_hart, o_ccu_begin_wback_en, o_ccu_prepare_ready, o_maint_valid, o_maint_op, o_maint_pa_line, o_ccu_finish_valid, o_ccu_finish_tag, o_ccu_finish_commit"}],"nets":[],"legend_note":"A single boundary symbol denotes a leaf: internal equations/registers are described in its function/dataflow contract, not invented child modules. NEW/MODIFY/REUSE/GENERATED provenance is listed in the block table. Clock/reset follow the common synchronous contract. Complete parent port declarations are in the component section.","library_sha256":"15DFB183E267D2A94F8CAB316E01EB3D2E9D2F9C006DC816790A394F4123506C"}
```

[Editable draw.io](figures/post_a06/m_vlsit_riscv_cmo_controller.drawio) · [Figure source](figures/post_a06/m_vlsit_riscv_cmo_controller.json).

**Interface contract.** All synchronous ports use the common cluster clock; the probe engine cache clock is the same domain in this cluster. A valid/ready payload is accepted only on the corresponding handshake and held through backpressure. Pulsed completion/ACK interfaces are described by the operation/FSM contract; they must not be treated as independent ready/valid channels.

| Direction | Exact source declaration |
|---|---|
| input | `wire i_clk_cluster` |
| input | `wire i_rst_n_cluster` |
| input | `wire i_cmo_valid` |
| output | `logic o_cmo_ready` |
| input | `wire [1:0] i_cmo_op` |
| input | `wire [51:0] i_cmo_pa_line` |
| input | `wire [63:0] i_cmo_vaddr` |
| input | `wire [63:0] i_cmo_pc` |
| input | `wire [1:0] i_cmo_hart` |
| output | `logic o_cmo_done` |
| output | `logic o_cmo_error` |
| output | `logic [63:0] o_cmo_vaddr` |
| output | `logic [63:0] o_cmo_pc` |
| output | `logic [1:0] o_cmo_hart` |
| output | `logic o_ccu_begin_valid` |
| input | `wire i_ccu_begin_ready` |
| output | `logic [1:0] o_ccu_begin_op` |
| output | `logic [51:0] o_ccu_begin_pa_line` |
| output | `logic [1:0] o_ccu_begin_hart` |
| output | `logic o_ccu_begin_wback_en` |
| input | `wire i_ccu_prepare_valid` |
| output | `logic o_ccu_prepare_ready` |
| input | `wire [LPARA_COH_TAG_W-1:0] i_ccu_prepare_tag` |
| input | `wire i_ccu_prepare_err` |
| output | `logic o_maint_valid` |
| input | `wire i_maint_ready` |
| output | `logic [1:0] o_maint_op` |
| output | `logic [51:0] o_maint_pa_line` |
| input | `wire i_maint_done` |
| input | `wire i_maint_error` |
| output | `logic o_ccu_finish_valid` |
| input | `wire i_ccu_finish_ready` |
| output | `logic [LPARA_COH_TAG_W-1:0] o_ccu_finish_tag` |
| output | `logic o_ccu_finish_commit` |
| input | `wire i_ccu_finish_done` |

**FSM:** [CMO_CONTROLLER](#cmo-controller). See Section 10.1 for every transition and retained obligation.

#### 14.4.24 `m_vlsit_riscv_coh_bank_arb` — NEW

Source: [rtl/common/vlsit/coherence/m_vlsit_riscv_coh_bank_arb.sv](../../rtl/vlsit/m_vlsit_riscv_coh_bank_arb.sv). Selected production source: **True**.

**Function.** Select eligible directory work fairly within each of four independent banks while preserving request identity.

**Working/data flow.** Filter ineligible requests before round-robin selection. Admit a lookup/update/cancel only when its owning context can legally proceed. Reservation-owner terminal work remains serviceable when another requester is blocked on the same set.

**State and storage ownership.** Per-bank round-robin/request-token state. Directory contents are not stored here.

**Safety, timing and error constraints.** An ineligible UPDATE must not hide the CANCEL that releases its reservation dependency. Consume a request token once and rearm only for a new eligible request.

**Verification boundary.** Bank-progress, reservation-cancel escape and A-05 directed units exist; saturated random fairness remains open.

The figure shows actual child composition; a leaf shows its own boundary. It does not invent intermediate RTL modules. / Hình thể hiện phân cấp source; leaf chỉ có symbol ranh giới, không tạo module giả.

![m_vlsit_riscv_coh_bank_arb composition](figures/post_a06/m_vlsit_riscv_coh_bank_arb.svg)

```json
{"page_name":"BLOCK_DIAGRAM","out_name":"m_vlsit_riscv_coh_bank_arb.drawio","layout":{"gap_h":120,"gap_v":110,"margin":80,"block_h":60},"top":{"frame_label":["Component composition","(m_vlsit_riscv_coh_bank_arb)"]},"frame_row":["m_vlsit_riscv_coh_bank_arb","Select eligible directory work fairly within each of four independent banks while preserving request identity.","rtl/common/vlsit/coherence/m_vlsit_riscv_coh_bank_arb.sv"],"frame_interfaces":["IN","OUT"],"blocks":[{"key":"B0","label":["component_boundary","(m_vlsit_riscv_coh_bank_arb)"],"width":340,"row":0,"col":0,"row_name":"component_boundary (m_vlsit_riscv_coh_bank_arb)","function":"Select eligible directory work fairly within each of four independent banks while preserving request identity.","source":"NEW; rtl/common/vlsit/coherence/m_vlsit_riscv_coh_bank_arb.sv"}],"connectors":[],"externals":[{"id":"IN","block":"B0","side":"L","dir":"in","pos":0,"text":["IN","ports"]},{"id":"OUT","block":"B0","side":"R","dir":"out","pos":0,"text":["OUT","ports"]}],"interfaces":[{"id":"IN","name":"Parent in ports","category":"custom","active":"in","signals":"i_clk_cluster, i_rst_n_cluster, i_req_valid, i_req_bank, i_gnt_ready"},{"id":"OUT","name":"Parent out ports","category":"custom","active":"out","signals":"o_gnt_valid, o_gnt_slot, o_bank_conflict_stall"}],"nets":[],"legend_note":"A single boundary symbol denotes a leaf: internal equations/registers are described in its function/dataflow contract, not invented child modules. NEW/MODIFY/REUSE/GENERATED provenance is listed in the block table. Clock/reset follow the common synchronous contract. Complete parent port declarations are in the component section.","library_sha256":"15DFB183E267D2A94F8CAB316E01EB3D2E9D2F9C006DC816790A394F4123506C"}
```

[Editable draw.io](figures/post_a06/m_vlsit_riscv_coh_bank_arb.drawio) · [Figure source](figures/post_a06/m_vlsit_riscv_coh_bank_arb.json).

**Interface contract.** All synchronous ports use the common cluster clock; the probe engine cache clock is the same domain in this cluster. A valid/ready payload is accepted only on the corresponding handshake and held through backpressure. Pulsed completion/ACK interfaces are described by the operation/FSM contract; they must not be treated as independent ready/valid channels.

| Direction | Exact source declaration |
|---|---|
| input | `wire i_clk_cluster` |
| input | `wire i_rst_n_cluster` |
| input | `wire [PARA_COH_TXN_NUM-1:0] i_req_valid` |
| input | `wire [PARA_COH_TXN_NUM-1:0][1:0] i_req_bank` |
| input | `wire [3:0] i_gnt_ready` |
| output | `logic [3:0] o_gnt_valid` |
| output | `logic [3:0][LPARA_COH_SLOT_W-1:0] o_gnt_slot` |
| output | `logic o_bank_conflict_stall` |

**FSM:** No new enum controller is declared by this module. Its combinational mapping, queue/valid-bit lifecycle, or instantiated child FSMs implement the behavior above. This is not a claim that the entire subtree is stateless.

#### 14.4.25 `m_vlsit_riscv_coh_fabric` — NEW

Source: [rtl/common/vlsit/coherence/m_vlsit_riscv_coh_fabric.sv](../../rtl/vlsit/m_vlsit_riscv_coh_fabric.sv). Selected production source: **True**.

**Function.** Coordinate directory lookup, ownership decisions, victim replacement, tagged two-phase probes and commit/abort for multiple in-flight cache lines.

**Working/data flow.** Allocate a root context only with a reserved victim escape credit available. Lookup the selected bank/set; capture owner/holders and actual PREPARE observations. If replacing a held directory entry, allocate a non-recursive victim child. If that victim is locked elsewhere, cancel the parent's set reservation before retrying. Publish directory changes only after successful terminal completion; return a retained success/error grant and release the matching context after consumption.

**State and storage ownership.** A state per context, retained requester/grant/error/victim/parent metadata and bank response bookkeeping; the transaction table holds phase-associated metadata and ACK masks.

**Safety, timing and error constraints.** Silent local E-to-M is legal and must be refined from actual probe results. Valid PREPARE-I can prune a conservative stale holder only at COMMIT. Owner writeback_done is required for actual dirty data. Missing phase ACKs have no timeout. N physical contexts admit at most N-1 CPU/CMO roots.

**Verification boundary.** A-01/A-02/A-04/A-05 targeted CPU/unit tests pass. This is not a formal global deadlock or all-traffic fairness proof.

The figure shows actual child composition; a leaf shows its own boundary. It does not invent intermediate RTL modules. / Hình thể hiện phân cấp source; leaf chỉ có symbol ranh giới, không tạo module giả.

![m_vlsit_riscv_coh_fabric composition](figures/post_a06/m_vlsit_riscv_coh_fabric.svg)

```json
{"page_name":"BLOCK_DIAGRAM","out_name":"m_vlsit_riscv_coh_fabric.drawio","layout":{"gap_h":120,"gap_v":110,"margin":80,"block_h":60},"top":{"frame_label":["Component composition","(m_vlsit_riscv_coh_fabric)"]},"frame_row":["m_vlsit_riscv_coh_fabric","Coordinate directory lookup, ownership decisions, victim replacement, tagged two-phase probes and commit/abort for multiple in-flight cache lines.","rtl/common/vlsit/coherence/m_vlsit_riscv_coh_fabric.sv"],"frame_interfaces":[],"blocks":[{"key":"B0","label":["u_vlsit_riscv_coh_bank_arb","(m_vlsit_riscv_coh_bank_arb)"],"width":340,"row":0,"col":0,"row_name":"u_vlsit_riscv_coh_bank_arb (m_vlsit_riscv_coh_bank_arb)","function":"Select eligible directory work fairly within each of four independent banks while preserving request identity.","source":"NEW; rtl/common/vlsit/coherence/m_vlsit_riscv_coh_bank_arb.sv"},{"key":"B1","label":["u_vlsit_riscv_coh_txn_table","(m_vlsit_riscv_coh_txn_table)"],"width":340,"row":0,"col":1,"row_name":"u_vlsit_riscv_coh_txn_table (m_vlsit_riscv_coh_txn_table)","function":"Own the lifetime and immutable identity of every active coherence transaction and its current probe phase.","source":"NEW; rtl/common/vlsit/coherence/m_vlsit_riscv_coh_txn_table.sv"},{"key":"B2","label":["u_vlsit_riscv_probe_scheduler","(m_vlsit_riscv_probe_scheduler)"],"width":360,"row":1,"col":0,"row_name":"u_vlsit_riscv_probe_scheduler (m_vlsit_riscv_probe_scheduler)","function":"Schedule one active tagged probe per cache and route matching cache responses to the correct context.","source":"NEW; rtl/common/vlsit/coherence/m_vlsit_riscv_probe_scheduler.sv"},{"key":"B3","label":["u_vlsit_riscv_sharer_directory","(m_vlsit_riscv_sharer_directory)"],"width":380,"row":1,"col":1,"row_name":"u_vlsit_riscv_sharer_directory (m_vlsit_riscv_sharer_directory)","function":"Store a conservative set of L1 holders and MESI/owner metadata independently of shared LLC residency.","source":"NEW; rtl/common/vlsit/coherence/m_vlsit_riscv_sharer_directory.sv"}],"connectors":[],"externals":[],"interfaces":[],"nets":[],"legend_note":"Exact source-referenced children; generate multiplicity and active branches are specified in the component text. Containment denotes hierarchy, not invented signal connectivity. NEW/MODIFY/REUSE/GENERATED provenance is listed in the block table. Clock/reset follow the common synchronous contract. Complete parent port declarations are in the component section.","library_sha256":"15DFB183E267D2A94F8CAB316E01EB3D2E9D2F9C006DC816790A394F4123506C"}
```

[Editable draw.io](figures/post_a06/m_vlsit_riscv_coh_fabric.drawio) · [Figure source](figures/post_a06/m_vlsit_riscv_coh_fabric.json).

**Interface contract.** All synchronous ports use the common cluster clock; the probe engine cache clock is the same domain in this cluster. A valid/ready payload is accepted only on the corresponding handshake and held through backpressure. Pulsed completion/ACK interfaces are described by the operation/FSM contract; they must not be treated as independent ready/valid channels.

| Direction | Exact source declaration |
|---|---|
| input | `wire i_clk_cluster` |
| input | `wire i_rst_n_cluster` |
| input | `wire i_ccu_begin_valid` |
| output | `logic o_ccu_begin_ready` |
| input | `wire [1:0] i_ccu_begin_op` |
| input | `wire [51:0] i_ccu_begin_pa_line` |
| input | `wire [1:0] i_ccu_begin_hart` |
| input | `wire i_ccu_begin_wback_en` |
| output | `logic o_ccu_prepare_valid` |
| input | `wire i_ccu_prepare_ready` |
| output | `logic [LPARA_COH_TAG_W-1:0] o_ccu_prepare_tag` |
| output | `logic o_ccu_prepare_err` |
| input | `wire i_ccu_finish_valid` |
| output | `logic o_ccu_finish_ready` |
| input | `wire [LPARA_COH_TAG_W-1:0] i_ccu_finish_tag` |
| input | `wire i_ccu_finish_commit` |
| output | `logic o_ccu_finish_done` |
| input | `wire [PARA_CPU_NUM-1:0] i_req_valid` |
| output | `logic [PARA_CPU_NUM-1:0] o_req_ready` |
| input | `wire [PARA_CPU_NUM-1:0][2:0] i_req_id` |
| input | `wire [PARA_CPU_NUM-1:0][51:0] i_req_pa_line` |
| input | `wire [PARA_CPU_NUM-1:0][1:0] i_req_kind` |
| output | `logic [PARA_CPU_NUM-1:0] o_gnt_valid` |
| input | `wire [PARA_CPU_NUM-1:0] i_gnt_ready` |
| output | `logic [PARA_CPU_NUM-1:0][2:0] o_gnt_req_id` |
| output | `logic [PARA_CPU_NUM-1:0][51:0] o_gnt_pa_line` |
| output | `logic [PARA_CPU_NUM-1:0][1:0] o_gnt_state` |
| output | `logic [PARA_CPU_NUM-1:0] o_gnt_err` |
| output | `logic [PARA_CPU_NUM-1:0] o_probe_req_valid` |
| input | `wire [PARA_CPU_NUM-1:0] i_probe_req_ready` |
| output | `logic [PARA_CPU_NUM-1:0][LPARA_COH_TAG_W-1:0] o_probe_req_tag` |
| output | `logic [PARA_CPU_NUM-1:0][51:0] o_probe_req_pa_line` |
| output | `logic [PARA_CPU_NUM-1:0][1:0] o_probe_req_phase` |
| output | `logic [PARA_CPU_NUM-1:0][1:0] o_probe_req_target_state` |
| output | `logic [PARA_CPU_NUM-1:0] o_probe_req_wback_en` |
| input | `wire [PARA_CPU_NUM-1:0] i_probe_rsp_valid` |
| output | `logic [PARA_CPU_NUM-1:0] o_probe_rsp_ready` |
| input | `wire [PARA_CPU_NUM-1:0][LPARA_COH_TAG_W-1:0] i_probe_rsp_tag` |
| input | `wire [PARA_CPU_NUM-1:0][51:0] i_probe_rsp_pa_line` |
| input | `wire [PARA_CPU_NUM-1:0][1:0] i_probe_rsp_phase` |
| input | `wire [PARA_CPU_NUM-1:0][1:0] i_probe_rsp_state` |
| input | `wire [PARA_CPU_NUM-1:0] i_probe_rsp_err` |
| input | `wire [PARA_CPU_NUM-1:0] i_probe_rsp_wback_done` |
| input | `wire i_same_line_lock_stall` |
| output | `logic o_coh_proto_diag_event` |
| output | `logic [2:0] o_dir_lookup_count` |
| output | `logic [2:0] o_dir_update_count` |
| output | `logic [11:0][2:0] o_ccu_evt_count` |

**FSM:** [CCU_CONTEXT](#ccu-context), [CCU_LOOKUP_VICTIM](#ccu-lookup-victim), [CCU_PREPARE_CMO](#ccu-prepare-cmo), [CCU_COMMIT_RELEASE](#ccu-commit-release), [CCU_ABORT_RELEASE](#ccu-abort-release). See Section 10.1 for every transition and retained obligation.

#### 14.4.26 `m_vlsit_riscv_coh_tile_array` — NEW

Source: [rtl/common/vlsit/coherence/m_vlsit_riscv_coh_tile_array.sv](../../rtl/vlsit/m_vlsit_riscv_coh_tile_array.sv). Selected production source: **True**.

**Function.** Compose one ownership/probe adapter per active hart with the multi-context directory-based MESI fabric.

**Working/data flow.** Collect per-tile permission requests, propagate tagged grants, distribute PREPARE/COMMIT/ABORT probes and carry their responses back to the transaction context. Query actual cache activity before servicing a probe and expose line locks to CPU access/victim selection.

**State and storage ownership.** Adapter locks and fabric contexts are separate storage owners. Tags identify active contexts; a tag is not a software hart ID.

**Safety, timing and error constraints.** Do not conflate a probe handshake with completion. A cache may retain a prepared line across multiple cycles while waiting for its matching terminal phase.

**Verification boundary.** Composed control units plus CPU atomic/maintenance paths pass. General multi-hart data correctness requires an independent memory scoreboard.

The figure shows actual child composition; a leaf shows its own boundary. It does not invent intermediate RTL modules. / Hình thể hiện phân cấp source; leaf chỉ có symbol ranh giới, không tạo module giả.

![m_vlsit_riscv_coh_tile_array composition](figures/post_a06/m_vlsit_riscv_coh_tile_array.svg)

```json
{"page_name":"BLOCK_DIAGRAM","out_name":"m_vlsit_riscv_coh_tile_array.drawio","layout":{"gap_h":120,"gap_v":110,"margin":80,"block_h":60},"top":{"frame_label":["Component composition","(m_vlsit_riscv_coh_tile_array)"]},"frame_row":["m_vlsit_riscv_coh_tile_array","Compose one ownership/probe adapter per active hart with the multi-context directory-based MESI fabric.","rtl/common/vlsit/coherence/m_vlsit_riscv_coh_tile_array.sv"],"frame_interfaces":[],"blocks":[{"key":"B0","label":["u_vlsit_riscv_coh_fabric","(m_vlsit_riscv_coh_fabric)"],"width":300,"row":0,"col":0,"row_name":"u_vlsit_riscv_coh_fabric (m_vlsit_riscv_coh_fabric)","function":"Coordinate directory lookup, ownership decisions, victim replacement, tagged two-phase probes and commit/abort for multiple in-flight cache lines.","source":"NEW; rtl/common/vlsit/coherence/m_vlsit_riscv_coh_fabric.sv"},{"key":"B1","label":["u_vlsit_riscv_tile_coh_adapter","(m_vlsit_riscv_tile_coh_adapter)"],"width":380,"row":1,"col":0,"row_name":"u_vlsit_riscv_tile_coh_adapter (m_vlsit_riscv_tile_coh_adapter)","function":"Bridge native tile ownership/probe interfaces to the cluster fabric while enforcing line-busy and lock constraints.","source":"NEW; rtl/common/vlsit/coherence/m_vlsit_riscv_tile_coh_adapter.sv"}],"connectors":[],"externals":[],"interfaces":[],"nets":[],"legend_note":"Exact source-referenced children; generate multiplicity and active branches are specified in the component text. Containment denotes hierarchy, not invented signal connectivity. NEW/MODIFY/REUSE/GENERATED provenance is listed in the block table. Clock/reset follow the common synchronous contract. Complete parent port declarations are in the component section.","library_sha256":"15DFB183E267D2A94F8CAB316E01EB3D2E9D2F9C006DC816790A394F4123506C"}
```

[Editable draw.io](figures/post_a06/m_vlsit_riscv_coh_tile_array.drawio) · [Figure source](figures/post_a06/m_vlsit_riscv_coh_tile_array.json).

**Interface contract.** All synchronous ports use the common cluster clock; the probe engine cache clock is the same domain in this cluster. A valid/ready payload is accepted only on the corresponding handshake and held through backpressure. Pulsed completion/ACK interfaces are described by the operation/FSM contract; they must not be treated as independent ready/valid channels.

| Direction | Exact source declaration |
|---|---|
| input | `wire i_ccu_begin_valid` |
| output | `logic o_ccu_begin_ready` |
| input | `wire [1:0] i_ccu_begin_op` |
| input | `wire [51:0] i_ccu_begin_pa_line` |
| input | `wire [1:0] i_ccu_begin_hart` |
| input | `wire i_ccu_begin_wback_en` |
| output | `logic o_ccu_prepare_valid` |
| input | `wire i_ccu_prepare_ready` |
| output | `logic [LPARA_COH_TAG_W-1:0] o_ccu_prepare_tag` |
| output | `logic o_ccu_prepare_err` |
| input | `wire i_ccu_finish_valid` |
| output | `logic o_ccu_finish_ready` |
| input | `wire [LPARA_COH_TAG_W-1:0] i_ccu_finish_tag` |
| input | `wire i_ccu_finish_commit` |
| output | `logic o_ccu_finish_done` |
| input | `wire i_clk_cluster` |
| input | `wire i_rst_n_cluster` |
| input | `wire [PARA_CPU_NUM-1:0] i_tile_access_valid` |
| input | `wire [PARA_CPU_NUM-1:0][51:0] i_tile_access_pa_line` |
| output | `logic [PARA_CPU_NUM-1:0] o_tile_access_locked` |
| input | `wire [PARA_CPU_NUM-1:0] i_tile_victim_valid` |
| input | `wire [PARA_CPU_NUM-1:0][51:0] i_tile_victim_pa_line` |
| output | `logic [PARA_CPU_NUM-1:0] o_tile_victim_locked` |
| input | `wire [PARA_CPU_NUM-1:0] i_tile_req_valid` |
| output | `logic [PARA_CPU_NUM-1:0] o_tile_req_ready` |
| input | `wire [PARA_CPU_NUM-1:0][2:0] i_tile_req_id` |
| input | `wire [PARA_CPU_NUM-1:0][51:0] i_tile_req_pa_line` |
| input | `wire [PARA_CPU_NUM-1:0][1:0] i_tile_req_kind` |
| output | `logic [PARA_CPU_NUM-1:0] o_tile_gnt_valid` |
| input | `wire [PARA_CPU_NUM-1:0] i_tile_gnt_ready` |
| output | `logic [PARA_CPU_NUM-1:0][2:0] o_tile_gnt_id` |
| output | `logic [PARA_CPU_NUM-1:0][51:0] o_tile_gnt_pa_line` |
| output | `logic [PARA_CPU_NUM-1:0][1:0] o_tile_gnt_state` |
| output | `logic [PARA_CPU_NUM-1:0] o_tile_gnt_err` |
| output | `logic [PARA_CPU_NUM-1:0] o_tile_probe_req_valid` |
| input | `wire [PARA_CPU_NUM-1:0] i_tile_probe_req_ready` |
| output | `logic [PARA_CPU_NUM-1:0][LPARA_COH_TAG_W-1:0] o_tile_probe_req_tag` |
| output | `logic [PARA_CPU_NUM-1:0][51:0] o_tile_probe_req_pa_line` |
| output | `logic [PARA_CPU_NUM-1:0][1:0] o_tile_probe_req_phase` |
| output | `logic [PARA_CPU_NUM-1:0][1:0] o_tile_probe_req_target_state` |
| output | `logic [PARA_CPU_NUM-1:0] o_tile_probe_req_wback_en` |
| input | `wire [PARA_CPU_NUM-1:0] i_tile_probe_rsp_valid` |
| output | `logic [PARA_CPU_NUM-1:0] o_tile_probe_rsp_ready` |
| input | `wire [PARA_CPU_NUM-1:0][LPARA_COH_TAG_W-1:0] i_tile_probe_rsp_tag` |
| input | `wire [PARA_CPU_NUM-1:0][51:0] i_tile_probe_rsp_pa_line` |
| input | `wire [PARA_CPU_NUM-1:0][1:0] i_tile_probe_rsp_phase` |
| input | `wire [PARA_CPU_NUM-1:0][1:0] i_tile_probe_rsp_state` |
| input | `wire [PARA_CPU_NUM-1:0] i_tile_probe_rsp_err` |
| input | `wire [PARA_CPU_NUM-1:0] i_tile_probe_rsp_wback_done` |
| output | `logic [PARA_CPU_NUM-1:0] o_tile_probe_query_valid` |
| output | `logic [PARA_CPU_NUM-1:0][51:0] o_tile_probe_query_pa_line` |
| input | `wire [PARA_CPU_NUM-1:0] i_tile_probe_line_busy` |
| output | `logic [PARA_CPU_NUM-1:0][PARA_COH_TXN_NUM-1:0] o_tile_line_lock_valid` |
| output | `logic [PARA_CPU_NUM-1:0][PARA_COH_TXN_NUM-1:0][51:0] o_tile_line_lock_pa_line` |
| output | `logic [PARA_CPU_NUM-1:0] o_tile_lock_diag_event` |
| output | `logic o_coh_proto_diag_event` |
| output | `logic [2:0] o_dir_lookup_count` |
| output | `logic [2:0] o_dir_update_count` |
| output | `logic [11:0][2:0] o_ccu_evt_count` |

**FSM:** No new enum controller is declared by this module. Its combinational mapping, queue/valid-bit lifecycle, or instantiated child FSMs implement the behavior above. This is not a claim that the entire subtree is stateless.

#### 14.4.27 `m_vlsit_riscv_coh_txn_table` — NEW

Source: [rtl/common/vlsit/coherence/m_vlsit_riscv_coh_txn_table.sv](../../rtl/vlsit/m_vlsit_riscv_coh_txn_table.sv). Selected production source: **True**.

**Function.** Own the lifetime and immutable identity of every active coherence transaction and its current probe phase.

**Working/data flow.** Allocate a free slot, retain line/requester/kind/target state, capture owner and phase information, accumulate only matching ACKs, preserve writeback/error obligations across phase changes, and release only the selected terminal context after response draining.

**State and storage ownership.** Per-slot valid, address, source/owner, target MESI, phase, expected/received masks and writeback/error state. PARA_COH_TXN_NUM is 2 through 16; default 8. CCU context tag width is max(1, clog2(context count)); the native probe endpoint has a separate fixed four-bit field adapted by its wrapper.

**Safety, timing and error constraints.** A new phase must not clear obligations needed by a later phase. Invalid or duplicate ACKs must not retire a live context. Reserved victim credit is an allocation policy enforced with the fabric.

**Verification boundary.** Context full/wrap, identity, phase retention, invalid ACK and mutation checks exist; random reorder coverage remains incomplete.

The figure shows actual child composition; a leaf shows its own boundary. It does not invent intermediate RTL modules. / Hình thể hiện phân cấp source; leaf chỉ có symbol ranh giới, không tạo module giả.

![m_vlsit_riscv_coh_txn_table composition](figures/post_a06/m_vlsit_riscv_coh_txn_table.svg)

```json
{"page_name":"BLOCK_DIAGRAM","out_name":"m_vlsit_riscv_coh_txn_table.drawio","layout":{"gap_h":120,"gap_v":110,"margin":80,"block_h":60},"top":{"frame_label":["Component composition","(m_vlsit_riscv_coh_txn_table)"]},"frame_row":["m_vlsit_riscv_coh_txn_table","Own the lifetime and immutable identity of every active coherence transaction and its current probe phase.","rtl/common/vlsit/coherence/m_vlsit_riscv_coh_txn_table.sv"],"frame_interfaces":["IN","OUT"],"blocks":[{"key":"B0","label":["component_boundary","(m_vlsit_riscv_coh_txn_table)"],"width":340,"row":0,"col":0,"row_name":"component_boundary (m_vlsit_riscv_coh_txn_table)","function":"Own the lifetime and immutable identity of every active coherence transaction and its current probe phase.","source":"NEW; rtl/common/vlsit/coherence/m_vlsit_riscv_coh_txn_table.sv"}],"connectors":[],"externals":[{"id":"IN","block":"B0","side":"L","dir":"in","pos":0,"text":["IN","ports"]},{"id":"OUT","block":"B0","side":"R","dir":"out","pos":0,"text":["OUT","ports"]}],"interfaces":[{"id":"IN","name":"Parent in ports","category":"custom","active":"in","signals":"i_clk_cluster, i_rst_n_cluster, i_alloc_valid, i_alloc_src, i_alloc_req_id, i_alloc_pa_line, i_alloc_kind, i_alloc_target_state, i_alloc_wback_en, i_release_valid, i_release_tag, i_phase_start_valid, i_phase_start_tag, i_phase_start, i_phase_expected, i_owner_capture_valid, i_owner_capture_tag, i_owner_capture_present, i_owner_capture_hart, i_ack_valid, i_ack_tag, i_ack_phase, i_ack_err, i_ack_wback_done"},{"id":"OUT","name":"Parent out ports","category":"custom","active":"out","signals":"o_alloc_ready, o_alloc_tag, o_release_ready, o_phase_start_ready, o_owner_capture_ready, o_ack_ready, o_ctx_valid, o_ctx_src, o_ctx_req_id, o_ctx_pa_line, o_ctx_kind, o_ctx_phase, o_ctx_ack_expected, o_ctx_ack_received, o_ctx_phase_active, o_ctx_phase_done, o_ctx_phase_err, o_ctx_owner_wback_done, o_ctx_target_state, o_ctx_wback_en, o_ctx_owner_known, o_ctx_owner_present, o_ctx_owner_hart, o_ctx_txn_err, o_ctx_owner_wback_err, o_coh_proto_diag_event"}],"nets":[],"legend_note":"A single boundary symbol denotes a leaf: internal equations/registers are described in its function/dataflow contract, not invented child modules. NEW/MODIFY/REUSE/GENERATED provenance is listed in the block table. Clock/reset follow the common synchronous contract. Complete parent port declarations are in the component section.","library_sha256":"15DFB183E267D2A94F8CAB316E01EB3D2E9D2F9C006DC816790A394F4123506C"}
```

[Editable draw.io](figures/post_a06/m_vlsit_riscv_coh_txn_table.drawio) · [Figure source](figures/post_a06/m_vlsit_riscv_coh_txn_table.json).

**Interface contract.** All synchronous ports use the common cluster clock; the probe engine cache clock is the same domain in this cluster. A valid/ready payload is accepted only on the corresponding handshake and held through backpressure. Pulsed completion/ACK interfaces are described by the operation/FSM contract; they must not be treated as independent ready/valid channels.

| Direction | Exact source declaration |
|---|---|
| input | `wire i_clk_cluster` |
| input | `wire i_rst_n_cluster` |
| input | `wire i_alloc_valid` |
| output | `logic o_alloc_ready` |
| input | `wire [2:0] i_alloc_src` |
| input | `wire [2:0] i_alloc_req_id` |
| input | `wire [51:0] i_alloc_pa_line` |
| input | `wire [1:0] i_alloc_kind` |
| input | `wire [1:0] i_alloc_target_state` |
| input | `wire i_alloc_wback_en` |
| output | `logic [LPARA_COH_TAG_W-1:0] o_alloc_tag` |
| input | `wire i_release_valid` |
| input | `wire [LPARA_COH_TAG_W-1:0] i_release_tag` |
| output | `logic o_release_ready` |
| input | `wire i_phase_start_valid` |
| input | `wire [LPARA_COH_TAG_W-1:0] i_phase_start_tag` |
| input | `wire [1:0] i_phase_start` |
| input | `wire [PARA_CPU_NUM-1:0] i_phase_expected` |
| output | `logic o_phase_start_ready` |
| input | `wire i_owner_capture_valid` |
| output | `logic o_owner_capture_ready` |
| input | `wire [LPARA_COH_TAG_W-1:0] i_owner_capture_tag` |
| input | `wire i_owner_capture_present` |
| input | `wire [1:0] i_owner_capture_hart` |
| input | `wire [PARA_CPU_NUM-1:0] i_ack_valid` |
| output | `logic [PARA_CPU_NUM-1:0] o_ack_ready` |
| input | `wire [PARA_CPU_NUM-1:0][LPARA_COH_TAG_W-1:0] i_ack_tag` |
| input | `wire [PARA_CPU_NUM-1:0][1:0] i_ack_phase` |
| input | `wire [PARA_CPU_NUM-1:0] i_ack_err` |
| input | `wire [PARA_CPU_NUM-1:0] i_ack_wback_done` |
| output | `logic [PARA_COH_TXN_NUM-1:0] o_ctx_valid` |
| output | `logic [PARA_COH_TXN_NUM-1:0][2:0] o_ctx_src` |
| output | `logic [PARA_COH_TXN_NUM-1:0][2:0] o_ctx_req_id` |
| output | `logic [PARA_COH_TXN_NUM-1:0][51:0] o_ctx_pa_line` |
| output | `logic [PARA_COH_TXN_NUM-1:0][1:0] o_ctx_kind` |
| output | `logic [PARA_COH_TXN_NUM-1:0][1:0] o_ctx_phase` |
| output | `logic [PARA_COH_TXN_NUM-1:0][PARA_CPU_NUM-1:0] o_ctx_ack_expected` |
| output | `logic [PARA_COH_TXN_NUM-1:0][PARA_CPU_NUM-1:0] o_ctx_ack_received` |
| output | `logic [PARA_COH_TXN_NUM-1:0] o_ctx_phase_active` |
| output | `logic [PARA_COH_TXN_NUM-1:0] o_ctx_phase_done` |
| output | `logic [PARA_COH_TXN_NUM-1:0] o_ctx_phase_err` |
| output | `logic [PARA_COH_TXN_NUM-1:0] o_ctx_owner_wback_done` |
| output | `logic [PARA_COH_TXN_NUM-1:0][1:0] o_ctx_target_state` |
| output | `logic [PARA_COH_TXN_NUM-1:0] o_ctx_wback_en` |
| output | `logic [PARA_COH_TXN_NUM-1:0] o_ctx_owner_known` |
| output | `logic [PARA_COH_TXN_NUM-1:0] o_ctx_owner_present` |
| output | `logic [PARA_COH_TXN_NUM-1:0][1:0] o_ctx_owner_hart` |
| output | `logic [PARA_COH_TXN_NUM-1:0] o_ctx_txn_err` |
| output | `logic [PARA_COH_TXN_NUM-1:0] o_ctx_owner_wback_err` |
| output | `logic o_coh_proto_diag_event` |

**FSM:** No new enum controller is declared by this module. Its combinational mapping, queue/valid-bit lifecycle, or instantiated child FSMs implement the behavior above. This is not a claim that the entire subtree is stateless.

#### 14.4.28 `m_vlsit_riscv_cpu_tile` — NEW

Source: [rtl/common/vlsit/cpu/m_vlsit_riscv_cpu_tile.sv](../../rtl/vlsit/m_vlsit_riscv_cpu_tile.sv). Selected production source: **True**.

**Function.** Wrap the locally adapted native CVA6 and derive its physical memory attributes from the same region table used by the AXI router.

**Working/data flow.** CVA6 fetches at the shared boot entry and distinguishes harts by hart ID. The cache subsystem routes D-cache ownership/probes and native writeback ACKs through the wrapper. The same compile-time address table classifies outgoing AW/AR transactions. External maintenance completion returns to CVA6 retirement; per-hart IRQ/debug signals retain their source identity.

**State and storage ownership.** Native pipeline, MMU, instruction cache, HPDcache and FPU state are inside CVA6. The wrapper itself does not duplicate cache data.

**Safety, timing and error constraints.** ExternalCmo is enabled by the production cluster. CVXIF is disabled in the local licensed configuration. The wrapper must preserve native request IDs and source semantics rather than restyle upstream ports.

**Verification boundary.** Real CPU boot/load/store/atomic/CMO and selected M/S trap cases pass. Full ISA, Sv39 and OS qualification remain open.

The figure shows actual child composition; a leaf shows its own boundary. It does not invent intermediate RTL modules. / Hình thể hiện phân cấp source; leaf chỉ có symbol ranh giới, không tạo module giả.

![m_vlsit_riscv_cpu_tile composition](figures/post_a06/m_vlsit_riscv_cpu_tile.svg)

```json
{"page_name":"BLOCK_DIAGRAM","out_name":"m_vlsit_riscv_cpu_tile.drawio","layout":{"gap_h":120,"gap_v":110,"margin":80,"block_h":60},"top":{"frame_label":["Component composition","(m_vlsit_riscv_cpu_tile)"]},"frame_row":["m_vlsit_riscv_cpu_tile","Wrap the locally adapted native CVA6 and derive its physical memory attributes from the same region table used by the AXI router.","rtl/common/vlsit/cpu/m_vlsit_riscv_cpu_tile.sv"],"frame_interfaces":[],"blocks":[{"key":"B0","label":["u_dont_touch_cva6","(cva6)"],"width":200,"row":0,"col":0,"row_name":"u_dont_touch_cva6 (cva6)","function":"Native CPU integration boundary","source":"MODIFY; rtl/common/modified/cva6/core/cva6.sv"},{"key":"B1","label":["u_vlsit_riscv_addr_decode_ar","(m_vlsit_riscv_addr_decode)"],"width":340,"row":0,"col":1,"row_name":"u_vlsit_riscv_addr_decode_ar (m_vlsit_riscv_addr_decode)","function":"Classify a complete physical access against a shared compile-time region table.","source":"NEW; rtl/common/vlsit/address_map/m_vlsit_riscv_addr_decode.sv"},{"key":"B2","label":["u_vlsit_riscv_addr_decode_aw","(m_vlsit_riscv_addr_decode)"],"width":340,"row":1,"col":0,"row_name":"u_vlsit_riscv_addr_decode_aw (m_vlsit_riscv_addr_decode)","function":"Classify a complete physical access against a shared compile-time region table.","source":"NEW; rtl/common/vlsit/address_map/m_vlsit_riscv_addr_decode.sv"}],"connectors":[],"externals":[],"interfaces":[],"nets":[],"legend_note":"Exact source-referenced children; generate multiplicity and active branches are specified in the component text. Containment denotes hierarchy, not invented signal connectivity. NEW/MODIFY/REUSE/GENERATED provenance is listed in the block table. Clock/reset follow the common synchronous contract. Complete parent port declarations are in the component section.","library_sha256":"15DFB183E267D2A94F8CAB316E01EB3D2E9D2F9C006DC816790A394F4123506C"}
```

[Editable draw.io](figures/post_a06/m_vlsit_riscv_cpu_tile.drawio) · [Figure source](figures/post_a06/m_vlsit_riscv_cpu_tile.json).

**Interface contract.** All synchronous ports use the common cluster clock; the probe engine cache clock is the same domain in this cluster. A valid/ready payload is accepted only on the corresponding handshake and held through backpressure. Pulsed completion/ACK interfaces are described by the operation/FSM contract; they must not be treated as independent ready/valid channels.

| Direction | Exact source declaration |
|---|---|
| input | `wire i_clk_tile` |
| input | `wire i_rst_n_tile` |
| input | `wire [63:0] i_boot_addr` |
| input | `wire [63:0] i_hart_id` |
| output | `logic o_cmo_req_valid` |
| input | `wire i_cmo_req_ready` |
| output | `logic [1:0] o_cmo_req_op` |
| output | `logic [51:0] o_cmo_req_pa_line` |
| output | `logic [63:0] o_cmo_req_vaddr` |
| output | `logic [63:0] o_cmo_req_pc` |
| input | `wire i_cmo_rsp_done` |
| input | `wire i_cmo_rsp_err` |
| input | `wire i_int_msip` |
| input | `wire i_int_mtip` |
| input | `wire i_int_meip` |
| input | `wire i_int_ssip` |
| input | `wire i_int_stip` |
| input | `wire i_int_seip` |
| input | `wire i_hart_debug_req` |
| output | `logic o_hart_debug_mode` |
| output | `logic [21:0] o_perf_event` |
| output | `logic [15:0] o_hpdcache_perf_event` |
| output | `logic o_dcache_flush_ack_valid` |
| output | `logic [51:0] o_dcache_flush_ack_nline` |
| output | `logic [1:0] o_dcache_flush_ack_origin` |
| output | `logic o_dcache_flush_ack_err` |
| output | `logic o_dcache_flush_rsp_invalid` |
| output | `logic o_cmo_entry_valid` |
| output | `logic [7:0] o_cmo_entry_op` |
| output | `logic [51:0] o_cmo_entry_pa_line` |
| output | `logic [63:0] o_cmo_entry_vaddr` |
| input | `wire i_coh_probe_query_valid` |
| input | `wire [51:0] i_coh_probe_query_nline` |
| output | `logic o_coh_probe_line_busy` |
| output | `logic o_coh_access_line_valid` |
| output | `logic [51:0] o_coh_access_nline` |
| output | `logic o_coh_victim_line_valid` |
| output | `logic [51:0] o_coh_victim_nline` |
| input | `wire [PARA_COH_TXN_NUM-1:0] i_coh_line_lock_valid` |
| input | `wire [PARA_COH_TXN_NUM-1:0][51:0] i_coh_line_lock_nline` |
| input | `wire i_coh_probe_req_valid` |
| output | `logic o_coh_probe_req_ready` |
| input | `wire [LPARA_COH_TAG_W-1:0] i_coh_probe_req_tag` |
| input | `wire [51:0] i_coh_probe_req_nline` |
| input | `wire [1:0] i_coh_probe_req_phase` |
| input | `wire [1:0] i_coh_probe_req_target_state` |
| input | `wire i_coh_probe_req_wback_en` |
| output | `logic o_coh_probe_rsp_valid` |
| input | `wire i_coh_probe_rsp_ready` |
| output | `logic [LPARA_COH_TAG_W-1:0] o_coh_probe_rsp_tag` |
| output | `logic [51:0] o_coh_probe_rsp_nline` |
| output | `logic [1:0] o_coh_probe_rsp_phase` |
| output | `logic [1:0] o_coh_probe_rsp_state` |
| output | `logic o_coh_probe_rsp_err` |
| output | `logic o_coh_probe_rsp_wback_done` |
| output | `logic o_coh_cache_req_valid` |
| input | `wire i_coh_cache_req_ready` |
| output | `logic [2:0] o_coh_cache_req_id` |
| output | `logic [51:0] o_coh_cache_req_nline` |
| output | `logic [1:0] o_coh_cache_req_kind` |
| input | `wire i_coh_cache_gnt_valid` |
| output | `logic o_coh_cache_gnt_ready` |
| input | `wire [2:0] i_coh_cache_gnt_id` |
| input | `wire [51:0] i_coh_cache_gnt_nline` |
| input | `wire [1:0] i_coh_cache_gnt_state` |
| input | `wire i_coh_cache_gnt_err` |
| output | `logic [3:0] o_axi_awid` |
| output | `logic [5:0] o_axi_awatop` |
| output | `logic [63:0] o_axi_awaddr` |
| output | `logic [7:0] o_axi_awlen` |
| output | `logic [2:0] o_axi_awsize` |
| output | `logic [1:0] o_axi_awburst` |
| output | `logic o_axi_awlock` |
| output | `logic [3:0] o_axi_awcache` |
| output | `logic [2:0] o_axi_awprot` |
| output | `logic [3:0] o_axi_awqos` |
| output | `logic [3:0] o_axi_awregion` |
| output | `logic o_axi_awvalid` |
| output | `logic o_axi_aw_region_match` |
| output | `logic [3:0] o_axi_aw_region_idx` |
| output | `logic [1:0] o_axi_aw_region_type` |
| output | `logic o_axi_aw_region_err` |
| input | `wire i_axi_awready` |
| output | `logic [63:0] o_axi_wdata` |
| output | `logic [7:0] o_axi_wstrb` |
| output | `logic o_axi_wlast` |
| output | `logic o_axi_wvalid` |
| input | `wire i_axi_wready` |
| input | `wire [3:0] i_axi_bid` |
| input | `wire [1:0] i_axi_bresp` |
| input | `wire i_axi_bvalid` |
| output | `logic o_axi_bready` |
| output | `logic [3:0] o_axi_arid` |
| output | `logic [63:0] o_axi_araddr` |
| output | `logic [7:0] o_axi_arlen` |
| output | `logic [2:0] o_axi_arsize` |
| output | `logic [1:0] o_axi_arburst` |
| output | `logic o_axi_arlock` |
| output | `logic [3:0] o_axi_arcache` |
| output | `logic [2:0] o_axi_arprot` |
| output | `logic [3:0] o_axi_arqos` |
| output | `logic [3:0] o_axi_arregion` |
| output | `logic o_axi_arvalid` |
| output | `logic o_axi_ar_region_match` |
| output | `logic [3:0] o_axi_ar_region_idx` |
| output | `logic [1:0] o_axi_ar_region_type` |
| output | `logic o_axi_ar_region_err` |
| output | `logic o_addr_region_config_valid` |
| input | `wire i_axi_arready` |
| input | `wire [3:0] i_axi_rid` |
| input | `wire [63:0] i_axi_rdata` |
| input | `wire [1:0] i_axi_rresp` |
| input | `wire i_axi_rlast` |
| input | `wire i_axi_rvalid` |
| output | `logic o_axi_rready` |

**FSM:** No new enum controller is declared by this module. Its combinational mapping, queue/valid-bit lifecycle, or instantiated child FSMs implement the behavior above. This is not a claim that the entire subtree is stateless.

#### 14.4.29 `m_vlsit_riscv_cpu_tile_array` — NEW

Source: [rtl/common/vlsit/cpu/m_vlsit_riscv_cpu_tile_array.sv](../../rtl/vlsit/m_vlsit_riscv_cpu_tile_array.sv). Selected production source: **True**.

**Function.** Replicate active CPU tiles and connect their ownership, query, lock and tagged-probe channels to one shared coherence tile array.

**Working/data flow.** Instantiate one CPU tile per active hart with zero-based hart ID and common boot address. Route each tile's ownership request and returned grant to the corresponding coherence adapter. Fan probes and line-lock observations to the correct tile. Tie off only the inactive fixed hart slots when PARA_CPU_NUM is 2.

**State and storage ownership.** Replication/control wrapper; per-hart execution state resides in the CPU tile, transaction state in the shared fabric.

**Safety, timing and error constraints.** Inactive slots must never issue AXI or coherence requests or contribute PMU/fault events. Active-hart index must agree across IRQ, probe, AXI ID extension and diagnostic paths.

**Verification boundary.** Active 2/4-hart real programs and inactive-slot unit checks exist; external per-hart IRQ/debug behavior still needs system tests.

The figure shows actual child composition; a leaf shows its own boundary. It does not invent intermediate RTL modules. / Hình thể hiện phân cấp source; leaf chỉ có symbol ranh giới, không tạo module giả.

![m_vlsit_riscv_cpu_tile_array composition](figures/post_a06/m_vlsit_riscv_cpu_tile_array.svg)

```json
{"page_name":"BLOCK_DIAGRAM","out_name":"m_vlsit_riscv_cpu_tile_array.drawio","layout":{"gap_h":120,"gap_v":110,"margin":80,"block_h":60},"top":{"frame_label":["Component composition","(m_vlsit_riscv_cpu_tile_array)"]},"frame_row":["m_vlsit_riscv_cpu_tile_array","Replicate active CPU tiles and connect their ownership, query, lock and tagged-probe channels to one shared coherence tile array.","rtl/common/vlsit/cpu/m_vlsit_riscv_cpu_tile_array.sv"],"frame_interfaces":[],"blocks":[{"key":"B0","label":["u_vlsit_riscv_coh_tile_array","(m_vlsit_riscv_coh_tile_array)"],"width":360,"row":0,"col":0,"row_name":"u_vlsit_riscv_coh_tile_array (m_vlsit_riscv_coh_tile_array)","function":"Compose one ownership/probe adapter per active hart with the multi-context directory-based MESI fabric.","source":"NEW; rtl/common/vlsit/coherence/m_vlsit_riscv_coh_tile_array.sv"},{"key":"B1","label":["u_vlsit_riscv_cpu_tile","(m_vlsit_riscv_cpu_tile)"],"width":280,"row":1,"col":0,"row_name":"u_vlsit_riscv_cpu_tile (m_vlsit_riscv_cpu_tile)","function":"Wrap the locally adapted native CVA6 and derive its physical memory attributes from the same region table used by the AXI router.","source":"NEW; rtl/common/vlsit/cpu/m_vlsit_riscv_cpu_tile.sv"}],"connectors":[],"externals":[],"interfaces":[],"nets":[],"legend_note":"Exact source-referenced children; generate multiplicity and active branches are specified in the component text. Containment denotes hierarchy, not invented signal connectivity. NEW/MODIFY/REUSE/GENERATED provenance is listed in the block table. Clock/reset follow the common synchronous contract. Complete parent port declarations are in the component section.","library_sha256":"15DFB183E267D2A94F8CAB316E01EB3D2E9D2F9C006DC816790A394F4123506C"}
```

[Editable draw.io](figures/post_a06/m_vlsit_riscv_cpu_tile_array.drawio) · [Figure source](figures/post_a06/m_vlsit_riscv_cpu_tile_array.json).

**Interface contract.** All synchronous ports use the common cluster clock; the probe engine cache clock is the same domain in this cluster. A valid/ready payload is accepted only on the corresponding handshake and held through backpressure. Pulsed completion/ACK interfaces are described by the operation/FSM contract; they must not be treated as independent ready/valid channels.

| Direction | Exact source declaration |
|---|---|
| output | `logic [3:0] o_cmo_req_valid` |
| input | `wire [3:0] i_cmo_req_ready` |
| output | `logic [3:0][1:0] o_cmo_req_op` |
| output | `logic [3:0][51:0] o_cmo_req_pa_line` |
| output | `logic [3:0][63:0] o_cmo_req_vaddr` |
| output | `logic [3:0][63:0] o_cmo_req_pc` |
| input | `wire [3:0] i_cmo_rsp_done` |
| input | `wire [3:0] i_cmo_rsp_err` |
| input | `wire i_ccu_begin_valid` |
| output | `logic o_ccu_begin_ready` |
| input | `wire [1:0] i_ccu_begin_op` |
| input | `wire [51:0] i_ccu_begin_pa_line` |
| input | `wire [1:0] i_ccu_begin_hart` |
| input | `wire i_ccu_begin_wback_en` |
| output | `logic o_ccu_prepare_valid` |
| input | `wire i_ccu_prepare_ready` |
| output | `logic [LPARA_COH_TAG_W-1:0] o_ccu_prepare_tag` |
| output | `logic o_ccu_prepare_err` |
| input | `wire i_ccu_finish_valid` |
| output | `logic o_ccu_finish_ready` |
| input | `wire [LPARA_COH_TAG_W-1:0] i_ccu_finish_tag` |
| input | `wire i_ccu_finish_commit` |
| output | `logic o_ccu_finish_done` |
| input | `wire i_clk_cluster` |
| input | `wire i_rst_n_cluster` |
| input | `wire [63:0] i_boot_addr` |
| input | `wire [3:0] i_int_msip` |
| input | `wire [3:0] i_int_mtip` |
| input | `wire [3:0] i_int_meip` |
| input | `wire [3:0] i_int_ssip` |
| input | `wire [3:0] i_int_stip` |
| input | `wire [3:0] i_int_seip` |
| input | `wire [3:0] i_hart_debug_req` |
| output | `logic [3:0] o_hart_debug_mode` |
| output | `logic [3:0] o_coh_access_locked` |
| output | `logic [3:0] o_coh_victim_locked` |
| output | `logic [3:0][3:0] o_axi_awid` |
| output | `logic [3:0][5:0] o_axi_awatop` |
| output | `logic [3:0][63:0] o_axi_awaddr` |
| output | `logic [3:0][7:0] o_axi_awlen` |
| output | `logic [3:0][2:0] o_axi_awsize` |
| output | `logic [3:0][1:0] o_axi_awburst` |
| output | `logic [3:0] o_axi_awlock` |
| output | `logic [3:0][3:0] o_axi_awcache` |
| output | `logic [3:0][2:0] o_axi_awprot` |
| output | `logic [3:0][3:0] o_axi_awqos` |
| output | `logic [3:0][3:0] o_axi_awregion` |
| output | `logic [3:0] o_axi_awvalid` |
| input | `wire [3:0] i_axi_awready` |
| output | `logic [3:0][63:0] o_axi_wdata` |
| output | `logic [3:0][7:0] o_axi_wstrb` |
| output | `logic [3:0] o_axi_wlast` |
| output | `logic [3:0] o_axi_wvalid` |
| input | `wire [3:0] i_axi_wready` |
| input | `wire [3:0][3:0] i_axi_bid` |
| input | `wire [3:0][1:0] i_axi_bresp` |
| input | `wire [3:0] i_axi_bvalid` |
| output | `logic [3:0] o_axi_bready` |
| output | `logic [3:0][3:0] o_axi_arid` |
| output | `logic [3:0][63:0] o_axi_araddr` |
| output | `logic [3:0][7:0] o_axi_arlen` |
| output | `logic [3:0][2:0] o_axi_arsize` |
| output | `logic [3:0][1:0] o_axi_arburst` |
| output | `logic [3:0] o_axi_arlock` |
| output | `logic [3:0][3:0] o_axi_arcache` |
| output | `logic [3:0][2:0] o_axi_arprot` |
| output | `logic [3:0][3:0] o_axi_arqos` |
| output | `logic [3:0][3:0] o_axi_arregion` |
| output | `logic [3:0] o_axi_arvalid` |
| input | `wire [3:0] i_axi_arready` |
| input | `wire [3:0][3:0] i_axi_rid` |
| input | `wire [3:0][63:0] i_axi_rdata` |
| input | `wire [3:0][1:0] i_axi_rresp` |
| input | `wire [3:0] i_axi_rlast` |
| input | `wire [3:0] i_axi_rvalid` |
| output | `logic [3:0] o_axi_rready` |
| output | `logic [3:0] o_axi_aw_region_match` |
| output | `logic [3:0][3:0] o_axi_aw_region_idx` |
| output | `logic [3:0][1:0] o_axi_aw_region_type` |
| output | `logic [3:0] o_axi_aw_region_err` |
| output | `logic [3:0] o_axi_ar_region_match` |
| output | `logic [3:0][3:0] o_axi_ar_region_idx` |
| output | `logic [3:0][1:0] o_axi_ar_region_type` |
| output | `logic [3:0] o_axi_ar_region_err` |
| output | `logic [3:0] o_tile_region_cfg_valid` |
| output | `logic o_region_cfg_valid` |
| output | `logic [3:0][21:0] o_perf_event` |
| output | `logic [3:0][15:0] o_hpdcache_perf_event` |
| output | `logic [3:0] o_cmo_entry_valid` |
| output | `logic [3:0][7:0] o_cmo_entry_op` |
| output | `logic [3:0][51:0] o_cmo_entry_pa_line` |
| output | `logic [3:0][63:0] o_cmo_entry_vaddr` |
| output | `logic [3:0] o_dcache_flush_ack_valid` |
| output | `logic [3:0][51:0] o_dcache_flush_ack_nline` |
| output | `logic [3:0][1:0] o_dcache_flush_ack_origin` |
| output | `logic [3:0] o_dcache_flush_ack_err` |
| output | `logic [3:0] o_dcache_flush_rsp_invalid` |
| output | `logic [3:0] o_coh_lock_diag_event` |
| output | `logic o_coh_proto_diag_event` |
| output | `logic [2:0] o_dir_lookup_count` |
| output | `logic [2:0] o_dir_update_count` |
| output | `logic [11:0][2:0] o_ccu_evt_count` |

**FSM:** No new enum controller is declared by this module. Its combinational mapping, queue/valid-bit lifecycle, or instantiated child FSMs implement the behavior above. This is not a claim that the entire subtree is stateless.

#### 14.4.30 `m_vlsit_riscv_fault_record` — NEW

Source: [rtl/common/vlsit/diagnostics/m_vlsit_riscv_fault_record.sv](../../rtl/vlsit/m_vlsit_riscv_fault_record.sv). Selected production source: **True**.

**Function.** Capture the first fatal ordinary L1 or shared LLC writeback error until reset.

**Working/data flow.** Select the lowest active L1 hart if several L1 events coincide; otherwise select LLC. Atomically capture source, victim address and raw B response with validity flags. Later independent fatal events only set multiple. A simultaneous second event also sets multiple on first capture.

**State and storage ownership.** First-fault status/info/address and reset-only valid/multiple state.

**Safety, timing and error constraints.** L1 has exact hart attribution. Shared LLC uses hart_valid=0; zero hart bits do not name hart 0. W1C diagnostic writes cannot clear this record. Precise CBO/FENCE/atomic errors are not ordinary fatal eviction records.

**Verification boundary.** A-06 ten real CPU cases plus priority/high-address/inactive-hart/reset units and overwrite mutation detection pass.

The figure shows actual child composition; a leaf shows its own boundary. It does not invent intermediate RTL modules. / Hình thể hiện phân cấp source; leaf chỉ có symbol ranh giới, không tạo module giả.

![m_vlsit_riscv_fault_record composition](figures/post_a06/m_vlsit_riscv_fault_record.svg)

```json
{"page_name":"BLOCK_DIAGRAM","out_name":"m_vlsit_riscv_fault_record.drawio","layout":{"gap_h":120,"gap_v":110,"margin":80,"block_h":60},"top":{"frame_label":["Component composition","(m_vlsit_riscv_fault_record)"]},"frame_row":["m_vlsit_riscv_fault_record","Capture the first fatal ordinary L1 or shared LLC writeback error until reset.","rtl/common/vlsit/diagnostics/m_vlsit_riscv_fault_record.sv"],"frame_interfaces":["IN","OUT"],"blocks":[{"key":"B0","label":["component_boundary","(m_vlsit_riscv_fault_record)"],"width":340,"row":0,"col":0,"row_name":"component_boundary (m_vlsit_riscv_fault_record)","function":"Capture the first fatal ordinary L1 or shared LLC writeback error until reset.","source":"NEW; rtl/common/vlsit/diagnostics/m_vlsit_riscv_fault_record.sv"}],"connectors":[],"externals":[{"id":"IN","block":"B0","side":"L","dir":"in","pos":0,"text":["IN","ports"]},{"id":"OUT","block":"B0","side":"R","dir":"out","pos":0,"text":["OUT","ports"]}],"interfaces":[{"id":"IN","name":"Parent in ports","category":"custom","active":"in","signals":"i_clk_cluster, i_rst_n_cluster, i_l1_fault_valid, i_l1_fault_addr, i_l1_fault_resp, i_llc_fault_valid, i_llc_fault_addr, i_llc_fault_resp"},{"id":"OUT","name":"Parent out ports","category":"custom","active":"out","signals":"o_fault_sts, o_fault_info, o_fault_addr_lo, o_fault_addr_hi"}],"nets":[],"legend_note":"A single boundary symbol denotes a leaf: internal equations/registers are described in its function/dataflow contract, not invented child modules. NEW/MODIFY/REUSE/GENERATED provenance is listed in the block table. Clock/reset follow the common synchronous contract. Complete parent port declarations are in the component section.","library_sha256":"15DFB183E267D2A94F8CAB316E01EB3D2E9D2F9C006DC816790A394F4123506C"}
```

[Editable draw.io](figures/post_a06/m_vlsit_riscv_fault_record.drawio) · [Figure source](figures/post_a06/m_vlsit_riscv_fault_record.json).

**Interface contract.** All synchronous ports use the common cluster clock; the probe engine cache clock is the same domain in this cluster. A valid/ready payload is accepted only on the corresponding handshake and held through backpressure. Pulsed completion/ACK interfaces are described by the operation/FSM contract; they must not be treated as independent ready/valid channels.

| Direction | Exact source declaration |
|---|---|
| input | `wire i_clk_cluster` |
| input | `wire i_rst_n_cluster` |
| input | `wire [3:0] i_l1_fault_valid` |
| input | `wire [3:0][55:0] i_l1_fault_addr` |
| input | `wire [3:0][1:0] i_l1_fault_resp` |
| input | `wire i_llc_fault_valid` |
| input | `wire [55:0] i_llc_fault_addr` |
| input | `wire [1:0] i_llc_fault_resp` |
| output | `logic [31:0] o_fault_sts` |
| output | `logic [31:0] o_fault_info` |
| output | `logic [31:0] o_fault_addr_lo` |
| output | `logic [31:0] o_fault_addr_hi` |

**FSM:** No new enum controller is declared by this module. Its combinational mapping, queue/valid-bit lifecycle, or instantiated child FSMs implement the behavior above. This is not a claim that the entire subtree is stateless.

#### 14.4.31 `m_vlsit_riscv_hpd_probe_engine` — NEW

Source: [rtl/common/vlsit/coherence/m_vlsit_riscv_hpd_probe_engine.sv](../../rtl/vlsit/m_vlsit_riscv_hpd_probe_engine.sv). Selected production source: **True**.

**Function.** Execute tagged PREPARE and matching COMMIT/ABORT against native HPDcache metadata and writeback services.

**Working/data flow.** PREPARE requests a metadata lookup. An actual dirty M hit with writeback enabled initiates a native flush and waits for its accepted B result. Return the prepared state/error and retain the line. Matching COMMIT updates a real hit to the target MESI state; validated absence remains I without allocating a line. Matching ABORT returns without changing the prepared state. Invalid terminal requests report an error while preserving the valid prepared context.

**State and storage ownership.** Probe tag/line/target, observed state/way/hit/error/writeback status and retained response; eleven-state explicit FSM.

**Safety, timing and error constraints.** Payload stays stable while response ready is low. A successful AW or W transfer is not writeback completion. Unknown/mismatched requests must not destroy a legitimate prepared transaction.

**Verification boundary.** Native probe-engine units plus dirty-owner, absence, ABORT and maintenance CPU paths pass.

The figure shows actual child composition; a leaf shows its own boundary. It does not invent intermediate RTL modules. / Hình thể hiện phân cấp source; leaf chỉ có symbol ranh giới, không tạo module giả.

![m_vlsit_riscv_hpd_probe_engine composition](figures/post_a06/m_vlsit_riscv_hpd_probe_engine.svg)

```json
{"page_name":"BLOCK_DIAGRAM","out_name":"m_vlsit_riscv_hpd_probe_engine.drawio","layout":{"gap_h":120,"gap_v":110,"margin":80,"block_h":60},"top":{"frame_label":["Component composition","(m_vlsit_riscv_hpd_probe_engine)"]},"frame_row":["m_vlsit_riscv_hpd_probe_engine","Execute tagged PREPARE and matching COMMIT/ABORT against native HPDcache metadata and writeback services.","rtl/common/vlsit/coherence/m_vlsit_riscv_hpd_probe_engine.sv"],"frame_interfaces":["IN","OUT"],"blocks":[{"key":"B0","label":["component_boundary","(m_vlsit_riscv_hpd_probe_engine)"],"width":380,"row":0,"col":0,"row_name":"component_boundary (m_vlsit_riscv_hpd_probe_engine)","function":"Execute tagged PREPARE and matching COMMIT/ABORT against native HPDcache metadata and writeback services.","source":"NEW; rtl/common/vlsit/coherence/m_vlsit_riscv_hpd_probe_engine.sv"}],"connectors":[],"externals":[{"id":"IN","block":"B0","side":"L","dir":"in","pos":0,"text":["IN","ports"]},{"id":"OUT","block":"B0","side":"R","dir":"out","pos":0,"text":["OUT","ports"]}],"interfaces":[{"id":"IN","name":"Parent in ports","category":"custom","active":"in","signals":"i_clk_cache, i_rst_n_cache, i_probe_req_valid, i_probe_req_tag, i_probe_req_nline, i_probe_req_phase, i_probe_req_target_state, i_probe_req_wback_en, i_probe_rsp_ready, i_lookup_ready, i_lookup_rsp_valid, i_lookup_rsp_tag, i_lookup_rsp_nline, i_lookup_rsp_way, i_lookup_rsp_hit, i_lookup_rsp_state, i_lookup_rsp_err, i_flush_ready, i_flush_ack_valid, i_flush_ack_nline, i_flush_ack_err, i_state_update_ready"},{"id":"OUT","name":"Parent out ports","category":"custom","active":"out","signals":"o_probe_req_ready, o_probe_rsp_valid, o_probe_rsp_tag, o_probe_rsp_nline, o_probe_rsp_phase, o_probe_rsp_state, o_probe_rsp_err, o_probe_rsp_wback_done, o_lookup_valid, o_lookup_tag, o_lookup_nline, o_lookup_rsp_ready, o_flush_valid, o_flush_nline, o_flush_way, o_state_update_valid, o_state_update_nline, o_state_update_way, o_state_update_state"}],"nets":[],"legend_note":"A single boundary symbol denotes a leaf: internal equations/registers are described in its function/dataflow contract, not invented child modules. NEW/MODIFY/REUSE/GENERATED provenance is listed in the block table. Clock/reset follow the common synchronous contract. Complete parent port declarations are in the component section.","library_sha256":"15DFB183E267D2A94F8CAB316E01EB3D2E9D2F9C006DC816790A394F4123506C"}
```

[Editable draw.io](figures/post_a06/m_vlsit_riscv_hpd_probe_engine.drawio) · [Figure source](figures/post_a06/m_vlsit_riscv_hpd_probe_engine.json).

**Interface contract.** All synchronous ports use the common cluster clock; the probe engine cache clock is the same domain in this cluster. A valid/ready payload is accepted only on the corresponding handshake and held through backpressure. Pulsed completion/ACK interfaces are described by the operation/FSM contract; they must not be treated as independent ready/valid channels.

| Direction | Exact source declaration |
|---|---|
| input | `wire i_clk_cache` |
| input | `wire i_rst_n_cache` |
| input | `wire i_probe_req_valid` |
| output | `logic o_probe_req_ready` |
| input | `wire [3:0] i_probe_req_tag` |
| input | `wire [51:0] i_probe_req_nline` |
| input | `wire [1:0] i_probe_req_phase` |
| input | `wire [1:0] i_probe_req_target_state` |
| input | `wire i_probe_req_wback_en` |
| output | `logic o_probe_rsp_valid` |
| input | `wire i_probe_rsp_ready` |
| output | `logic [3:0] o_probe_rsp_tag` |
| output | `logic [51:0] o_probe_rsp_nline` |
| output | `logic [1:0] o_probe_rsp_phase` |
| output | `logic [1:0] o_probe_rsp_state` |
| output | `logic o_probe_rsp_err` |
| output | `logic o_probe_rsp_wback_done` |
| output | `logic o_lookup_valid` |
| input | `wire i_lookup_ready` |
| output | `logic [3:0] o_lookup_tag` |
| output | `logic [51:0] o_lookup_nline` |
| input | `wire i_lookup_rsp_valid` |
| output | `logic o_lookup_rsp_ready` |
| input | `wire [3:0] i_lookup_rsp_tag` |
| input | `wire [51:0] i_lookup_rsp_nline` |
| input | `wire [PARA_WAY_NUM-1:0] i_lookup_rsp_way` |
| input | `wire i_lookup_rsp_hit` |
| input | `wire [1:0] i_lookup_rsp_state` |
| input | `wire i_lookup_rsp_err` |
| output | `logic o_flush_valid` |
| input | `wire i_flush_ready` |
| output | `logic [51:0] o_flush_nline` |
| output | `logic [PARA_WAY_NUM-1:0] o_flush_way` |
| input | `wire i_flush_ack_valid` |
| input | `wire [51:0] i_flush_ack_nline` |
| input | `wire i_flush_ack_err` |
| output | `logic o_state_update_valid` |
| input | `wire i_state_update_ready` |
| output | `logic [51:0] o_state_update_nline` |
| output | `logic [PARA_WAY_NUM-1:0] o_state_update_way` |
| output | `logic [1:0] o_state_update_state` |

**FSM:** [HPD_PROBE](#hpd-probe). See Section 10.1 for every transition and retained obligation.

#### 14.4.32 `m_vlsit_riscv_pmu` — NEW

Source: [rtl/common/vlsit/pmu/m_vlsit_riscv_pmu.sv](../../rtl/vlsit/m_vlsit_riscv_pmu.sv). Selected production source: **True**.

**Function.** Integrate source event packing, scope selection, counters, atomic snapshots and aggregate overflow interrupt.

**Working/data flow.** Pack CVA6/HPDcache events per hart, sum active-hart indications for aggregate scope, combine LLC indicators and CCU occurrence counts, select a source/scope for each enabled counter, accumulate modulo width, snapshot all counters together and feed overflow causes to generated CSR.

**State and storage ownership.** Counter/snapshot storage lives in children; selectors and enable/raw IRQ fields live in generated CSR.

**Safety, timing and error constraints.** Default 16 counters, configurable 1 through 32; width 32 or 64. Scope 0 through 3 is per-hart, 4 aggregates active harts, 5 selects cluster events; unsupported combinations count zero. Validate source-event meaning before using results as IPC evidence.

**Verification boundary.** Connected and linted; a full active PMU-to-software functional campaign is missing.

The figure shows actual child composition; a leaf shows its own boundary. It does not invent intermediate RTL modules. / Hình thể hiện phân cấp source; leaf chỉ có symbol ranh giới, không tạo module giả.

![m_vlsit_riscv_pmu composition](figures/post_a06/m_vlsit_riscv_pmu.svg)

```json
{"page_name":"BLOCK_DIAGRAM","out_name":"m_vlsit_riscv_pmu.drawio","layout":{"gap_h":120,"gap_v":110,"margin":80,"block_h":60},"top":{"frame_label":["Component composition","(m_vlsit_riscv_pmu)"]},"frame_row":["m_vlsit_riscv_pmu","Integrate source event packing, scope selection, counters, atomic snapshots and aggregate overflow interrupt.","rtl/common/vlsit/pmu/m_vlsit_riscv_pmu.sv"],"frame_interfaces":[],"blocks":[{"key":"B0","label":["u_vlsit_pmu_aggregate","(m_vlsit_pmu_aggregate)"],"width":280,"row":0,"col":0,"row_name":"u_vlsit_pmu_aggregate (m_vlsit_pmu_aggregate)","function":"Sum the same event indicator across active harts without discarding simultaneous occurrences.","source":"NEW; rtl/common/vlsit/pmu/m_vlsit_pmu_aggregate.sv"},{"key":"B1","label":["u_vlsit_pmu_cluster_evt","(m_vlsit_pmu_cluster_evt)"],"width":300,"row":0,"col":1,"row_name":"u_vlsit_pmu_cluster_evt (m_vlsit_pmu_cluster_evt)","function":"Pack LLC single-bit indicators and CCU three-bit same-cycle occurrence counts into cluster event slots.","source":"NEW; rtl/common/vlsit/pmu/m_vlsit_pmu_cluster_evt.sv"},{"key":"B2","label":["u_vlsit_pmu_cnt_bank","(m_vlsit_pmu_counter_bank)"],"width":300,"row":1,"col":0,"row_name":"u_vlsit_pmu_cnt_bank (m_vlsit_pmu_counter_bank)","function":"Accumulate enabled event occurrence counts modulo the configured counter width and emit carry/overflow events.","source":"NEW; rtl/common/vlsit/pmu/m_vlsit_pmu_counter_bank.sv"},{"key":"B3","label":["u_vlsit_pmu_evt_sel","(m_vlsit_pmu_event_select)"],"width":300,"row":1,"col":1,"row_name":"u_vlsit_pmu_evt_sel (m_vlsit_pmu_event_select)","function":"Decode each software event ID and scope into an occurrence count for one counter.","source":"NEW; rtl/common/vlsit/pmu/m_vlsit_pmu_event_select.sv"},{"key":"B4","label":["u_vlsit_pmu_hart_evt","(m_vlsit_pmu_hart_evt)"],"width":260,"row":2,"col":0,"row_name":"u_vlsit_pmu_hart_evt (m_vlsit_pmu_hart_evt)","function":"Pack CVA6 and HPDcache source indicators into a stable per-hart catalog order.","source":"NEW; rtl/common/vlsit/pmu/m_vlsit_pmu_hart_evt.sv"},{"key":"B5","label":["u_vlsit_pmu_irq","(m_vlsit_pmu_irq)"],"width":200,"row":2,"col":1,"row_name":"u_vlsit_pmu_irq (m_vlsit_pmu_irq)","function":"Merge newly overflowing counters into retained raw causes and drive one aggregate level interrupt.","source":"NEW; rtl/common/vlsit/pmu/m_vlsit_pmu_irq.sv"},{"key":"B6","label":["u_vlsit_pmu_snapshot","(m_vlsit_pmu_snapshot)"],"width":260,"row":3,"col":0,"row_name":"u_vlsit_pmu_snapshot (m_vlsit_pmu_snapshot)","function":"Capture every live counter atomically and expose stable software low/high read words.","source":"NEW; rtl/common/vlsit/pmu/m_vlsit_pmu_snapshot.sv"}],"connectors":[],"externals":[],"interfaces":[],"nets":[],"legend_note":"Exact source-referenced children; generate multiplicity and active branches are specified in the component text. Containment denotes hierarchy, not invented signal connectivity. NEW/MODIFY/REUSE/GENERATED provenance is listed in the block table. Clock/reset follow the common synchronous contract. Complete parent port declarations are in the component section.","library_sha256":"15DFB183E267D2A94F8CAB316E01EB3D2E9D2F9C006DC816790A394F4123506C"}
```

[Editable draw.io](figures/post_a06/m_vlsit_riscv_pmu.drawio) · [Figure source](figures/post_a06/m_vlsit_riscv_pmu.json).

**Interface contract.** All synchronous ports use the common cluster clock; the probe engine cache clock is the same domain in this cluster. A valid/ready payload is accepted only on the corresponding handshake and held through backpressure. Pulsed completion/ACK interfaces are described by the operation/FSM contract; they must not be treated as independent ready/valid channels.

| Direction | Exact source declaration |
|---|---|
| input | `wire i_clk_cluster` |
| input | `wire i_rst_n_cluster` |
| input | `wire [PARA_CPU_NUM-1:0] i_hart_active` |
| input | `wire [PARA_CPU_NUM-1:0][LPARA_CVA6_EVT_NUM-1:0] i_cva6_evt` |
| input | `wire [PARA_CPU_NUM-1:0][LPARA_HPD_EVT_NUM-1:0] i_hpdcache_evt` |
| input | `wire [LPARA_LLC_EVT_NUM-1:0] i_llc_evt` |
| input | `wire [LPARA_CCU_EVT_NUM-1:0][2:0] i_ccu_evt_count` |
| input | `wire [PARA_PMU_CNT_NUM-1:0][15:0] i_pmu_evt_event_id` |
| input | `wire [PARA_PMU_CNT_NUM-1:0][2:0] i_pmu_evt_scope` |
| input | `wire [PARA_PMU_CNT_NUM-1:0] i_pmu_evt_en` |
| input | `wire i_pmu_ctrl_snapshot_req` |
| input | `wire [31:0] i_irq_en_overflow_en` |
| input | `wire [31:0] i_irq_raw_overflow` |
| output | `logic [PARA_PMU_CNT_NUM-1:0][31:0] o_pmu_count_lo_value` |
| output | `logic [PARA_PMU_CNT_NUM-1:0][31:0] o_pmu_count_hi_value` |
| output | `logic o_pmu_ctrl_snapshot_req_clear` |
| output | `logic o_pmu_ctrl_snapshot_done_wdata` |
| output | `logic o_pmu_ctrl_snapshot_done_we` |
| output | `logic [31:0] o_irq_raw_overflow_wdata` |
| output | `logic o_irq_raw_overflow_we` |
| output | `logic [31:0] o_irq_sts_overflow_pending` |
| output | `logic o_int_pmu` |

**FSM:** No new enum controller is declared by this module. Its combinational mapping, queue/valid-bit lifecycle, or instantiated child FSMs implement the behavior above. This is not a claim that the entire subtree is stateless.

#### 14.4.33 `m_vlsit_riscv_probe_scheduler` — NEW

Source: [rtl/common/vlsit/coherence/m_vlsit_riscv_probe_scheduler.sv](../../rtl/vlsit/m_vlsit_riscv_probe_scheduler.sv). Selected production source: **True**.

**Function.** Schedule one active tagged probe per cache and route matching cache responses to the correct context.

**Working/data flow.** Round-robin scan active contexts for each hart; select only expected, not-yet-ACKed targets. Retain request payload through backpressure. After PREPARE acceptance, keep phase-owner association so only the same transaction's terminal work uses that cache. Buffer the matching ACK until the transaction table accepts it; drain mismatches into a diagnostic event.

**State and storage ownership.** Per-hart request/active-probe/phase-owner/ACK-valid registers, associated tag/line/phase/state/error payload and scan pointer.

**Safety, timing and error constraints.** Target MESI comes from the matching context, never an unrelated live signal. Tag, line and phase all participate in response matching. No new PREPARE may steal a cache while an earlier transaction awaits COMMIT/ABORT.

**Verification boundary.** Tagged phase/invalid response/control tests and CPU paths pass. General hostile response ordering remains a verification task.

The figure shows actual child composition; a leaf shows its own boundary. It does not invent intermediate RTL modules. / Hình thể hiện phân cấp source; leaf chỉ có symbol ranh giới, không tạo module giả.

![m_vlsit_riscv_probe_scheduler composition](figures/post_a06/m_vlsit_riscv_probe_scheduler.svg)

```json
{"page_name":"BLOCK_DIAGRAM","out_name":"m_vlsit_riscv_probe_scheduler.drawio","layout":{"gap_h":120,"gap_v":110,"margin":80,"block_h":60},"top":{"frame_label":["Component composition","(m_vlsit_riscv_probe_scheduler)"]},"frame_row":["m_vlsit_riscv_probe_scheduler","Schedule one active tagged probe per cache and route matching cache responses to the correct context.","rtl/common/vlsit/coherence/m_vlsit_riscv_probe_scheduler.sv"],"frame_interfaces":["IN","OUT"],"blocks":[{"key":"B0","label":["component_boundary","(m_vlsit_riscv_probe_scheduler)"],"width":360,"row":0,"col":0,"row_name":"component_boundary (m_vlsit_riscv_probe_scheduler)","function":"Schedule one active tagged probe per cache and route matching cache responses to the correct context.","source":"NEW; rtl/common/vlsit/coherence/m_vlsit_riscv_probe_scheduler.sv"}],"connectors":[],"externals":[{"id":"IN","block":"B0","side":"L","dir":"in","pos":0,"text":["IN","ports"]},{"id":"OUT","block":"B0","side":"R","dir":"out","pos":0,"text":["OUT","ports"]}],"interfaces":[{"id":"IN","name":"Parent in ports","category":"custom","active":"in","signals":"i_clk_cluster, i_rst_n_cluster, i_ctx_valid, i_ctx_pa_line, i_ctx_phase, i_ctx_ack_expected, i_ctx_ack_received, i_ctx_phase_active, i_ctx_target_state, i_ctx_wback_en, i_probe_req_ready, i_probe_rsp_valid, i_probe_rsp_tag, i_probe_rsp_pa_line, i_probe_rsp_phase, i_probe_rsp_state, i_probe_rsp_err, i_probe_rsp_wback_done, i_ack_ready"},{"id":"OUT","name":"Parent out ports","category":"custom","active":"out","signals":"o_probe_req_valid, o_probe_req_tag, o_probe_req_pa_line, o_probe_req_phase, o_probe_req_target_state, o_probe_req_wback_en, o_probe_rsp_ready, o_ack_valid, o_ack_tag, o_ack_phase, o_ack_state, o_ack_err, o_ack_wback_done, o_coh_proto_diag_event"}],"nets":[],"legend_note":"A single boundary symbol denotes a leaf: internal equations/registers are described in its function/dataflow contract, not invented child modules. NEW/MODIFY/REUSE/GENERATED provenance is listed in the block table. Clock/reset follow the common synchronous contract. Complete parent port declarations are in the component section.","library_sha256":"15DFB183E267D2A94F8CAB316E01EB3D2E9D2F9C006DC816790A394F4123506C"}
```

[Editable draw.io](figures/post_a06/m_vlsit_riscv_probe_scheduler.drawio) · [Figure source](figures/post_a06/m_vlsit_riscv_probe_scheduler.json).

**Interface contract.** All synchronous ports use the common cluster clock; the probe engine cache clock is the same domain in this cluster. A valid/ready payload is accepted only on the corresponding handshake and held through backpressure. Pulsed completion/ACK interfaces are described by the operation/FSM contract; they must not be treated as independent ready/valid channels.

| Direction | Exact source declaration |
|---|---|
| input | `wire i_clk_cluster` |
| input | `wire i_rst_n_cluster` |
| input | `wire [PARA_COH_TXN_NUM-1:0] i_ctx_valid` |
| input | `wire [PARA_COH_TXN_NUM-1:0][51:0] i_ctx_pa_line` |
| input | `wire [PARA_COH_TXN_NUM-1:0][1:0] i_ctx_phase` |
| input | `wire [PARA_COH_TXN_NUM-1:0][PARA_CPU_NUM-1:0] i_ctx_ack_expected` |
| input | `wire [PARA_COH_TXN_NUM-1:0][PARA_CPU_NUM-1:0] i_ctx_ack_received` |
| input | `wire [PARA_COH_TXN_NUM-1:0] i_ctx_phase_active` |
| input | `wire [PARA_COH_TXN_NUM-1:0][1:0] i_ctx_target_state` |
| input | `wire [PARA_COH_TXN_NUM-1:0] i_ctx_wback_en` |
| output | `logic [PARA_CPU_NUM-1:0] o_probe_req_valid` |
| input | `wire [PARA_CPU_NUM-1:0] i_probe_req_ready` |
| output | `logic [PARA_CPU_NUM-1:0][LPARA_COH_TAG_W-1:0] o_probe_req_tag` |
| output | `logic [PARA_CPU_NUM-1:0][51:0] o_probe_req_pa_line` |
| output | `logic [PARA_CPU_NUM-1:0][1:0] o_probe_req_phase` |
| output | `logic [PARA_CPU_NUM-1:0][1:0] o_probe_req_target_state` |
| output | `logic [PARA_CPU_NUM-1:0] o_probe_req_wback_en` |
| input | `wire [PARA_CPU_NUM-1:0] i_probe_rsp_valid` |
| output | `logic [PARA_CPU_NUM-1:0] o_probe_rsp_ready` |
| input | `wire [PARA_CPU_NUM-1:0][LPARA_COH_TAG_W-1:0] i_probe_rsp_tag` |
| input | `wire [PARA_CPU_NUM-1:0][51:0] i_probe_rsp_pa_line` |
| input | `wire [PARA_CPU_NUM-1:0][1:0] i_probe_rsp_phase` |
| input | `wire [PARA_CPU_NUM-1:0][1:0] i_probe_rsp_state` |
| input | `wire [PARA_CPU_NUM-1:0] i_probe_rsp_err` |
| input | `wire [PARA_CPU_NUM-1:0] i_probe_rsp_wback_done` |
| output | `logic [PARA_CPU_NUM-1:0] o_ack_valid` |
| input | `wire [PARA_CPU_NUM-1:0] i_ack_ready` |
| output | `logic [PARA_CPU_NUM-1:0][LPARA_COH_TAG_W-1:0] o_ack_tag` |
| output | `logic [PARA_CPU_NUM-1:0][1:0] o_ack_phase` |
| output | `logic [PARA_CPU_NUM-1:0][1:0] o_ack_state` |
| output | `logic [PARA_CPU_NUM-1:0] o_ack_err` |
| output | `logic [PARA_CPU_NUM-1:0] o_ack_wback_done` |
| output | `logic [PARA_CPU_NUM-1:0] o_coh_proto_diag_event` |

**FSM:** No new enum controller is declared by this module. Its combinational mapping, queue/valid-bit lifecycle, or instantiated child FSMs implement the behavior above. This is not a claim that the entire subtree is stateless.

#### 14.4.34 `m_vlsit_riscv_sharer_directory` — NEW

Source: [rtl/common/vlsit/coherence/m_vlsit_riscv_sharer_directory.sv](../../rtl/vlsit/m_vlsit_riscv_sharer_directory.sv). Selected production source: **True**.

**Function.** Store a conservative set of L1 holders and MESI/owner metadata independently of shared LLC residency.

**Working/data flow.** Decode a 16-byte physical line into bank/set/tag. Lookup and reserve a candidate way, prefer an invalid way, otherwise choose tree-PLRU. Permit only the reservation owner's commit/update/cancel. Before overwriting a held victim, wait for its holders and dirty data obligations to finish.

**State and storage ownership.** Four banks, eight-way sets, tags/valid/holders/owner/state, per-set reservations and replacement metadata. Logical default directory capacity follows the approved 2/4-hart configuration.

**Safety, timing and error constraints.** Extra holder bits are conservative only when later probes reconcile them. A missing actual holder is forbidden. LLC eviction does not itself invalidate L1; directory victim eviction does require holder service.

**Verification boundary.** Lookup/update/cancel, PLRU, victim and A-04/A-05 units/CPU paths exist. ASIC SRAM binding and formal no-false-negative proof remain open.

The figure shows actual child composition; a leaf shows its own boundary. It does not invent intermediate RTL modules. / Hình thể hiện phân cấp source; leaf chỉ có symbol ranh giới, không tạo module giả.

![m_vlsit_riscv_sharer_directory composition](figures/post_a06/m_vlsit_riscv_sharer_directory.svg)

```json
{"page_name":"BLOCK_DIAGRAM","out_name":"m_vlsit_riscv_sharer_directory.drawio","layout":{"gap_h":120,"gap_v":110,"margin":80,"block_h":60},"top":{"frame_label":["Component composition","(m_vlsit_riscv_sharer_directory)"]},"frame_row":["m_vlsit_riscv_sharer_directory","Store a conservative set of L1 holders and MESI/owner metadata independently of shared LLC residency.","rtl/common/vlsit/coherence/m_vlsit_riscv_sharer_directory.sv"],"frame_interfaces":["IN","OUT"],"blocks":[{"key":"B0","label":["component_boundary","(m_vlsit_riscv_sharer_directory)"],"width":380,"row":0,"col":0,"row_name":"component_boundary (m_vlsit_riscv_sharer_directory)","function":"Store a conservative set of L1 holders and MESI/owner metadata independently of shared LLC residency.","source":"NEW; rtl/common/vlsit/coherence/m_vlsit_riscv_sharer_directory.sv"}],"connectors":[],"externals":[{"id":"IN","block":"B0","side":"L","dir":"in","pos":0,"text":["IN","ports"]},{"id":"OUT","block":"B0","side":"R","dir":"out","pos":0,"text":["OUT","ports"]}],"interfaces":[{"id":"IN","name":"Parent in ports","category":"custom","active":"in","signals":"i_clk_cluster, i_rst_n_cluster, i_lookup_valid, i_lookup_pa_line, i_lookup_tag, i_lookup_rsp_ready, i_update_valid, i_update_tag, i_update_pa_line, i_update_way, i_update_holders, i_update_owner, i_update_state, i_cancel_valid, i_cancel_tag, i_cancel_pa_line"},{"id":"OUT","name":"Parent out ports","category":"custom","active":"out","signals":"o_lookup_ready, o_lookup_rsp_valid, o_lookup_hit, o_lookup_rsp_tag, o_lookup_way, o_lookup_victim_valid, o_lookup_victim_pa_line, o_lookup_holders, o_lookup_owner, o_lookup_state, o_update_ready, o_cancel_ready, o_dir_lookup_count, o_dir_update_count, o_coh_proto_diag_event"}],"nets":[],"legend_note":"A single boundary symbol denotes a leaf: internal equations/registers are described in its function/dataflow contract, not invented child modules. NEW/MODIFY/REUSE/GENERATED provenance is listed in the block table. Clock/reset follow the common synchronous contract. Complete parent port declarations are in the component section.","library_sha256":"15DFB183E267D2A94F8CAB316E01EB3D2E9D2F9C006DC816790A394F4123506C"}
```

[Editable draw.io](figures/post_a06/m_vlsit_riscv_sharer_directory.drawio) · [Figure source](figures/post_a06/m_vlsit_riscv_sharer_directory.json).

**Interface contract.** All synchronous ports use the common cluster clock; the probe engine cache clock is the same domain in this cluster. A valid/ready payload is accepted only on the corresponding handshake and held through backpressure. Pulsed completion/ACK interfaces are described by the operation/FSM contract; they must not be treated as independent ready/valid channels.

| Direction | Exact source declaration |
|---|---|
| input | `wire i_clk_cluster` |
| input | `wire i_rst_n_cluster` |
| input | `wire [3:0] i_lookup_valid` |
| output | `logic [3:0] o_lookup_ready` |
| input | `wire [3:0][51:0] i_lookup_pa_line` |
| input | `wire [3:0][LPARA_COH_TAG_W-1:0] i_lookup_tag` |
| output | `logic [3:0] o_lookup_rsp_valid` |
| input | `wire [3:0] i_lookup_rsp_ready` |
| output | `logic [3:0] o_lookup_hit` |
| output | `logic [3:0][LPARA_COH_TAG_W-1:0] o_lookup_rsp_tag` |
| output | `logic [3:0][2:0] o_lookup_way` |
| output | `logic [3:0] o_lookup_victim_valid` |
| output | `logic [3:0][51:0] o_lookup_victim_pa_line` |
| output | `logic [3:0][PARA_CPU_NUM-1:0] o_lookup_holders` |
| output | `logic [3:0][1:0] o_lookup_owner` |
| output | `logic [3:0][1:0] o_lookup_state` |
| input | `wire [3:0] i_update_valid` |
| output | `logic [3:0] o_update_ready` |
| input | `wire [3:0][LPARA_COH_TAG_W-1:0] i_update_tag` |
| input | `wire [3:0][51:0] i_update_pa_line` |
| input | `wire [3:0][2:0] i_update_way` |
| input | `wire [3:0][PARA_CPU_NUM-1:0] i_update_holders` |
| input | `wire [3:0][1:0] i_update_owner` |
| input | `wire [3:0][1:0] i_update_state` |
| input | `wire [3:0] i_cancel_valid` |
| output | `logic [3:0] o_cancel_ready` |
| input | `wire [3:0][LPARA_COH_TAG_W-1:0] i_cancel_tag` |
| input | `wire [3:0][51:0] i_cancel_pa_line` |
| output | `logic [2:0] o_dir_lookup_count` |
| output | `logic [2:0] o_dir_update_count` |
| output | `logic [3:0] o_coh_proto_diag_event` |

**FSM:** No new enum controller is declared by this module. Its combinational mapping, queue/valid-bit lifecycle, or instantiated child FSMs implement the behavior above. This is not a claim that the entire subtree is stateless.

#### 14.4.35 `m_vlsit_riscv_tile_coh_adapter` — NEW

Source: [rtl/common/vlsit/coherence/m_vlsit_riscv_tile_coh_adapter.sv](../../rtl/vlsit/m_vlsit_riscv_tile_coh_adapter.sv). Selected production source: **True**.

**Function.** Bridge native tile ownership/probe interfaces to the cluster fabric while enforcing line-busy and lock constraints.

**Working/data flow.** Capture a native ownership request and retain its source ID through grant. Before a PREPARE, query the cache and delay same-line service while refill/AMO/eviction activity is unsafe. Acquire/release the tagged line lock with the two-phase probe lifetime and preserve retained phase identity under backpressure.

**State and storage ownership.** Request/grant and probe association state plus the child cache-line lock table.

**Safety, timing and error constraints.** A different-line CPU hit may proceed only if it does not conflict with a shared array resource. Failed terminal validation must not silently unlock the line or publish MESI changes.

**Verification boundary.** Focused adapter/lock units and native CPU scenarios exist. Array-resource contention must not be mistaken for guaranteed hit-under-probe throughput.

The figure shows actual child composition; a leaf shows its own boundary. It does not invent intermediate RTL modules. / Hình thể hiện phân cấp source; leaf chỉ có symbol ranh giới, không tạo module giả.

![m_vlsit_riscv_tile_coh_adapter composition](figures/post_a06/m_vlsit_riscv_tile_coh_adapter.svg)

```json
{"page_name":"BLOCK_DIAGRAM","out_name":"m_vlsit_riscv_tile_coh_adapter.drawio","layout":{"gap_h":120,"gap_v":110,"margin":80,"block_h":60},"top":{"frame_label":["Component composition","(m_vlsit_riscv_tile_coh_adapter)"]},"frame_row":["m_vlsit_riscv_tile_coh_adapter","Bridge native tile ownership/probe interfaces to the cluster fabric while enforcing line-busy and lock constraints.","rtl/common/vlsit/coherence/m_vlsit_riscv_tile_coh_adapter.sv"],"frame_interfaces":[],"blocks":[{"key":"B0","label":["u_vlsit_riscv_cache_line_locks","(m_vlsit_riscv_cache_line_locks)"],"width":380,"row":0,"col":0,"row_name":"u_vlsit_riscv_cache_line_locks (m_vlsit_riscv_cache_line_locks)","function":"Track line exclusion by transaction tag and answer CPU access, victim and probe lock queries.","source":"NEW; rtl/common/vlsit/coherence/m_vlsit_riscv_cache_line_locks.sv"}],"connectors":[],"externals":[],"interfaces":[],"nets":[],"legend_note":"Exact source-referenced children; generate multiplicity and active branches are specified in the component text. Containment denotes hierarchy, not invented signal connectivity. NEW/MODIFY/REUSE/GENERATED provenance is listed in the block table. Clock/reset follow the common synchronous contract. Complete parent port declarations are in the component section.","library_sha256":"15DFB183E267D2A94F8CAB316E01EB3D2E9D2F9C006DC816790A394F4123506C"}
```

[Editable draw.io](figures/post_a06/m_vlsit_riscv_tile_coh_adapter.drawio) · [Figure source](figures/post_a06/m_vlsit_riscv_tile_coh_adapter.json).

**Interface contract.** All synchronous ports use the common cluster clock; the probe engine cache clock is the same domain in this cluster. A valid/ready payload is accepted only on the corresponding handshake and held through backpressure. Pulsed completion/ACK interfaces are described by the operation/FSM contract; they must not be treated as independent ready/valid channels.

| Direction | Exact source declaration |
|---|---|
| input | `wire i_clk_cluster` |
| input | `wire i_rst_n_cluster` |
| input | `wire i_cache_access_valid` |
| input | `wire [51:0] i_cache_access_pa_line` |
| output | `logic o_cache_access_locked` |
| input | `wire i_cache_victim_valid` |
| input | `wire [51:0] i_cache_victim_pa_line` |
| output | `logic o_cache_victim_locked` |
| output | `logic [PARA_COH_TXN_NUM-1:0] o_cache_line_lock_valid` |
| output | `logic [PARA_COH_TXN_NUM-1:0][51:0] o_cache_line_lock_pa_line` |
| output | `logic o_lock_diag_event` |
| output | `logic o_cache_probe_query_valid` |
| output | `logic [51:0] o_cache_probe_query_nline` |
| input | `wire i_cache_probe_line_busy` |
| input | `wire i_cache_req_valid` |
| output | `logic o_cache_req_ready` |
| input | `wire [2:0] i_cache_req_id` |
| input | `wire [51:0] i_cache_req_pa_line` |
| input | `wire [1:0] i_cache_req_kind` |
| output | `logic o_req_valid` |
| input | `wire i_req_ready` |
| output | `logic [2:0] o_req_id` |
| output | `logic [51:0] o_req_pa_line` |
| output | `logic [1:0] o_req_kind` |
| input | `wire i_gnt_valid` |
| output | `logic o_gnt_ready` |
| input | `wire [2:0] i_gnt_id` |
| input | `wire [51:0] i_gnt_pa_line` |
| input | `wire [1:0] i_gnt_state` |
| input | `wire i_gnt_err` |
| output | `logic o_cache_gnt_valid` |
| input | `wire i_cache_gnt_ready` |
| output | `logic [2:0] o_cache_gnt_id` |
| output | `logic [51:0] o_cache_gnt_pa_line` |
| output | `logic [1:0] o_cache_gnt_state` |
| output | `logic o_cache_gnt_err` |
| input | `wire i_probe_req_valid` |
| output | `logic o_probe_req_ready` |
| input | `wire [LPARA_COH_TAG_W-1:0] i_probe_req_tag` |
| input | `wire [51:0] i_probe_req_pa_line` |
| input | `wire [1:0] i_probe_req_phase` |
| input | `wire [1:0] i_probe_req_target_state` |
| input | `wire i_probe_req_wback_en` |
| output | `logic o_cache_probe_req_valid` |
| input | `wire i_cache_probe_req_ready` |
| output | `logic [LPARA_COH_TAG_W-1:0] o_cache_probe_req_tag` |
| output | `logic [51:0] o_cache_probe_req_pa_line` |
| output | `logic [1:0] o_cache_probe_req_phase` |
| output | `logic [1:0] o_cache_probe_req_target_state` |
| output | `logic o_cache_probe_req_wback_en` |
| input | `wire i_cache_probe_rsp_valid` |
| output | `logic o_cache_probe_rsp_ready` |
| input | `wire [LPARA_COH_TAG_W-1:0] i_cache_probe_rsp_tag` |
| input | `wire [51:0] i_cache_probe_rsp_pa_line` |
| input | `wire [1:0] i_cache_probe_rsp_phase` |
| input | `wire [1:0] i_cache_probe_rsp_state` |
| input | `wire i_cache_probe_rsp_err` |
| input | `wire i_cache_probe_rsp_wback_done` |
| output | `logic o_probe_rsp_valid` |
| input | `wire i_probe_rsp_ready` |
| output | `logic [LPARA_COH_TAG_W-1:0] o_probe_rsp_tag` |
| output | `logic [51:0] o_probe_rsp_pa_line` |
| output | `logic [1:0] o_probe_rsp_phase` |
| output | `logic [1:0] o_probe_rsp_state` |
| output | `logic o_probe_rsp_err` |
| output | `logic o_probe_rsp_wback_done` |

**FSM:** No new enum controller is declared by this module. Its combinational mapping, queue/valid-bit lifecycle, or instantiated child FSMs implement the behavior above. This is not a claim that the entire subtree is stateless.

### 14.5 Modified native source contracts / Hợp đồng source native đã sửa

Every selected modified source is listed below. Native ports/types/state names retain upstream naming and licenses; VLSIT wrappers adapt boundaries. A package is a type/constant dependency, not an instantiable RTL component. Header history is implementation provenance and can contain superseded staging comments; current behavior follows this specification and the actual source. / Liệt kê mọi source MODIFY được chọn; package không phải module. Không restyle RTL reuse theo rule VLSIT.

#### 14.5.1 `id_queue.sv` — MODIFY

Source: [rtl/common/modified/axi_llc/common_cells/src/id_queue.sv](../../rtl/modified/axi_llc/common_cells/src/id_queue.sv).

**Function and local effect.** Native id queue component. Preserve the native request/result or storage behavior while applying the explicit local changes recorded below. Its parent consumes the exact typed interfaces in this section; queue, arithmetic, memory and protocol helpers do not create new architectural ownership rules. Native latency/ordering remains source-defined and is not independently qualified by TOP lint.

![id_queue selected modified component](figures/post_a06/id_queue.svg)

```json
{"page_name":"BLOCK_DIAGRAM","out_name":"id_queue.drawio","layout":{"gap_h":120,"gap_v":110,"margin":80,"block_h":60},"top":{"frame_label":["Component composition","(id_queue)"]},"frame_row":["id_queue","Native modified component; function and change contract are specified in Section 14.","rtl/common/modified/axi_llc/common_cells/src/id_queue.sv"],"frame_interfaces":[],"blocks":[{"key":"B0","label":["i_ht_free_lzc","(lzc)"],"width":160,"row":0,"col":0,"row_name":"i_ht_free_lzc (lzc)","function":"Native component","source":"REUSE; rtl/common/third_party/cva6/vendor/pulp-platform/common_cells/src/lzc.sv"},{"key":"B1","label":["i_ld_free_lzc","(lzc)"],"width":160,"row":0,"col":1,"row_name":"i_ld_free_lzc (lzc)","function":"Native component","source":"REUSE; rtl/common/third_party/cva6/vendor/pulp-platform/common_cells/src/lzc.sv"},{"key":"B2","label":["i_id_ohb_in","(onehot_to_bin)"],"width":180,"row":1,"col":0,"row_name":"i_id_ohb_in (onehot_to_bin)","function":"Native component","source":"REUSE; rtl/common/third_party/axi_llc_locked/common_cells/src/onehot_to_bin.sv"},{"key":"B3","label":["i_id_ohb_out","(onehot_to_bin)"],"width":180,"row":1,"col":1,"row_name":"i_id_ohb_out (onehot_to_bin)","function":"Native component","source":"REUSE; rtl/common/third_party/axi_llc_locked/common_cells/src/onehot_to_bin.sv"}],"connectors":[],"externals":[],"interfaces":[],"nets":[],"legend_note":"Exact source-referenced children; generate multiplicity and active branches are specified in the component text. Containment denotes hierarchy, not invented signal connectivity. NEW/MODIFY/REUSE/GENERATED provenance is listed in the block table. Clock/reset follow the common synchronous contract. Complete parent port declarations are in the component section.","library_sha256":"15DFB183E267D2A94F8CAB316E01EB3D2E9D2F9C006DC816790A394F4123506C"}
```

[Editable draw.io](figures/post_a06/id_queue.drawio) · [Figure source](figures/post_a06/id_queue.json).

**Interface and flow.** Keep native typed request/response records and source ordering. The parent wrapper owns translation to VLSIT flat ports. Exact port declarations:

| Direction | Exact source declaration |
|---|---|
| input | `logic clk_i` |
| input | `logic rst_ni` |
| input | `id_t inp_id_i` |
| input | `data_t inp_data_i` |
| input | `logic inp_req_i` |
| output | `logic inp_gnt_o` |
| input | `data_t [NUM_CMP_PORTS-1:0] exists_data_i` |
| input | `data_t [NUM_CMP_PORTS-1:0] exists_mask_i` |
| input | `logic [NUM_CMP_PORTS-1:0] exists_req_i` |
| output | `logic [NUM_CMP_PORTS-1:0] exists_o` |
| output | `logic [NUM_CMP_PORTS-1:0] exists_gnt_o` |
| input | `id_t oup_id_i` |
| input | `logic oup_pop_i` |
| input | `logic oup_req_i` |
| output | `data_t oup_data_o` |
| output | `logic oup_data_valid_o` |
| output | `logic oup_gnt_o` |
| output | `logic full_o` |
| output | `logic empty_o` |

**Recorded local changes (source history, not a substitute for the current contract):**
- Declare the existing internal empty net explicitly; no functional change.

**State/verification.** Native state encodings and helper logic remain source-owned. Coherence/maintenance-relevant state machines are discussed in Section 10; native arithmetic/MMU/helper integration is linted, with only the specific activated CPU/FPU cases described in Section 15. No blanket ISA/FP/MMU or helper-equivalence qualification is claimed.

#### 14.5.2 `axi_llc_burst_cutter.sv` — MODIFY

Source: [rtl/common/modified/axi_llc/src/axi_llc_burst_cutter.sv](../../rtl/modified/axi_llc/src/axi_llc_burst_cutter.sv).

**Function and local effect.** Native axi llc burst cutter component. Preserve the native request/result or storage behavior while applying the explicit local changes recorded below. Its parent consumes the exact typed interfaces in this section; queue, arithmetic, memory and protocol helpers do not create new architectural ownership rules. Native latency/ordering remains source-defined and is not independently qualified by TOP lint.

![axi_llc_burst_cutter selected modified component](figures/post_a06/axi_llc_burst_cutter.svg)

```json
{"page_name":"BLOCK_DIAGRAM","out_name":"axi_llc_burst_cutter.drawio","layout":{"gap_h":120,"gap_v":110,"margin":80,"block_h":60},"top":{"frame_label":["Component composition","(axi_llc_burst_cutter)"]},"frame_row":["axi_llc_burst_cutter","Native modified component; function and change contract are specified in Section 14.","rtl/common/modified/axi_llc/src/axi_llc_burst_cutter.sv"],"frame_interfaces":[],"blocks":[{"key":"B0","label":["i_burst_cutter_decode","(addr_decode)"],"width":260,"row":0,"col":0,"row_name":"i_burst_cutter_decode (addr_decode)","function":"Native component","source":"REUSE; rtl/common/third_party/axi_llc_locked/common_cells/src/addr_decode.sv"}],"connectors":[],"externals":[],"interfaces":[],"nets":[],"legend_note":"Exact source-referenced children; generate multiplicity and active branches are specified in the component text. Containment denotes hierarchy, not invented signal connectivity. NEW/MODIFY/REUSE/GENERATED provenance is listed in the block table. Clock/reset follow the common synchronous contract. Complete parent port declarations are in the component section.","library_sha256":"15DFB183E267D2A94F8CAB316E01EB3D2E9D2F9C006DC816790A394F4123506C"}
```

[Editable draw.io](figures/post_a06/axi_llc_burst_cutter.drawio) · [Figure source](figures/post_a06/axi_llc_burst_cutter.json).

**Interface and flow.** Keep native typed request/response records and source ordering. The parent wrapper owns translation to VLSIT flat ports. Exact port declarations:

| Direction | Exact source declaration |
|---|---|
| input | `logic clk_i` |
| input | `logic rst_ni` |
| input | `chan_t curr_chan_i` |
| output | `chan_t next_chan_o` |
| output | `desc_t desc_o` |
| input | `rule_t cached_rule_i` |
| input | `rule_t spm_rule_i` |

**Recorded local changes (source history, not a substitute for the current contract):**
- Keep address-map multiplication and burst alignment at AXI address precision.
- Extend the line address before applying the byte-offset shift.

**State/verification.** Native state encodings and helper logic remain source-owned. Coherence/maintenance-relevant state machines are discussed in Section 10; native arithmetic/MMU/helper integration is linted, with only the specific activated CPU/FPU cases described in Section 15. No blanket ISA/FP/MMU or helper-equivalence qualification is claimed.

#### 14.5.3 `axi_llc_chan_splitter.sv` — MODIFY

Source: [rtl/common/modified/axi_llc/src/axi_llc_chan_splitter.sv](../../rtl/modified/axi_llc/src/axi_llc_chan_splitter.sv).

**Function and local effect.** Native axi llc chan splitter component. Preserve the native request/result or storage behavior while applying the explicit local changes recorded below. Its parent consumes the exact typed interfaces in this section; queue, arithmetic, memory and protocol helpers do not create new architectural ownership rules. Native latency/ordering remains source-defined and is not independently qualified by TOP lint.

![axi_llc_chan_splitter selected modified component](figures/post_a06/axi_llc_chan_splitter.svg)

```json
{"page_name":"BLOCK_DIAGRAM","out_name":"axi_llc_chan_splitter.drawio","layout":{"gap_h":120,"gap_v":110,"margin":80,"block_h":60},"top":{"frame_label":["Component composition","(axi_llc_chan_splitter)"]},"frame_row":["axi_llc_chan_splitter","Native modified component; function and change contract are specified in Section 14.","rtl/common/modified/axi_llc/src/axi_llc_chan_splitter.sv"],"frame_interfaces":[],"blocks":[{"key":"B0","label":["i_burst_cutter","(axi_llc_burst_cutter)"],"width":260,"row":0,"col":0,"row_name":"i_burst_cutter (axi_llc_burst_cutter)","function":"Native component","source":"MODIFY; rtl/common/modified/axi_llc/src/axi_llc_burst_cutter.sv"}],"connectors":[],"externals":[],"interfaces":[],"nets":[],"legend_note":"Exact source-referenced children; generate multiplicity and active branches are specified in the component text. Containment denotes hierarchy, not invented signal connectivity. NEW/MODIFY/REUSE/GENERATED provenance is listed in the block table. Clock/reset follow the common synchronous contract. Complete parent port declarations are in the component section.","library_sha256":"15DFB183E267D2A94F8CAB316E01EB3D2E9D2F9C006DC816790A394F4123506C"}
```

[Editable draw.io](figures/post_a06/axi_llc_chan_splitter.drawio) · [Figure source](figures/post_a06/axi_llc_chan_splitter.json).

**Interface and flow.** Keep native typed request/response records and source ordering. The parent wrapper owns translation to VLSIT flat ports. Exact port declarations:

| Direction | Exact source declaration |
|---|---|
| input | `logic clk_i` |
| input | `logic rst_ni` |
| input | `chan_t ax_chan_slv_i` |
| input | `logic ax_chan_valid_i` |
| output | `logic ax_chan_ready_o` |
| output | `desc_t desc_o` |
| output | `logic desc_valid_o` |
| input | `logic desc_ready_i` |
| output | `logic unit_busy_o` |
| input | `rule_t cached_rule_i` |
| input | `rule_t spm_rule_i` |

**Recorded local changes (source history, not a substitute for the current contract):**
- Separate payload selection from descriptor-ready and FSM next-state logic.

**State/verification.** Native state encodings and helper logic remain source-owned. Coherence/maintenance-relevant state machines are discussed in Section 10; native arithmetic/MMU/helper integration is linted, with only the specific activated CPU/FPU cases described in Section 15. No blanket ISA/FP/MMU or helper-equivalence qualification is claimed.

#### 14.5.4 `axi_llc_config.sv` — MODIFY

Source: [rtl/common/modified/axi_llc/src/axi_llc_config.sv](../../rtl/modified/axi_llc/src/axi_llc_config.sv).

**Function and local effect.** Native BIST/whole-way flush control. Coordinate software configuration and native flush/BIST descriptors. The VLSIT service bridge blocks runtime SPM; full software-driven service verification remains open.

![axi_llc_config selected modified component](figures/post_a06/axi_llc_config.svg)

```json
{"page_name":"BLOCK_DIAGRAM","out_name":"axi_llc_config.drawio","layout":{"gap_h":120,"gap_v":110,"margin":80,"block_h":60},"top":{"frame_label":["Component composition","(axi_llc_config)"]},"frame_row":["axi_llc_config","Native modified component; function and change contract are specified in Section 14.","rtl/common/modified/axi_llc/src/axi_llc_config.sv"],"frame_interfaces":[],"blocks":[{"key":"B0","label":["i_ar_addr_decode","(addr_decode)"],"width":200,"row":0,"col":0,"row_name":"i_ar_addr_decode (addr_decode)","function":"Native component","source":"REUSE; rtl/common/third_party/axi_llc_locked/common_cells/src/addr_decode.sv"},{"key":"B1","label":["i_aw_addr_decode","(addr_decode)"],"width":200,"row":0,"col":1,"row_name":"i_aw_addr_decode (addr_decode)","function":"Native component","source":"REUSE; rtl/common/third_party/axi_llc_locked/common_cells/src/addr_decode.sv"},{"key":"B2","label":["i_flush_recv_counter","(counter)"],"width":240,"row":1,"col":0,"row_name":"i_flush_recv_counter (counter)","function":"Native component","source":"REUSE; rtl/common/third_party/cva6/vendor/pulp-platform/common_cells/src/counter.sv"},{"key":"B3","label":["i_flush_send_counter","(counter)"],"width":240,"row":1,"col":1,"row_name":"i_flush_send_counter (counter)","function":"Native component","source":"REUSE; rtl/common/third_party/cva6/vendor/pulp-platform/common_cells/src/counter.sv"},{"key":"B4","label":["i_lzc_flush","(lzc)"],"width":140,"row":2,"col":0,"row_name":"i_lzc_flush (lzc)","function":"Native component","source":"REUSE; rtl/common/third_party/cva6/vendor/pulp-platform/common_cells/src/lzc.sv"}],"connectors":[],"externals":[],"interfaces":[],"nets":[],"legend_note":"Exact source-referenced children; generate multiplicity and active branches are specified in the component text. Containment denotes hierarchy, not invented signal connectivity. NEW/MODIFY/REUSE/GENERATED provenance is listed in the block table. Clock/reset follow the common synchronous contract. Complete parent port declarations are in the component section.","library_sha256":"15DFB183E267D2A94F8CAB316E01EB3D2E9D2F9C006DC816790A394F4123506C"}
```

[Editable draw.io](figures/post_a06/axi_llc_config.drawio) · [Figure source](figures/post_a06/axi_llc_config.json).

**Interface and flow.** Keep native typed request/response records and source ordering. The parent wrapper owns translation to VLSIT flat ports. Exact port declarations:

| Direction | Exact source declaration |
|---|---|
| input | `logic clk_i` |
| input | `logic rst_ni` |
| input | `conf_regs_q_t conf_regs_i` |
| output | `conf_regs_d_t conf_regs_o` |
| output | `set_asso_t spm_lock_o` |
| output | `set_asso_t flushed_o` |
| output | `desc_t desc_o` |
| output | `logic desc_valid_o` |
| input | `logic desc_ready_i` |
| input | `addr_full_t slv_aw_addr_i` |
| input | `addr_full_t slv_ar_addr_i` |
| output | `logic mst_aw_bypass_o` |
| output | `logic mst_ar_bypass_o` |
| output | `logic llc_isolate_o` |
| input | `logic llc_isolated_i` |
| input | `logic aw_unit_busy_i` |
| input | `logic ar_unit_busy_i` |
| input | `logic flush_desc_recv_i` |
| input | `set_asso_t bist_res_i` |
| input | `logic bist_valid_i` |
| input | `rule_full_t axi_cached_rule_i` |
| input | `rule_full_t axi_spm_rule_i` |

**Recorded local changes (source history, not a substitute for the current contract):**
- Make destination-width extension and truncation explicit at RTL assignments.

**State/verification.** Native state encodings and helper logic remain source-owned. Coherence/maintenance-relevant state machines are discussed in Section 10; native arithmetic/MMU/helper integration is linted, with only the specific activated CPU/FPU cases described in Section 15. No blanket ISA/FP/MMU or helper-equivalence qualification is claimed.

#### 14.5.5 `axi_llc_evict_unit.sv` — MODIFY

Source: [rtl/common/modified/axi_llc/src/axi_llc_evict_unit.sv](../../rtl/modified/axi_llc/src/axi_llc_evict_unit.sv).

**Function and local effect.** Eviction/refill transport completion. Retain descriptor and dirty-data obligations across native AXI responses; expose fatal ordinary-writeback and maintenance-specific completion/error separately.

![axi_llc_evict_unit selected modified component](figures/post_a06/axi_llc_evict_unit.svg)

```json
{"page_name":"BLOCK_DIAGRAM","out_name":"axi_llc_evict_unit.drawio","layout":{"gap_h":120,"gap_v":110,"margin":80,"block_h":60},"top":{"frame_label":["Component composition","(axi_llc_evict_unit)"]},"frame_row":["axi_llc_evict_unit","Native modified component; function and change contract are specified in Section 14.","rtl/common/modified/axi_llc/src/axi_llc_evict_unit.sv"],"frame_interfaces":[],"blocks":[{"key":"B0","label":["i_aw_master","(axi_llc_ax_master)"],"width":220,"row":0,"col":0,"row_name":"i_aw_master (axi_llc_ax_master)","function":"Native component","source":"MODIFY; rtl/common/modified/axi_llc/src/eviction_refill/axi_llc_ax_master.sv"},{"key":"B1","label":["i_w_master","(axi_llc_w_master)"],"width":220,"row":0,"col":1,"row_name":"i_w_master (axi_llc_w_master)","function":"LLC AXI writeback master","source":"MODIFY; rtl/common/modified/axi_llc/src/eviction_refill/axi_llc_w_master.sv"},{"key":"B2","label":["i_stream_fifo_evict","(stream_fifo)"],"width":220,"row":1,"col":0,"row_name":"i_stream_fifo_evict (stream_fifo)","function":"Native component","source":"REUSE; rtl/common/third_party/axi_llc_locked/common_cells/src/stream_fifo.sv"},{"key":"B3","label":["i_stream_fifo_miss_buffer","(stream_fifo)"],"width":300,"row":1,"col":1,"row_name":"i_stream_fifo_miss_buffer (stream_fifo)","function":"Native component","source":"REUSE; rtl/common/third_party/axi_llc_locked/common_cells/src/stream_fifo.sv"}],"connectors":[],"externals":[],"interfaces":[],"nets":[],"legend_note":"Exact source-referenced children; generate multiplicity and active branches are specified in the component text. Containment denotes hierarchy, not invented signal connectivity. NEW/MODIFY/REUSE/GENERATED provenance is listed in the block table. Clock/reset follow the common synchronous contract. Complete parent port declarations are in the component section.","library_sha256":"15DFB183E267D2A94F8CAB316E01EB3D2E9D2F9C006DC816790A394F4123506C"}
```

[Editable draw.io](figures/post_a06/axi_llc_evict_unit.drawio) · [Figure source](figures/post_a06/axi_llc_evict_unit.json).

**Interface and flow.** Keep native typed request/response records and source ordering. The parent wrapper owns translation to VLSIT flat ports. Exact port declarations:

| Direction | Exact source declaration |
|---|---|
| input | `logic clk_i` |
| input | `logic rst_ni` |
| input | `logic test_i` |
| input | `desc_t desc_i` |
| input | `logic desc_valid_i` |
| output | `logic desc_ready_o` |
| output | `desc_t desc_o` |
| output | `logic desc_valid_o` |
| input | `logic desc_ready_i` |
| output | `way_inp_t way_inp_o` |
| output | `logic way_inp_valid_o` |
| input | `logic way_inp_ready_i` |
| input | `way_oup_t way_out_i` |
| input | `logic way_out_valid_i` |
| output | `logic way_out_ready_o` |
| output | `aw_chan_t aw_chan_mst_o` |
| output | `logic aw_chan_valid_o` |
| input | `logic aw_chan_ready_i` |
| output | `w_chan_t w_chan_mst_o` |
| output | `logic w_chan_valid_o` |
| input | `logic w_chan_ready_i` |
| input | `b_chan_t b_chan_mst_i` |
| input | `logic b_chan_valid_i` |
| output | `logic b_chan_ready_o` |
| output | `logic flush_desc_recv_o` |
| output | `logic wb_commit_o` |
| output | `logic wb_fault_o` |
| output | `logic wb_fault_event_o` |
| output | `logic [AxiCfg.AddrWidthFull-1:0] wb_fault_addr_o` |
| output | `logic [1:0] wb_fault_resp_o` |
| output | `logic wb_error_o` |
| output | `logic maint_wb_done_o` |
| output | `logic maint_wb_error_o` |

**Recorded local changes (source history, not a substitute for the current contract):**
- DEC-039/040: forward matched fatal writeback event/address/raw BRESP.
- Forward successful normal-eviction B completion to deferred tag update. Houses the components for the eviction operation. Is AW/W/B AXI Master and evicts lines from the different ways Descriptors enter, go to the AW master, then to W master, then leave through a FIFO

**State/verification.** Native state encodings and helper logic remain source-owned. Coherence/maintenance-relevant state machines are discussed in Section 10; native arithmetic/MMU/helper integration is linted, with only the specific activated CPU/FPU cases described in Section 15. No blanket ISA/FP/MMU or helper-equivalence qualification is claimed.

#### 14.5.6 `axi_llc_hit_miss.sv` — MODIFY

Source: [rtl/common/modified/axi_llc/src/axi_llc_hit_miss.sv](../../rtl/modified/axi_llc/src/axi_llc_hit_miss.sv).

**Function and local effect.** LLC lookup and descriptor association. Carry the right victim tag/way/set/maintenance attributes from hit/miss detection into retained eviction/refill processing.

![axi_llc_hit_miss selected modified component](figures/post_a06/axi_llc_hit_miss.svg)

```json
{"page_name":"BLOCK_DIAGRAM","out_name":"axi_llc_hit_miss.drawio","layout":{"gap_h":120,"gap_v":110,"margin":80,"block_h":60},"top":{"frame_label":["Component composition","(axi_llc_hit_miss)"]},"frame_row":["axi_llc_hit_miss","Native modified component; function and change contract are specified in Section 14.","rtl/common/modified/axi_llc/src/axi_llc_hit_miss.sv"],"frame_interfaces":[],"blocks":[{"key":"B0","label":["i_lock_box_bloom","(axi_llc_lock_box_bloom)"],"width":280,"row":0,"col":0,"row_name":"i_lock_box_bloom (axi_llc_lock_box_bloom)","function":"Native component","source":"REUSE; rtl/common/third_party/axi_llc/src/hit_miss_detect/axi_llc_lock_box_bloom.sv"},{"key":"B1","label":["i_miss_counters","(axi_llc_miss_counters)"],"width":280,"row":0,"col":1,"row_name":"i_miss_counters (axi_llc_miss_counters)","function":"Native component","source":"MODIFY; rtl/common/modified/axi_llc/src/hit_miss_detect/axi_llc_miss_counters.sv"},{"key":"B2","label":["i_tag_store","(axi_llc_tag_store)"],"width":220,"row":1,"col":0,"row_name":"i_tag_store (axi_llc_tag_store)","function":"LLC tag/dirty publication","source":"MODIFY; rtl/common/modified/axi_llc/src/hit_miss_detect/axi_llc_tag_store.sv"}],"connectors":[],"externals":[],"interfaces":[],"nets":[],"legend_note":"Exact source-referenced children; generate multiplicity and active branches are specified in the component text. Containment denotes hierarchy, not invented signal connectivity. NEW/MODIFY/REUSE/GENERATED provenance is listed in the block table. Clock/reset follow the common synchronous contract. Complete parent port declarations are in the component section.","library_sha256":"15DFB183E267D2A94F8CAB316E01EB3D2E9D2F9C006DC816790A394F4123506C"}
```

[Editable draw.io](figures/post_a06/axi_llc_hit_miss.drawio) · [Figure source](figures/post_a06/axi_llc_hit_miss.json).

**Interface and flow.** Keep native typed request/response records and source ordering. The parent wrapper owns translation to VLSIT flat ports. Exact port declarations:

| Direction | Exact source declaration |
|---|---|
| input | `logic clk_i` |
| input | `logic rst_ni` |
| input | `logic test_i` |
| input | `logic flush_commit_i` |
| input | `logic wb_commit_i` |
| input | `logic wb_error_i` |
| input | `logic refill_done_i` |
| input | `logic refill_error_i` |
| input | `way_ind_t refill_way_i` |
| input | `logic [Cfg.IndexLength-1:0] refill_index_i` |
| input | `logic maint_wb_done_i` |
| input | `logic maint_wb_error_i` |
| output | `logic maint_done_o` |
| output | `logic maint_error_o` |
| input | `desc_t desc_i` |
| input | `logic valid_i` |
| output | `logic ready_o` |
| output | `desc_t desc_o` |
| output | `logic miss_valid_o` |
| input | `logic miss_ready_i` |
| output | `logic hit_valid_o` |
| input | `logic hit_ready_i` |
| input | `way_ind_t spm_lock_i` |
| input | `way_ind_t flushed_i` |
| input | `lock_t w_unlock_i` |
| input | `logic w_unlock_req_i` |
| output | `logic w_unlock_gnt_o` |
| input | `lock_t r_unlock_i` |
| input | `logic r_unlock_req_i` |
| output | `logic r_unlock_gnt_o` |
| input | `cnt_t cnt_down_i` |
| output | `way_ind_t bist_res_o` |
| output | `logic bist_valid_o` |

**Recorded local changes (source history, not a substitute for the current contract):**
- Defer way-flush tag invalidation until successful AXI writeback completion. Preserve dirty line state on a failed writeback; reset is required for recovery.
- Defer dirty replacement-tag writes until OKAY B; retain fault/descriptor on writeback errors and export the fault through the cluster wrappers.
- DEC-038/A-02: commit refill tags only after complete successful R data; failed refills propagate error and invalidate the reserved allocation.

**State/verification.** Native state encodings and helper logic remain source-owned. Coherence/maintenance-relevant state machines are discussed in Section 10; native arithmetic/MMU/helper integration is linted, with only the specific activated CPU/FPU cases described in Section 15. No blanket ISA/FP/MMU or helper-equivalence qualification is claimed.

#### 14.5.7 `axi_llc_pkg.sv` — MODIFY

Source: [rtl/common/modified/axi_llc/src/axi_llc_pkg.sv](../../rtl/modified/axi_llc/src/axi_llc_pkg.sv).

**Function.** Type/configuration/package support; not an instantiable block, so no fictitious block/FSM diagram is supplied. Its definitions are consumed by the selected native component interfaces.

**Recorded local changes (source history, not a substitute for the current contract):**
- Add no-allocation per-line maintenance lookup operation. Contains the configuration and internal messages structs of the `axi_llc`.
- Extend AXI burst length before computing the number of transferred bytes.

**State/verification.** Native state encodings and helper logic remain source-owned. Coherence/maintenance-relevant state machines are discussed in Section 10; native arithmetic/MMU/helper integration is linted, with only the specific activated CPU/FPU cases described in Section 15. No blanket ISA/FP/MMU or helper-equivalence qualification is claimed.

#### 14.5.8 `axi_llc_read_unit.sv` — MODIFY

Source: [rtl/common/modified/axi_llc/src/axi_llc_read_unit.sv](../../rtl/modified/axi_llc/src/axi_llc_read_unit.sv).

**Function and local effect.** Native axi llc read unit component. Preserve the native request/result or storage behavior while applying the explicit local changes recorded below. Its parent consumes the exact typed interfaces in this section; queue, arithmetic, memory and protocol helpers do not create new architectural ownership rules. Native latency/ordering remains source-defined and is not independently qualified by TOP lint.

![axi_llc_read_unit selected modified component](figures/post_a06/axi_llc_read_unit.svg)

```json
{"page_name":"BLOCK_DIAGRAM","out_name":"axi_llc_read_unit.drawio","layout":{"gap_h":120,"gap_v":110,"margin":80,"block_h":60},"top":{"frame_label":["Component composition","(axi_llc_read_unit)"]},"frame_row":["axi_llc_read_unit","Native modified component; function and change contract are specified in Section 14.","rtl/common/modified/axi_llc/src/axi_llc_read_unit.sv"],"frame_interfaces":[],"blocks":[{"key":"B0","label":["i_r_fifo","(fifo_v3)"],"width":120,"row":0,"col":0,"row_name":"i_r_fifo (fifo_v3)","function":"Native component","source":"REUSE; rtl/common/third_party/cva6/vendor/pulp-platform/common_cells/src/fifo_v3.sv"},{"key":"B1","label":["i_r_meta_fifo","(fifo_v3)"],"width":160,"row":1,"col":0,"row_name":"i_r_meta_fifo (fifo_v3)","function":"Native component","source":"REUSE; rtl/common/third_party/cva6/vendor/pulp-platform/common_cells/src/fifo_v3.sv"}],"connectors":[],"externals":[],"interfaces":[],"nets":[],"legend_note":"Exact source-referenced children; generate multiplicity and active branches are specified in the component text. Containment denotes hierarchy, not invented signal connectivity. NEW/MODIFY/REUSE/GENERATED provenance is listed in the block table. Clock/reset follow the common synchronous contract. Complete parent port declarations are in the component section.","library_sha256":"15DFB183E267D2A94F8CAB316E01EB3D2E9D2F9C006DC816790A394F4123506C"}
```

[Editable draw.io](figures/post_a06/axi_llc_read_unit.drawio) · [Figure source](figures/post_a06/axi_llc_read_unit.json).

**Interface and flow.** Keep native typed request/response records and source ordering. The parent wrapper owns translation to VLSIT flat ports. Exact port declarations:

| Direction | Exact source declaration |
|---|---|
| input | `logic clk_i` |
| input | `logic rst_ni` |
| input | `logic test_i` |
| input | `desc_t desc_i` |
| input | `logic desc_valid_i` |
| output | `logic desc_ready_o` |
| output | `r_chan_t r_chan_slv_o` |
| output | `logic r_chan_valid_o` |
| input | `logic r_chan_ready_i` |
| output | `way_inp_t way_inp_o` |
| output | `logic way_inp_valid_o` |
| input | `logic way_inp_ready_i` |
| input | `way_oup_t way_out_i` |
| input | `logic way_out_valid_i` |
| output | `logic way_out_ready_o` |
| output | `lock_t r_unlock_o` |
| output | `logic r_unlock_req_o` |
| input | `logic r_unlock_gnt_i` |

**Recorded local changes (source history, not a substitute for the current contract):**
- Make destination-width extension and truncation explicit at RTL assignments.
- Size incremental burst address arithmetic to the AXI helper address type.

**State/verification.** Native state encodings and helper logic remain source-owned. Coherence/maintenance-relevant state machines are discussed in Section 10; native arithmetic/MMU/helper integration is linted, with only the specific activated CPU/FPU cases described in Section 15. No blanket ISA/FP/MMU or helper-equivalence qualification is claimed.

#### 14.5.9 `axi_llc_reg_wrap.sv` — MODIFY

Source: [rtl/common/modified/axi_llc/src/axi_llc_reg_wrap.sv](../../rtl/modified/axi_llc/src/axi_llc_reg_wrap.sv).

**Function and local effect.** Native LLC software wrapper. Connect RegBus configuration and native AXI/maintenance/status/error/fatal-record fields without changing the external cluster to APB.

![axi_llc_reg_wrap selected modified component](figures/post_a06/axi_llc_reg_wrap.svg)

```json
{"page_name":"BLOCK_DIAGRAM","out_name":"axi_llc_reg_wrap.drawio","layout":{"gap_h":120,"gap_v":110,"margin":80,"block_h":60},"top":{"frame_label":["Component composition","(axi_llc_reg_wrap)"]},"frame_row":["axi_llc_reg_wrap","Native modified component; function and change contract are specified in Section 14.","rtl/common/modified/axi_llc/src/axi_llc_reg_wrap.sv"],"frame_interfaces":[],"blocks":[{"key":"B0","label":["i_llc_config_regfile","(axi_llc_reg_top)"],"width":240,"row":0,"col":0,"row_name":"i_llc_config_regfile (axi_llc_reg_top)","function":"Native component","source":"REUSE; rtl/common/third_party/axi_llc/src/axi_llc_reg_top.sv"},{"key":"B1","label":["i_axi_llc_top_raw","(axi_llc_top)"],"width":200,"row":1,"col":0,"row_name":"i_axi_llc_top_raw (axi_llc_top)","function":"Shared LLC orchestration and maintenance ingress","source":"MODIFY; rtl/common/modified/axi_llc/src/axi_llc_top.sv"}],"connectors":[],"externals":[],"interfaces":[],"nets":[],"legend_note":"Exact source-referenced children; generate multiplicity and active branches are specified in the component text. Containment denotes hierarchy, not invented signal connectivity. NEW/MODIFY/REUSE/GENERATED provenance is listed in the block table. Clock/reset follow the common synchronous contract. Complete parent port declarations are in the component section.","library_sha256":"15DFB183E267D2A94F8CAB316E01EB3D2E9D2F9C006DC816790A394F4123506C"}
```

[Editable draw.io](figures/post_a06/axi_llc_reg_wrap.drawio) · [Figure source](figures/post_a06/axi_llc_reg_wrap.json).

**Interface and flow.** Keep native typed request/response records and source ordering. The parent wrapper owns translation to VLSIT flat ports. Exact port declarations:

| Direction | Exact source declaration |
|---|---|
| input | `logic maint_valid_i` |
| output | `logic maint_ready_o` |
| input | `logic [1:0] maint_op_i` |
| input | `logic [51:0] maint_pa_line_i` |
| output | `logic maint_done_o` |
| output | `logic maint_error_o` |
| input | `logic clk_i` |
| input | `logic rst_ni` |
| input | `logic test_i` |
| input | `slv_req_t slv_req_i` |
| output | `slv_resp_t slv_resp_o` |
| output | `mst_req_t mst_req_o` |
| input | `mst_resp_t mst_resp_i` |
| input | `reg_req_t conf_req_i` |
| output | `reg_resp_t conf_resp_o` |
| input | `axi_addr_t cached_start_addr_i` |
| input | `axi_addr_t cached_end_addr_i` |
| input | `axi_addr_t spm_start_addr_i` |
| output | `logic wb_fault_o` |
| output | `logic wb_fault_event_o` |
| output | `logic [AxiAddrWidth-1:0] wb_fault_addr_o` |
| output | `logic [1:0] wb_fault_resp_o` |
| output | `axi_llc_pkg::events_t axi_llc_events_o` |

**Recorded local changes (source history, not a substitute for the current contract):**
- DEC-039/040: forward matched fatal writeback event/address/raw BRESP.
- Export retained LLC writeback fault to the cluster status path. Wraps the top_level of the axi_llc with structs as AXI connections and a regbus-accessible register file. The standard configuration is a cache size of 512KByte with a set-associativity of 8, and line length of 8 blocks, one block equals the AXI data width of the
- Size each native configuration field explicitly at the generated RegBus boundary.

**State/verification.** Native state encodings and helper logic remain source-owned. Coherence/maintenance-relevant state machines are discussed in Section 10; native arithmetic/MMU/helper integration is linted, with only the specific activated CPU/FPU cases described in Section 15. No blanket ISA/FP/MMU or helper-equivalence qualification is claimed.

#### 14.5.10 `axi_llc_top.sv` — MODIFY

Source: [rtl/common/modified/axi_llc/src/axi_llc_top.sv](../../rtl/modified/axi_llc/src/axi_llc_top.sv).

**Function and local effect.** Shared LLC orchestration and maintenance ingress. Capture one per-line maintenance descriptor, coordinate native queue service, defer destructive tag actions until writeback success and forward matched fatal metadata.

![axi_llc_top selected modified component](figures/post_a06/axi_llc_top.svg)

```json
{"page_name":"BLOCK_DIAGRAM","out_name":"axi_llc_top.drawio","layout":{"gap_h":120,"gap_v":110,"margin":80,"block_h":60},"top":{"frame_label":["Component composition","(axi_llc_top)"]},"frame_row":["axi_llc_top","Native modified component; function and change contract are specified in Section 14.","rtl/common/modified/axi_llc/src/axi_llc_top.sv"],"frame_interfaces":[],"blocks":[{"key":"B0","label":["i_axi_bypass_demux","(axi_demux)"],"width":220,"row":0,"col":0,"row_name":"i_axi_bypass_demux (axi_demux)","function":"Native component","source":"REUSE; rtl/common/third_party/axi_llc_locked/axi/src/axi_demux.sv"},{"key":"B1","label":["i_axi_isolate_flush","(axi_isolate)"],"width":220,"row":0,"col":1,"row_name":"i_axi_isolate_flush (axi_isolate)","function":"Native component","source":"MODIFY; rtl/common/modified/axi_llc_locked/axi/src/axi_isolate.sv"},{"key":"B2","label":["i_ar_splitter","(axi_llc_chan_splitter)"],"width":280,"row":0,"col":2,"row_name":"i_ar_splitter (axi_llc_chan_splitter)","function":"Native component","source":"MODIFY; rtl/common/modified/axi_llc/src/axi_llc_chan_splitter.sv"},{"key":"B3","label":["i_aw_splitter","(axi_llc_chan_splitter)"],"width":280,"row":1,"col":0,"row_name":"i_aw_splitter (axi_llc_chan_splitter)","function":"Native component","source":"MODIFY; rtl/common/modified/axi_llc/src/axi_llc_chan_splitter.sv"},{"key":"B4","label":["i_llc_config","(axi_llc_config)"],"width":200,"row":1,"col":1,"row_name":"i_llc_config (axi_llc_config)","function":"Native BIST/whole-way flush control","source":"MODIFY; rtl/common/modified/axi_llc/src/axi_llc_config.sv"},{"key":"B5","label":["i_evict_unit","(axi_llc_evict_unit)"],"width":240,"row":1,"col":2,"row_name":"i_evict_unit (axi_llc_evict_unit)","function":"Eviction/refill transport completion","source":"MODIFY; rtl/common/modified/axi_llc/src/axi_llc_evict_unit.sv"},{"key":"B6","label":["i_hit_miss_unit","(axi_llc_hit_miss)"],"width":220,"row":2,"col":0,"row_name":"i_hit_miss_unit (axi_llc_hit_miss)","function":"LLC lookup and descriptor association","source":"MODIFY; rtl/common/modified/axi_llc/src/axi_llc_hit_miss.sv"},{"key":"B7","label":["i_merge_unit","(axi_llc_merge_unit)"],"width":240,"row":2,"col":1,"row_name":"i_merge_unit (axi_llc_merge_unit)","function":"Native component","source":"REUSE; rtl/common/third_party/axi_llc/src/axi_llc_merge_unit.sv"},{"key":"B8","label":["i_read_unit","(axi_llc_read_unit)"],"width":220,"row":2,"col":2,"row_name":"i_read_unit (axi_llc_read_unit)","function":"Native component","source":"MODIFY; rtl/common/modified/axi_llc/src/axi_llc_read_unit.sv"},{"key":"B9","label":["i_refill_unit","(axi_llc_refill_unit)"],"width":260,"row":3,"col":0,"row_name":"i_refill_unit (axi_llc_refill_unit)","function":"Native component","source":"REUSE; rtl/common/third_party/axi_llc/src/axi_llc_refill_unit.sv"},{"key":"B10","label":["i_llc_ways","(axi_llc_ways)"],"width":180,"row":3,"col":1,"row_name":"i_llc_ways (axi_llc_ways)","function":"Native component","source":"REUSE; rtl/common/third_party/axi_llc/src/axi_llc_ways.sv"},{"key":"B11","label":["i_write_unit","(axi_llc_write_unit)"],"width":240,"row":3,"col":2,"row_name":"i_write_unit (axi_llc_write_unit)","function":"Native component","source":"MODIFY; rtl/common/modified/axi_llc/src/axi_llc_write_unit.sv"},{"key":"B12","label":["i_axi_bypass_mux","(axi_mux)"],"width":200,"row":4,"col":0,"row_name":"i_axi_bypass_mux (axi_mux)","function":"Native component","source":"REUSE; rtl/common/third_party/axi_llc_locked/axi/src/axi_mux.sv"},{"key":"B13","label":["i_rw_arb_tree","(rr_arb_tree)"],"width":160,"row":4,"col":1,"row_name":"i_rw_arb_tree (rr_arb_tree)","function":"Native component","source":"MODIFY; rtl/common/modified/cva6/vendor/pulp-platform/common_cells/src/rr_arb_tree.sv"},{"key":"B14","label":["i_rw_spill","(spill_register)"],"width":200,"row":4,"col":2,"row_name":"i_rw_spill (spill_register)","function":"Native component","source":"REUSE; rtl/common/third_party/axi_llc_locked/common_cells/src/spill_register.sv"}],"connectors":[],"externals":[],"interfaces":[],"nets":[],"legend_note":"Exact source-referenced children; generate multiplicity and active branches are specified in the component text. Containment denotes hierarchy, not invented signal connectivity. NEW/MODIFY/REUSE/GENERATED provenance is listed in the block table. Clock/reset follow the common synchronous contract. Complete parent port declarations are in the component section.","library_sha256":"15DFB183E267D2A94F8CAB316E01EB3D2E9D2F9C006DC816790A394F4123506C"}
```

[Editable draw.io](figures/post_a06/axi_llc_top.drawio) · [Figure source](figures/post_a06/axi_llc_top.json).

**Interface and flow.** Keep native typed request/response records and source ordering. The parent wrapper owns translation to VLSIT flat ports. Exact port declarations:

| Direction | Exact source declaration |
|---|---|
| input | `logic maint_valid_i` |
| output | `logic maint_ready_o` |
| input | `logic [1:0] maint_op_i` |
| input | `logic [51:0] maint_pa_line_i` |
| output | `logic maint_done_o` |
| output | `logic maint_error_o` |
| input | `logic clk_i` |
| input | `logic rst_ni` |
| input | `logic test_i` |
| input | `slv_req_t slv_req_i` |
| output | `slv_resp_t slv_resp_o` |
| output | `mst_req_t mst_req_o` |
| input | `mst_resp_t mst_resp_i` |
| input | `conf_regs_q_t conf_regs_i` |
| output | `conf_regs_d_t conf_regs_o` |
| input | `axi_addr_t cached_start_addr_i` |
| input | `axi_addr_t cached_end_addr_i` |
| input | `axi_addr_t spm_start_addr_i` |
| output | `logic wb_fault_o` |
| output | `logic wb_fault_event_o` |
| output | `logic [AxiAddrWidth-1:0] wb_fault_addr_o` |
| output | `logic [1:0] wb_fault_resp_o` |
| output | `axi_llc_pkg::events_t axi_llc_events_o` |

**Recorded local changes (source history, not a substitute for the current contract):**
- DEC-039/040: forward matched fatal writeback event/address/raw BRESP.
- Defer way-flush tag invalidation until successful AXI writeback completion. Preserve dirty line state on a failed writeback; reset is required for recovery.
- Defer dirty replacement-tag writes until OKAY B; retain fault/descriptor on writeback errors and export the fault through the cluster wrappers. Contains the top_level of the axi_llc with structs as AXI connections. The standard configuration is a cache size of 512KByte with a set-associativity of 8, and line length of 8 blocks, one block equals the AXI data width of the
- DEC-038/A-02: commit refill tags only after complete successful R data; failed refills propagate error and invalidate the reserved allocation.

**State/verification.** Native state encodings and helper logic remain source-owned. Coherence/maintenance-relevant state machines are discussed in Section 10; native arithmetic/MMU/helper integration is linted, with only the specific activated CPU/FPU cases described in Section 15. No blanket ISA/FP/MMU or helper-equivalence qualification is claimed.

#### 14.5.11 `axi_llc_write_unit.sv` — MODIFY

Source: [rtl/common/modified/axi_llc/src/axi_llc_write_unit.sv](../../rtl/modified/axi_llc/src/axi_llc_write_unit.sv).

**Function and local effect.** Native axi llc write unit component. Preserve the native request/result or storage behavior while applying the explicit local changes recorded below. Its parent consumes the exact typed interfaces in this section; queue, arithmetic, memory and protocol helpers do not create new architectural ownership rules. Native latency/ordering remains source-defined and is not independently qualified by TOP lint.

![axi_llc_write_unit selected modified component](figures/post_a06/axi_llc_write_unit.svg)

```json
{"page_name":"BLOCK_DIAGRAM","out_name":"axi_llc_write_unit.drawio","layout":{"gap_h":120,"gap_v":110,"margin":80,"block_h":60},"top":{"frame_label":["Component composition","(axi_llc_write_unit)"]},"frame_row":["axi_llc_write_unit","Native modified component; function and change contract are specified in Section 14.","rtl/common/modified/axi_llc/src/axi_llc_write_unit.sv"],"frame_interfaces":[],"blocks":[{"key":"B0","label":["i_spill_register_b","(spill_register)"],"width":220,"row":0,"col":0,"row_name":"i_spill_register_b (spill_register)","function":"Native component","source":"REUSE; rtl/common/third_party/axi_llc_locked/common_cells/src/spill_register.sv"},{"key":"B1","label":["i_w_stream_fifo","(stream_fifo)"],"width":180,"row":1,"col":0,"row_name":"i_w_stream_fifo (stream_fifo)","function":"Native component","source":"REUSE; rtl/common/third_party/axi_llc_locked/common_cells/src/stream_fifo.sv"}],"connectors":[],"externals":[],"interfaces":[],"nets":[],"legend_note":"Exact source-referenced children; generate multiplicity and active branches are specified in the component text. Containment denotes hierarchy, not invented signal connectivity. NEW/MODIFY/REUSE/GENERATED provenance is listed in the block table. Clock/reset follow the common synchronous contract. Complete parent port declarations are in the component section.","library_sha256":"15DFB183E267D2A94F8CAB316E01EB3D2E9D2F9C006DC816790A394F4123506C"}
```

[Editable draw.io](figures/post_a06/axi_llc_write_unit.drawio) · [Figure source](figures/post_a06/axi_llc_write_unit.json).

**Interface and flow.** Keep native typed request/response records and source ordering. The parent wrapper owns translation to VLSIT flat ports. Exact port declarations:

| Direction | Exact source declaration |
|---|---|
| input | `logic clk_i` |
| input | `logic rst_ni` |
| input | `logic test_i` |
| input | `desc_t desc_i` |
| input | `logic desc_valid_i` |
| output | `logic desc_ready_o` |
| input | `w_chan_t w_chan_slv_i` |
| input | `logic w_chan_valid_i` |
| output | `logic w_chan_ready_o` |
| output | `b_chan_t b_chan_slv_o` |
| output | `logic b_chan_valid_o` |
| input | `logic b_chan_ready_i` |
| output | `way_inp_t way_inp_o` |
| output | `logic way_inp_valid_o` |
| input | `logic way_inp_ready_i` |
| output | `lock_t w_unlock_o` |
| output | `logic w_unlock_req_o` |
| input | `logic w_unlock_gnt_i` |

**Recorded local changes (source history, not a substitute for the current contract):**
- Make destination-width extension and truncation explicit at RTL assignments.
- Size incremental burst address arithmetic to the AXI helper address type.

**State/verification.** Native state encodings and helper logic remain source-owned. Coherence/maintenance-relevant state machines are discussed in Section 10; native arithmetic/MMU/helper integration is linted, with only the specific activated CPU/FPU cases described in Section 15. No blanket ISA/FP/MMU or helper-equivalence qualification is claimed.

#### 14.5.12 `axi_llc_ax_master.sv` — MODIFY

Source: [rtl/common/modified/axi_llc/src/eviction_refill/axi_llc_ax_master.sv](../../rtl/modified/axi_llc/src/eviction_refill/axi_llc_ax_master.sv).

**Function and local effect.** Native axi llc ax master component. Preserve the native request/result or storage behavior while applying the explicit local changes recorded below. Its parent consumes the exact typed interfaces in this section; queue, arithmetic, memory and protocol helpers do not create new architectural ownership rules. Native latency/ordering remains source-defined and is not independently qualified by TOP lint.

![axi_llc_ax_master selected modified component](figures/post_a06/axi_llc_ax_master.svg)

```json
{"page_name":"BLOCK_DIAGRAM","out_name":"axi_llc_ax_master.drawio","layout":{"gap_h":120,"gap_v":110,"margin":80,"block_h":60},"top":{"frame_label":["Component composition","(axi_llc_ax_master)"]},"frame_row":["axi_llc_ax_master","Native modified component; function and change contract are specified in Section 14.","rtl/common/modified/axi_llc/src/eviction_refill/axi_llc_ax_master.sv"],"frame_interfaces":["IN","OUT"],"blocks":[{"key":"B0","label":["component_boundary","(axi_llc_ax_master)"],"width":220,"row":0,"col":0,"row_name":"component_boundary (axi_llc_ax_master)","function":"Native component","source":"MODIFY; rtl/common/modified/axi_llc/src/eviction_refill/axi_llc_ax_master.sv"}],"connectors":[],"externals":[{"id":"IN","block":"B0","side":"L","dir":"in","pos":0,"text":["IN","ports"]},{"id":"OUT","block":"B0","side":"R","dir":"out","pos":0,"text":["OUT","ports"]}],"interfaces":[{"id":"IN","name":"Parent in ports","category":"custom","active":"in","signals":"clk_i, rst_ni, desc_i, desc_valid_i, desc_ready_i, ax_chan_ready_i"},{"id":"OUT","name":"Parent out ports","category":"custom","active":"out","signals":"desc_ready_o, desc_o, desc_valid_o, ax_chan_mst_o, ax_chan_valid_o"}],"nets":[],"legend_note":"A single boundary symbol denotes a leaf: internal equations/registers are described in its function/dataflow contract, not invented child modules. NEW/MODIFY/REUSE/GENERATED provenance is listed in the block table. Clock/reset follow the common synchronous contract. Complete parent port declarations are in the component section.","library_sha256":"15DFB183E267D2A94F8CAB316E01EB3D2E9D2F9C006DC816790A394F4123506C"}
```

[Editable draw.io](figures/post_a06/axi_llc_ax_master.drawio) · [Figure source](figures/post_a06/axi_llc_ax_master.json).

**Interface and flow.** Keep native typed request/response records and source ordering. The parent wrapper owns translation to VLSIT flat ports. Exact port declarations:

| Direction | Exact source declaration |
|---|---|
| input | `logic clk_i` |
| input | `logic rst_ni` |
| input | `desc_t desc_i` |
| input | `logic desc_valid_i` |
| output | `logic desc_ready_o` |
| output | `desc_t desc_o` |
| output | `logic desc_valid_o` |
| input | `logic desc_ready_i` |
| output | `ax_chan_t ax_chan_mst_o` |
| output | `logic ax_chan_valid_o` |
| input | `logic ax_chan_ready_i` |

**Recorded local changes (source history, not a substitute for the current contract):**
- Make destination-width extension and truncation explicit at RTL assignments.

**State/verification.** Native state encodings and helper logic remain source-owned. Coherence/maintenance-relevant state machines are discussed in Section 10; native arithmetic/MMU/helper integration is linted, with only the specific activated CPU/FPU cases described in Section 15. No blanket ISA/FP/MMU or helper-equivalence qualification is claimed.

#### 14.5.13 `axi_llc_r_master.sv` — MODIFY

Source: [rtl/common/modified/axi_llc/src/eviction_refill/axi_llc_r_master.sv](../../rtl/modified/axi_llc/src/eviction_refill/axi_llc_r_master.sv).

**Function and local effect.** LLC refill read master. Preserve ID/data/last/error association across refill buffering and explicit width/selection fixes; a failed refill must not silently create a valid cache line.

![axi_llc_r_master selected modified component](figures/post_a06/axi_llc_r_master.svg)

```json
{"page_name":"BLOCK_DIAGRAM","out_name":"axi_llc_r_master.drawio","layout":{"gap_h":120,"gap_v":110,"margin":80,"block_h":60},"top":{"frame_label":["Component composition","(axi_llc_r_master)"]},"frame_row":["axi_llc_r_master","Native modified component; function and change contract are specified in Section 14.","rtl/common/modified/axi_llc/src/eviction_refill/axi_llc_r_master.sv"],"frame_interfaces":[],"blocks":[{"key":"B0","label":["i_block_offset_counter","(counter)"],"width":260,"row":0,"col":0,"row_name":"i_block_offset_counter (counter)","function":"Native component","source":"REUSE; rtl/common/third_party/cva6/vendor/pulp-platform/common_cells/src/counter.sv"}],"connectors":[],"externals":[],"interfaces":[],"nets":[],"legend_note":"Exact source-referenced children; generate multiplicity and active branches are specified in the component text. Containment denotes hierarchy, not invented signal connectivity. NEW/MODIFY/REUSE/GENERATED provenance is listed in the block table. Clock/reset follow the common synchronous contract. Complete parent port declarations are in the component section.","library_sha256":"15DFB183E267D2A94F8CAB316E01EB3D2E9D2F9C006DC816790A394F4123506C"}
```

[Editable draw.io](figures/post_a06/axi_llc_r_master.drawio) · [Figure source](figures/post_a06/axi_llc_r_master.json).

**Interface and flow.** Keep native typed request/response records and source ordering. The parent wrapper owns translation to VLSIT flat ports. Exact port declarations:

| Direction | Exact source declaration |
|---|---|
| input | `logic clk_i` |
| input | `logic rst_ni` |
| input | `desc_t desc_i` |
| input | `logic desc_valid_i` |
| output | `logic desc_ready_o` |
| output | `desc_t desc_o` |
| output | `logic desc_valid_o` |
| input | `logic desc_ready_i` |
| input | `r_chan_t r_chan_mst_i` |
| input | `logic r_chan_valid_i` |
| output | `logic r_chan_ready_o` |
| output | `way_inp_t way_inp_o` |
| output | `logic way_inp_valid_o` |
| input | `logic way_inp_ready_i` |

**Recorded local changes (source history, not a substitute for the current contract):**
- DEC-038/A-02: aggregate refill RRESP errors into the returned descriptor.

**State/verification.** Native state encodings and helper logic remain source-owned. Coherence/maintenance-relevant state machines are discussed in Section 10; native arithmetic/MMU/helper integration is linted, with only the specific activated CPU/FPU cases described in Section 15. No blanket ISA/FP/MMU or helper-equivalence qualification is claimed.

#### 14.5.14 `axi_llc_w_master.sv` — MODIFY

Source: [rtl/common/modified/axi_llc/src/eviction_refill/axi_llc_w_master.sv](../../rtl/modified/axi_llc/src/eviction_refill/axi_llc_w_master.sv).

**Function and local effect.** LLC AXI writeback master. Retain the victim descriptor until accepted B. On failed non-maintenance B emit a pulse with actual victim tag plus set address and raw BRESP; do not report the replacement/refill address.

![axi_llc_w_master selected modified component](figures/post_a06/axi_llc_w_master.svg)

```json
{"page_name":"BLOCK_DIAGRAM","out_name":"axi_llc_w_master.drawio","layout":{"gap_h":120,"gap_v":110,"margin":80,"block_h":60},"top":{"frame_label":["Component composition","(axi_llc_w_master)"]},"frame_row":["axi_llc_w_master","Native modified component; function and change contract are specified in Section 14.","rtl/common/modified/axi_llc/src/eviction_refill/axi_llc_w_master.sv"],"frame_interfaces":[],"blocks":[{"key":"B0","label":["i_block_offset_counter","(counter)"],"width":260,"row":0,"col":0,"row_name":"i_block_offset_counter (counter)","function":"Native component","source":"REUSE; rtl/common/third_party/cva6/vendor/pulp-platform/common_cells/src/counter.sv"},{"key":"B1","label":["i_w_to_send_counter","(counter)"],"width":220,"row":0,"col":1,"row_name":"i_w_to_send_counter (counter)","function":"Native component","source":"REUSE; rtl/common/third_party/cva6/vendor/pulp-platform/common_cells/src/counter.sv"},{"key":"B2","label":["i_r_data_fifo","(fifo_v3)"],"width":160,"row":1,"col":0,"row_name":"i_r_data_fifo (fifo_v3)","function":"Native component","source":"REUSE; rtl/common/third_party/cva6/vendor/pulp-platform/common_cells/src/fifo_v3.sv"}],"connectors":[],"externals":[],"interfaces":[],"nets":[],"legend_note":"Exact source-referenced children; generate multiplicity and active branches are specified in the component text. Containment denotes hierarchy, not invented signal connectivity. NEW/MODIFY/REUSE/GENERATED provenance is listed in the block table. Clock/reset follow the common synchronous contract. Complete parent port declarations are in the component section.","library_sha256":"15DFB183E267D2A94F8CAB316E01EB3D2E9D2F9C006DC816790A394F4123506C"}
```

[Editable draw.io](figures/post_a06/axi_llc_w_master.drawio) · [Figure source](figures/post_a06/axi_llc_w_master.json).

**Interface and flow.** Keep native typed request/response records and source ordering. The parent wrapper owns translation to VLSIT flat ports. Exact port declarations:

| Direction | Exact source declaration |
|---|---|
| input | `logic clk_i` |
| input | `logic rst_ni` |
| input | `logic test_i` |
| input | `desc_t desc_i` |
| input | `logic desc_valid_i` |
| output | `logic desc_ready_o` |
| output | `desc_t desc_o` |
| output | `logic desc_valid_o` |
| input | `logic desc_ready_i` |
| output | `w_chan_t w_chan_mst_o` |
| output | `logic w_chan_valid_o` |
| input | `logic w_chan_ready_i` |
| input | `b_chan_t b_chan_mst_i` |
| input | `logic b_chan_valid_i` |
| output | `logic b_chan_ready_o` |
| output | `way_inp_t way_inp_o` |
| output | `logic way_inp_valid_o` |
| input | `logic way_inp_ready_i` |
| input | `way_oup_t way_out_i` |
| input | `logic way_out_valid_i` |
| output | `logic way_out_ready_o` |
| output | `logic flush_desc_recv_o` |
| output | `logic wb_commit_o` |
| output | `logic wb_fault_o` |
| output | `logic wb_fault_event_o` |
| output | `logic [AxiCfg.AddrWidthFull-1:0] wb_fault_addr_o` |
| output | `logic [1:0] wb_fault_resp_o` |
| output | `logic wb_error_o` |
| output | `logic maint_wb_done_o` |
| output | `logic maint_wb_error_o` |

**Recorded local changes (source history, not a substitute for the current contract):**
- DEC-039/040: forward matched fatal writeback event/address/raw BRESP.
- Defer way-flush tag invalidation until successful AXI writeback completion. Preserve dirty line state on a failed writeback; reset is required for recovery.
- Defer dirty replacement-tag writes until OKAY B; retain fault/descriptor on writeback errors and export the fault through the cluster wrappers. This unit handles the generation of w beats on the master channel if there is a cache line to evict. It has a register that holds the descriptor. All operations occur, when a valid descriptor is in the unit. The unit has two status flags `busy_q` and `send_q`. These

**State/verification.** Native state encodings and helper logic remain source-owned. Coherence/maintenance-relevant state machines are discussed in Section 10; native arithmetic/MMU/helper integration is linted, with only the specific activated CPU/FPU cases described in Section 15. No blanket ISA/FP/MMU or helper-equivalence qualification is claimed.

#### 14.5.15 `axi_llc_miss_counters.sv` — MODIFY

Source: [rtl/common/modified/axi_llc/src/hit_miss_detect/axi_llc_miss_counters.sv](../../rtl/modified/axi_llc/src/hit_miss_detect/axi_llc_miss_counters.sv).

**Function and local effect.** Native axi llc miss counters component. Preserve the native request/result or storage behavior while applying the explicit local changes recorded below. Its parent consumes the exact typed interfaces in this section; queue, arithmetic, memory and protocol helpers do not create new architectural ownership rules. Native latency/ordering remains source-defined and is not independently qualified by TOP lint.

![axi_llc_miss_counters selected modified component](figures/post_a06/axi_llc_miss_counters.svg)

```json
{"page_name":"BLOCK_DIAGRAM","out_name":"axi_llc_miss_counters.drawio","layout":{"gap_h":120,"gap_v":110,"margin":80,"block_h":60},"top":{"frame_label":["Component composition","(axi_llc_miss_counters)"]},"frame_row":["axi_llc_miss_counters","Native modified component; function and change contract are specified in Section 14.","rtl/common/modified/axi_llc/src/hit_miss_detect/axi_llc_miss_counters.sv"],"frame_interfaces":[],"blocks":[{"key":"B0","label":["i_miss_cnt","(counter)"],"width":120,"row":0,"col":0,"row_name":"i_miss_cnt (counter)","function":"Native component","source":"REUSE; rtl/common/third_party/cva6/vendor/pulp-platform/common_cells/src/counter.sv"},{"key":"B1","label":["i_miss_w_cnt","(counter)"],"width":140,"row":1,"col":0,"row_name":"i_miss_w_cnt (counter)","function":"Native component","source":"REUSE; rtl/common/third_party/cva6/vendor/pulp-platform/common_cells/src/counter.sv"}],"connectors":[],"externals":[],"interfaces":[],"nets":[],"legend_note":"Exact source-referenced children; generate multiplicity and active branches are specified in the component text. Containment denotes hierarchy, not invented signal connectivity. NEW/MODIFY/REUSE/GENERATED provenance is listed in the block table. Clock/reset follow the common synchronous contract. Complete parent port declarations are in the component section.","library_sha256":"15DFB183E267D2A94F8CAB316E01EB3D2E9D2F9C006DC816790A394F4123506C"}
```

[Editable draw.io](figures/post_a06/axi_llc_miss_counters.drawio) · [Figure source](figures/post_a06/axi_llc_miss_counters.json).

**Interface and flow.** Keep native typed request/response records and source ordering. The parent wrapper owns translation to VLSIT flat ports. Exact port declarations:

| Direction | Exact source declaration |
|---|---|
| input | `logic clk_i` |
| input | `logic rst_ni` |
| input | `cnt_t cnt_up_i` |
| input | `cnt_t cnt_down_i` |
| output | `logic to_miss_o` |
| output | `logic stall_o` |

**Recorded local changes (source history, not a substitute for the current contract):**
- Size outstanding-ID comparisons explicitly.

**State/verification.** Native state encodings and helper logic remain source-owned. Coherence/maintenance-relevant state machines are discussed in Section 10; native arithmetic/MMU/helper integration is linted, with only the specific activated CPU/FPU cases described in Section 15. No blanket ISA/FP/MMU or helper-equivalence qualification is claimed.

#### 14.5.16 `axi_llc_tag_store.sv` — MODIFY

Source: [rtl/common/modified/axi_llc/src/hit_miss_detect/axi_llc_tag_store.sv](../../rtl/modified/axi_llc/src/hit_miss_detect/axi_llc_tag_store.sv).

**Function and local effect.** LLC tag/dirty publication. Keep dirty victim/tag association through pending writeback. Publish replacement/clean/invalidate only after successful completion; preserve the victim on error and guard pending full/wrap conditions.

![axi_llc_tag_store selected modified component](figures/post_a06/axi_llc_tag_store.svg)

```json
{"page_name":"BLOCK_DIAGRAM","out_name":"axi_llc_tag_store.drawio","layout":{"gap_h":120,"gap_v":110,"margin":80,"block_h":60},"top":{"frame_label":["Component composition","(axi_llc_tag_store)"]},"frame_row":["axi_llc_tag_store","Native modified component; function and change contract are specified in Section 14.","rtl/common/modified/axi_llc/src/hit_miss_detect/axi_llc_tag_store.sv"],"frame_interfaces":[],"blocks":[{"key":"B0","label":["i_evict_box","(axi_llc_evict_box)"],"width":220,"row":0,"col":0,"row_name":"i_evict_box (axi_llc_evict_box)","function":"Native component","source":"REUSE; rtl/common/third_party/axi_llc/src/hit_miss_detect/axi_llc_evict_box.sv"},{"key":"B1","label":["i_tag_pattern_gen","(axi_llc_tag_pattern_gen)"],"width":300,"row":0,"col":1,"row_name":"i_tag_pattern_gen (axi_llc_tag_pattern_gen)","function":"Native component","source":"REUSE; rtl/common/third_party/axi_llc/src/hit_miss_detect/axi_llc_tag_pattern_gen.sv"},{"key":"B2","label":["i_onehot_to_bin","(onehot_to_bin)"],"width":180,"row":1,"col":0,"row_name":"i_onehot_to_bin (onehot_to_bin)","function":"Native component","source":"REUSE; rtl/common/third_party/axi_llc_locked/common_cells/src/onehot_to_bin.sv"},{"key":"B3","label":["i_shift_reg_bist","(shift_reg)"],"width":200,"row":1,"col":1,"row_name":"i_shift_reg_bist (shift_reg)","function":"Native component","source":"REUSE; rtl/common/third_party/cva6/vendor/pulp-platform/common_cells/src/shift_reg.sv"},{"key":"B4","label":["i_shift_reg_rvalid","(shift_reg)"],"width":220,"row":2,"col":0,"row_name":"i_shift_reg_rvalid (shift_reg)","function":"Native component","source":"REUSE; rtl/common/third_party/cva6/vendor/pulp-platform/common_cells/src/shift_reg.sv"},{"key":"B5","label":["i_spill_register","(spill_register)"],"width":200,"row":2,"col":1,"row_name":"i_spill_register (spill_register)","function":"Native component","source":"REUSE; rtl/common/third_party/axi_llc_locked/common_cells/src/spill_register.sv"},{"key":"B6","label":["i_tag_store","(tc_sram)"],"width":140,"row":3,"col":0,"row_name":"i_tag_store (tc_sram)","function":"Native component","source":"MODIFY; rtl/common/modified/cva6/vendor/pulp-platform/tech_cells_generic/src/rtl/tc_sram.sv"}],"connectors":[],"externals":[],"interfaces":[],"nets":[],"legend_note":"Exact source-referenced children; generate multiplicity and active branches are specified in the component text. Containment denotes hierarchy, not invented signal connectivity. NEW/MODIFY/REUSE/GENERATED provenance is listed in the block table. Clock/reset follow the common synchronous contract. Complete parent port declarations are in the component section.","library_sha256":"15DFB183E267D2A94F8CAB316E01EB3D2E9D2F9C006DC816790A394F4123506C"}
```

[Editable draw.io](figures/post_a06/axi_llc_tag_store.drawio) · [Figure source](figures/post_a06/axi_llc_tag_store.json).

**Interface and flow.** Keep native typed request/response records and source ordering. The parent wrapper owns translation to VLSIT flat ports. Exact port declarations:

| Direction | Exact source declaration |
|---|---|
| input | `logic clk_i` |
| input | `logic rst_ni` |
| input | `logic test_i` |
| input | `logic flush_commit_i` |
| input | `logic wb_commit_i` |
| input | `logic wb_error_i` |
| input | `logic refill_done_i` |
| input | `logic refill_error_i` |
| input | `way_ind_t refill_way_i` |
| input | `logic [Cfg.IndexLength-1:0] refill_index_i` |
| input | `logic maint_wb_done_i` |
| input | `logic maint_wb_error_i` |
| output | `logic maint_done_o` |
| output | `logic maint_error_o` |
| input | `way_ind_t spm_lock_i` |
| input | `way_ind_t flushed_i` |
| input | `store_req_t req_i` |
| input | `logic valid_i` |
| output | `logic ready_o` |
| output | `store_res_t res_o` |
| output | `logic valid_o` |
| input | `logic ready_i` |
| output | `way_ind_t bist_res_o` |
| output | `logic bist_valid_o` |

**Recorded local changes (source history, not a substitute for the current contract):**
- Defer way-flush tag invalidation until successful AXI writeback completion. Preserve dirty line state on a failed writeback; reset is required for recovery.
- Defer dirty replacement-tag writes until OKAY B; retain fault/descriptor on writeback errors and export the fault through the cluster wrappers.
- Permit deferred commit during full-table lookup stalls; prevent hit-stream starvation of pending writes. Verified full-table escape and pointer wrap. This is the Tag storage for the LLC There are four types of requests which can be made onto this unit. `axi_llc_pkg::Bist`:
- Initialize the SRAM index at its own width rather than the number-of-ways width.
- DEC-038/A-02: commit refill tags only after complete successful R data; failed refills propagate error and invalidate the reserved allocation.
- DEC-036/A-03 stress: backpressure every miss when the pending ring is full; clean misses reserve slots too and must not overwrite live entries.

**State/verification.** Native state encodings and helper logic remain source-owned. Coherence/maintenance-relevant state machines are discussed in Section 10; native arithmetic/MMU/helper integration is linted, with only the specific activated CPU/FPU cases described in Section 15. No blanket ISA/FP/MMU or helper-equivalence qualification is claimed.

#### 14.5.17 `axi_atop_filter.sv` — MODIFY

Source: [rtl/common/modified/axi_llc_locked/axi/src/axi_atop_filter.sv](../../rtl/modified/axi_llc_locked/axi/src/axi_atop_filter.sv).

**Function and local effect.** Native axi atop filter component. Preserve the native request/result or storage behavior while applying the explicit local changes recorded below. Its parent consumes the exact typed interfaces in this section; queue, arithmetic, memory and protocol helpers do not create new architectural ownership rules. Native latency/ordering remains source-defined and is not independently qualified by TOP lint.

![axi_atop_filter selected modified component](figures/post_a06/axi_atop_filter.svg)

```json
{"page_name":"BLOCK_DIAGRAM","out_name":"axi_atop_filter.drawio","layout":{"gap_h":120,"gap_v":110,"margin":80,"block_h":60},"top":{"frame_label":["Component composition","(axi_atop_filter)"]},"frame_row":["axi_atop_filter","Native modified component; function and change contract are specified in Section 14.","rtl/common/modified/axi_llc_locked/axi/src/axi_atop_filter.sv"],"frame_interfaces":[],"blocks":[{"key":"B0","label":["r_resp_cmd","(stream_register)"],"width":200,"row":0,"col":0,"row_name":"r_resp_cmd (stream_register)","function":"Native component","source":"REUSE; rtl/common/third_party/axi_llc_locked/common_cells/src/stream_register.sv"}],"connectors":[],"externals":[],"interfaces":[],"nets":[],"legend_note":"Exact source-referenced children; generate multiplicity and active branches are specified in the component text. Containment denotes hierarchy, not invented signal connectivity. NEW/MODIFY/REUSE/GENERATED provenance is listed in the block table. Clock/reset follow the common synchronous contract. Complete parent port declarations are in the component section.","library_sha256":"15DFB183E267D2A94F8CAB316E01EB3D2E9D2F9C006DC816790A394F4123506C"}
```

[Editable draw.io](figures/post_a06/axi_atop_filter.drawio) · [Figure source](figures/post_a06/axi_atop_filter.json).

**Interface and flow.** Keep native typed request/response records and source ordering. The parent wrapper owns translation to VLSIT flat ports. Exact port declarations:

| Direction | Exact source declaration |
|---|---|
| input | `logic clk_i` |
| input | `logic rst_ni` |
| input | `axi_req_t slv_req_i` |
| output | `axi_resp_t slv_resp_o` |
| output | `axi_req_t mst_req_o` |
| input | `axi_resp_t mst_resp_i` |
**Function and local effect.** Native axi atop filter intf component. Preserve the native request/result or storage behavior while applying the explicit local changes recorded below. Its parent consumes the exact typed interfaces in this section; queue, arithmetic, memory and protocol helpers do not create new architectural ownership rules. Native latency/ordering remains source-defined and is not independently qualified by TOP lint.

![axi_atop_filter_intf selected modified component](figures/post_a06/axi_atop_filter_intf.svg)

```json
{"page_name":"BLOCK_DIAGRAM","out_name":"axi_atop_filter_intf.drawio","layout":{"gap_h":120,"gap_v":110,"margin":80,"block_h":60},"top":{"frame_label":["Component composition","(axi_atop_filter_intf)"]},"frame_row":["axi_atop_filter_intf","Native modified component; function and change contract are specified in Section 14.","rtl/common/modified/axi_llc_locked/axi/src/axi_atop_filter.sv"],"frame_interfaces":[],"blocks":[{"key":"B0","label":["i_axi_atop_filter","(axi_atop_filter)"],"width":200,"row":0,"col":0,"row_name":"i_axi_atop_filter (axi_atop_filter)","function":"Native component","source":"MODIFY; rtl/common/modified/axi_llc_locked/axi/src/axi_atop_filter.sv"}],"connectors":[],"externals":[],"interfaces":[],"nets":[],"legend_note":"Exact source-referenced children; generate multiplicity and active branches are specified in the component text. Containment denotes hierarchy, not invented signal connectivity. NEW/MODIFY/REUSE/GENERATED provenance is listed in the block table. Clock/reset follow the common synchronous contract. Complete parent port declarations are in the component section.","library_sha256":"15DFB183E267D2A94F8CAB316E01EB3D2E9D2F9C006DC816790A394F4123506C"}
```

[Editable draw.io](figures/post_a06/axi_atop_filter_intf.drawio) · [Figure source](figures/post_a06/axi_atop_filter_intf.json).

**Interface and flow.** Keep native typed request/response records and source ordering. The parent wrapper owns translation to VLSIT flat ports. Exact port declarations:

| Direction | Exact source declaration |
|---|---|
| input | `logic clk_i` |
| input | `logic rst_ni` |
| interface modport | `AXI_BUS.Slave slv` |
| interface modport | `AXI_BUS.Master mst` |

**Recorded local changes (source history, not a substitute for the current contract):**
- Compare the write count at the configured transaction-limit width.

**State/verification.** Native state encodings and helper logic remain source-owned. Coherence/maintenance-relevant state machines are discussed in Section 10; native arithmetic/MMU/helper integration is linted, with only the specific activated CPU/FPU cases described in Section 15. No blanket ISA/FP/MMU or helper-equivalence qualification is claimed.

#### 14.5.18 `axi_demux_simple.sv` — MODIFY

Source: [rtl/common/modified/axi_llc_locked/axi/src/axi_demux_simple.sv](../../rtl/modified/axi_llc_locked/axi/src/axi_demux_simple.sv).

**Function and local effect.** Native axi demux simple component. Preserve the native request/result or storage behavior while applying the explicit local changes recorded below. Its parent consumes the exact typed interfaces in this section; queue, arithmetic, memory and protocol helpers do not create new architectural ownership rules. Native latency/ordering remains source-defined and is not independently qualified by TOP lint.

![axi_demux_simple selected modified component](figures/post_a06/axi_demux_simple.svg)

```json
{"page_name":"BLOCK_DIAGRAM","out_name":"axi_demux_simple.drawio","layout":{"gap_h":120,"gap_v":110,"margin":80,"block_h":60},"top":{"frame_label":["Component composition","(axi_demux_simple)"]},"frame_row":["axi_demux_simple","Native modified component; function and change contract are specified in Section 14.","rtl/common/modified/axi_llc_locked/axi/src/axi_demux_simple.sv"],"frame_interfaces":[],"blocks":[{"key":"B0","label":["i_ar_id_counter","(axi_demux_id_counters)"],"width":280,"row":0,"col":0,"row_name":"i_ar_id_counter (axi_demux_id_counters)","function":"Native component","source":"REUSE; rtl/common/third_party/axi_llc_locked/axi/src/axi_demux_id_counters.sv"},{"key":"B1","label":["i_aw_id_counter","(axi_demux_id_counters)"],"width":280,"row":0,"col":1,"row_name":"i_aw_id_counter (axi_demux_id_counters)","function":"Native component","source":"REUSE; rtl/common/third_party/axi_llc_locked/axi/src/axi_demux_id_counters.sv"},{"key":"B2","label":["i_counter_open_w","(counter)"],"width":200,"row":1,"col":0,"row_name":"i_counter_open_w (counter)","function":"Native component","source":"REUSE; rtl/common/third_party/cva6/vendor/pulp-platform/common_cells/src/counter.sv"},{"key":"B3","label":["i_b_mux","(rr_arb_tree)"],"width":160,"row":1,"col":1,"row_name":"i_b_mux (rr_arb_tree)","function":"Native component","source":"MODIFY; rtl/common/modified/cva6/vendor/pulp-platform/common_cells/src/rr_arb_tree.sv"},{"key":"B4","label":["i_r_mux","(rr_arb_tree)"],"width":160,"row":2,"col":0,"row_name":"i_r_mux (rr_arb_tree)","function":"Native component","source":"MODIFY; rtl/common/modified/cva6/vendor/pulp-platform/common_cells/src/rr_arb_tree.sv"}],"connectors":[],"externals":[],"interfaces":[],"nets":[],"legend_note":"Exact source-referenced children; generate multiplicity and active branches are specified in the component text. Containment denotes hierarchy, not invented signal connectivity. NEW/MODIFY/REUSE/GENERATED provenance is listed in the block table. Clock/reset follow the common synchronous contract. Complete parent port declarations are in the component section.","library_sha256":"15DFB183E267D2A94F8CAB316E01EB3D2E9D2F9C006DC816790A394F4123506C"}
```

[Editable draw.io](figures/post_a06/axi_demux_simple.drawio) · [Figure source](figures/post_a06/axi_demux_simple.json).

**Interface and flow.** Keep native typed request/response records and source ordering. The parent wrapper owns translation to VLSIT flat ports. Exact port declarations:

| Direction | Exact source declaration |
|---|---|
| input | `logic clk_i` |
| input | `logic rst_ni` |
| input | `logic test_i` |
| input | `axi_req_t slv_req_i` |
| input | `select_t slv_aw_select_i` |
| input | `select_t slv_ar_select_i` |
| output | `axi_resp_t slv_resp_o` |
| output | `axi_req_t [NoMstPorts-1:0] mst_reqs_o` |
| input | `axi_resp_t [NoMstPorts-1:0] mst_resps_i` |

**Recorded local changes (source history, not a substitute for the current contract):**
- Keep response arbitration VALID separate from selected B/R payload fields.
- Size route-selection comparisons to integer loop indices.

**State/verification.** Native state encodings and helper logic remain source-owned. Coherence/maintenance-relevant state machines are discussed in Section 10; native arithmetic/MMU/helper integration is linted, with only the specific activated CPU/FPU cases described in Section 15. No blanket ISA/FP/MMU or helper-equivalence qualification is claimed.

#### 14.5.19 `axi_isolate.sv` — MODIFY

Source: [rtl/common/modified/axi_llc_locked/axi/src/axi_isolate.sv](../../rtl/modified/axi_llc_locked/axi/src/axi_isolate.sv).

**Function and local effect.** Native axi isolate component. Preserve the native request/result or storage behavior while applying the explicit local changes recorded below. Its parent consumes the exact typed interfaces in this section; queue, arithmetic, memory and protocol helpers do not create new architectural ownership rules. Native latency/ordering remains source-defined and is not independently qualified by TOP lint.

![axi_isolate selected modified component](figures/post_a06/axi_isolate.svg)

```json
{"page_name":"BLOCK_DIAGRAM","out_name":"axi_isolate.drawio","layout":{"gap_h":120,"gap_v":110,"margin":80,"block_h":60},"top":{"frame_label":["Component composition","(axi_isolate)"]},"frame_row":["axi_isolate","Native modified component; function and change contract are specified in Section 14.","rtl/common/modified/axi_llc_locked/axi/src/axi_isolate.sv"],"frame_interfaces":[],"blocks":[{"key":"B0","label":["i_axi_demux","(axi_demux)"],"width":140,"row":0,"col":0,"row_name":"i_axi_demux (axi_demux)","function":"Native component","source":"REUSE; rtl/common/third_party/axi_llc_locked/axi/src/axi_demux.sv"},{"key":"B1","label":["i_axi_err_slv","(axi_err_slv)"],"width":160,"row":0,"col":1,"row_name":"i_axi_err_slv (axi_err_slv)","function":"Native component","source":"REUSE; rtl/common/third_party/axi_llc_locked/axi/src/axi_err_slv.sv"},{"key":"B2","label":["i_axi_isolate","(axi_isolate_inner)"],"width":220,"row":1,"col":0,"row_name":"i_axi_isolate (axi_isolate_inner)","function":"Native component","source":"MODIFY; rtl/common/modified/axi_llc_locked/axi/src/axi_isolate.sv"}],"connectors":[],"externals":[],"interfaces":[],"nets":[],"legend_note":"Exact source-referenced children; generate multiplicity and active branches are specified in the component text. Containment denotes hierarchy, not invented signal connectivity. NEW/MODIFY/REUSE/GENERATED provenance is listed in the block table. Clock/reset follow the common synchronous contract. Complete parent port declarations are in the component section.","library_sha256":"15DFB183E267D2A94F8CAB316E01EB3D2E9D2F9C006DC816790A394F4123506C"}
```

[Editable draw.io](figures/post_a06/axi_isolate.drawio) · [Figure source](figures/post_a06/axi_isolate.json).

**Interface and flow.** Keep native typed request/response records and source ordering. The parent wrapper owns translation to VLSIT flat ports. Exact port declarations:

| Direction | Exact source declaration |
|---|---|
| input | `logic clk_i` |
| input | `logic rst_ni` |
| input | `axi_req_t slv_req_i` |
| output | `axi_resp_t slv_resp_o` |
| output | `axi_req_t mst_req_o` |
| input | `axi_resp_t mst_resp_i` |
| input | `logic isolate_i` |
| output | `logic isolated_o` |
**Function and local effect.** Native axi isolate inner component. Preserve the native request/result or storage behavior while applying the explicit local changes recorded below. Its parent consumes the exact typed interfaces in this section; queue, arithmetic, memory and protocol helpers do not create new architectural ownership rules. Native latency/ordering remains source-defined and is not independently qualified by TOP lint.

![axi_isolate_inner selected modified component](figures/post_a06/axi_isolate_inner.svg)

```json
{"page_name":"BLOCK_DIAGRAM","out_name":"axi_isolate_inner.drawio","layout":{"gap_h":120,"gap_v":110,"margin":80,"block_h":60},"top":{"frame_label":["Component composition","(axi_isolate_inner)"]},"frame_row":["axi_isolate_inner","Native modified component; function and change contract are specified in Section 14.","rtl/common/modified/axi_llc_locked/axi/src/axi_isolate.sv"],"frame_interfaces":["IN","OUT"],"blocks":[{"key":"B0","label":["component_boundary","(axi_isolate_inner)"],"width":220,"row":0,"col":0,"row_name":"component_boundary (axi_isolate_inner)","function":"Native component","source":"MODIFY; rtl/common/modified/axi_llc_locked/axi/src/axi_isolate.sv"}],"connectors":[],"externals":[{"id":"IN","block":"B0","side":"L","dir":"in","pos":0,"text":["IN","ports"]},{"id":"OUT","block":"B0","side":"R","dir":"out","pos":0,"text":["OUT","ports"]}],"interfaces":[{"id":"IN","name":"Parent in ports","category":"custom","active":"in","signals":"clk_i, rst_ni, slv_req_i, mst_resp_i, isolate_i"},{"id":"OUT","name":"Parent out ports","category":"custom","active":"out","signals":"slv_resp_o, mst_req_o, isolated_o"}],"nets":[],"legend_note":"A single boundary symbol denotes a leaf: internal equations/registers are described in its function/dataflow contract, not invented child modules. NEW/MODIFY/REUSE/GENERATED provenance is listed in the block table. Clock/reset follow the common synchronous contract. Complete parent port declarations are in the component section.","library_sha256":"15DFB183E267D2A94F8CAB316E01EB3D2E9D2F9C006DC816790A394F4123506C"}
```

[Editable draw.io](figures/post_a06/axi_isolate_inner.drawio) · [Figure source](figures/post_a06/axi_isolate_inner.json).

**Interface and flow.** Keep native typed request/response records and source ordering. The parent wrapper owns translation to VLSIT flat ports. Exact port declarations:

| Direction | Exact source declaration |
|---|---|
| input | `logic clk_i` |
| input | `logic rst_ni` |
| input | `axi_req_t slv_req_i` |
| output | `axi_resp_t slv_resp_o` |
| output | `axi_req_t mst_req_o` |
| input | `axi_resp_t mst_resp_i` |
| input | `logic isolate_i` |
| output | `logic isolated_o` |
**Function and local effect.** Native axi isolate intf component. Preserve the native request/result or storage behavior while applying the explicit local changes recorded below. Its parent consumes the exact typed interfaces in this section; queue, arithmetic, memory and protocol helpers do not create new architectural ownership rules. Native latency/ordering remains source-defined and is not independently qualified by TOP lint.

![axi_isolate_intf selected modified component](figures/post_a06/axi_isolate_intf.svg)

```json
{"page_name":"BLOCK_DIAGRAM","out_name":"axi_isolate_intf.drawio","layout":{"gap_h":120,"gap_v":110,"margin":80,"block_h":60},"top":{"frame_label":["Component composition","(axi_isolate_intf)"]},"frame_row":["axi_isolate_intf","Native modified component; function and change contract are specified in Section 14.","rtl/common/modified/axi_llc_locked/axi/src/axi_isolate.sv"],"frame_interfaces":[],"blocks":[{"key":"B0","label":["i_axi_isolate","(axi_isolate)"],"width":160,"row":0,"col":0,"row_name":"i_axi_isolate (axi_isolate)","function":"Native component","source":"MODIFY; rtl/common/modified/axi_llc_locked/axi/src/axi_isolate.sv"}],"connectors":[],"externals":[],"interfaces":[],"nets":[],"legend_note":"Exact source-referenced children; generate multiplicity and active branches are specified in the component text. Containment denotes hierarchy, not invented signal connectivity. NEW/MODIFY/REUSE/GENERATED provenance is listed in the block table. Clock/reset follow the common synchronous contract. Complete parent port declarations are in the component section.","library_sha256":"15DFB183E267D2A94F8CAB316E01EB3D2E9D2F9C006DC816790A394F4123506C"}
```

[Editable draw.io](figures/post_a06/axi_isolate_intf.drawio) · [Figure source](figures/post_a06/axi_isolate_intf.json).

**Interface and flow.** Keep native typed request/response records and source ordering. The parent wrapper owns translation to VLSIT flat ports. Exact port declarations:

| Direction | Exact source declaration |
|---|---|
| input | `logic clk_i` |
| input | `logic rst_ni` |
| interface modport | `AXI_BUS.Slave slv` |
| interface modport | `AXI_BUS.Master mst` |
| input | `logic isolate_i` |
| output | `logic isolated_o` |

**Recorded local changes (source history, not a substitute for the current contract):**
- Separate channel outputs from isolation FSM next-state; no added registers or latency.

**State/verification.** Native state encodings and helper logic remain source-owned. Coherence/maintenance-relevant state machines are discussed in Section 10; native arithmetic/MMU/helper integration is linted, with only the specific activated CPU/FPU cases described in Section 15. No blanket ISA/FP/MMU or helper-equivalence qualification is claimed.

#### 14.5.20 `stream_xbar.sv` — MODIFY

Source: [rtl/common/modified/axi_llc_locked/common_cells/src/stream_xbar.sv](../../rtl/modified/axi_llc_locked/common_cells/src/stream_xbar.sv).

**Function and local effect.** Native stream xbar component. Preserve the native request/result or storage behavior while applying the explicit local changes recorded below. Its parent consumes the exact typed interfaces in this section; queue, arithmetic, memory and protocol helpers do not create new architectural ownership rules. Native latency/ordering remains source-defined and is not independently qualified by TOP lint.

![stream_xbar selected modified component](figures/post_a06/stream_xbar.svg)

```json
{"page_name":"BLOCK_DIAGRAM","out_name":"stream_xbar.drawio","layout":{"gap_h":120,"gap_v":110,"margin":80,"block_h":60},"top":{"frame_label":["Component composition","(stream_xbar)"]},"frame_row":["stream_xbar","Native modified component; function and change contract are specified in Section 14.","rtl/common/modified/axi_llc_locked/common_cells/src/stream_xbar.sv"],"frame_interfaces":[],"blocks":[{"key":"B0","label":["i_rr_arb_tree","(rr_arb_tree)"],"width":160,"row":0,"col":0,"row_name":"i_rr_arb_tree (rr_arb_tree)","function":"Native component","source":"MODIFY; rtl/common/modified/cva6/vendor/pulp-platform/common_cells/src/rr_arb_tree.sv"},{"key":"B1","label":["i_spill_register","(spill_register)"],"width":200,"row":0,"col":1,"row_name":"i_spill_register (spill_register)","function":"Native component","source":"REUSE; rtl/common/third_party/axi_llc_locked/common_cells/src/spill_register.sv"},{"key":"B2","label":["i_stream_demux","(stream_demux)"],"width":180,"row":1,"col":0,"row_name":"i_stream_demux (stream_demux)","function":"Native component","source":"MODIFY; rtl/common/modified/cva6/vendor/pulp-platform/common_cells/src/stream_demux.sv"}],"connectors":[],"externals":[],"interfaces":[],"nets":[],"legend_note":"Exact source-referenced children; generate multiplicity and active branches are specified in the component text. Containment denotes hierarchy, not invented signal connectivity. NEW/MODIFY/REUSE/GENERATED provenance is listed in the block table. Clock/reset follow the common synchronous contract. Complete parent port declarations are in the component section.","library_sha256":"15DFB183E267D2A94F8CAB316E01EB3D2E9D2F9C006DC816790A394F4123506C"}
```

[Editable draw.io](figures/post_a06/stream_xbar.drawio) · [Figure source](figures/post_a06/stream_xbar.json).

**Interface and flow.** Keep native typed request/response records and source ordering. The parent wrapper owns translation to VLSIT flat ports. Exact port declarations:

| Direction | Exact source declaration |
|---|---|
| input | `logic clk_i` |
| input | `logic rst_ni` |
| input | `logic flush_i` |
| input | `idx_inp_t [NumOut-1:0] rr_i` |
| input | `payload_t [NumInp-1:0] data_i` |
| input | `sel_oup_t [NumInp-1:0] sel_i` |
| input | `logic [NumInp-1:0] valid_i` |
| output | `logic [NumInp-1:0] ready_o` |
| output | `payload_t [NumOut-1:0] data_o` |
| output | `idx_inp_t [NumOut-1:0] idx_o` |
| output | `logic [NumOut-1:0] valid_o` |
| input | `logic [NumOut-1:0] ready_i` |

**Recorded local changes (source history, not a substitute for the current contract):**
- Represent boolean crossbar parameters as one-bit values.
- Compare selected outputs at the configured integer limit width.

**State/verification.** Native state encodings and helper logic remain source-owned. Coherence/maintenance-relevant state machines are discussed in Section 10; native arithmetic/MMU/helper integration is linted, with only the specific activated CPU/FPU cases described in Section 15. No blanket ISA/FP/MMU or helper-equivalence qualification is claimed.

#### 14.5.21 `sub_per_hash.sv` — MODIFY

Source: [rtl/common/modified/axi_llc_locked/common_cells/src/sub_per_hash.sv](../../rtl/modified/axi_llc_locked/common_cells/src/sub_per_hash.sv).

**Function and local effect.** Native sub per hash component. Preserve the native request/result or storage behavior while applying the explicit local changes recorded below. Its parent consumes the exact typed interfaces in this section; queue, arithmetic, memory and protocol helpers do not create new architectural ownership rules. Native latency/ordering remains source-defined and is not independently qualified by TOP lint.

![sub_per_hash selected modified component](figures/post_a06/sub_per_hash.svg)

```json
{"page_name":"BLOCK_DIAGRAM","out_name":"sub_per_hash.drawio","layout":{"gap_h":120,"gap_v":110,"margin":80,"block_h":60},"top":{"frame_label":["Component composition","(sub_per_hash)"]},"frame_row":["sub_per_hash","Native modified component; function and change contract are specified in Section 14.","rtl/common/modified/axi_llc_locked/common_cells/src/sub_per_hash.sv"],"frame_interfaces":["IN","OUT"],"blocks":[{"key":"B0","label":["component_boundary","(sub_per_hash)"],"width":220,"row":0,"col":0,"row_name":"component_boundary (sub_per_hash)","function":"Native component","source":"MODIFY; rtl/common/modified/axi_llc_locked/common_cells/src/sub_per_hash.sv"}],"connectors":[],"externals":[{"id":"IN","block":"B0","side":"L","dir":"in","pos":0,"text":["IN","ports"]},{"id":"OUT","block":"B0","side":"R","dir":"out","pos":0,"text":["OUT","ports"]}],"interfaces":[{"id":"IN","name":"Parent in ports","category":"custom","active":"in","signals":"data_i"},{"id":"OUT","name":"Parent out ports","category":"custom","active":"out","signals":"hash_o, hash_onehot_o"}],"nets":[],"legend_note":"A single boundary symbol denotes a leaf: internal equations/registers are described in its function/dataflow contract, not invented child modules. NEW/MODIFY/REUSE/GENERATED provenance is listed in the block table. Clock/reset follow the common synchronous contract. Complete parent port declarations are in the component section.","library_sha256":"15DFB183E267D2A94F8CAB316E01EB3D2E9D2F9C006DC816790A394F4123506C"}
```

[Editable draw.io](figures/post_a06/sub_per_hash.drawio) · [Figure source](figures/post_a06/sub_per_hash.json).

**Interface and flow.** Keep native typed request/response records and source ordering. The parent wrapper owns translation to VLSIT flat ports. Exact port declarations:

| Direction | Exact source declaration |
|---|---|
| input | `logic [InpWidth-1:0] data_i` |
| output | `logic [HashWidth-1:0] hash_o` |
| output | `logic [2**HashWidth-1:0] hash_onehot_o` |

**Recorded local changes (source history, not a substitute for the current contract):**
- Make destination-width extension and truncation explicit at RTL assignments.
- Size hash-constant permutation arithmetic and bounded array indices explicitly.

**State/verification.** Native state encodings and helper logic remain source-owned. Coherence/maintenance-relevant state machines are discussed in Section 10; native arithmetic/MMU/helper integration is linted, with only the specific activated CPU/FPU cases described in Section 15. No blanket ISA/FP/MMU or helper-equivalence qualification is claimed.

#### 14.5.22 `sram.sv` — MODIFY

Source: [rtl/common/modified/cva6/common/local/util/sram.sv](../../rtl/modified/cva6/common/local/util/sram.sv).

**Function and local effect.** SRAM wrapper for FPGA (requires the fpga-support submodule). Preserve the native request/result or storage behavior while applying the explicit local changes recorded below. Its parent consumes the exact typed interfaces in this section; queue, arithmetic, memory and protocol helpers do not create new architectural ownership rules. Native latency/ordering remains source-defined and is not independently qualified by TOP lint.

![sram selected modified component](figures/post_a06/sram.svg)

```json
{"page_name":"BLOCK_DIAGRAM","out_name":"sram.drawio","layout":{"gap_h":120,"gap_v":110,"margin":80,"block_h":60},"top":{"frame_label":["Component composition","(sram)"]},"frame_row":["sram","Native modified component; function and change contract are specified in Section 14.","rtl/common/modified/cva6/common/local/util/sram.sv"],"frame_interfaces":[],"blocks":[{"key":"B0","label":["i_tc_sram_wrapper","(tc_sram_wrapper)"],"width":200,"row":0,"col":0,"row_name":"i_tc_sram_wrapper (tc_sram_wrapper)","function":"Native component","source":"REUSE; rtl/common/third_party/cva6/common/local/util/tc_sram_wrapper.sv"},{"key":"B1","label":["i_tc_sram_wrapper_user","(tc_sram_wrapper)"],"width":260,"row":1,"col":0,"row_name":"i_tc_sram_wrapper_user (tc_sram_wrapper)","function":"Native component","source":"REUSE; rtl/common/third_party/cva6/common/local/util/tc_sram_wrapper.sv"}],"connectors":[],"externals":[],"interfaces":[],"nets":[],"legend_note":"Exact source-referenced children; generate multiplicity and active branches are specified in the component text. Containment denotes hierarchy, not invented signal connectivity. NEW/MODIFY/REUSE/GENERATED provenance is listed in the block table. Clock/reset follow the common synchronous contract. Complete parent port declarations are in the component section.","library_sha256":"15DFB183E267D2A94F8CAB316E01EB3D2E9D2F9C006DC816790A394F4123506C"}
```

[Editable draw.io](figures/post_a06/sram.drawio) · [Figure source](figures/post_a06/sram.json).

**Interface and flow.** Keep native typed request/response records and source ordering. The parent wrapper owns translation to VLSIT flat ports. Exact port declarations:

| Direction | Exact source declaration |
|---|---|
| input | `logic clk_i` |
| input | `logic rst_ni` |
| input | `logic req_i` |
| input | `logic we_i` |
| input | `logic [$clog2(NUM_WORDS)-1:0] addr_i` |
| input | `logic [USER_WIDTH-1:0] wuser_i` |
| input | `logic [DATA_WIDTH-1:0] wdata_i` |
| input | `logic [(DATA_WIDTH+7)/8-1:0] be_i` |
| output | `logic [USER_WIDTH-1:0] ruser_o` |
| output | `logic [DATA_WIDTH-1:0] rdata_o` |

**Recorded local changes (source history, not a substitute for the current contract):**
- Make destination-width extension and truncation explicit at RTL assignments.

**State/verification.** Native state encodings and helper logic remain source-owned. Coherence/maintenance-relevant state machines are discussed in Section 10; native arithmetic/MMU/helper integration is linted, with only the specific activated CPU/FPU cases described in Section 15. No blanket ISA/FP/MMU or helper-equivalence qualification is claimed.

#### 14.5.23 `sram_cache.sv` — MODIFY

Source: [rtl/common/modified/cva6/common/local/util/sram_cache.sv](../../rtl/modified/cva6/common/local/util/sram_cache.sv).

**Function and local effect.** SRAM wrapper for FPGA (requires the fpga-support submodule). Preserve the native request/result or storage behavior while applying the explicit local changes recorded below. Its parent consumes the exact typed interfaces in this section; queue, arithmetic, memory and protocol helpers do not create new architectural ownership rules. Native latency/ordering remains source-defined and is not independently qualified by TOP lint.

![sram_cache selected modified component](figures/post_a06/sram_cache.svg)

```json
{"page_name":"BLOCK_DIAGRAM","out_name":"sram_cache.drawio","layout":{"gap_h":120,"gap_v":110,"margin":80,"block_h":60},"top":{"frame_label":["Component composition","(sram_cache)"]},"frame_row":["sram_cache","Native modified component; function and change contract are specified in Section 14.","rtl/common/modified/cva6/common/local/util/sram_cache.sv"],"frame_interfaces":[],"blocks":[{"key":"B0","label":["data_sram","(sram)"],"width":120,"row":0,"col":0,"row_name":"data_sram (sram)","function":"Native component","source":"MODIFY; rtl/common/modified/cva6/common/local/util/sram.sv"},{"key":"B1","label":["i_tc_sram_wrapper","(tc_sram_wrapper_cache_techno)"],"width":360,"row":1,"col":0,"row_name":"i_tc_sram_wrapper (tc_sram_wrapper_cache_techno)","function":"Native component","source":"REUSE; rtl/common/third_party/cva6/common/local/util/tc_sram_wrapper_cache_techno.sv"}],"connectors":[],"externals":[],"interfaces":[],"nets":[],"legend_note":"Exact source-referenced children; generate multiplicity and active branches are specified in the component text. Containment denotes hierarchy, not invented signal connectivity. NEW/MODIFY/REUSE/GENERATED provenance is listed in the block table. Clock/reset follow the common synchronous contract. Complete parent port declarations are in the component section.","library_sha256":"15DFB183E267D2A94F8CAB316E01EB3D2E9D2F9C006DC816790A394F4123506C"}
```

[Editable draw.io](figures/post_a06/sram_cache.drawio) · [Figure source](figures/post_a06/sram_cache.json).

**Interface and flow.** Keep native typed request/response records and source ordering. The parent wrapper owns translation to VLSIT flat ports. Exact port declarations:

| Direction | Exact source declaration |
|---|---|
| input | `logic clk_i` |
| input | `logic rst_ni` |
| input | `logic req_i` |
| input | `logic we_i` |
| input | `logic [$clog2(NUM_WORDS)-1:0] addr_i` |
| input | `logic [USER_WIDTH-1:0] wuser_i` |
| input | `logic [DATA_WIDTH-1:0] wdata_i` |
| input | `logic [(DATA_WIDTH+7)/8-1:0] be_i` |
| output | `logic [USER_WIDTH-1:0] ruser_o` |
| output | `logic [DATA_WIDTH-1:0] rdata_o` |

**Recorded local changes (source history, not a substitute for the current contract):**
- Convert the user-enable configuration word to a Boolean condition.

**State/verification.** Native state encodings and helper logic remain source-owned. Coherence/maintenance-relevant state machines are discussed in Section 10; native arithmetic/MMU/helper integration is linted, with only the specific activated CPU/FPU cases described in Section 15. No blanket ISA/FP/MMU or helper-equivalence qualification is claimed.

#### 14.5.24 `aes.sv` — MODIFY

Source: [rtl/common/modified/cva6/core/aes.sv](../../rtl/modified/cva6/core/aes.sv).

**Function and local effect.** The Zkn extension including its subsets accelerates cryptographic workloads by introducing dedicated. Preserve the native request/result or storage behavior while applying the explicit local changes recorded below. Its parent consumes the exact typed interfaces in this section; queue, arithmetic, memory and protocol helpers do not create new architectural ownership rules. Native latency/ordering remains source-defined and is not independently qualified by TOP lint.

![aes selected modified component](figures/post_a06/aes.svg)

```json
{"page_name":"BLOCK_DIAGRAM","out_name":"aes.drawio","layout":{"gap_h":120,"gap_v":110,"margin":80,"block_h":60},"top":{"frame_label":["Component composition","(aes)"]},"frame_row":["aes","Native modified component; function and change contract are specified in Section 14.","rtl/common/modified/cva6/core/aes.sv"],"frame_interfaces":["IN","OUT"],"blocks":[{"key":"B0","label":["component_boundary","(aes)"],"width":220,"row":0,"col":0,"row_name":"component_boundary (aes)","function":"Native component","source":"MODIFY; rtl/common/modified/cva6/core/aes.sv"}],"connectors":[],"externals":[{"id":"IN","block":"B0","side":"L","dir":"in","pos":0,"text":["IN","ports"]},{"id":"OUT","block":"B0","side":"R","dir":"out","pos":0,"text":["OUT","ports"]}],"interfaces":[{"id":"IN","name":"Parent in ports","category":"custom","active":"in","signals":"clk_i, rst_ni, fu_data_i, orig_instr_aes"},{"id":"OUT","name":"Parent out ports","category":"custom","active":"out","signals":"result_o"}],"nets":[],"legend_note":"A single boundary symbol denotes a leaf: internal equations/registers are described in its function/dataflow contract, not invented child modules. NEW/MODIFY/REUSE/GENERATED provenance is listed in the block table. Clock/reset follow the common synchronous contract. Complete parent port declarations are in the component section.","library_sha256":"15DFB183E267D2A94F8CAB316E01EB3D2E9D2F9C006DC816790A394F4123506C"}
```

[Editable draw.io](figures/post_a06/aes.drawio) · [Figure source](figures/post_a06/aes.json).

**Interface and flow.** Keep native typed request/response records and source ordering. The parent wrapper owns translation to VLSIT flat ports. Exact port declarations:

| Direction | Exact source declaration |
|---|---|
| input | `logic clk_i` |
| input | `logic rst_ni` |
| input | `fu_data_t fu_data_i` |
| input | `logic [ 5:0] orig_instr_aes` |
| output | `logic [CVA6Cfg.XLEN-1:0] result_o` |

**Recorded local changes (source history, not a substitute for the current contract):**
- Make destination-width extension and truncation explicit at RTL assignments.

**State/verification.** Native state encodings and helper logic remain source-owned. Coherence/maintenance-relevant state machines are discussed in Section 10; native arithmetic/MMU/helper integration is linted, with only the specific activated CPU/FPU cases described in Section 15. No blanket ISA/FP/MMU or helper-equivalence qualification is claimed.

#### 14.5.25 `alu.sv` — MODIFY

Source: [rtl/common/modified/cva6/core/alu.sv](../../rtl/modified/cva6/core/alu.sv).

**Function and local effect.** Ariane ALU based on RI5CY's ALU. Preserve the native request/result or storage behavior while applying the explicit local changes recorded below. Its parent consumes the exact typed interfaces in this section; queue, arithmetic, memory and protocol helpers do not create new architectural ownership rules. Native latency/ordering remains source-defined and is not independently qualified by TOP lint.

![alu selected modified component](figures/post_a06/alu.svg)

```json
{"page_name":"BLOCK_DIAGRAM","out_name":"alu.drawio","layout":{"gap_h":120,"gap_v":110,"margin":80,"block_h":60},"top":{"frame_label":["Component composition","(alu)"]},"frame_row":["alu","Native modified component; function and change contract are specified in Section 14.","rtl/common/modified/cva6/core/alu.sv"],"frame_interfaces":[],"blocks":[{"key":"B0","label":["i_clz_32b","(lzc)"],"width":120,"row":0,"col":0,"row_name":"i_clz_32b (lzc)","function":"Native component","source":"REUSE; rtl/common/third_party/cva6/vendor/pulp-platform/common_cells/src/lzc.sv"},{"key":"B1","label":["i_clz_64b","(lzc)"],"width":120,"row":0,"col":1,"row_name":"i_clz_64b (lzc)","function":"Native component","source":"REUSE; rtl/common/third_party/cva6/vendor/pulp-platform/common_cells/src/lzc.sv"},{"key":"B2","label":["i_cpop_count","(popcount)"],"width":140,"row":1,"col":0,"row_name":"i_cpop_count (popcount)","function":"Native component","source":"REUSE; rtl/common/third_party/cva6/vendor/pulp-platform/common_cells/src/popcount.sv"}],"connectors":[],"externals":[],"interfaces":[],"nets":[],"legend_note":"Exact source-referenced children; generate multiplicity and active branches are specified in the component text. Containment denotes hierarchy, not invented signal connectivity. NEW/MODIFY/REUSE/GENERATED provenance is listed in the block table. Clock/reset follow the common synchronous contract. Complete parent port declarations are in the component section.","library_sha256":"15DFB183E267D2A94F8CAB316E01EB3D2E9D2F9C006DC816790A394F4123506C"}
```

[Editable draw.io](figures/post_a06/alu.drawio) · [Figure source](figures/post_a06/alu.json).

**Interface and flow.** Keep native typed request/response records and source ordering. The parent wrapper owns translation to VLSIT flat ports. Exact port declarations:

| Direction | Exact source declaration |
|---|---|
| input | `logic clk_i` |
| input | `logic rst_ni` |
| input | `fu_data_t fu_data_i` |
| input | `fu_data_t fu_data_cpop_i` |
| output | `logic [CVA6Cfg.XLEN-1:0] result_o` |
| output | `logic alu_branch_res_o` |

**Recorded local changes (source history, not a substitute for the current contract):**
- Make destination-width extension and truncation explicit at RTL assignments.
- Size unsigned word operations, rotation distances and permutation indices explicitly.

**State/verification.** Native state encodings and helper logic remain source-owned. Coherence/maintenance-relevant state machines are discussed in Section 10; native arithmetic/MMU/helper integration is linted, with only the specific activated CPU/FPU cases described in Section 15. No blanket ISA/FP/MMU or helper-equivalence qualification is claimed.

#### 14.5.26 `ariane_regfile_ff.sv` — MODIFY

Source: [rtl/common/modified/cva6/core/ariane_regfile_ff.sv](../../rtl/modified/cva6/core/ariane_regfile_ff.sv).

**Function and local effect.** Register file with 31 or 15x 32 bit wide registers.. Preserve the native request/result or storage behavior while applying the explicit local changes recorded below. Its parent consumes the exact typed interfaces in this section; queue, arithmetic, memory and protocol helpers do not create new architectural ownership rules. Native latency/ordering remains source-defined and is not independently qualified by TOP lint.

![ariane_regfile selected modified component](figures/post_a06/ariane_regfile.svg)

```json
{"page_name":"BLOCK_DIAGRAM","out_name":"ariane_regfile.drawio","layout":{"gap_h":120,"gap_v":110,"margin":80,"block_h":60},"top":{"frame_label":["Component composition","(ariane_regfile)"]},"frame_row":["ariane_regfile","Native modified component; function and change contract are specified in Section 14.","rtl/common/modified/cva6/core/ariane_regfile_ff.sv"],"frame_interfaces":["IN","OUT"],"blocks":[{"key":"B0","label":["component_boundary","(ariane_regfile)"],"width":220,"row":0,"col":0,"row_name":"component_boundary (ariane_regfile)","function":"Native component","source":"MODIFY; rtl/common/modified/cva6/core/ariane_regfile_ff.sv"}],"connectors":[],"externals":[{"id":"IN","block":"B0","side":"L","dir":"in","pos":0,"text":["IN","ports"]},{"id":"OUT","block":"B0","side":"R","dir":"out","pos":0,"text":["OUT","ports"]}],"interfaces":[{"id":"IN","name":"Parent in ports","category":"custom","active":"in","signals":"clk_i, rst_ni, test_en_i, raddr_i, waddr_i, wdata_i, we_i"},{"id":"OUT","name":"Parent out ports","category":"custom","active":"out","signals":"rdata_o"}],"nets":[],"legend_note":"A single boundary symbol denotes a leaf: internal equations/registers are described in its function/dataflow contract, not invented child modules. NEW/MODIFY/REUSE/GENERATED provenance is listed in the block table. Clock/reset follow the common synchronous contract. Complete parent port declarations are in the component section.","library_sha256":"15DFB183E267D2A94F8CAB316E01EB3D2E9D2F9C006DC816790A394F4123506C"}
```

[Editable draw.io](figures/post_a06/ariane_regfile.drawio) · [Figure source](figures/post_a06/ariane_regfile.json).

**Interface and flow.** Keep native typed request/response records and source ordering. The parent wrapper owns translation to VLSIT flat ports. Exact port declarations:

| Direction | Exact source declaration |
|---|---|
| input | `logic clk_i` |
| input | `logic rst_ni` |
| input | `logic test_en_i` |
| input | `logic [ NR_READ_PORTS-1:0][ 4:0] raddr_i` |
| output | `logic [ NR_READ_PORTS-1:0][DATA_WIDTH-1:0] rdata_o` |
| input | `logic [CVA6Cfg.NrCommitPorts-1:0][ 4:0] waddr_i` |
| input | `logic [CVA6Cfg.NrCommitPorts-1:0][DATA_WIDTH-1:0] wdata_i` |
| input | `logic [CVA6Cfg.NrCommitPorts-1:0] we_i` |

**Recorded local changes (source history, not a substitute for the current contract):**
- Compare register indices at the loop-index width.

**State/verification.** Native state encodings and helper logic remain source-owned. Coherence/maintenance-relevant state machines are discussed in Section 10; native arithmetic/MMU/helper integration is linted, with only the specific activated CPU/FPU cases described in Section 15. No blanket ISA/FP/MMU or helper-equivalence qualification is claimed.

#### 14.5.27 `cva6_hpdcache_if_adapter.sv` — MODIFY

Source: [rtl/common/modified/cva6/core/cache_subsystem/cva6_hpdcache_if_adapter.sv](../../rtl/modified/cva6/core/cache_subsystem/cva6_hpdcache_if_adapter.sv).

**Function and local effect.** CPU-to-cache request adaptation. Preserve request identity, ownership needs and atomic/CMO error response association across the native CPU/cache adapter.

![cva6_hpdcache_if_adapter selected modified component](figures/post_a06/cva6_hpdcache_if_adapter.svg)

```json
{"page_name":"BLOCK_DIAGRAM","out_name":"cva6_hpdcache_if_adapter.drawio","layout":{"gap_h":120,"gap_v":110,"margin":80,"block_h":60},"top":{"frame_label":["Component composition","(cva6_hpdcache_if_adapter)"]},"frame_row":["cva6_hpdcache_if_adapter","Native modified component; function and change contract are specified in Section 14.","rtl/common/modified/cva6/core/cache_subsystem/cva6_hpdcache_if_adapter.sv"],"frame_interfaces":["IN","OUT"],"blocks":[{"key":"B0","label":["component_boundary","(cva6_hpdcache_if_adapter)"],"width":300,"row":0,"col":0,"row_name":"component_boundary (cva6_hpdcache_if_adapter)","function":"CPU-to-cache request adaptation","source":"MODIFY; rtl/common/modified/cva6/core/cache_subsystem/cva6_hpdcache_if_adapter.sv"}],"connectors":[],"externals":[{"id":"IN","block":"B0","side":"L","dir":"in","pos":0,"text":["IN","ports"]},{"id":"OUT","block":"B0","side":"R","dir":"out","pos":0,"text":["OUT","ports"]}],"interfaces":[{"id":"IN","name":"Parent in ports","category":"custom","active":"in","signals":"clk_i, rst_ni, hpdcache_req_sid_i, cva6_req_i, cva6_amo_req_i, cva6_dcache_flush_i, hpdcache_req_ready_i, hpdcache_rsp_valid_i, hpdcache_rsp_i"},{"id":"OUT","name":"Parent out ports","category":"custom","active":"out","signals":"cva6_req_o, cva6_amo_resp_o, cva6_amo_error_o, cva6_dcache_flush_ack_o, hpdcache_req_valid_o, hpdcache_req_o, hpdcache_req_abort_o, hpdcache_req_tag_o, hpdcache_req_pma_o"}],"nets":[],"legend_note":"A single boundary symbol denotes a leaf: internal equations/registers are described in its function/dataflow contract, not invented child modules. NEW/MODIFY/REUSE/GENERATED provenance is listed in the block table. Clock/reset follow the common synchronous contract. Complete parent port declarations are in the component section.","library_sha256":"15DFB183E267D2A94F8CAB316E01EB3D2E9D2F9C006DC816790A394F4123506C"}
```

[Editable draw.io](figures/post_a06/cva6_hpdcache_if_adapter.drawio) · [Figure source](figures/post_a06/cva6_hpdcache_if_adapter.json).

**Interface and flow.** Keep native typed request/response records and source ordering. The parent wrapper owns translation to VLSIT flat ports. Exact port declarations:

| Direction | Exact source declaration |
|---|---|
| input | `logic clk_i` |
| input | `logic rst_ni` |
| input | `hpdcache_req_sid_t hpdcache_req_sid_i` |
| input | `dcache_req_i_t cva6_req_i` |
| output | `dcache_req_o_t cva6_req_o` |
| input | `ariane_pkg::amo_req_t cva6_amo_req_i` |
| output | `ariane_pkg::amo_resp_t cva6_amo_resp_o` |
| output | `logic cva6_amo_error_o` |
| input | `logic cva6_dcache_flush_i` |
| output | `logic cva6_dcache_flush_ack_o` |
| output | `logic hpdcache_req_valid_o` |
| input | `logic hpdcache_req_ready_i` |
| output | `hpdcache_req_t hpdcache_req_o` |
| output | `logic hpdcache_req_abort_o` |
| output | `hpdcache_tag_t hpdcache_req_tag_o` |
| output | `hpdcache_pkg::hpdcache_pma_t hpdcache_req_pma_o` |
| input | `logic hpdcache_rsp_valid_i` |
| input | `hpdcache_rsp_t hpdcache_rsp_i` |

**Recorded local changes (source history, not a substitute for the current contract):**
- Decode PMA from input tags instead of the request struct being constructed.
- Make destination-width extension and truncation explicit at RTL assignments.
- Zero-extend request sizes to the native HPDcache request encoding width.
- DEC-038/A-02: preserve cached atomic errors and precise retirement fault state.

**State/verification.** Native state encodings and helper logic remain source-owned. Coherence/maintenance-relevant state machines are discussed in Section 10; native arithmetic/MMU/helper integration is linted, with only the specific activated CPU/FPU cases described in Section 15. No blanket ISA/FP/MMU or helper-equivalence qualification is claimed.

#### 14.5.28 `cva6_hpdcache_subsystem.sv` — MODIFY

Source: [rtl/common/modified/cva6/core/cache_subsystem/cva6_hpdcache_subsystem.sv](../../rtl/modified/cva6/core/cache_subsystem/cva6_hpdcache_subsystem.sv).

**Function and local effect.** Cache subsystem integration. Carry native instruction/data traffic, events, cache flush origins and the retained external maintenance path through the selected HPDcache write-back configuration.

![cva6_hpdcache_subsystem selected modified component](figures/post_a06/cva6_hpdcache_subsystem.svg)

```json
{"page_name":"BLOCK_DIAGRAM","out_name":"cva6_hpdcache_subsystem.drawio","layout":{"gap_h":120,"gap_v":110,"margin":80,"block_h":60},"top":{"frame_label":["Component composition","(cva6_hpdcache_subsystem)"]},"frame_row":["cva6_hpdcache_subsystem","Native modified component; function and change contract are specified in Section 14.","rtl/common/modified/cva6/core/cache_subsystem/cva6_hpdcache_subsystem.sv"],"frame_interfaces":[],"blocks":[{"key":"B0","label":["i_axi_arbiter","(cva6_hpdcache_subsystem_axi_arbiter)"],"width":440,"row":0,"col":0,"row_name":"i_axi_arbiter (cva6_hpdcache_subsystem_axi_arbiter)","function":"Cache AXI source arbitration","source":"MODIFY; rtl/common/modified/cva6/core/cache_subsystem/cva6_hpdcache_subsystem_axi_arbiter.sv"},{"key":"B1","label":["i_dcache","(cva6_hpdcache_wrapper)"],"width":280,"row":0,"col":1,"row_name":"i_dcache (cva6_hpdcache_wrapper)","function":"Native HPDcache and probe integration","source":"MODIFY; rtl/common/modified/cva6/core/cache_subsystem/cva6_hpdcache_wrapper.sv"},{"key":"B2","label":["i_cva6_icache","(cva6_icache)"],"width":160,"row":1,"col":0,"row_name":"i_cva6_icache (cva6_icache)","function":"Native component","source":"MODIFY; rtl/common/modified/cva6/core/cache_subsystem/cva6_icache.sv"}],"connectors":[],"externals":[],"interfaces":[],"nets":[],"legend_note":"Exact source-referenced children; generate multiplicity and active branches are specified in the component text. Containment denotes hierarchy, not invented signal connectivity. NEW/MODIFY/REUSE/GENERATED provenance is listed in the block table. Clock/reset follow the common synchronous contract. Complete parent port declarations are in the component section.","library_sha256":"15DFB183E267D2A94F8CAB316E01EB3D2E9D2F9C006DC816790A394F4123506C"}
```

[Editable draw.io](figures/post_a06/cva6_hpdcache_subsystem.drawio) · [Figure source](figures/post_a06/cva6_hpdcache_subsystem.json).

**Interface and flow.** Keep native typed request/response records and source ordering. The parent wrapper owns translation to VLSIT flat ports. Exact port declarations:

| Direction | Exact source declaration |
|---|---|
| input | `logic clk_i` |
| input | `logic rst_ni` |
| output | `noc_req_t noc_req_o` |
| input | `noc_resp_t noc_resp_i` |
| input | `logic icache_en_i` |
| input | `logic icache_flush_i` |
| output | `logic icache_flush_done_o` |
| output | `logic icache_miss_o` |
| input | `icache_areq_t icache_areq_i` |
| output | `icache_arsp_t icache_areq_o` |
| input | `icache_dreq_t icache_dreq_i` |
| output | `icache_drsp_t icache_dreq_o` |
| input | `logic dcache_enable_i` |
| input | `logic fence_sync_i` |
| output | `logic fence_line_valid_o` |
| input | `logic fence_line_ready_i` |
| output | `logic [CVA6Cfg.PLEN-5:0] fence_line_o` |
| input | `logic fence_line_done_i` |
| input | `logic fence_line_error_i` |
| output | `logic fence_error_o` |
| output | `logic [CVA6Cfg.PLEN-5:0] fence_error_line_o` |
| input | `logic dcache_flush_i` |
| output | `logic dcache_flush_ack_o` |
| output | `logic coh_flush_ack_valid_o` |
| output | `logic [CVA6Cfg.PLEN-4-1:0] coh_flush_ack_nline_o` |
| output | `logic [1:0] coh_flush_ack_origin_o` |
| output | `logic coh_flush_ack_error_o` |
| output | `logic coh_flush_rsp_invalid_o` |
| input | `logic coh_probe_query_valid_i` |
| input | `logic [CVA6Cfg.PLEN-4-1:0] coh_probe_query_nline_i` |
| output | `logic coh_probe_line_busy_o` |
| output | `logic coh_access_line_valid_o` |
| output | `logic [CVA6Cfg.PLEN-4-1:0] coh_access_nline_o` |
| output | `logic coh_victim_line_valid_o` |
| output | `logic [CVA6Cfg.PLEN-4-1:0] coh_victim_nline_o` |
| input | `logic [15:0] coh_line_lock_valid_i` |
| input | `logic [15:0][CVA6Cfg.PLEN-4-1:0] coh_line_lock_nline_i` |
| input | `logic coh_probe_req_valid_i` |
| output | `logic coh_probe_req_ready_o` |
| input | `logic [3:0] coh_probe_req_tag_i` |
| input | `logic [CVA6Cfg.PLEN-4-1:0] coh_probe_req_nline_i` |
| input | `logic [1:0] coh_probe_req_phase_i` |
| input | `logic [1:0] coh_probe_req_target_state_i` |
| input | `logic coh_probe_req_wback_en_i` |
| output | `logic coh_probe_rsp_valid_o` |
| input | `logic coh_probe_rsp_ready_i` |
| output | `logic [3:0] coh_probe_rsp_tag_o` |
| output | `logic [CVA6Cfg.PLEN-4-1:0] coh_probe_rsp_nline_o` |
| output | `logic [1:0] coh_probe_rsp_phase_o` |
| output | `logic [1:0] coh_probe_rsp_state_o` |
| output | `logic coh_probe_rsp_err_o` |
| output | `logic coh_probe_rsp_wback_done_o` |
| output | `logic coh_own_req_valid_o` |
| input | `logic coh_own_req_ready_i` |
| output | `logic [2:0] coh_own_req_id_o` |
| output | `logic [CVA6Cfg.PLEN-4-1:0] coh_own_req_nline_o` |
| output | `logic [1:0] coh_own_req_kind_o` |
| input | `logic coh_own_gnt_valid_i` |
| output | `logic coh_own_gnt_ready_o` |
| input | `logic [2:0] coh_own_gnt_id_i` |
| input | `logic [CVA6Cfg.PLEN-4-1:0] coh_own_gnt_nline_i` |
| input | `logic [1:0] coh_own_gnt_state_i` |
| input | `logic coh_own_gnt_err_i` |
| output | `logic dcache_miss_o` |
| output | `logic [15:0] dcache_perf_event_o` |
| input | `logic dcache_scrub_enable_i` |
| input | `logic [5:0] dcache_scrub_period_i` |
| output | `logic dcache_scrub_cycle_o` |
| output | `logic dcache_dat_cor_err_o` |
| output | `logic dcache_dat_unc_err_o` |
| output | `logic dcache_dir_cor_err_o` |
| output | `logic dcache_dir_unc_err_o` |
| input | `ariane_pkg::amo_req_t dcache_amo_req_i` |
| output | `ariane_pkg::amo_resp_t dcache_amo_resp_o` |
| output | `logic dcache_amo_error_o` |
| input | `dcache_req_i_t [NumPorts-1:0] dcache_req_ports_i` |
| output | `dcache_req_o_t [NumPorts-1:0] dcache_req_ports_o` |
| output | `logic wbuffer_empty_o` |
| output | `logic wbuffer_not_ni_o` |
| input | `logic [NrHwPrefetchers-1:0] hwpf_base_set_i` |
| input | `logic [NrHwPrefetchers-1:0][63:0] hwpf_base_i` |
| output | `logic [NrHwPrefetchers-1:0][63:0] hwpf_base_o` |
| input | `logic [NrHwPrefetchers-1:0] hwpf_param_set_i` |
| input | `logic [NrHwPrefetchers-1:0][63:0] hwpf_param_i` |
| output | `logic [NrHwPrefetchers-1:0][63:0] hwpf_param_o` |
| input | `logic [NrHwPrefetchers-1:0] hwpf_throttle_set_i` |
| input | `logic [NrHwPrefetchers-1:0][63:0] hwpf_throttle_i` |
| output | `logic [NrHwPrefetchers-1:0][63:0] hwpf_throttle_o` |
| output | `logic [ 63:0] hwpf_status_o` |

**Recorded local changes (source history, not a substitute for the current contract):**
- Route matched HPDcache flush B-response metadata to the CVA6 boundary.
- Route the exact-line MSHR/refill busy query to the tile boundary.
- Carry CCU line-lock vectors into the HPDcache wrapper.
- Route the tagged PREPARE/COMMIT/ABORT probe endpoint through CVA6.
- Route the HPDcache ownership permission handshake through the CVA6 subsystem.
- Expand request type declarations using explicit two-state widths for portable configured-subsystem elaboration in Verilator 5.053.
- Restore the upstream request-type macro after the explicit-width expansion failed in the configured Verilator elaboration.
- Propagate Stage-1 access and selected victim line observations to CVA6.
- Route the native 16-bit HPDcache PMU event vector through this subsystem.
- Size the instruction-cache read transaction ID at the cache boundary.
- DEC-030/031: retain FENCE.I through coherent clean completion and precise fault. Change: Forward coherent FENCE.I scan requests, terminal completions and physical fault line.
- DEC-038/A-02: preserve cached atomic errors and precise retirement fault state.

**State/verification.** Native state encodings and helper logic remain source-owned. Coherence/maintenance-relevant state machines are discussed in Section 10; native arithmetic/MMU/helper integration is linted, with only the specific activated CPU/FPU cases described in Section 15. No blanket ISA/FP/MMU or helper-equivalence qualification is claimed.

#### 14.5.29 `cva6_hpdcache_subsystem_axi_arbiter.sv` — MODIFY

Source: [rtl/common/modified/cva6/core/cache_subsystem/cva6_hpdcache_subsystem_axi_arbiter.sv](../../rtl/modified/cva6/core/cache_subsystem/cva6_hpdcache_subsystem_axi_arbiter.sv).

**Function and local effect.** Cache AXI source arbitration. Arbitrate instruction/data/cache sources and retain source ID association for B/R; report native writeback status to the proper flush origin.

![cva6_hpdcache_subsystem_axi_arbiter selected modified component](figures/post_a06/cva6_hpdcache_subsystem_axi_arbiter.svg)

```json
{"page_name":"BLOCK_DIAGRAM","out_name":"cva6_hpdcache_subsystem_axi_arbiter.drawio","layout":{"gap_h":120,"gap_v":110,"margin":80,"block_h":60},"top":{"frame_label":["Component composition","(cva6_hpdcache_subsystem_axi_arbiter)"]},"frame_row":["cva6_hpdcache_subsystem_axi_arbiter","Native modified component; function and change contract are specified in Section 14.","rtl/common/modified/cva6/core/cache_subsystem/cva6_hpdcache_subsystem_axi_arbiter.sv"],"frame_interfaces":[],"blocks":[{"key":"B0","label":["i_icache_hpdcache_data_upsize","(hpdcache_data_upsize)"],"width":340,"row":0,"col":0,"row_name":"i_icache_hpdcache_data_upsize (hpdcache_data_upsize)","function":"Native component","source":"MODIFY; rtl/common/modified/hpdcache_cva6_pinned/rtl/src/common/hpdcache_data_upsize.sv"},{"key":"B1","label":["i_icache_miss_req_fifo","(hpdcache_fifo_reg)"],"width":260,"row":0,"col":1,"row_name":"i_icache_miss_req_fifo (hpdcache_fifo_reg)","function":"Native component","source":"REUSE; rtl/common/third_party/hpdcache_cva6_pinned/rtl/src/common/hpdcache_fifo_reg.sv"},{"key":"B2","label":["i_icache_refill_meta_fifo","(hpdcache_fifo_reg)"],"width":300,"row":1,"col":0,"row_name":"i_icache_refill_meta_fifo (hpdcache_fifo_reg)","function":"Native component","source":"REUSE; rtl/common/third_party/hpdcache_cva6_pinned/rtl/src/common/hpdcache_fifo_reg.sv"},{"key":"B3","label":["i_mem_req_read_arbiter","(hpdcache_mem_req_read_arbiter)"],"width":360,"row":1,"col":1,"row_name":"i_mem_req_read_arbiter (hpdcache_mem_req_read_arbiter)","function":"Native component","source":"REUSE; rtl/common/third_party/hpdcache_cva6_pinned/rtl/src/utils/hpdcache_mem_req_read_arbiter.sv"},{"key":"B4","label":["i_mem_resp_read_demux","(hpdcache_mem_resp_demux)"],"width":300,"row":2,"col":0,"row_name":"i_mem_resp_read_demux (hpdcache_mem_resp_demux)","function":"Native component","source":"MODIFY; rtl/common/modified/hpdcache_cva6_pinned/rtl/src/utils/hpdcache_mem_resp_demux.sv"},{"key":"B5","label":["i_hpdcache_mem_to_axi_read","(hpdcache_mem_to_axi_read)"],"width":300,"row":2,"col":1,"row_name":"i_hpdcache_mem_to_axi_read (hpdcache_mem_to_axi_read)","function":"Native component","source":"REUSE; rtl/common/third_party/hpdcache_cva6_pinned/rtl/src/utils/hpdcache_mem_to_axi_read.sv"},{"key":"B6","label":["i_hpdcache_mem_to_axi_write","(hpdcache_mem_to_axi_write)"],"width":320,"row":3,"col":0,"row_name":"i_hpdcache_mem_to_axi_write (hpdcache_mem_to_axi_write)","function":"Native component","source":"MODIFY; rtl/common/modified/hpdcache_cva6_pinned/rtl/src/utils/hpdcache_mem_to_axi_write.sv"}],"connectors":[],"externals":[],"interfaces":[],"nets":[],"legend_note":"Exact source-referenced children; generate multiplicity and active branches are specified in the component text. Containment denotes hierarchy, not invented signal connectivity. NEW/MODIFY/REUSE/GENERATED provenance is listed in the block table. Clock/reset follow the common synchronous contract. Complete parent port declarations are in the component section.","library_sha256":"15DFB183E267D2A94F8CAB316E01EB3D2E9D2F9C006DC816790A394F4123506C"}
```

[Editable draw.io](figures/post_a06/cva6_hpdcache_subsystem_axi_arbiter.drawio) · [Figure source](figures/post_a06/cva6_hpdcache_subsystem_axi_arbiter.json).

**Interface and flow.** Keep native typed request/response records and source ordering. The parent wrapper owns translation to VLSIT flat ports. Exact port declarations:

| Direction | Exact source declaration |
|---|---|
| input | `logic clk_i` |
| input | `logic rst_ni` |
| input | `logic icache_miss_valid_i` |
| output | `logic icache_miss_ready_o` |
| input | `icache_req_t icache_miss_i` |
| input | `hpdcache_mem_id_t icache_miss_id_i` |
| output | `logic icache_miss_resp_valid_o` |
| output | `icache_rtrn_t icache_miss_resp_o` |
| output | `logic dcache_read_ready_o` |
| input | `logic dcache_read_valid_i` |
| input | `hpdcache_mem_req_t dcache_read_i` |
| input | `logic dcache_read_resp_ready_i` |
| output | `logic dcache_read_resp_valid_o` |
| output | `hpdcache_mem_resp_r_t dcache_read_resp_o` |
| output | `logic dcache_write_ready_o` |
| input | `logic dcache_write_valid_i` |
| input | `hpdcache_mem_req_t dcache_write_i` |
| output | `logic dcache_write_data_ready_o` |
| input | `logic dcache_write_data_valid_i` |
| input | `hpdcache_mem_req_w_t dcache_write_data_i` |
| input | `logic dcache_write_resp_ready_i` |
| output | `logic dcache_write_resp_valid_o` |
| output | `hpdcache_mem_resp_w_t dcache_write_resp_o` |
| output | `axi_req_t axi_req_o` |
| input | `axi_rsp_t axi_resp_i` |

**Recorded local changes (source history, not a substitute for the current contract):**
- Make destination-width extension and truncation explicit at RTL assignments.

**State/verification.** Native state encodings and helper logic remain source-owned. Coherence/maintenance-relevant state machines are discussed in Section 10; native arithmetic/MMU/helper integration is linted, with only the specific activated CPU/FPU cases described in Section 15. No blanket ISA/FP/MMU or helper-equivalence qualification is claimed.

#### 14.5.30 `cva6_hpdcache_wrapper.sv` — MODIFY

Source: [rtl/common/modified/cva6/core/cache_subsystem/cva6_hpdcache_wrapper.sv](../../rtl/modified/cva6/core/cache_subsystem/cva6_hpdcache_wrapper.sv).

**Function and local effect.** Native HPDcache and probe integration. Integrate the new tagged HPDcache probe endpoint with native metadata lookup/update, flush ACK, cache busy query and ownership request/grant channels.

![cva6_hpdcache_wrapper selected modified component](figures/post_a06/cva6_hpdcache_wrapper.svg)

```json
{"page_name":"BLOCK_DIAGRAM","out_name":"cva6_hpdcache_wrapper.drawio","layout":{"gap_h":120,"gap_v":110,"margin":80,"block_h":60},"top":{"frame_label":["Component composition","(cva6_hpdcache_wrapper)"]},"frame_row":["cva6_hpdcache_wrapper","Native modified component; function and change contract are specified in Section 14.","rtl/common/modified/cva6/core/cache_subsystem/cva6_hpdcache_wrapper.sv"],"frame_interfaces":[],"blocks":[{"key":"B0","label":["i_cva6_hpdcache_load_if_adapter","(cva6_hpdcache_if_adapter)"],"width":360,"row":0,"col":0,"row_name":"i_cva6_hpdcache_load_if_adapter (cva6_hpdcache_if_adapter)","function":"CPU-to-cache request adaptation","source":"MODIFY; rtl/common/modified/cva6/core/cache_subsystem/cva6_hpdcache_if_adapter.sv"},{"key":"B1","label":["i_cva6_hpdcache_store_if_adapter","(cva6_hpdcache_if_adapter)"],"width":380,"row":0,"col":1,"row_name":"i_cva6_hpdcache_store_if_adapter (cva6_hpdcache_if_adapter)","function":"CPU-to-cache request adaptation","source":"MODIFY; rtl/common/modified/cva6/core/cache_subsystem/cva6_hpdcache_if_adapter.sv"},{"key":"B2","label":["i_hpdcache","(hpdcache)"],"width":120,"row":1,"col":0,"row_name":"i_hpdcache (hpdcache)","function":"Native D-cache composition","source":"MODIFY; rtl/common/modified/hpdcache/rtl/src/hpdcache.sv"},{"key":"B3","label":["i_hwpf_stride_wrapper","(hwpf_stride_wrapper)"],"width":260,"row":1,"col":1,"row_name":"i_hwpf_stride_wrapper (hwpf_stride_wrapper)","function":"Native component","source":"MODIFY; rtl/common/modified/hpdcache/rtl/src/hwpf_stride_wrapper.sv"}],"connectors":[],"externals":[],"interfaces":[],"nets":[],"legend_note":"Exact source-referenced children; generate multiplicity and active branches are specified in the component text. Containment denotes hierarchy, not invented signal connectivity. NEW/MODIFY/REUSE/GENERATED provenance is listed in the block table. Clock/reset follow the common synchronous contract. Complete parent port declarations are in the component section.","library_sha256":"15DFB183E267D2A94F8CAB316E01EB3D2E9D2F9C006DC816790A394F4123506C"}
```

[Editable draw.io](figures/post_a06/cva6_hpdcache_wrapper.drawio) · [Figure source](figures/post_a06/cva6_hpdcache_wrapper.json).

**Interface and flow.** Keep native typed request/response records and source ordering. The parent wrapper owns translation to VLSIT flat ports. Exact port declarations:

| Direction | Exact source declaration |
|---|---|
| input | `logic clk_i` |
| input | `logic rst_ni` |
| input | `logic dcache_enable_i` |
| input | `logic fence_sync_i` |
| output | `logic fence_line_valid_o` |
| input | `logic fence_line_ready_i` |
| output | `logic [CVA6Cfg.PLEN-5:0] fence_line_o` |
| input | `logic fence_line_done_i` |
| input | `logic fence_line_error_i` |
| output | `logic fence_error_o` |
| output | `logic [CVA6Cfg.PLEN-5:0] fence_error_line_o` |
| input | `logic dcache_flush_i` |
| output | `logic dcache_flush_ack_o` |
| output | `logic dcache_miss_o` |
| output | `logic [15:0] dcache_perf_event_o` |
| input | `ariane_pkg::amo_req_t dcache_amo_req_i` |
| output | `ariane_pkg::amo_resp_t dcache_amo_resp_o` |
| output | `logic dcache_amo_error_o` |
| input | `dcache_req_i_t [NumPorts-1:0] dcache_req_ports_i` |
| output | `dcache_req_o_t [NumPorts-1:0] dcache_req_ports_o` |
| input | `logic dcache_scrub_enable_i` |
| input | `logic [ 5:0] dcache_scrub_period_i` |
| output | `logic dcache_scrub_cycle_o` |
| output | `logic dcache_dat_cor_err_o` |
| output | `logic dcache_dat_unc_err_o` |
| output | `logic dcache_dir_cor_err_o` |
| output | `logic dcache_dir_unc_err_o` |
| output | `logic wbuffer_empty_o` |
| output | `logic wbuffer_not_ni_o` |
| input | `logic [NrHwPrefetchers-1:0] hwpf_base_set_i` |
| input | `logic [NrHwPrefetchers-1:0][63:0] hwpf_base_i` |
| output | `logic [NrHwPrefetchers-1:0][63:0] hwpf_base_o` |
| input | `logic [NrHwPrefetchers-1:0] hwpf_param_set_i` |
| input | `logic [NrHwPrefetchers-1:0][63:0] hwpf_param_i` |
| output | `logic [NrHwPrefetchers-1:0][63:0] hwpf_param_o` |
| input | `logic [NrHwPrefetchers-1:0] hwpf_throttle_set_i` |
| input | `logic [NrHwPrefetchers-1:0][63:0] hwpf_throttle_i` |
| output | `logic [NrHwPrefetchers-1:0][63:0] hwpf_throttle_o` |
| output | `logic [ 63:0] hwpf_status_o` |
| input | `logic dcache_mem_req_read_ready_i` |
| output | `logic dcache_mem_req_read_valid_o` |
| output | `hpdcache_mem_req_t dcache_mem_req_read_o` |
| output | `logic dcache_mem_resp_read_ready_o` |
| input | `logic dcache_mem_resp_read_valid_i` |
| input | `hpdcache_mem_resp_r_t dcache_mem_resp_read_i` |
| input | `logic dcache_mem_resp_read_inval_i` |
| input | `hpdcache_nline_t dcache_mem_resp_read_inval_nline_i` |
| input | `logic dcache_mem_req_write_ready_i` |
| output | `logic dcache_mem_req_write_valid_o` |
| output | `hpdcache_mem_req_t dcache_mem_req_write_o` |
| input | `logic dcache_mem_req_write_data_ready_i` |
| output | `logic dcache_mem_req_write_data_valid_o` |
| output | `hpdcache_mem_req_w_t dcache_mem_req_write_data_o` |
| output | `logic dcache_mem_resp_write_ready_o` |
| input | `logic dcache_mem_resp_write_valid_i` |
| input | `hpdcache_mem_resp_w_t dcache_mem_resp_write_i` |
| output | `logic coh_flush_ack_valid_o` |
| output | `logic [HPDcacheCfg.nlineWidth-1:0] coh_flush_ack_nline_o` |
| output | `logic [1:0] coh_flush_ack_origin_o` |
| output | `logic coh_flush_ack_error_o` |
| output | `logic coh_flush_rsp_invalid_o` |
| input | `logic coh_probe_query_valid_i` |
| input | `hpdcache_nline_t coh_probe_query_nline_i` |
| output | `logic coh_probe_line_busy_o` |
| output | `logic coh_access_line_valid_o` |
| output | `hpdcache_nline_t coh_access_nline_o` |
| output | `logic coh_victim_line_valid_o` |
| output | `hpdcache_nline_t coh_victim_nline_o` |
| input | `logic [15:0] coh_line_lock_valid_i` |
| input | `logic [15:0][HPDcacheCfg.nlineWidth-1:0] coh_line_lock_nline_i` |
| input | `logic coh_probe_req_valid_i` |
| output | `logic coh_probe_req_ready_o` |
| input | `logic [3:0] coh_probe_req_tag_i` |
| input | `hpdcache_nline_t coh_probe_req_nline_i` |
| input | `logic [1:0] coh_probe_req_phase_i` |
| input | `logic [1:0] coh_probe_req_target_state_i` |
| input | `logic coh_probe_req_wback_en_i` |
| output | `logic coh_probe_rsp_valid_o` |
| input | `logic coh_probe_rsp_ready_i` |
| output | `logic [3:0] coh_probe_rsp_tag_o` |
| output | `hpdcache_nline_t coh_probe_rsp_nline_o` |
| output | `logic [1:0] coh_probe_rsp_phase_o` |
| output | `logic [1:0] coh_probe_rsp_state_o` |
| output | `logic coh_probe_rsp_err_o` |
| output | `logic coh_probe_rsp_wback_done_o` |
| output | `logic coh_own_req_valid_o` |
| input | `logic coh_own_req_ready_i` |
| output | `logic [2:0] coh_own_req_id_o` |
| output | `hpdcache_nline_t coh_own_req_nline_o` |
| output | `logic [1:0] coh_own_req_kind_o` |
| input | `logic coh_own_gnt_valid_i` |
| output | `logic coh_own_gnt_ready_o` |
| input | `logic [2:0] coh_own_gnt_id_i` |
| input | `hpdcache_nline_t coh_own_gnt_nline_i` |
| input | `logic [1:0] coh_own_gnt_state_i` |
| input | `logic coh_own_gnt_err_i` |

**Recorded local changes (source history, not a substitute for the current contract):**
- Export matched HPDcache flush B-response metadata to the subsystem boundary.
- Export the exact-line MSHR/refill busy query through the cache wrapper.
- Export CCU line-lock vectors to HPDcache for request and victim replay.
- Route the tagged PREPARE/COMMIT/ABORT request and held response to HPDcache.
- Carry HPDcache miss ownership request/grant signals through the cache wrapper.
- Export the live Stage-1 request and replacement-victim line observations.
- Export native HPDcache PMU indicators without changing their source logic.
- Include replay/refill/pipeline drain in the retirement store-empty indication. `include "hpdcache_typedef.svh"
- DEC-030/031: retain FENCE.I through coherent clean completion and precise fault. Change: Connect coherent FENCE.I walker sidebands to native HPDcache.
- DEC-038/A-02: preserve cached atomic errors and precise retirement fault state.

**State/verification.** Native state encodings and helper logic remain source-owned. Coherence/maintenance-relevant state machines are discussed in Section 10; native arithmetic/MMU/helper integration is linted, with only the specific activated CPU/FPU cases described in Section 15. No blanket ISA/FP/MMU or helper-equivalence qualification is claimed.

#### 14.5.31 `cva6_icache.sv` — MODIFY

Source: [rtl/common/modified/cva6/core/cache_subsystem/cva6_icache.sv](../../rtl/modified/cva6/core/cache_subsystem/cva6_icache.sv).

**Function and local effect.** Instruction cache that is compatible with openpiton.. Preserve the native request/result or storage behavior while applying the explicit local changes recorded below. Its parent consumes the exact typed interfaces in this section; queue, arithmetic, memory and protocol helpers do not create new architectural ownership rules. Native latency/ordering remains source-defined and is not independently qualified by TOP lint.

![cva6_icache selected modified component](figures/post_a06/cva6_icache.svg)

```json
{"page_name":"BLOCK_DIAGRAM","out_name":"cva6_icache.drawio","layout":{"gap_h":120,"gap_v":110,"margin":80,"block_h":60},"top":{"frame_label":["Component composition","(cva6_icache)"]},"frame_row":["cva6_icache","Native modified component; function and change contract are specified in Section 14.","rtl/common/modified/cva6/core/cache_subsystem/cva6_icache.sv"],"frame_interfaces":[],"blocks":[{"key":"B0","label":["i_lfsr","(lfsr)"],"width":80,"row":0,"col":0,"row_name":"i_lfsr (lfsr)","function":"Native component","source":"MODIFY; rtl/common/modified/cva6/vendor/pulp-platform/common_cells/src/lfsr.sv"},{"key":"B1","label":["i_lzc","(lzc)"],"width":60,"row":0,"col":1,"row_name":"i_lzc (lzc)","function":"Native component","source":"REUSE; rtl/common/third_party/cva6/vendor/pulp-platform/common_cells/src/lzc.sv"},{"key":"B2","label":["i_lzc_hit","(lzc)"],"width":120,"row":1,"col":0,"row_name":"i_lzc_hit (lzc)","function":"Native component","source":"REUSE; rtl/common/third_party/cva6/vendor/pulp-platform/common_cells/src/lzc.sv"},{"key":"B3","label":["data_sram","(sram_cache)"],"width":140,"row":1,"col":1,"row_name":"data_sram (sram_cache)","function":"Native component","source":"MODIFY; rtl/common/modified/cva6/common/local/util/sram_cache.sv"},{"key":"B4","label":["tag_sram","(sram_cache)"],"width":140,"row":2,"col":0,"row_name":"tag_sram (sram_cache)","function":"Native component","source":"MODIFY; rtl/common/modified/cva6/common/local/util/sram_cache.sv"}],"connectors":[],"externals":[],"interfaces":[],"nets":[],"legend_note":"Exact source-referenced children; generate multiplicity and active branches are specified in the component text. Containment denotes hierarchy, not invented signal connectivity. NEW/MODIFY/REUSE/GENERATED provenance is listed in the block table. Clock/reset follow the common synchronous contract. Complete parent port declarations are in the component section.","library_sha256":"15DFB183E267D2A94F8CAB316E01EB3D2E9D2F9C006DC816790A394F4123506C"}
```

[Editable draw.io](figures/post_a06/cva6_icache.drawio) · [Figure source](figures/post_a06/cva6_icache.json).

**Interface and flow.** Keep native typed request/response records and source ordering. The parent wrapper owns translation to VLSIT flat ports. Exact port declarations:

| Direction | Exact source declaration |
|---|---|
| input | `logic clk_i` |
| input | `logic rst_ni` |
| input | `logic flush_i` |
| output | `logic flush_done_o` |
| input | `logic en_i` |
| output | `logic miss_o` |
| input | `icache_areq_t areq_i` |
| output | `icache_arsp_t areq_o` |
| input | `icache_dreq_t dreq_i` |
| output | `icache_drsp_t dreq_o` |
| input | `logic mem_rtrn_vld_i` |
| input | `icache_rtrn_t mem_rtrn_i` |
| output | `logic mem_data_req_o` |
| input | `logic mem_data_ack_i` |
| output | `icache_req_t mem_data_o` |

**Recorded local changes (source history, not a substitute for the current contract):**
- Make destination-width extension and truncation explicit at RTL assignments.
- Size noncacheable offset operands and user-enable conditions explicitly.
- Extend the retained line offset explicitly in the address-width selection.
- DEC-030/031: acknowledge completed I-cache invalidation before FENCE.I retirement.

**State/verification.** Native state encodings and helper logic remain source-owned. Coherence/maintenance-relevant state machines are discussed in Section 10; native arithmetic/MMU/helper integration is linted, with only the specific activated CPU/FPU cases described in Section 15. No blanket ISA/FP/MMU or helper-equivalence qualification is claimed.

#### 14.5.32 `cva6_icache_axi_wrapper.sv` — MODIFY

Source: [rtl/common/modified/cva6/core/cache_subsystem/cva6_icache_axi_wrapper.sv](../../rtl/modified/cva6/core/cache_subsystem/cva6_icache_axi_wrapper.sv).

**Function and local effect.** wrapper module to connect the L1I$ to a 64bit AXI bus.. Preserve the native request/result or storage behavior while applying the explicit local changes recorded below. Its parent consumes the exact typed interfaces in this section; queue, arithmetic, memory and protocol helpers do not create new architectural ownership rules. Native latency/ordering remains source-defined and is not independently qualified by TOP lint.

![cva6_icache_axi_wrapper selected modified component](figures/post_a06/cva6_icache_axi_wrapper.svg)

```json
{"page_name":"BLOCK_DIAGRAM","out_name":"cva6_icache_axi_wrapper.drawio","layout":{"gap_h":120,"gap_v":110,"margin":80,"block_h":60},"top":{"frame_label":["Component composition","(cva6_icache_axi_wrapper)"]},"frame_row":["cva6_icache_axi_wrapper","Native modified component; function and change contract are specified in Section 14.","rtl/common/modified/cva6/core/cache_subsystem/cva6_icache_axi_wrapper.sv"],"frame_interfaces":[],"blocks":[{"key":"B0","label":["i_axi_shim","(axi_shim)"],"width":120,"row":0,"col":0,"row_name":"i_axi_shim (axi_shim)","function":"Native component","source":"REUSE; rtl/common/third_party/cva6/core/axi_shim.sv"},{"key":"B1","label":["i_cva6_icache","(cva6_icache)"],"width":160,"row":1,"col":0,"row_name":"i_cva6_icache (cva6_icache)","function":"Native component","source":"MODIFY; rtl/common/modified/cva6/core/cache_subsystem/cva6_icache.sv"}],"connectors":[],"externals":[],"interfaces":[],"nets":[],"legend_note":"Exact source-referenced children; generate multiplicity and active branches are specified in the component text. Containment denotes hierarchy, not invented signal connectivity. NEW/MODIFY/REUSE/GENERATED provenance is listed in the block table. Clock/reset follow the common synchronous contract. Complete parent port declarations are in the component section.","library_sha256":"15DFB183E267D2A94F8CAB316E01EB3D2E9D2F9C006DC816790A394F4123506C"}
```

[Editable draw.io](figures/post_a06/cva6_icache_axi_wrapper.drawio) · [Figure source](figures/post_a06/cva6_icache_axi_wrapper.json).

**Interface and flow.** Keep native typed request/response records and source ordering. The parent wrapper owns translation to VLSIT flat ports. Exact port declarations:

| Direction | Exact source declaration |
|---|---|
| input | `logic clk_i` |
| input | `logic rst_ni` |
| input | `riscv::priv_lvl_t priv_lvl_i` |
| input | `logic flush_i` |
| input | `logic en_i` |
| output | `logic miss_o` |
| input | `icache_areq_t areq_i` |
| output | `icache_arsp_t areq_o` |
| input | `icache_dreq_t dreq_i` |
| output | `icache_drsp_t dreq_o` |
| output | `axi_req_t axi_req_o` |
| input | `axi_rsp_t axi_resp_i` |

**Recorded local changes (source history, not a substitute for the current contract):**
- DEC-030: explicitly leave the optional I-cache maintenance ACK unused in this legacy cache wrapper.

**State/verification.** Native state encodings and helper logic remain source-owned. Coherence/maintenance-relevant state machines are discussed in Section 10; native arithmetic/MMU/helper integration is linted, with only the specific activated CPU/FPU cases described in Section 15. No blanket ISA/FP/MMU or helper-equivalence qualification is claimed.

#### 14.5.33 `wt_cache_subsystem.sv` — MODIFY

Source: [rtl/common/modified/cva6/core/cache_subsystem/wt_cache_subsystem.sv](../../rtl/modified/cva6/core/cache_subsystem/wt_cache_subsystem.sv).

**Function and local effect.** Ariane cache subsystem that is compatible with the OpenPiton. Preserve the native request/result or storage behavior while applying the explicit local changes recorded below. Its parent consumes the exact typed interfaces in this section; queue, arithmetic, memory and protocol helpers do not create new architectural ownership rules. Native latency/ordering remains source-defined and is not independently qualified by TOP lint.

![wt_cache_subsystem selected modified component](figures/post_a06/wt_cache_subsystem.svg)

```json
{"page_name":"BLOCK_DIAGRAM","out_name":"wt_cache_subsystem.drawio","layout":{"gap_h":120,"gap_v":110,"margin":80,"block_h":60},"top":{"frame_label":["Component composition","(wt_cache_subsystem)"]},"frame_row":["wt_cache_subsystem","Native modified component; function and change contract are specified in Section 14.","rtl/common/modified/cva6/core/cache_subsystem/wt_cache_subsystem.sv"],"frame_interfaces":[],"blocks":[{"key":"B0","label":["i_cva6_icache","(cva6_icache)"],"width":160,"row":0,"col":0,"row_name":"i_cva6_icache (cva6_icache)","function":"Native component","source":"MODIFY; rtl/common/modified/cva6/core/cache_subsystem/cva6_icache.sv"},{"key":"B1","label":["i_adapter","(wt_axi_adapter)"],"width":200,"row":0,"col":1,"row_name":"i_adapter (wt_axi_adapter)","function":"Native component","source":"REUSE; rtl/common/third_party/cva6/core/cache_subsystem/wt_axi_adapter.sv"},{"key":"B2","label":["i_wt_dcache","(wt_dcache)"],"width":140,"row":1,"col":0,"row_name":"i_wt_dcache (wt_dcache)","function":"Native component","source":"REUSE; rtl/common/third_party/cva6/core/cache_subsystem/wt_dcache.sv"}],"connectors":[],"externals":[],"interfaces":[],"nets":[],"legend_note":"Exact source-referenced children; generate multiplicity and active branches are specified in the component text. Containment denotes hierarchy, not invented signal connectivity. NEW/MODIFY/REUSE/GENERATED provenance is listed in the block table. Clock/reset follow the common synchronous contract. Complete parent port declarations are in the component section.","library_sha256":"15DFB183E267D2A94F8CAB316E01EB3D2E9D2F9C006DC816790A394F4123506C"}
```

[Editable draw.io](figures/post_a06/wt_cache_subsystem.drawio) · [Figure source](figures/post_a06/wt_cache_subsystem.json).

**Interface and flow.** Keep native typed request/response records and source ordering. The parent wrapper owns translation to VLSIT flat ports. Exact port declarations:

| Direction | Exact source declaration |
|---|---|
| input | `logic clk_i` |
| input | `logic rst_ni` |
| input | `logic icache_en_i` |
| input | `logic icache_flush_i` |
| output | `logic icache_miss_o` |
| input | `icache_areq_t icache_areq_i` |
| output | `icache_arsp_t icache_areq_o` |
| input | `icache_dreq_t icache_dreq_i` |
| output | `icache_drsp_t icache_dreq_o` |
| input | `logic dcache_enable_i` |
| input | `logic dcache_flush_i` |
| output | `logic dcache_flush_ack_o` |
| output | `logic dcache_miss_o` |
| output | `logic [NumPorts-1:0][CVA6Cfg.DCACHE_SET_ASSOC-1:0] miss_vld_bits_o` |
| input | `amo_req_t dcache_amo_req_i` |
| output | `amo_resp_t dcache_amo_resp_o` |
| input | `logic mbe_i` |
| input | `dcache_req_i_t [NumPorts-1:0] dcache_req_ports_i` |
| output | `dcache_req_o_t [NumPorts-1:0] dcache_req_ports_o` |
| output | `logic wbuffer_empty_o` |
| output | `logic wbuffer_not_ni_o` |
| output | `noc_req_t noc_req_o` |
| input | `noc_resp_t noc_resp_i` |
| input | `logic [63:0] inval_addr_i` |
| input | `logic inval_valid_i` |
| output | `logic inval_ready_o` |

**Recorded local changes (source history, not a substitute for the current contract):**
- DEC-030: explicitly leave the optional I-cache maintenance ACK unused in this legacy cache wrapper.

**State/verification.** Native state encodings and helper logic remain source-owned. Coherence/maintenance-relevant state machines are discussed in Section 10; native arithmetic/MMU/helper integration is linted, with only the specific activated CPU/FPU cases described in Section 15. No blanket ISA/FP/MMU or helper-equivalence qualification is claimed.

#### 14.5.34 `commit_stage.sv` — MODIFY

Source: [rtl/common/modified/cva6/core/commit_stage.sv](../../rtl/modified/cva6/core/commit_stage.sv).

**Function and local effect.** Precise retirement and completion. Hold accepted CBO/FENCE.I until terminal completion. Retain PC/address/error provenance, defer interrupt/debug admission while maintenance is active, retire only on success and trap after ABORT on failure.

![commit_stage selected modified component](figures/post_a06/commit_stage.svg)

```json
{"page_name":"BLOCK_DIAGRAM","out_name":"commit_stage.drawio","layout":{"gap_h":120,"gap_v":110,"margin":80,"block_h":60},"top":{"frame_label":["Component composition","(commit_stage)"]},"frame_row":["commit_stage","Native modified component; function and change contract are specified in Section 14.","rtl/common/modified/cva6/core/commit_stage.sv"],"frame_interfaces":["IN","OUT"],"blocks":[{"key":"B0","label":["component_boundary","(commit_stage)"],"width":220,"row":0,"col":0,"row_name":"component_boundary (commit_stage)","function":"Precise retirement and completion","source":"MODIFY; rtl/common/modified/cva6/core/commit_stage.sv"}],"connectors":[],"externals":[{"id":"IN","block":"B0","side":"L","dir":"in","pos":0,"text":["IN","ports"]},{"id":"OUT","block":"B0","side":"R","dir":"out","pos":0,"text":["OUT","ports"]}],"interfaces":[{"id":"IN","name":"Parent in ports","category":"custom","active":"in","signals":"clk_i, rst_ni, halt_i, flush_dcache_i, single_step_i, commit_instr_i, commit_drop_i, amo_resp_i, amo_error_i, amo_active_i, csr_rdata_i, csr_exception_i, cmo_entry_valid_i, cmo_entry_op_i, cmo_entry_paddr_i, cmo_entry_vaddr_i, cmo_ready_i, cmo_done_i, cmo_error_i, cmo_fault_paddr_i, fence_icache_done_i, commit_lsu_ready_i, no_st_pending_i, shared_tlb_flush_busy_i, sdtrig_commit_icount_valid_i, sdtrig_commit_icount_nr_instr_i, sdtrig_commit_action_i, sdtrig_commit_std_exception_valid_i"},{"id":"OUT","name":"Parent out ports","category":"custom","active":"out","signals":"exception_o, dirty_fp_state_o, commit_ack_o, commit_macro_ack_o, waddr_o, wdata_o, we_gpr_o, we_fpr_o, pc_o, csr_op_o, csr_wdata_o, csr_write_fflags_o, cmo_valid_o, cmo_op_o, cmo_pa_line_o, cmo_vaddr_o, cmo_pc_o, fence_sync_o, fence_icache_req_o, cmo_active_o, commit_lsu_o, commit_tran_id_o, amo_valid_commit_o, commit_csr_o, fence_i_o, fence_o, flush_commit_o, sfence_vma_o, hfence_vvma_o, hfence_gvma_o"}],"nets":[],"legend_note":"A single boundary symbol denotes a leaf: internal equations/registers are described in its function/dataflow contract, not invented child modules. NEW/MODIFY/REUSE/GENERATED provenance is listed in the block table. Clock/reset follow the common synchronous contract. Complete parent port declarations are in the component section.","library_sha256":"15DFB183E267D2A94F8CAB316E01EB3D2E9D2F9C006DC816790A394F4123506C"}
```

[Editable draw.io](figures/post_a06/commit_stage.drawio) · [Figure source](figures/post_a06/commit_stage.json).

**Interface and flow.** Keep native typed request/response records and source ordering. The parent wrapper owns translation to VLSIT flat ports. Exact port declarations:

| Direction | Exact source declaration |
|---|---|
| input | `logic clk_i` |
| input | `logic rst_ni` |
| input | `logic halt_i` |
| input | `logic flush_dcache_i` |
| output | `exception_t exception_o` |
| output | `logic dirty_fp_state_o` |
| input | `logic single_step_i` |
| input | `scoreboard_entry_t [CVA6Cfg.NrCommitPorts-1:0] commit_instr_i` |
| input | `logic [CVA6Cfg.NrCommitPorts-1:0] commit_drop_i` |
| output | `logic [CVA6Cfg.NrCommitPorts-1:0] commit_ack_o` |
| output | `logic [CVA6Cfg.NrCommitPorts-1:0] commit_macro_ack_o` |
| output | `logic [CVA6Cfg.NrCommitPorts-1:0][4:0] waddr_o` |
| output | `logic [CVA6Cfg.NrCommitPorts-1:0][CVA6Cfg.XLEN-1:0] wdata_o` |
| output | `logic [CVA6Cfg.NrCommitPorts-1:0] we_gpr_o` |
| output | `logic [CVA6Cfg.NrCommitPorts-1:0] we_fpr_o` |
| input | `amo_resp_t amo_resp_i` |
| input | `logic amo_error_i` |
| input | `logic amo_active_i` |
| output | `logic [CVA6Cfg.VLEN-1:0] pc_o` |
| output | `fu_op csr_op_o` |
| output | `logic [CVA6Cfg.XLEN-1:0] csr_wdata_o` |
| input | `logic [CVA6Cfg.XLEN-1:0] csr_rdata_i` |
| output | `logic csr_write_fflags_o` |
| input | `exception_t csr_exception_i` |
| input | `logic cmo_entry_valid_i` |
| input | `logic [7:0] cmo_entry_op_i` |
| input | `logic [CVA6Cfg.PLEN-1:0] cmo_entry_paddr_i` |
| input | `logic [CVA6Cfg.VLEN-1:0] cmo_entry_vaddr_i` |
| output | `logic cmo_valid_o` |
| input | `logic cmo_ready_i` |
| output | `logic [1:0] cmo_op_o` |
| output | `logic [CVA6Cfg.PLEN-5:0] cmo_pa_line_o` |
| output | `logic [CVA6Cfg.VLEN-1:0] cmo_vaddr_o` |
| output | `logic [CVA6Cfg.VLEN-1:0] cmo_pc_o` |
| input | `logic cmo_done_i` |
| input | `logic cmo_error_i` |
| input | `logic [CVA6Cfg.PLEN-1:0] cmo_fault_paddr_i` |
| output | `logic fence_sync_o` |
| output | `logic fence_icache_req_o` |
| input | `logic fence_icache_done_i` |
| output | `logic cmo_active_o` |
| output | `logic commit_lsu_o` |
| input | `logic commit_lsu_ready_i` |
| output | `logic [CVA6Cfg.TRANS_ID_BITS-1:0] commit_tran_id_o` |
| output | `logic amo_valid_commit_o` |
| input | `logic no_st_pending_i` |
| output | `logic commit_csr_o` |
| output | `logic fence_i_o` |
| output | `logic fence_o` |
| output | `logic flush_commit_o` |
| output | `logic sfence_vma_o` |
| output | `logic hfence_vvma_o` |
| output | `logic hfence_gvma_o` |
| input | `logic shared_tlb_flush_busy_i` |
| input | `logic sdtrig_commit_icount_valid_i` |
| input | `logic [$clog2(CVA6Cfg.NrCommitPorts)-1:0] sdtrig_commit_icount_nr_instr_i` |
| input | `logic [CVA6Cfg.XLEN-1:0] sdtrig_commit_action_i` |
| input | `logic sdtrig_commit_std_exception_valid_i` |

**Recorded local changes (source history, not a substitute for the current contract):**
- Add external CMO retirement completion, precise cause-7 failure, and deferred interrupt/debug exception entry while a command is outstanding. ExternalCmo remains disabled until the cluster service path is connected.
- Decouple CSR opcode and FP-flag payload from CSR access-fault retirement feedback.
- Bound FP flag merging to its five-bit field before XLEN extension.
- DEC-030/031: retain FENCE.I through coherent clean completion and precise fault. Change: Add whole-FENCE command/completion retention, precise cause 24 and physical fault address.
- DEC-038/A-02: preserve cached atomic errors and precise retirement fault state.

**State/verification.** Native state encodings and helper logic remain source-owned. Coherence/maintenance-relevant state machines are discussed in Section 10; native arithmetic/MMU/helper integration is linted, with only the specific activated CPU/FPU cases described in Section 15. No blanket ISA/FP/MMU or helper-equivalence qualification is claimed.

#### 14.5.35 `controller.sv` — MODIFY

Source: [rtl/common/modified/cva6/core/controller.sv](../../rtl/modified/cva6/core/controller.sv).

**Function and local effect.** Pipeline flush and fence coordination. Coordinate fetch/pipeline invalidation with retained maintenance completion so an accepted CBO/FENCE.I cannot be lost by ordinary flush/interrupt/debug control.

![controller selected modified component](figures/post_a06/controller.svg)

```json
{"page_name":"BLOCK_DIAGRAM","out_name":"controller.drawio","layout":{"gap_h":120,"gap_v":110,"margin":80,"block_h":60},"top":{"frame_label":["Component composition","(controller)"]},"frame_row":["controller","Native modified component; function and change contract are specified in Section 14.","rtl/common/modified/cva6/core/controller.sv"],"frame_interfaces":["IN","OUT"],"blocks":[{"key":"B0","label":["component_boundary","(controller)"],"width":220,"row":0,"col":0,"row_name":"component_boundary (controller)","function":"Pipeline flush and fence coordination","source":"MODIFY; rtl/common/modified/cva6/core/controller.sv"}],"connectors":[],"externals":[{"id":"IN","block":"B0","side":"L","dir":"in","pos":0,"text":["IN","ports"]},{"id":"OUT","block":"B0","side":"R","dir":"out","pos":0,"text":["OUT","ports"]}],"interfaces":[{"id":"IN","name":"Parent in ports","category":"custom","active":"in","signals":"clk_i, rst_ni, v_i, flush_dcache_ack_i, halt_csr_i, halt_acc_i, eret_i, ex_valid_i, set_debug_pc_i, resolved_branch_i, flush_csr_i, fence_i_i, fence_i, sfence_vma_i, hfence_vvma_i, hfence_gvma_i, flush_commit_i, flush_acc_i"},{"id":"OUT","name":"Parent out ports","category":"custom","active":"out","signals":"set_pc_commit_o, flush_if_o, flush_unissued_instr_o, flush_id_o, flush_ex_o, flush_bp_o, flush_icache_o, flush_dcache_o, flush_tlb_o, flush_tlb_vvma_o, flush_tlb_gvma_o, halt_frontend_o, halt_o"}],"nets":[],"legend_note":"A single boundary symbol denotes a leaf: internal equations/registers are described in its function/dataflow contract, not invented child modules. NEW/MODIFY/REUSE/GENERATED provenance is listed in the block table. Clock/reset follow the common synchronous contract. Complete parent port declarations are in the component section.","library_sha256":"15DFB183E267D2A94F8CAB316E01EB3D2E9D2F9C006DC816790A394F4123506C"}
```

[Editable draw.io](figures/post_a06/controller.drawio) · [Figure source](figures/post_a06/controller.json).

**Interface and flow.** Keep native typed request/response records and source ordering. The parent wrapper owns translation to VLSIT flat ports. Exact port declarations:

| Direction | Exact source declaration |
|---|---|
| input | `logic clk_i` |
| input | `logic rst_ni` |
| input | `logic v_i` |
| output | `logic set_pc_commit_o` |
| output | `logic flush_if_o` |
| output | `logic flush_unissued_instr_o` |
| output | `logic flush_id_o` |
| output | `logic flush_ex_o` |
| output | `logic flush_bp_o` |
| output | `logic flush_icache_o` |
| output | `logic flush_dcache_o` |
| input | `logic flush_dcache_ack_i` |
| output | `logic flush_tlb_o` |
| output | `logic flush_tlb_vvma_o` |
| output | `logic flush_tlb_gvma_o` |
| input | `logic halt_csr_i` |
| input | `logic halt_acc_i` |
| output | `logic halt_frontend_o` |
| output | `logic halt_o` |
| input | `logic eret_i` |
| input | `logic ex_valid_i` |
| input | `logic set_debug_pc_i` |
| input | `bp_resolve_t resolved_branch_i` |
| input | `logic flush_csr_i` |
| input | `logic fence_i_i` |
| input | `logic fence_i` |
| input | `logic sfence_vma_i` |
| input | `logic hfence_vvma_i` |
| input | `logic hfence_gvma_i` |
| input | `logic flush_commit_i` |
| input | `logic flush_acc_i` |

**Recorded local changes (source history, not a substitute for the current contract):**
- DEC-030/031: retain FENCE.I through coherent clean completion and precise fault. Change: Invalidate I-cache after coherent completion without repeating the legacy D-cache flush.

**State/verification.** Native state encodings and helper logic remain source-owned. Coherence/maintenance-relevant state machines are discussed in Section 10; native arithmetic/MMU/helper integration is linted, with only the specific activated CPU/FPU cases described in Section 15. No blanket ISA/FP/MMU or helper-equivalence qualification is claimed.

#### 14.5.36 `csr_regfile.sv` — MODIFY

Source: [rtl/common/modified/cva6/core/csr_regfile.sv](../../rtl/modified/cva6/core/csr_regfile.sv).

**Function and local effect.** Privilege, delegation and trap state. Route precise maintenance and atomic errors to the correct M/S trap state. Preserve the custom FENCE.I cause-24 and aligned physical fault-value contract; software support is a SoC dependency.

![csr_regfile selected modified component](figures/post_a06/csr_regfile.svg)

```json
{"page_name":"BLOCK_DIAGRAM","out_name":"csr_regfile.drawio","layout":{"gap_h":120,"gap_v":110,"margin":80,"block_h":60},"top":{"frame_label":["Component composition","(csr_regfile)"]},"frame_row":["csr_regfile","Native modified component; function and change contract are specified in Section 14.","rtl/common/modified/cva6/core/csr_regfile.sv"],"frame_interfaces":[],"blocks":[{"key":"B0","label":["trigger_module_i","(trigger_module)"],"width":200,"row":0,"col":0,"row_name":"trigger_module_i (trigger_module)","function":"Native component","source":"REUSE; rtl/common/third_party/cva6/core/trigger_module.sv"}],"connectors":[],"externals":[],"interfaces":[],"nets":[],"legend_note":"Exact source-referenced children; generate multiplicity and active branches are specified in the component text. Containment denotes hierarchy, not invented signal connectivity. NEW/MODIFY/REUSE/GENERATED provenance is listed in the block table. Clock/reset follow the common synchronous contract. Complete parent port declarations are in the component section.","library_sha256":"15DFB183E267D2A94F8CAB316E01EB3D2E9D2F9C006DC816790A394F4123506C"}
```

[Editable draw.io](figures/post_a06/csr_regfile.drawio) · [Figure source](figures/post_a06/csr_regfile.json).

**Interface and flow.** Keep native typed request/response records and source ordering. The parent wrapper owns translation to VLSIT flat ports. Exact port declarations:

| Direction | Exact source declaration |
|---|---|
| input | `logic clk_i` |
| input | `logic rst_ni` |
| input | `logic time_irq_i` |
| input | `logic s_time_irq_i` |
| output | `logic flush_o` |
| output | `logic halt_csr_o` |
| input | `scoreboard_entry_t commit_instr_i` |
| input | `logic [CVA6Cfg.NrCommitPorts-1:0] commit_ack_i` |
| input | `logic [CVA6Cfg.VLEN-1:0] boot_addr_i` |
| input | `logic [CVA6Cfg.XLEN-1:0] hart_id_i` |
| input | `exception_t ex_i` |
| input | `logic maintenance_fault_i` |
| input | `fu_op csr_op_i` |
| input | `logic [11:0] csr_addr_i` |
| input | `logic [CVA6Cfg.XLEN-1:0] csr_wdata_i` |
| output | `logic [CVA6Cfg.XLEN-1:0] csr_rdata_o` |
| input | `logic dirty_fp_state_i` |
| input | `logic csr_write_fflags_i` |
| input | `logic dirty_v_state_i` |
| input | `logic [CVA6Cfg.VLEN-1:0] pc_i` |
| output | `exception_t csr_exception_o` |
| output | `logic [CVA6Cfg.VLEN-1:0] epc_o` |
| output | `logic eret_o` |
| output | `logic [CVA6Cfg.VLEN-1:0] trap_vector_base_o` |
| output | `riscv::priv_lvl_t priv_lvl_o` |
| output | `logic mbe_o` |
| output | `logic v_o` |
| input | `logic [4:0] acc_fflags_ex_i` |
| input | `logic acc_fflags_ex_valid_i` |
| output | `riscv::xs_t fs_o` |
| output | `riscv::xs_t vfs_o` |
| output | `logic [4:0] fflags_o` |
| output | `logic [2:0] frm_o` |
| output | `logic [6:0] fprec_o` |
| output | `riscv::xs_t vs_o` |
| output | `irq_ctrl_t irq_ctrl_o` |
| output | `logic en_translation_o` |
| output | `logic en_g_translation_o` |
| output | `logic en_ld_st_translation_o` |
| output | `logic en_ld_st_g_translation_o` |
| output | `riscv::priv_lvl_t ld_st_priv_lvl_o` |
| output | `logic ld_st_v_o` |
| input | `logic csr_hs_ld_st_inst_i` |
| output | `logic sum_o` |
| output | `logic vs_sum_o` |
| output | `logic mxr_o` |
| output | `logic vmxr_o` |
| output | `logic [CVA6Cfg.PPNW-1:0] satp_ppn_o` |
| output | `logic [CVA6Cfg.ASID_WIDTH-1:0] asid_o` |
| output | `logic [CVA6Cfg.PPNW-1:0] vsatp_ppn_o` |
| output | `logic [CVA6Cfg.ASID_WIDTH-1:0] vs_asid_o` |
| output | `logic [CVA6Cfg.PPNW-1:0] hgatp_ppn_o` |
| output | `logic [CVA6Cfg.VMID_WIDTH-1:0] vmid_o` |
| output | `riscv::cbie_t mcbie_o` |
| output | `riscv::cbie_t scbie_o` |
| output | `riscv::cbie_t hcbie_o` |
| output | `logic mcbcfe_o` |
| output | `logic scbcfe_o` |
| output | `logic hcbcfe_o` |
| input | `logic [1:0] irq_i` |
| input | `logic ipi_i` |
| input | `logic s_ipi_i` |
| input | `logic debug_req_i` |
| output | `logic set_debug_pc_o` |
| output | `logic tvm_o` |
| output | `logic tw_o` |
| output | `logic vtw_o` |
| output | `logic tsr_o` |
| output | `logic hu_o` |
| output | `logic debug_mode_o` |
| output | `logic single_step_o` |
| output | `logic icache_en_o` |
| output | `logic dcache_en_o` |
| output | `logic dcache_scrub_en_o` |
| output | `logic [5:0] dcache_scrub_period_o` |
| input | `logic dcache_scrub_cycle_i` |
| input | `logic dcache_dat_cor_err_i` |
| input | `logic dcache_dat_unc_err_i` |
| input | `logic dcache_dir_cor_err_i` |
| input | `logic dcache_dir_unc_err_i` |
| output | `logic acc_cons_en_o` |
| output | `logic [11:0] perf_addr_o` |
| output | `logic [CVA6Cfg.XLEN-1:0] perf_data_o` |
| input | `logic [CVA6Cfg.XLEN-1:0] perf_data_i` |
| output | `logic perf_we_o` |
| output | `riscv::pmpcfg_t [avoid_neg(CVA6Cfg.NrPMPEntries-1):0] pmpcfg_o` |
| output | `logic [avoid_neg(CVA6Cfg.NrPMPEntries-1):0][CVA6Cfg.PLEN-3:0] pmpaddr_o` |
| output | `logic [31:0] mcountinhibit_o` |
| output | `rvfi_probes_csr_t rvfi_csr_o` |
| output | `jvt_t jvt_o` |
| input | `logic [CVA6Cfg.VLEN-1:0] sdtrig_lsu_inputs_vaddr_i` |
| input | `logic [CVA6Cfg.XLEN-1:0] sdtrig_lsu_inputs_data_i` |
| input | `logic sdtrig_lsu_inputs_fu_i` |
| input | `logic sdtrig_lsu_inputs_valid_i` |
| input | `logic [CVA6Cfg.XLEN-1:0] sdtrig_load_data_i` |
| input | `logic sdtrig_load_valid_i` |
| output | `logic sdtrig_load_stall_o` |
| output | `logic sdtrig_load_cancel_o` |
| output | `logic [CVA6Cfg.XLEN-1:0] sdtrig_load_action_o` |
| output | `logic sdtrig_store_stall_o` |
| output | `logic [CVA6Cfg.XLEN-1:0] sdtrig_store_action_o` |
| input | `logic [CVA6Cfg.NrIssuePorts-1:0][CVA6Cfg.VLEN-1:0] fetch_sdtrig_pc_i` |
| input | `logic [CVA6Cfg.NrIssuePorts-1:0][31:0] fetch_sdtrig_instr_i` |
| output | `logic [CVA6Cfg.XLEN-1:0] sdtrig_decoder_action_o[CVA6Cfg.NrIssuePorts]` |
| output | `logic sdtrig_commit_icount_valid_o` |
| output | `logic [$clog2(CVA6Cfg.NrCommitPorts)-1:0] sdtrig_commit_icount_nr_instr_o` |
| output | `logic [CVA6Cfg.XLEN-1:0] sdtrig_commit_action_o` |
| output | `logic sdtrig_commit_std_exception_valid_o` |

**Recorded local changes (source history, not a substitute for the current contract):**
- Added supervisor software and timer interrupt inputs to the effective MIP view. Retained software-writable SSIP/STIP state independently from external levels. Gate SSIP by RVS/SoftwareInterruptEn and STIP by RVS.
- Separate CSR write payload from access/control decode to remove retirement feedback.
- Size CSR read/write fields and counter indices; initialize the complete exception record.
- Make destination-width extension and truncation explicit at RTL assignments.
- DEC-030/031: retain FENCE.I through coherent clean completion and precise fault. Change: Distinguish cause 24 from DEBUG_REQUEST; allow cause-24 delegation and normal trap CSRs.

**State/verification.** Native state encodings and helper logic remain source-owned. Coherence/maintenance-relevant state machines are discussed in Section 10; native arithmetic/MMU/helper integration is linted, with only the specific activated CPU/FPU cases described in Section 15. No blanket ISA/FP/MMU or helper-equivalence qualification is claimed.

#### 14.5.37 `cva6.sv` — MODIFY

Source: [rtl/common/modified/cva6/core/cva6.sv](../../rtl/modified/cva6/core/cva6.sv).

**Function and local effect.** Native CPU integration boundary. Connect boot/IRQ/debug, retained maintenance command/completion, trap state, source event taps and cache-coherence query/probe/flush status without replacing the CPU architecture.

![cva6 selected modified component](figures/post_a06/cva6.svg)

```json
{"page_name":"BLOCK_DIAGRAM","out_name":"cva6.drawio","layout":{"gap_h":120,"gap_v":110,"margin":80,"block_h":60},"top":{"frame_label":["Component composition","(cva6)"]},"frame_row":["cva6","Native modified component; function and change contract are specified in Section 14.","rtl/common/modified/cva6/core/cva6.sv"],"frame_interfaces":[],"blocks":[{"key":"B0","label":["i_acc_dispatcher","(acc_dispatcher)"],"width":200,"row":0,"col":0,"row_name":"i_acc_dispatcher (acc_dispatcher)","function":"Native component","source":"REUSE; rtl/common/third_party/cva6/core/acc_dispatcher.sv"},{"key":"B1","label":["commit_stage_i","(commit_stage)"],"width":180,"row":0,"col":1,"row_name":"commit_stage_i (commit_stage)","function":"Precise retirement and completion","source":"MODIFY; rtl/common/modified/cva6/core/commit_stage.sv"},{"key":"B2","label":["controller_i","(controller)"],"width":140,"row":0,"col":2,"row_name":"controller_i (controller)","function":"Pipeline flush and fence coordination","source":"MODIFY; rtl/common/modified/cva6/core/controller.sv"},{"key":"B3","label":["csr_regfile_i","(csr_regfile)"],"width":160,"row":1,"col":0,"row_name":"csr_regfile_i (csr_regfile)","function":"Privilege, delegation and trap state","source":"MODIFY; rtl/common/modified/cva6/core/csr_regfile.sv"},{"key":"B4","label":["i_pc_fifo","(cva6_fifo_v3)"],"width":180,"row":1,"col":1,"row_name":"i_pc_fifo (cva6_fifo_v3)","function":"Native component","source":"MODIFY; rtl/common/modified/cva6/core/cva6_fifo_v3.sv"},{"key":"B5","label":["i_cache_subsystem","(cva6_hpdcache_subsystem)"],"width":300,"row":1,"col":2,"row_name":"i_cache_subsystem (cva6_hpdcache_subsystem)","function":"Cache subsystem integration","source":"MODIFY; rtl/common/modified/cva6/core/cache_subsystem/cva6_hpdcache_subsystem.sv"},{"key":"B6","label":["i_cva6_rvfi_probes","(cva6_rvfi_probes)"],"width":220,"row":2,"col":0,"row_name":"i_cva6_rvfi_probes (cva6_rvfi_probes)","function":"Native component","source":"REUSE; rtl/common/third_party/cva6/core/cva6_rvfi_probes.sv"},{"key":"B7","label":["ex_stage_i","(ex_stage)"],"width":120,"row":2,"col":1,"row_name":"ex_stage_i (ex_stage)","function":"Native component","source":"MODIFY; rtl/common/modified/cva6/core/ex_stage.sv"},{"key":"B8","label":["i_frontend","(frontend)"],"width":120,"row":2,"col":2,"row_name":"i_frontend (frontend)","function":"Native component","source":"REUSE; rtl/common/third_party/cva6/core/frontend/frontend.sv"},{"key":"B9","label":["id_stage_i","(id_stage)"],"width":120,"row":3,"col":0,"row_name":"id_stage_i (id_stage)","function":"Native component","source":"REUSE; rtl/common/third_party/cva6/core/id_stage.sv"},{"key":"B10","label":["instr_tracer_i","(instr_tracer)"],"width":180,"row":3,"col":1,"row_name":"instr_tracer_i (instr_tracer)","function":"Native component","source":"REUSE; verification/common/third_party/cva6/common/local/util/instr_tracer.sv"},{"key":"B11","label":["issue_stage_i","(issue_stage)"],"width":160,"row":3,"col":2,"row_name":"issue_stage_i (issue_stage)","function":"Native component","source":"REUSE; rtl/common/third_party/cva6/core/issue_stage.sv"},{"key":"B12","label":["perf_counters_i","(perf_counters)"],"width":180,"row":4,"col":0,"row_name":"perf_counters_i (perf_counters)","function":"Native CPU event taps","source":"MODIFY; rtl/common/modified/cva6/core/perf_counters.sv"},{"key":"B13","label":["i_rr_arb_tree","(rr_arb_tree)"],"width":160,"row":4,"col":1,"row_name":"i_rr_arb_tree (rr_arb_tree)","function":"Native component","source":"MODIFY; rtl/common/modified/cva6/vendor/pulp-platform/common_cells/src/rr_arb_tree.sv"},{"key":"B14","label":["i_cache_subsystem","(std_cache_subsystem)"],"width":260,"row":4,"col":2,"row_name":"i_cache_subsystem (std_cache_subsystem)","function":"Native component","source":"REUSE; rtl/common/third_party/cva6/core/cache_subsystem/std_cache_subsystem.sv"},{"key":"B15","label":["i_cache_subsystem","(wt_cache_subsystem)"],"width":240,"row":5,"col":0,"row_name":"i_cache_subsystem (wt_cache_subsystem)","function":"Native component","source":"MODIFY; rtl/common/modified/cva6/core/cache_subsystem/wt_cache_subsystem.sv"}],"connectors":[],"externals":[],"interfaces":[],"nets":[],"legend_note":"Exact source-referenced children; generate multiplicity and active branches are specified in the component text. Containment denotes hierarchy, not invented signal connectivity. NEW/MODIFY/REUSE/GENERATED provenance is listed in the block table. Clock/reset follow the common synchronous contract. Complete parent port declarations are in the component section.","library_sha256":"15DFB183E267D2A94F8CAB316E01EB3D2E9D2F9C006DC816790A394F4123506C"}
```

[Editable draw.io](figures/post_a06/cva6.drawio) · [Figure source](figures/post_a06/cva6.json).

**Interface and flow.** Keep native typed request/response records and source ordering. The parent wrapper owns translation to VLSIT flat ports. Exact port declarations:

| Direction | Exact source declaration |
|---|---|
| input | `logic clk_i` |
| input | `logic rst_ni` |
| input | `logic [CVA6Cfg.VLEN-1:0] boot_addr_i` |
| input | `logic [CVA6Cfg.XLEN-1:0] hart_id_i` |
| input | `logic [1:0] irq_i` |
| input | `logic ipi_i` |
| input | `logic time_irq_i` |
| input | `logic s_ipi_i` |
| input | `logic s_time_irq_i` |
| input | `logic debug_req_i` |
| output | `logic [21:0] perf_event_o` |
| output | `logic [15:0] hpdcache_perf_event_o` |
| output | `logic debug_mode_o` |
| output | `logic dcache_flush_ack_valid_o` |
| output | `logic [CVA6Cfg.PLEN-4-1:0] dcache_flush_ack_nline_o` |
| output | `logic [1:0] dcache_flush_ack_origin_o` |
| output | `logic dcache_flush_ack_error_o` |
| output | `logic dcache_flush_rsp_invalid_o` |
| input | `logic dcache_probe_query_valid_i` |
| input | `logic [CVA6Cfg.PLEN-4-1:0] dcache_probe_query_nline_i` |
| output | `logic dcache_probe_line_busy_o` |
| output | `logic dcache_access_line_valid_o` |
| output | `logic [CVA6Cfg.PLEN-4-1:0] dcache_access_nline_o` |
| output | `logic dcache_victim_line_valid_o` |
| output | `logic [CVA6Cfg.PLEN-4-1:0] dcache_victim_nline_o` |
| input | `logic [15:0] dcache_coh_lock_valid_i` |
| input | `logic [15:0][CVA6Cfg.PLEN-4-1:0] dcache_coh_lock_nline_i` |
| input | `logic dcache_probe_req_valid_i` |
| output | `logic dcache_probe_req_ready_o` |
| input | `logic [3:0] dcache_probe_req_tag_i` |
| input | `logic [CVA6Cfg.PLEN-4-1:0] dcache_probe_req_nline_i` |
| input | `logic [1:0] dcache_probe_req_phase_i` |
| input | `logic [1:0] dcache_probe_req_target_state_i` |
| input | `logic dcache_probe_req_wback_en_i` |
| output | `logic dcache_probe_rsp_valid_o` |
| input | `logic dcache_probe_rsp_ready_i` |
| output | `logic [3:0] dcache_probe_rsp_tag_o` |
| output | `logic [CVA6Cfg.PLEN-4-1:0] dcache_probe_rsp_nline_o` |
| output | `logic [1:0] dcache_probe_rsp_phase_o` |
| output | `logic [1:0] dcache_probe_rsp_state_o` |
| output | `logic dcache_probe_rsp_error_o` |
| output | `logic dcache_probe_rsp_wback_done_o` |
| output | `logic cmo_valid_o` |
| input | `logic cmo_ready_i` |
| output | `logic [1:0] cmo_op_o` |
| output | `logic [CVA6Cfg.PLEN-5:0] cmo_pa_line_o` |
| output | `logic [CVA6Cfg.VLEN-1:0] cmo_vaddr_o` |
| output | `logic [CVA6Cfg.VLEN-1:0] cmo_pc_o` |
| input | `logic cmo_done_i` |
| input | `logic cmo_error_i` |
| output | `logic cmo_entry_valid_o` |
| output | `cbo_t cmo_entry_op_o` |
| output | `logic [CVA6Cfg.PLEN-4-1:0] cmo_entry_pa_line_o` |
| output | `logic [CVA6Cfg.VLEN-1:0] cmo_entry_vaddr_o` |
| output | `logic dcache_own_req_valid_o` |
| input | `logic dcache_own_req_ready_i` |
| output | `logic [2:0] dcache_own_req_id_o` |
| output | `logic [CVA6Cfg.PLEN-4-1:0] dcache_own_req_nline_o` |
| output | `logic [1:0] dcache_own_req_kind_o` |
| input | `logic dcache_own_gnt_valid_i` |
| output | `logic dcache_own_gnt_ready_o` |
| input | `logic [2:0] dcache_own_gnt_id_i` |
| input | `logic [CVA6Cfg.PLEN-4-1:0] dcache_own_gnt_nline_i` |
| input | `logic [1:0] dcache_own_gnt_state_i` |
| input | `logic dcache_own_gnt_error_i` |
| output | `rvfi_probes_t rvfi_probes_o` |
| output | `cvxif_req_t cvxif_req_o` |
| input | `cvxif_resp_t cvxif_resp_i` |
| output | `noc_req_t noc_req_o` |
| input | `noc_resp_t noc_resp_i` |

**Recorded local changes (source history, not a substitute for the current contract):**
- Added the internal 22-bit PMU event tap; ties it low when performance counters are disabled. Added supervisor software and timer interrupt inputs for the selected cluster interrupt map.
- Exported architectural debug mode for the per-hart cluster status port.
- Route the native HPDcache PREPARE/COMMIT/ABORT request and response path. Exported matched HPDcache flush B-response metadata for CCU integration.
- Route an exact-line HPDcache MSHR/refill busy query through the tile boundary.
- Route tagged CCU line-lock vectors through the selected HPDcache subsystem.
- Route the cache-side two-phase probe endpoint through CVA6 and HPDcache.
- Export HPDcache ownership requests and matching CCU grants so cacheable refill reads wait for permission before issuing AXI AR.
- Export HPDcache Stage-1 access and selected victim line observations.
- Export native HPDcache PMU events to the cluster tile boundary.
- Export the oldest pending CBO operation, physical line, and original virtual address. `include "rvfi_types.svh" `include "cvxif_types.svh"
- Route the staged ExternalCmo retirement mode through the LSU hierarchy; external completion dequeues CBO without a duplicate local cache request.
- Make the diagnostic trace-mode temporary lifetime explicit.
- DEC-030/031: retain FENCE.I through coherent clean completion and precise fault. Change: Connect whole-cache walker, per-line CCU service and maintenance-fault provenance.
- DEC-038/A-02: preserve cached atomic errors and precise retirement fault state.

**State/verification.** Native state encodings and helper logic remain source-owned. Coherence/maintenance-relevant state machines are discussed in Section 10; native arithmetic/MMU/helper integration is linted, with only the specific activated CPU/FPU cases described in Section 15. No blanket ISA/FP/MMU or helper-equivalence qualification is claimed.

#### 14.5.38 `cva6_fifo_v3.sv` — MODIFY

Source: [rtl/common/modified/cva6/core/cva6_fifo_v3.sv](../../rtl/modified/cva6/core/cva6_fifo_v3.sv).

**Function and local effect.** Native cva6 fifo v3 component. Preserve the native request/result or storage behavior while applying the explicit local changes recorded below. Its parent consumes the exact typed interfaces in this section; queue, arithmetic, memory and protocol helpers do not create new architectural ownership rules. Native latency/ordering remains source-defined and is not independently qualified by TOP lint.

![cva6_fifo_v3 selected modified component](figures/post_a06/cva6_fifo_v3.svg)

```json
{"page_name":"BLOCK_DIAGRAM","out_name":"cva6_fifo_v3.drawio","layout":{"gap_h":120,"gap_v":110,"margin":80,"block_h":60},"top":{"frame_label":["Component composition","(cva6_fifo_v3)"]},"frame_row":["cva6_fifo_v3","Native modified component; function and change contract are specified in Section 14.","rtl/common/modified/cva6/core/cva6_fifo_v3.sv"],"frame_interfaces":[],"blocks":[{"key":"B0","label":["fifo_ram","(AsyncDpRam)"],"width":140,"row":0,"col":0,"row_name":"fifo_ram (AsyncDpRam)","function":"Native component","source":"REUSE; rtl/common/third_party/cva6/vendor/pulp-platform/fpga-support/rtl/AsyncDpRam.sv"},{"key":"B1","label":["fifo_ram","(SyncDpRam_ind_r_w)"],"width":220,"row":1,"col":0,"row_name":"fifo_ram (SyncDpRam_ind_r_w)","function":"Native component","source":"REUSE; rtl/common/third_party/cva6/vendor/pulp-platform/fpga-support/rtl/SyncDpRam_ind_r_w.sv"}],"connectors":[],"externals":[],"interfaces":[],"nets":[],"legend_note":"Exact source-referenced children; generate multiplicity and active branches are specified in the component text. Containment denotes hierarchy, not invented signal connectivity. NEW/MODIFY/REUSE/GENERATED provenance is listed in the block table. Clock/reset follow the common synchronous contract. Complete parent port declarations are in the component section.","library_sha256":"15DFB183E267D2A94F8CAB316E01EB3D2E9D2F9C006DC816790A394F4123506C"}
```

[Editable draw.io](figures/post_a06/cva6_fifo_v3.drawio) · [Figure source](figures/post_a06/cva6_fifo_v3.json).

**Interface and flow.** Keep native typed request/response records and source ordering. The parent wrapper owns translation to VLSIT flat ports. Exact port declarations:

| Direction | Exact source declaration |
|---|---|
| input | `logic clk_i` |
| input | `logic rst_ni` |
| input | `logic flush_i` |
| input | `logic testmode_i` |
| output | `logic full_o` |
| output | `logic empty_o` |
| output | `logic [ADDR_DEPTH-1:0] usage_o` |
| input | `dtype data_i` |
| input | `logic push_i` |
| output | `dtype data_o` |
| input | `logic pop_i` |

**Recorded local changes (source history, not a substitute for the current contract):**
- Default combinational temporaries to remove inferred storage in ASIC configuration.

**State/verification.** Native state encodings and helper logic remain source-owned. Coherence/maintenance-relevant state machines are discussed in Section 10; native arithmetic/MMU/helper integration is linted, with only the specific activated CPU/FPU cases described in Section 15. No blanket ISA/FP/MMU or helper-equivalence qualification is claimed.

#### 14.5.39 `cva6_mmu.sv` — MODIFY

Source: [rtl/common/modified/cva6/core/cva6_mmu/cva6_mmu.sv](../../rtl/modified/cva6/core/cva6_mmu/cva6_mmu.sv).

**Function and local effect.** Memory Management Unit for CVA6, contains TLB and. Preserve the native request/result or storage behavior while applying the explicit local changes recorded below. Its parent consumes the exact typed interfaces in this section; queue, arithmetic, memory and protocol helpers do not create new architectural ownership rules. Native latency/ordering remains source-defined and is not independently qualified by TOP lint.

![cva6_mmu selected modified component](figures/post_a06/cva6_mmu.svg)

```json
{"page_name":"BLOCK_DIAGRAM","out_name":"cva6_mmu.drawio","layout":{"gap_h":120,"gap_v":110,"margin":80,"block_h":60},"top":{"frame_label":["Component composition","(cva6_mmu)"]},"frame_row":["cva6_mmu","Native modified component; function and change contract are specified in Section 14.","rtl/common/modified/cva6/core/cva6_mmu/cva6_mmu.sv"],"frame_interfaces":[],"blocks":[{"key":"B0","label":["i_ptw","(cva6_ptw)"],"width":120,"row":0,"col":0,"row_name":"i_ptw (cva6_ptw)","function":"Native component","source":"REUSE; rtl/common/third_party/cva6/core/cva6_mmu/cva6_ptw.sv"},{"key":"B1","label":["i_shared_tlb","(cva6_shared_tlb)"],"width":200,"row":0,"col":1,"row_name":"i_shared_tlb (cva6_shared_tlb)","function":"Native component","source":"MODIFY; rtl/common/modified/cva6/core/cva6_mmu/cva6_shared_tlb.sv"},{"key":"B2","label":["i_dtlb","(cva6_tlb)"],"width":120,"row":1,"col":0,"row_name":"i_dtlb (cva6_tlb)","function":"Native component","source":"MODIFY; rtl/common/modified/cva6/core/cva6_mmu/cva6_tlb.sv"},{"key":"B3","label":["i_itlb","(cva6_tlb)"],"width":120,"row":1,"col":1,"row_name":"i_itlb (cva6_tlb)","function":"Native component","source":"MODIFY; rtl/common/modified/cva6/core/cva6_mmu/cva6_tlb.sv"}],"connectors":[],"externals":[],"interfaces":[],"nets":[],"legend_note":"Exact source-referenced children; generate multiplicity and active branches are specified in the component text. Containment denotes hierarchy, not invented signal connectivity. NEW/MODIFY/REUSE/GENERATED provenance is listed in the block table. Clock/reset follow the common synchronous contract. Complete parent port declarations are in the component section.","library_sha256":"15DFB183E267D2A94F8CAB316E01EB3D2E9D2F9C006DC816790A394F4123506C"}
```

[Editable draw.io](figures/post_a06/cva6_mmu.drawio) · [Figure source](figures/post_a06/cva6_mmu.json).

**Interface and flow.** Keep native typed request/response records and source ordering. The parent wrapper owns translation to VLSIT flat ports. Exact port declarations:

| Direction | Exact source declaration |
|---|---|
| input | `logic clk_i` |
| input | `logic rst_ni` |
| input | `logic flush_i` |
| input | `logic enable_translation_i` |
| input | `logic enable_g_translation_i` |
| input | `logic en_ld_st_translation_i` |
| input | `logic en_ld_st_g_translation_i` |
| input | `icache_arsp_t icache_areq_i` |
| output | `icache_areq_t icache_areq_o` |
| input | `exception_t misaligned_ex_i` |
| input | `logic lsu_req_i` |
| input | `logic [CVA6Cfg.VLEN-1:0] lsu_vaddr_i` |
| input | `logic [31:0] lsu_tinst_i` |
| input | `logic lsu_is_store_i` |
| output | `logic csr_hs_ld_st_inst_o` |
| output | `logic lsu_dtlb_hit_o` |
| output | `logic [CVA6Cfg.PPNW-1:0] lsu_dtlb_ppn_o` |
| output | `logic lsu_valid_o` |
| output | `logic [CVA6Cfg.PLEN-1:0] lsu_paddr_o` |
| output | `logic [CVA6Cfg.VLEN-1:0] lsu_vaddr_o` |
| output | `logic lsu_is_store_o` |
| output | `logic lsu_hlvx_inst_o` |
| output | `exception_t lsu_exception_o` |
| input | `riscv::priv_lvl_t priv_lvl_i` |
| input | `logic v_i` |
| input | `riscv::priv_lvl_t ld_st_priv_lvl_i` |
| input | `logic ld_st_v_i` |
| input | `logic sum_i` |
| input | `logic vs_sum_i` |
| input | `logic mxr_i` |
| input | `logic vmxr_i` |
| input | `logic mbe_i` |
| input | `logic hlvx_inst_i` |
| input | `logic hs_ld_st_inst_i` |
| input | `logic [CVA6Cfg.PPNW-1:0] satp_ppn_i` |
| input | `logic [CVA6Cfg.PPNW-1:0] vsatp_ppn_i` |
| input | `logic [CVA6Cfg.PPNW-1:0] hgatp_ppn_i` |
| input | `logic [CVA6Cfg.ASID_WIDTH-1:0] asid_i` |
| input | `logic [CVA6Cfg.ASID_WIDTH-1:0] vs_asid_i` |
| input | `logic [CVA6Cfg.ASID_WIDTH-1:0] asid_to_be_flushed_i` |
| input | `logic [CVA6Cfg.VMID_WIDTH-1:0] vmid_i` |
| input | `logic [CVA6Cfg.VMID_WIDTH-1:0] vmid_to_be_flushed_i` |
| input | `logic [CVA6Cfg.VLEN-1:0] vaddr_to_be_flushed_i` |
| input | `logic [CVA6Cfg.GPLEN-1:0] gpaddr_to_be_flushed_i` |
| input | `logic flush_tlb_i` |
| input | `logic flush_tlb_vvma_i` |
| input | `logic flush_tlb_gvma_i` |
| output | `logic shared_tlb_flush_busy_o` |
| output | `logic itlb_miss_o` |
| output | `logic dtlb_miss_o` |
| input | `dcache_req_o_t req_port_i` |
| output | `dcache_req_i_t req_port_o` |
| input | `riscv::pmpcfg_t [avoid_neg(CVA6Cfg.NrPMPEntries-1):0] pmpcfg_i` |
| input | `logic [avoid_neg(CVA6Cfg.NrPMPEntries-1):0][CVA6Cfg.PLEN-3:0] pmpaddr_i` |

**Recorded local changes (source history, not a substitute for the current contract):**
- Default combinational temporaries to remove inferred storage in ASIC configuration.

**State/verification.** Native state encodings and helper logic remain source-owned. Coherence/maintenance-relevant state machines are discussed in Section 10; native arithmetic/MMU/helper integration is linted, with only the specific activated CPU/FPU cases described in Section 15. No blanket ISA/FP/MMU or helper-equivalence qualification is claimed.

#### 14.5.40 `cva6_shared_tlb.sv` — MODIFY

Source: [rtl/common/modified/cva6/core/cva6_mmu/cva6_shared_tlb.sv](../../rtl/modified/cva6/core/cva6_mmu/cva6_shared_tlb.sv).

**Function and local effect.** N-way associative shared TLB, it allows to reduce the number. Preserve the native request/result or storage behavior while applying the explicit local changes recorded below. Its parent consumes the exact typed interfaces in this section; queue, arithmetic, memory and protocol helpers do not create new architectural ownership rules. Native latency/ordering remains source-defined and is not independently qualified by TOP lint.

![cva6_shared_tlb selected modified component](figures/post_a06/cva6_shared_tlb.svg)

```json
{"page_name":"BLOCK_DIAGRAM","out_name":"cva6_shared_tlb.drawio","layout":{"gap_h":120,"gap_v":110,"margin":80,"block_h":60},"top":{"frame_label":["Component composition","(cva6_shared_tlb)"]},"frame_row":["cva6_shared_tlb","Native modified component; function and change contract are specified in Section 14.","rtl/common/modified/cva6/core/cva6_mmu/cva6_shared_tlb.sv"],"frame_interfaces":[],"blocks":[{"key":"B0","label":["i_lfsr","(lfsr)"],"width":80,"row":0,"col":0,"row_name":"i_lfsr (lfsr)","function":"Native component","source":"MODIFY; rtl/common/modified/cva6/vendor/pulp-platform/common_cells/src/lfsr.sv"},{"key":"B1","label":["i_lzc","(lzc)"],"width":60,"row":0,"col":1,"row_name":"i_lzc (lzc)","function":"Native component","source":"REUSE; rtl/common/third_party/cva6/vendor/pulp-platform/common_cells/src/lzc.sv"},{"key":"B2","label":["pte_sram","(sram)"],"width":100,"row":1,"col":0,"row_name":"pte_sram (sram)","function":"Native component","source":"MODIFY; rtl/common/modified/cva6/common/local/util/sram.sv"},{"key":"B3","label":["tag_sram","(sram)"],"width":100,"row":1,"col":1,"row_name":"tag_sram (sram)","function":"Native component","source":"MODIFY; rtl/common/modified/cva6/common/local/util/sram.sv"}],"connectors":[],"externals":[],"interfaces":[],"nets":[],"legend_note":"Exact source-referenced children; generate multiplicity and active branches are specified in the component text. Containment denotes hierarchy, not invented signal connectivity. NEW/MODIFY/REUSE/GENERATED provenance is listed in the block table. Clock/reset follow the common synchronous contract. Complete parent port declarations are in the component section.","library_sha256":"15DFB183E267D2A94F8CAB316E01EB3D2E9D2F9C006DC816790A394F4123506C"}
```

[Editable draw.io](figures/post_a06/cva6_shared_tlb.drawio) · [Figure source](figures/post_a06/cva6_shared_tlb.json).

**Interface and flow.** Keep native typed request/response records and source ordering. The parent wrapper owns translation to VLSIT flat ports. Exact port declarations:

| Direction | Exact source declaration |
|---|---|
| input | `logic clk_i` |
| input | `logic rst_ni` |
| input | `logic flush_i` |
| input | `logic flush_vvma_i` |
| input | `logic flush_gvma_i` |
| input | `logic s_st_enbl_i` |
| input | `logic g_st_enbl_i` |
| input | `logic v_i` |
| input | `logic s_ld_st_enbl_i` |
| input | `logic g_ld_st_enbl_i` |
| input | `logic ld_st_v_i` |
| input | `logic [CVA6Cfg.ASID_WIDTH-1:0] dtlb_asid_i` |
| input | `logic [CVA6Cfg.ASID_WIDTH-1:0] itlb_asid_i` |
| input | `logic [CVA6Cfg.VMID_WIDTH-1:0] lu_vmid_i` |
| input | `logic itlb_access_i` |
| input | `logic itlb_hit_i` |
| input | `logic [CVA6Cfg.VLEN-1:0] itlb_vaddr_i` |
| input | `logic dtlb_access_i` |
| input | `logic dtlb_hit_i` |
| input | `logic [CVA6Cfg.VLEN-1:0] dtlb_vaddr_i` |
| input | `logic shared_tlb_miss_i` |
| input | `logic [CVA6Cfg.ASID_WIDTH-1:0] asid_to_be_flushed_i` |
| input | `logic [CVA6Cfg.VLEN-1:0] vaddr_to_be_flushed_i` |
| input | `logic [CVA6Cfg.VMID_WIDTH-1:0] vmid_to_be_flushed_i` |
| input | `logic [CVA6Cfg.GPLEN-1:0] gpaddr_to_be_flushed_i` |
| output | `tlb_update_cva6_t itlb_update_o` |
| output | `tlb_update_cva6_t dtlb_update_o` |
| output | `logic itlb_miss_o` |
| output | `logic dtlb_miss_o` |
| output | `logic flush_busy_o` |
| output | `logic shared_tlb_access_o` |
| output | `logic shared_tlb_hit_o` |
| output | `logic [CVA6Cfg.VLEN-1:0] shared_tlb_vaddr_o` |
| output | `logic itlb_req_o` |
| input | `tlb_update_cva6_t shared_tlb_update_i` |

**Recorded local changes (source history, not a substitute for the current contract):**
- Size guest physical page assignment to the configured translated-address vector.

**State/verification.** Native state encodings and helper logic remain source-owned. Coherence/maintenance-relevant state machines are discussed in Section 10; native arithmetic/MMU/helper integration is linted, with only the specific activated CPU/FPU cases described in Section 15. No blanket ISA/FP/MMU or helper-equivalence qualification is claimed.

#### 14.5.41 `cva6_tlb.sv` — MODIFY

Source: [rtl/common/modified/cva6/core/cva6_mmu/cva6_tlb.sv](../../rtl/modified/cva6/core/cva6_mmu/cva6_tlb.sv).

**Function and local effect.** Translation Lookaside Buffer, parameterizable to Sv32 or Sv39,. Preserve the native request/result or storage behavior while applying the explicit local changes recorded below. Its parent consumes the exact typed interfaces in this section; queue, arithmetic, memory and protocol helpers do not create new architectural ownership rules. Native latency/ordering remains source-defined and is not independently qualified by TOP lint.

![cva6_tlb selected modified component](figures/post_a06/cva6_tlb.svg)

```json
{"page_name":"BLOCK_DIAGRAM","out_name":"cva6_tlb.drawio","layout":{"gap_h":120,"gap_v":110,"margin":80,"block_h":60},"top":{"frame_label":["Component composition","(cva6_tlb)"]},"frame_row":["cva6_tlb","Native modified component; function and change contract are specified in Section 14.","rtl/common/modified/cva6/core/cva6_mmu/cva6_tlb.sv"],"frame_interfaces":["IN","OUT"],"blocks":[{"key":"B0","label":["component_boundary","(cva6_tlb)"],"width":220,"row":0,"col":0,"row_name":"component_boundary (cva6_tlb)","function":"Native component","source":"MODIFY; rtl/common/modified/cva6/core/cva6_mmu/cva6_tlb.sv"}],"connectors":[],"externals":[{"id":"IN","block":"B0","side":"L","dir":"in","pos":0,"text":["IN","ports"]},{"id":"OUT","block":"B0","side":"R","dir":"out","pos":0,"text":["OUT","ports"]}],"interfaces":[{"id":"IN","name":"Parent in ports","category":"custom","active":"in","signals":"clk_i, rst_ni, flush_i, flush_vvma_i, flush_gvma_i, s_st_enbl_i, g_st_enbl_i, v_i, update_i, lu_access_i, lu_asid_i, lu_vmid_i, lu_vaddr_i, asid_to_be_flushed_i, vmid_to_be_flushed_i, vaddr_to_be_flushed_i, gpaddr_to_be_flushed_i"},{"id":"OUT","name":"Parent out ports","category":"custom","active":"out","signals":"lu_gpaddr_o, lu_content_o, lu_g_content_o, lu_is_page_o, lu_hit_o"}],"nets":[],"legend_note":"A single boundary symbol denotes a leaf: internal equations/registers are described in its function/dataflow contract, not invented child modules. NEW/MODIFY/REUSE/GENERATED provenance is listed in the block table. Clock/reset follow the common synchronous contract. Complete parent port declarations are in the component section.","library_sha256":"15DFB183E267D2A94F8CAB316E01EB3D2E9D2F9C006DC816790A394F4123506C"}
```

[Editable draw.io](figures/post_a06/cva6_tlb.drawio) · [Figure source](figures/post_a06/cva6_tlb.json).

**Interface and flow.** Keep native typed request/response records and source ordering. The parent wrapper owns translation to VLSIT flat ports. Exact port declarations:

| Direction | Exact source declaration |
|---|---|
| input | `logic clk_i` |
| input | `logic rst_ni` |
| input | `logic flush_i` |
| input | `logic flush_vvma_i` |
| input | `logic flush_gvma_i` |
| input | `logic s_st_enbl_i` |
| input | `logic g_st_enbl_i` |
| input | `logic v_i` |
| input | `tlb_update_cva6_t update_i` |
| input | `logic lu_access_i` |
| input | `logic [CVA6Cfg.ASID_WIDTH-1:0] lu_asid_i` |
| input | `logic [CVA6Cfg.VMID_WIDTH-1:0] lu_vmid_i` |
| input | `logic [CVA6Cfg.VLEN-1:0] lu_vaddr_i` |
| output | `logic [CVA6Cfg.GPLEN-1:0] lu_gpaddr_o` |
| output | `pte_cva6_t lu_content_o` |
| output | `pte_cva6_t lu_g_content_o` |
| input | `logic [CVA6Cfg.ASID_WIDTH-1:0] asid_to_be_flushed_i` |
| input | `logic [CVA6Cfg.VMID_WIDTH-1:0] vmid_to_be_flushed_i` |
| input | `logic [CVA6Cfg.VLEN-1:0] vaddr_to_be_flushed_i` |
| input | `logic [CVA6Cfg.GPLEN-1:0] gpaddr_to_be_flushed_i` |
| output | `logic [CVA6Cfg.PtLevels-2:0] lu_is_page_o` |
| output | `logic lu_hit_o` |

**Recorded local changes (source history, not a substitute for the current contract):**
- Default combinational temporaries to remove inferred storage in ASIC configuration.
- Make destination-width extension and truncation explicit at RTL assignments.

**State/verification.** Native state encodings and helper logic remain source-owned. Coherence/maintenance-relevant state machines are discussed in Section 10; native arithmetic/MMU/helper integration is linted, with only the specific activated CPU/FPU cases described in Section 15. No blanket ISA/FP/MMU or helper-equivalence qualification is claimed.

#### 14.5.42 `decoder.sv` — MODIFY

Source: [rtl/common/modified/cva6/core/decoder.sv](../../rtl/modified/cva6/core/decoder.sv).

**Function and local effect.** Issues instruction from the scoreboard and fetches the operands. Preserve the native request/result or storage behavior while applying the explicit local changes recorded below. Its parent consumes the exact typed interfaces in this section; queue, arithmetic, memory and protocol helpers do not create new architectural ownership rules. Native latency/ordering remains source-defined and is not independently qualified by TOP lint.

![decoder selected modified component](figures/post_a06/decoder.svg)

```json
{"page_name":"BLOCK_DIAGRAM","out_name":"decoder.drawio","layout":{"gap_h":120,"gap_v":110,"margin":80,"block_h":60},"top":{"frame_label":["Component composition","(decoder)"]},"frame_row":["decoder","Native modified component; function and change contract are specified in Section 14.","rtl/common/modified/cva6/core/decoder.sv"],"frame_interfaces":[],"blocks":[{"key":"B0","label":["i_accel_decoder","(cva6_accel_first_pass_decoder)"],"width":360,"row":0,"col":0,"row_name":"i_accel_decoder (cva6_accel_first_pass_decoder)","function":"Native component","source":"REUSE; rtl/common/third_party/cva6/core/cva6_accel_first_pass_decoder_stub.sv"}],"connectors":[],"externals":[],"interfaces":[],"nets":[],"legend_note":"Exact source-referenced children; generate multiplicity and active branches are specified in the component text. Containment denotes hierarchy, not invented signal connectivity. NEW/MODIFY/REUSE/GENERATED provenance is listed in the block table. Clock/reset follow the common synchronous contract. Complete parent port declarations are in the component section.","library_sha256":"15DFB183E267D2A94F8CAB316E01EB3D2E9D2F9C006DC816790A394F4123506C"}
```

[Editable draw.io](figures/post_a06/decoder.drawio) · [Figure source](figures/post_a06/decoder.json).

**Interface and flow.** Keep native typed request/response records and source ordering. The parent wrapper owns translation to VLSIT flat ports. Exact port declarations:

| Direction | Exact source declaration |
|---|---|
| input | `logic debug_req_i` |
| input | `logic [CVA6Cfg.VLEN-1:0] pc_i` |
| input | `logic is_compressed_i` |
| input | `logic [15:0] compressed_instr_i` |
| input | `logic is_illegal_i` |
| input | `logic [31:0] instruction_i` |
| input | `logic is_macro_instr_i` |
| input | `logic is_last_macro_instr_i` |
| input | `logic is_double_rd_macro_instr_i` |
| input | `logic is_zcmt_i` |
| input | `logic [CVA6Cfg.XLEN-1:0] jump_address_i` |
| input | `branchpredict_sbe_t branch_predict_i` |
| input | `exception_t ex_i` |
| input | `logic [1:0] irq_i` |
| input | `irq_ctrl_t irq_ctrl_i` |
| input | `riscv::priv_lvl_t priv_lvl_i` |
| input | `logic v_i` |
| input | `logic debug_mode_i` |
| input | `riscv::xs_t fs_i` |
| input | `riscv::xs_t vfs_i` |
| input | `logic [2:0] frm_i` |
| input | `riscv::xs_t vs_i` |
| input | `logic tvm_i` |
| input | `logic tw_i` |
| input | `logic vtw_i` |
| input | `logic tsr_i` |
| input | `logic hu_i` |
| input | `riscv::cbie_t mcbie_i` |
| input | `riscv::cbie_t scbie_i` |
| input | `riscv::cbie_t hcbie_i` |
| input | `logic mcbcfe_i` |
| input | `logic scbcfe_i` |
| input | `logic hcbcfe_i` |
| output | `scoreboard_entry_t instruction_o` |
| output | `logic [31:0] orig_instr_o` |
| output | `logic is_control_flow_instr_o` |
| input | `logic [CVA6Cfg.XLEN-1:0] sdtrig_decoder_action_i` |

**Recorded local changes (source history, not a substitute for the current contract):**
- Separate decoded exception payload from scoreboard validity; preserve cycle behavior.
- Make destination-width extension and truncation explicit at RTL assignments.

**State/verification.** Native state encodings and helper logic remain source-owned. Coherence/maintenance-relevant state machines are discussed in Section 10; native arithmetic/MMU/helper integration is linted, with only the specific activated CPU/FPU cases described in Section 15. No blanket ISA/FP/MMU or helper-equivalence qualification is claimed.

#### 14.5.43 `ex_stage.sv` — MODIFY

Source: [rtl/common/modified/cva6/core/ex_stage.sv](../../rtl/modified/cva6/core/ex_stage.sv).

**Function and local effect.** Instantiation of all functional units residing in the execute stage. Preserve the native request/result or storage behavior while applying the explicit local changes recorded below. Its parent consumes the exact typed interfaces in this section; queue, arithmetic, memory and protocol helpers do not create new architectural ownership rules. Native latency/ordering remains source-defined and is not independently qualified by TOP lint.

![ex_stage selected modified component](figures/post_a06/ex_stage.svg)

```json
{"page_name":"BLOCK_DIAGRAM","out_name":"ex_stage.drawio","layout":{"gap_h":120,"gap_v":110,"margin":80,"block_h":60},"top":{"frame_label":["Component composition","(ex_stage)"]},"frame_row":["ex_stage","Native modified component; function and change contract are specified in Section 14.","rtl/common/modified/cva6/core/ex_stage.sv"],"frame_interfaces":[],"blocks":[{"key":"B0","label":["aes_i","(aes)"],"width":60,"row":0,"col":0,"row_name":"aes_i (aes)","function":"Native component","source":"MODIFY; rtl/common/modified/cva6/core/aes.sv"},{"key":"B1","label":["alu_wrapper_i","(alu_wrapper)"],"width":160,"row":0,"col":1,"row_name":"alu_wrapper_i (alu_wrapper)","function":"Native component","source":"REUSE; rtl/common/third_party/cva6/core/alu_wrapper.sv"},{"key":"B2","label":["branch_unit_i","(branch_unit)"],"width":160,"row":1,"col":0,"row_name":"branch_unit_i (branch_unit)","function":"Native component","source":"REUSE; rtl/common/third_party/cva6/core/branch_unit.sv"},{"key":"B3","label":["csr_buffer_i","(csr_buffer)"],"width":140,"row":1,"col":1,"row_name":"csr_buffer_i (csr_buffer)","function":"Native component","source":"REUSE; rtl/common/third_party/cva6/core/csr_buffer.sv"},{"key":"B4","label":["cvxif_fu_i","(cvxif_fu)"],"width":120,"row":2,"col":0,"row_name":"cvxif_fu_i (cvxif_fu)","function":"Native component","source":"REUSE; rtl/common/third_party/cva6/core/cvxif_fu.sv"},{"key":"B5","label":["fpu_i","(fpu_wrap)"],"width":120,"row":2,"col":1,"row_name":"fpu_i (fpu_wrap)","function":"FPU pipeline and issue/response wrapper","source":"MODIFY; rtl/common/modified/cva6/core/fpu_wrap.sv"},{"key":"B6","label":["lsu_i","(load_store_unit)"],"width":200,"row":3,"col":0,"row_name":"lsu_i (load_store_unit)","function":"LSU maintenance and atomic integration","source":"MODIFY; rtl/common/modified/cva6/core/load_store_unit.sv"},{"key":"B7","label":["i_mult","(mult)"],"width":80,"row":3,"col":1,"row_name":"i_mult (mult)","function":"Native component","source":"MODIFY; rtl/common/modified/cva6/core/mult.sv"}],"connectors":[],"externals":[],"interfaces":[],"nets":[],"legend_note":"Exact source-referenced children; generate multiplicity and active branches are specified in the component text. Containment denotes hierarchy, not invented signal connectivity. NEW/MODIFY/REUSE/GENERATED provenance is listed in the block table. Clock/reset follow the common synchronous contract. Complete parent port declarations are in the component section.","library_sha256":"15DFB183E267D2A94F8CAB316E01EB3D2E9D2F9C006DC816790A394F4123506C"}
```

[Editable draw.io](figures/post_a06/ex_stage.drawio) · [Figure source](figures/post_a06/ex_stage.json).

**Interface and flow.** Keep native typed request/response records and source ordering. The parent wrapper owns translation to VLSIT flat ports. Exact port declarations:

| Direction | Exact source declaration |
|---|---|
| input | `logic clk_i` |
| input | `logic rst_ni` |
| input | `logic flush_i` |
| input | `logic debug_mode_i` |
| input | `logic [CVA6Cfg.NrIssuePorts-1:0][CVA6Cfg.VLEN-1:0] rs1_forwarding_i` |
| input | `logic [CVA6Cfg.NrIssuePorts-1:0][CVA6Cfg.VLEN-1:0] rs2_forwarding_i` |
| input | `fu_data_t [CVA6Cfg.NrIssuePorts-1:0] fu_data_i` |
| input | `alu_bypass_t alu_bypass_i` |
| input | `logic [CVA6Cfg.VLEN-1:0] pc_i` |
| input | `logic is_zcmt_i` |
| input | `logic is_compressed_instr_i` |
| input | `logic [CVA6Cfg.NrIssuePorts-1:0][31:0] tinst_i` |
| output | `logic [CVA6Cfg.XLEN-1:0] flu_result_o` |
| output | `logic [CVA6Cfg.TRANS_ID_BITS-1:0] flu_trans_id_o` |
| output | `exception_t flu_exception_o` |
| output | `logic flu_ready_o` |
| output | `logic flu_valid_o` |
| input | `logic [CVA6Cfg.NrIssuePorts-1:0] alu_valid_i` |
| input | `logic [CVA6Cfg.NrIssuePorts-1:0] aes_valid_i` |
| input | `logic [CVA6Cfg.NrIssuePorts-1:0] branch_valid_i` |
| input | `branchpredict_sbe_t branch_predict_i` |
| output | `bp_resolve_t resolved_branch_o` |
| output | `logic resolve_branch_o` |
| input | `logic [CVA6Cfg.NrIssuePorts-1:0] csr_valid_i` |
| output | `logic [11:0] csr_addr_o` |
| input | `logic csr_commit_i` |
| input | `logic [CVA6Cfg.NrIssuePorts-1:0] mult_valid_i` |
| output | `logic lsu_ready_o` |
| input | `logic [CVA6Cfg.NrIssuePorts-1:0] lsu_valid_i` |
| output | `logic load_valid_o` |
| output | `logic [CVA6Cfg.XLEN-1:0] load_result_o` |
| output | `logic [CVA6Cfg.TRANS_ID_BITS-1:0] load_trans_id_o` |
| output | `exception_t load_exception_o` |
| output | `logic store_valid_o` |
| output | `logic [CVA6Cfg.XLEN-1:0] store_result_o` |
| output | `logic [CVA6Cfg.TRANS_ID_BITS-1:0] store_trans_id_o` |
| output | `exception_t store_exception_o` |
| input | `logic lsu_commit_i` |
| output | `logic lsu_commit_ready_o` |
| input | `logic [CVA6Cfg.TRANS_ID_BITS-1:0] commit_tran_id_i` |
| input | `logic stall_st_pending_i` |
| output | `logic no_st_pending_o` |
| output | `logic shared_tlb_flush_busy_o` |
| input | `logic amo_valid_commit_i` |
| output | `logic fpu_ready_o` |
| input | `logic [CVA6Cfg.NrIssuePorts-1:0] fpu_valid_i` |
| input | `logic [1:0] fpu_fmt_i` |
| input | `logic [2:0] fpu_rm_i` |
| input | `logic [2:0] fpu_frm_i` |
| input | `logic [6:0] fpu_prec_i` |
| output | `logic [CVA6Cfg.TRANS_ID_BITS-1:0] fpu_trans_id_o` |
| output | `logic [CVA6Cfg.XLEN-1:0] fpu_result_o` |
| output | `logic fpu_valid_o` |
| output | `exception_t fpu_exception_o` |
| output | `logic fpu_early_valid_o` |
| input | `logic [CVA6Cfg.NrIssuePorts-1:0] alu2_valid_i` |
| input | `logic [CVA6Cfg.NrIssuePorts-1:0] x_valid_i` |
| output | `logic x_ready_o` |
| input | `logic [31:0] x_off_instr_i` |
| output | `logic [CVA6Cfg.TRANS_ID_BITS-1:0] x_trans_id_o` |
| output | `exception_t x_exception_o` |
| output | `logic [CVA6Cfg.XLEN-1:0] x_result_o` |
| output | `logic x_valid_o` |
| output | `logic x_we_o` |
| output | `logic [4:0] x_rd_o` |
| input | `logic x_result_valid_i` |
| input | `x_result_t x_result_i` |
| output | `logic x_result_ready_o` |
| input | `logic x_transaction_rejected_i` |
| input | `logic acc_valid_i` |
| input | `acc_mmu_req_t acc_mmu_req_i` |
| output | `acc_mmu_resp_t acc_mmu_resp_o` |
| input | `logic enable_translation_i` |
| input | `logic enable_g_translation_i` |
| input | `logic en_ld_st_translation_i` |
| input | `logic en_ld_st_g_translation_i` |
| input | `logic flush_tlb_i` |
| input | `logic flush_tlb_vvma_i` |
| input | `logic flush_tlb_gvma_i` |
| input | `riscv::priv_lvl_t priv_lvl_i` |
| input | `logic mbe_i` |
| input | `logic v_i` |
| input | `riscv::priv_lvl_t ld_st_priv_lvl_i` |
| input | `logic ld_st_v_i` |
| output | `logic csr_hs_ld_st_inst_o` |
| input | `logic sum_i` |
| input | `logic vs_sum_i` |
| input | `logic mxr_i` |
| input | `logic vmxr_i` |
| input | `logic [CVA6Cfg.PPNW-1:0] satp_ppn_i` |
| input | `logic [CVA6Cfg.ASID_WIDTH-1:0] asid_i` |
| input | `logic [CVA6Cfg.PPNW-1:0] vsatp_ppn_i` |
| input | `logic [CVA6Cfg.ASID_WIDTH-1:0] vs_asid_i` |
| input | `logic [CVA6Cfg.PPNW-1:0] hgatp_ppn_i` |
| input | `logic [CVA6Cfg.VMID_WIDTH-1:0] vmid_i` |
| input | `icache_arsp_t icache_areq_i` |
| output | `icache_areq_t icache_areq_o` |
| input | `dcache_req_o_t [2:0] dcache_req_ports_i` |
| output | `dcache_req_i_t [2:0] dcache_req_ports_o` |
| input | `logic dcache_wbuffer_empty_i` |
| input | `logic dcache_wbuffer_not_ni_i` |
| output | `amo_req_t amo_req_o` |
| input | `amo_resp_t amo_resp_i` |
| output | `logic itlb_miss_o` |
| output | `logic dtlb_miss_o` |
| input | `riscv::pmpcfg_t [avoid_neg(CVA6Cfg.NrPMPEntries-1):0] pmpcfg_i` |
| input | `logic [avoid_neg(CVA6Cfg.NrPMPEntries-1):0][CVA6Cfg.PLEN-3:0] pmpaddr_i` |
| output | `lsu_ctrl_t rvfi_lsu_ctrl_o` |
| output | `[CVA6Cfg.PLEN-1:0] rvfi_mem_paddr_o` |
| output | `logic cmo_entry_valid_o` |
| output | `cbo_t cmo_entry_op_o` |
| output | `logic [CVA6Cfg.PLEN-1:0] cmo_entry_paddr_o` |
| output | `logic [CVA6Cfg.VLEN-1:0] cmo_entry_vaddr_o` |
| input | `logic [5:0] orig_instr_aes_i` |
| output | `logic [CVA6Cfg.VLEN-1:0] sdtrig_lsu_inputs_operand_a_o` |
| output | `logic [CVA6Cfg.XLEN-1:0] sdtrig_lsu_inputs_operand_c_o` |
| output | `logic sdtrig_lsu_inputs_we_o` |
| output | `logic sdtrig_lsu_inputs_valid_o` |
| input | `logic sdtrig_load_stall_i` |
| input | `logic sdtrig_load_cancel_i` |
| input | `logic [CVA6Cfg.XLEN-1:0] sdtrig_load_action_i` |
| input | `logic sdtrig_store_stall_i` |
| input | `logic [CVA6Cfg.XLEN-1:0] sdtrig_store_action_i` |

**Recorded local changes (source history, not a substitute for the current contract):**
- Forward pending CBO metadata from LSU to CVA6 retirement logic.
- Route the staged ExternalCmo retirement mode through the LSU hierarchy; external completion dequeues CBO without a duplicate local cache request.
- Keep inactive second-issue selectors legal in single-issue configurations.

**State/verification.** Native state encodings and helper logic remain source-owned. Coherence/maintenance-relevant state machines are discussed in Section 10; native arithmetic/MMU/helper integration is linted, with only the specific activated CPU/FPU cases described in Section 15. No blanket ISA/FP/MMU or helper-equivalence qualification is claimed.

#### 14.5.44 `fpu_wrap.sv` — MODIFY

Source: [rtl/common/modified/cva6/core/fpu_wrap.sv](../../rtl/modified/cva6/core/fpu_wrap.sv).

**Function and local effect.** FPU pipeline and issue/response wrapper. Separate state-derived valid/payload selection from ready-dependent control to remove a combinational feedback path without adding latency or changing arithmetic.

![fpu_wrap selected modified component](figures/post_a06/fpu_wrap.svg)

```json
{"page_name":"BLOCK_DIAGRAM","out_name":"fpu_wrap.drawio","layout":{"gap_h":120,"gap_v":110,"margin":80,"block_h":60},"top":{"frame_label":["Component composition","(fpu_wrap)"]},"frame_row":["fpu_wrap","Native modified component; function and change contract are specified in Section 14.","rtl/common/modified/cva6/core/fpu_wrap.sv"],"frame_interfaces":[],"blocks":[{"key":"B0","label":["i_fpnew_bulk","(fpnew_top)"],"width":140,"row":0,"col":0,"row_name":"i_fpnew_bulk (fpnew_top)","function":"Native component","source":"REUSE; rtl/common/third_party/cvfpu/src/fpnew_top.sv"}],"connectors":[],"externals":[],"interfaces":[],"nets":[],"legend_note":"Exact source-referenced children; generate multiplicity and active branches are specified in the component text. Containment denotes hierarchy, not invented signal connectivity. NEW/MODIFY/REUSE/GENERATED provenance is listed in the block table. Clock/reset follow the common synchronous contract. Complete parent port declarations are in the component section.","library_sha256":"15DFB183E267D2A94F8CAB316E01EB3D2E9D2F9C006DC816790A394F4123506C"}
```

[Editable draw.io](figures/post_a06/fpu_wrap.drawio) · [Figure source](figures/post_a06/fpu_wrap.json).

**Interface and flow.** Keep native typed request/response records and source ordering. The parent wrapper owns translation to VLSIT flat ports. Exact port declarations:

| Direction | Exact source declaration |
|---|---|
| input | `logic clk_i` |
| input | `logic rst_ni` |
| input | `logic flush_i` |
| input | `logic fpu_valid_i` |
| output | `logic fpu_ready_o` |
| input | `fu_data_t fu_data_i` |
| input | `logic [ 1:0] fpu_fmt_i` |
| input | `logic [ 2:0] fpu_rm_i` |
| input | `logic [ 2:0] fpu_frm_i` |
| input | `logic [ 6:0] fpu_prec_i` |
| output | `logic [CVA6Cfg.TRANS_ID_BITS-1:0] fpu_trans_id_o` |
| output | `logic [ CVA6Cfg.FLen-1:0] result_o` |
| output | `logic fpu_valid_o` |
| output | `exception_t fpu_exception_o` |
| output | `logic fpu_early_valid_o` |

**Recorded local changes (source history, not a substitute for the current contract):**
- Size packed scalar floating-point operand replication to the configured register width.
- Index feature masks, pipeline latencies and unit types explicitly by format/group enums.
- Derive payload selection and VALID separately from READY feedback; preserve the upstream hold/accept cycle behavior without warning suppression.

**State/verification.** Native state encodings and helper logic remain source-owned. Coherence/maintenance-relevant state machines are discussed in Section 10; native arithmetic/MMU/helper integration is linted, with only the specific activated CPU/FPU cases described in Section 15. No blanket ISA/FP/MMU or helper-equivalence qualification is claimed.

#### 14.5.45 `build_config_pkg.sv` — MODIFY

Source: [rtl/common/modified/cva6/core/include/build_config_pkg.sv](../../rtl/modified/cva6/core/include/build_config_pkg.sv).

**Function.** Type/configuration/package support; not an instantiable block, so no fictitious block/FSM diagram is supplied. Its definitions are consumed by the selected native component interfaces.

**Recorded local changes (source history, not a substitute for the current contract):**
- Convert user-enable configuration words explicitly to one-bit enables.

**State/verification.** Native state encodings and helper logic remain source-owned. Coherence/maintenance-relevant state machines are discussed in Section 10; native arithmetic/MMU/helper integration is linted, with only the specific activated CPU/FPU cases described in Section 15. No blanket ISA/FP/MMU or helper-equivalence qualification is claimed.

#### 14.5.46 `cv64a6_imafdc_sv39_hpdcache_wb_config_pkg.sv` — MODIFY

Source: [rtl/common/modified/cva6/core/include/cv64a6_imafdc_sv39_hpdcache_wb_config_pkg.sv](../../rtl/modified/cva6/core/include/cv64a6_imafdc_sv39_hpdcache_wb_config_pkg.sv).

**Function.** Type/configuration/package support; not an instantiable block, so no fictitious block/FSM diagram is supplied. Its definitions are consumed by the selected native component interfaces.

**Recorded local changes (source history, not a substitute for the current contract):**
- Disabled CVXIF because the approved cluster interface has no CVXIF accelerator ports. Source configuration and all other upstream contents remain unchanged.
- Match trigger capability encodings to their declared configuration field widths.

**State/verification.** Native state encodings and helper logic remain source-owned. Coherence/maintenance-relevant state machines are discussed in Section 10; native arithmetic/MMU/helper integration is linted, with only the specific activated CPU/FPU cases described in Section 15. No blanket ISA/FP/MMU or helper-equivalence qualification is claimed.

#### 14.5.47 `issue_read_operands.sv` — MODIFY

Source: [rtl/common/modified/cva6/core/issue_read_operands.sv](../../rtl/modified/cva6/core/issue_read_operands.sv).

**Function and local effect.** Issues instruction from the scoreboard and fetches the operands. Preserve the native request/result or storage behavior while applying the explicit local changes recorded below. Its parent consumes the exact typed interfaces in this section; queue, arithmetic, memory and protocol helpers do not create new architectural ownership rules. Native latency/ordering remains source-defined and is not independently qualified by TOP lint.

![issue_read_operands selected modified component](figures/post_a06/issue_read_operands.svg)

```json
{"page_name":"BLOCK_DIAGRAM","out_name":"issue_read_operands.drawio","layout":{"gap_h":120,"gap_v":110,"margin":80,"block_h":60},"top":{"frame_label":["Component composition","(issue_read_operands)"]},"frame_row":["issue_read_operands","Native modified component; function and change contract are specified in Section 14.","rtl/common/modified/cva6/core/issue_read_operands.sv"],"frame_interfaces":[],"blocks":[{"key":"B0","label":["i_ariane_fp_regfile","(ariane_regfile)"],"width":220,"row":0,"col":0,"row_name":"i_ariane_fp_regfile (ariane_regfile)","function":"Native component","source":"MODIFY; rtl/common/modified/cva6/core/ariane_regfile_ff.sv"},{"key":"B1","label":["i_ariane_regfile","(ariane_regfile)"],"width":200,"row":0,"col":1,"row_name":"i_ariane_regfile (ariane_regfile)","function":"Native component","source":"MODIFY; rtl/common/modified/cva6/core/ariane_regfile_ff.sv"},{"key":"B2","label":["i_ariane_fp_regfile_fpga","(ariane_regfile_fpga)"],"width":280,"row":1,"col":0,"row_name":"i_ariane_fp_regfile_fpga (ariane_regfile_fpga)","function":"Native component","source":"REUSE; rtl/common/third_party/cva6/core/ariane_regfile_fpga.sv"},{"key":"B3","label":["i_ariane_regfile_fpga","(ariane_regfile_fpga)"],"width":260,"row":1,"col":1,"row_name":"i_ariane_regfile_fpga (ariane_regfile_fpga)","function":"Native component","source":"REUSE; rtl/common/third_party/cva6/core/ariane_regfile_fpga.sv"},{"key":"B4","label":["i_cvxif_issue_register_commit_if_driver","(cvxif_issue_register_commit_if_driver)"],"width":460,"row":2,"col":0,"row_name":"i_cvxif_issue_register_commit_if_driver (cvxif_issue_register_commit_if_driver)","function":"Native component","source":"REUSE; rtl/common/third_party/cva6/core/cvxif_issue_register_commit_if_driver.sv"},{"key":"B5","label":["i_rs1_last_raw","(raw_checker)"],"width":180,"row":2,"col":1,"row_name":"i_rs1_last_raw (raw_checker)","function":"Native component","source":"MODIFY; rtl/common/modified/cva6/core/raw_checker.sv"},{"key":"B6","label":["i_rs2_last_raw","(raw_checker)"],"width":180,"row":3,"col":0,"row_name":"i_rs2_last_raw (raw_checker)","function":"Native component","source":"MODIFY; rtl/common/modified/cva6/core/raw_checker.sv"},{"key":"B7","label":["i_rs3_last_raw","(raw_checker)"],"width":180,"row":3,"col":1,"row_name":"i_rs3_last_raw (raw_checker)","function":"Native component","source":"MODIFY; rtl/common/modified/cva6/core/raw_checker.sv"}],"connectors":[],"externals":[],"interfaces":[],"nets":[],"legend_note":"Exact source-referenced children; generate multiplicity and active branches are specified in the component text. Containment denotes hierarchy, not invented signal connectivity. NEW/MODIFY/REUSE/GENERATED provenance is listed in the block table. Clock/reset follow the common synchronous contract. Complete parent port declarations are in the component section.","library_sha256":"15DFB183E267D2A94F8CAB316E01EB3D2E9D2F9C006DC816790A394F4123506C"}
```

[Editable draw.io](figures/post_a06/issue_read_operands.drawio) · [Figure source](figures/post_a06/issue_read_operands.json).

**Interface and flow.** Keep native typed request/response records and source ordering. The parent wrapper owns translation to VLSIT flat ports. Exact port declarations:

| Direction | Exact source declaration |
|---|---|
| input | `logic clk_i` |
| input | `logic rst_ni` |
| input | `logic flush_i` |
| input | `logic stall_i` |
| input | `scoreboard_entry_t [CVA6Cfg.NrIssuePorts-1:0] issue_instr_i` |
| input | `scoreboard_entry_t [CVA6Cfg.NrIssuePorts-1:0] issue_instr_i_prev` |
| input | `logic [CVA6Cfg.NrIssuePorts-1:0][31:0] orig_instr_i` |
| input | `logic [CVA6Cfg.NrIssuePorts-1:0] issue_instr_valid_i` |
| output | `logic [CVA6Cfg.NrIssuePorts-1:0] issue_ack_o` |
| input | `forwarding_t fwd_i` |
| output | `fu_data_t [CVA6Cfg.NrIssuePorts-1:0] fu_data_o` |
| output | `alu_bypass_t alu_bypass_o` |
| output | `logic [CVA6Cfg.NrIssuePorts-1:0][CVA6Cfg.VLEN-1:0] rs1_forwarding_o` |
| output | `logic [CVA6Cfg.NrIssuePorts-1:0][CVA6Cfg.VLEN-1:0] rs2_forwarding_o` |
| output | `logic [CVA6Cfg.VLEN-1:0] pc_o` |
| output | `logic is_zcmt_o` |
| output | `logic is_compressed_instr_o` |
| input | `logic flu_ready_i` |
| output | `logic [CVA6Cfg.NrIssuePorts-1:0] alu_valid_o` |
| output | `logic [CVA6Cfg.NrIssuePorts-1:0] aes_valid_o` |
| output | `logic [CVA6Cfg.NrIssuePorts-1:0] branch_valid_o` |
| output | `logic [CVA6Cfg.NrIssuePorts-1:0][31:0] tinst_o` |
| output | `branchpredict_sbe_t branch_predict_o` |
| input | `logic lsu_ready_i` |
| output | `logic [CVA6Cfg.NrIssuePorts-1:0] lsu_valid_o` |
| output | `logic [CVA6Cfg.NrIssuePorts-1:0] mult_valid_o` |
| input | `logic fpu_ready_i` |
| input | `logic fpu_early_valid_i` |
| output | `logic [CVA6Cfg.NrIssuePorts-1:0] fpu_valid_o` |
| output | `logic [1:0] fpu_fmt_o` |
| output | `logic [2:0] fpu_rm_o` |
| output | `logic [CVA6Cfg.NrIssuePorts-1:0] alu2_valid_o` |
| output | `logic [CVA6Cfg.NrIssuePorts-1:0] csr_valid_o` |
| output | `logic [CVA6Cfg.NrIssuePorts-1:0] cvxif_valid_o` |
| input | `logic cvxif_ready_i` |
| output | `logic [31:0] cvxif_off_instr_o` |
| input | `logic [CVA6Cfg.XLEN-1:0] hart_id_i` |
| input | `logic x_issue_ready_i` |
| input | `x_issue_resp_t x_issue_resp_i` |
| output | `logic x_issue_valid_o` |
| output | `x_issue_req_t x_issue_req_o` |
| input | `logic x_register_ready_i` |
| output | `logic x_register_valid_o` |
| output | `x_register_t x_register_o` |
| output | `logic x_commit_valid_o` |
| output | `x_commit_t x_commit_o` |
| output | `logic x_transaction_accepted_o` |
| output | `logic x_transaction_rejected_o` |
| output | `logic x_issue_writeback_o` |
| output | `logic [CVA6Cfg.TRANS_ID_BITS-1:0] x_id_o` |
| input | `logic [CVA6Cfg.NrCommitPorts-1:0][4:0] waddr_i` |
| input | `logic [CVA6Cfg.NrCommitPorts-1:0][CVA6Cfg.XLEN-1:0] wdata_i` |
| input | `logic [CVA6Cfg.NrCommitPorts-1:0] we_gpr_i` |
| input | `logic [CVA6Cfg.NrCommitPorts-1:0] we_fpr_i` |
| output | `logic stall_issue_o` |
| output | `logic [CVA6Cfg.NrIssuePorts-1:0][CVA6Cfg.XLEN-1:0] rvfi_rs1_o` |
| output | `logic [CVA6Cfg.NrIssuePorts-1:0][CVA6Cfg.XLEN-1:0] rvfi_rs2_o` |
| output | `logic [5:0] orig_instr_aes_bits` |

**Recorded local changes (source history, not a substitute for the current contract):**
- Keep constant-disabled second-issue and third-operand branches within declared bounds.

**State/verification.** Native state encodings and helper logic remain source-owned. Coherence/maintenance-relevant state machines are discussed in Section 10; native arithmetic/MMU/helper integration is linted, with only the specific activated CPU/FPU cases described in Section 15. No blanket ISA/FP/MMU or helper-equivalence qualification is claimed.

#### 14.5.48 `load_store_unit.sv` — MODIFY

Source: [rtl/common/modified/cva6/core/load_store_unit.sv](../../rtl/modified/cva6/core/load_store_unit.sv).

**Function and local effect.** LSU maintenance and atomic integration. Connect the selected external-maintenance mode and native store/load/translation state to the retained retirement service and cache hierarchy.

![load_store_unit selected modified component](figures/post_a06/load_store_unit.svg)

```json
{"page_name":"BLOCK_DIAGRAM","out_name":"load_store_unit.drawio","layout":{"gap_h":120,"gap_v":110,"margin":80,"block_h":60},"top":{"frame_label":["Component composition","(load_store_unit)"]},"frame_row":["load_store_unit","Native modified component; function and change contract are specified in Section 14.","rtl/common/modified/cva6/core/load_store_unit.sv"],"frame_interfaces":[],"blocks":[{"key":"B0","label":["i_cva6_mmu","(cva6_mmu)"],"width":120,"row":0,"col":0,"row_name":"i_cva6_mmu (cva6_mmu)","function":"Native component","source":"MODIFY; rtl/common/modified/cva6/core/cva6_mmu/cva6_mmu.sv"},{"key":"B1","label":["i_load_unit","(load_unit)"],"width":140,"row":0,"col":1,"row_name":"i_load_unit (load_unit)","function":"Load/atomic completion and fault path","source":"MODIFY; rtl/common/modified/cva6/core/load_unit.sv"},{"key":"B2","label":["lsu_bypass_i","(lsu_bypass)"],"width":140,"row":1,"col":0,"row_name":"lsu_bypass_i (lsu_bypass)","function":"Native component","source":"REUSE; rtl/common/third_party/cva6/core/lsu_bypass.sv"},{"key":"B3","label":["i_pmp_data_if","(pmp_data_if)"],"width":160,"row":1,"col":1,"row_name":"i_pmp_data_if (pmp_data_if)","function":"Native component","source":"REUSE; rtl/common/third_party/cva6/core/pmp/src/pmp_data_if.sv"},{"key":"B4","label":["i_pipe_reg_load","(shift_reg)"],"width":180,"row":2,"col":0,"row_name":"i_pipe_reg_load (shift_reg)","function":"Native component","source":"REUSE; rtl/common/third_party/cva6/vendor/pulp-platform/common_cells/src/shift_reg.sv"},{"key":"B5","label":["i_pipe_reg_store","(shift_reg)"],"width":200,"row":2,"col":1,"row_name":"i_pipe_reg_store (shift_reg)","function":"Native component","source":"REUSE; rtl/common/third_party/cva6/vendor/pulp-platform/common_cells/src/shift_reg.sv"},{"key":"B6","label":["i_store_unit","(store_unit)"],"width":140,"row":3,"col":0,"row_name":"i_store_unit (store_unit)","function":"Store translation and CBO metadata","source":"MODIFY; rtl/common/modified/cva6/core/store_unit.sv"}],"connectors":[],"externals":[],"interfaces":[],"nets":[],"legend_note":"Exact source-referenced children; generate multiplicity and active branches are specified in the component text. Containment denotes hierarchy, not invented signal connectivity. NEW/MODIFY/REUSE/GENERATED provenance is listed in the block table. Clock/reset follow the common synchronous contract. Complete parent port declarations are in the component section.","library_sha256":"15DFB183E267D2A94F8CAB316E01EB3D2E9D2F9C006DC816790A394F4123506C"}
```

[Editable draw.io](figures/post_a06/load_store_unit.drawio) · [Figure source](figures/post_a06/load_store_unit.json).

**Interface and flow.** Keep native typed request/response records and source ordering. The parent wrapper owns translation to VLSIT flat ports. Exact port declarations:

| Direction | Exact source declaration |
|---|---|
| input | `logic clk_i` |
| input | `logic rst_ni` |
| input | `logic flush_i` |
| input | `logic stall_st_pending_i` |
| output | `logic no_st_pending_o` |
| output | `logic shared_tlb_flush_busy_o` |
| input | `logic amo_valid_commit_i` |
| input | `logic [31:0] tinst_i` |
| input | `fu_data_t fu_data_i` |
| output | `logic lsu_ready_o` |
| input | `logic lsu_valid_i` |
| input | `logic speculative_load_i` |
| output | `logic [CVA6Cfg.TRANS_ID_BITS-1:0] load_trans_id_o` |
| output | `logic [CVA6Cfg.XLEN-1:0] load_result_o` |
| output | `logic load_valid_o` |
| output | `exception_t load_exception_o` |
| output | `logic [CVA6Cfg.TRANS_ID_BITS-1:0] store_trans_id_o` |
| output | `logic [CVA6Cfg.XLEN-1:0] store_result_o` |
| output | `logic store_valid_o` |
| output | `exception_t store_exception_o` |
| input | `logic commit_i` |
| output | `logic commit_ready_o` |
| input | `logic [CVA6Cfg.TRANS_ID_BITS-1:0] commit_tran_id_i` |
| input | `bp_resolve_t resolved_branch_i` |
| input | `logic enable_translation_i` |
| input | `logic enable_g_translation_i` |
| input | `logic en_ld_st_translation_i` |
| input | `logic en_ld_st_g_translation_i` |
| input | `acc_mmu_req_t acc_mmu_req_i` |
| output | `acc_mmu_resp_t acc_mmu_resp_o` |
| input | `icache_arsp_t icache_areq_i` |
| output | `icache_areq_t icache_areq_o` |
| input | `riscv::priv_lvl_t priv_lvl_i` |
| input | `logic mbe_i` |
| input | `logic v_i` |
| input | `riscv::priv_lvl_t ld_st_priv_lvl_i` |
| input | `logic ld_st_v_i` |
| output | `logic csr_hs_ld_st_inst_o` |
| input | `logic sum_i` |
| input | `logic vs_sum_i` |
| input | `logic mxr_i` |
| input | `logic vmxr_i` |
| input | `logic [ CVA6Cfg.PPNW-1:0] satp_ppn_i` |
| input | `logic [CVA6Cfg.ASID_WIDTH-1:0] asid_i` |
| input | `logic [ CVA6Cfg.PPNW-1:0] vsatp_ppn_i` |
| input | `logic [CVA6Cfg.ASID_WIDTH-1:0] vs_asid_i` |
| input | `logic [ CVA6Cfg.PPNW-1:0] hgatp_ppn_i` |
| input | `logic [CVA6Cfg.VMID_WIDTH-1:0] vmid_i` |
| input | `logic [CVA6Cfg.ASID_WIDTH-1:0] asid_to_be_flushed_i` |
| input | `logic [CVA6Cfg.VMID_WIDTH-1:0] vmid_to_be_flushed_i` |
| input | `logic [ CVA6Cfg.VLEN-1:0] vaddr_to_be_flushed_i` |
| input | `logic [ CVA6Cfg.GPLEN-1:0] gpaddr_to_be_flushed_i` |
| input | `logic flush_tlb_i` |
| input | `logic flush_tlb_vvma_i` |
| input | `logic flush_tlb_gvma_i` |
| output | `logic itlb_miss_o` |
| output | `logic dtlb_miss_o` |
| input | `dcache_req_o_t [2:0] dcache_req_ports_i` |
| output | `dcache_req_i_t [2:0] dcache_req_ports_o` |
| input | `logic dcache_wbuffer_empty_i` |
| input | `logic dcache_wbuffer_not_ni_i` |
| output | `amo_req_t amo_req_o` |
| input | `amo_resp_t amo_resp_i` |
| input | `riscv::pmpcfg_t [avoid_neg(CVA6Cfg.NrPMPEntries-1):0] pmpcfg_i` |
| input | `logic [avoid_neg(CVA6Cfg.NrPMPEntries-1):0][CVA6Cfg.PLEN-3:0] pmpaddr_i` |
| output | `lsu_ctrl_t rvfi_lsu_ctrl_o` |
| output | `logic [CVA6Cfg.PLEN-1:0] rvfi_mem_paddr_o` |
| output | `logic cmo_entry_valid_o` |
| output | `cbo_t cmo_entry_op_o` |
| output | `logic [CVA6Cfg.PLEN-1:0] cmo_entry_paddr_o` |
| output | `logic [CVA6Cfg.VLEN-1:0] cmo_entry_vaddr_o` |
| input | `logic sdtrig_load_stall_i` |
| input | `logic sdtrig_load_cancel_i` |
| input | `logic [CVA6Cfg.XLEN-1:0] sdtrig_load_action_i` |
| input | `logic sdtrig_store_stall_i` |
| input | `logic [CVA6Cfg.XLEN-1:0] sdtrig_store_action_i` |

**Recorded local changes (source history, not a substitute for the current contract):**
- Forward pending CBO PA/VA/op metadata from the store buffer.
- Route the staged ExternalCmo retirement mode through the LSU hierarchy; external completion dequeues CBO without a duplicate local cache request.
- Make destination-width extension and truncation explicit at RTL assignments.

**State/verification.** Native state encodings and helper logic remain source-owned. Coherence/maintenance-relevant state machines are discussed in Section 10; native arithmetic/MMU/helper integration is linted, with only the specific activated CPU/FPU cases described in Section 15. No blanket ISA/FP/MMU or helper-equivalence qualification is claimed.

#### 14.5.49 `load_unit.sv` — MODIFY

Source: [rtl/common/modified/cva6/core/load_unit.sv](../../rtl/modified/cva6/core/load_unit.sv).

**Function and local effect.** Load/atomic completion and fault path. Preserve cached atomic/load response error provenance and destination association while the CCU-owned request is stalled or completed.

![load_unit selected modified component](figures/post_a06/load_unit.svg)

```json
{"page_name":"BLOCK_DIAGRAM","out_name":"load_unit.drawio","layout":{"gap_h":120,"gap_v":110,"margin":80,"block_h":60},"top":{"frame_label":["Component composition","(load_unit)"]},"frame_row":["load_unit","Native modified component; function and change contract are specified in Section 14.","rtl/common/modified/cva6/core/load_unit.sv"],"frame_interfaces":[],"blocks":[{"key":"B0","label":["lzc_windex_i","(lzc)"],"width":140,"row":0,"col":0,"row_name":"lzc_windex_i (lzc)","function":"Native component","source":"REUSE; rtl/common/third_party/cva6/vendor/pulp-platform/common_cells/src/lzc.sv"}],"connectors":[],"externals":[],"interfaces":[],"nets":[],"legend_note":"Exact source-referenced children; generate multiplicity and active branches are specified in the component text. Containment denotes hierarchy, not invented signal connectivity. NEW/MODIFY/REUSE/GENERATED provenance is listed in the block table. Clock/reset follow the common synchronous contract. Complete parent port declarations are in the component section.","library_sha256":"15DFB183E267D2A94F8CAB316E01EB3D2E9D2F9C006DC816790A394F4123506C"}
```

[Editable draw.io](figures/post_a06/load_unit.drawio) · [Figure source](figures/post_a06/load_unit.json).

**Interface and flow.** Keep native typed request/response records and source ordering. The parent wrapper owns translation to VLSIT flat ports. Exact port declarations:

| Direction | Exact source declaration |
|---|---|
| input | `logic clk_i` |
| input | `logic rst_ni` |
| input | `logic flush_i` |
| input | `logic valid_i` |
| input | `lsu_ctrl_t lsu_ctrl_i` |
| output | `logic pop_ld_o` |
| output | `logic valid_o` |
| output | `logic [CVA6Cfg.TRANS_ID_BITS-1:0] trans_id_o` |
| output | `logic [CVA6Cfg.XLEN-1:0] result_o` |
| output | `exception_t ex_o` |
| input | `logic mbe_i` |
| output | `logic translation_req_o` |
| output | `logic [CVA6Cfg.VLEN-1:0] vaddr_o` |
| output | `logic [31:0] tinst_o` |
| output | `logic hs_ld_st_inst_o` |
| output | `logic hlvx_inst_o` |
| input | `logic [CVA6Cfg.PLEN-1:0] paddr_i` |
| input | `exception_t ex_i` |
| input | `logic dtlb_hit_i` |
| input | `logic [CVA6Cfg.PPNW-1:0] dtlb_ppn_i` |
| output | `logic [11:0] page_offset_o` |
| input | `logic page_offset_matches_i` |
| input | `logic store_buffer_empty_i` |
| input | `logic [CVA6Cfg.TRANS_ID_BITS-1:0] commit_tran_id_i` |
| input | `dcache_req_o_t req_port_i` |
| output | `dcache_req_i_t req_port_o` |
| input | `logic dcache_wbuffer_not_ni_i` |
| input | `logic sdtrig_load_stall_i` |
| input | `logic sdtrig_load_cancel_i` |
| input | `logic [CVA6Cfg.XLEN-1:0] sdtrig_load_action_i` |

**Recorded local changes (source history, not a substitute for the current contract):**
- Size load-buffer indices and alignment assertions explicitly.

**State/verification.** Native state encodings and helper logic remain source-owned. Coherence/maintenance-relevant state machines are discussed in Section 10; native arithmetic/MMU/helper integration is linted, with only the specific activated CPU/FPU cases described in Section 15. No blanket ISA/FP/MMU or helper-equivalence qualification is claimed.

#### 14.5.50 `mult.sv` — MODIFY

Source: [rtl/common/modified/cva6/core/mult.sv](../../rtl/modified/cva6/core/mult.sv).

**Function and local effect.** Native mult component. Preserve the native request/result or storage behavior while applying the explicit local changes recorded below. Its parent consumes the exact typed interfaces in this section; queue, arithmetic, memory and protocol helpers do not create new architectural ownership rules. Native latency/ordering remains source-defined and is not independently qualified by TOP lint.

![mult selected modified component](figures/post_a06/mult.svg)

```json
{"page_name":"BLOCK_DIAGRAM","out_name":"mult.drawio","layout":{"gap_h":120,"gap_v":110,"margin":80,"block_h":60},"top":{"frame_label":["Component composition","(mult)"]},"frame_row":["mult","Native modified component; function and change contract are specified in Section 14.","rtl/common/modified/cva6/core/mult.sv"],"frame_interfaces":[],"blocks":[{"key":"B0","label":["i_multiplier","(multiplier)"],"width":140,"row":0,"col":0,"row_name":"i_multiplier (multiplier)","function":"Native component","source":"REUSE; rtl/common/third_party/cva6/core/multiplier.sv"},{"key":"B1","label":["i_div","(serdiv)"],"width":100,"row":1,"col":0,"row_name":"i_div (serdiv)","function":"Native component","source":"MODIFY; rtl/common/modified/cva6/core/serdiv.sv"}],"connectors":[],"externals":[],"interfaces":[],"nets":[],"legend_note":"Exact source-referenced children; generate multiplicity and active branches are specified in the component text. Containment denotes hierarchy, not invented signal connectivity. NEW/MODIFY/REUSE/GENERATED provenance is listed in the block table. Clock/reset follow the common synchronous contract. Complete parent port declarations are in the component section.","library_sha256":"15DFB183E267D2A94F8CAB316E01EB3D2E9D2F9C006DC816790A394F4123506C"}
```

[Editable draw.io](figures/post_a06/mult.drawio) · [Figure source](figures/post_a06/mult.json).

**Interface and flow.** Keep native typed request/response records and source ordering. The parent wrapper owns translation to VLSIT flat ports. Exact port declarations:

| Direction | Exact source declaration |
|---|---|
| input | `logic clk_i` |
| input | `logic rst_ni` |
| input | `logic flush_i` |
| input | `fu_data_t fu_data_i` |
| input | `logic mult_valid_i` |
| output | `logic [ CVA6Cfg.XLEN-1:0] result_o` |
| output | `logic mult_valid_o` |
| output | `logic mult_ready_o` |
| output | `logic [CVA6Cfg.TRANS_ID_BITS-1:0] mult_trans_id_o` |

**Recorded local changes (source history, not a substitute for the current contract):**
- Make destination-width extension and truncation explicit at RTL assignments.
- Select the specified low word before RISC-V word-result sign extension.

**State/verification.** Native state encodings and helper logic remain source-owned. Coherence/maintenance-relevant state machines are discussed in Section 10; native arithmetic/MMU/helper integration is linted, with only the specific activated CPU/FPU cases described in Section 15. No blanket ISA/FP/MMU or helper-equivalence qualification is claimed.

#### 14.5.51 `perf_counters.sv` — MODIFY

Source: [rtl/common/modified/cva6/core/perf_counters.sv](../../rtl/modified/cva6/core/perf_counters.sv).

**Function and local effect.** Native CPU event taps. Expose the existing native HPM source expressions for cluster observation. Preserve each indicator unit; OR-reduced per-hart categories are not arbitrary retirement popcounts.

![perf_counters selected modified component](figures/post_a06/perf_counters.svg)

```json
{"page_name":"BLOCK_DIAGRAM","out_name":"perf_counters.drawio","layout":{"gap_h":120,"gap_v":110,"margin":80,"block_h":60},"top":{"frame_label":["Component composition","(perf_counters)"]},"frame_row":["perf_counters","Native modified component; function and change contract are specified in Section 14.","rtl/common/modified/cva6/core/perf_counters.sv"],"frame_interfaces":["IN","OUT"],"blocks":[{"key":"B0","label":["component_boundary","(perf_counters)"],"width":220,"row":0,"col":0,"row_name":"component_boundary (perf_counters)","function":"Native CPU event taps","source":"MODIFY; rtl/common/modified/cva6/core/perf_counters.sv"}],"connectors":[],"externals":[{"id":"IN","block":"B0","side":"L","dir":"in","pos":0,"text":["IN","ports"]},{"id":"OUT","block":"B0","side":"R","dir":"out","pos":0,"text":["OUT","ports"]}],"interfaces":[{"id":"IN","name":"Parent in ports","category":"custom","active":"in","signals":"clk_i, rst_ni, debug_mode_i, addr_i, we_i, data_i, commit_instr_i, commit_ack_i, l1_icache_miss_i, l1_dcache_miss_i, itlb_miss_i, dtlb_miss_i, sb_full_i, if_empty_i, ex_i, eret_i, resolved_branch_i, branch_exceptions_i, l1_icache_access_i, l1_dcache_access_i, miss_vld_bits_i, i_tlb_flush_i, stall_issue_i, mcountinhibit_i"},{"id":"OUT","name":"Parent out ports","category":"custom","active":"out","signals":"data_o, perf_event_o"}],"nets":[],"legend_note":"A single boundary symbol denotes a leaf: internal equations/registers are described in its function/dataflow contract, not invented child modules. NEW/MODIFY/REUSE/GENERATED provenance is listed in the block table. Clock/reset follow the common synchronous contract. Complete parent port declarations are in the component section.","library_sha256":"15DFB183E267D2A94F8CAB316E01EB3D2E9D2F9C006DC816790A394F4123506C"}
```

[Editable draw.io](figures/post_a06/perf_counters.drawio) · [Figure source](figures/post_a06/perf_counters.json).

**Interface and flow.** Keep native typed request/response records and source ordering. The parent wrapper owns translation to VLSIT flat ports. Exact port declarations:

| Direction | Exact source declaration |
|---|---|
| input | `logic clk_i` |
| input | `logic rst_ni` |
| input | `logic debug_mode_i` |
| input | `logic [11:0] addr_i` |
| input | `logic we_i` |
| input | `logic [CVA6Cfg.XLEN-1:0] data_i` |
| output | `logic [CVA6Cfg.XLEN-1:0] data_o` |
| output | `logic [21:0] perf_event_o` |
| input | `scoreboard_entry_t [CVA6Cfg.NrCommitPorts-1:0] commit_instr_i` |
| input | `logic [CVA6Cfg.NrCommitPorts-1:0] commit_ack_i` |
| input | `logic l1_icache_miss_i` |
| input | `logic l1_dcache_miss_i` |
| input | `logic itlb_miss_i` |
| input | `logic dtlb_miss_i` |
| input | `logic sb_full_i` |
| input | `logic if_empty_i` |
| input | `exception_t ex_i` |
| input | `logic eret_i` |
| input | `bp_resolve_t resolved_branch_i` |
| input | `exception_t branch_exceptions_i` |
| input | `icache_dreq_t l1_icache_access_i` |
| input | `dcache_req_i_t [2:0] l1_dcache_access_i` |
| input | `logic [NumPorts-1:0][CVA6Cfg.DCACHE_SET_ASSOC-1:0]miss_vld_bits_i` |
| input | `logic i_tlb_flush_i` |
| input | `logic stall_issue_i` |
| input | `logic [31:0] mcountinhibit_i` |

**Recorded local changes (source history, not a substitute for the current contract):**
- Exported the 22 raw event indicators for the cluster PMU; native CSR counters are unchanged.
- Explicitly size CSR counter words, event selectors and register-range arithmetic.

**State/verification.** Native state encodings and helper logic remain source-owned. Coherence/maintenance-relevant state machines are discussed in Section 10; native arithmetic/MMU/helper integration is linted, with only the specific activated CPU/FPU cases described in Section 15. No blanket ISA/FP/MMU or helper-equivalence qualification is claimed.

#### 14.5.52 `raw_checker.sv` — MODIFY

Source: [rtl/common/modified/cva6/core/raw_checker.sv](../../rtl/modified/cva6/core/raw_checker.sv).

**Function and local effect.** Native raw checker component. Preserve the native request/result or storage behavior while applying the explicit local changes recorded below. Its parent consumes the exact typed interfaces in this section; queue, arithmetic, memory and protocol helpers do not create new architectural ownership rules. Native latency/ordering remains source-defined and is not independently qualified by TOP lint.

![raw_checker selected modified component](figures/post_a06/raw_checker.svg)

```json
{"page_name":"BLOCK_DIAGRAM","out_name":"raw_checker.drawio","layout":{"gap_h":120,"gap_v":110,"margin":80,"block_h":60},"top":{"frame_label":["Component composition","(raw_checker)"]},"frame_row":["raw_checker","Native modified component; function and change contract are specified in Section 14.","rtl/common/modified/cva6/core/raw_checker.sv"],"frame_interfaces":["IN","OUT"],"blocks":[{"key":"B0","label":["component_boundary","(raw_checker)"],"width":220,"row":0,"col":0,"row_name":"component_boundary (raw_checker)","function":"Native component","source":"MODIFY; rtl/common/modified/cva6/core/raw_checker.sv"}],"connectors":[],"externals":[{"id":"IN","block":"B0","side":"L","dir":"in","pos":0,"text":["IN","ports"]},{"id":"OUT","block":"B0","side":"R","dir":"out","pos":0,"text":["OUT","ports"]}],"interfaces":[{"id":"IN","name":"Parent in ports","category":"custom","active":"in","signals":"clk_i, rst_ni, rs_i, rs_fpr_i, rd_i, rd_fpr_i, still_issued_i, issue_pointer_i"},{"id":"OUT","name":"Parent out ports","category":"custom","active":"out","signals":"idx_o, valid_o"}],"nets":[],"legend_note":"A single boundary symbol denotes a leaf: internal equations/registers are described in its function/dataflow contract, not invented child modules. NEW/MODIFY/REUSE/GENERATED provenance is listed in the block table. Clock/reset follow the common synchronous contract. Complete parent port declarations are in the component section.","library_sha256":"15DFB183E267D2A94F8CAB316E01EB3D2E9D2F9C006DC816790A394F4123506C"}
```

[Editable draw.io](figures/post_a06/raw_checker.drawio) · [Figure source](figures/post_a06/raw_checker.json).

**Interface and flow.** Keep native typed request/response records and source ordering. The parent wrapper owns translation to VLSIT flat ports. Exact port declarations:

| Direction | Exact source declaration |
|---|---|
| input | `logic clk_i` |
| input | `logic rst_ni` |
| input | `logic [REG_ADDR_SIZE-1:0] rs_i` |
| input | `logic rs_fpr_i` |
| input | `logic [CVA6Cfg.NR_SB_ENTRIES-1:0][REG_ADDR_SIZE-1:0] rd_i` |
| input | `logic [CVA6Cfg.NR_SB_ENTRIES-1:0] rd_fpr_i` |
| input | `logic [CVA6Cfg.NR_SB_ENTRIES-1:0] still_issued_i` |
| input | `logic [CVA6Cfg.TRANS_ID_BITS-1:0] issue_pointer_i` |
| output | `logic [CVA6Cfg.TRANS_ID_BITS-1:0] idx_o` |
| output | `logic valid_o` |

**Recorded local changes (source history, not a substitute for the current contract):**
- Make destination-width extension and truncation explicit at RTL assignments.
- Express the first scoreboard entry boundary without constant range comparisons.
- Separate the maximal pointer value from constant upper-bound comparisons.

**State/verification.** Native state encodings and helper logic remain source-owned. Coherence/maintenance-relevant state machines are discussed in Section 10; native arithmetic/MMU/helper integration is linted, with only the specific activated CPU/FPU cases described in Section 15. No blanket ISA/FP/MMU or helper-equivalence qualification is claimed.

#### 14.5.53 `scoreboard.sv` — MODIFY

Source: [rtl/common/modified/cva6/core/scoreboard.sv](../../rtl/modified/cva6/core/scoreboard.sv).

**Function and local effect.** Scoreboard - keeps track of all decoded, issued and committed instructions. Preserve the native request/result or storage behavior while applying the explicit local changes recorded below. Its parent consumes the exact typed interfaces in this section; queue, arithmetic, memory and protocol helpers do not create new architectural ownership rules. Native latency/ordering remains source-defined and is not independently qualified by TOP lint.

![scoreboard selected modified component](figures/post_a06/scoreboard.svg)

```json
{"page_name":"BLOCK_DIAGRAM","out_name":"scoreboard.drawio","layout":{"gap_h":120,"gap_v":110,"margin":80,"block_h":60},"top":{"frame_label":["Component composition","(scoreboard)"]},"frame_row":["scoreboard","Native modified component; function and change contract are specified in Section 14.","rtl/common/modified/cva6/core/scoreboard.sv"],"frame_interfaces":["IN","OUT"],"blocks":[{"key":"B0","label":["component_boundary","(scoreboard)"],"width":220,"row":0,"col":0,"row_name":"component_boundary (scoreboard)","function":"Native component","source":"MODIFY; rtl/common/modified/cva6/core/scoreboard.sv"}],"connectors":[],"externals":[{"id":"IN","block":"B0","side":"L","dir":"in","pos":0,"text":["IN","ports"]},{"id":"OUT","block":"B0","side":"R","dir":"out","pos":0,"text":["OUT","ports"]}],"interfaces":[{"id":"IN","name":"Parent in ports","category":"custom","active":"in","signals":"clk_i, rst_ni, flush_unissued_instr_i, flush_i, x_transaction_accepted_i, x_issue_writeback_i, x_id_i, commit_ack_i, decoded_instr_i, orig_instr_i, decoded_instr_valid_i, issue_ack_i, resolved_branch_i, trans_id_i, wbdata_i, ex_i, wt_valid_i, x_we_i, x_rd_i"},{"id":"OUT","name":"Parent out ports","category":"custom","active":"out","signals":"sb_full_o, commit_instr_o, commit_drop_o, decoded_instr_ack_o, issue_instr_o, orig_instr_o, issue_instr_valid_o, fwd_o, rvfi_issue_pointer_o, rvfi_commit_pointer_o"}],"nets":[],"legend_note":"A single boundary symbol denotes a leaf: internal equations/registers are described in its function/dataflow contract, not invented child modules. NEW/MODIFY/REUSE/GENERATED provenance is listed in the block table. Clock/reset follow the common synchronous contract. Complete parent port declarations are in the component section.","library_sha256":"15DFB183E267D2A94F8CAB316E01EB3D2E9D2F9C006DC816790A394F4123506C"}
```

[Editable draw.io](figures/post_a06/scoreboard.drawio) · [Figure source](figures/post_a06/scoreboard.json).

**Interface and flow.** Keep native typed request/response records and source ordering. The parent wrapper owns translation to VLSIT flat ports. Exact port declarations:

| Direction | Exact source declaration |
|---|---|
| input | `logic clk_i` |
| input | `logic rst_ni` |
| output | `logic sb_full_o` |
| input | `logic flush_unissued_instr_i` |
| input | `logic flush_i` |
| input | `logic x_transaction_accepted_i` |
| input | `logic x_issue_writeback_i` |
| input | `logic [CVA6Cfg.TRANS_ID_BITS-1:0] x_id_i` |
| output | `scoreboard_entry_t [CVA6Cfg.NrCommitPorts-1:0] commit_instr_o` |
| output | `logic [CVA6Cfg.NrCommitPorts-1:0] commit_drop_o` |
| input | `logic [CVA6Cfg.NrCommitPorts-1:0] commit_ack_i` |
| input | `scoreboard_entry_t [CVA6Cfg.NrIssuePorts-1:0] decoded_instr_i` |
| input | `logic [CVA6Cfg.NrIssuePorts-1:0][31:0] orig_instr_i` |
| input | `logic [CVA6Cfg.NrIssuePorts-1:0] decoded_instr_valid_i` |
| output | `logic [CVA6Cfg.NrIssuePorts-1:0] decoded_instr_ack_o` |
| output | `scoreboard_entry_t [CVA6Cfg.NrIssuePorts-1:0] issue_instr_o` |
| output | `logic [CVA6Cfg.NrIssuePorts-1:0][31:0] orig_instr_o` |
| output | `logic [CVA6Cfg.NrIssuePorts-1:0] issue_instr_valid_o` |
| input | `logic [CVA6Cfg.NrIssuePorts-1:0] issue_ack_i` |
| output | `forwarding_t fwd_o` |
| input | `bp_resolve_t resolved_branch_i` |
| input | `logic [CVA6Cfg.NrWbPorts-1:0][CVA6Cfg.TRANS_ID_BITS-1:0] trans_id_i` |
| input | `logic [CVA6Cfg.NrWbPorts-1:0][CVA6Cfg.XLEN-1:0] wbdata_i` |
| input | `exception_t [CVA6Cfg.NrWbPorts-1:0] ex_i` |
| input | `logic [CVA6Cfg.NrWbPorts-1:0] wt_valid_i` |
| input | `logic x_we_i` |
| input | `logic [4:0] x_rd_i` |
| output | `logic [ CVA6Cfg.NrIssuePorts-1:0][CVA6Cfg.TRANS_ID_BITS-1:0] rvfi_issue_pointer_o` |
| output | `logic [CVA6Cfg.NrCommitPorts-1:0][CVA6Cfg.TRANS_ID_BITS-1:0] rvfi_commit_pointer_o` |

**Recorded local changes (source history, not a substitute for the current contract):**
- Make destination-width extension and truncation explicit at RTL assignments.
- Perform commit-slot offset arithmetic at integer precision before pointer truncation.
- Extend the commit pointer before integer offset addition.

**State/verification.** Native state encodings and helper logic remain source-owned. Coherence/maintenance-relevant state machines are discussed in Section 10; native arithmetic/MMU/helper integration is linted, with only the specific activated CPU/FPU cases described in Section 15. No blanket ISA/FP/MMU or helper-equivalence qualification is claimed.

#### 14.5.54 `serdiv.sv` — MODIFY

Source: [rtl/common/modified/cva6/core/serdiv.sv](../../rtl/modified/cva6/core/serdiv.sv).

**Function and local effect.** simple 64bit serial divider. Preserve the native request/result or storage behavior while applying the explicit local changes recorded below. Its parent consumes the exact typed interfaces in this section; queue, arithmetic, memory and protocol helpers do not create new architectural ownership rules. Native latency/ordering remains source-defined and is not independently qualified by TOP lint.

![serdiv selected modified component](figures/post_a06/serdiv.svg)

```json
{"page_name":"BLOCK_DIAGRAM","out_name":"serdiv.drawio","layout":{"gap_h":120,"gap_v":110,"margin":80,"block_h":60},"top":{"frame_label":["Component composition","(serdiv)"]},"frame_row":["serdiv","Native modified component; function and change contract are specified in Section 14.","rtl/common/modified/cva6/core/serdiv.sv"],"frame_interfaces":[],"blocks":[{"key":"B0","label":["i_lzc_a","(lzc)"],"width":100,"row":0,"col":0,"row_name":"i_lzc_a (lzc)","function":"Native component","source":"REUSE; rtl/common/third_party/cva6/vendor/pulp-platform/common_cells/src/lzc.sv"},{"key":"B1","label":["i_lzc_b","(lzc)"],"width":100,"row":1,"col":0,"row_name":"i_lzc_b (lzc)","function":"Native component","source":"REUSE; rtl/common/third_party/cva6/vendor/pulp-platform/common_cells/src/lzc.sv"}],"connectors":[],"externals":[],"interfaces":[],"nets":[],"legend_note":"Exact source-referenced children; generate multiplicity and active branches are specified in the component text. Containment denotes hierarchy, not invented signal connectivity. NEW/MODIFY/REUSE/GENERATED provenance is listed in the block table. Clock/reset follow the common synchronous contract. Complete parent port declarations are in the component section.","library_sha256":"15DFB183E267D2A94F8CAB316E01EB3D2E9D2F9C006DC816790A394F4123506C"}
```

[Editable draw.io](figures/post_a06/serdiv.drawio) · [Figure source](figures/post_a06/serdiv.json).

**Interface and flow.** Keep native typed request/response records and source ordering. The parent wrapper owns translation to VLSIT flat ports. Exact port declarations:

| Direction | Exact source declaration |
|---|---|
| input | `logic clk_i` |
| input | `logic rst_ni` |
| input | `logic [CVA6Cfg.TRANS_ID_BITS-1:0] id_i` |
| input | `logic [WIDTH-1:0] op_a_i` |
| input | `logic [WIDTH-1:0] op_b_i` |
| input | `logic [1:0] opcode_i` |
| input | `logic in_vld_i` |
| output | `logic in_rdy_o` |
| input | `logic flush_i` |
| output | `logic out_vld_o` |
| input | `logic out_rdy_i` |
| output | `logic [CVA6Cfg.TRANS_ID_BITS-1:0] id_o` |
| output | `logic [WIDTH-1:0] res_o` |

**Recorded local changes (source history, not a substitute for the current contract):**
- Make destination-width extension and truncation explicit at RTL assignments.

**State/verification.** Native state encodings and helper logic remain source-owned. Coherence/maintenance-relevant state machines are discussed in Section 10; native arithmetic/MMU/helper integration is linted, with only the specific activated CPU/FPU cases described in Section 15. No blanket ISA/FP/MMU or helper-equivalence qualification is claimed.

#### 14.5.55 `store_buffer.sv` — MODIFY

Source: [rtl/common/modified/cva6/core/store_buffer.sv](../../rtl/modified/cva6/core/store_buffer.sv).

**Function and local effect.** Retained committed store/CBO queue. Retain effective VA, physical line, operation and completion association. An externally completed CBO dequeues once without issuing a duplicate local maintenance operation.

![store_buffer selected modified component](figures/post_a06/store_buffer.svg)

```json
{"page_name":"BLOCK_DIAGRAM","out_name":"store_buffer.drawio","layout":{"gap_h":120,"gap_v":110,"margin":80,"block_h":60},"top":{"frame_label":["Component composition","(store_buffer)"]},"frame_row":["store_buffer","Native modified component; function and change contract are specified in Section 14.","rtl/common/modified/cva6/core/store_buffer.sv"],"frame_interfaces":["IN","OUT"],"blocks":[{"key":"B0","label":["component_boundary","(store_buffer)"],"width":220,"row":0,"col":0,"row_name":"component_boundary (store_buffer)","function":"Retained committed store/CBO queue","source":"MODIFY; rtl/common/modified/cva6/core/store_buffer.sv"}],"connectors":[],"externals":[{"id":"IN","block":"B0","side":"L","dir":"in","pos":0,"text":["IN","ports"]},{"id":"OUT","block":"B0","side":"R","dir":"out","pos":0,"text":["OUT","ports"]}],"interfaces":[{"id":"IN","name":"Parent in ports","category":"custom","active":"in","signals":"clk_i, rst_ni, flush_i, stall_st_pending_i, page_offset_i, commit_i, valid_i, valid_without_flush_i, paddr_i, vaddr_i, data_i, be_i, data_size_i, cbo_op_i, req_port_i"},{"id":"OUT","name":"Parent out ports","category":"custom","active":"out","signals":"no_st_pending_o, store_buffer_empty_o, page_offset_matches_o, commit_ready_o, ready_o, rvfi_mem_paddr_o, cmo_entry_valid_o, cmo_entry_op_o, cmo_entry_paddr_o, cmo_entry_vaddr_o, req_port_o"}],"nets":[],"legend_note":"A single boundary symbol denotes a leaf: internal equations/registers are described in its function/dataflow contract, not invented child modules. NEW/MODIFY/REUSE/GENERATED provenance is listed in the block table. Clock/reset follow the common synchronous contract. Complete parent port declarations are in the component section.","library_sha256":"15DFB183E267D2A94F8CAB316E01EB3D2E9D2F9C006DC816790A394F4123506C"}
```

[Editable draw.io](figures/post_a06/store_buffer.drawio) · [Figure source](figures/post_a06/store_buffer.json).

**Interface and flow.** Keep native typed request/response records and source ordering. The parent wrapper owns translation to VLSIT flat ports. Exact port declarations:

| Direction | Exact source declaration |
|---|---|
| input | `logic clk_i` |
| input | `logic rst_ni` |
| input | `logic flush_i` |
| input | `logic stall_st_pending_i` |
| output | `logic no_st_pending_o` |
| output | `logic store_buffer_empty_o` |
| input | `logic [11:0] page_offset_i` |
| output | `logic page_offset_matches_o` |
| input | `logic commit_i` |
| output | `logic commit_ready_o` |
| output | `logic ready_o` |
| input | `logic valid_i` |
| input | `logic valid_without_flush_i` |
| input | `logic [CVA6Cfg.PLEN-1:0] paddr_i` |
| input | `logic [CVA6Cfg.VLEN-1:0] vaddr_i` |
| output | `logic [CVA6Cfg.PLEN-1:0] rvfi_mem_paddr_o` |
| input | `logic [CVA6Cfg.XLEN-1:0] data_i` |
| input | `logic [(CVA6Cfg.XLEN/8)-1:0] be_i` |
| input | `logic [1:0] data_size_i` |
| input | `cbo_t cbo_op_i` |
| output | `logic cmo_entry_valid_o` |
| output | `cbo_t cmo_entry_op_o` |
| output | `logic [CVA6Cfg.PLEN-1:0] cmo_entry_paddr_o` |
| output | `logic [CVA6Cfg.VLEN-1:0] cmo_entry_vaddr_o` |
| input | `dcache_req_o_t req_port_i` |
| output | `dcache_req_i_t req_port_o` |

**Recorded local changes (source history, not a substitute for the current contract):**
- Retain each effective virtual address and expose head CBO metadata.
- Route the staged ExternalCmo retirement mode through the LSU hierarchy; external completion dequeues CBO without a duplicate local cache request. Align speculative pointers on simultaneous completion and pipeline flush.

**State/verification.** Native state encodings and helper logic remain source-owned. Coherence/maintenance-relevant state machines are discussed in Section 10; native arithmetic/MMU/helper integration is linted, with only the specific activated CPU/FPU cases described in Section 15. No blanket ISA/FP/MMU or helper-equivalence qualification is claimed.

#### 14.5.56 `store_unit.sv` — MODIFY

Source: [rtl/common/modified/cva6/core/store_unit.sv](../../rtl/modified/cva6/core/store_unit.sv).

**Function and local effect.** Store translation and CBO metadata. Carry decoded maintenance kind and effective address through the native store path to its retained queue/retirement interface; preserve precise errors.

![store_unit selected modified component](figures/post_a06/store_unit.svg)

```json
{"page_name":"BLOCK_DIAGRAM","out_name":"store_unit.drawio","layout":{"gap_h":120,"gap_v":110,"margin":80,"block_h":60},"top":{"frame_label":["Component composition","(store_unit)"]},"frame_row":["store_unit","Native modified component; function and change contract are specified in Section 14.","rtl/common/modified/cva6/core/store_unit.sv"],"frame_interfaces":[],"blocks":[{"key":"B0","label":["i_amo_buffer","(amo_buffer)"],"width":140,"row":0,"col":0,"row_name":"i_amo_buffer (amo_buffer)","function":"Native component","source":"REUSE; rtl/common/third_party/cva6/core/amo_buffer.sv"},{"key":"B1","label":["store_buffer_i","(store_buffer)"],"width":180,"row":1,"col":0,"row_name":"store_buffer_i (store_buffer)","function":"Retained committed store/CBO queue","source":"MODIFY; rtl/common/modified/cva6/core/store_buffer.sv"}],"connectors":[],"externals":[],"interfaces":[],"nets":[],"legend_note":"Exact source-referenced children; generate multiplicity and active branches are specified in the component text. Containment denotes hierarchy, not invented signal connectivity. NEW/MODIFY/REUSE/GENERATED provenance is listed in the block table. Clock/reset follow the common synchronous contract. Complete parent port declarations are in the component section.","library_sha256":"15DFB183E267D2A94F8CAB316E01EB3D2E9D2F9C006DC816790A394F4123506C"}
```

[Editable draw.io](figures/post_a06/store_unit.drawio) · [Figure source](figures/post_a06/store_unit.json).

**Interface and flow.** Keep native typed request/response records and source ordering. The parent wrapper owns translation to VLSIT flat ports. Exact port declarations:

| Direction | Exact source declaration |
|---|---|
| input | `logic clk_i` |
| input | `logic rst_ni` |
| input | `logic flush_i` |
| input | `logic stall_st_pending_i` |
| output | `logic no_st_pending_o` |
| output | `logic store_buffer_empty_o` |
| input | `logic valid_i` |
| input | `lsu_ctrl_t lsu_ctrl_i` |
| output | `logic pop_st_o` |
| input | `logic commit_i` |
| output | `logic commit_ready_o` |
| input | `logic amo_valid_commit_i` |
| input | `logic mbe_i` |
| output | `logic valid_o` |
| output | `logic [CVA6Cfg.TRANS_ID_BITS-1:0] trans_id_o` |
| output | `logic [CVA6Cfg.XLEN-1:0] result_o` |
| output | `exception_t ex_o` |
| output | `logic translation_req_o` |
| output | `logic [CVA6Cfg.VLEN-1:0] vaddr_o` |
| output | `logic [CVA6Cfg.PLEN-1:0] rvfi_mem_paddr_o` |
| output | `logic cmo_entry_valid_o` |
| output | `cbo_t cmo_entry_op_o` |
| output | `logic [CVA6Cfg.PLEN-1:0] cmo_entry_paddr_o` |
| output | `logic [CVA6Cfg.VLEN-1:0] cmo_entry_vaddr_o` |
| output | `logic [31:0] tinst_o` |
| output | `logic hs_ld_st_inst_o` |
| output | `logic hlvx_inst_o` |
| input | `logic [CVA6Cfg.PLEN-1:0] paddr_i` |
| input | `exception_t ex_i` |
| input | `logic dtlb_hit_i` |
| input | `logic [11:0] page_offset_i` |
| output | `logic page_offset_matches_o` |
| output | `amo_req_t amo_req_o` |
| input | `amo_resp_t amo_resp_i` |
| input | `dcache_req_o_t req_port_i` |
| output | `dcache_req_i_t req_port_o` |
| input | `logic sdtrig_store_stall_i` |
| input | `logic [CVA6Cfg.XLEN-1:0] sdtrig_store_action_i` |

**Recorded local changes (source history, not a substitute for the current contract):**
- Export pending CBO metadata from the store buffer to retirement logic.
- Align effective VA with registered store data/op during back-to-back issue.
- Route the staged ExternalCmo retirement mode through the LSU hierarchy; external completion dequeues CBO without a duplicate local cache request.
- DEC-038/A-02: preserve cached atomic errors and precise retirement fault state.

**State/verification.** Native state encodings and helper logic remain source-owned. Coherence/maintenance-relevant state machines are discussed in Section 10; native arithmetic/MMU/helper integration is linted, with only the specific activated CPU/FPU cases described in Section 15. No blanket ISA/FP/MMU or helper-equivalence qualification is claimed.

#### 14.5.57 `axi_pkg.sv` — MODIFY

Source: [rtl/common/modified/cva6/vendor/pulp-platform/axi/src/axi_pkg.sv](../../rtl/modified/cva6/vendor/pulp-platform/axi/src/axi_pkg.sv).

**Function.** Type/configuration/package support; not an instantiable block, so no fictitious block/FSM diagram is supplied. Its definitions are consumed by the selected native component interfaces.

**Recorded local changes (source history, not a substitute for the current contract):**
- Size AXI wrap arithmetic at address precision and byte-index returns at their declared width.

**State/verification.** Native state encodings and helper logic remain source-owned. Coherence/maintenance-relevant state machines are discussed in Section 10; native arithmetic/MMU/helper integration is linted, with only the specific activated CPU/FPU cases described in Section 15. No blanket ISA/FP/MMU or helper-equivalence qualification is claimed.

#### 14.5.58 `lfsr.sv` — MODIFY

Source: [rtl/common/modified/cva6/vendor/pulp-platform/common_cells/src/lfsr.sv](../../rtl/modified/cva6/vendor/pulp-platform/common_cells/src/lfsr.sv).

**Function and local effect.** This is a parametric LFSR with precomputed coefficients for. Preserve the native request/result or storage behavior while applying the explicit local changes recorded below. Its parent consumes the exact typed interfaces in this section; queue, arithmetic, memory and protocol helpers do not create new architectural ownership rules. Native latency/ordering remains source-defined and is not independently qualified by TOP lint.

![lfsr selected modified component](figures/post_a06/lfsr.svg)

```json
{"page_name":"BLOCK_DIAGRAM","out_name":"lfsr.drawio","layout":{"gap_h":120,"gap_v":110,"margin":80,"block_h":60},"top":{"frame_label":["Component composition","(lfsr)"]},"frame_row":["lfsr","Native modified component; function and change contract are specified in Section 14.","rtl/common/modified/cva6/vendor/pulp-platform/common_cells/src/lfsr.sv"],"frame_interfaces":["IN","OUT"],"blocks":[{"key":"B0","label":["component_boundary","(lfsr)"],"width":220,"row":0,"col":0,"row_name":"component_boundary (lfsr)","function":"Native component","source":"MODIFY; rtl/common/modified/cva6/vendor/pulp-platform/common_cells/src/lfsr.sv"}],"connectors":[],"externals":[{"id":"IN","block":"B0","side":"L","dir":"in","pos":0,"text":["IN","ports"]},{"id":"OUT","block":"B0","side":"R","dir":"out","pos":0,"text":["OUT","ports"]}],"interfaces":[{"id":"IN","name":"Parent in ports","category":"custom","active":"in","signals":"clk_i, rst_ni, en_i"},{"id":"OUT","name":"Parent out ports","category":"custom","active":"out","signals":"out_o"}],"nets":[],"legend_note":"A single boundary symbol denotes a leaf: internal equations/registers are described in its function/dataflow contract, not invented child modules. NEW/MODIFY/REUSE/GENERATED provenance is listed in the block table. Clock/reset follow the common synchronous contract. Complete parent port declarations are in the component section.","library_sha256":"15DFB183E267D2A94F8CAB316E01EB3D2E9D2F9C006DC816790A394F4123506C"}
```

[Editable draw.io](figures/post_a06/lfsr.drawio) · [Figure source](figures/post_a06/lfsr.json).

**Interface and flow.** Keep native typed request/response records and source ordering. The parent wrapper owns translation to VLSIT flat ports. Exact port declarations:

| Direction | Exact source declaration |
|---|---|
| input | `logic clk_i` |
| input | `logic rst_ni` |
| input | `logic en_i` |
| output | `logic [OutWidth-1:0] out_o` |

**Recorded local changes (source history, not a substitute for the current contract):**
- Test nonzero reset seed without extending the hardware seed to integer width.

**State/verification.** Native state encodings and helper logic remain source-owned. Coherence/maintenance-relevant state machines are discussed in Section 10; native arithmetic/MMU/helper integration is linted, with only the specific activated CPU/FPU cases described in Section 15. No blanket ISA/FP/MMU or helper-equivalence qualification is claimed.

#### 14.5.59 `rr_arb_tree.sv` — MODIFY

Source: [rtl/common/modified/cva6/vendor/pulp-platform/common_cells/src/rr_arb_tree.sv](../../rtl/modified/cva6/vendor/pulp-platform/common_cells/src/rr_arb_tree.sv).

**Function and local effect.** logarithmic arbitration tree with round robin arbitration scheme.. Preserve the native request/result or storage behavior while applying the explicit local changes recorded below. Its parent consumes the exact typed interfaces in this section; queue, arithmetic, memory and protocol helpers do not create new architectural ownership rules. Native latency/ordering remains source-defined and is not independently qualified by TOP lint.

![rr_arb_tree selected modified component](figures/post_a06/rr_arb_tree.svg)

```json
{"page_name":"BLOCK_DIAGRAM","out_name":"rr_arb_tree.drawio","layout":{"gap_h":120,"gap_v":110,"margin":80,"block_h":60},"top":{"frame_label":["Component composition","(rr_arb_tree)"]},"frame_row":["rr_arb_tree","Native modified component; function and change contract are specified in Section 14.","rtl/common/modified/cva6/vendor/pulp-platform/common_cells/src/rr_arb_tree.sv"],"frame_interfaces":[],"blocks":[{"key":"B0","label":["i_lzc_lower","(lzc)"],"width":140,"row":0,"col":0,"row_name":"i_lzc_lower (lzc)","function":"Native component","source":"REUSE; rtl/common/third_party/cva6/vendor/pulp-platform/common_cells/src/lzc.sv"},{"key":"B1","label":["i_lzc_upper","(lzc)"],"width":140,"row":1,"col":0,"row_name":"i_lzc_upper (lzc)","function":"Native component","source":"REUSE; rtl/common/third_party/cva6/vendor/pulp-platform/common_cells/src/lzc.sv"}],"connectors":[],"externals":[],"interfaces":[],"nets":[],"legend_note":"Exact source-referenced children; generate multiplicity and active branches are specified in the component text. Containment denotes hierarchy, not invented signal connectivity. NEW/MODIFY/REUSE/GENERATED provenance is listed in the block table. Clock/reset follow the common synchronous contract. Complete parent port declarations are in the component section.","library_sha256":"15DFB183E267D2A94F8CAB316E01EB3D2E9D2F9C006DC816790A394F4123506C"}
```

[Editable draw.io](figures/post_a06/rr_arb_tree.drawio) · [Figure source](figures/post_a06/rr_arb_tree.json).

**Interface and flow.** Keep native typed request/response records and source ordering. The parent wrapper owns translation to VLSIT flat ports. Exact port declarations:

| Direction | Exact source declaration |
|---|---|
| input | `logic clk_i` |
| input | `logic rst_ni` |
| input | `logic flush_i` |
| input | `idx_t rr_i` |
| input | `logic [NumIn-1:0] req_i` |
| output | `logic [NumIn-1:0] gnt_o` |
| input | `DataType [NumIn-1:0] data_i` |
| output | `logic req_o` |
| input | `logic gnt_i` |
| output | `DataType data_o` |
| output | `idx_t idx_o` |

**Recorded local changes (source history, not a substitute for the current contract):**
- Separate the first arbitration input from comparisons whose result is constant.

**State/verification.** Native state encodings and helper logic remain source-owned. Coherence/maintenance-relevant state machines are discussed in Section 10; native arithmetic/MMU/helper integration is linted, with only the specific activated CPU/FPU cases described in Section 15. No blanket ISA/FP/MMU or helper-equivalence qualification is claimed.

#### 14.5.60 `stream_demux.sv` — MODIFY

Source: [rtl/common/modified/cva6/vendor/pulp-platform/common_cells/src/stream_demux.sv](../../rtl/modified/cva6/vendor/pulp-platform/common_cells/src/stream_demux.sv).

**Function and local effect.** Native stream demux component. Preserve the native request/result or storage behavior while applying the explicit local changes recorded below. Its parent consumes the exact typed interfaces in this section; queue, arithmetic, memory and protocol helpers do not create new architectural ownership rules. Native latency/ordering remains source-defined and is not independently qualified by TOP lint.

![stream_demux selected modified component](figures/post_a06/stream_demux.svg)

```json
{"page_name":"BLOCK_DIAGRAM","out_name":"stream_demux.drawio","layout":{"gap_h":120,"gap_v":110,"margin":80,"block_h":60},"top":{"frame_label":["Component composition","(stream_demux)"]},"frame_row":["stream_demux","Native modified component; function and change contract are specified in Section 14.","rtl/common/modified/cva6/vendor/pulp-platform/common_cells/src/stream_demux.sv"],"frame_interfaces":["IN","OUT"],"blocks":[{"key":"B0","label":["component_boundary","(stream_demux)"],"width":220,"row":0,"col":0,"row_name":"component_boundary (stream_demux)","function":"Native component","source":"MODIFY; rtl/common/modified/cva6/vendor/pulp-platform/common_cells/src/stream_demux.sv"}],"connectors":[],"externals":[{"id":"IN","block":"B0","side":"L","dir":"in","pos":0,"text":["IN","ports"]},{"id":"OUT","block":"B0","side":"R","dir":"out","pos":0,"text":["OUT","ports"]}],"interfaces":[{"id":"IN","name":"Parent in ports","category":"custom","active":"in","signals":"inp_valid_i, oup_sel_i, oup_ready_i"},{"id":"OUT","name":"Parent out ports","category":"custom","active":"out","signals":"inp_ready_o, oup_valid_o"}],"nets":[],"legend_note":"A single boundary symbol denotes a leaf: internal equations/registers are described in its function/dataflow contract, not invented child modules. NEW/MODIFY/REUSE/GENERATED provenance is listed in the block table. Clock/reset follow the common synchronous contract. Complete parent port declarations are in the component section.","library_sha256":"15DFB183E267D2A94F8CAB316E01EB3D2E9D2F9C006DC816790A394F4123506C"}
```

[Editable draw.io](figures/post_a06/stream_demux.drawio) · [Figure source](figures/post_a06/stream_demux.json).

**Interface and flow.** Keep native typed request/response records and source ordering. The parent wrapper owns translation to VLSIT flat ports. Exact port declarations:

| Direction | Exact source declaration |
|---|---|
| input | `logic inp_valid_i` |
| output | `logic inp_ready_o` |
| input | `logic [LOG_N_OUP-1:0] oup_sel_i` |
| output | `logic [N_OUP-1:0] oup_valid_o` |
| input | `logic [N_OUP-1:0] oup_ready_i` |

**Recorded local changes (source history, not a substitute for the current contract):**
- Size the default demultiplexer index-width parameter as an integer.

**State/verification.** Native state encodings and helper logic remain source-owned. Coherence/maintenance-relevant state machines are discussed in Section 10; native arithmetic/MMU/helper integration is linted, with only the specific activated CPU/FPU cases described in Section 15. No blanket ISA/FP/MMU or helper-equivalence qualification is claimed.

#### 14.5.61 `tc_sram.sv` — MODIFY

Source: [rtl/common/modified/cva6/vendor/pulp-platform/tech_cells_generic/src/rtl/tc_sram.sv](../../rtl/modified/cva6/vendor/pulp-platform/tech_cells_generic/src/rtl/tc_sram.sv).

**Function and local effect.** Functional module of a generic SRAM. Preserve the native request/result or storage behavior while applying the explicit local changes recorded below. Its parent consumes the exact typed interfaces in this section; queue, arithmetic, memory and protocol helpers do not create new architectural ownership rules. Native latency/ordering remains source-defined and is not independently qualified by TOP lint.

![tc_sram selected modified component](figures/post_a06/tc_sram.svg)

```json
{"page_name":"BLOCK_DIAGRAM","out_name":"tc_sram.drawio","layout":{"gap_h":120,"gap_v":110,"margin":80,"block_h":60},"top":{"frame_label":["Component composition","(tc_sram)"]},"frame_row":["tc_sram","Native modified component; function and change contract are specified in Section 14.","rtl/common/modified/cva6/vendor/pulp-platform/tech_cells_generic/src/rtl/tc_sram.sv"],"frame_interfaces":["IN","OUT"],"blocks":[{"key":"B0","label":["component_boundary","(tc_sram)"],"width":220,"row":0,"col":0,"row_name":"component_boundary (tc_sram)","function":"Native component","source":"MODIFY; rtl/common/modified/cva6/vendor/pulp-platform/tech_cells_generic/src/rtl/tc_sram.sv"}],"connectors":[],"externals":[{"id":"IN","block":"B0","side":"L","dir":"in","pos":0,"text":["IN","ports"]},{"id":"OUT","block":"B0","side":"R","dir":"out","pos":0,"text":["OUT","ports"]}],"interfaces":[{"id":"IN","name":"Parent in ports","category":"custom","active":"in","signals":"clk_i, rst_ni, req_i, we_i, addr_i, wdata_i, be_i"},{"id":"OUT","name":"Parent out ports","category":"custom","active":"out","signals":"rdata_o"}],"nets":[],"legend_note":"A single boundary symbol denotes a leaf: internal equations/registers are described in its function/dataflow contract, not invented child modules. NEW/MODIFY/REUSE/GENERATED provenance is listed in the block table. Clock/reset follow the common synchronous contract. Complete parent port declarations are in the component section.","library_sha256":"15DFB183E267D2A94F8CAB316E01EB3D2E9D2F9C006DC816790A394F4123506C"}
```

[Editable draw.io](figures/post_a06/tc_sram.drawio) · [Figure source](figures/post_a06/tc_sram.json).

**Interface and flow.** Keep native typed request/response records and source ordering. The parent wrapper owns translation to VLSIT flat ports. Exact port declarations:

| Direction | Exact source declaration |
|---|---|
| input | `logic clk_i` |
| input | `logic rst_ni` |
| input | `logic [NumPorts-1:0] req_i` |
| input | `logic [NumPorts-1:0] we_i` |
| input | `addr_t [NumPorts-1:0] addr_i` |
| input | `data_t [NumPorts-1:0] wdata_i` |
| input | `be_t [NumPorts-1:0] be_i` |
| output | `data_t [NumPorts-1:0] rdata_o` |

**Recorded local changes (source history, not a substitute for the current contract):**
- Make destination-width extension and truncation explicit at RTL assignments.
- Use a string-valued SRAM simulation initialization mode.
- Declare the simulation initialization mode as a string.
- Express the SRAM read shift loop without a zero unsigned upper bound.

**State/verification.** Native state encodings and helper logic remain source-owned. Coherence/maintenance-relevant state machines are discussed in Section 10; native arithmetic/MMU/helper integration is linted, with only the specific activated CPU/FPU cases described in Section 15. No blanket ISA/FP/MMU or helper-equivalence qualification is claimed.

#### 14.5.62 `fpnew_cast_multi.sv` — MODIFY

Source: [rtl/common/modified/cvfpu/src/fpnew_cast_multi.sv](../../rtl/modified/cvfpu/src/fpnew_cast_multi.sv).

**Function and local effect.** Native fpnew cast multi component. Preserve the native request/result or storage behavior while applying the explicit local changes recorded below. Its parent consumes the exact typed interfaces in this section; queue, arithmetic, memory and protocol helpers do not create new architectural ownership rules. Native latency/ordering remains source-defined and is not independently qualified by TOP lint.

![fpnew_cast_multi selected modified component](figures/post_a06/fpnew_cast_multi.svg)

```json
{"page_name":"BLOCK_DIAGRAM","out_name":"fpnew_cast_multi.drawio","layout":{"gap_h":120,"gap_v":110,"margin":80,"block_h":60},"top":{"frame_label":["Component composition","(fpnew_cast_multi)"]},"frame_row":["fpnew_cast_multi","Native modified component; function and change contract are specified in Section 14.","rtl/common/modified/cvfpu/src/fpnew_cast_multi.sv"],"frame_interfaces":[],"blocks":[{"key":"B0","label":["i_fpnew_classifier","(fpnew_classifier)"],"width":220,"row":0,"col":0,"row_name":"i_fpnew_classifier (fpnew_classifier)","function":"Native component","source":"REUSE; rtl/common/third_party/cvfpu/src/fpnew_classifier.sv"},{"key":"B1","label":["i_fpnew_rounding","(fpnew_rounding)"],"width":200,"row":0,"col":1,"row_name":"i_fpnew_rounding (fpnew_rounding)","function":"Native component","source":"REUSE; rtl/common/third_party/cvfpu/src/fpnew_rounding.sv"},{"key":"B2","label":["i_lzc","(lzc)"],"width":60,"row":1,"col":0,"row_name":"i_lzc (lzc)","function":"Native component","source":"REUSE; rtl/common/third_party/cva6/vendor/pulp-platform/common_cells/src/lzc.sv"}],"connectors":[],"externals":[],"interfaces":[],"nets":[],"legend_note":"Exact source-referenced children; generate multiplicity and active branches are specified in the component text. Containment denotes hierarchy, not invented signal connectivity. NEW/MODIFY/REUSE/GENERATED provenance is listed in the block table. Clock/reset follow the common synchronous contract. Complete parent port declarations are in the component section.","library_sha256":"15DFB183E267D2A94F8CAB316E01EB3D2E9D2F9C006DC816790A394F4123506C"}
```

[Editable draw.io](figures/post_a06/fpnew_cast_multi.drawio) · [Figure source](figures/post_a06/fpnew_cast_multi.json).

**Interface and flow.** Keep native typed request/response records and source ordering. The parent wrapper owns translation to VLSIT flat ports. Exact port declarations:

| Direction | Exact source declaration |
|---|---|
| input | `logic clk_i` |
| input | `logic rst_ni` |
| input | `logic [WIDTH-1:0] operands_i` |
| input | `logic [NUM_FORMATS-1:0] is_boxed_i` |
| input | `fpnew_pkg::roundmode_e rnd_mode_i` |
| input | `fpnew_pkg::operation_e op_i` |
| input | `logic op_mod_i` |
| input | `fpnew_pkg::fp_format_e src_fmt_i` |
| input | `fpnew_pkg::fp_format_e dst_fmt_i` |
| input | `fpnew_pkg::int_format_e int_fmt_i` |
| input | `TagType tag_i` |
| input | `logic mask_i` |
| input | `AuxType aux_i` |
| input | `logic in_valid_i` |
| output | `logic in_ready_o` |
| input | `logic flush_i` |
| output | `logic [WIDTH-1:0] result_o` |
| output | `fpnew_pkg::status_t status_o` |
| output | `logic extension_bit_o` |
| output | `TagType tag_o` |
| output | `logic mask_o` |
| output | `AuxType aux_o` |
| output | `logic out_valid_o` |
| input | `logic out_ready_i` |
| output | `logic busy_o` |
| input | `logic [ExtRegEnaWidth-1:0] reg_ena_i` |
| output | `logic early_out_valid_o` |

**Recorded local changes (source history, not a substitute for the current contract):**
- Make destination-width extension and truncation explicit at RTL assignments.
- Size conversion exponent arithmetic and shift operands while retaining signedness.
- Extend the signed normalization count to the internal exponent width.
- Use descending packed dimensions and explicitly indexed format/group constants.

**State/verification.** Native state encodings and helper logic remain source-owned. Coherence/maintenance-relevant state machines are discussed in Section 10; native arithmetic/MMU/helper integration is linted, with only the specific activated CPU/FPU cases described in Section 15. No blanket ISA/FP/MMU or helper-equivalence qualification is claimed.

#### 14.5.63 `fpnew_divsqrt_th_64_multi.sv` — MODIFY

Source: [rtl/common/modified/cvfpu/src/fpnew_divsqrt_th_64_multi.sv](../../rtl/modified/cvfpu/src/fpnew_divsqrt_th_64_multi.sv).

**Function and local effect.** Native fpnew divsqrt th 64 multi component. Preserve the native request/result or storage behavior while applying the explicit local changes recorded below. Its parent consumes the exact typed interfaces in this section; queue, arithmetic, memory and protocol helpers do not create new architectural ownership rules. Native latency/ordering remains source-defined and is not independently qualified by TOP lint.

![fpnew_divsqrt_th_64_multi selected modified component](figures/post_a06/fpnew_divsqrt_th_64_multi.svg)

```json
{"page_name":"BLOCK_DIAGRAM","out_name":"fpnew_divsqrt_th_64_multi.drawio","layout":{"gap_h":120,"gap_v":110,"margin":80,"block_h":60},"top":{"frame_label":["Component composition","(fpnew_divsqrt_th_64_multi)"]},"frame_row":["fpnew_divsqrt_th_64_multi","Native modified component; function and change contract are specified in Section 14.","rtl/common/modified/cvfpu/src/fpnew_divsqrt_th_64_multi.sv"],"frame_interfaces":[],"blocks":[{"key":"B0","label":["i_ct_vfdsu_top","(ct_vfdsu_top)"],"width":180,"row":0,"col":0,"row_name":"i_ct_vfdsu_top (ct_vfdsu_top)","function":"Native component","source":"REUSE; rtl/common/third_party/cvfpu/vendor/openc910/C910_RTL_FACTORY/gen_rtl/vfdsu/rtl/ct_vfdsu_top.v"}],"connectors":[],"externals":[],"interfaces":[],"nets":[],"legend_note":"Exact source-referenced children; generate multiplicity and active branches are specified in the component text. Containment denotes hierarchy, not invented signal connectivity. NEW/MODIFY/REUSE/GENERATED provenance is listed in the block table. Clock/reset follow the common synchronous contract. Complete parent port declarations are in the component section.","library_sha256":"15DFB183E267D2A94F8CAB316E01EB3D2E9D2F9C006DC816790A394F4123506C"}
```

[Editable draw.io](figures/post_a06/fpnew_divsqrt_th_64_multi.drawio) · [Figure source](figures/post_a06/fpnew_divsqrt_th_64_multi.json).

**Interface and flow.** Keep native typed request/response records and source ordering. The parent wrapper owns translation to VLSIT flat ports. Exact port declarations:

| Direction | Exact source declaration |
|---|---|
| input | `logic clk_i` |
| input | `logic rst_ni` |
| input | `logic [1:0][WIDTH-1:0] operands_i` |
| input | `logic [NUM_FORMATS-1:0][1:0] is_boxed_i` |
| input | `fpnew_pkg::roundmode_e rnd_mode_i` |
| input | `fpnew_pkg::operation_e op_i` |
| input | `fpnew_pkg::fp_format_e dst_fmt_i` |
| input | `TagType tag_i` |
| input | `logic mask_i` |
| input | `AuxType aux_i` |
| input | `logic vectorial_op_i` |
| input | `logic in_valid_i` |
| output | `logic in_ready_o` |
| output | `logic divsqrt_done_o` |
| input | `logic simd_synch_done_i` |
| output | `logic divsqrt_ready_o` |
| input | `logic simd_synch_rdy_i` |
| input | `logic flush_i` |
| output | `logic [WIDTH-1:0] result_o` |
| output | `fpnew_pkg::status_t status_o` |
| output | `logic extension_bit_o` |
| output | `TagType tag_o` |
| output | `logic mask_o` |
| output | `AuxType aux_o` |
| output | `logic out_valid_o` |
| input | `logic out_ready_i` |
| output | `logic busy_o` |
| input | `logic [ExtRegEnaWidth-1:0] reg_ena_i` |
| output | `logic early_out_valid_o` |

**Recorded local changes (source history, not a substitute for the current contract):**
- Reset the single-bit vector-operation pipeline flag with a single-bit zero.
- Use descending packed dimensions and explicitly indexed format/group constants.

**State/verification.** Native state encodings and helper logic remain source-owned. Coherence/maintenance-relevant state machines are discussed in Section 10; native arithmetic/MMU/helper integration is linted, with only the specific activated CPU/FPU cases described in Section 15. No blanket ISA/FP/MMU or helper-equivalence qualification is claimed.

#### 14.5.64 `fpnew_fma.sv` — MODIFY

Source: [rtl/common/modified/cvfpu/src/fpnew_fma.sv](../../rtl/modified/cvfpu/src/fpnew_fma.sv).

**Function and local effect.** Native fpnew fma component. Preserve the native request/result or storage behavior while applying the explicit local changes recorded below. Its parent consumes the exact typed interfaces in this section; queue, arithmetic, memory and protocol helpers do not create new architectural ownership rules. Native latency/ordering remains source-defined and is not independently qualified by TOP lint.

![fpnew_fma selected modified component](figures/post_a06/fpnew_fma.svg)

```json
{"page_name":"BLOCK_DIAGRAM","out_name":"fpnew_fma.drawio","layout":{"gap_h":120,"gap_v":110,"margin":80,"block_h":60},"top":{"frame_label":["Component composition","(fpnew_fma)"]},"frame_row":["fpnew_fma","Native modified component; function and change contract are specified in Section 14.","rtl/common/modified/cvfpu/src/fpnew_fma.sv"],"frame_interfaces":[],"blocks":[{"key":"B0","label":["i_class_inputs","(fpnew_classifier)"],"width":220,"row":0,"col":0,"row_name":"i_class_inputs (fpnew_classifier)","function":"Native component","source":"REUSE; rtl/common/third_party/cvfpu/src/fpnew_classifier.sv"},{"key":"B1","label":["i_fpnew_rounding","(fpnew_rounding)"],"width":200,"row":0,"col":1,"row_name":"i_fpnew_rounding (fpnew_rounding)","function":"Native component","source":"REUSE; rtl/common/third_party/cvfpu/src/fpnew_rounding.sv"},{"key":"B2","label":["i_lzc","(lzc)"],"width":60,"row":1,"col":0,"row_name":"i_lzc (lzc)","function":"Native component","source":"REUSE; rtl/common/third_party/cva6/vendor/pulp-platform/common_cells/src/lzc.sv"}],"connectors":[],"externals":[],"interfaces":[],"nets":[],"legend_note":"Exact source-referenced children; generate multiplicity and active branches are specified in the component text. Containment denotes hierarchy, not invented signal connectivity. NEW/MODIFY/REUSE/GENERATED provenance is listed in the block table. Clock/reset follow the common synchronous contract. Complete parent port declarations are in the component section.","library_sha256":"15DFB183E267D2A94F8CAB316E01EB3D2E9D2F9C006DC816790A394F4123506C"}
```

[Editable draw.io](figures/post_a06/fpnew_fma.drawio) · [Figure source](figures/post_a06/fpnew_fma.json).

**Interface and flow.** Keep native typed request/response records and source ordering. The parent wrapper owns translation to VLSIT flat ports. Exact port declarations:

| Direction | Exact source declaration |
|---|---|
| input | `logic clk_i` |
| input | `logic rst_ni` |
| input | `logic [2:0][WIDTH-1:0] operands_i` |
| input | `logic [2:0] is_boxed_i` |
| input | `fpnew_pkg::roundmode_e rnd_mode_i` |
| input | `fpnew_pkg::operation_e op_i` |
| input | `logic op_mod_i` |
| input | `TagType tag_i` |
| input | `logic mask_i` |
| input | `AuxType aux_i` |
| input | `logic in_valid_i` |
| output | `logic in_ready_o` |
| input | `logic flush_i` |
| output | `logic [WIDTH-1:0] result_o` |
| output | `fpnew_pkg::status_t status_o` |
| output | `logic extension_bit_o` |
| output | `TagType tag_o` |
| output | `logic mask_o` |
| output | `AuxType aux_o` |
| output | `logic out_valid_o` |
| input | `logic out_ready_i` |
| output | `logic busy_o` |
| input | `logic [ExtRegEnaWidth-1:0] reg_ena_i` |
| output | `logic early_out_valid_o` |

**Recorded local changes (source history, not a substitute for the current contract):**
- Make destination-width extension and truncation explicit at RTL assignments.
- Size floating-point fields and arithmetic extensions explicitly without changing round stages.
- Use descending packed dimensions and explicitly indexed format/group constants.

**State/verification.** Native state encodings and helper logic remain source-owned. Coherence/maintenance-relevant state machines are discussed in Section 10; native arithmetic/MMU/helper integration is linted, with only the specific activated CPU/FPU cases described in Section 15. No blanket ISA/FP/MMU or helper-equivalence qualification is claimed.

#### 14.5.65 `fpnew_noncomp.sv` — MODIFY

Source: [rtl/common/modified/cvfpu/src/fpnew_noncomp.sv](../../rtl/modified/cvfpu/src/fpnew_noncomp.sv).

**Function and local effect.** Native fpnew noncomp component. Preserve the native request/result or storage behavior while applying the explicit local changes recorded below. Its parent consumes the exact typed interfaces in this section; queue, arithmetic, memory and protocol helpers do not create new architectural ownership rules. Native latency/ordering remains source-defined and is not independently qualified by TOP lint.

![fpnew_noncomp selected modified component](figures/post_a06/fpnew_noncomp.svg)

```json
{"page_name":"BLOCK_DIAGRAM","out_name":"fpnew_noncomp.drawio","layout":{"gap_h":120,"gap_v":110,"margin":80,"block_h":60},"top":{"frame_label":["Component composition","(fpnew_noncomp)"]},"frame_row":["fpnew_noncomp","Native modified component; function and change contract are specified in Section 14.","rtl/common/modified/cvfpu/src/fpnew_noncomp.sv"],"frame_interfaces":[],"blocks":[{"key":"B0","label":["i_class_a","(fpnew_classifier)"],"width":220,"row":0,"col":0,"row_name":"i_class_a (fpnew_classifier)","function":"Native component","source":"REUSE; rtl/common/third_party/cvfpu/src/fpnew_classifier.sv"}],"connectors":[],"externals":[],"interfaces":[],"nets":[],"legend_note":"Exact source-referenced children; generate multiplicity and active branches are specified in the component text. Containment denotes hierarchy, not invented signal connectivity. NEW/MODIFY/REUSE/GENERATED provenance is listed in the block table. Clock/reset follow the common synchronous contract. Complete parent port declarations are in the component section.","library_sha256":"15DFB183E267D2A94F8CAB316E01EB3D2E9D2F9C006DC816790A394F4123506C"}
```

[Editable draw.io](figures/post_a06/fpnew_noncomp.drawio) · [Figure source](figures/post_a06/fpnew_noncomp.json).

**Interface and flow.** Keep native typed request/response records and source ordering. The parent wrapper owns translation to VLSIT flat ports. Exact port declarations:

| Direction | Exact source declaration |
|---|---|
| input | `logic clk_i` |
| input | `logic rst_ni` |
| input | `logic [1:0][WIDTH-1:0] operands_i` |
| input | `logic [1:0] is_boxed_i` |
| input | `fpnew_pkg::roundmode_e rnd_mode_i` |
| input | `fpnew_pkg::operation_e op_i` |
| input | `logic op_mod_i` |
| input | `TagType tag_i` |
| input | `logic mask_i` |
| input | `AuxType aux_i` |
| input | `logic in_valid_i` |
| output | `logic in_ready_o` |
| input | `logic flush_i` |
| output | `logic [WIDTH-1:0] result_o` |
| output | `fpnew_pkg::status_t status_o` |
| output | `logic extension_bit_o` |
| output | `fpnew_pkg::classmask_e class_mask_o` |
| output | `logic is_class_o` |
| output | `TagType tag_o` |
| output | `logic mask_o` |
| output | `AuxType aux_o` |
| output | `logic out_valid_o` |
| input | `logic out_ready_i` |
| output | `logic busy_o` |
| input | `logic [ExtRegEnaWidth-1:0] reg_ena_i` |
| output | `logic early_out_valid_o` |

**Recorded local changes (source history, not a substitute for the current contract):**
- Make destination-width extension and truncation explicit at RTL assignments.
- Size floating-point fields and arithmetic extensions explicitly without changing round stages.
- Use descending packed dimensions and explicitly indexed format/group constants.

**State/verification.** Native state encodings and helper logic remain source-owned. Coherence/maintenance-relevant state machines are discussed in Section 10; native arithmetic/MMU/helper integration is linted, with only the specific activated CPU/FPU cases described in Section 15. No blanket ISA/FP/MMU or helper-equivalence qualification is claimed.

#### 14.5.66 `fpnew_opgroup_block.sv` — MODIFY

Source: [rtl/common/modified/cvfpu/src/fpnew_opgroup_block.sv](../../rtl/modified/cvfpu/src/fpnew_opgroup_block.sv).

**Function and local effect.** Native FPU operation-group routing. Drive merged-format readiness from the scalar slice result rather than reading a packed ready vector while driving it; preserve format selection, payload and configured latency.

![fpnew_opgroup_block selected modified component](figures/post_a06/fpnew_opgroup_block.svg)

```json
{"page_name":"BLOCK_DIAGRAM","out_name":"fpnew_opgroup_block.drawio","layout":{"gap_h":120,"gap_v":110,"margin":80,"block_h":60},"top":{"frame_label":["Component composition","(fpnew_opgroup_block)"]},"frame_row":["fpnew_opgroup_block","Native modified component; function and change contract are specified in Section 14.","rtl/common/modified/cvfpu/src/fpnew_opgroup_block.sv"],"frame_interfaces":[],"blocks":[{"key":"B0","label":["i_fmt_slice","(fpnew_opgroup_fmt_slice)"],"width":300,"row":0,"col":0,"row_name":"i_fmt_slice (fpnew_opgroup_fmt_slice)","function":"Native component","source":"MODIFY; rtl/common/modified/cvfpu/src/fpnew_opgroup_fmt_slice.sv"},{"key":"B1","label":["i_multifmt_slice","(fpnew_opgroup_multifmt_slice)"],"width":360,"row":0,"col":1,"row_name":"i_multifmt_slice (fpnew_opgroup_multifmt_slice)","function":"Native component","source":"MODIFY; rtl/common/modified/cvfpu/src/fpnew_opgroup_multifmt_slice.sv"},{"key":"B2","label":["i_arbiter","(rr_arb_tree)"],"width":160,"row":1,"col":0,"row_name":"i_arbiter (rr_arb_tree)","function":"Native component","source":"MODIFY; rtl/common/modified/cva6/vendor/pulp-platform/common_cells/src/rr_arb_tree.sv"}],"connectors":[],"externals":[],"interfaces":[],"nets":[],"legend_note":"Exact source-referenced children; generate multiplicity and active branches are specified in the component text. Containment denotes hierarchy, not invented signal connectivity. NEW/MODIFY/REUSE/GENERATED provenance is listed in the block table. Clock/reset follow the common synchronous contract. Complete parent port declarations are in the component section.","library_sha256":"15DFB183E267D2A94F8CAB316E01EB3D2E9D2F9C006DC816790A394F4123506C"}
```

[Editable draw.io](figures/post_a06/fpnew_opgroup_block.drawio) · [Figure source](figures/post_a06/fpnew_opgroup_block.json).

**Interface and flow.** Keep native typed request/response records and source ordering. The parent wrapper owns translation to VLSIT flat ports. Exact port declarations:

| Direction | Exact source declaration |
|---|---|
| input | `logic clk_i` |
| input | `logic rst_ni` |
| input | `logic [NUM_OPERANDS-1:0][Width-1:0] operands_i` |
| input | `logic [NUM_FORMATS-1:0][NUM_OPERANDS-1:0] is_boxed_i` |
| input | `fpnew_pkg::roundmode_e rnd_mode_i` |
| input | `fpnew_pkg::operation_e op_i` |
| input | `logic op_mod_i` |
| input | `fpnew_pkg::fp_format_e src_fmt_i` |
| input | `fpnew_pkg::fp_format_e dst_fmt_i` |
| input | `fpnew_pkg::int_format_e int_fmt_i` |
| input | `logic vectorial_op_i` |
| input | `TagType tag_i` |
| input | `MaskType simd_mask_i` |
| input | `logic in_valid_i` |
| output | `logic in_ready_o` |
| input | `logic flush_i` |
| output | `logic [Width-1:0] result_o` |
| output | `fpnew_pkg::status_t status_o` |
| output | `logic extension_bit_o` |
| output | `TagType tag_o` |
| output | `logic out_valid_o` |
| input | `logic out_ready_i` |
| output | `logic busy_o` |
| output | `logic early_valid_o` |

**Recorded local changes (source history, not a substitute for the current contract):**
- Drive merged format readiness from the slice directly, not from a bit of the ready vector that the alias also drives. Preserve all format routing.

**State/verification.** Native state encodings and helper logic remain source-owned. Coherence/maintenance-relevant state machines are discussed in Section 10; native arithmetic/MMU/helper integration is linted, with only the specific activated CPU/FPU cases described in Section 15. No blanket ISA/FP/MMU or helper-equivalence qualification is claimed.

#### 14.5.67 `fpnew_opgroup_fmt_slice.sv` — MODIFY

Source: [rtl/common/modified/cvfpu/src/fpnew_opgroup_fmt_slice.sv](../../rtl/modified/cvfpu/src/fpnew_opgroup_fmt_slice.sv).

**Function and local effect.** Native fpnew opgroup fmt slice component. Preserve the native request/result or storage behavior while applying the explicit local changes recorded below. Its parent consumes the exact typed interfaces in this section; queue, arithmetic, memory and protocol helpers do not create new architectural ownership rules. Native latency/ordering remains source-defined and is not independently qualified by TOP lint.

![fpnew_opgroup_fmt_slice selected modified component](figures/post_a06/fpnew_opgroup_fmt_slice.svg)

```json
{"page_name":"BLOCK_DIAGRAM","out_name":"fpnew_opgroup_fmt_slice.drawio","layout":{"gap_h":120,"gap_v":110,"margin":80,"block_h":60},"top":{"frame_label":["Component composition","(fpnew_opgroup_fmt_slice)"]},"frame_row":["fpnew_opgroup_fmt_slice","Native modified component; function and change contract are specified in Section 14.","rtl/common/modified/cvfpu/src/fpnew_opgroup_fmt_slice.sv"],"frame_interfaces":[],"blocks":[{"key":"B0","label":["i_fma","(fpnew_fma)"],"width":140,"row":0,"col":0,"row_name":"i_fma (fpnew_fma)","function":"Native component","source":"MODIFY; rtl/common/modified/cvfpu/src/fpnew_fma.sv"},{"key":"B1","label":["i_noncomp","(fpnew_noncomp)"],"width":180,"row":1,"col":0,"row_name":"i_noncomp (fpnew_noncomp)","function":"Native component","source":"MODIFY; rtl/common/modified/cvfpu/src/fpnew_noncomp.sv"}],"connectors":[],"externals":[],"interfaces":[],"nets":[],"legend_note":"Exact source-referenced children; generate multiplicity and active branches are specified in the component text. Containment denotes hierarchy, not invented signal connectivity. NEW/MODIFY/REUSE/GENERATED provenance is listed in the block table. Clock/reset follow the common synchronous contract. Complete parent port declarations are in the component section.","library_sha256":"15DFB183E267D2A94F8CAB316E01EB3D2E9D2F9C006DC816790A394F4123506C"}
```

[Editable draw.io](figures/post_a06/fpnew_opgroup_fmt_slice.drawio) · [Figure source](figures/post_a06/fpnew_opgroup_fmt_slice.json).

**Interface and flow.** Keep native typed request/response records and source ordering. The parent wrapper owns translation to VLSIT flat ports. Exact port declarations:

| Direction | Exact source declaration |
|---|---|
| input | `logic clk_i` |
| input | `logic rst_ni` |
| input | `logic [NUM_OPERANDS-1:0][Width-1:0] operands_i` |
| input | `logic [NUM_OPERANDS-1:0] is_boxed_i` |
| input | `fpnew_pkg::roundmode_e rnd_mode_i` |
| input | `fpnew_pkg::operation_e op_i` |
| input | `logic op_mod_i` |
| input | `logic vectorial_op_i` |
| input | `TagType tag_i` |
| input | `MaskType simd_mask_i` |
| input | `logic in_valid_i` |
| output | `logic in_ready_o` |
| input | `logic flush_i` |
| output | `logic [Width-1:0] result_o` |
| output | `fpnew_pkg::status_t status_o` |
| output | `logic extension_bit_o` |
| output | `TagType tag_o` |
| output | `logic out_valid_o` |
| input | `logic out_ready_i` |
| output | `logic busy_o` |
| input | `logic [ExtRegEnaWidth-1:0] reg_ena_i` |
| output | `logic early_out_valid_o` |

**Recorded local changes (source history, not a substitute for the current contract):**
- Make destination-width extension and truncation explicit at RTL assignments.
- Use Boolean SIMD-class selection and explicitly extend scalar class masks.

**State/verification.** Native state encodings and helper logic remain source-owned. Coherence/maintenance-relevant state machines are discussed in Section 10; native arithmetic/MMU/helper integration is linted, with only the specific activated CPU/FPU cases described in Section 15. No blanket ISA/FP/MMU or helper-equivalence qualification is claimed.

#### 14.5.68 `fpnew_opgroup_multifmt_slice.sv` — MODIFY

Source: [rtl/common/modified/cvfpu/src/fpnew_opgroup_multifmt_slice.sv](../../rtl/modified/cvfpu/src/fpnew_opgroup_multifmt_slice.sv).

**Function and local effect.** Native fpnew opgroup multifmt slice component. Preserve the native request/result or storage behavior while applying the explicit local changes recorded below. Its parent consumes the exact typed interfaces in this section; queue, arithmetic, memory and protocol helpers do not create new architectural ownership rules. Native latency/ordering remains source-defined and is not independently qualified by TOP lint.

![fpnew_opgroup_multifmt_slice selected modified component](figures/post_a06/fpnew_opgroup_multifmt_slice.svg)

```json
{"page_name":"BLOCK_DIAGRAM","out_name":"fpnew_opgroup_multifmt_slice.drawio","layout":{"gap_h":120,"gap_v":110,"margin":80,"block_h":60},"top":{"frame_label":["Component composition","(fpnew_opgroup_multifmt_slice)"]},"frame_row":["fpnew_opgroup_multifmt_slice","Native modified component; function and change contract are specified in Section 14.","rtl/common/modified/cvfpu/src/fpnew_opgroup_multifmt_slice.sv"],"frame_interfaces":[],"blocks":[{"key":"B0","label":["i_fpnew_cast_multi","(fpnew_cast_multi)"],"width":220,"row":0,"col":0,"row_name":"i_fpnew_cast_multi (fpnew_cast_multi)","function":"Native component","source":"MODIFY; rtl/common/modified/cvfpu/src/fpnew_cast_multi.sv"},{"key":"B1","label":["i_fpnew_divsqrt_multi","(fpnew_divsqrt_multi)"],"width":260,"row":0,"col":1,"row_name":"i_fpnew_divsqrt_multi (fpnew_divsqrt_multi)","function":"Native component","source":"REUSE; rtl/common/third_party/cvfpu/src/fpnew_divsqrt_multi.sv"},{"key":"B2","label":["i_fpnew_divsqrt_multi_th","(fpnew_divsqrt_th_32)"],"width":280,"row":1,"col":0,"row_name":"i_fpnew_divsqrt_multi_th (fpnew_divsqrt_th_32)","function":"Native component","source":"REUSE; rtl/common/third_party/cvfpu/src/fpnew_divsqrt_th_32.sv"},{"key":"B3","label":["i_fpnew_divsqrt_th_64_c910","(fpnew_divsqrt_th_64_multi)"],"width":320,"row":1,"col":1,"row_name":"i_fpnew_divsqrt_th_64_c910 (fpnew_divsqrt_th_64_multi)","function":"Native component","source":"MODIFY; rtl/common/modified/cvfpu/src/fpnew_divsqrt_th_64_multi.sv"},{"key":"B4","label":["i_fpnew_fma_multi","(fpnew_fma_multi)"],"width":200,"row":2,"col":0,"row_name":"i_fpnew_fma_multi (fpnew_fma_multi)","function":"Native component","source":"REUSE; rtl/common/third_party/cvfpu/src/fpnew_fma_multi.sv"}],"connectors":[],"externals":[],"interfaces":[],"nets":[],"legend_note":"Exact source-referenced children; generate multiplicity and active branches are specified in the component text. Containment denotes hierarchy, not invented signal connectivity. NEW/MODIFY/REUSE/GENERATED provenance is listed in the block table. Clock/reset follow the common synchronous contract. Complete parent port declarations are in the component section.","library_sha256":"15DFB183E267D2A94F8CAB316E01EB3D2E9D2F9C006DC816790A394F4123506C"}
```

[Editable draw.io](figures/post_a06/fpnew_opgroup_multifmt_slice.drawio) · [Figure source](figures/post_a06/fpnew_opgroup_multifmt_slice.json).

**Interface and flow.** Keep native typed request/response records and source ordering. The parent wrapper owns translation to VLSIT flat ports. Exact port declarations:

| Direction | Exact source declaration |
|---|---|
| input | `logic clk_i` |
| input | `logic rst_ni` |
| input | `logic [NUM_OPERANDS-1:0][Width-1:0] operands_i` |
| input | `logic [NUM_FORMATS-1:0][NUM_OPERANDS-1:0] is_boxed_i` |
| input | `fpnew_pkg::roundmode_e rnd_mode_i` |
| input | `fpnew_pkg::operation_e op_i` |
| input | `logic op_mod_i` |
| input | `fpnew_pkg::fp_format_e src_fmt_i` |
| input | `fpnew_pkg::fp_format_e dst_fmt_i` |
| input | `fpnew_pkg::int_format_e int_fmt_i` |
| input | `logic vectorial_op_i` |
| input | `TagType tag_i` |
| input | `MaskType simd_mask_i` |
| input | `logic in_valid_i` |
| output | `logic in_ready_o` |
| input | `logic flush_i` |
| output | `logic [Width-1:0] result_o` |
| output | `fpnew_pkg::status_t status_o` |
| output | `logic extension_bit_o` |
| output | `TagType tag_o` |
| output | `logic out_valid_o` |
| input | `logic out_ready_i` |
| output | `logic busy_o` |
| input | `logic [ExtRegEnaWidth-1:0] reg_ena_i` |
| output | `logic early_out_valid_o` |

**Recorded local changes (source history, not a substitute for the current contract):**
- Make destination-width extension and truncation explicit at RTL assignments.
- Match vector-operation masks and format-selection field widths.
- Use descending packed dimensions and explicitly indexed format/group constants.

**State/verification.** Native state encodings and helper logic remain source-owned. Coherence/maintenance-relevant state machines are discussed in Section 10; native arithmetic/MMU/helper integration is linted, with only the specific activated CPU/FPU cases described in Section 15. No blanket ISA/FP/MMU or helper-equivalence qualification is claimed.

#### 14.5.69 `fpnew_pkg.sv` — MODIFY

Source: [rtl/common/modified/cvfpu/src/fpnew_pkg.sv](../../rtl/modified/cvfpu/src/fpnew_pkg.sv).

**Function.** Type/configuration/package support; not an instantiable block, so no fictitious block/FSM diagram is supplied. Its definitions are consumed by the selected native component interfaces.

**Recorded local changes (source history, not a substitute for the current contract):**
- Return the integer-format enum at the declared integer function width.
- Use descending packed dimensions and explicitly indexed format/group constants.

**State/verification.** Native state encodings and helper logic remain source-owned. Coherence/maintenance-relevant state machines are discussed in Section 10; native arithmetic/MMU/helper integration is linted, with only the specific activated CPU/FPU cases described in Section 15. No blanket ISA/FP/MMU or helper-equivalence qualification is claimed.

#### 14.5.70 `hpdcache.sv` — MODIFY

Source: [rtl/common/modified/hpdcache/rtl/src/hpdcache.sv](../../rtl/modified/hpdcache/rtl/src/hpdcache.sv).

**Function and local effect.** Native D-cache composition. Route shared-line busy/lock queries, tagged metadata probe operations, permission-before-refill, origin-tagged writeback completion and source events through the cache hierarchy.

![hpdcache selected modified component](figures/post_a06/hpdcache.svg)

```json
{"page_name":"BLOCK_DIAGRAM","out_name":"hpdcache.drawio","layout":{"gap_h":120,"gap_v":110,"margin":80,"block_h":60},"top":{"frame_label":["Component composition","(hpdcache)"]},"frame_row":["hpdcache","Native modified component; function and change contract are specified in Section 14.","rtl/common/modified/hpdcache/rtl/src/hpdcache.sv"],"frame_interfaces":[],"blocks":[{"key":"B0","label":["hpdcache_cmo_i","(hpdcache_cmo)"],"width":180,"row":0,"col":0,"row_name":"hpdcache_cmo_i (hpdcache_cmo)","function":"Native component","source":"MODIFY; rtl/common/modified/hpdcache_cva6_pinned/rtl/src/hpdcache_cmo.sv"},{"key":"B1","label":["core_req_arbiter_i","(hpdcache_core_arbiter)"],"width":280,"row":0,"col":1,"row_name":"core_req_arbiter_i (hpdcache_core_arbiter)","function":"Native component","source":"REUSE; rtl/common/third_party/hpdcache_cva6_pinned/rtl/src/hpdcache_core_arbiter.sv"},{"key":"B2","label":["hpdcache_ctrl_i","(hpdcache_ctrl)"],"width":180,"row":0,"col":2,"row_name":"hpdcache_ctrl_i (hpdcache_ctrl)","function":"Cache array resource arbitration","source":"MODIFY; rtl/common/modified/hpdcache/rtl/src/hpdcache_ctrl.sv"},{"key":"B3","label":["flush_i","(hpdcache_flush)"],"width":200,"row":1,"col":0,"row_name":"flush_i (hpdcache_flush)","function":"Origin-tagged dirty writeback completion","source":"MODIFY; rtl/common/modified/hpdcache/rtl/src/hpdcache_flush.sv"},{"key":"B4","label":["hpdcache_mem_req_read_arbiter_i","(hpdcache_mem_req_read_arbiter)"],"width":360,"row":1,"col":1,"row_name":"hpdcache_mem_req_read_arbiter_i (hpdcache_mem_req_read_arbiter)","function":"Native component","source":"REUSE; rtl/common/third_party/hpdcache_cva6_pinned/rtl/src/utils/hpdcache_mem_req_read_arbiter.sv"},{"key":"B5","label":["hpdcache_mem_req_write_arbiter_i","(hpdcache_mem_req_write_arbiter)"],"width":380,"row":1,"col":2,"row_name":"hpdcache_mem_req_write_arbiter_i (hpdcache_mem_req_write_arbiter)","function":"Native component","source":"REUSE; rtl/common/third_party/hpdcache_cva6_pinned/rtl/src/utils/hpdcache_mem_req_write_arbiter.sv"},{"key":"B6","label":["hpdcache_miss_handler_i","(hpdcache_miss_handler)"],"width":280,"row":2,"col":0,"row_name":"hpdcache_miss_handler_i (hpdcache_miss_handler)","function":"Ownership-gated miss and refill","source":"MODIFY; rtl/common/modified/hpdcache/rtl/src/hpdcache_miss_handler.sv"},{"key":"B7","label":["hpdcache_uc_i","(hpdcache_uncached)"],"width":220,"row":2,"col":1,"row_name":"hpdcache_uc_i (hpdcache_uncached)","function":"Native component","source":"MODIFY; rtl/common/modified/hpdcache_cva6_pinned/rtl/src/hpdcache_uncached.sv"},{"key":"B8","label":["hpdcache_wbuf_i","(hpdcache_wbuf)"],"width":180,"row":2,"col":2,"row_name":"hpdcache_wbuf_i (hpdcache_wbuf)","function":"Native component","source":"REUSE; rtl/common/third_party/hpdcache_cva6_pinned/rtl/src/hpdcache_wbuf.sv"},{"key":"B9","label":["u_vlsit_riscv_hpd_probe_engine","(m_vlsit_riscv_hpd_probe_engine)"],"width":380,"row":3,"col":0,"row_name":"u_vlsit_riscv_hpd_probe_engine (m_vlsit_riscv_hpd_probe_engine)","function":"Execute tagged PREPARE and matching COMMIT/ABORT against native HPDcache metadata and writeback services.","source":"NEW; rtl/common/vlsit/coherence/m_vlsit_riscv_hpd_probe_engine.sv"}],"connectors":[],"externals":[],"interfaces":[],"nets":[],"legend_note":"Exact source-referenced children; generate multiplicity and active branches are specified in the component text. Containment denotes hierarchy, not invented signal connectivity. NEW/MODIFY/REUSE/GENERATED provenance is listed in the block table. Clock/reset follow the common synchronous contract. Complete parent port declarations are in the component section.","library_sha256":"15DFB183E267D2A94F8CAB316E01EB3D2E9D2F9C006DC816790A394F4123506C"}
```

[Editable draw.io](figures/post_a06/hpdcache.drawio) · [Figure source](figures/post_a06/hpdcache.json).

**Interface and flow.** Keep native typed request/response records and source ordering. The parent wrapper owns translation to VLSIT flat ports. Exact port declarations:

| Direction | Exact source declaration |
|---|---|
| input | `logic clk_i` |
| input | `logic rst_ni` |
| input | `logic wbuf_flush_i` |
| input | `logic fence_sync_i` |
| output | `logic fence_line_valid_o` |
| input | `logic fence_line_ready_i` |
| output | `hpdcache_nline_t fence_line_o` |
| input | `logic fence_line_done_i` |
| input | `logic fence_line_error_i` |
| output | `logic fence_error_o` |
| output | `hpdcache_nline_t fence_error_line_o` |
| input | `logic core_req_valid_i [HPDcacheCfg.u.nRequesters]` |
| output | `logic core_req_ready_o [HPDcacheCfg.u.nRequesters]` |
| input | `hpdcache_req_t core_req_i [HPDcacheCfg.u.nRequesters]` |
| input | `logic core_req_abort_i [HPDcacheCfg.u.nRequesters]` |
| input | `hpdcache_tag_t core_req_tag_i [HPDcacheCfg.u.nRequesters]` |
| input | `hpdcache_pma_t core_req_pma_i [HPDcacheCfg.u.nRequesters]` |
| output | `logic core_rsp_valid_o [HPDcacheCfg.u.nRequesters]` |
| output | `hpdcache_rsp_t core_rsp_o [HPDcacheCfg.u.nRequesters]` |
| input | `logic mem_req_read_ready_i` |
| output | `logic mem_req_read_valid_o` |
| output | `hpdcache_mem_req_t mem_req_read_o` |
| output | `logic mem_resp_read_ready_o` |
| input | `logic mem_resp_read_valid_i` |
| input | `hpdcache_mem_resp_r_t mem_resp_read_i` |
| input | `logic mem_resp_read_inval_i` |
| input | `hpdcache_nline_t mem_resp_read_inval_nline_i` |
| input | `logic mem_req_write_ready_i` |
| output | `logic mem_req_write_valid_o` |
| output | `hpdcache_mem_req_t mem_req_write_o` |
| input | `logic mem_req_write_data_ready_i` |
| output | `logic mem_req_write_data_valid_o` |
| output | `hpdcache_mem_req_w_t mem_req_write_data_o` |
| output | `logic mem_resp_write_ready_o` |
| input | `logic mem_resp_write_valid_i` |
| input | `hpdcache_mem_resp_w_t mem_resp_write_i` |
| output | `logic evt_cache_write_miss_o` |
| output | `logic evt_cache_read_miss_o` |
| output | `logic evt_cache_dir_unc_err_o` |
| output | `logic evt_cache_dir_cor_err_o` |
| output | `logic evt_cache_dat_unc_err_o` |
| output | `logic evt_cache_dat_cor_err_o` |
| output | `logic evt_scrub_complete_o` |
| output | `logic evt_uncached_req_o` |
| output | `logic evt_cmo_req_o` |
| output | `logic evt_write_req_o` |
| output | `logic evt_read_req_o` |
| output | `logic evt_prefetch_req_o` |
| output | `logic evt_req_on_hold_o` |
| output | `logic evt_rtab_rollback_o` |
| output | `logic evt_stall_refill_o` |
| output | `logic evt_stall_o` |
| output | `logic wbuf_empty_o` |
| output | `logic coh_cpu_idle_o` |
| input | `logic cfg_enable_i` |
| input | `wbuf_timecnt_t cfg_wbuf_threshold_i` |
| input | `logic cfg_wbuf_reset_timecnt_on_write_i` |
| input | `logic cfg_wbuf_sequential_waw_i` |
| input | `logic cfg_wbuf_inhibit_write_coalescing_i` |
| input | `logic cfg_prefetch_updt_plru_i` |
| input | `logic cfg_error_on_cacheable_amo_i` |
| input | `logic cfg_rtab_single_entry_i` |
| input | `logic cfg_default_wb_i` |
| input | `logic cfg_scrub_enable_i` |
| input | `logic unsigned [5:0] cfg_scrub_period_i` |
| input | `logic cfg_scrub_restart_i` |
| output | `logic flush_ack_valid_o` |
| output | `logic [HPDcacheCfg.nlineWidth-1:0] flush_ack_nline_o` |
| output | `logic [1:0] flush_ack_origin_o` |
| output | `logic flush_ack_error_o` |
| output | `logic flush_rsp_invalid_o` |
| input | `logic coh_probe_query_valid_i` |
| input | `hpdcache_nline_t coh_probe_query_nline_i` |
| output | `logic coh_probe_line_busy_o` |
| output | `logic coh_access_line_valid_o` |
| output | `hpdcache_nline_t coh_access_nline_o` |
| output | `logic coh_victim_line_valid_o` |
| output | `hpdcache_nline_t coh_victim_nline_o` |
| input | `logic [15:0] coh_line_lock_valid_i` |
| input | `logic [15:0][HPDcacheCfg.nlineWidth-1:0] coh_line_lock_nline_i` |
| input | `logic coh_probe_req_valid_i` |
| output | `logic coh_probe_req_ready_o` |
| input | `logic [3:0] coh_probe_req_tag_i` |
| input | `hpdcache_nline_t coh_probe_req_nline_i` |
| input | `logic [1:0] coh_probe_req_phase_i` |
| input | `logic [1:0] coh_probe_req_target_state_i` |
| input | `logic coh_probe_req_wback_en_i` |
| output | `logic coh_probe_rsp_valid_o` |
| input | `logic coh_probe_rsp_ready_i` |
| output | `logic [3:0] coh_probe_rsp_tag_o` |
| output | `hpdcache_nline_t coh_probe_rsp_nline_o` |
| output | `logic [1:0] coh_probe_rsp_phase_o` |
| output | `logic [1:0] coh_probe_rsp_state_o` |
| output | `logic coh_probe_rsp_err_o` |
| output | `logic coh_probe_rsp_wback_done_o` |
| output | `logic coh_own_req_valid_o` |
| input | `logic coh_own_req_ready_i` |
| output | `logic [2:0] coh_own_req_id_o` |
| output | `hpdcache_nline_t coh_own_req_nline_o` |
| output | `logic [1:0] coh_own_req_kind_o` |
| input | `logic coh_own_gnt_valid_i` |
| output | `logic coh_own_gnt_ready_o` |
| input | `logic [2:0] coh_own_gnt_id_i` |
| input | `hpdcache_nline_t coh_own_gnt_nline_i` |
| input | `logic [1:0] coh_own_gnt_state_i` |
| input | `logic coh_own_gnt_err_i` |

**Recorded local changes (source history, not a substitute for the current contract):**
- Connect the modified flush-engine origin, line, B-error and invalid-ID status to the cache subsystem boundary.
- Add a clean-line exclusive metadata bit for the planned MESI extension; legacy update paths keep it zero pending CCU permission integration.
- Expose exact-line MSHR/refill activity to the coherence integration boundary.
- Route per-tag coherence line-lock vectors into the modified controller.
- Combine exact-line MSHR/refill and controller-pipeline activity in the probe-admission busy query.
- Use width-inferred all-one constants for uncached request IDs, avoiding zero-count replication when the configured memory ID width is one bit.
- Route a backpressured tagged directory lookup channel to the HPDcache controller for native coherence probe service.
- Carry the four-bit CCU transaction tag through the held directory lookup response, supporting up to sixteen coherence contexts.
- Integrate the tagged two-phase probe engine, matching writeback response, and COMMIT-only MESI directory update inside the cache boundary.
- Qualify replay-table flush completion by origin so probe/CMO B responses cannot release an unrelated CPU victim dependency with the same line.
- Cast configuration-derived type widths to explicit two-state localparams for portable parameterized-range elaboration in Verilator 5.053.
- Restore upstream configuration-derived type ranges after explicit-width localparams failed in the configured Verilator elaboration.
- Export the cache-line ownership request/grant handshake used to gate cacheable misses before refill AR issuance.
- Export current Stage-1 access and selected victim line observations.
- Export CPU replay, miss and pipeline idle for CBO ordering after retired stores. `include "hpdcache_typedef.svh"
- DEC-030/031: retain FENCE.I through coherent clean completion and precise fault. Change: Gate new load/prefetch admission during fence; retain store drain and probe progress.
- DEC-038/A-02: connect probe/eviction reservation invalidation and protect the local cached atomic read-modify-write against same-line probes.

**State/verification.** Native state encodings and helper logic remain source-owned. Coherence/maintenance-relevant state machines are discussed in Section 10; native arithmetic/MMU/helper integration is linted, with only the specific activated CPU/FPU cases described in Section 15. No blanket ISA/FP/MMU or helper-equivalence qualification is claimed.

#### 14.5.71 `hpdcache_ctrl.sv` — MODIFY

Source: [rtl/common/modified/hpdcache/rtl/src/hpdcache_ctrl.sv](../../rtl/modified/hpdcache/rtl/src/hpdcache_ctrl.sv).

**Function and local effect.** Cache array resource arbitration. Arbitrate CPU/replay/refill/probe/flush/ECC resources; block only admissions that conflict with required resources, drain admitted work and protect the first probe writeback SRAM capture.

![hpdcache_ctrl selected modified component](figures/post_a06/hpdcache_ctrl.svg)

```json
{"page_name":"BLOCK_DIAGRAM","out_name":"hpdcache_ctrl.drawio","layout":{"gap_h":120,"gap_v":110,"margin":80,"block_h":60},"top":{"frame_label":["Component composition","(hpdcache_ctrl)"]},"frame_row":["hpdcache_ctrl","Native modified component; function and change contract are specified in Section 14.","rtl/common/modified/hpdcache/rtl/src/hpdcache_ctrl.sv"],"frame_interfaces":[],"blocks":[{"key":"B0","label":["dir_hit_way_encoder_i","(hpdcache_1hot_to_binary)"],"width":300,"row":0,"col":0,"row_name":"dir_hit_way_encoder_i (hpdcache_1hot_to_binary)","function":"Native component","source":"REUSE; rtl/common/third_party/hpdcache_cva6_pinned/rtl/src/common/hpdcache_1hot_to_binary.sv"},{"key":"B1","label":["refill_way_encoder_i","(hpdcache_1hot_to_binary)"],"width":300,"row":0,"col":1,"row_name":"refill_way_encoder_i (hpdcache_1hot_to_binary)","function":"Native component","source":"REUSE; rtl/common/third_party/hpdcache_cva6_pinned/rtl/src/common/hpdcache_1hot_to_binary.sv"},{"key":"B2","label":["hpdcache_ctrl_pe_i","(hpdcache_ctrl_pe)"],"width":220,"row":1,"col":0,"row_name":"hpdcache_ctrl_pe_i (hpdcache_ctrl_pe)","function":"Hit/eviction pipeline execution","source":"MODIFY; rtl/common/modified/hpdcache/rtl/src/hpdcache_ctrl_pe.sv"},{"key":"B3","label":["hpdcache_memctrl_i","(hpdcache_memctrl)"],"width":220,"row":1,"col":1,"row_name":"hpdcache_memctrl_i (hpdcache_memctrl)","function":"Tag/data array ownership","source":"MODIFY; rtl/common/modified/hpdcache/rtl/src/hpdcache_memctrl.sv"},{"key":"B4","label":["hpdcache_rtab_i","(hpdcache_rtab)"],"width":180,"row":2,"col":0,"row_name":"hpdcache_rtab_i (hpdcache_rtab)","function":"Replay and blocked-request lifetime","source":"MODIFY; rtl/common/modified/hpdcache/rtl/src/hpdcache_rtab.sv"}],"connectors":[],"externals":[],"interfaces":[],"nets":[],"legend_note":"Exact source-referenced children; generate multiplicity and active branches are specified in the component text. Containment denotes hierarchy, not invented signal connectivity. NEW/MODIFY/REUSE/GENERATED provenance is listed in the block table. Clock/reset follow the common synchronous contract. Complete parent port declarations are in the component section.","library_sha256":"15DFB183E267D2A94F8CAB316E01EB3D2E9D2F9C006DC816790A394F4123506C"}
```

[Editable draw.io](figures/post_a06/hpdcache_ctrl.drawio) · [Figure source](figures/post_a06/hpdcache_ctrl.json).

**Interface and flow.** Keep native typed request/response records and source ordering. The parent wrapper owns translation to VLSIT flat ports. Exact port declarations:

| Direction | Exact source declaration |
|---|---|
| input | `logic clk_i` |
| input | `logic rst_ni` |
| input | `logic core_req_valid_i` |
| output | `logic core_req_ready_o` |
| input | `hpdcache_req_t core_req_i` |
| input | `logic core_req_abort_i` |
| input | `hpdcache_tag_t core_req_tag_i` |
| input | `hpdcache_pma_t core_req_pma_i` |
| output | `logic core_rsp_valid_o` |
| output | `hpdcache_rsp_t core_rsp_o` |
| input | `logic wbuf_flush_i` |
| input | `logic [15:0] coh_line_lock_valid_i` |
| input | `logic [15:0][$bits(hpdcache_nline_t)-1:0] coh_line_lock_nline_i` |
| input | `logic coh_probe_query_valid_i` |
| input | `hpdcache_nline_t coh_probe_query_nline_i` |
| output | `logic coh_probe_pipeline_busy_o` |
| input | `logic coh_probe_flush_pending_i` |
| input | `logic coh_atomic_grant_i` |
| input | `hpdcache_nline_t coh_atomic_grant_nline_i` |
| output | `logic coh_access_line_valid_o` |
| output | `hpdcache_nline_t coh_access_nline_o` |
| output | `logic coh_victim_line_valid_o` |
| output | `hpdcache_nline_t coh_victim_nline_o` |
| input | `logic coh_probe_lookup_valid_i` |
| output | `logic coh_probe_lookup_ready_o` |
| input | `logic [3:0] coh_probe_lookup_tag_i` |
| input | `hpdcache_nline_t coh_probe_lookup_nline_i` |
| output | `logic coh_probe_lookup_rsp_valid_o` |
| input | `logic coh_probe_lookup_rsp_ready_i` |
| output | `logic [3:0] coh_probe_lookup_rsp_tag_o` |
| output | `hpdcache_way_vector_t coh_probe_lookup_rsp_way_o` |
| output | `logic coh_probe_lookup_rsp_hit_o` |
| output | `logic [1:0] coh_probe_lookup_rsp_state_o` |
| output | `logic coh_probe_lookup_rsp_error_o` |
| output | `hpdcache_nline_t coh_probe_lookup_rsp_nline_o` |
| input | `logic coh_probe_state_update_valid_i` |
| output | `logic coh_probe_state_update_ready_o` |
| input | `hpdcache_nline_t coh_probe_state_update_nline_i` |
| input | `hpdcache_way_vector_t coh_probe_state_update_way_i` |
| input | `logic [1:0] coh_probe_state_update_state_i` |
| output | `logic st0_mshr_check_o` |
| output | `hpdcache_req_offset_t st0_mshr_check_offset_o` |
| output | `hpdcache_nline_t st1_mshr_check_nline_o` |
| input | `logic st1_mshr_hit_i` |
| input | `logic st1_mshr_alloc_ready_i` |
| input | `logic st1_mshr_alloc_full_i` |
| input | `logic st1_mshr_alloc_cbuf_full_i` |
| output | `logic st2_mshr_alloc_o` |
| output | `logic st2_mshr_alloc_cs_o` |
| output | `hpdcache_nline_t st2_mshr_alloc_nline_o` |
| output | `hpdcache_req_tid_t st2_mshr_alloc_tid_o` |
| output | `hpdcache_req_sid_t st2_mshr_alloc_sid_o` |
| output | `hpdcache_word_t st2_mshr_alloc_word_o` |
| output | `hpdcache_req_data_t st2_mshr_alloc_wdata_o` |
| output | `hpdcache_req_be_t st2_mshr_alloc_be_o` |
| output | `hpdcache_way_vector_t st2_mshr_alloc_victim_way_o` |
| output | `logic st2_mshr_alloc_need_rsp_o` |
| output | `logic st2_mshr_alloc_is_prefetch_o` |
| output | `logic st2_mshr_alloc_wback_o` |
| output | `logic st2_mshr_alloc_dirty_o` |
| output | `logic st2_mshr_alloc_exclusive_o` |
| output | `logic st2_mshr_alloc_probe_shared_o` |
| input | `logic refill_req_valid_i` |
| output | `logic refill_req_ready_o` |
| input | `logic refill_is_error_i` |
| input | `logic refill_busy_i` |
| input | `logic refill_updt_sel_victim_i` |
| input | `hpdcache_set_t refill_set_i` |
| input | `hpdcache_way_vector_t refill_way_i` |
| input | `hpdcache_dir_entry_t refill_dir_entry_i` |
| input | `logic refill_write_dir_i` |
| input | `logic refill_write_data_i` |
| input | `hpdcache_word_t refill_word_i` |
| input | `hpdcache_access_data_t refill_data_i` |
| input | `logic refill_core_rsp_valid_i` |
| input | `hpdcache_rsp_t refill_core_rsp_i` |
| input | `hpdcache_nline_t refill_nline_i` |
| input | `logic refill_updt_rtab_i` |
| input | `logic flush_busy_i` |
| output | `hpdcache_nline_t flush_check_nline_o` |
| input | `logic flush_check_hit_i` |
| output | `logic flush_alloc_o` |
| input | `logic flush_alloc_ready_i` |
| output | `hpdcache_nline_t flush_alloc_nline_o` |
| output | `hpdcache_way_vector_t flush_alloc_way_o` |
| input | `logic flush_data_read_i` |
| input | `hpdcache_set_t flush_data_read_set_i` |
| input | `hpdcache_word_t flush_data_read_word_i` |
| input | `hpdcache_way_vector_t flush_data_read_way_i` |
| output | `hpdcache_access_data_t flush_data_read_data_o` |
| input | `logic flush_ack_i` |
| input | `hpdcache_nline_t flush_ack_nline_i` |
| input | `logic flush_ack_error_i` |
| input | `logic inval_check_dir_i` |
| input | `logic inval_write_dir_i` |
| input | `hpdcache_nline_t inval_nline_i` |
| output | `logic inval_hit_o` |
| input | `logic wbuf_empty_i` |
| output | `logic wbuf_flush_all_o` |
| output | `logic wbuf_write_o` |
| input | `logic wbuf_write_ready_i` |
| output | `wbuf_addr_t wbuf_write_addr_o` |
| output | `wbuf_data_t wbuf_write_data_o` |
| output | `wbuf_be_t wbuf_write_be_o` |
| output | `logic wbuf_write_uncacheable_o` |
| input | `logic wbuf_read_hit_i` |
| output | `logic wbuf_read_flush_hit_o` |
| output | `hpdcache_req_addr_t wbuf_rtab_addr_o` |
| output | `logic wbuf_rtab_is_read_o` |
| input | `logic wbuf_rtab_hit_open_i` |
| input | `logic wbuf_rtab_hit_pend_i` |
| input | `logic wbuf_rtab_hit_sent_i` |
| input | `logic wbuf_rtab_not_ready_i` |
| input | `logic uc_busy_i` |
| input | `logic uc_lrsc_match_i` |
| output | `logic uc_lrsc_invalidate_o` |
| output | `hpdcache_nline_t uc_lrsc_invalidate_nline_o` |
| output | `logic uc_lrsc_snoop_o` |
| output | `hpdcache_req_addr_t uc_lrsc_snoop_addr_o` |
| output | `hpdcache_req_size_t uc_lrsc_snoop_size_o` |
| output | `logic uc_req_valid_o` |
| output | `hpdcache_uc_op_t uc_req_op_o` |
| output | `hpdcache_req_addr_t uc_req_addr_o` |
| output | `hpdcache_req_size_t uc_req_size_o` |
| output | `hpdcache_req_data_t uc_req_data_o` |
| output | `hpdcache_req_be_t uc_req_be_o` |
| output | `logic uc_req_uc_o` |
| output | `hpdcache_req_sid_t uc_req_sid_o` |
| output | `hpdcache_req_tid_t uc_req_tid_o` |
| output | `logic uc_req_need_rsp_o` |
| output | `hpdcache_way_vector_t uc_req_dir_hit_way_o` |
| output | `hpdcache_req_data_t uc_req_old_data_o` |
| input | `logic uc_data_amo_write_i` |
| input | `logic uc_data_amo_write_enable_i` |
| input | `hpdcache_set_t uc_data_amo_write_set_i` |
| input | `hpdcache_req_size_t uc_data_amo_write_size_i` |
| input | `hpdcache_word_t uc_data_amo_write_word_i` |
| input | `hpdcache_way_vector_t uc_data_amo_write_way_i` |
| input | `hpdcache_req_data_t uc_data_amo_write_data_i` |
| input | `hpdcache_req_be_t uc_data_amo_write_be_i` |
| output | `logic uc_core_rsp_ready_o` |
| input | `logic uc_core_rsp_valid_i` |
| input | `hpdcache_rsp_t uc_core_rsp_i` |
| input | `logic cmo_busy_i` |
| output | `logic cmo_req_valid_o` |
| output | `hpdcache_cmoh_op_t cmo_req_op_o` |
| output | `hpdcache_req_addr_t cmo_req_addr_o` |
| output | `hpdcache_req_sid_t cmo_req_sid_o` |
| output | `hpdcache_req_tid_t cmo_req_tid_o` |
| output | `logic cmo_req_need_rsp_o` |
| output | `logic cmo_dirty_set_en_o` |
| output | `hpdcache_set_t cmo_dirty_min_set_o` |
| output | `hpdcache_set_t cmo_dirty_max_set_o` |
| output | `logic cmo_valid_set_en_o` |
| output | `hpdcache_set_t cmo_valid_min_set_o` |
| output | `hpdcache_set_t cmo_valid_max_set_o` |
| input | `logic cmo_flush_all_i` |
| input | `logic cmo_inval_all_i` |
| input | `logic cmo_dir_check_entry_i` |
| input | `hpdcache_set_t cmo_dir_check_entry_set_i` |
| input | `hpdcache_way_vector_t cmo_dir_check_entry_way_i` |
| output | `logic cmo_dir_check_entry_valid_o` |
| output | `logic cmo_dir_check_entry_wback_o` |
| output | `logic cmo_dir_check_entry_dirty_o` |
| output | `hpdcache_tag_t cmo_dir_check_entry_tag_o` |
| input | `logic cmo_dir_updt_i` |
| input | `hpdcache_set_t cmo_dir_updt_set_i` |
| input | `hpdcache_way_vector_t cmo_dir_updt_way_i` |
| input | `logic cmo_dir_updt_valid_i` |
| input | `logic cmo_dir_updt_wback_i` |
| input | `logic cmo_dir_updt_dirty_i` |
| input | `logic cmo_dir_updt_fetch_i` |
| input | `hpdcache_tag_t cmo_dir_updt_tag_i` |
| output | `logic cmo_core_rsp_ready_o` |
| input | `logic cmo_core_rsp_valid_i` |
| input | `hpdcache_rsp_t cmo_core_rsp_i` |
| input | `logic mshr_empty_i` |
| input | `logic flush_empty_i` |
| output | `logic rtab_empty_o` |
| output | `logic ctrl_empty_o` |
| input | `logic cfg_enable_i` |
| input | `logic cfg_prefetch_updt_plru_i` |
| input | `logic cfg_rtab_single_entry_i` |
| input | `logic cfg_default_wb_i` |
| input | `logic cfg_scrub_enable_i` |
| input | `logic unsigned [5:0] cfg_scrub_period_i` |
| input | `logic cfg_scrub_restart_i` |
| output | `logic evt_cache_write_miss_o` |
| output | `logic evt_cache_read_miss_o` |
| output | `logic evt_cache_dir_unc_err_o` |
| output | `logic evt_cache_dir_cor_err_o` |
| output | `logic evt_cache_dat_unc_err_o` |
| output | `logic evt_cache_dat_cor_err_o` |
| output | `logic evt_scrub_complete_o` |
| output | `logic evt_uncached_req_o` |
| output | `logic evt_cmo_req_o` |
| output | `logic evt_write_req_o` |
| output | `logic evt_read_req_o` |
| output | `logic evt_prefetch_req_o` |
| output | `logic evt_req_on_hold_o` |
| output | `logic evt_rtab_rollback_o` |
| output | `logic evt_stall_refill_o` |
| output | `logic evt_stall_o` |

**Recorded local changes (source history, not a substitute for the current contract):**
- Route the directory E state to the protocol engine for Shared write-hit replay through exclusive ownership acquisition.
- Add the native probe COMMIT directory-update handshake to the controller.
- Match active CCU line locks against the CPU request and selected victim; route locked-line waits into the replay-table sidecar dependency.
- Include accepted Stage-0 and active Stage-1 requests in exact-line busy detection so PREPARE cannot race an in-flight CPU access.
- Expose the directory's tagged read-only probe lookup channel through the controller without consuming the CPU request interface.
- Preserve the four-bit CCU transaction tag through lookup backpressure.
- Pipeline write intent independently of write-buffer dirty-data allocation for ownership requests on write-allocate misses.
- Export the active Stage-1 request and selected victim line addresses for tile-level lock observation; busy-query admission remains authoritative.
- Make destination-width extension and truncation explicit at RTL assignments.
- DEC-038/A-02: expose exact-line local reservation invalidation.

**State/verification.** Native state encodings and helper logic remain source-owned. Coherence/maintenance-relevant state machines are discussed in Section 10; native arithmetic/MMU/helper integration is linted, with only the specific activated CPU/FPU cases described in Section 15. No blanket ISA/FP/MMU or helper-equivalence qualification is claimed.

#### 14.5.72 `hpdcache_ctrl_pe.sv` — MODIFY

Source: [rtl/common/modified/hpdcache/rtl/src/hpdcache_ctrl_pe.sv](../../rtl/modified/hpdcache/rtl/src/hpdcache_ctrl_pe.sv).

**Function and local effect.** Hit/eviction pipeline execution. Maintain exclusive/dirty metadata and silent E-to-M consistency. Do not allocate a replacement or overwrite a dirty victim until its writeback B succeeds; retain failed context/data until reset.

![hpdcache_ctrl_pe selected modified component](figures/post_a06/hpdcache_ctrl_pe.svg)

```json
{"page_name":"BLOCK_DIAGRAM","out_name":"hpdcache_ctrl_pe.drawio","layout":{"gap_h":120,"gap_v":110,"margin":80,"block_h":60},"top":{"frame_label":["Component composition","(hpdcache_ctrl_pe)"]},"frame_row":["hpdcache_ctrl_pe","Native modified component; function and change contract are specified in Section 14.","rtl/common/modified/hpdcache/rtl/src/hpdcache_ctrl_pe.sv"],"frame_interfaces":["IN","OUT"],"blocks":[{"key":"B0","label":["component_boundary","(hpdcache_ctrl_pe)"],"width":220,"row":0,"col":0,"row_name":"component_boundary (hpdcache_ctrl_pe)","function":"Hit/eviction pipeline execution","source":"MODIFY; rtl/common/modified/hpdcache/rtl/src/hpdcache_ctrl_pe.sv"}],"connectors":[],"externals":[{"id":"IN","block":"B0","side":"L","dir":"in","pos":0,"text":["IN","ports"]},{"id":"OUT","block":"B0","side":"R","dir":"out","pos":0,"text":["OUT","ports"]}],"interfaces":[{"id":"IN","name":"Parent in ports","category":"custom","active":"in","signals":"core_req_valid_i, scrub_req_valid_i, rtab_req_valid_i, refill_req_valid_i, st0_req_is_error_i, st0_req_is_uncacheable_i, st0_req_need_rsp_i, st0_req_is_load_i, st0_req_is_scrub_i, st0_req_is_store_i, st0_req_is_amo_i, st0_req_is_cmo_fence_i, st0_req_is_cmo_inval_i, st0_req_is_cmo_flush_i, st0_req_is_cmo_prefetch_i, st0_req_is_partial_i, st1_req_valid_i, st1_req_abort_i, st1_req_rtab_i, st1_req_is_error_i, st1_req_is_uncacheable_i, st1_req_need_rsp_i, st1_req_is_load_i, st1_req_is_store_i, st1_req_is_amo_i, st1_req_is_amo_lr_i, st1_req_is_amo_sc_i, uc_lrsc_match_i, st1_req_is_cmo_inval_i, st1_req_is_cmo_inval_nline_i, st1_req_is_cmo_flush_i, st1_req_is_cmo_flush_nline_i, st1_req_is_cmo_flush_inval_nline_i, st1_req_is_cmo_fence_i, st1_req_is_cmo_prefetch_i, st1_req_is_partial_i, st1_req_nline_i, st1_victim_nline_i, st1_coh_line_locked_i, st1_dir_victim_locked_i, st1_req_wr_wt_i, st1_req_wr_wb_i, st1_req_wr_auto_i, st1_dir_hit_i, st1_dir_hit_wback_i, st1_dir_hit_dirty_i, st1_dir_hit_exclusive_i, st1_dir_hit_fetch_i, st1_dir_victim_unavailable_i, st1_dir_victim_valid_i, st1_dir_victim_wback_i, st1_dir_victim_dirty_i, st1_dir_err_cor_i, st1_dir_err_unc_i, st1_dat_err_cor_i, st1_dat_err_unc_i, st1_dat_err_unc_dirty_i, err_busy_i, err_wait_i, st1_mshr_alloc_ready_i, st1_mshr_hit_i, st1_mshr_full_i, st1_mshr_cbuf_full_i, st1_no_pend_trans_i, st2_mshr_alloc_i, st2_mshr_alloc_is_prefetch_i, st2_mshr_alloc_wback_i, st2_mshr_alloc_dirty_i, st2_mshr_alloc_exclusive_i, st2_dir_updt_i, st2_dir_updt_valid_i, st2_dir_updt_wback_i, st2_dir_updt_dirty_i, st2_dir_updt_fetch_i, rd_wr_conflict_i, rtab_full_i, rtab_fence_i, rtab_check_hit_i, cachedir_init_ready_i, refill_busy_i, refill_core_rsp_valid_i, wbuf_write_ready_i, wbuf_read_hit_i, flush_busy_i, ordinary_flush_hold_i, st1_flush_check_hit_i, st1_flush_alloc_ready_i, st2_flush_alloc_i, coh_probe_flush_pending_i, uc_busy_i, cmo_busy_i, cfg_prefetch_updt_plru_i, cfg_default_wb_i"},{"id":"OUT","name":"Parent out ports","category":"custom","active":"out","signals":"core_req_ready_o, scrub_req_ready_o, rtab_req_ready_o, refill_req_ready_o, st0_req_mshr_check_o, st0_req_cachedir_read_o, st1_err_o, st1_req_valid_o, st1_rsp_valid_o, st1_rsp_error_o, st1_rsp_aborted_o, st1_req_cachedir_sel_victim_o, st1_req_cachedir_updt_sel_victim_o, st1_req_cachedata_write_o, st1_req_cachedata_write_enable_o, st1_req_cachedata_write_merge_o, st2_mshr_alloc_o, st2_mshr_alloc_cs_o, st2_mshr_alloc_need_rsp_o, st2_mshr_alloc_wback_o, st2_mshr_alloc_dirty_o, st2_mshr_alloc_exclusive_o, st2_mshr_alloc_probe_shared_o, st2_dir_updt_o, st2_dir_updt_valid_o, st2_dir_updt_wback_o, st2_dir_updt_dirty_o, st2_dir_updt_fetch_o, req_cachedata_read_o, rtab_check_o, st1_rtab_alloc_o, st1_rtab_alloc_and_link_o, st1_rtab_commit_o, st1_rtab_rback_o, st1_rtab_mshr_hit_o, st1_rtab_probe_lock_o, st1_rtab_probe_lock_nline_o, st1_rtab_mshr_full_o, st1_rtab_mshr_ready_o, st1_rtab_write_miss_o, st1_rtab_wbuf_hit_o, st1_rtab_wbuf_not_ready_o, st1_rtab_dir_unavailable_o, st1_rtab_dir_fetch_o, st1_rtab_flush_hit_o, st1_rtab_flush_not_ready_o, st1_rtab_pend_trans_o, wbuf_write_valid_o, wbuf_write_uncacheable_o, wbuf_read_flush_hit_o, wbuf_flush_all_o, st2_flush_alloc_o, uc_req_valid_o, uc_core_rsp_ready_o, cmo_req_valid_o, cmo_core_rsp_ready_o, evt_cache_write_miss_o, evt_cache_read_miss_o, evt_cache_dir_unc_err_o, evt_cache_dir_cor_err_o, evt_cache_dat_unc_err_o, evt_cache_dat_cor_err_o, evt_uncached_req_o, evt_cmo_req_o, evt_write_req_o, evt_read_req_o, evt_prefetch_req_o, evt_req_on_hold_o, evt_rtab_rollback_o, evt_stall_refill_o, evt_stall_o"}],"nets":[],"legend_note":"A single boundary symbol denotes a leaf: internal equations/registers are described in its function/dataflow contract, not invented child modules. NEW/MODIFY/REUSE/GENERATED provenance is listed in the block table. Clock/reset follow the common synchronous contract. Complete parent port declarations are in the component section.","library_sha256":"15DFB183E267D2A94F8CAB316E01EB3D2E9D2F9C006DC816790A394F4123506C"}
```

[Editable draw.io](figures/post_a06/hpdcache_ctrl_pe.drawio) · [Figure source](figures/post_a06/hpdcache_ctrl_pe.json).

**Interface and flow.** Keep native typed request/response records and source ordering. The parent wrapper owns translation to VLSIT flat ports. Exact port declarations:

| Direction | Exact source declaration |
|---|---|
| input | `logic core_req_valid_i` |
| output | `logic core_req_ready_o` |
| input | `logic scrub_req_valid_i` |
| output | `logic scrub_req_ready_o` |
| input | `logic rtab_req_valid_i` |
| output | `logic rtab_req_ready_o` |
| input | `logic refill_req_valid_i` |
| output | `logic refill_req_ready_o` |
| input | `logic st0_req_is_error_i` |
| input | `logic st0_req_is_uncacheable_i` |
| input | `logic st0_req_need_rsp_i` |
| input | `logic st0_req_is_load_i` |
| input | `logic st0_req_is_scrub_i` |
| input | `logic st0_req_is_store_i` |
| input | `logic st0_req_is_amo_i` |
| input | `logic st0_req_is_cmo_fence_i` |
| input | `logic st0_req_is_cmo_inval_i` |
| input | `logic st0_req_is_cmo_flush_i` |
| input | `logic st0_req_is_cmo_prefetch_i` |
| input | `logic st0_req_is_partial_i` |
| output | `logic st0_req_mshr_check_o` |
| output | `logic st0_req_cachedir_read_o` |
| input | `logic st1_req_valid_i` |
| input | `logic st1_req_abort_i` |
| input | `logic st1_req_rtab_i` |
| input | `logic st1_req_is_error_i` |
| input | `logic st1_req_is_uncacheable_i` |
| input | `logic st1_req_need_rsp_i` |
| input | `logic st1_req_is_load_i` |
| input | `logic st1_req_is_store_i` |
| input | `logic st1_req_is_amo_i` |
| input | `logic st1_req_is_amo_lr_i` |
| input | `logic st1_req_is_amo_sc_i` |
| input | `logic uc_lrsc_match_i` |
| input | `logic st1_req_is_cmo_inval_i` |
| input | `logic st1_req_is_cmo_inval_nline_i` |
| input | `logic st1_req_is_cmo_flush_i` |
| input | `logic st1_req_is_cmo_flush_nline_i` |
| input | `logic st1_req_is_cmo_flush_inval_nline_i` |
| input | `logic st1_req_is_cmo_fence_i` |
| input | `logic st1_req_is_cmo_prefetch_i` |
| input | `logic st1_req_is_partial_i` |
| input | `hpdcache_nline_t st1_req_nline_i` |
| input | `hpdcache_nline_t st1_victim_nline_i` |
| input | `logic st1_coh_line_locked_i` |
| input | `logic st1_dir_victim_locked_i` |
| input | `logic st1_req_wr_wt_i` |
| input | `logic st1_req_wr_wb_i` |
| input | `logic st1_req_wr_auto_i` |
| input | `logic st1_dir_hit_i` |
| input | `logic st1_dir_hit_wback_i` |
| input | `logic st1_dir_hit_dirty_i` |
| input | `logic st1_dir_hit_exclusive_i` |
| input | `logic st1_dir_hit_fetch_i` |
| input | `logic st1_dir_victim_unavailable_i` |
| input | `logic st1_dir_victim_valid_i` |
| input | `logic st1_dir_victim_wback_i` |
| input | `logic st1_dir_victim_dirty_i` |
| input | `logic st1_dir_err_cor_i` |
| input | `logic st1_dir_err_unc_i` |
| input | `logic st1_dat_err_cor_i` |
| input | `logic st1_dat_err_unc_i` |
| input | `logic st1_dat_err_unc_dirty_i` |
| output | `logic st1_err_o` |
| input | `logic err_busy_i` |
| input | `logic err_wait_i` |
| output | `logic st1_req_valid_o` |
| output | `logic st1_rsp_valid_o` |
| output | `logic st1_rsp_error_o` |
| output | `logic st1_rsp_aborted_o` |
| output | `logic st1_req_cachedir_sel_victim_o` |
| output | `logic st1_req_cachedir_updt_sel_victim_o` |
| output | `logic st1_req_cachedata_write_o` |
| output | `logic st1_req_cachedata_write_enable_o` |
| output | `logic st1_req_cachedata_write_merge_o` |
| input | `logic st1_mshr_alloc_ready_i` |
| input | `logic st1_mshr_hit_i` |
| input | `logic st1_mshr_full_i` |
| input | `logic st1_mshr_cbuf_full_i` |
| input | `logic st1_no_pend_trans_i` |
| input | `logic st2_mshr_alloc_i` |
| input | `logic st2_mshr_alloc_is_prefetch_i` |
| input | `logic st2_mshr_alloc_wback_i` |
| input | `logic st2_mshr_alloc_dirty_i` |
| input | `logic st2_mshr_alloc_exclusive_i` |
| output | `logic st2_mshr_alloc_o` |
| output | `logic st2_mshr_alloc_cs_o` |
| output | `logic st2_mshr_alloc_need_rsp_o` |
| output | `logic st2_mshr_alloc_wback_o` |
| output | `logic st2_mshr_alloc_dirty_o` |
| output | `logic st2_mshr_alloc_exclusive_o` |
| output | `logic st2_mshr_alloc_probe_shared_o` |
| input | `logic st2_dir_updt_i` |
| input | `logic st2_dir_updt_valid_i` |
| input | `logic st2_dir_updt_wback_i` |
| input | `logic st2_dir_updt_dirty_i` |
| input | `logic st2_dir_updt_fetch_i` |
| output | `logic st2_dir_updt_o` |
| output | `logic st2_dir_updt_valid_o` |
| output | `logic st2_dir_updt_wback_o` |
| output | `logic st2_dir_updt_dirty_o` |
| output | `logic st2_dir_updt_fetch_o` |
| output | `logic req_cachedata_read_o` |
| input | `logic rd_wr_conflict_i` |
| input | `logic rtab_full_i` |
| input | `logic rtab_fence_i` |
| output | `logic rtab_check_o` |
| input | `logic rtab_check_hit_i` |
| output | `logic st1_rtab_alloc_o` |
| output | `logic st1_rtab_alloc_and_link_o` |
| output | `logic st1_rtab_commit_o` |
| output | `logic st1_rtab_rback_o` |
| output | `logic st1_rtab_mshr_hit_o` |
| output | `logic st1_rtab_probe_lock_o` |
| output | `hpdcache_nline_t st1_rtab_probe_lock_nline_o` |
| output | `logic st1_rtab_mshr_full_o` |
| output | `logic st1_rtab_mshr_ready_o` |
| output | `logic st1_rtab_write_miss_o` |
| output | `logic st1_rtab_wbuf_hit_o` |
| output | `logic st1_rtab_wbuf_not_ready_o` |
| output | `logic st1_rtab_dir_unavailable_o` |
| output | `logic st1_rtab_dir_fetch_o` |
| output | `logic st1_rtab_flush_hit_o` |
| output | `logic st1_rtab_flush_not_ready_o` |
| output | `logic st1_rtab_pend_trans_o` |
| input | `logic cachedir_init_ready_i` |
| input | `logic refill_busy_i` |
| input | `logic refill_core_rsp_valid_i` |
| input | `logic wbuf_write_ready_i` |
| input | `logic wbuf_read_hit_i` |
| output | `logic wbuf_write_valid_o` |
| output | `logic wbuf_write_uncacheable_o` |
| output | `logic wbuf_read_flush_hit_o` |
| output | `logic wbuf_flush_all_o` |
| input | `logic flush_busy_i` |
| input | `logic ordinary_flush_hold_i` |
| input | `logic st1_flush_check_hit_i` |
| input | `logic st1_flush_alloc_ready_i` |
| input | `logic st2_flush_alloc_i` |
| output | `logic st2_flush_alloc_o` |
| input | `logic coh_probe_flush_pending_i` |
| input | `logic uc_busy_i` |
| output | `logic uc_req_valid_o` |
| output | `logic uc_core_rsp_ready_o` |
| input | `logic cmo_busy_i` |
| output | `logic cmo_req_valid_o` |
| output | `logic cmo_core_rsp_ready_o` |
| input | `logic cfg_prefetch_updt_plru_i` |
| input | `logic cfg_default_wb_i` |
| output | `logic evt_cache_write_miss_o` |
| output | `logic evt_cache_read_miss_o` |
| output | `logic evt_cache_dir_unc_err_o` |
| output | `logic evt_cache_dir_cor_err_o` |
| output | `logic evt_cache_dat_unc_err_o` |
| output | `logic evt_cache_dat_cor_err_o` |
| output | `logic evt_uncached_req_o` |
| output | `logic evt_cmo_req_o` |
| output | `logic evt_write_req_o` |
| output | `logic evt_read_req_o` |
| output | `logic evt_prefetch_req_o` |
| output | `logic evt_req_on_hold_o` |
| output | `logic evt_rtab_rollback_o` |
| output | `logic evt_stall_refill_o` |
| output | `logic evt_stall_o` |

**Recorded local changes (source history, not a substitute for the current contract):**
- Convert clean Shared write hits into replayed write misses so the line obtains exclusive CCU permission before cache data is modified.
- Park same-line requests and requests with a locked victim in RTAB until the matching CCU line lock is released.
- Export write intent separately from CBUF dirty-data allocation so a write miss still requests exclusive permission when the CBUF is full.
- DEC-038/A-02: unique refill/replay and local cached atomic execution.

**State/verification.** Native state encodings and helper logic remain source-owned. Coherence/maintenance-relevant state machines are discussed in Section 10; native arithmetic/MMU/helper integration is linted, with only the specific activated CPU/FPU cases described in Section 15. No blanket ISA/FP/MMU or helper-equivalence qualification is claimed.

#### 14.5.73 `hpdcache_flush.sv` — MODIFY

Source: [rtl/common/modified/hpdcache/rtl/src/hpdcache_flush.sv](../../rtl/modified/hpdcache/rtl/src/hpdcache_flush.sv).

**Function and local effect.** Origin-tagged dirty writeback completion. Keep flush descriptors through accepted B, preserve native origin/line/ID/status and report success only for matching B=OKAY. Invalid responses are diagnostic; fatal ordinary errors retain recoverable state.

![hpdcache_flush selected modified component](figures/post_a06/hpdcache_flush.svg)

```json
{"page_name":"BLOCK_DIAGRAM","out_name":"hpdcache_flush.drawio","layout":{"gap_h":120,"gap_v":110,"margin":80,"block_h":60},"top":{"frame_label":["Component composition","(hpdcache_flush)"]},"frame_row":["hpdcache_flush","Native modified component; function and change contract are specified in Section 14.","rtl/common/modified/hpdcache/rtl/src/hpdcache_flush.sv"],"frame_interfaces":[],"blocks":[{"key":"B0","label":["flush_dir_free_ptr_bin_i","(hpdcache_1hot_to_binary)"],"width":300,"row":0,"col":0,"row_name":"flush_dir_free_ptr_bin_i (hpdcache_1hot_to_binary)","function":"Native component","source":"REUSE; rtl/common/third_party/hpdcache_cva6_pinned/rtl/src/common/hpdcache_1hot_to_binary.sv"},{"key":"B1","label":["flush_data_resizer_i","(hpdcache_data_resize)"],"width":260,"row":0,"col":1,"row_name":"flush_data_resizer_i (hpdcache_data_resize)","function":"Native component","source":"REUSE; rtl/common/third_party/hpdcache_cva6_pinned/rtl/src/common/hpdcache_data_resize.sv"},{"key":"B2","label":["flush_ack_decoder_i","(hpdcache_decoder)"],"width":220,"row":1,"col":0,"row_name":"flush_ack_decoder_i (hpdcache_decoder)","function":"Native component","source":"REUSE; rtl/common/third_party/hpdcache_cva6_pinned/rtl/src/common/hpdcache_decoder.sv"},{"key":"B3","label":["mem_req_meta_fifo_i","(hpdcache_fifo_reg)"],"width":220,"row":1,"col":1,"row_name":"mem_req_meta_fifo_i (hpdcache_fifo_reg)","function":"Native component","source":"REUSE; rtl/common/third_party/hpdcache_cva6_pinned/rtl/src/common/hpdcache_fifo_reg.sv"},{"key":"B4","label":["flush_dir_free_arb_i","(hpdcache_fxarb)"],"width":240,"row":2,"col":0,"row_name":"flush_dir_free_arb_i (hpdcache_fxarb)","function":"Native component","source":"REUSE; rtl/common/third_party/hpdcache_cva6_pinned/rtl/src/common/hpdcache_fxarb.sv"}],"connectors":[],"externals":[],"interfaces":[],"nets":[],"legend_note":"Exact source-referenced children; generate multiplicity and active branches are specified in the component text. Containment denotes hierarchy, not invented signal connectivity. NEW/MODIFY/REUSE/GENERATED provenance is listed in the block table. Clock/reset follow the common synchronous contract. Complete parent port declarations are in the component section.","library_sha256":"15DFB183E267D2A94F8CAB316E01EB3D2E9D2F9C006DC816790A394F4123506C"}
```

[Editable draw.io](figures/post_a06/hpdcache_flush.drawio) · [Figure source](figures/post_a06/hpdcache_flush.json).

**Interface and flow.** Keep native typed request/response records and source ordering. The parent wrapper owns translation to VLSIT flat ports. Exact port declarations:

| Direction | Exact source declaration |
|---|---|
| input | `logic clk_i` |
| input | `logic rst_ni` |
| output | `logic flush_empty_o` |
| output | `logic flush_full_o` |
| output | `logic flush_busy_o` |
| input | `hpdcache_nline_t flush_check_nline_i` |
| output | `logic flush_check_hit_o` |
| input | `logic flush_alloc_i` |
| output | `logic flush_alloc_ready_o` |
| input | `hpdcache_nline_t flush_alloc_nline_i` |
| input | `hpdcache_way_vector_t flush_alloc_way_i` |
| input | `logic [1:0] flush_alloc_origin_i` |
| output | `logic flush_data_read_o` |
| output | `hpdcache_set_t flush_data_read_set_o` |
| output | `hpdcache_word_t flush_data_read_word_o` |
| output | `hpdcache_way_vector_t flush_data_read_way_o` |
| input | `hpdcache_access_data_t flush_data_read_data_i` |
| output | `logic flush_ack_o` |
| output | `hpdcache_nline_t flush_ack_nline_o` |
| output | `logic [1:0] flush_ack_origin_o` |
| output | `logic flush_ack_error_o` |
| output | `logic flush_rsp_invalid_o` |
| input | `logic mem_req_write_ready_i` |
| output | `logic mem_req_write_valid_o` |
| output | `hpdcache_mem_req_t mem_req_write_o` |
| input | `logic mem_req_write_data_ready_i` |
| output | `logic mem_req_write_data_valid_o` |
| output | `hpdcache_mem_req_w_t mem_req_write_data_o` |
| output | `logic mem_resp_write_ready_o` |
| input | `logic mem_resp_write_valid_i` |
| input | `hpdcache_mem_resp_w_t mem_resp_write_i` |

**Recorded local changes (source history, not a substitute for the current contract):**
- Preserve allocation origin through writeback completion; report B errors. Consume/diagnose responses not matching a live non-atomic flush ID. REQ-MEM-012/015/018: the cache owner must retain M until COMMIT/ABORT. This engine releases transport entries on matching B, including B errors; it does not change MESI or authorize dirty/tag state destruction.
- Extend physical line addresses explicitly to the external memory address width.

**State/verification.** Native state encodings and helper logic remain source-owned. Coherence/maintenance-relevant state machines are discussed in Section 10; native arithmetic/MMU/helper integration is linted, with only the specific activated CPU/FPU cases described in Section 15. No blanket ISA/FP/MMU or helper-equivalence qualification is claimed.

#### 14.5.74 `hpdcache_memctrl.sv` — MODIFY

Source: [rtl/common/modified/hpdcache/rtl/src/hpdcache_memctrl.sv](../../rtl/modified/hpdcache/rtl/src/hpdcache_memctrl.sv).

**Function and local effect.** Tag/data array ownership. Expose read-only tagged lookup and COMMIT-only metadata update, retain dirty/exclusive state and arbitrate native tag/data access without collision.

![hpdcache_memctrl selected modified component](figures/post_a06/hpdcache_memctrl.svg)

```json
{"page_name":"BLOCK_DIAGRAM","out_name":"hpdcache_memctrl.drawio","layout":{"gap_h":120,"gap_v":110,"margin":80,"block_h":60},"top":{"frame_label":["Component composition","(hpdcache_memctrl)"]},"frame_row":["hpdcache_memctrl","Native modified component; function and change contract are specified in Section 14.","rtl/common/modified/hpdcache/rtl/src/hpdcache_memctrl.sv"],"frame_interfaces":[],"blocks":[{"key":"B0","label":["amo_be_demux_i","(hpdcache_demux)"],"width":200,"row":0,"col":0,"row_name":"amo_be_demux_i (hpdcache_demux)","function":"Native component","source":"REUSE; rtl/common/third_party/hpdcache_cva6_pinned/rtl/src/common/hpdcache_demux.sv"},{"key":"B1","label":["data_req_write_be_demux_i","(hpdcache_demux)"],"width":300,"row":0,"col":1,"row_name":"data_req_write_be_demux_i (hpdcache_demux)","function":"Native component","source":"REUSE; rtl/common/third_party/hpdcache_cva6_pinned/rtl/src/common/hpdcache_demux.sv"},{"key":"B2","label":["data_read_flush_mux_row_i","(hpdcache_mux)"],"width":300,"row":0,"col":2,"row_name":"data_read_flush_mux_row_i (hpdcache_mux)","function":"Native component","source":"REUSE; rtl/common/third_party/hpdcache_cva6_pinned/rtl/src/common/hpdcache_mux.sv"},{"key":"B3","label":["data_read_flush_mux_way_i","(hpdcache_mux)"],"width":300,"row":1,"col":0,"row_name":"data_read_flush_mux_way_i (hpdcache_mux)","function":"Native component","source":"REUSE; rtl/common/third_party/hpdcache_cva6_pinned/rtl/src/common/hpdcache_mux.sv"},{"key":"B4","label":["data_read_req_word_mux_i","(hpdcache_mux)"],"width":280,"row":1,"col":1,"row_name":"data_read_req_word_mux_i (hpdcache_mux)","function":"Native component","source":"REUSE; rtl/common/third_party/hpdcache_cva6_pinned/rtl/src/common/hpdcache_mux.sv"},{"key":"B5","label":["data_read_req_word_way_mux_i","(hpdcache_mux)"],"width":340,"row":1,"col":2,"row_name":"data_read_req_word_way_mux_i (hpdcache_mux)","function":"Native component","source":"REUSE; rtl/common/third_party/hpdcache_cva6_pinned/rtl/src/common/hpdcache_mux.sv"},{"key":"B6","label":["flush_tag_mux_i","(hpdcache_mux)"],"width":180,"row":2,"col":0,"row_name":"flush_tag_mux_i (hpdcache_mux)","function":"Native component","source":"REUSE; rtl/common/third_party/hpdcache_cva6_pinned/rtl/src/common/hpdcache_mux.sv"},{"key":"B7","label":["hit_tag_mux_i","(hpdcache_mux)"],"width":180,"row":2,"col":1,"row_name":"hit_tag_mux_i (hpdcache_mux)","function":"Native component","source":"REUSE; rtl/common/third_party/hpdcache_cva6_pinned/rtl/src/common/hpdcache_mux.sv"},{"key":"B8","label":["i_dir_ways_mux","(hpdcache_mux)"],"width":180,"row":2,"col":2,"row_name":"i_dir_ways_mux (hpdcache_mux)","function":"Native component","source":"REUSE; rtl/common/third_party/hpdcache_cva6_pinned/rtl/src/common/hpdcache_mux.sv"},{"key":"B9","label":["victim_tag_mux_i","(hpdcache_mux)"],"width":200,"row":3,"col":0,"row_name":"victim_tag_mux_i (hpdcache_mux)","function":"Native component","source":"REUSE; rtl/common/third_party/hpdcache_cva6_pinned/rtl/src/common/hpdcache_mux.sv"},{"key":"B10","label":["dir_sram","(hpdcache_sram)"],"width":180,"row":3,"col":1,"row_name":"dir_sram (hpdcache_sram)","function":"Native component","source":"REUSE; rtl/common/third_party/hpdcache_cva6_pinned/rtl/src/common/hpdcache_sram.sv"},{"key":"B11","label":["data_sram","(hpdcache_sram_wbyteenable)"],"width":320,"row":3,"col":2,"row_name":"data_sram (hpdcache_sram_wbyteenable)","function":"Native component","source":"REUSE; rtl/common/third_party/hpdcache_cva6_pinned/rtl/src/common/hpdcache_sram_wbyteenable.sv"},{"key":"B12","label":["victim_sel_i","(hpdcache_victim_sel)"],"width":260,"row":4,"col":0,"row_name":"victim_sel_i (hpdcache_victim_sel)","function":"Native component","source":"REUSE; rtl/common/third_party/hpdcache_cva6_pinned/rtl/src/hpdcache_victim_sel.sv"}],"connectors":[],"externals":[],"interfaces":[],"nets":[],"legend_note":"Exact source-referenced children; generate multiplicity and active branches are specified in the component text. Containment denotes hierarchy, not invented signal connectivity. NEW/MODIFY/REUSE/GENERATED provenance is listed in the block table. Clock/reset follow the common synchronous contract. Complete parent port declarations are in the component section.","library_sha256":"15DFB183E267D2A94F8CAB316E01EB3D2E9D2F9C006DC816790A394F4123506C"}
```

[Editable draw.io](figures/post_a06/hpdcache_memctrl.drawio) · [Figure source](figures/post_a06/hpdcache_memctrl.json).

**Interface and flow.** Keep native typed request/response records and source ordering. The parent wrapper owns translation to VLSIT flat ports. Exact port declarations:

| Direction | Exact source declaration |
|---|---|
| input | `logic clk_i` |
| input | `logic rst_ni` |
| output | `logic ready_o` |
| output | `logic rd_wr_conflict_o` |
| input | `logic dir_match_i` |
| input | `hpdcache_set_t dir_match_set_i` |
| input | `hpdcache_tag_t dir_match_tag_i` |
| input | `logic dir_updt_sel_victim_i` |
| output | `hpdcache_way_vector_t dir_hit_way_o` |
| output | `hpdcache_tag_t dir_hit_tag_o` |
| output | `logic dir_hit_wback_o` |
| output | `logic dir_hit_dirty_o` |
| output | `logic dir_hit_exclusive_o` |
| output | `logic dir_hit_fetch_o` |
| input | `logic dir_updt_i` |
| input | `hpdcache_set_t dir_updt_set_i` |
| input | `hpdcache_way_vector_t dir_updt_way_i` |
| input | `hpdcache_tag_t dir_updt_tag_i` |
| input | `logic dir_updt_valid_i` |
| input | `logic dir_updt_wback_i` |
| input | `logic dir_updt_dirty_i` |
| input | `logic dir_updt_fetch_i` |
| input | `logic dir_refill_i` |
| input | `hpdcache_set_t dir_refill_set_i` |
| input | `hpdcache_way_vector_t dir_refill_way_i` |
| input | `hpdcache_dir_entry_t dir_refill_entry_i` |
| input | `logic dir_refill_updt_sel_victim_i` |
| input | `logic dir_victim_sel_i` |
| input | `hpdcache_set_t dir_victim_set_i` |
| output | `logic dir_victim_valid_o` |
| output | `logic dir_victim_wback_o` |
| output | `logic dir_victim_dirty_o` |
| output | `hpdcache_tag_t dir_victim_tag_o` |
| output | `hpdcache_way_vector_t dir_victim_way_o` |
| input | `logic dir_inval_check_i` |
| input | `hpdcache_nline_t dir_inval_nline_i` |
| input | `logic dir_inval_write_i` |
| output | `logic dir_inval_hit_o` |
| input | `logic dir_probe_lookup_valid_i` |
| output | `logic dir_probe_lookup_ready_o` |
| input | `logic [3:0] dir_probe_lookup_tag_i` |
| input | `hpdcache_nline_t dir_probe_lookup_nline_i` |
| output | `logic dir_probe_lookup_rsp_valid_o` |
| input | `logic dir_probe_lookup_rsp_ready_i` |
| output | `logic [3:0] dir_probe_lookup_rsp_tag_o` |
| output | `hpdcache_way_vector_t dir_probe_lookup_rsp_way_o` |
| output | `logic dir_probe_lookup_rsp_hit_o` |
| output | `logic [1:0] dir_probe_lookup_rsp_state_o` |
| output | `logic dir_probe_lookup_rsp_error_o` |
| output | `hpdcache_nline_t dir_probe_lookup_rsp_nline_o` |
| input | `logic dir_probe_state_update_valid_i` |
| output | `logic dir_probe_state_update_ready_o` |
| input | `hpdcache_nline_t dir_probe_state_update_nline_i` |
| input | `hpdcache_way_vector_t dir_probe_state_update_way_i` |
| input | `logic [1:0] dir_probe_state_update_state_i` |
| input | `logic dir_cmo_check_entry_i` |
| input | `hpdcache_set_t dir_cmo_check_entry_set_i` |
| input | `hpdcache_way_vector_t dir_cmo_check_entry_way_i` |
| output | `logic dir_cmo_check_entry_valid_o` |
| output | `logic dir_cmo_check_entry_wback_o` |
| output | `logic dir_cmo_check_entry_dirty_o` |
| output | `hpdcache_tag_t dir_cmo_check_entry_tag_o` |
| input | `logic dir_cmo_updt_i` |
| input | `hpdcache_set_t dir_cmo_updt_set_i` |
| input | `hpdcache_way_vector_t dir_cmo_updt_way_i` |
| input | `hpdcache_tag_t dir_cmo_updt_tag_i` |
| input | `logic dir_cmo_updt_valid_i` |
| input | `logic dir_cmo_updt_wback_i` |
| input | `logic dir_cmo_updt_dirty_i` |
| input | `logic dir_cmo_updt_fetch_i` |
| output | `hpdcache_way_vector_t dir_err_cor_o` |
| output | `hpdcache_way_vector_t dir_err_unc_o` |
| output | `hpdcache_way_vector_t dir_err_valid_o` |
| output | `hpdcache_way_vector_t dir_err_dirty_o` |
| input | `hpdcache_set_t dir_err_set_i` |
| input | `hpdcache_way_vector_t dir_err_way_i` |
| input | `logic dir_err_read_i` |
| output | `hpdcache_dir_entry_t dir_err_rdata_o` |
| input | `logic dir_err_write_i` |
| input | `hpdcache_dir_entry_t dir_err_wdata_i` |
| input | `logic data_req_read_i` |
| input | `hpdcache_set_t data_req_read_set_i` |
| input | `hpdcache_req_size_t data_req_read_size_i` |
| input | `hpdcache_word_t data_req_read_word_i` |
| input | `hpdcache_way_vector_t data_req_read_way_i` |
| output | `hpdcache_req_data_t data_req_read_data_o` |
| input | `logic data_req_write_i` |
| input | `logic data_req_write_enable_i` |
| input | `logic data_req_write_merge_i` |
| input | `hpdcache_set_t data_req_write_set_i` |
| input | `hpdcache_way_vector_t data_req_write_way_i` |
| input | `hpdcache_req_size_t data_req_write_size_i` |
| input | `hpdcache_word_t data_req_write_word_i` |
| input | `hpdcache_req_data_t data_req_write_data_i` |
| input | `hpdcache_req_be_t data_req_write_be_i` |
| input | `logic data_amo_write_i` |
| input | `logic data_amo_write_enable_i` |
| input | `hpdcache_set_t data_amo_write_set_i` |
| input | `hpdcache_req_size_t data_amo_write_size_i` |
| input | `hpdcache_word_t data_amo_write_word_i` |
| input | `hpdcache_way_vector_t data_amo_write_way_i` |
| input | `hpdcache_req_data_t data_amo_write_data_i` |
| input | `hpdcache_req_be_t data_amo_write_be_i` |
| input | `logic data_flush_read_i` |
| input | `hpdcache_set_t data_flush_read_set_i` |
| input | `hpdcache_word_t data_flush_read_word_i` |
| input | `hpdcache_way_vector_t data_flush_read_way_i` |
| output | `hpdcache_access_data_t data_flush_read_data_o` |
| input | `logic data_refill_i` |
| input | `hpdcache_set_t data_refill_set_i` |
| input | `hpdcache_way_vector_t data_refill_way_i` |
| input | `hpdcache_word_t data_refill_word_i` |
| input | `hpdcache_access_data_t data_refill_data_i` |
| output | `hpdcache_way_vector_t data_err_cor_o` |
| output | `hpdcache_way_vector_t data_err_unc_o` |
| input | `hpdcache_set_t data_err_set_i` |
| input | `hpdcache_way_vector_t data_err_way_i` |
| input | `hpdcache_word_t data_err_word_i` |
| input | `logic data_err_read_i` |
| output | `hpdcache_access_data_t data_err_rdata_o` |
| input | `logic data_err_write_i` |
| input | `hpdcache_access_data_t data_err_wdata_i` |

**Recorded local changes (source history, not a substitute for the current contract):**
- Export the per-line MESI E bit to the request controller so clean S hits can be replayed through the ownership-gated write-miss path.
- Add a COMMIT-only MESI directory write port; PREPARE/ABORT remain non-mutating.
- Preserve the added MESI exclusive metadata field in directory updates; existing non-coherent updates initialize it to zero.
- Add a backpressured, read-only directory lookup port for tagged coherence probes, arbitrated against existing directory RAM users.
- Capture and return the four-bit CCU transaction tag with each lookup response so the cluster can correlate up to sixteen active contexts.

**State/verification.** Native state encodings and helper logic remain source-owned. Coherence/maintenance-relevant state machines are discussed in Section 10; native arithmetic/MMU/helper integration is linted, with only the specific activated CPU/FPU cases described in Section 15. No blanket ISA/FP/MMU or helper-equivalence qualification is claimed.

#### 14.5.75 `hpdcache_miss_handler.sv` — MODIFY

Source: [rtl/common/modified/hpdcache/rtl/src/hpdcache_miss_handler.sv](../../rtl/modified/hpdcache/rtl/src/hpdcache_miss_handler.sv).

**Function and local effect.** Ownership-gated miss and refill. Obtain CCU permission before issuing the refill. Retain request/grant state, return denied ownership as a precise error, and avoid installing valid/exclusive data after a failed refill.

![hpdcache_miss_handler selected modified component](figures/post_a06/hpdcache_miss_handler.svg)

```json
{"page_name":"BLOCK_DIAGRAM","out_name":"hpdcache_miss_handler.drawio","layout":{"gap_h":120,"gap_v":110,"margin":80,"block_h":60},"top":{"frame_label":["Component composition","(hpdcache_miss_handler)"]},"frame_row":["hpdcache_miss_handler","Native modified component; function and change contract are specified in Section 14.","rtl/common/modified/hpdcache/rtl/src/hpdcache_miss_handler.sv"],"frame_interfaces":[],"blocks":[{"key":"B0","label":["victim_way_encoder_i","(hpdcache_1hot_to_binary)"],"width":300,"row":0,"col":0,"row_name":"victim_way_encoder_i (hpdcache_1hot_to_binary)","function":"Native component","source":"REUSE; rtl/common/third_party/hpdcache_cva6_pinned/rtl/src/common/hpdcache_1hot_to_binary.sv"},{"key":"B1","label":["hpdcache_cbuf_i","(hpdcache_cbuf)"],"width":180,"row":0,"col":1,"row_name":"hpdcache_cbuf_i (hpdcache_cbuf)","function":"Native component","source":"REUSE; rtl/common/third_party/hpdcache_cva6_pinned/rtl/src/hpdcache_cbuf.sv"},{"key":"B2","label":["i_data_resize","(hpdcache_data_resize)"],"width":260,"row":1,"col":0,"row_name":"i_data_resize (hpdcache_data_resize)","function":"Native component","source":"REUSE; rtl/common/third_party/hpdcache_cva6_pinned/rtl/src/common/hpdcache_data_resize.sv"},{"key":"B3","label":["victim_way_decoder_i","(hpdcache_decoder)"],"width":240,"row":1,"col":1,"row_name":"victim_way_decoder_i (hpdcache_decoder)","function":"Native component","source":"REUSE; rtl/common/third_party/hpdcache_cva6_pinned/rtl/src/common/hpdcache_decoder.sv"},{"key":"B4","label":["i_r_metadata_fifo","(hpdcache_fifo_reg)"],"width":220,"row":2,"col":0,"row_name":"i_r_metadata_fifo (hpdcache_fifo_reg)","function":"Native component","source":"REUSE; rtl/common/third_party/hpdcache_cva6_pinned/rtl/src/common/hpdcache_fifo_reg.sv"},{"key":"B5","label":["i_refill_core_rsp_buf","(hpdcache_fifo_reg)"],"width":260,"row":2,"col":1,"row_name":"i_refill_core_rsp_buf (hpdcache_fifo_reg)","function":"Native component","source":"REUSE; rtl/common/third_party/hpdcache_cva6_pinned/rtl/src/common/hpdcache_fifo_reg.sv"},{"key":"B6","label":["hpdcache_mshr_i","(hpdcache_mshr)"],"width":180,"row":3,"col":0,"row_name":"hpdcache_mshr_i (hpdcache_mshr)","function":"Outstanding miss identity and busy queries","source":"MODIFY; rtl/common/modified/hpdcache/rtl/src/hpdcache_mshr.sv"},{"key":"B7","label":["data_read_rsp_mux_i","(hpdcache_mux)"],"width":220,"row":3,"col":1,"row_name":"data_read_rsp_mux_i (hpdcache_mux)","function":"Native component","source":"REUSE; rtl/common/third_party/hpdcache_cva6_pinned/rtl/src/common/hpdcache_mux.sv"}],"connectors":[],"externals":[],"interfaces":[],"nets":[],"legend_note":"Exact source-referenced children; generate multiplicity and active branches are specified in the component text. Containment denotes hierarchy, not invented signal connectivity. NEW/MODIFY/REUSE/GENERATED provenance is listed in the block table. Clock/reset follow the common synchronous contract. Complete parent port declarations are in the component section.","library_sha256":"15DFB183E267D2A94F8CAB316E01EB3D2E9D2F9C006DC816790A394F4123506C"}
```

[Editable draw.io](figures/post_a06/hpdcache_miss_handler.drawio) · [Figure source](figures/post_a06/hpdcache_miss_handler.json).

**Interface and flow.** Keep native typed request/response records and source ordering. The parent wrapper owns translation to VLSIT flat ports. Exact port declarations:

| Direction | Exact source declaration |
|---|---|
| input | `logic clk_i` |
| input | `logic rst_ni` |
| output | `logic mshr_empty_o` |
| output | `logic mshr_full_o` |
| input | `logic cfg_prefetch_updt_sel_victim_i` |
| input | `logic mshr_check_i` |
| input | `hpdcache_req_offset_t mshr_check_offset_i` |
| input | `hpdcache_nline_t mshr_check_nline_i` |
| output | `logic mshr_check_hit_o` |
| input | `logic probe_check_valid_i` |
| input | `hpdcache_nline_t probe_check_nline_i` |
| output | `logic probe_line_busy_o` |
| output | `logic mshr_alloc_ready_o` |
| input | `logic mshr_alloc_i` |
| input | `logic mshr_alloc_cs_i` |
| input | `hpdcache_nline_t mshr_alloc_nline_i` |
| output | `logic mshr_alloc_full_o` |
| output | `logic mshr_alloc_cbuf_full_o` |
| input | `hpdcache_req_tid_t mshr_alloc_tid_i` |
| input | `hpdcache_req_sid_t mshr_alloc_sid_i` |
| input | `hpdcache_word_t mshr_alloc_word_i` |
| input | `hpdcache_way_vector_t mshr_alloc_victim_way_i` |
| input | `logic mshr_alloc_need_rsp_i` |
| input | `logic mshr_alloc_is_prefetch_i` |
| input | `logic mshr_alloc_wback_i` |
| input | `logic mshr_alloc_dirty_i` |
| input | `logic mshr_alloc_exclusive_i` |
| input | `logic mshr_alloc_probe_shared_i` |
| input | `hpdcache_req_data_t mshr_alloc_wdata_i` |
| input | `hpdcache_req_be_t mshr_alloc_be_i` |
| input | `logic refill_req_ready_i` |
| output | `logic refill_req_valid_o` |
| output | `logic refill_is_error_o` |
| output | `logic refill_busy_o` |
| output | `logic refill_updt_sel_victim_o` |
| output | `hpdcache_set_t refill_set_o` |
| output | `hpdcache_way_vector_t refill_way_o` |
| output | `hpdcache_dir_entry_t refill_dir_entry_o` |
| output | `logic refill_write_dir_o` |
| output | `logic refill_write_data_o` |
| output | `hpdcache_refill_data_t refill_data_o` |
| output | `hpdcache_word_t refill_word_o` |
| output | `hpdcache_nline_t refill_nline_o` |
| output | `logic refill_updt_rtab_o` |
| output | `logic inval_check_dir_o` |
| output | `logic inval_write_dir_o` |
| output | `hpdcache_nline_t inval_nline_o` |
| input | `logic inval_hit_i` |
| output | `logic refill_core_rsp_valid_o` |
| output | `hpdcache_rsp_t refill_core_rsp_o` |
| input | `logic mem_req_ready_i` |
| output | `logic mem_req_valid_o` |
| output | `hpdcache_mem_req_t mem_req_o` |
| output | `logic mem_resp_ready_o` |
| input | `logic mem_resp_valid_i` |
| input | `hpdcache_mem_resp_r_t mem_resp_i` |
| input | `logic mem_resp_inval_i` |
| input | `hpdcache_nline_t mem_resp_inval_nline_i` |
| output | `logic coh_own_req_valid_o` |
| input | `logic coh_own_req_ready_i` |
| output | `logic [2:0] coh_own_req_id_o` |
| output | `hpdcache_nline_t coh_own_req_nline_o` |
| output | `logic [1:0] coh_own_req_kind_o` |
| input | `logic coh_own_gnt_valid_i` |
| output | `logic coh_own_gnt_ready_o` |
| input | `logic [2:0] coh_own_gnt_id_i` |
| input | `hpdcache_nline_t coh_own_gnt_nline_i` |
| input | `logic [1:0] coh_own_gnt_state_i` |
| input | `logic coh_own_gnt_err_i` |

**Recorded local changes (source history, not a substitute for the current contract):**
- Initialize the added MESI exclusive metadata to Shared on existing refills; coherent permission integration will set E only after a CCU grant.
- Gate cacheable refill AR requests on a matching CCU permission grant, retain E permission through the response metadata FIFO, and convert a failed/mismatched grant into a synthetic HPDcache memory error response.
- Separate exclusive write intent from CBUF data allocation and preserve an M grant as dirty ownership when the write request must replay after refill.
- Expose exact-line busy status for active MSHR entries and the refill engine.
- Separate refill response VALID from refill-ready FSM combinational dependencies.
- Make destination-width extension and truncation explicit at RTL assignments.
- DEC-038/A-02: allow probes of the retained Shared copy while its atomic upgrade waits for CCU permission; exclude probes after permission acceptance.

**State/verification.** Native state encodings and helper logic remain source-owned. Coherence/maintenance-relevant state machines are discussed in Section 10; native arithmetic/MMU/helper integration is linted, with only the specific activated CPU/FPU cases described in Section 15. No blanket ISA/FP/MMU or helper-equivalence qualification is claimed.

#### 14.5.76 `hpdcache_mshr.sv` — MODIFY

Source: [rtl/common/modified/hpdcache/rtl/src/hpdcache_mshr.sv](../../rtl/modified/hpdcache/rtl/src/hpdcache_mshr.sv).

**Function and local effect.** Outstanding miss identity and busy queries. Track active physical miss lines and preserve request identity through refill/error completion so a probe of the same line waits safely.

![hpdcache_mshr selected modified component](figures/post_a06/hpdcache_mshr.svg)

```json
{"page_name":"BLOCK_DIAGRAM","out_name":"hpdcache_mshr.drawio","layout":{"gap_h":120,"gap_v":110,"margin":80,"block_h":60},"top":{"frame_label":["Component composition","(hpdcache_mshr)"]},"frame_row":["hpdcache_mshr","Native modified component; function and change contract are specified in Section 14.","rtl/common/modified/hpdcache/rtl/src/hpdcache_mshr.sv"],"frame_interfaces":[],"blocks":[{"key":"B0","label":["mshr_mem","(hpdcache_regbank_wbyteenable_1rw)"],"width":400,"row":0,"col":0,"row_name":"mshr_mem (hpdcache_regbank_wbyteenable_1rw)","function":"Native component","source":"REUSE; rtl/common/third_party/hpdcache_cva6_pinned/rtl/src/common/hpdcache_regbank_wbyteenable_1rw.sv"},{"key":"B1","label":["mshr_mem","(hpdcache_regbank_wmask_1rw)"],"width":340,"row":0,"col":1,"row_name":"mshr_mem (hpdcache_regbank_wmask_1rw)","function":"Native component","source":"REUSE; rtl/common/third_party/hpdcache_cva6_pinned/rtl/src/common/hpdcache_regbank_wmask_1rw.sv"},{"key":"B2","label":["mshr_mem","(hpdcache_sram_wbyteenable)"],"width":320,"row":1,"col":0,"row_name":"mshr_mem (hpdcache_sram_wbyteenable)","function":"Native component","source":"REUSE; rtl/common/third_party/hpdcache_cva6_pinned/rtl/src/common/hpdcache_sram_wbyteenable.sv"},{"key":"B3","label":["mshr_mem","(hpdcache_sram_wmask)"],"width":260,"row":1,"col":1,"row_name":"mshr_mem (hpdcache_sram_wmask)","function":"Native component","source":"REUSE; rtl/common/third_party/hpdcache_cva6_pinned/rtl/src/common/hpdcache_sram_wmask.sv"}],"connectors":[],"externals":[],"interfaces":[],"nets":[],"legend_note":"Exact source-referenced children; generate multiplicity and active branches are specified in the component text. Containment denotes hierarchy, not invented signal connectivity. NEW/MODIFY/REUSE/GENERATED provenance is listed in the block table. Clock/reset follow the common synchronous contract. Complete parent port declarations are in the component section.","library_sha256":"15DFB183E267D2A94F8CAB316E01EB3D2E9D2F9C006DC816790A394F4123506C"}
```

[Editable draw.io](figures/post_a06/hpdcache_mshr.drawio) · [Figure source](figures/post_a06/hpdcache_mshr.json).

**Interface and flow.** Keep native typed request/response records and source ordering. The parent wrapper owns translation to VLSIT flat ports. Exact port declarations:

| Direction | Exact source declaration |
|---|---|
| input | `logic clk_i` |
| input | `logic rst_ni` |
| output | `logic empty_o` |
| output | `logic full_o` |
| input | `logic probe_check_i` |
| input | `hpdcache_nline_t probe_check_nline_i` |
| output | `logic probe_hit_o` |
| input | `logic check_i` |
| input | `hpdcache_set_t check_set_i` |
| input | `hpdcache_tag_t check_tag_i` |
| output | `logic hit_o` |
| input | `logic alloc_i` |
| input | `logic alloc_cs_i` |
| input | `hpdcache_nline_t alloc_nline_i` |
| input | `hpdcache_req_tid_t alloc_req_id_i` |
| input | `hpdcache_req_sid_t alloc_src_id_i` |
| input | `hpdcache_word_t alloc_word_i` |
| input | `hpdcache_way_t alloc_victim_way_i` |
| input | `logic alloc_need_rsp_i` |
| input | `logic alloc_is_prefetch_i` |
| input | `logic alloc_wback_i` |
| input | `logic alloc_dirty_i` |
| input | `cbuf_id_t alloc_cbuf_id_i` |
| output | `logic alloc_full_o` |
| output | `mshr_way_t alloc_way_o` |
| input | `logic ack_i` |
| input | `logic ack_cs_i` |
| input | `mshr_set_t ack_set_i` |
| input | `mshr_way_t ack_way_i` |
| output | `hpdcache_req_tid_t ack_req_id_o` |
| output | `hpdcache_req_sid_t ack_src_id_o` |
| output | `hpdcache_set_t ack_cache_set_o` |
| output | `hpdcache_way_t ack_cache_way_o` |
| output | `hpdcache_tag_t ack_cache_tag_o` |
| output | `hpdcache_word_t ack_word_o` |
| output | `logic ack_need_rsp_o` |
| output | `logic ack_is_prefetch_o` |
| output | `logic ack_wback_o` |
| output | `logic ack_dirty_o` |
| output | `cbuf_id_t ack_cbuf_id_o` |

**Recorded local changes (source history, not a substitute for the current contract):**
- Add a parallel exact-line query over valid MSHR entries for coherence integration; retain all upstream allocation, acknowledgement, and RAM logic.

**State/verification.** Native state encodings and helper logic remain source-owned. Coherence/maintenance-relevant state machines are discussed in Section 10; native arithmetic/MMU/helper integration is linted, with only the specific activated CPU/FPU cases described in Section 15. No blanket ISA/FP/MMU or helper-equivalence qualification is claimed.

#### 14.5.77 `hpdcache_rtab.sv` — MODIFY

Source: [rtl/common/modified/hpdcache/rtl/src/hpdcache_rtab.sv](../../rtl/modified/hpdcache/rtl/src/hpdcache_rtab.sv).

**Function and local effect.** Replay and blocked-request lifetime. Retain replay association and avoid reissuing a dependent request while ownership/line locks or failed ordinary eviction hold the cache controller.

![hpdcache_rtab selected modified component](figures/post_a06/hpdcache_rtab.svg)

```json
{"page_name":"BLOCK_DIAGRAM","out_name":"hpdcache_rtab.drawio","layout":{"gap_h":120,"gap_v":110,"margin":80,"block_h":60},"top":{"frame_label":["Component composition","(hpdcache_rtab)"]},"frame_row":["hpdcache_rtab","Native modified component; function and change contract are specified in Section 14.","rtl/common/modified/hpdcache/rtl/src/hpdcache_rtab.sv"],"frame_interfaces":[],"blocks":[{"key":"B0","label":["wbuf_pending_arb_i","(hpdcache_fxarb)"],"width":220,"row":0,"col":0,"row_name":"wbuf_pending_arb_i (hpdcache_fxarb)","function":"Native component","source":"REUSE; rtl/common/third_party/hpdcache_cva6_pinned/rtl/src/common/hpdcache_fxarb.sv"},{"key":"B1","label":["pop_mux_i","(hpdcache_mux)"],"width":180,"row":0,"col":1,"row_name":"pop_mux_i (hpdcache_mux)","function":"Native component","source":"REUSE; rtl/common/third_party/hpdcache_cva6_pinned/rtl/src/common/hpdcache_mux.sv"},{"key":"B2","label":["wbuf_pending_addr_mux_i","(hpdcache_mux)"],"width":280,"row":0,"col":2,"row_name":"wbuf_pending_addr_mux_i (hpdcache_mux)","function":"Native component","source":"REUSE; rtl/common/third_party/hpdcache_cva6_pinned/rtl/src/common/hpdcache_mux.sv"},{"key":"B3","label":["wbuf_pending_is_read_mux_i","(hpdcache_mux)"],"width":300,"row":1,"col":0,"row_name":"wbuf_pending_is_read_mux_i (hpdcache_mux)","function":"Native component","source":"REUSE; rtl/common/third_party/hpdcache_cva6_pinned/rtl/src/common/hpdcache_mux.sv"},{"key":"B4","label":["free_encoder_i","(hpdcache_prio_1hot_encoder)"],"width":340,"row":1,"col":1,"row_name":"free_encoder_i (hpdcache_prio_1hot_encoder)","function":"Native component","source":"REUSE; rtl/common/third_party/hpdcache_cva6_pinned/rtl/src/common/hpdcache_prio_1hot_encoder.sv"},{"key":"B5","label":["pop_arb_i","(hpdcache_rrarb)"],"width":200,"row":1,"col":2,"row_name":"pop_arb_i (hpdcache_rrarb)","function":"Native component","source":"REUSE; rtl/common/third_party/hpdcache_cva6_pinned/rtl/src/common/hpdcache_rrarb.sv"},{"key":"B6","label":["waiters_dir_unavailable_arb_i","(hpdcache_rrarb)"],"width":340,"row":2,"col":0,"row_name":"waiters_dir_unavailable_arb_i (hpdcache_rrarb)","function":"Native component","source":"REUSE; rtl/common/third_party/hpdcache_cva6_pinned/rtl/src/common/hpdcache_rrarb.sv"},{"key":"B7","label":["waiters_mshr_full_arb_i","(hpdcache_rrarb)"],"width":280,"row":2,"col":1,"row_name":"waiters_mshr_full_arb_i (hpdcache_rrarb)","function":"Native component","source":"REUSE; rtl/common/third_party/hpdcache_cva6_pinned/rtl/src/common/hpdcache_rrarb.sv"},{"key":"B8","label":["wbuf_rd_pending_arb_i","(hpdcache_rrarb)"],"width":260,"row":2,"col":2,"row_name":"wbuf_rd_pending_arb_i (hpdcache_rrarb)","function":"Native component","source":"REUSE; rtl/common/third_party/hpdcache_cva6_pinned/rtl/src/common/hpdcache_rrarb.sv"},{"key":"B9","label":["wbuf_wr_pending_arb_i","(hpdcache_rrarb)"],"width":260,"row":3,"col":0,"row_name":"wbuf_wr_pending_arb_i (hpdcache_rrarb)","function":"Native component","source":"REUSE; rtl/common/third_party/hpdcache_cva6_pinned/rtl/src/common/hpdcache_rrarb.sv"}],"connectors":[],"externals":[],"interfaces":[],"nets":[],"legend_note":"Exact source-referenced children; generate multiplicity and active branches are specified in the component text. Containment denotes hierarchy, not invented signal connectivity. NEW/MODIFY/REUSE/GENERATED provenance is listed in the block table. Clock/reset follow the common synchronous contract. Complete parent port declarations are in the component section.","library_sha256":"15DFB183E267D2A94F8CAB316E01EB3D2E9D2F9C006DC816790A394F4123506C"}
```

[Editable draw.io](figures/post_a06/hpdcache_rtab.drawio) · [Figure source](figures/post_a06/hpdcache_rtab.json).

**Interface and flow.** Keep native typed request/response records and source ordering. The parent wrapper owns translation to VLSIT flat ports. Exact port declarations:

| Direction | Exact source declaration |
|---|---|
| input | `logic clk_i` |
| input | `logic rst_ni` |
| output | `logic empty_o` |
| output | `logic full_o` |
| output | `logic fence_o` |
| input | `logic check_i` |
| input | `hpdcache_nline_t check_nline_i` |
| output | `logic check_hit_o` |
| input | `logic alloc_i` |
| input | `logic alloc_and_link_i` |
| input | `rtab_entry_t alloc_req_i` |
| input | `hpdcache_rtab_deps_t alloc_deps_i` |
| input | `logic alloc_probe_lock_i` |
| input | `hpdcache_nline_t alloc_probe_lock_nline_i` |
| output | `logic pop_try_valid_o` |
| input | `logic pop_try_i` |
| output | `rtab_entry_t pop_try_req_o` |
| output | `rtab_ptr_t pop_try_ptr_o` |
| input | `logic pop_commit_i` |
| input | `rtab_ptr_t pop_commit_ptr_i` |
| input | `logic pop_rback_i` |
| input | `rtab_ptr_t pop_rback_ptr_i` |
| output | `hpdcache_req_addr_t wbuf_addr_o` |
| output | `logic wbuf_is_read_o` |
| input | `logic wbuf_hit_open_i` |
| input | `logic wbuf_hit_pend_i` |
| input | `logic wbuf_hit_sent_i` |
| input | `logic wbuf_not_ready_i` |
| input | `logic miss_ready_i` |
| input | `logic refill_i` |
| input | `logic refill_is_error_i` |
| input | `hpdcache_nline_t refill_nline_i` |
| input | `hpdcache_way_t refill_way_index_i` |
| input | `logic flush_ack_i` |
| input | `hpdcache_nline_t flush_ack_nline_i` |
| input | `logic flush_ready_i` |
| input | `logic cfg_single_entry_i` |
| input | `logic [15:0] probe_lock_valid_i` |
| input | `logic [15:0][$bits(hpdcache_nline_t)-1:0] probe_lock_nline_i` |
| input | `logic no_pend_trans_i` |

**Recorded local changes (source history, not a substitute for the current contract):**
- Add a per-entry line-lock dependency that clears only after its exact physical cache line leaves the CCU lock vector.

**State/verification.** Native state encodings and helper logic remain source-owned. Coherence/maintenance-relevant state machines are discussed in Section 10; native arithmetic/MMU/helper integration is linted, with only the specific activated CPU/FPU cases described in Section 15. No blanket ISA/FP/MMU or helper-equivalence qualification is claimed.

#### 14.5.78 `hwpf_stride_wrapper.sv` — MODIFY

Source: [rtl/common/modified/hpdcache/rtl/src/hwpf_stride_wrapper.sv](../../rtl/modified/hpdcache/rtl/src/hwpf_stride_wrapper.sv).

**Function and local effect.** Linear Hardware Memory Prefetcher wrapper.. Preserve the native request/result or storage behavior while applying the explicit local changes recorded below. Its parent consumes the exact typed interfaces in this section; queue, arithmetic, memory and protocol helpers do not create new architectural ownership rules. Native latency/ordering remains source-defined and is not independently qualified by TOP lint.

![hwpf_stride_wrapper selected modified component](figures/post_a06/hwpf_stride_wrapper.svg)

```json
{"page_name":"BLOCK_DIAGRAM","out_name":"hwpf_stride_wrapper.drawio","layout":{"gap_h":120,"gap_v":110,"margin":80,"block_h":60},"top":{"frame_label":["Component composition","(hwpf_stride_wrapper)"]},"frame_row":["hwpf_stride_wrapper","Native modified component; function and change contract are specified in Section 14.","rtl/common/modified/hpdcache/rtl/src/hwpf_stride_wrapper.sv"],"frame_interfaces":[],"blocks":[{"key":"B0","label":["hwpf_stride_i","(hwpf_stride)"],"width":160,"row":0,"col":0,"row_name":"hwpf_stride_i (hwpf_stride)","function":"Native component","source":"MODIFY; rtl/common/modified/hpdcache_cva6_pinned/rtl/src/hwpf_stride/hwpf_stride.sv"},{"key":"B1","label":["hwpf_stride_arb_i","(hwpf_stride_arb)"],"width":200,"row":1,"col":0,"row_name":"hwpf_stride_arb_i (hwpf_stride_arb)","function":"Native component","source":"REUSE; rtl/common/third_party/hpdcache_cva6_pinned/rtl/src/hwpf_stride/hwpf_stride_arb.sv"}],"connectors":[],"externals":[],"interfaces":[],"nets":[],"legend_note":"Exact source-referenced children; generate multiplicity and active branches are specified in the component text. Containment denotes hierarchy, not invented signal connectivity. NEW/MODIFY/REUSE/GENERATED provenance is listed in the block table. Clock/reset follow the common synchronous contract. Complete parent port declarations are in the component section.","library_sha256":"15DFB183E267D2A94F8CAB316E01EB3D2E9D2F9C006DC816790A394F4123506C"}
```

[Editable draw.io](figures/post_a06/hwpf_stride_wrapper.drawio) · [Figure source](figures/post_a06/hwpf_stride_wrapper.json).

**Interface and flow.** Keep native typed request/response records and source ordering. The parent wrapper owns translation to VLSIT flat ports. Exact port declarations:

| Direction | Exact source declaration |
|---|---|
| input | `logic clk_i` |
| input | `logic rst_ni` |
| input | `logic [NUM_HW_PREFETCH-1:0] hwpf_stride_base_set_i` |
| input | `hwpf_stride_base_t [NUM_HW_PREFETCH-1:0] hwpf_stride_base_i` |
| output | `hwpf_stride_base_t [NUM_HW_PREFETCH-1:0] hwpf_stride_base_o` |
| input | `logic [NUM_HW_PREFETCH-1:0] hwpf_stride_param_set_i` |
| input | `hwpf_stride_param_t [NUM_HW_PREFETCH-1:0] hwpf_stride_param_i` |
| output | `hwpf_stride_param_t [NUM_HW_PREFETCH-1:0] hwpf_stride_param_o` |
| input | `logic [NUM_HW_PREFETCH-1:0] hwpf_stride_throttle_set_i` |
| input | `hwpf_stride_throttle_t [NUM_HW_PREFETCH-1:0] hwpf_stride_throttle_i` |
| output | `hwpf_stride_throttle_t [NUM_HW_PREFETCH-1:0] hwpf_stride_throttle_o` |
| output | `hwpf_stride_status_t hwpf_stride_status_o` |
| input | `logic [NUM_SNOOP_PORTS-1:0] snoop_valid_i` |
| input | `logic [NUM_SNOOP_PORTS-1:0] snoop_abort_i` |
| input | `hpdcache_req_offset_t [NUM_SNOOP_PORTS-1:0] snoop_addr_offset_i` |
| input | `hpdcache_tag_t [NUM_SNOOP_PORTS-1:0] snoop_addr_tag_i` |
| input | `logic [NUM_SNOOP_PORTS-1:0] snoop_phys_indexed_i` |
| input | `hpdcache_req_sid_t hpdcache_req_sid_i` |
| output | `logic hpdcache_req_valid_o` |
| input | `logic hpdcache_req_ready_i` |
| output | `hpdcache_req_t hpdcache_req_o` |
| output | `logic hpdcache_req_abort_o` |
| output | `hpdcache_tag_t hpdcache_req_tag_o` |
| output | `hpdcache_pma_t hpdcache_req_pma_o` |
| input | `logic hpdcache_rsp_valid_i` |
| input | `hpdcache_rsp_t hpdcache_rsp_i` |

**Recorded local changes (source history, not a substitute for the current contract):**
- Use explicit two-state width constants for parameterized line/set ranges so the configured subsystem elaborates in Verilator 5.053.
- Restore upstream line/set typedef ranges after explicit-width localparams failed in the configured Verilator elaboration. `include "hpdcache_typedef.svh"
- Make destination-width extension and truncation explicit at RTL assignments.

**State/verification.** Native state encodings and helper logic remain source-owned. Coherence/maintenance-relevant state machines are discussed in Section 10; native arithmetic/MMU/helper integration is linted, with only the specific activated CPU/FPU cases described in Section 15. No blanket ISA/FP/MMU or helper-equivalence qualification is claimed.

#### 14.5.79 `hpdcache_data_upsize.sv` — MODIFY

Source: [rtl/common/modified/hpdcache_cva6_pinned/rtl/src/common/hpdcache_data_upsize.sv](../../rtl/modified/hpdcache_cva6_pinned/rtl/src/common/hpdcache_data_upsize.sv).

**Function and local effect.** Refill data upsize. Preserve the native request/result or storage behavior while applying the explicit local changes recorded below. Its parent consumes the exact typed interfaces in this section; queue, arithmetic, memory and protocol helpers do not create new architectural ownership rules. Native latency/ordering remains source-defined and is not independently qualified by TOP lint.

![hpdcache_data_upsize selected modified component](figures/post_a06/hpdcache_data_upsize.svg)

```json
{"page_name":"BLOCK_DIAGRAM","out_name":"hpdcache_data_upsize.drawio","layout":{"gap_h":120,"gap_v":110,"margin":80,"block_h":60},"top":{"frame_label":["Component composition","(hpdcache_data_upsize)"]},"frame_row":["hpdcache_data_upsize","Native modified component; function and change contract are specified in Section 14.","rtl/common/modified/hpdcache_cva6_pinned/rtl/src/common/hpdcache_data_upsize.sv"],"frame_interfaces":["IN","OUT"],"blocks":[{"key":"B0","label":["component_boundary","(hpdcache_data_upsize)"],"width":260,"row":0,"col":0,"row_name":"component_boundary (hpdcache_data_upsize)","function":"Native component","source":"MODIFY; rtl/common/modified/hpdcache_cva6_pinned/rtl/src/common/hpdcache_data_upsize.sv"}],"connectors":[],"externals":[{"id":"IN","block":"B0","side":"L","dir":"in","pos":0,"text":["IN","ports"]},{"id":"OUT","block":"B0","side":"R","dir":"out","pos":0,"text":["OUT","ports"]}],"interfaces":[{"id":"IN","name":"Parent in ports","category":"custom","active":"in","signals":"clk_i, rst_ni, w_i, wdata_i, wlast_i, r_i"},{"id":"OUT","name":"Parent out ports","category":"custom","active":"out","signals":"wok_o, rok_o, rdata_o"}],"nets":[],"legend_note":"A single boundary symbol denotes a leaf: internal equations/registers are described in its function/dataflow contract, not invented child modules. NEW/MODIFY/REUSE/GENERATED provenance is listed in the block table. Clock/reset follow the common synchronous contract. Complete parent port declarations are in the component section.","library_sha256":"15DFB183E267D2A94F8CAB316E01EB3D2E9D2F9C006DC816790A394F4123506C"}
```

[Editable draw.io](figures/post_a06/hpdcache_data_upsize.drawio) · [Figure source](figures/post_a06/hpdcache_data_upsize.json).

**Interface and flow.** Keep native typed request/response records and source ordering. The parent wrapper owns translation to VLSIT flat ports. Exact port declarations:

| Direction | Exact source declaration |
|---|---|
| input | `logic clk_i` |
| input | `logic rst_ni` |
| input | `logic w_i` |
| output | `logic wok_o` |
| input | `wdata_t wdata_i` |
| input | `logic wlast_i` |
| input | `logic r_i` |
| output | `logic rok_o` |
| output | `rdata_t rdata_o` |

**Recorded local changes (source history, not a substitute for the current contract):**
- Keep pointer and word-count widths legal when no data-width upsizing is needed.

**State/verification.** Native state encodings and helper logic remain source-owned. Coherence/maintenance-relevant state machines are discussed in Section 10; native arithmetic/MMU/helper integration is linted, with only the specific activated CPU/FPU cases described in Section 15. No blanket ISA/FP/MMU or helper-equivalence qualification is claimed.

#### 14.5.80 `hpdcache_cmo.sv` — MODIFY

Source: [rtl/common/modified/hpdcache_cva6_pinned/rtl/src/hpdcache_cmo.sv](../../rtl/modified/hpdcache_cva6_pinned/rtl/src/hpdcache_cmo.sv).

**Function and local effect.** HPDcache Cache-Management-Operation Handler. Preserve the native request/result or storage behavior while applying the explicit local changes recorded below. Its parent consumes the exact typed interfaces in this section; queue, arithmetic, memory and protocol helpers do not create new architectural ownership rules. Native latency/ordering remains source-defined and is not independently qualified by TOP lint.

![hpdcache_cmo selected modified component](figures/post_a06/hpdcache_cmo.svg)

```json
{"page_name":"BLOCK_DIAGRAM","out_name":"hpdcache_cmo.drawio","layout":{"gap_h":120,"gap_v":110,"margin":80,"block_h":60},"top":{"frame_label":["Component composition","(hpdcache_cmo)"]},"frame_row":["hpdcache_cmo","Native modified component; function and change contract are specified in Section 14.","rtl/common/modified/hpdcache_cva6_pinned/rtl/src/hpdcache_cmo.sv"],"frame_interfaces":[],"blocks":[{"key":"B0","label":["flush_req_fifo_i","(hpdcache_fifo_reg)"],"width":220,"row":0,"col":0,"row_name":"flush_req_fifo_i (hpdcache_fifo_reg)","function":"Native component","source":"REUSE; rtl/common/third_party/hpdcache_cva6_pinned/rtl/src/common/hpdcache_fifo_reg.sv"},{"key":"B1","label":["cmoh_core_rsp_buffer_i","(hpdcache_sync_buffer)"],"width":260,"row":1,"col":0,"row_name":"cmoh_core_rsp_buffer_i (hpdcache_sync_buffer)","function":"Native component","source":"REUSE; rtl/common/third_party/hpdcache_cva6_pinned/rtl/src/common/hpdcache_sync_buffer.sv"}],"connectors":[],"externals":[],"interfaces":[],"nets":[],"legend_note":"Exact source-referenced children; generate multiplicity and active branches are specified in the component text. Containment denotes hierarchy, not invented signal connectivity. NEW/MODIFY/REUSE/GENERATED provenance is listed in the block table. Clock/reset follow the common synchronous contract. Complete parent port declarations are in the component section.","library_sha256":"15DFB183E267D2A94F8CAB316E01EB3D2E9D2F9C006DC816790A394F4123506C"}
```

[Editable draw.io](figures/post_a06/hpdcache_cmo.drawio) · [Figure source](figures/post_a06/hpdcache_cmo.json).

**Interface and flow.** Keep native typed request/response records and source ordering. The parent wrapper owns translation to VLSIT flat ports. Exact port declarations:

| Direction | Exact source declaration |
|---|---|
| input | `logic clk_i` |
| input | `logic rst_ni` |
| input | `logic fence_sync_i` |
| output | `logic fence_line_valid_o` |
| input | `logic fence_line_ready_i` |
| output | `hpdcache_nline_t fence_line_o` |
| input | `logic fence_line_done_i` |
| input | `logic fence_line_error_i` |
| output | `logic fence_error_o` |
| output | `hpdcache_nline_t fence_error_line_o` |
| input | `logic req_valid_i` |
| output | `logic req_ready_o` |
| input | `hpdcache_cmoh_op_t req_op_i` |
| input | `hpdcache_req_addr_t req_addr_i` |
| input | `hpdcache_req_sid_t req_sid_i` |
| input | `hpdcache_req_tid_t req_tid_i` |
| input | `logic req_need_rsp_i` |
| input | `logic dirty_set_en_i` |
| input | `hpdcache_set_t dirty_min_set_i` |
| input | `hpdcache_set_t dirty_max_set_i` |
| input | `logic valid_set_en_i` |
| input | `hpdcache_set_t valid_min_set_i` |
| input | `hpdcache_set_t valid_max_set_i` |
| output | `logic flush_all_o` |
| output | `logic inval_all_o` |
| input | `logic core_rsp_ready_i` |
| output | `logic core_rsp_valid_o` |
| output | `hpdcache_rsp_t core_rsp_o` |
| output | `logic dir_check_entry_o` |
| output | `hpdcache_set_t dir_check_entry_set_o` |
| output | `hpdcache_way_vector_t dir_check_entry_way_o` |
| input | `logic dir_check_entry_valid_i` |
| input | `logic dir_check_entry_wback_i` |
| input | `logic dir_check_entry_dirty_i` |
| input | `hpdcache_tag_t dir_check_entry_tag_i` |
| output | `logic dir_updt_o` |
| output | `hpdcache_set_t dir_updt_set_o` |
| output | `hpdcache_way_vector_t dir_updt_way_o` |
| output | `logic dir_updt_valid_o` |
| output | `logic dir_updt_wback_o` |
| output | `logic dir_updt_dirty_o` |
| output | `logic dir_updt_fetch_o` |
| output | `hpdcache_tag_t dir_updt_tag_o` |
| input | `logic flush_empty_i` |
| output | `logic flush_alloc_o` |
| input | `logic flush_alloc_ready_i` |
| output | `hpdcache_nline_t flush_alloc_nline_o` |
| output | `hpdcache_way_vector_t flush_alloc_way_o` |

**Recorded local changes (source history, not a substitute for the current contract):**
- DEC-030/031: retain FENCE.I through coherent clean completion and precise fault. Change: Walk dirty lines through CCU; preserve dirty tracking on ABORT and stop at failed line.

**State/verification.** Native state encodings and helper logic remain source-owned. Coherence/maintenance-relevant state machines are discussed in Section 10; native arithmetic/MMU/helper integration is linted, with only the specific activated CPU/FPU cases described in Section 15. No blanket ISA/FP/MMU or helper-equivalence qualification is claimed.

#### 14.5.81 `hpdcache_uncached.sv` — MODIFY

Source: [rtl/common/modified/hpdcache_cva6_pinned/rtl/src/hpdcache_uncached.sv](../../rtl/modified/hpdcache_cva6_pinned/rtl/src/hpdcache_uncached.sv).

**Function and local effect.** HPDcache uncached and AMO request handler. Preserve the native request/result or storage behavior while applying the explicit local changes recorded below. Its parent consumes the exact typed interfaces in this section; queue, arithmetic, memory and protocol helpers do not create new architectural ownership rules. Native latency/ordering remains source-defined and is not independently qualified by TOP lint.

![hpdcache_uncached selected modified component](figures/post_a06/hpdcache_uncached.svg)

```json
{"page_name":"BLOCK_DIAGRAM","out_name":"hpdcache_uncached.drawio","layout":{"gap_h":120,"gap_v":110,"margin":80,"block_h":60},"top":{"frame_label":["Component composition","(hpdcache_uncached)"]},"frame_row":["hpdcache_uncached","Native modified component; function and change contract are specified in Section 14.","rtl/common/modified/hpdcache_cva6_pinned/rtl/src/hpdcache_uncached.sv"],"frame_interfaces":[],"blocks":[{"key":"B0","label":["amo_unit_i","(hpdcache_amo)"],"width":180,"row":0,"col":0,"row_name":"amo_unit_i (hpdcache_amo)","function":"Native component","source":"REUSE; rtl/common/third_party/hpdcache_cva6_pinned/rtl/src/hpdcache_amo.sv"},{"key":"B1","label":["mem_write_be_demux_i","(hpdcache_demux)"],"width":240,"row":0,"col":1,"row_name":"mem_write_be_demux_i (hpdcache_demux)","function":"Native component","source":"REUSE; rtl/common/third_party/hpdcache_cva6_pinned/rtl/src/common/hpdcache_demux.sv"},{"key":"B2","label":["amo_ld_data_mux_i","(hpdcache_mux)"],"width":200,"row":1,"col":0,"row_name":"amo_ld_data_mux_i (hpdcache_mux)","function":"Native component","source":"REUSE; rtl/common/third_party/hpdcache_cva6_pinned/rtl/src/common/hpdcache_mux.sv"},{"key":"B3","label":["amo_st_data_mux_i","(hpdcache_mux)"],"width":200,"row":1,"col":1,"row_name":"amo_st_data_mux_i (hpdcache_mux)","function":"Native component","source":"REUSE; rtl/common/third_party/hpdcache_cva6_pinned/rtl/src/common/hpdcache_mux.sv"},{"key":"B4","label":["data_read_rsp_mux_i","(hpdcache_mux)"],"width":220,"row":2,"col":0,"row_name":"data_read_rsp_mux_i (hpdcache_mux)","function":"Native component","source":"REUSE; rtl/common/third_party/hpdcache_cva6_pinned/rtl/src/common/hpdcache_mux.sv"}],"connectors":[],"externals":[],"interfaces":[],"nets":[],"legend_note":"Exact source-referenced children; generate multiplicity and active branches are specified in the component text. Containment denotes hierarchy, not invented signal connectivity. NEW/MODIFY/REUSE/GENERATED provenance is listed in the block table. Clock/reset follow the common synchronous contract. Complete parent port declarations are in the component section.","library_sha256":"15DFB183E267D2A94F8CAB316E01EB3D2E9D2F9C006DC816790A394F4123506C"}
```

[Editable draw.io](figures/post_a06/hpdcache_uncached.drawio) · [Figure source](figures/post_a06/hpdcache_uncached.json).

**Interface and flow.** Keep native typed request/response records and source ordering. The parent wrapper owns translation to VLSIT flat ports. Exact port declarations:

| Direction | Exact source declaration |
|---|---|
| input | `logic clk_i` |
| input | `logic rst_ni` |
| input | `logic req_valid_i` |
| output | `logic req_ready_o` |
| input | `hpdcache_uc_op_t req_op_i` |
| input | `hpdcache_req_addr_t req_addr_i` |
| input | `hpdcache_req_size_t req_size_i` |
| input | `hpdcache_req_data_t req_data_i` |
| input | `hpdcache_req_be_t req_be_i` |
| input | `logic req_uc_i` |
| input | `hpdcache_req_sid_t req_sid_i` |
| input | `hpdcache_req_tid_t req_tid_i` |
| input | `logic req_need_rsp_i` |
| input | `hpdcache_way_vector_t req_hit_way_i` |
| input | `hpdcache_req_data_t req_old_data_i` |
| output | `logic data_amo_write_o` |
| output | `logic data_amo_write_enable_o` |
| output | `hpdcache_set_t data_amo_write_set_o` |
| output | `hpdcache_req_size_t data_amo_write_size_o` |
| output | `hpdcache_word_t data_amo_write_word_o` |
| output | `hpdcache_way_vector_t data_amo_write_way_o` |
| output | `hpdcache_req_data_t data_amo_write_data_o` |
| output | `hpdcache_req_be_t data_amo_write_be_o` |
| input | `logic local_fault_i` |
| input | `logic coh_invalidate_i` |
| input | `hpdcache_nline_t coh_invalidate_nline_i` |
| input | `logic local_invalidate_i` |
| input | `hpdcache_nline_t local_invalidate_nline_i` |
| output | `logic lrsc_match_o` |
| output | `logic local_atomic_busy_o` |
| output | `hpdcache_nline_t local_atomic_nline_o` |
| input | `logic lrsc_snoop_i` |
| input | `hpdcache_req_addr_t lrsc_snoop_addr_i` |
| input | `hpdcache_req_size_t lrsc_snoop_size_i` |
| input | `logic core_rsp_ready_i` |
| output | `logic core_rsp_valid_o` |
| output | `hpdcache_rsp_t core_rsp_o` |
| input | `hpdcache_mem_id_t mem_read_id_i` |
| input | `hpdcache_mem_id_t mem_write_id_i` |
| input | `logic mem_req_read_ready_i` |
| output | `logic mem_req_read_valid_o` |
| output | `hpdcache_mem_req_t mem_req_read_o` |
| output | `logic mem_resp_read_ready_o` |
| input | `logic mem_resp_read_valid_i` |
| input | `hpdcache_mem_resp_r_t mem_resp_read_i` |
| input | `logic mem_req_write_ready_i` |
| output | `logic mem_req_write_valid_o` |
| output | `hpdcache_mem_req_t mem_req_write_o` |
| input | `logic mem_req_write_data_ready_i` |
| output | `logic mem_req_write_data_valid_o` |
| output | `hpdcache_mem_req_w_t mem_req_write_data_o` |
| output | `logic mem_resp_write_ready_o` |
| input | `logic mem_resp_write_valid_i` |
| input | `hpdcache_mem_resp_w_t mem_resp_write_i` |
| input | `logic cfg_error_on_cacheable_amo_i` |

**Recorded local changes (source history, not a substitute for the current contract):**
- Make destination-width extension and truncation explicit at RTL assignments.
- DEC-038/A-02: execute cached atomics locally after CCU permission; cancel reservations on probes/evictions and expose the active atomic line.

**State/verification.** Native state encodings and helper logic remain source-owned. Coherence/maintenance-relevant state machines are discussed in Section 10; native arithmetic/MMU/helper integration is linted, with only the specific activated CPU/FPU cases described in Section 15. No blanket ISA/FP/MMU or helper-equivalence qualification is claimed.

#### 14.5.82 `hwpf_stride.sv` — MODIFY

Source: [rtl/common/modified/hpdcache_cva6_pinned/rtl/src/hwpf_stride/hwpf_stride.sv](../../rtl/modified/hpdcache_cva6_pinned/rtl/src/hwpf_stride/hwpf_stride.sv).

**Function and local effect.** HPDcache Linear Hardware Memory Prefetcher.. Preserve the native request/result or storage behavior while applying the explicit local changes recorded below. Its parent consumes the exact typed interfaces in this section; queue, arithmetic, memory and protocol helpers do not create new architectural ownership rules. Native latency/ordering remains source-defined and is not independently qualified by TOP lint.

![hwpf_stride selected modified component](figures/post_a06/hwpf_stride.svg)

```json
{"page_name":"BLOCK_DIAGRAM","out_name":"hwpf_stride.drawio","layout":{"gap_h":120,"gap_v":110,"margin":80,"block_h":60},"top":{"frame_label":["Component composition","(hwpf_stride)"]},"frame_row":["hwpf_stride","Native modified component; function and change contract are specified in Section 14.","rtl/common/modified/hpdcache_cva6_pinned/rtl/src/hwpf_stride/hwpf_stride.sv"],"frame_interfaces":["IN","OUT"],"blocks":[{"key":"B0","label":["component_boundary","(hwpf_stride)"],"width":220,"row":0,"col":0,"row_name":"component_boundary (hwpf_stride)","function":"Native component","source":"MODIFY; rtl/common/modified/hpdcache_cva6_pinned/rtl/src/hwpf_stride/hwpf_stride.sv"}],"connectors":[],"externals":[{"id":"IN","block":"B0","side":"L","dir":"in","pos":0,"text":["IN","ports"]},{"id":"OUT","block":"B0","side":"R","dir":"out","pos":0,"text":["OUT","ports"]}],"interfaces":[{"id":"IN","name":"Parent in ports","category":"custom","active":"in","signals":"clk_i, rst_ni, csr_base_set_i, csr_base_i, csr_param_set_i, csr_param_i, csr_throttle_set_i, csr_throttle_i, snoop_match_i, hpdcache_req_ready_i, hpdcache_rsp_valid_i, hpdcache_rsp_i"},{"id":"OUT","name":"Parent out ports","category":"custom","active":"out","signals":"csr_base_o, csr_param_o, csr_throttle_o, busy_o, snoop_nline_o, hpdcache_req_valid_o, hpdcache_req_o"}],"nets":[],"legend_note":"A single boundary symbol denotes a leaf: internal equations/registers are described in its function/dataflow contract, not invented child modules. NEW/MODIFY/REUSE/GENERATED provenance is listed in the block table. Clock/reset follow the common synchronous contract. Complete parent port declarations are in the component section.","library_sha256":"15DFB183E267D2A94F8CAB316E01EB3D2E9D2F9C006DC816790A394F4123506C"}
```

[Editable draw.io](figures/post_a06/hwpf_stride.drawio) · [Figure source](figures/post_a06/hwpf_stride.json).

**Interface and flow.** Keep native typed request/response records and source ordering. The parent wrapper owns translation to VLSIT flat ports. Exact port declarations:

| Direction | Exact source declaration |
|---|---|
| input | `logic clk_i` |
| input | `logic rst_ni` |
| input | `logic csr_base_set_i` |
| input | `hwpf_stride_base_t csr_base_i` |
| input | `logic csr_param_set_i` |
| input | `hwpf_stride_param_t csr_param_i` |
| input | `logic csr_throttle_set_i` |
| input | `hwpf_stride_throttle_t csr_throttle_i` |
| output | `hwpf_stride_base_t csr_base_o` |
| output | `hwpf_stride_param_t csr_param_o` |
| output | `hwpf_stride_throttle_t csr_throttle_o` |
| output | `logic busy_o` |
| output | `hpdcache_nline_t snoop_nline_o` |
| input | `logic snoop_match_i` |
| output | `logic hpdcache_req_valid_o` |
| input | `logic hpdcache_req_ready_i` |
| output | `hpdcache_req_t hpdcache_req_o` |
| input | `logic hpdcache_rsp_valid_i` |
| input | `hpdcache_rsp_t hpdcache_rsp_i` |

**Recorded local changes (source history, not a substitute for the current contract):**
- Make destination-width extension and truncation explicit at RTL assignments.

**State/verification.** Native state encodings and helper logic remain source-owned. Coherence/maintenance-relevant state machines are discussed in Section 10; native arithmetic/MMU/helper integration is linted, with only the specific activated CPU/FPU cases described in Section 15. No blanket ISA/FP/MMU or helper-equivalence qualification is claimed.

#### 14.5.83 `hpdcache_mem_resp_demux.sv` — MODIFY

Source: [rtl/common/modified/hpdcache_cva6_pinned/rtl/src/utils/hpdcache_mem_resp_demux.sv](../../rtl/modified/hpdcache_cva6_pinned/rtl/src/utils/hpdcache_mem_resp_demux.sv).

**Function and local effect.** Dcache Memory Response Demultiplexer. Preserve the native request/result or storage behavior while applying the explicit local changes recorded below. Its parent consumes the exact typed interfaces in this section; queue, arithmetic, memory and protocol helpers do not create new architectural ownership rules. Native latency/ordering remains source-defined and is not independently qualified by TOP lint.

![hpdcache_mem_resp_demux selected modified component](figures/post_a06/hpdcache_mem_resp_demux.svg)

```json
{"page_name":"BLOCK_DIAGRAM","out_name":"hpdcache_mem_resp_demux.drawio","layout":{"gap_h":120,"gap_v":110,"margin":80,"block_h":60},"top":{"frame_label":["Component composition","(hpdcache_mem_resp_demux)"]},"frame_row":["hpdcache_mem_resp_demux","Native modified component; function and change contract are specified in Section 14.","rtl/common/modified/hpdcache_cva6_pinned/rtl/src/utils/hpdcache_mem_resp_demux.sv"],"frame_interfaces":[],"blocks":[{"key":"B0","label":["i_resp_demux","(hpdcache_demux)"],"width":200,"row":0,"col":0,"row_name":"i_resp_demux (hpdcache_demux)","function":"Native component","source":"REUSE; rtl/common/third_party/hpdcache_cva6_pinned/rtl/src/common/hpdcache_demux.sv"},{"key":"B1","label":["i_resp_valid_demux","(hpdcache_demux)"],"width":220,"row":0,"col":1,"row_name":"i_resp_valid_demux (hpdcache_demux)","function":"Native component","source":"REUSE; rtl/common/third_party/hpdcache_cva6_pinned/rtl/src/common/hpdcache_demux.sv"},{"key":"B2","label":["i_resp_ready_mux","(hpdcache_mux)"],"width":200,"row":1,"col":0,"row_name":"i_resp_ready_mux (hpdcache_mux)","function":"Native component","source":"REUSE; rtl/common/third_party/hpdcache_cva6_pinned/rtl/src/common/hpdcache_mux.sv"}],"connectors":[],"externals":[],"interfaces":[],"nets":[],"legend_note":"Exact source-referenced children; generate multiplicity and active branches are specified in the component text. Containment denotes hierarchy, not invented signal connectivity. NEW/MODIFY/REUSE/GENERATED provenance is listed in the block table. Clock/reset follow the common synchronous contract. Complete parent port declarations are in the component section.","library_sha256":"15DFB183E267D2A94F8CAB316E01EB3D2E9D2F9C006DC816790A394F4123506C"}
```

[Editable draw.io](figures/post_a06/hpdcache_mem_resp_demux.drawio) · [Figure source](figures/post_a06/hpdcache_mem_resp_demux.json).

**Interface and flow.** Keep native typed request/response records and source ordering. The parent wrapper owns translation to VLSIT flat ports. Exact port declarations:

| Direction | Exact source declaration |
|---|---|
| input | `logic clk_i` |
| input | `logic rst_ni` |
| output | `logic mem_resp_ready_o` |
| input | `logic mem_resp_valid_i` |
| input | `resp_id_t mem_resp_id_i` |
| input | `resp_t mem_resp_i` |
| input | `logic mem_resp_ready_i [N-1:0]` |
| output | `logic mem_resp_valid_o [N-1:0]` |
| output | `resp_t mem_resp_o [N-1:0]` |
| input | `rt_t mem_resp_rt_i` |

**Recorded local changes (source history, not a substitute for the current contract):**
- Make destination-width extension and truncation explicit at RTL assignments.

**State/verification.** Native state encodings and helper logic remain source-owned. Coherence/maintenance-relevant state machines are discussed in Section 10; native arithmetic/MMU/helper integration is linted, with only the specific activated CPU/FPU cases described in Section 15. No blanket ISA/FP/MMU or helper-equivalence qualification is claimed.

#### 14.5.84 `hpdcache_mem_to_axi_write.sv` — MODIFY

Source: [rtl/common/modified/hpdcache_cva6_pinned/rtl/src/utils/hpdcache_mem_to_axi_write.sv](../../rtl/modified/hpdcache_cva6_pinned/rtl/src/utils/hpdcache_mem_to_axi_write.sv).

**Function and local effect.** Dcache memory request to axi write channels. Preserve the native request/result or storage behavior while applying the explicit local changes recorded below. Its parent consumes the exact typed interfaces in this section; queue, arithmetic, memory and protocol helpers do not create new architectural ownership rules. Native latency/ordering remains source-defined and is not independently qualified by TOP lint.

![hpdcache_mem_to_axi_write selected modified component](figures/post_a06/hpdcache_mem_to_axi_write.svg)

```json
{"page_name":"BLOCK_DIAGRAM","out_name":"hpdcache_mem_to_axi_write.drawio","layout":{"gap_h":120,"gap_v":110,"margin":80,"block_h":60},"top":{"frame_label":["Component composition","(hpdcache_mem_to_axi_write)"]},"frame_row":["hpdcache_mem_to_axi_write","Native modified component; function and change contract are specified in Section 14.","rtl/common/modified/hpdcache_cva6_pinned/rtl/src/utils/hpdcache_mem_to_axi_write.sv"],"frame_interfaces":["IN","OUT"],"blocks":[{"key":"B0","label":["component_boundary","(hpdcache_mem_to_axi_write)"],"width":320,"row":0,"col":0,"row_name":"component_boundary (hpdcache_mem_to_axi_write)","function":"Native component","source":"MODIFY; rtl/common/modified/hpdcache_cva6_pinned/rtl/src/utils/hpdcache_mem_to_axi_write.sv"}],"connectors":[],"externals":[{"id":"IN","block":"B0","side":"L","dir":"in","pos":0,"text":["IN","ports"]},{"id":"OUT","block":"B0","side":"R","dir":"out","pos":0,"text":["OUT","ports"]}],"interfaces":[{"id":"IN","name":"Parent in ports","category":"custom","active":"in","signals":"req_valid_i, req_i, req_data_valid_i, req_data_i, resp_ready_i, axi_aw_ready_i, axi_w_ready_i, axi_b_valid_i, axi_b_i"},{"id":"OUT","name":"Parent out ports","category":"custom","active":"out","signals":"req_ready_o, req_data_ready_o, resp_valid_o, resp_o, axi_aw_valid_o, axi_aw_o, axi_w_valid_o, axi_w_o, axi_b_ready_o"}],"nets":[],"legend_note":"A single boundary symbol denotes a leaf: internal equations/registers are described in its function/dataflow contract, not invented child modules. NEW/MODIFY/REUSE/GENERATED provenance is listed in the block table. Clock/reset follow the common synchronous contract. Complete parent port declarations are in the component section.","library_sha256":"15DFB183E267D2A94F8CAB316E01EB3D2E9D2F9C006DC816790A394F4123506C"}
```

[Editable draw.io](figures/post_a06/hpdcache_mem_to_axi_write.drawio) · [Figure source](figures/post_a06/hpdcache_mem_to_axi_write.json).

**Interface and flow.** Keep native typed request/response records and source ordering. The parent wrapper owns translation to VLSIT flat ports. Exact port declarations:

| Direction | Exact source declaration |
|---|---|
| output | `logic req_ready_o` |
| input | `logic req_valid_i` |
| input | `hpdcache_mem_req_t req_i` |
| output | `logic req_data_ready_o` |
| input | `logic req_data_valid_i` |
| input | `hpdcache_mem_req_w_t req_data_i` |
| input | `logic resp_ready_i` |
| output | `logic resp_valid_o` |
| output | `hpdcache_mem_resp_w_t resp_o` |
| output | `logic axi_aw_valid_o` |
| output | `aw_chan_t axi_aw_o` |
| input | `logic axi_aw_ready_i` |
| output | `logic axi_w_valid_o` |
| output | `w_chan_t axi_w_o` |
| input | `logic axi_w_ready_i` |
| input | `logic axi_b_valid_i` |
| input | `b_chan_t axi_b_i` |
| output | `logic axi_b_ready_o` |

**Recorded local changes (source history, not a substitute for the current contract):**
- Preserve zero ATOP/lock defaults explicitly for reserved request encodings.

**State/verification.** Native state encodings and helper logic remain source-owned. Coherence/maintenance-relevant state machines are discussed in Section 10; native arithmetic/MMU/helper integration is linted, with only the specific activated CPU/FPU cases described in Section 15. No blanket ISA/FP/MMU or helper-equivalence qualification is claimed.

**Unselected local copies.** None in the captured source inventory. They do not establish a current active implementation or test result.
