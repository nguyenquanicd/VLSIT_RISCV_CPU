// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vtb_cmo_ccu.h for the primary calling header

#include "Vtb_cmo_ccu__pch.h"

void Vtb_cmo_ccu___024root___timing_ready(Vtb_cmo_ccu___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_cmo_ccu___024root___timing_ready\n"); );
    Vtb_cmo_ccu__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if ((4ULL & vlSelfRef.__VactTriggered[0U])) {
        vlSelfRef.__VtrigSched_h73091968__0.ready("@(negedge tb_cmo_ccu.clk)");
    }
    if ((1ULL & vlSelfRef.__VactTriggered[0U])) {
        vlSelfRef.__VtrigSched_h730918a7__0.ready("@(posedge tb_cmo_ccu.clk)");
    }
    if ((8ULL & vlSelfRef.__VactTriggered[0U])) {
        vlSelfRef.__VtrigSched_h251dcf9f__0.ready("@( (tb_cmo_ccu.dut.reg_cmo_active & (5'h10 == (tb_cmo_ccu.dut.reg_fsm_ctx_current_state[tb_cmo_ccu.dut.reg_cmo_tag]))))");
    }
    if ((0x0000000000000010ULL & vlSelfRef.__VactTriggered[0U])) {
        vlSelfRef.__VtrigSched_hd1e4dd35__0.ready("@( (tb_cmo_ccu.dut.reg_cmo_active & ((5'he == (tb_cmo_ccu.dut.reg_fsm_ctx_current_state[tb_cmo_ccu.dut.reg_cmo_tag])) & tb_cmo_ccu.dut.w_release_hs[tb_cmo_ccu.dut.reg_cmo_tag+:1])))");
    }
}

void Vtb_cmo_ccu___024root___timing_resume(Vtb_cmo_ccu___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_cmo_ccu___024root___timing_resume\n"); );
    Vtb_cmo_ccu__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    vlSelfRef.__VtrigSched_h73091968__0.moveToResumeQueue(
                                                          "@(negedge tb_cmo_ccu.clk)");
    vlSelfRef.__VtrigSched_h730918a7__0.moveToResumeQueue(
                                                          "@(posedge tb_cmo_ccu.clk)");
    vlSelfRef.__VtrigSched_h251dcf9f__0.moveToResumeQueue(
                                                          "@( (tb_cmo_ccu.dut.reg_cmo_active & (5'h10 == (tb_cmo_ccu.dut.reg_fsm_ctx_current_state[tb_cmo_ccu.dut.reg_cmo_tag]))))");
    vlSelfRef.__VtrigSched_hd1e4dd35__0.moveToResumeQueue(
                                                          "@( (tb_cmo_ccu.dut.reg_cmo_active & ((5'he == (tb_cmo_ccu.dut.reg_fsm_ctx_current_state[tb_cmo_ccu.dut.reg_cmo_tag])) & tb_cmo_ccu.dut.w_release_hs[tb_cmo_ccu.dut.reg_cmo_tag+:1])))");
    vlSelfRef.__VtrigSched_h73091968__0.resume("@(negedge tb_cmo_ccu.clk)");
    vlSelfRef.__VtrigSched_h730918a7__0.resume("@(posedge tb_cmo_ccu.clk)");
    vlSelfRef.__VtrigSched_h251dcf9f__0.resume("@( (tb_cmo_ccu.dut.reg_cmo_active & (5'h10 == (tb_cmo_ccu.dut.reg_fsm_ctx_current_state[tb_cmo_ccu.dut.reg_cmo_tag]))))");
    vlSelfRef.__VtrigSched_hd1e4dd35__0.resume("@( (tb_cmo_ccu.dut.reg_cmo_active & ((5'he == (tb_cmo_ccu.dut.reg_fsm_ctx_current_state[tb_cmo_ccu.dut.reg_cmo_tag])) & tb_cmo_ccu.dut.w_release_hs[tb_cmo_ccu.dut.reg_cmo_tag+:1])))");
    if ((0x0000000000000020ULL & vlSelfRef.__VactTriggered[0U])) {
        vlSelfRef.__VdlySched.resume();
    }
}

