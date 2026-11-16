// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design internal header
// See Vtb_cmo_retirement.h for the primary calling header

#ifndef VERILATED_VTB_CMO_RETIREMENT___024ROOT_H_
#define VERILATED_VTB_CMO_RETIREMENT___024ROOT_H_  // guard

#include "verilated.h"
#include "verilated_timing.h"


class Vtb_cmo_retirement__Syms;

class alignas(VL_CACHE_LINE_BYTES) Vtb_cmo_retirement___024root final {
  public:

    // DESIGN-SPECIFIC STATE
    CData/*0:0*/ tb_cmo_retirement__DOT__clk;
    CData/*0:0*/ tb_cmo_retirement__DOT__rst;
    CData/*0:0*/ tb_cmo_retirement__DOT__halt;
    CData/*0:0*/ tb_cmo_retirement__DOT__no_store;
    CData/*0:0*/ tb_cmo_retirement__DOT__ready;
    CData/*0:0*/ tb_cmo_retirement__DOT__done;
    CData/*0:0*/ tb_cmo_retirement__DOT__error;
    CData/*0:0*/ tb_cmo_retirement__DOT__active;
    CData/*0:0*/ tb_cmo_retirement__DOT__pop;
    CData/*1:0*/ tb_cmo_retirement__DOT__ack;
    CData/*0:0*/ tb_cmo_retirement__DOT__dut__DOT__cmo_head;
    CData/*0:0*/ tb_cmo_retirement__DOT__dut__DOT__cmo_busy_q;
    CData/*0:0*/ tb_cmo_retirement__DOT__dut__DOT__cmo_complete_q;
    CData/*0:0*/ tb_cmo_retirement__DOT__dut__DOT__cmo_error_q;
    CData/*0:0*/ tb_cmo_retirement__DOT__dut__DOT__cmo_offer_q;
    CData/*0:0*/ tb_cmo_retirement__DOT__dut__DOT__cmo_eligible;
    CData/*1:0*/ tb_cmo_retirement__DOT__dut__DOT__cmo_op_q;
    CData/*0:0*/ tb_cmo_retirement__DOT__dut__DOT__cmo_take;
    CData/*0:0*/ __VdfgRegularize_h6e95ff9d_0_3;
    CData/*0:0*/ __VdfgRegularize_h6e95ff9d_0_11;
    CData/*0:0*/ __VdfgRegularize_h6e95ff9d_0_12;
    CData/*0:0*/ __Vtrigprevexpr___TOP__tb_cmo_retirement__DOT__clk__0;
    CData/*0:0*/ __Vtrigprevexpr___TOP__tb_cmo_retirement__DOT__rst__0;
    CData/*0:0*/ __Vtrigprevexpr___TOP__tb_cmo_retirement__DOT__dut__DOT__cmo_offer_q__0;
    VlWide<7>/*203:0*/ __VdfgRegularize_h6e95ff9d_0_4;
    VlWide<7>/*201:0*/ __VdfgRegularize_h6e95ff9d_0_7;
    IData/*31:0*/ __Vi;
    VlWide<23>/*711:0*/ tb_cmo_retirement__DOT__entry;
    VlWide<7>/*203:0*/ tb_cmo_retirement__DOT__irq;
    VlWide<7>/*203:0*/ tb_cmo_retirement__DOT__fault;
    QData/*63:0*/ tb_cmo_retirement__DOT__source_va;
    QData/*51:0*/ tb_cmo_retirement__DOT__dut__DOT__cmo_line_q;
    QData/*63:0*/ tb_cmo_retirement__DOT__dut__DOT__cmo_pc_q;
    QData/*63:0*/ tb_cmo_retirement__DOT__dut__DOT__cmo_fault_vaddr_q;
    VlUnpacked<QData/*63:0*/, 1> __VstlTriggered;
    VlUnpacked<QData/*63:0*/, 1> __VicoTriggered;
    VlUnpacked<QData/*63:0*/, 1> __VactTriggered;
    VlUnpacked<QData/*63:0*/, 1> __VactTriggeredAcc;
    VlUnpacked<QData/*63:0*/, 1> __VnbaTriggered;
    VlDelayScheduler __VdlySched;
    VlTriggerScheduler __VtrigSched_hd76ea377__0;
    VlTriggerScheduler __VtrigSched_hd76ea2b8__0;
    VlTriggerScheduler __VtrigSched_h03c8db67__0;

    // INTERNAL VARIABLES
    Vtb_cmo_retirement__Syms* vlSymsp;
    const char* vlNamep;

    // CONSTRUCTORS
    Vtb_cmo_retirement___024root(Vtb_cmo_retirement__Syms* symsp, const char* namep);
    ~Vtb_cmo_retirement___024root();
    VL_UNCOPYABLE(Vtb_cmo_retirement___024root);

    // INTERNAL METHODS
};


#endif  // guard
