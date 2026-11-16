// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design internal header
// See Vtb_store_unit_cmo_metadata.h for the primary calling header

#ifndef VERILATED_VTB_STORE_UNIT_CMO_METADATA___024ROOT_H_
#define VERILATED_VTB_STORE_UNIT_CMO_METADATA___024ROOT_H_  // guard

#include "verilated.h"
#include "verilated_timing.h"


class Vtb_store_unit_cmo_metadata__Syms;

class alignas(VL_CACHE_LINE_BYTES) Vtb_store_unit_cmo_metadata___024root final {
  public:

    // DESIGN-SPECIFIC STATE
    CData/*0:0*/ tb_store_unit_cmo_metadata__DOT__clk_i;
    CData/*0:0*/ tb_store_unit_cmo_metadata__DOT__rst_ni;
    CData/*0:0*/ tb_store_unit_cmo_metadata__DOT__valid_i;
    CData/*1:0*/ tb_store_unit_cmo_metadata__DOT__dut__DOT__state_q;
    CData/*0:0*/ tb_store_unit_cmo_metadata__DOT__dut__DOT__instr_is_amo;
    CData/*7:0*/ tb_store_unit_cmo_metadata__DOT__dut__DOT__st_be_q;
    CData/*1:0*/ tb_store_unit_cmo_metadata__DOT__dut__DOT__st_data_size_q;
    CData/*3:0*/ tb_store_unit_cmo_metadata__DOT__dut__DOT__amo_op_q;
    CData/*7:0*/ tb_store_unit_cmo_metadata__DOT__dut__DOT__cbo_op_q;
    CData/*0:0*/ tb_store_unit_cmo_metadata__DOT__dut__DOT__store_buffer_valid;
    CData/*0:0*/ tb_store_unit_cmo_metadata__DOT__dut__DOT__amo_buffer_valid;
    CData/*1:0*/ tb_store_unit_cmo_metadata__DOT__dut__DOT__genblk1__DOT__i_amo_buffer__DOT__i_amo_fifo__DOT__status_cnt_q;
    CData/*2:0*/ tb_store_unit_cmo_metadata__DOT__dut__DOT__store_buffer_i__DOT__speculative_status_cnt_n;
    CData/*2:0*/ tb_store_unit_cmo_metadata__DOT__dut__DOT__store_buffer_i__DOT__speculative_status_cnt_q;
    CData/*1:0*/ tb_store_unit_cmo_metadata__DOT__dut__DOT__store_buffer_i__DOT__speculative_read_pointer_q;
    CData/*1:0*/ tb_store_unit_cmo_metadata__DOT__dut__DOT__store_buffer_i__DOT__speculative_write_pointer_q;
    CData/*0:0*/ __VdfgRegularize_h6e95ff9d_0_2;
    CData/*1:0*/ __VdfgRegularize_h6e95ff9d_0_4;
    CData/*1:0*/ __VdfgRegularize_h6e95ff9d_0_10;
    CData/*1:0*/ __Vsampled_TOP__tb_store_unit_cmo_metadata__DOT__dut__DOT__genblk1__DOT__i_amo_buffer__DOT__i_amo_fifo__DOT__status_cnt_q;
    CData/*0:0*/ __Vsampled_TOP__tb_store_unit_cmo_metadata__DOT__dut__DOT__amo_buffer_valid;
    CData/*0:0*/ __Vsampled_TOP__tb_store_unit_cmo_metadata__DOT__rst_ni;
    CData/*2:0*/ __Vsampled_TOP__tb_store_unit_cmo_metadata__DOT__dut__DOT__store_buffer_i__DOT__speculative_status_cnt_q;
    CData/*0:0*/ __Vsampled_TOP__tb_store_unit_cmo_metadata__DOT__dut__DOT__store_buffer_valid;
    CData/*0:0*/ __Vtrigprevexpr___TOP__tb_store_unit_cmo_metadata__DOT__clk_i__0;
    CData/*0:0*/ __Vtrigprevexpr___TOP__tb_store_unit_cmo_metadata__DOT__rst_ni__0;
    IData/*31:0*/ __Vi;
    VlWide<6>/*180:0*/ tb_store_unit_cmo_metadata__DOT__ctrl;
    QData/*55:0*/ tb_store_unit_cmo_metadata__DOT__pa;
    QData/*63:0*/ tb_store_unit_cmo_metadata__DOT__dut__DOT__st_data_q;
    QData/*63:0*/ tb_store_unit_cmo_metadata__DOT__dut__DOT__st_vaddr_q;
    VlUnpacked<VlWide<7>/*203:0*/, 4> tb_store_unit_cmo_metadata__DOT__dut__DOT__store_buffer_i__DOT__speculative_queue_n;
    VlUnpacked<VlWide<7>/*203:0*/, 4> tb_store_unit_cmo_metadata__DOT__dut__DOT__store_buffer_i__DOT__speculative_queue_q;
    VlUnpacked<QData/*63:0*/, 1> __VstlTriggered;
    VlUnpacked<QData/*63:0*/, 1> __VicoTriggered;
    VlUnpacked<QData/*63:0*/, 1> __VactTriggered;
    VlUnpacked<QData/*63:0*/, 1> __VactTriggeredAcc;
    VlUnpacked<QData/*63:0*/, 1> __VnbaTriggered;
    VlDelayScheduler __VdlySched;
    VlTriggerScheduler __VtrigSched_h2b5d7992__0;
    VlTriggerScheduler __VtrigSched_h2b5c8a55__0;

    // INTERNAL VARIABLES
    Vtb_store_unit_cmo_metadata__Syms* vlSymsp;
    const char* vlNamep;

    // CONSTRUCTORS
    Vtb_store_unit_cmo_metadata___024root(Vtb_store_unit_cmo_metadata__Syms* symsp, const char* namep);
    ~Vtb_store_unit_cmo_metadata___024root();
    VL_UNCOPYABLE(Vtb_store_unit_cmo_metadata___024root);

    // INTERNAL METHODS
};


#endif  // guard