void Vtb_cmo_ccu___024root___trigger_orInto__act_vec_vec(VlUnpacked<QData/*63:0*/, 1> &out, const VlUnpacked<QData/*63:0*/, 1> &in) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_cmo_ccu___024root___trigger_orInto__act_vec_vec\n"); );
    // Locals
    IData/*31:0*/ n;
    // Body
    n = 0U;
    do {
        out[n] = (out[n] | in[n]);
        n = ((IData)(1U) + n);
    } while ((0U >= n));
}

void Vtb_cmo_ccu___024root___trigger_clear__act(VlUnpacked<QData/*63:0*/, 1> &out) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_cmo_ccu___024root___trigger_clear__act\n"); );
    // Locals
    IData/*31:0*/ n;
    // Body
    n = 0U;
    do {
        out[n] = 0ULL;
        n = ((IData)(1U) + n);
    } while ((1U > n));
}

void Vtb_cmo_ccu___024root____VbeforeTrig_h73091968__0(Vtb_cmo_ccu___024root* vlSelf, const char* __VeventDescription) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_cmo_ccu___024root____VbeforeTrig_h73091968__0\n"); );
    Vtb_cmo_ccu__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    VlUnpacked<QData/*63:0*/, 1> __VTmp;
    // Body
    __VTmp[0U] = (QData)((IData)(((((~ (IData)(vlSelfRef.tb_cmo_ccu__DOT__clk)) 
                                    & (IData)(vlSelfRef.__Vtrigprevexpr___TOP__tb_cmo_ccu__DOT__clk__0)) 
                                   << 2U) | ((IData)(vlSelfRef.tb_cmo_ccu__DOT__clk) 
                                             & (~ (IData)(vlSelfRef.__Vtrigprevexpr___TOP__tb_cmo_ccu__DOT__clk__0))))));
    vlSelfRef.__Vtrigprevexpr___TOP__tb_cmo_ccu__DOT__clk__0 
        = vlSelfRef.tb_cmo_ccu__DOT__clk;
    if ((1ULL & __VTmp[0U])) {
        vlSelfRef.__VtrigSched_h730918a7__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h730918a7__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h730918a7__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h730918a7__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h730918a7__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h730918a7__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h730918a7__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h730918a7__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h730918a7__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h730918a7__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h730918a7__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h730918a7__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h730918a7__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h730918a7__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h730918a7__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h730918a7__0.ready(__VeventDescription);
    }
    if ((4ULL & __VTmp[0U])) {
        vlSelfRef.__VtrigSched_h73091968__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h73091968__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h73091968__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h73091968__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h73091968__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h73091968__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h73091968__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h73091968__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h73091968__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h73091968__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h73091968__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h73091968__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h73091968__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h73091968__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h73091968__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h73091968__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h73091968__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h73091968__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h73091968__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h73091968__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h73091968__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h73091968__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h73091968__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h73091968__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h73091968__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h73091968__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h73091968__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h73091968__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h73091968__0.ready(__VeventDescription);
    }
    vlSelfRef.__VactTriggeredAcc[0U] = (vlSelfRef.__VactTriggeredAcc[0U] 
                                        | __VTmp[0U]);
}

void Vtb_cmo_ccu___024root____VbeforeTrig_h730918a7__0(Vtb_cmo_ccu___024root* vlSelf, const char* __VeventDescription) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_cmo_ccu___024root____VbeforeTrig_h730918a7__0\n"); );
    Vtb_cmo_ccu__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    VlUnpacked<QData/*63:0*/, 1> __VTmp;
    // Body
    __VTmp[0U] = (QData)((IData)(((((~ (IData)(vlSelfRef.tb_cmo_ccu__DOT__clk)) 
                                    & (IData)(vlSelfRef.__Vtrigprevexpr___TOP__tb_cmo_ccu__DOT__clk__0)) 
                                   << 2U) | ((IData)(vlSelfRef.tb_cmo_ccu__DOT__clk) 
                                             & (~ (IData)(vlSelfRef.__Vtrigprevexpr___TOP__tb_cmo_ccu__DOT__clk__0))))));
    vlSelfRef.__Vtrigprevexpr___TOP__tb_cmo_ccu__DOT__clk__0 
        = vlSelfRef.tb_cmo_ccu__DOT__clk;
    if ((1ULL & __VTmp[0U])) {
        vlSelfRef.__VtrigSched_h730918a7__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h730918a7__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h730918a7__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h730918a7__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h730918a7__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h730918a7__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h730918a7__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h730918a7__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h730918a7__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h730918a7__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h730918a7__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h730918a7__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h730918a7__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h730918a7__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h730918a7__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h730918a7__0.ready(__VeventDescription);
    }
    if ((4ULL & __VTmp[0U])) {
        vlSelfRef.__VtrigSched_h73091968__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h73091968__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h73091968__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h73091968__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h73091968__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h73091968__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h73091968__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h73091968__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h73091968__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h73091968__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h73091968__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h73091968__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h73091968__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h73091968__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h73091968__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h73091968__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h73091968__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h73091968__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h73091968__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h73091968__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h73091968__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h73091968__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h73091968__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h73091968__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h73091968__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h73091968__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h73091968__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h73091968__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h73091968__0.ready(__VeventDescription);
    }
    vlSelfRef.__VactTriggeredAcc[0U] = (vlSelfRef.__VactTriggeredAcc[0U] 
                                        | __VTmp[0U]);
}

