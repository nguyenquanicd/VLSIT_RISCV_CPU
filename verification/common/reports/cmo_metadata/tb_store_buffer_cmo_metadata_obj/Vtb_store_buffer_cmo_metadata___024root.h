// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design internal header
// See Vtb_store_buffer_cmo_metadata.h for the primary calling header

#ifndef VERILATED_VTB_STORE_BUFFER_CMO_METADATA___024ROOT_H_
#define VERILATED_VTB_STORE_BUFFER_CMO_METADATA___024ROOT_H_  // guard

#include "verilated.h"
#include "verilated_timing.h"


class Vtb_store_buffer_cmo_metadata__Syms;

class alignas(VL_CACHE_LINE_BYTES) Vtb_store_buffer_cmo_metadata___024root final {
  public:

    // DESIGN-SPECIFIC STATE
    CData/*0:0*/ tb_store_buffer_cmo_metadata__DOT__clk_i;
    CData/*0:0*/ tb_store_buffer_cmo_metadata__DOT__rst_ni;
    CData/*0:0*/ tb_store_buffer_cmo_metadata__DOT__flush_i;
    CData/*0:0*/ tb_store_buffer_cmo_metadata__DOT__commit_i;
    CData/*0:0*/ tb_store_buffer_cmo_metadata__DOT__valid_i;
    CData/*3:0*/ tb_store_buffer_cmo_metadata__DOT__be_i;
    CData/*7:0*/ tb_store_buffer_cmo_metadata__DOT__cbo_op_i;
    CData/*7:0*/ tb_store_buffer_cmo_metadata__DOT__cmo_entry_op_o;
    CData/*2:0*/ tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_status_cnt_q;
    CData/*2:0*/ tb_store_buffer_cmo_metadata__DOT__dut__DOT__commit_status_cnt_q;
    CData/*1:0*/ tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_read_pointer_n;
    CData/*1:0*/ tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_read_pointer_q;
    CData/*1:0*/ tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_write_pointer_n;
    CData/*1:0*/ tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_write_pointer_q;
    CData/*1:0*/ tb_store_buffer_cmo_metadata__DOT__dut__DOT__commit_read_pointer_q;
    CData/*1:0*/ tb_store_buffer_cmo_metadata__DOT__dut__DOT__commit_write_pointer_q;
    CData/*2:0*/ __VdfgRegularize_h6e95ff9d_0_1;
    CData/*0:0*/ __VdfgRegularize_h6e95ff9d_0_2;
    CData/*1:0*/ __VdfgRegularize_h6e95ff9d_0_3;
    CData/*0:0*/ __Vsampled_TOP__tb_store_buffer_cmo_metadata__DOT__rst_ni;
    CData/*0:0*/ __Vsampled_TOP__tb_store_buffer_cmo_metadata__DOT__flush_i;
    CData/*1:0*/ __Vsampled_TOP__tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_read_pointer_q;
    CData/*7:0*/ __Vsampled_TOP__tb_store_buffer_cmo_metadata__DOT__cmo_entry_op_o;
    CData/*0:0*/ __Vsampled_TOP__tb_store_buffer_cmo_metadata__DOT__commit_i;
    CData/*2:0*/ __Vsampled_TOP__tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_status_cnt_q;
    CData/*0:0*/ __Vsampled_TOP__tb_store_buffer_cmo_metadata__DOT__valid_i;
    CData/*2:0*/ __Vsampled_TOP__tb_store_buffer_cmo_metadata__DOT__dut__DOT__commit_status_cnt_q;
    CData/*0:0*/ __Vtrigprevexpr___TOP__tb_store_buffer_cmo_metadata__DOT__clk_i__0;
    CData/*0:0*/ __Vtrigprevexpr___TOP__tb_store_buffer_cmo_metadata__DOT__rst_ni__0;
    IData/*31:0*/ tb_store_buffer_cmo_metadata__DOT__paddr_i;
    IData/*31:0*/ tb_store_buffer_cmo_metadata__DOT__vaddr_i;
    IData/*31:0*/ tb_store_buffer_cmo_metadata__DOT__data_i;
    IData/*31:0*/ __Vi;
    VlUnpacked<VlWide<4>/*111:0*/, 4> tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_queue_n;
    VlUnpacked<VlWide<4>/*111:0*/, 4> tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_queue_q;
    VlUnpacked<VlWide<4>/*111:0*/, 4> tb_store_buffer_cmo_metadata__DOT__dut__DOT__commit_queue_n;
    VlUnpacked<VlWide<4>/*111:0*/, 4> tb_store_buffer_cmo_metadata__DOT__dut__DOT__commit_queue_q;
    VlUnpacked<VlWide<4>/*111:0*/, 4> __Vsampled_TOP__tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_queue_q;
    VlUnpacked<QData/*63:0*/, 1> __VstlTriggered;
    VlUnpacked<QData/*63:0*/, 1> __VicoTriggered;
    VlUnpacked<QData/*63:0*/, 1> __VactTriggered;
    VlUnpacked<QData/*63:0*/, 1> __VactTriggeredAcc;
    VlUnpacked<QData/*63:0*/, 1> __VnbaTriggered;
    VlDelayScheduler __VdlySched;
    VlTriggerScheduler __VtrigSched_h6d618272__0;
    VlTriggerScheduler __VtrigSched_h6d618335__0;

    // INTERNAL VARIABLES
    Vtb_store_buffer_cmo_metadata__Syms* vlSymsp;
    const char* vlNamep;

    // CONSTRUCTORS
    Vtb_store_buffer_cmo_metadata___024root(Vtb_store_buffer_cmo_metadata__Syms* symsp, const char* namep);
    ~Vtb_store_buffer_cmo_metadata___024root();
    VL_UNCOPYABLE(Vtb_store_buffer_cmo_metadata___024root);

    // INTERNAL METHODS
};


#endif  // guard
