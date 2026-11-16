// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design internal header
// See Vtb_cmo_arbiter.h for the primary calling header

#ifndef VERILATED_VTB_CMO_ARBITER___024ROOT_H_
#define VERILATED_VTB_CMO_ARBITER___024ROOT_H_  // guard

#include "verilated.h"
#include "verilated_timing.h"


class Vtb_cmo_arbiter__Syms;

class alignas(VL_CACHE_LINE_BYTES) Vtb_cmo_arbiter___024root final {
  public:

    // DESIGN-SPECIFIC STATE
    CData/*0:0*/ tb_cmo_arbiter__DOT__clk;
    CData/*0:0*/ tb_cmo_arbiter__DOT__rst;
    CData/*3:0*/ tb_cmo_arbiter__DOT__valid;
    CData/*3:0*/ tb_cmo_arbiter__DOT__ready;
    CData/*3:0*/ tb_cmo_arbiter__DOT__done;
    CData/*3:0*/ tb_cmo_arbiter__DOT__err;
    CData/*0:0*/ tb_cmo_arbiter__DOT__cv;
    CData/*0:0*/ tb_cmo_arbiter__DOT__cr;
    CData/*0:0*/ tb_cmo_arbiter__DOT__cd;
    CData/*0:0*/ tb_cmo_arbiter__DOT__ce;
    CData/*0:0*/ tb_cmo_arbiter__DOT__dut__DOT__reg_cmd_valid;
    CData/*0:0*/ tb_cmo_arbiter__DOT__dut__DOT__reg_busy;
    CData/*1:0*/ tb_cmo_arbiter__DOT__dut__DOT__reg_rr_hart;
    CData/*1:0*/ tb_cmo_arbiter__DOT__dut__DOT__reg_cmd_hart;
    CData/*1:0*/ tb_cmo_arbiter__DOT__dut__DOT__w_pick_hart;
    CData/*0:0*/ tb_cmo_arbiter__DOT__dut__DOT__w_capture;
    CData/*0:0*/ tb_cmo_arbiter__DOT__dut__DOT__w_issue;
    CData/*0:0*/ tb_cmo_arbiter__DOT__dut__DOT__w_complete;
    CData/*0:0*/ __Vtrigprevexpr___TOP__tb_cmo_arbiter__DOT__clk__0;
    CData/*0:0*/ __Vtrigprevexpr___TOP__tb_cmo_arbiter__DOT__rst__0;
    IData/*31:0*/ __Vi;
    VlWide<7>/*207:0*/ tb_cmo_arbiter__DOT__pa;
    VlWide<8>/*255:0*/ tb_cmo_arbiter__DOT__va;
    VlWide<8>/*255:0*/ tb_cmo_arbiter__DOT__pc;
    QData/*51:0*/ tb_cmo_arbiter__DOT__dut__DOT__reg_cmd_pa_line;
    QData/*63:0*/ tb_cmo_arbiter__DOT__dut__DOT__reg_cmd_vaddr;
    QData/*63:0*/ tb_cmo_arbiter__DOT__dut__DOT__reg_cmd_pc;
    VlUnpacked<QData/*63:0*/, 1> __VstlTriggered;
    VlUnpacked<QData/*63:0*/, 1> __VicoTriggered;
    VlUnpacked<QData/*63:0*/, 1> __VactTriggered;
    VlUnpacked<QData/*63:0*/, 1> __VactTriggeredAcc;
    VlUnpacked<QData/*63:0*/, 1> __VnbaTriggered;
    VlDelayScheduler __VdlySched;
    VlTriggerScheduler __VtrigSched_ha124248b__0;
    VlTriggerScheduler __VtrigSched_ha12423cc__0;

    // INTERNAL VARIABLES
    Vtb_cmo_arbiter__Syms* vlSymsp;
    const char* vlNamep;

    // CONSTRUCTORS
    Vtb_cmo_arbiter___024root(Vtb_cmo_arbiter__Syms* symsp, const char* namep);
    ~Vtb_cmo_arbiter___024root();
    VL_UNCOPYABLE(Vtb_cmo_arbiter___024root);

    // INTERNAL METHODS
};


#endif  // guard