void Vtb_cmo_ccu___024root____VbeforeTrig_h251dcf9f__0(Vtb_cmo_ccu___024root* vlSelf, const char* __VeventDescription) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_cmo_ccu___024root____VbeforeTrig_h251dcf9f__0\n"); );
    Vtb_cmo_ccu__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    VlUnpacked<QData/*63:0*/, 1> __VTmp;
    CData/*0:0*/ __Vtrigprevexpr_hc129541c__0;
    __Vtrigprevexpr_hc129541c__0 = 0;
    // Body
    __Vtrigprevexpr_hc129541c__0 = ((IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__reg_cmo_active) 
                                    & (0x10U == vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__reg_fsm_ctx_current_state
                                       [vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__reg_cmo_tag]));
    __VTmp[0U] = (QData)((IData)((((IData)(__Vtrigprevexpr_hc129541c__0) 
                                   != (IData)(vlSelfRef.__Vtrigprevexpr_hc129541c__1)) 
                                  << 3U)));
    vlSelfRef.__Vtrigprevexpr_hc129541c__1 = __Vtrigprevexpr_hc129541c__0;
    if ((8ULL & __VTmp[0U])) {
        vlSelfRef.__VtrigSched_h251dcf9f__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h251dcf9f__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h251dcf9f__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h251dcf9f__0.ready(__VeventDescription);
    }
    vlSelfRef.__VactTriggeredAcc[0U] = (vlSelfRef.__VactTriggeredAcc[0U] 
                                        | __VTmp[0U]);
}

void Vtb_cmo_ccu___024root____VbeforeTrig_hd1e4dd35__0(Vtb_cmo_ccu___024root* vlSelf, const char* __VeventDescription) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_cmo_ccu___024root____VbeforeTrig_hd1e4dd35__0\n"); );
    Vtb_cmo_ccu__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    VlUnpacked<QData/*63:0*/, 1> __VTmp;
    CData/*0:0*/ __Vtrigprevexpr_h55d26132__0;
    __Vtrigprevexpr_h55d26132__0 = 0;
    // Body
    __Vtrigprevexpr_h55d26132__0 = ((IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__reg_cmo_active) 
                                    & ((0x0eU == vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__reg_fsm_ctx_current_state
                                        [vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__reg_cmo_tag]) 
                                       & ((IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__w_release_hs) 
                                          >> (IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__reg_cmo_tag))));
    __VTmp[0U] = (QData)((IData)((((IData)(__Vtrigprevexpr_h55d26132__0) 
                                   != (IData)(vlSelfRef.__Vtrigprevexpr_h55d26132__1)) 
                                  << 4U)));
    vlSelfRef.__Vtrigprevexpr_h55d26132__1 = __Vtrigprevexpr_h55d26132__0;
    if ((0x0000000000000010ULL & __VTmp[0U])) {
        vlSelfRef.__VtrigSched_hd1e4dd35__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hd1e4dd35__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hd1e4dd35__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hd1e4dd35__0.ready(__VeventDescription);
    }
    vlSelfRef.__VactTriggeredAcc[0U] = (vlSelfRef.__VactTriggeredAcc[0U] 
                                        | __VTmp[0U]);
}

#ifdef VL_DEBUG
void Vtb_cmo_ccu___024root___eval_debug_assertions(Vtb_cmo_ccu___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_cmo_ccu___024root___eval_debug_assertions\n"); );
    Vtb_cmo_ccu__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
}
#endif  // VL_DEBUG
