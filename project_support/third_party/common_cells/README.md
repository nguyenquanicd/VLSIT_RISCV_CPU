[![Build Status](https://github.com/pulp-platform/common_cells/actions/workflows/ci.yml/badge.svg?branch=master)](https://github.com/pulp-platform/common_cells/actions/workflows/ci.yml?query=branch%3Amaster)
[![GitHub tag (latest SemVer)](https://img.shields.io/github/v/tag/pulp-platform/common_cells?color=blue&label=current&sort=semver)](CHANGELOG.md)
[![SHL-0.51 license](https://img.shields.io/badge/license-SHL--0.51-green)](../../licenses/third_party/common_cells/LICENSE)

# Common Cells Repository

Maintainer: Philippe Sauter <phsauter@iis.ee.ethz.ch>

This repository contains commonly used cells and headers for use in various projects.

## Cell Contents

This repository currently contains the following cells, ordered by categories.
Please note that cells with status *deprecated* are not to be used for new designs and only serve to provide compatibility with old code.

### Clocks and Resets

| Name                                                                  | Description                                                                              | Status | Superseded By |
|-----------------------------------------------------------------------|------------------------------------------------------------------------------------------|--------|---------------|
| [`cc_clk_int_div`](../../../rtl/common/third_party/common_cells/src/cc_clk_int_div.sv)                             | Arbitrary integer clock divider with config interface and 50% output clock duty cycle    | active |               |
| [`cc_clk_int_div_static`](../../../rtl/common/third_party/common_cells/src/cc_clk_int_div_static.sv)               | A convenience wrapper around `cc_clk_int_div` with static division factor.                | active |               |
| [`cc_rstgen`](../../../rtl/common/third_party/common_cells/src/cc_rstgen.sv)                                       | Reset synchronizer                                                                       | active |               |
| [`cc_rstgen_bypass`](../../../rtl/common/third_party/common_cells/src/cc_rstgen_bypass.sv)                         | Reset synchronizer with dedicated test reset bypass                                      | active |               |

### Clock Domains and Asynchronous Crossings

| Name                                                                          | Description                                                                                      | Status | Superseded By |
|-------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------|--------|---------------|
| [`cc_cdc_4phase`](../../../rtl/common/third_party/common_cells/src/cc_cdc_4phase.sv)                                       | Clock domain crossing using 4-phase handshake, with ready/valid interface                        | active |               |
| [`cc_cdc_2phase`](../../../rtl/common/third_party/common_cells/src/cc_cdc_2phase.sv)                                       | Clock domain crossing using two-phase handshake, with ready/valid interface                      | active |               |
| [`cc_cdc_2phase_clearable`](../../../rtl/common/third_party/common_cells/src/cc_cdc_2phase_clearable.sv)                   | Identical to `cc_cdc_2phase` but supports one-sided async/sync resetting of either src or dst    | active |               |
| [`cc_cdc_fifo_2phase`](../../../rtl/common/third_party/common_cells/src/cc_cdc_fifo_2phase.sv)                             | Clock domain crossing FIFO using two-phase handshake, with ready/valid interface                 | active |               |
| [`cc_cdc_fifo_gray`](../../../rtl/common/third_party/common_cells/src/cc_cdc_fifo_gray.sv)                                 | Clock domain crossing FIFO using a gray-counter, with ready/valid interface                      | active |               |
| [`cc_cdc_fifo_gray_clearable`](../../../rtl/common/third_party/common_cells/src/cc_cdc_fifo_gray_clearable.sv)             | Identical to `cc_cdc_fifo_gray` but supports one-sided async/sync resetting of either src or dst | active |               |
| [`cc_cdc_reset_ctrlr`](../../../rtl/common/third_party/common_cells/src/cc_cdc_reset_ctrlr.sv)                             | Lock-step reset sequencer across clock domains, internally used by clearable CDCs                | active |               |
| [`cc_clk_mux_glitch_free`](../../../rtl/common/third_party/common_cells/src/cc_clk_mux_glitch_free.sv)                     | A glitch-free clock multiplexer with parameterizable number of inputs.                           | active |               |
| [`cc_edge_detect`](../../../rtl/common/third_party/common_cells/src/cc_edge_detect.sv)                                     | Rising/falling edge detector                                                                     | active |               |
| [`cc_edge_propagator`](../../../rtl/common/third_party/common_cells/src/cc_edge_propagator.sv)                             | Propagates a single-cycle pulse across an asynchronous clock domain crossing                     | active |               |
| [`cc_edge_propagator_ack`](../../../rtl/common/third_party/common_cells/src/cc_edge_propagator_ack.sv)                     | `cc_edge_propagator` with sender-synchronous acknowledge pin, flags received pulse               | active |               |
| [`cc_edge_propagator_rx`](../../../rtl/common/third_party/common_cells/src/cc_edge_propagator_rx.sv)                       | Receive slice of `cc_edge_propagator`, requires only the receiver clock                          | active |               |
| [`cc_edge_propagator_tx`](../../../rtl/common/third_party/common_cells/src/cc_edge_propagator_tx.sv)                       | Transmit slice of `cc_edge_propagator`, requires only the sender clock                           | active |               |
| [`cc_isochronous_spill_register`](../../../rtl/common/third_party/common_cells/src/cc_isochronous_spill_register.sv)       | Isochronous clock domain crossing and full handshake, like `cc_spill_register`                   | active |               |
| [`cc_isochronous_4phase_handshake`](../../../rtl/common/third_party/common_cells/src/cc_isochronous_4phase_handshake.sv)   | Isochronous four-phase handshake.                                                                | active |               |
| [`cc_serial_deglitch`](../../../rtl/common/third_party/common_cells/src/cc_serial_deglitch.sv)                             | Update output only after input has remained stable for a number of cycles                        | active |               |
| [`cc_majority_vote_filter`](../../../rtl/common/third_party/common_cells/src/cc_majority_vote_filter.sv)                   | Smooth noisy data using a moving window threshold vote                                           | active |               |
| [`cc_sync_wedge`](../../../rtl/common/third_party/common_cells/src/cc_sync_wedge.sv)                                       | Serial line synchronizer with edge detector                                                      | active |               |

The generic synchronizer is provided by the [`tech_cells_generic`](https://github.com/pulp-platform/tech_cells_generic) dependency as `tc_sync`.

### Counters and Shift Registers

| Name                                              | Description                                                         | Status | Superseded By |
| ------------------------------------------------- | ------------------------------------------------------------------- | ------ | ------------- |
| [`cc_counter`](../../../rtl/common/third_party/common_cells/src/cc_counter.sv)                 | Generic up/down counter with overflow detection                     | active |               |
| [`cc_credit_counter`](../../../rtl/common/third_party/common_cells/src/cc_credit_counter.sv)   | Up/down counter for credit                                          | active |               |
| [`cc_delta_counter`](../../../rtl/common/third_party/common_cells/src/cc_delta_counter.sv)     | Up/down counter with variable delta and overflow detection          | active |               |
| [`cc_exp_backoff`](../../../rtl/common/third_party/common_cells/src/cc_exp_backoff.sv)         | Exponential backoff counter with randomization                      | active |               |
| [`cc_lfsr_8bit`](../../../rtl/common/third_party/common_cells/src/cc_lfsr_8bit.sv)             | 8-bit linear feedback shift register (LFSR)                         | active |               |
| [`cc_lfsr_16bit`](../../../rtl/common/third_party/common_cells/src/cc_lfsr_16bit.sv)           | 16-bit linear feedback shift register (LFSR)                        | active |               |
| [`cc_lfsr`](../../../rtl/common/third_party/common_cells/src/cc_lfsr.sv)                       | 4...64-bit parametric Galois LFSR with optional whitening feature   | active |               |
| [`cc_max_counter`](../../../rtl/common/third_party/common_cells/src/cc_max_counter.sv)         | Up/down counter with variable delta that tracks its maximum value   | active |               |
| [`cc_trip_counter`](../../../rtl/common/third_party/common_cells/src/cc_trip_counter.sv)       | Counter that resets automatically when it reaches a specified bound | active |               |

### Data Path Elements

| Name                                                                      | Description                                                                                               | Status | Superseded By |
|---------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------|--------|---------------|
| [`cc_addr_decode`](../../../rtl/common/third_party/common_cells/src/cc_addr_decode.sv)                                 | Address map decoder                                                                                       | active |               |
| [`cc_addr_decode_dync`](../../../rtl/common/third_party/common_cells/src/cc_addr_decode_dync.sv)                       | Address map decoder extended to support dynamic online configuration                                      | active |               |
| [`cc_addr_decode_napot`](../../../rtl/common/third_party/common_cells/src/cc_addr_decode_napot.sv)                     | Address map decoder using naturally-aligned power of two (NAPOT) regions                                  | active |               |
| [`cc_multiaddr_decode`](../../../rtl/common/third_party/common_cells/src/cc_multiaddr_decode.sv)                       | Address map decoder using NAPOT regions and allowing for multiple address inputs                          | active |               |
| [`cc_ecc_decode`](../../../rtl/common/third_party/common_cells/src/cc_ecc_decode.sv)                                   | SECDED Decoder (Single Error Correction, Double Error Detection)                                          | active |               |
| [`cc_ecc_encode`](../../../rtl/common/third_party/common_cells/src/cc_ecc_encode.sv)                                   | SECDED Encoder (Single Error Correction, Double Error Detection)                                          | active |               |
| [`cc_binary_to_gray`](../../../rtl/common/third_party/common_cells/src/cc_binary_to_gray.sv)                           | Binary to gray code converter                                                                             | active |               |
| [`cc_gray_to_binary`](../../../rtl/common/third_party/common_cells/src/cc_gray_to_binary.sv)                           | Gray code to binary converter                                                                             | active |               |
| [`cc_lzc`](../../../rtl/common/third_party/common_cells/src/cc_lzc.sv)                                                 | Leading/trailing-zero counter                                                                             | active |               |
| [`cc_onehot`](../../../rtl/common/third_party/common_cells/src/cc_onehot.sv)                                           | Hardware implementation of SystemVerilog's `$onehot()` function                                           | active |               |
| [`cc_onehot_to_bin`](../../../rtl/common/third_party/common_cells/src/cc_onehot_to_bin.sv)                             | One-hot to binary converter                                                                               | active |               |
| [`cc_shift_register`](../../../rtl/common/third_party/common_cells/src/cc_shift_register.sv)                           | Shift register for arbitrary types                                                                        | active |               |
| [`cc_shift_register_gated`](../../../rtl/common/third_party/common_cells/src/cc_shift_register_gated.sv)               | Shift register with ICG for arbitrary types                                                               | active |               |
| [`cc_rr_arb_tree`](../../../rtl/common/third_party/common_cells/src/cc_rr_arb_tree.sv)                                 | Round-robin arbiter for req/gnt and vld/rdy interfaces with optional priority                             | active |               |
| [`cc_fall_through_register`](../../../rtl/common/third_party/common_cells/src/cc_fall_through_register.sv)             | Fall-through register with ready/valid interface                                                          | active |               |
| [`cc_spill_register_flushable`](../../../rtl/common/third_party/common_cells/src/cc_spill_register_flushable.sv)       | Register with ready/valid interface to cut all combinational interface paths and additional flush signal. | active |               |
| [`cc_spill_register`](../../../rtl/common/third_party/common_cells/src/cc_spill_register.sv)                           | Register with ready/valid interface to cut all combinational interface paths                              | active |               |
| [`cc_stream_arbiter`](../../../rtl/common/third_party/common_cells/src/cc_stream_arbiter.sv)                           | Round-robin arbiter for ready/valid stream interface                                                      | active |               |
| [`cc_stream_demux`](../../../rtl/common/third_party/common_cells/src/cc_stream_demux.sv)                               | Ready/valid interface demultiplexer                                                                       | active |               |
| [`cc_lossy_valid_to_stream`](../../../rtl/common/third_party/common_cells/src/cc_lossy_valid_to_stream.sv)             | Convert Valid-only to ready/valid by updating in-flight transaction                                       | active |               |
| [`cc_stream_join`](../../../rtl/common/third_party/common_cells/src/cc_stream_join.sv)                                 | Ready/valid handshake join multiple to one common                                                         | active |               |
| [`cc_stream_join_dynamic`](../../../rtl/common/third_party/common_cells/src/cc_stream_join_dynamic.sv)                 | Ready/valid handshake join multiple to one common, dynamically configurable subset selection              | active |               |
| [`cc_stream_mux`](../../../rtl/common/third_party/common_cells/src/cc_stream_mux.sv)                                   | Ready/valid interface multiplexer                                                                         | active |               |
| [`cc_stream_register`](../../../rtl/common/third_party/common_cells/src/cc_stream_register.sv)                         | Register with ready/valid interface                                                                       | active |               |
| [`cc_stream_fork`](../../../rtl/common/third_party/common_cells/src/cc_stream_fork.sv)                                 | Ready/valid fork                                                                                          | active |               |
| [`cc_stream_fork_dynamic`](../../../rtl/common/third_party/common_cells/src/cc_stream_fork_dynamic.sv)                 | Ready/valid fork, with selection mask for partial forking                                                 | active |               |
| [`cc_stream_filter`](../../../rtl/common/third_party/common_cells/src/cc_stream_filter.sv)                             | Ready/valid filter                                                                                        | active |               |
| [`cc_stream_delay`](../../../rtl/common/third_party/common_cells/src/cc_stream_delay.sv)                               | Randomize or delay ready/valid interface                                                                  | active |               |
| [`cc_stream_to_mem`](../../../rtl/common/third_party/common_cells/src/cc_stream_to_mem.sv)                             | Use memories without flow control for output data in streams.                                             | active |               |
| [`cc_stream_xbar`](../../../rtl/common/third_party/common_cells/src/cc_stream_xbar.sv)                                 | Fully connected crossbar with ready/valid interface.                                                      | active |               |
| [`cc_stream_omega_net`](../../../rtl/common/third_party/common_cells/src/cc_stream_omega_net.sv)                       | One-way stream omega-net with ready/valid interface. Isomorphic to a butterfly.                           | active |               |
| [`cc_stream_throttle`](../../../rtl/common/third_party/common_cells/src/cc_stream_throttle.sv)                         | Restrict the number of outstanding transfers in a stream.                                                 | active |               |
| [`cc_sub_per_hash`](../../../rtl/common/third_party/common_cells/src/cc_sub_per_hash.sv)                               | Substitution-permutation hash function                                                                    | active |               |
| [`cc_popcount`](../../../rtl/common/third_party/common_cells/src/cc_popcount.sv)                                       | Combinatorial popcount (hamming weight)                                                                   | active |               |
| [`cc_mem_to_banks_detailed`](../../../rtl/common/third_party/common_cells/src/cc_mem_to_banks_detailed.sv)             | Split memory access over multiple parallel banks with detailed response signals                           | active |               |
| [`cc_mem_to_banks`](../../../rtl/common/third_party/common_cells/src/cc_mem_to_banks.sv)                               | Split memory access over multiple parallel banks                                                          | active |               |
| [`cc_heaviside`](../../../rtl/common/third_party/common_cells/src/cc_heaviside.sv)                                     | Generates a mask obtained by applying the Heaviside step function                                         | active |               |
| [`cc_boxcar`](../../../rtl/common/third_party/common_cells/src/cc_boxcar.sv)                                           | Generates a mask obtained by applying a boxcar function                                                   | active |               |

### Data Structures

| Name                                                                        | Description                                                                | Status | Superseded By |
| --------------------------------------------------------------------------- | -------------------------------------------------------------------------- | ------ | ------------- |
| [`cc_cb_filter`](../../../rtl/common/third_party/common_cells/src/cc_cb_filter.sv)                                       | Counting-Bloom-Filter with combinational lookup                            | active |               |
| [`cc_fifo`](../../../rtl/common/third_party/common_cells/src/cc_fifo.sv)                                                 | FIFO register with generic fill counts                                     | active |               |
| [`cc_id_queue`](../../../rtl/common/third_party/common_cells/src/cc_id_queue.sv)                                         | Queue that preserves FIFO order for entries with the same ID               | active |               |
| [`cc_passthrough_stream_fifo`](../../../rtl/common/third_party/common_cells/src/cc_passthrough_stream_fifo.sv)           | FIFO register with ready/valid interface and same-cycle push/pop when full | active |               |
| [`cc_ring_buffer`](../../../rtl/common/third_party/common_cells/src/cc_ring_buffer.sv)                                   | Ring buffer with sequential write and random-access read interfaces        | active |               |
| [`cc_stream_fifo`](../../../rtl/common/third_party/common_cells/src/cc_stream_fifo.sv)                                   | FIFO register with ready/valid interface                                   | active |               |
| [`cc_stream_fifo_optimal_wrap`](../../../rtl/common/third_party/common_cells/src/cc_stream_fifo_optimal_wrap.sv)         | Wrapper that optimally selects either a spill register or a FIFO           | active |               |
| [`cc_plru_tree`](../../../rtl/common/third_party/common_cells/src/cc_plru_tree.sv)                                       | Pseudo least recently used tree                                            | active |               |
| [`cc_unread`](../../../rtl/common/third_party/common_cells/src/cc_unread.sv)                                             | Empty module to sink unconnected outputs into                              | active |               |
| [`cc_read`](../../../rtl/common/third_party/common_cells/src/cc_read.sv)                                                 | Dummy module that prevents a signal from being removed during synthesis    | active |               |

### Packages and Interfaces

| Name                                             | Description                                                       | Status | Superseded By |
| ------------------------------------------------ | ----------------------------------------------------------------- | ------ | ------------- |
| [`cc_pkg`](../../../rtl/common/third_party/common_cells/src/cc_pkg.sv)                        | Shared package for common functions, types, and encodings         | active |               |
| [`cc_stream_dv`](../../../rtl/common/third_party/common_cells/src/cc_stream_intf.sv)          | Ready/valid stream interface with a custom payload type           | active |               |

### Ports

Generally, modules with sequential logic receive at least the following inputs.
Intentional exceptions are clock, reset, cdc cells, and any cells that receive multiple clock inputs.

| Name     | Description                                                                                                                                                   |
| -------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `clk_i`  | Clock driving sequential logic.                                                                                                                               |
| `rst_ni` | Asynchronous reset, active-low. Brings the module to its reset state.                                                                                         |
| `clr_i`  | Synchronous clear, active-high. Brings the module to its reset state in the next clock cycle. Can be driven by synchronous logic or tied to `1'b0` if unused. |

### Use of Macros

Internally, the cells use macros to implement sequential logic (flip-flops) and assertions.
These macros are defined in this repo; see [RTL Register Macros](#rtl-register-macros) and [SVA Macros](#systemverilog-assertion-macros) below for more details.

## Header Contents

This repository currently contains the following header files.

### RTL Register Macros

The header file [`registers.svh`](../../../rtl/common/third_party/common_cells/include/common_cells/registers.svh) contains macros that expand to descriptions of registers.
To avoid misuse of `always_ff` blocks, only the following macros shall be used to describe sequential behavior.
The use of linter rules that flag explicit uses of `always_ff` in source code is encouraged.

|    Macro              |                             Arguments                                        |                                Description                                                   |
| --------------------- | ---------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------- |
| <code>`FF</code>      | `q_sig`, `d_sig`, `rst_val`, (`clk_sig`, `arstn_sig`)                        | Flip-flop with asynchronous active-low reset                                                 |
| <code>`FFAR</code>    | `q_sig`, `d_sig`, `rst_val`, (`clk_sig`, `arst_sig`)                         | Flip-flop with asynchronous active-high reset                                                |
| <code>`FFARNC</code>  | `q_sig`, `d_sig`, `clr_sig`, `rst_val`, (`clk_sig`, `arstn_sig`)             | Flip-flop with asynchronous active-low reset and synchronous active-high clear               |
| <code>`FFSR</code>    | `q_sig`, `d_sig`, `rst_val`, `clk_sig`, `rst_sig`                            | Flip-flop with synchronous active-high reset                                                 |
| <code>`FFSRN</code>   | `q_sig`, `d_sig`, `rst_val`, `clk_sig`, `rstn_sig`                           | Flip-flop with synchronous active-low reset                                                  |
| <code>`FFNR</code>    | `q_sig`, `d_sig`, (`clk_sig`)                                                | Flip-flop without reset                                                                      |
|                       |                                                                              |                                                                                              |
| <code>`FFL</code>     | `q_sig`, `d_sig`, `load_ena`, `rst_val`, (`clk_sig`, `arstn_sig`)            | Flip-flop with load-enable and asynchronous active-low reset                                 |
| <code>`FFLAR</code>   | `q_sig`, `d_sig`, `load_ena`, `rst_val`, (`clk_sig`, `arst_sig`)             | Flip-flop with load-enable and asynchronous active-high reset                                |
| <code>`FFLARNC</code> | `q_sig`, `d_sig`, `load_ena`, `clr_sig`, `rst_val`, (`clk_sig`, `arstn_sig`) | Flip-flop with load-enable, asynchronous active-low reset and synchronous active-high clear |
| <code>`FFLSR</code>   | `q_sig`, `d_sig`, `load_ena`, `rst_val`, `clk_sig`, `rst_sig`                | Flip-flop with load-enable and synchronous active-high reset                                 |
| <code>`FFLSRN</code>  | `q_sig`, `d_sig`, `load_ena`, `rst_val`, `clk_sig`, `rstn_sig`               | Flip-flop with load-enable and synchronous active-low reset                                  |
| <code>`FFLNR</code>   | `q_sig`, `d_sig`, `load_ena`, (`clk_sig`)                                    | Flip-flop with load-enable without reset                                                     |
- *The name of the clock signal for implicit variants is `clk_i`.*
- *The name of the reset signal for implicit variants is `rst_i` or `rst_ni`, respectively for active-high and active-low variants.*
- *Argument suffix `_sig` indicates signal names for present and next state as well as clocks, resets and synchronous clear signals.*
- *Argument `rst_val` specifies the value literal to be assigned upon reset.*
- *Argument `load_ena` specifies the boolean expression that forms the load enable of the register.*
- *Arguments `clr_sig`, `rst_sig` and `rstn_sig` must be plain signal names, not expressions.*

### SystemVerilog Assertion Macros

The header file [`assertions.svh`](../../../rtl/common/third_party/common_cells/include/common_cells/assertions.svh) contains macros that expand to assertion blocks.
These macros should reduce the effort in writing many assertions and make it
easier to use them. They are similar to but incompatible with the macros used by [lowrisc](https://github.com/lowRISC/opentitan/blob/master/hw/ip/prim/rtl/prim_assert.sv).

#### Simple Assertion and Cover Macros
| Macro              | Arguments                                        | Description                                                                |
| ------------------ | ------------------------------------------------ | -------------------------------------------------------------------------- |
| <code>`ASSERT_I</code>     | `__name`, `__prop`, (`__desc`)                   | Immediate assertion                                                        |
| <code>`ASSERT_INIT</code>  | `__name`, `__prop`, (`__desc`)                   | Assertion in initial block. Can be used for things like parameter checking |
| <code>`ASSERT_FINAL</code> | `__name`, `__prop`, (`__desc`)                   | Assertion in final block                                                   |
| <code>`ASSERT</code>       | `__name`, `__prop`, (`__clk`, `__rst`, `__desc`) | Assert a concurrent property directly                                      |
| <code>`ASSERT_NEVER</code> | `__name`, `__prop`, (`__clk`, `__rst`, `__desc`) | Assert a concurrent property NEVER happens                                 |
| <code>`ASSERT_KNOWN</code> | `__name`, `__sig`, (`__clk`, `__rst`, `__desc`)  | Concurrent clocked assertion with custom error message                     |
| <code>`COVER</code>        | `__name`, `__prop`, (`__clk`, `__rst`)           | Cover a concurrent property                                                |
- *The name of the clock and reset signals for implicit variants is `clk_i` and `rst_ni`, respectively.*
- *`__desc` is an optional string argument describing the failure causing the assertion to be violated that is embedded into the error report and defaults to `""`.*

#### Complex Assertion Macros
| Macro                 | Arguments                                                                           | Description                                                                                                |
| --------------------- | ----------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------- |
| <code>`ASSERT_PULSE</code>    | `__name`, `__sig`, (`__clk`, `__rst`, `__desc`)                                     | Assert that signal is an active-high pulse with pulse length of 1 clock cycle                              |
| <code>`ASSERT_IF</code>       | `__name`, `__prop`, `__enable`, (`__clk`, `__rst`, `__desc`)                        | Assert that a property is true only when an enable signal is set                                           |
| <code>`ASSERT_KNOWN_IF</code> | `__name`, `__sig`, `__enable`, (`__clk`, `__rst`, `__desc`)                         | Assert that signal has a known value (each bit is either '0' or '1') after reset if enable is set          |
| <code>`ASSERT_STABLE</code>   | `__name`, `__valid`, `__ready`, `__data`, (`__mask`, `__clk`, `__rst`, `__desc`)    | Assert that the unmasked data on a ready-valid interface is kept stable after valid is asserted, until ready is asserted |
- *The name of the clock and reset signals for implicit variants is `clk_i` and `rst_ni`, respectively.*
- *`__desc` is an optional string argument describing the failure causing the assertion to be violated that is embedded into the error report and defaults to `""`.*

#### Assumption Macros

| Macro          | Arguments                                        | Description                  |
| -------------- | ------------------------------------------------ | ---------------------------- |
| <code>`ASSUME</code>   | `__name`, `__prop`, (`__clk`, `__rst`, `__desc`) | Assume a concurrent property |
| <code>`ASSUME_I</code> | `__name`, `__prop`, (`__desc`)                   | Assume an immediate property |
- *The name of the clock and reset signals for implicit variants is `clk_i` and `rst_ni`, respectively.*
- *`__desc` is an optional string argument describing the failure causing the assertion to be violated that is embedded into the error report and defaults to `""`.*

#### Formal Verification Macros

| Macro              | Arguments                                        | Description                                                  |
| ------------------ | ------------------------------------------------ | ------------------------------------------------------------ |
| <code>`ASSUME_FPV</code>   | `__name`, `__prop`, (`__clk`, `__rst`, `__desc`) | Assume a concurrent property during formal verification only |
| <code>`ASSUME_I_FPV</code> | `__name`, `__prop`, (`__desc`)                   | Assume an immediate property during formal verification only |
| <code>`COVER_FPV</code>    | `__name`, `__prop`, (`__clk`, `__rst`)           | Cover a concurrent property during formal verification       |
- *The name of the clock and reset signals for implicit variants is `clk_i` and `rst_ni`, respectively.*
- *`__desc` is an optional string argument describing the failure causing the assertion to be violated that is embedded into the error report and defaults to `""`.*
