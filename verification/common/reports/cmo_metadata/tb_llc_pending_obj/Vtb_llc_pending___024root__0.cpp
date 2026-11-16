// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vtb_llc_pending.h for the primary calling header

#include "Vtb_llc_pending__pch.h"

VlCoroutine Vtb_llc_pending___024root___eval_initial__TOP__Vtiming__0(Vtb_llc_pending___024root* vlSelf);
VlCoroutine Vtb_llc_pending___024root___eval_initial__TOP__Vtiming__1(Vtb_llc_pending___024root* vlSelf);
VlCoroutine Vtb_llc_pending___024root___eval_initial__TOP__Vtiming__2(Vtb_llc_pending___024root* vlSelf);

void Vtb_llc_pending___024root___eval_initial(Vtb_llc_pending___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_llc_pending___024root___eval_initial\n"); );
    Vtb_llc_pending__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    Vtb_llc_pending___024root___eval_initial__TOP__Vtiming__0(vlSelf);
    Vtb_llc_pending___024root___eval_initial__TOP__Vtiming__1(vlSelf);
    Vtb_llc_pending___024root___eval_initial__TOP__Vtiming__2(vlSelf);
}

void Vtb_llc_pending___024root___eval_sample(Vtb_llc_pending___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_llc_pending___024root___eval_sample\n"); );
    Vtb_llc_pending__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
}

#ifdef VL_DEBUG
VL_ATTR_COLD void Vtb_llc_pending___024root___dump_triggers__ico(const VlUnpacked<QData/*63:0*/, 1> &triggers, const std::string &tag);
#endif  // VL_DEBUG

bool Vtb_llc_pending___024root___eval_ico(Vtb_llc_pending___024root* vlSelf, CData/*0:0*/ firstIteration) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_llc_pending___024root___eval_ico\n"); );
    Vtb_llc_pending__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    vlSelfRef.__VicoTriggered[0U] = ((0xfffffffffffffffeULL 
                                      & vlSelfRef.__VicoTriggered[0U]) 
                                     | (IData)((IData)(firstIteration)));
#ifdef VL_DEBUG
    if (VL_UNLIKELY(vlSymsp->_vm_contextp__->debug())) {
        Vtb_llc_pending___024root___dump_triggers__ico(vlSelfRef.__VicoTriggered, "ico"s);
    }
#endif
    return (0U);
}

void Vtb_llc_pending___024root___timing_ready(Vtb_llc_pending___024root* vlSelf);
void Vtb_llc_pending___024root___trigger_orInto__act_vec_vec(VlUnpacked<QData/*63:0*/, 1> &out, const VlUnpacked<QData/*63:0*/, 1> &in);
#ifdef VL_DEBUG
VL_ATTR_COLD void Vtb_llc_pending___024root___dump_triggers__act(const VlUnpacked<QData/*63:0*/, 1> &triggers, const std::string &tag);
#endif  // VL_DEBUG
bool Vtb_llc_pending___024root___trigger_anySet__act(const VlUnpacked<QData/*63:0*/, 1> &in);
void Vtb_llc_pending___024root___timing_resume(Vtb_llc_pending___024root* vlSelf);
void Vtb_llc_pending___024root___act_comb__TOP__0(Vtb_llc_pending___024root* vlSelf);

bool Vtb_llc_pending___024root___eval_act(Vtb_llc_pending___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_llc_pending___024root___eval_act\n"); );
    Vtb_llc_pending__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    CData/*0:0*/ __VactExecute;
    // Body
    {
        // Inlined CFunc: _eval_triggers_vec__act
        CData/*0:0*/ __Vinline_0__eval_triggers_vec__act___Vtrigprevexpr_h88bb5eb1__0;
        __Vinline_0__eval_triggers_vec__act___Vtrigprevexpr_h88bb5eb1__0 = 0;
        __Vinline_0__eval_triggers_vec__act___Vtrigprevexpr_h88bb5eb1__0 
            = (0U == (IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__pending_valid_q));
        vlSelfRef.__VactTriggered[0U] = (QData)((IData)(
                                                        (((vlSelfRef.__VdlySched.awaitingCurrentTime() 
                                                           << 5U) 
                                                          | ((__Vinline_0__eval_triggers_vec__act___Vtrigprevexpr_h88bb5eb1__0 
                                                              != (IData)(vlSelfRef.__Vtrigprevexpr_h88bb5eb1__1)) 
                                                             << 4U)) 
                                                         | (((((IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_tag_pattern_gen__DOT__eoc_q) 
                                                               != (IData)(vlSelfRef.__Vtrigprevexpr___TOP__tb_llc_pending__DOT__dut__DOT__i_tag_pattern_gen__DOT__eoc_q__0)) 
                                                              << 3U) 
                                                             | (((~ (IData)(vlSelfRef.tb_llc_pending__DOT__clk)) 
                                                                 & (IData)(vlSelfRef.__Vtrigprevexpr___TOP__tb_llc_pending__DOT__clk__0)) 
                                                                << 2U)) 
                                                            | ((((~ (IData)(vlSelfRef.tb_llc_pending__DOT__rst)) 
                                                                 & (IData)(vlSelfRef.__Vtrigprevexpr___TOP__tb_llc_pending__DOT__rst__0)) 
                                                                << 1U) 
                                                               | ((IData)(vlSelfRef.tb_llc_pending__DOT__clk) 
                                                                  & (~ (IData)(vlSelfRef.__Vtrigprevexpr___TOP__tb_llc_pending__DOT__clk__0))))))));
        vlSelfRef.__Vtrigprevexpr___TOP__tb_llc_pending__DOT__clk__0 
            = vlSelfRef.tb_llc_pending__DOT__clk;
        vlSelfRef.__Vtrigprevexpr___TOP__tb_llc_pending__DOT__rst__0 
            = vlSelfRef.tb_llc_pending__DOT__rst;
        vlSelfRef.__Vtrigprevexpr___TOP__tb_llc_pending__DOT__dut__DOT__i_tag_pattern_gen__DOT__eoc_q__0 
            = vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_tag_pattern_gen__DOT__eoc_q;
        vlSelfRef.__Vtrigprevexpr_h88bb5eb1__1 = __Vinline_0__eval_triggers_vec__act___Vtrigprevexpr_h88bb5eb1__0;
    }
    Vtb_llc_pending___024root___timing_ready(vlSelf);
    Vtb_llc_pending___024root___trigger_orInto__act_vec_vec(vlSelfRef.__VactTriggered, vlSelfRef.__VactTriggeredAcc);
#ifdef VL_DEBUG
    if (VL_UNLIKELY(vlSymsp->_vm_contextp__->debug())) {
        Vtb_llc_pending___024root___dump_triggers__act(vlSelfRef.__VactTriggered, "act"s);
    }
#endif
    Vtb_llc_pending___024root___trigger_orInto__act_vec_vec(vlSelfRef.__VnbaTriggered, vlSelfRef.__VactTriggered);
    __VactExecute = Vtb_llc_pending___024root___trigger_anySet__act(vlSelfRef.__VactTriggered);
    if (__VactExecute) {
        vlSelfRef.__VactTriggeredAcc.fill(0ULL);
        Vtb_llc_pending___024root___timing_resume(vlSelf);
        {
            // Inlined CFunc: _eval_body__act
            if ((0x000000000000001dULL & vlSelfRef.__VactTriggered[0U])) {
                Vtb_llc_pending___024root___act_comb__TOP__0(vlSelf);
            }
        }
    }
    return (__VactExecute);
}

bool Vtb_llc_pending___024root___eval_inact(Vtb_llc_pending___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_llc_pending___024root___eval_inact\n"); );
    Vtb_llc_pending__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    CData/*0:0*/ __VinactExecute;
    // Body
    __VinactExecute = vlSelfRef.__VdlySched.awaitingZeroDelay();
    if (__VinactExecute) {
        VL_FATAL_MT("tb_llc_pending.sv", 2, "", "ZERODLY: Design Verilated with '--no-sched-zero-delay', but #0 delay executed at runtime");
    }
    return (__VinactExecute);
}

void Vtb_llc_pending___024root___nba_sequent__TOP__0(Vtb_llc_pending___024root* vlSelf);
void Vtb_llc_pending___024root___trigger_clear__act(VlUnpacked<QData/*63:0*/, 1> &out);

bool Vtb_llc_pending___024root___eval_nba(Vtb_llc_pending___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_llc_pending___024root___eval_nba\n"); );
    Vtb_llc_pending__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    CData/*0:0*/ __VnbaExecute;
    // Body
    __VnbaExecute = Vtb_llc_pending___024root___trigger_anySet__act(vlSelfRef.__VnbaTriggered);
    if (__VnbaExecute) {
        {
            // Inlined CFunc: _eval_body__nba
            if ((3ULL & vlSelfRef.__VnbaTriggered[0U])) {
                Vtb_llc_pending___024root___nba_sequent__TOP__0(vlSelf);
            }
            if ((0x000000000000001fULL & vlSelfRef.__VnbaTriggered[0U])) {
                Vtb_llc_pending___024root___act_comb__TOP__0(vlSelf);
            }
        }
        Vtb_llc_pending___024root___trigger_clear__act(vlSelfRef.__VnbaTriggered);
    }
    return (__VnbaExecute);
}

bool Vtb_llc_pending___024root___eval_obs(Vtb_llc_pending___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_llc_pending___024root___eval_obs\n"); );
    Vtb_llc_pending__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    return (0U);
}

bool Vtb_llc_pending___024root___eval_react(Vtb_llc_pending___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_llc_pending___024root___eval_react\n"); );
    Vtb_llc_pending__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    return (0U);
}

void Vtb_llc_pending___024root___eval_postponed(Vtb_llc_pending___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_llc_pending___024root___eval_postponed\n"); );
    Vtb_llc_pending__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
}

void Vtb_llc_pending___024root____VbeforeTrig_h3cf2b702__0(Vtb_llc_pending___024root* vlSelf, const char* __VeventDescription);
void Vtb_llc_pending___024root____VbeforeTrig_h3cf2b645__0(Vtb_llc_pending___024root* vlSelf, const char* __VeventDescription);
void Vtb_llc_pending___024root____VbeforeTrig_h84e4166d__0(Vtb_llc_pending___024root* vlSelf, const char* __VeventDescription);
void Vtb_llc_pending___024root____VbeforeTrig_hdc8bdab8__0(Vtb_llc_pending___024root* vlSelf, const char* __VeventDescription);

VlCoroutine Vtb_llc_pending___024root___eval_initial__TOP__Vtiming__0(Vtb_llc_pending___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_llc_pending___024root___eval_initial__TOP__Vtiming__0\n"); );
    Vtb_llc_pending__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    IData/*31:0*/ tb_llc_pending__DOT__unnamedblk1_1__DOT____Vrepeat0;
    tb_llc_pending__DOT__unnamedblk1_1__DOT____Vrepeat0 = 0;
    IData/*31:0*/ tb_llc_pending__DOT__unnamedblk1__DOT__k;
    tb_llc_pending__DOT__unnamedblk1__DOT__k = 0;
    IData/*31:0*/ tb_llc_pending__DOT__unnamedblk2__DOT__round_idx;
    tb_llc_pending__DOT__unnamedblk2__DOT__round_idx = 0;
    IData/*31:0*/ tb_llc_pending__DOT__unnamedblk2__DOT__unnamedblk1_2__DOT____Vrepeat1;
    tb_llc_pending__DOT__unnamedblk2__DOT__unnamedblk1_2__DOT____Vrepeat1 = 0;
    IData/*31:0*/ tb_llc_pending__DOT__unnamedblk2__DOT__unnamedblk5__DOT__unnamedblk1_3__DOT____Vrepeat2;
    tb_llc_pending__DOT__unnamedblk2__DOT__unnamedblk5__DOT__unnamedblk1_3__DOT____Vrepeat2 = 0;
    CData/*1:0*/ __Vtask_tb_llc_pending__DOT__send__0__mode;
    __Vtask_tb_llc_pending__DOT__send__0__mode = 0;
    IData/*31:0*/ __Vtask_tb_llc_pending__DOT__send__0__idx;
    __Vtask_tb_llc_pending__DOT__send__0__idx = 0;
    IData/*31:0*/ __Vtask_tb_llc_pending__DOT__send__0__tag_value;
    __Vtask_tb_llc_pending__DOT__send__0__tag_value = 0;
    CData/*0:0*/ __Vtask_tb_llc_pending__DOT__send__0__dirty;
    __Vtask_tb_llc_pending__DOT__send__0__dirty = 0;
    CData/*1:0*/ __Vtask_tb_llc_pending__DOT__send__1__mode;
    __Vtask_tb_llc_pending__DOT__send__1__mode = 0;
    IData/*31:0*/ __Vtask_tb_llc_pending__DOT__send__1__idx;
    __Vtask_tb_llc_pending__DOT__send__1__idx = 0;
    IData/*31:0*/ __Vtask_tb_llc_pending__DOT__send__1__tag_value;
    __Vtask_tb_llc_pending__DOT__send__1__tag_value = 0;
    CData/*0:0*/ __Vtask_tb_llc_pending__DOT__send__1__dirty;
    __Vtask_tb_llc_pending__DOT__send__1__dirty = 0;
    CData/*0:0*/ __Vtask_tb_llc_pending__DOT__receive__2__eh;
    __Vtask_tb_llc_pending__DOT__receive__2__eh = 0;
    CData/*0:0*/ __Vtask_tb_llc_pending__DOT__receive__2__ee;
    __Vtask_tb_llc_pending__DOT__receive__2__ee = 0;
    CData/*1:0*/ __Vtask_tb_llc_pending__DOT__send__3__mode;
    __Vtask_tb_llc_pending__DOT__send__3__mode = 0;
    IData/*31:0*/ __Vtask_tb_llc_pending__DOT__send__3__idx;
    __Vtask_tb_llc_pending__DOT__send__3__idx = 0;
    IData/*31:0*/ __Vtask_tb_llc_pending__DOT__send__3__tag_value;
    __Vtask_tb_llc_pending__DOT__send__3__tag_value = 0;
    CData/*0:0*/ __Vtask_tb_llc_pending__DOT__send__3__dirty;
    __Vtask_tb_llc_pending__DOT__send__3__dirty = 0;
    CData/*0:0*/ __Vtask_tb_llc_pending__DOT__receive__4__eh;
    __Vtask_tb_llc_pending__DOT__receive__4__eh = 0;
    CData/*0:0*/ __Vtask_tb_llc_pending__DOT__receive__4__ee;
    __Vtask_tb_llc_pending__DOT__receive__4__ee = 0;
    CData/*1:0*/ __Vtask_tb_llc_pending__DOT__send__5__mode;
    __Vtask_tb_llc_pending__DOT__send__5__mode = 0;
    IData/*31:0*/ __Vtask_tb_llc_pending__DOT__send__5__idx;
    __Vtask_tb_llc_pending__DOT__send__5__idx = 0;
    IData/*31:0*/ __Vtask_tb_llc_pending__DOT__send__5__tag_value;
    __Vtask_tb_llc_pending__DOT__send__5__tag_value = 0;
    CData/*0:0*/ __Vtask_tb_llc_pending__DOT__send__5__dirty;
    __Vtask_tb_llc_pending__DOT__send__5__dirty = 0;
    CData/*0:0*/ __Vtask_tb_llc_pending__DOT__receive__6__eh;
    __Vtask_tb_llc_pending__DOT__receive__6__eh = 0;
    CData/*0:0*/ __Vtask_tb_llc_pending__DOT__receive__6__ee;
    __Vtask_tb_llc_pending__DOT__receive__6__ee = 0;
    CData/*1:0*/ __Vtask_tb_llc_pending__DOT__send__7__mode;
    __Vtask_tb_llc_pending__DOT__send__7__mode = 0;
    IData/*31:0*/ __Vtask_tb_llc_pending__DOT__send__7__idx;
    __Vtask_tb_llc_pending__DOT__send__7__idx = 0;
    IData/*31:0*/ __Vtask_tb_llc_pending__DOT__send__7__tag_value;
    __Vtask_tb_llc_pending__DOT__send__7__tag_value = 0;
    CData/*0:0*/ __Vtask_tb_llc_pending__DOT__send__7__dirty;
    __Vtask_tb_llc_pending__DOT__send__7__dirty = 0;
    CData/*0:0*/ __Vtask_tb_llc_pending__DOT__receive__9__eh;
    __Vtask_tb_llc_pending__DOT__receive__9__eh = 0;
    CData/*0:0*/ __Vtask_tb_llc_pending__DOT__receive__9__ee;
    __Vtask_tb_llc_pending__DOT__receive__9__ee = 0;
    CData/*1:0*/ __Vtask_tb_llc_pending__DOT__send__11__mode;
    __Vtask_tb_llc_pending__DOT__send__11__mode = 0;
    IData/*31:0*/ __Vtask_tb_llc_pending__DOT__send__11__idx;
    __Vtask_tb_llc_pending__DOT__send__11__idx = 0;
    IData/*31:0*/ __Vtask_tb_llc_pending__DOT__send__11__tag_value;
    __Vtask_tb_llc_pending__DOT__send__11__tag_value = 0;
    CData/*0:0*/ __Vtask_tb_llc_pending__DOT__send__11__dirty;
    __Vtask_tb_llc_pending__DOT__send__11__dirty = 0;
    CData/*0:0*/ __Vtask_tb_llc_pending__DOT__receive__12__eh;
    __Vtask_tb_llc_pending__DOT__receive__12__eh = 0;
    CData/*0:0*/ __Vtask_tb_llc_pending__DOT__receive__12__ee;
    __Vtask_tb_llc_pending__DOT__receive__12__ee = 0;
    // Body
    vlSelfRef.tb_llc_pending__DOT__req[0U] = 0U;
    vlSelfRef.tb_llc_pending__DOT__req[1U] = 0U;
    vlSelfRef.tb_llc_pending__DOT__req[2U] = 0U;
    tb_llc_pending__DOT__unnamedblk1_1__DOT____Vrepeat0 = 2U;
    while (VL_LTS_III(32, 0U, tb_llc_pending__DOT__unnamedblk1_1__DOT____Vrepeat0)) {
        Vtb_llc_pending___024root____VbeforeTrig_h3cf2b702__0(vlSelf, 
                                                              "@(negedge tb_llc_pending.clk)");
        co_await vlSelfRef.__VtrigSched_h3cf2b702__0.trigger(0U, 
                                                             nullptr, 
                                                             "@(negedge tb_llc_pending.clk)", 
                                                             "tb_llc_pending.sv", 
                                                             51);
        tb_llc_pending__DOT__unnamedblk1_1__DOT____Vrepeat0 
            = (tb_llc_pending__DOT__unnamedblk1_1__DOT____Vrepeat0 
               - (IData)(1U));
    }
    vlSelfRef.tb_llc_pending__DOT__rst = 1U;
    __Vtask_tb_llc_pending__DOT__send__0__dirty = 0U;
    __Vtask_tb_llc_pending__DOT__send__0__tag_value = 0U;
    __Vtask_tb_llc_pending__DOT__send__0__idx = 0U;
    __Vtask_tb_llc_pending__DOT__send__0__mode = 0U;
    Vtb_llc_pending___024root____VbeforeTrig_h3cf2b702__0(vlSelf, 
                                                          "@(negedge tb_llc_pending.clk)");
    co_await vlSelfRef.__VtrigSched_h3cf2b702__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(negedge tb_llc_pending.clk)", 
                                                         "tb_llc_pending.sv", 
                                                         35);
    vlSelfRef.tb_llc_pending__DOT__req[0U] = (IData)(
                                                     (((QData)((IData)(
                                                                       (8U 
                                                                        | (7U 
                                                                           & __Vtask_tb_llc_pending__DOT__send__0__idx)))) 
                                                       << 0x0000003cU) 
                                                      | ((0x0ffffffffffffff8ULL 
                                                          & (VL_EXTENDS_QI(57,32, __Vtask_tb_llc_pending__DOT__send__0__tag_value) 
                                                             << 3U)) 
                                                         | (QData)((IData)(
                                                                           ((IData)(__Vtask_tb_llc_pending__DOT__send__0__dirty) 
                                                                            << 2U))))));
    vlSelfRef.tb_llc_pending__DOT__req[1U] = (IData)(
                                                     ((((QData)((IData)(
                                                                        (8U 
                                                                         | (7U 
                                                                            & __Vtask_tb_llc_pending__DOT__send__0__idx)))) 
                                                        << 0x0000003cU) 
                                                       | ((0x0ffffffffffffff8ULL 
                                                           & (VL_EXTENDS_QI(57,32, __Vtask_tb_llc_pending__DOT__send__0__tag_value) 
                                                              << 3U)) 
                                                          | (QData)((IData)(
                                                                            ((IData)(__Vtask_tb_llc_pending__DOT__send__0__dirty) 
                                                                             << 2U))))) 
                                                      >> 0x00000020U));
    vlSelfRef.tb_llc_pending__DOT__req[2U] = (3U & (IData)(__Vtask_tb_llc_pending__DOT__send__0__mode));
    vlSelfRef.tb_llc_pending__DOT__iv = 1U;
    do {
        Vtb_llc_pending___024root____VbeforeTrig_h3cf2b645__0(vlSelf, 
                                                              "@(posedge tb_llc_pending.clk)");
        co_await vlSelfRef.__VtrigSched_h3cf2b645__0.trigger(0U, 
                                                             nullptr, 
                                                             "@(posedge tb_llc_pending.clk)", 
                                                             "tb_llc_pending.sv", 
                                                             37);
    } while ((1U & (~ (IData)(vlSelfRef.tb_llc_pending__DOT__ir))));
    Vtb_llc_pending___024root____VbeforeTrig_h3cf2b702__0(vlSelf, 
                                                          "@(negedge tb_llc_pending.clk)");
    co_await vlSelfRef.__VtrigSched_h3cf2b702__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(negedge tb_llc_pending.clk)", 
                                                         "tb_llc_pending.sv", 
                                                         38);
    vlSelfRef.tb_llc_pending__DOT__iv = 0U;
    while ((1U & (~ (IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_tag_pattern_gen__DOT__eoc_q)))) {
        Vtb_llc_pending___024root____VbeforeTrig_h84e4166d__0(vlSelf, 
                                                              "@( tb_llc_pending.dut.i_tag_pattern_gen.eoc_q)");
        co_await vlSelfRef.__VtrigSched_h84e4166d__0.trigger(1U, 
                                                             nullptr, 
                                                             "@( tb_llc_pending.dut.i_tag_pattern_gen.eoc_q)", 
                                                             "tb_llc_pending.sv", 
                                                             52);
    }
    Vtb_llc_pending___024root____VbeforeTrig_h3cf2b702__0(vlSelf, 
                                                          "@(negedge tb_llc_pending.clk)");
    co_await vlSelfRef.__VtrigSched_h3cf2b702__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(negedge tb_llc_pending.clk)", 
                                                         "tb_llc_pending.sv", 
                                                         52);
    tb_llc_pending__DOT__unnamedblk1__DOT__k = 0U;
    while (VL_GTS_III(32, 8U, tb_llc_pending__DOT__unnamedblk1__DOT__k)) {
        __Vtask_tb_llc_pending__DOT__send__1__dirty = 1U;
        __Vtask_tb_llc_pending__DOT__send__1__tag_value 
            = ((IData)(0x00000010U) + tb_llc_pending__DOT__unnamedblk1__DOT__k);
        __Vtask_tb_llc_pending__DOT__send__1__idx = tb_llc_pending__DOT__unnamedblk1__DOT__k;
        __Vtask_tb_llc_pending__DOT__send__1__mode = 2U;
        Vtb_llc_pending___024root____VbeforeTrig_h3cf2b702__0(vlSelf, 
                                                              "@(negedge tb_llc_pending.clk)");
        co_await vlSelfRef.__VtrigSched_h3cf2b702__0.trigger(0U, 
                                                             nullptr, 
                                                             "@(negedge tb_llc_pending.clk)", 
                                                             "tb_llc_pending.sv", 
                                                             35);
        vlSelfRef.tb_llc_pending__DOT__req[0U] = (IData)(
                                                         (((QData)((IData)(
                                                                           (8U 
                                                                            | (7U 
                                                                               & __Vtask_tb_llc_pending__DOT__send__1__idx)))) 
                                                           << 0x0000003cU) 
                                                          | ((0x0ffffffffffffff8ULL 
                                                              & (VL_EXTENDS_QI(57,32, __Vtask_tb_llc_pending__DOT__send__1__tag_value) 
                                                                 << 3U)) 
                                                             | (QData)((IData)(
                                                                               ((IData)(__Vtask_tb_llc_pending__DOT__send__1__dirty) 
                                                                                << 2U))))));
        vlSelfRef.tb_llc_pending__DOT__req[1U] = (IData)(
                                                         ((((QData)((IData)(
                                                                            (8U 
                                                                             | (7U 
                                                                                & __Vtask_tb_llc_pending__DOT__send__1__idx)))) 
                                                            << 0x0000003cU) 
                                                           | ((0x0ffffffffffffff8ULL 
                                                               & (VL_EXTENDS_QI(57,32, __Vtask_tb_llc_pending__DOT__send__1__tag_value) 
                                                                  << 3U)) 
                                                              | (QData)((IData)(
                                                                                ((IData)(__Vtask_tb_llc_pending__DOT__send__1__dirty) 
                                                                                << 2U))))) 
                                                          >> 0x00000020U));
        vlSelfRef.tb_llc_pending__DOT__req[2U] = (3U 
                                                  & (IData)(__Vtask_tb_llc_pending__DOT__send__1__mode));
        vlSelfRef.tb_llc_pending__DOT__iv = 1U;
        do {
            Vtb_llc_pending___024root____VbeforeTrig_h3cf2b645__0(vlSelf, 
                                                                  "@(posedge tb_llc_pending.clk)");
            co_await vlSelfRef.__VtrigSched_h3cf2b645__0.trigger(0U, 
                                                                 nullptr, 
                                                                 "@(posedge tb_llc_pending.clk)", 
                                                                 "tb_llc_pending.sv", 
                                                                 37);
        } while ((1U & (~ (IData)(vlSelfRef.tb_llc_pending__DOT__ir))));
        Vtb_llc_pending___024root____VbeforeTrig_h3cf2b702__0(vlSelf, 
                                                              "@(negedge tb_llc_pending.clk)");
        co_await vlSelfRef.__VtrigSched_h3cf2b702__0.trigger(0U, 
                                                             nullptr, 
                                                             "@(negedge tb_llc_pending.clk)", 
                                                             "tb_llc_pending.sv", 
                                                             38);
        vlSelfRef.tb_llc_pending__DOT__iv = 0U;
        __Vtask_tb_llc_pending__DOT__receive__2__ee = 0U;
        __Vtask_tb_llc_pending__DOT__receive__2__eh = 0U;
        while ((1U & (~ ((IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__a_full_q) 
                         | (IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__b_full_q))))) {
            Vtb_llc_pending___024root____VbeforeTrig_h3cf2b702__0(vlSelf, 
                                                                  "@(negedge tb_llc_pending.clk)");
            co_await vlSelfRef.__VtrigSched_h3cf2b702__0.trigger(0U, 
                                                                 nullptr, 
                                                                 "@(negedge tb_llc_pending.clk)", 
                                                                 "tb_llc_pending.sv", 
                                                                 41);
        }
        if (VL_UNLIKELY(((((1U & (IData)((((IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__b_full_q)
                                            ? vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__b_data_q
                                            : vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__a_data_q) 
                                          >> 0x0000003aU))) 
                           != (IData)(__Vtask_tb_llc_pending__DOT__receive__2__eh)) 
                          | ((1U & (IData)((((IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__b_full_q)
                                              ? vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__b_data_q
                                              : vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__a_data_q) 
                                            >> 0x00000039U))) 
                             != (IData)(__Vtask_tb_llc_pending__DOT__receive__2__ee)))))) {
            VL_WRITEF_NX("[%0t] %%Fatal: tb_llc_pending.sv:42: Assertion failed in %m: tag response mismatch\n",3, 'M',vlSymsp->name(),"tb_llc_pending.receive", 'T',-9
                         , '#',64,VL_TIME_UNITED_Q(1000));
            VL_STOP_MT("tb_llc_pending.sv", 42, "", false);
        }
        vlSelfRef.tb_llc_pending__DOT__orr = 1U;
        Vtb_llc_pending___024root____VbeforeTrig_h3cf2b645__0(vlSelf, 
                                                              "@(posedge tb_llc_pending.clk)");
        co_await vlSelfRef.__VtrigSched_h3cf2b645__0.trigger(0U, 
                                                             nullptr, 
                                                             "@(posedge tb_llc_pending.clk)", 
                                                             "tb_llc_pending.sv", 
                                                             43);
        Vtb_llc_pending___024root____VbeforeTrig_h3cf2b702__0(vlSelf, 
                                                              "@(negedge tb_llc_pending.clk)");
        co_await vlSelfRef.__VtrigSched_h3cf2b702__0.trigger(0U, 
                                                             nullptr, 
                                                             "@(negedge tb_llc_pending.clk)", 
                                                             "tb_llc_pending.sv", 
                                                             43);
        vlSelfRef.tb_llc_pending__DOT__orr = 0U;
        tb_llc_pending__DOT__unnamedblk1__DOT__k = 
            ((IData)(1U) + tb_llc_pending__DOT__unnamedblk1__DOT__k);
    }
    tb_llc_pending__DOT__unnamedblk2__DOT__round_idx = 0U;
    while (VL_GTS_III(32, 3U, tb_llc_pending__DOT__unnamedblk2__DOT__round_idx)) {
        if ((0U != tb_llc_pending__DOT__unnamedblk2__DOT__round_idx)) {
            vlSelfRef.tb_llc_pending__DOT__unnamedblk2__DOT__unnamedblk3__DOT__k = 0U;
            while (VL_GTS_III(32, 5U, vlSelfRef.tb_llc_pending__DOT__unnamedblk2__DOT__unnamedblk3__DOT__k)) {
                __Vtask_tb_llc_pending__DOT__send__3__dirty = 1U;
                __Vtask_tb_llc_pending__DOT__send__3__tag_value 
                    = ((IData)(0x00000020U) + (VL_MULS_III(32, (IData)(0x00000010U), tb_llc_pending__DOT__unnamedblk2__DOT__round_idx) 
                                               + vlSelfRef.tb_llc_pending__DOT__unnamedblk2__DOT__unnamedblk3__DOT__k));
                __Vtask_tb_llc_pending__DOT__send__3__idx 
                    = vlSelfRef.tb_llc_pending__DOT__unnamedblk2__DOT__unnamedblk3__DOT__k;
                __Vtask_tb_llc_pending__DOT__send__3__mode = 2U;
                Vtb_llc_pending___024root____VbeforeTrig_h3cf2b702__0(vlSelf, 
                                                                      "@(negedge tb_llc_pending.clk)");
                co_await vlSelfRef.__VtrigSched_h3cf2b702__0.trigger(0U, 
                                                                     nullptr, 
                                                                     "@(negedge tb_llc_pending.clk)", 
                                                                     "tb_llc_pending.sv", 
                                                                     35);
                vlSelfRef.tb_llc_pending__DOT__req[0U] 
                    = (IData)((((QData)((IData)((8U 
                                                 | (7U 
                                                    & __Vtask_tb_llc_pending__DOT__send__3__idx)))) 
                                << 0x0000003cU) | (
                                                   (0x0ffffffffffffff8ULL 
                                                    & (VL_EXTENDS_QI(57,32, __Vtask_tb_llc_pending__DOT__send__3__tag_value) 
                                                       << 3U)) 
                                                   | (QData)((IData)(
                                                                     ((IData)(__Vtask_tb_llc_pending__DOT__send__3__dirty) 
                                                                      << 2U))))));
                vlSelfRef.tb_llc_pending__DOT__req[1U] 
                    = (IData)(((((QData)((IData)((8U 
                                                  | (7U 
                                                     & __Vtask_tb_llc_pending__DOT__send__3__idx)))) 
                                 << 0x0000003cU) | 
                                ((0x0ffffffffffffff8ULL 
                                  & (VL_EXTENDS_QI(57,32, __Vtask_tb_llc_pending__DOT__send__3__tag_value) 
                                     << 3U)) | (QData)((IData)(
                                                               ((IData)(__Vtask_tb_llc_pending__DOT__send__3__dirty) 
                                                                << 2U))))) 
                               >> 0x00000020U));
                vlSelfRef.tb_llc_pending__DOT__req[2U] 
                    = (3U & (IData)(__Vtask_tb_llc_pending__DOT__send__3__mode));
                vlSelfRef.tb_llc_pending__DOT__iv = 1U;
                do {
                    Vtb_llc_pending___024root____VbeforeTrig_h3cf2b645__0(vlSelf, 
                                                                          "@(posedge tb_llc_pending.clk)");
                    co_await vlSelfRef.__VtrigSched_h3cf2b645__0.trigger(0U, 
                                                                         nullptr, 
                                                                         "@(posedge tb_llc_pending.clk)", 
                                                                         "tb_llc_pending.sv", 
                                                                         37);
                } while ((1U & (~ (IData)(vlSelfRef.tb_llc_pending__DOT__ir))));
                Vtb_llc_pending___024root____VbeforeTrig_h3cf2b702__0(vlSelf, 
                                                                      "@(negedge tb_llc_pending.clk)");
                co_await vlSelfRef.__VtrigSched_h3cf2b702__0.trigger(0U, 
                                                                     nullptr, 
                                                                     "@(negedge tb_llc_pending.clk)", 
                                                                     "tb_llc_pending.sv", 
                                                                     38);
                vlSelfRef.tb_llc_pending__DOT__iv = 0U;
                __Vtask_tb_llc_pending__DOT__receive__4__ee = 0U;
                __Vtask_tb_llc_pending__DOT__receive__4__eh = 1U;
                while ((1U & (~ ((IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__a_full_q) 
                                 | (IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__b_full_q))))) {
                    Vtb_llc_pending___024root____VbeforeTrig_h3cf2b702__0(vlSelf, 
                                                                          "@(negedge tb_llc_pending.clk)");
                    co_await vlSelfRef.__VtrigSched_h3cf2b702__0.trigger(0U, 
                                                                         nullptr, 
                                                                         "@(negedge tb_llc_pending.clk)", 
                                                                         "tb_llc_pending.sv", 
                                                                         41);
                }
                if (VL_UNLIKELY(((((1U & (IData)((((IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__b_full_q)
                                                    ? vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__b_data_q
                                                    : vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__a_data_q) 
                                                  >> 0x0000003aU))) 
                                   != (IData)(__Vtask_tb_llc_pending__DOT__receive__4__eh)) 
                                  | ((1U & (IData)(
                                                   (((IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__b_full_q)
                                                      ? vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__b_data_q
                                                      : vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__a_data_q) 
                                                    >> 0x00000039U))) 
                                     != (IData)(__Vtask_tb_llc_pending__DOT__receive__4__ee)))))) {
                    VL_WRITEF_NX("[%0t] %%Fatal: tb_llc_pending.sv:42: Assertion failed in %m: tag response mismatch\n",3, 'M',vlSymsp->name(),"tb_llc_pending.receive", 'T',-9
                                 , '#',64,VL_TIME_UNITED_Q(1000));
                    VL_STOP_MT("tb_llc_pending.sv", 42, "", false);
                }
                vlSelfRef.tb_llc_pending__DOT__orr = 1U;
                Vtb_llc_pending___024root____VbeforeTrig_h3cf2b645__0(vlSelf, 
                                                                      "@(posedge tb_llc_pending.clk)");
                co_await vlSelfRef.__VtrigSched_h3cf2b645__0.trigger(0U, 
                                                                     nullptr, 
                                                                     "@(posedge tb_llc_pending.clk)", 
                                                                     "tb_llc_pending.sv", 
                                                                     43);
                Vtb_llc_pending___024root____VbeforeTrig_h3cf2b702__0(vlSelf, 
                                                                      "@(negedge tb_llc_pending.clk)");
                co_await vlSelfRef.__VtrigSched_h3cf2b702__0.trigger(0U, 
                                                                     nullptr, 
                                                                     "@(negedge tb_llc_pending.clk)", 
                                                                     "tb_llc_pending.sv", 
                                                                     43);
                vlSelfRef.tb_llc_pending__DOT__orr = 0U;
                vlSelfRef.tb_llc_pending__DOT__unnamedblk2__DOT__unnamedblk3__DOT__k 
                    = ((IData)(1U) + vlSelfRef.tb_llc_pending__DOT__unnamedblk2__DOT__unnamedblk3__DOT__k);
            }
        }
        vlSelfRef.tb_llc_pending__DOT__unnamedblk2__DOT__unnamedblk4__DOT__k = 0U;
        while (VL_GTS_III(32, 4U, vlSelfRef.tb_llc_pending__DOT__unnamedblk2__DOT__unnamedblk4__DOT__k)) {
            __Vtask_tb_llc_pending__DOT__send__5__dirty = 0U;
            __Vtask_tb_llc_pending__DOT__send__5__tag_value 
                = ((IData)(0x00000030U) + (VL_MULS_III(32, (IData)(0x00000010U), tb_llc_pending__DOT__unnamedblk2__DOT__round_idx) 
                                           + vlSelfRef.tb_llc_pending__DOT__unnamedblk2__DOT__unnamedblk4__DOT__k));
            __Vtask_tb_llc_pending__DOT__send__5__idx 
                = vlSelfRef.tb_llc_pending__DOT__unnamedblk2__DOT__unnamedblk4__DOT__k;
            __Vtask_tb_llc_pending__DOT__send__5__mode = 2U;
            Vtb_llc_pending___024root____VbeforeTrig_h3cf2b702__0(vlSelf, 
                                                                  "@(negedge tb_llc_pending.clk)");
            co_await vlSelfRef.__VtrigSched_h3cf2b702__0.trigger(0U, 
                                                                 nullptr, 
                                                                 "@(negedge tb_llc_pending.clk)", 
                                                                 "tb_llc_pending.sv", 
                                                                 35);
            vlSelfRef.tb_llc_pending__DOT__req[0U] 
                = (IData)((((QData)((IData)((8U | (7U 
                                                   & __Vtask_tb_llc_pending__DOT__send__5__idx)))) 
                            << 0x0000003cU) | ((0x0ffffffffffffff8ULL 
                                                & (VL_EXTENDS_QI(57,32, __Vtask_tb_llc_pending__DOT__send__5__tag_value) 
                                                   << 3U)) 
                                               | (QData)((IData)(
                                                                 ((IData)(__Vtask_tb_llc_pending__DOT__send__5__dirty) 
                                                                  << 2U))))));
            vlSelfRef.tb_llc_pending__DOT__req[1U] 
                = (IData)(((((QData)((IData)((8U | 
                                              (7U & __Vtask_tb_llc_pending__DOT__send__5__idx)))) 
                             << 0x0000003cU) | ((0x0ffffffffffffff8ULL 
                                                 & (VL_EXTENDS_QI(57,32, __Vtask_tb_llc_pending__DOT__send__5__tag_value) 
                                                    << 3U)) 
                                                | (QData)((IData)(
                                                                  ((IData)(__Vtask_tb_llc_pending__DOT__send__5__dirty) 
                                                                   << 2U))))) 
                           >> 0x00000020U));
            vlSelfRef.tb_llc_pending__DOT__req[2U] 
                = (3U & (IData)(__Vtask_tb_llc_pending__DOT__send__5__mode));
            vlSelfRef.tb_llc_pending__DOT__iv = 1U;
            do {
                Vtb_llc_pending___024root____VbeforeTrig_h3cf2b645__0(vlSelf, 
                                                                      "@(posedge tb_llc_pending.clk)");
                co_await vlSelfRef.__VtrigSched_h3cf2b645__0.trigger(0U, 
                                                                     nullptr, 
                                                                     "@(posedge tb_llc_pending.clk)", 
                                                                     "tb_llc_pending.sv", 
                                                                     37);
            } while ((1U & (~ (IData)(vlSelfRef.tb_llc_pending__DOT__ir))));
            Vtb_llc_pending___024root____VbeforeTrig_h3cf2b702__0(vlSelf, 
                                                                  "@(negedge tb_llc_pending.clk)");
            co_await vlSelfRef.__VtrigSched_h3cf2b702__0.trigger(0U, 
                                                                 nullptr, 
                                                                 "@(negedge tb_llc_pending.clk)", 
                                                                 "tb_llc_pending.sv", 
                                                                 38);
            vlSelfRef.tb_llc_pending__DOT__iv = 0U;
            __Vtask_tb_llc_pending__DOT__receive__6__ee = 1U;
            __Vtask_tb_llc_pending__DOT__receive__6__eh = 0U;
            while ((1U & (~ ((IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__a_full_q) 
                             | (IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__b_full_q))))) {
                Vtb_llc_pending___024root____VbeforeTrig_h3cf2b702__0(vlSelf, 
                                                                      "@(negedge tb_llc_pending.clk)");
                co_await vlSelfRef.__VtrigSched_h3cf2b702__0.trigger(0U, 
                                                                     nullptr, 
                                                                     "@(negedge tb_llc_pending.clk)", 
                                                                     "tb_llc_pending.sv", 
                                                                     41);
            }
            if (VL_UNLIKELY(((((1U & (IData)((((IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__b_full_q)
                                                ? vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__b_data_q
                                                : vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__a_data_q) 
                                              >> 0x0000003aU))) 
                               != (IData)(__Vtask_tb_llc_pending__DOT__receive__6__eh)) 
                              | ((1U & (IData)((((IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__b_full_q)
                                                  ? vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__b_data_q
                                                  : vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__a_data_q) 
                                                >> 0x00000039U))) 
                                 != (IData)(__Vtask_tb_llc_pending__DOT__receive__6__ee)))))) {
                VL_WRITEF_NX("[%0t] %%Fatal: tb_llc_pending.sv:42: Assertion failed in %m: tag response mismatch\n",3, 'M',vlSymsp->name(),"tb_llc_pending.receive", 'T',-9
                             , '#',64,VL_TIME_UNITED_Q(1000));
                VL_STOP_MT("tb_llc_pending.sv", 42, "", false);
            }
            vlSelfRef.tb_llc_pending__DOT__orr = 1U;
            Vtb_llc_pending___024root____VbeforeTrig_h3cf2b645__0(vlSelf, 
                                                                  "@(posedge tb_llc_pending.clk)");
            co_await vlSelfRef.__VtrigSched_h3cf2b645__0.trigger(0U, 
                                                                 nullptr, 
                                                                 "@(posedge tb_llc_pending.clk)", 
                                                                 "tb_llc_pending.sv", 
                                                                 43);
            Vtb_llc_pending___024root____VbeforeTrig_h3cf2b702__0(vlSelf, 
                                                                  "@(negedge tb_llc_pending.clk)");
            co_await vlSelfRef.__VtrigSched_h3cf2b702__0.trigger(0U, 
                                                                 nullptr, 
                                                                 "@(negedge tb_llc_pending.clk)", 
                                                                 "tb_llc_pending.sv", 
                                                                 43);
            vlSelfRef.tb_llc_pending__DOT__orr = 0U;
            vlSelfRef.tb_llc_pending__DOT__unnamedblk2__DOT__unnamedblk4__DOT__k 
                = ((IData)(1U) + vlSelfRef.tb_llc_pending__DOT__unnamedblk2__DOT__unnamedblk4__DOT__k);
        }
        if (VL_UNLIKELY(((0x0fU != (IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__pending_valid_q))))) {
            VL_WRITEF_NX("[%0t] %%Fatal: tb_llc_pending.sv:66: Assertion failed in %m: table did not reach full\n",3, 'M',vlSymsp->name(),"tb_llc_pending.unnamedblk2", 'T',-9
                         , '#',64,VL_TIME_UNITED_Q(1000));
            VL_STOP_MT("tb_llc_pending.sv", 66, "", false);
        }
        __Vtask_tb_llc_pending__DOT__send__7__dirty = 0U;
        __Vtask_tb_llc_pending__DOT__send__7__tag_value 
            = ((IData)(0x00000034U) + VL_MULS_III(32, (IData)(0x00000010U), tb_llc_pending__DOT__unnamedblk2__DOT__round_idx));
        __Vtask_tb_llc_pending__DOT__send__7__idx = 4U;
        __Vtask_tb_llc_pending__DOT__send__7__mode = 2U;
        Vtb_llc_pending___024root____VbeforeTrig_h3cf2b702__0(vlSelf, 
                                                              "@(negedge tb_llc_pending.clk)");
        co_await vlSelfRef.__VtrigSched_h3cf2b702__0.trigger(0U, 
                                                             nullptr, 
                                                             "@(negedge tb_llc_pending.clk)", 
                                                             "tb_llc_pending.sv", 
                                                             35);
        vlSelfRef.tb_llc_pending__DOT__req[0U] = (IData)(
                                                         (((QData)((IData)(
                                                                           (8U 
                                                                            | (7U 
                                                                               & __Vtask_tb_llc_pending__DOT__send__7__idx)))) 
                                                           << 0x0000003cU) 
                                                          | ((0x0ffffffffffffff8ULL 
                                                              & (VL_EXTENDS_QI(57,32, __Vtask_tb_llc_pending__DOT__send__7__tag_value) 
                                                                 << 3U)) 
                                                             | (QData)((IData)(
                                                                               ((IData)(__Vtask_tb_llc_pending__DOT__send__7__dirty) 
                                                                                << 2U))))));
        vlSelfRef.tb_llc_pending__DOT__req[1U] = (IData)(
                                                         ((((QData)((IData)(
                                                                            (8U 
                                                                             | (7U 
                                                                                & __Vtask_tb_llc_pending__DOT__send__7__idx)))) 
                                                            << 0x0000003cU) 
                                                           | ((0x0ffffffffffffff8ULL 
                                                               & (VL_EXTENDS_QI(57,32, __Vtask_tb_llc_pending__DOT__send__7__tag_value) 
                                                                  << 3U)) 
                                                              | (QData)((IData)(
                                                                                ((IData)(__Vtask_tb_llc_pending__DOT__send__7__dirty) 
                                                                                << 2U))))) 
                                                          >> 0x00000020U));
        vlSelfRef.tb_llc_pending__DOT__req[2U] = (3U 
                                                  & (IData)(__Vtask_tb_llc_pending__DOT__send__7__mode));
        vlSelfRef.tb_llc_pending__DOT__iv = 1U;
        do {
            Vtb_llc_pending___024root____VbeforeTrig_h3cf2b645__0(vlSelf, 
                                                                  "@(posedge tb_llc_pending.clk)");
            co_await vlSelfRef.__VtrigSched_h3cf2b645__0.trigger(0U, 
                                                                 nullptr, 
                                                                 "@(posedge tb_llc_pending.clk)", 
                                                                 "tb_llc_pending.sv", 
                                                                 37);
        } while ((1U & (~ (IData)(vlSelfRef.tb_llc_pending__DOT__ir))));
        Vtb_llc_pending___024root____VbeforeTrig_h3cf2b702__0(vlSelf, 
                                                              "@(negedge tb_llc_pending.clk)");
        co_await vlSelfRef.__VtrigSched_h3cf2b702__0.trigger(0U, 
                                                             nullptr, 
                                                             "@(negedge tb_llc_pending.clk)", 
                                                             "tb_llc_pending.sv", 
                                                             38);
        vlSelfRef.tb_llc_pending__DOT__iv = 0U;
        tb_llc_pending__DOT__unnamedblk2__DOT__unnamedblk1_2__DOT____Vrepeat1 = 4U;
        while (VL_LTS_III(32, 0U, tb_llc_pending__DOT__unnamedblk2__DOT__unnamedblk1_2__DOT____Vrepeat1)) {
            Vtb_llc_pending___024root____VbeforeTrig_h3cf2b702__0(vlSelf, 
                                                                  "@(negedge tb_llc_pending.clk)");
            co_await vlSelfRef.__VtrigSched_h3cf2b702__0.trigger(0U, 
                                                                 nullptr, 
                                                                 "@(negedge tb_llc_pending.clk)", 
                                                                 "tb_llc_pending.sv", 
                                                                 69);
            if (VL_UNLIKELY((((IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__a_full_q) 
                              | (IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__b_full_q))))) {
                VL_WRITEF_NX("[%0t] %%Fatal: tb_llc_pending.sv:70: Assertion failed in %m: dirty replacement accepted with pending table full\n",3, 'M',vlSymsp->name(),"tb_llc_pending.unnamedblk2.unnamedblk1_2", 'T',-9
                             , '#',64,VL_TIME_UNITED_Q(1000));
                VL_STOP_MT("tb_llc_pending.sv", 70, "", false);
            }
            tb_llc_pending__DOT__unnamedblk2__DOT__unnamedblk1_2__DOT____Vrepeat1 
                = (tb_llc_pending__DOT__unnamedblk2__DOT__unnamedblk1_2__DOT____Vrepeat1 
                   - (IData)(1U));
        }
        Vtb_llc_pending___024root____VbeforeTrig_h3cf2b702__0(vlSelf, 
                                                              "@(negedge tb_llc_pending.clk)");
        co_await vlSelfRef.__VtrigSched_h3cf2b702__0.trigger(0U, 
                                                             nullptr, 
                                                             "@(negedge tb_llc_pending.clk)", 
                                                             "tb_llc_pending.sv", 
                                                             46);
        vlSelfRef.tb_llc_pending__DOT__commit = 1U;
        Vtb_llc_pending___024root____VbeforeTrig_h3cf2b645__0(vlSelf, 
                                                              "@(posedge tb_llc_pending.clk)");
        co_await vlSelfRef.__VtrigSched_h3cf2b645__0.trigger(0U, 
                                                             nullptr, 
                                                             "@(posedge tb_llc_pending.clk)", 
                                                             "tb_llc_pending.sv", 
                                                             47);
        Vtb_llc_pending___024root____VbeforeTrig_h3cf2b702__0(vlSelf, 
                                                              "@(negedge tb_llc_pending.clk)");
        co_await vlSelfRef.__VtrigSched_h3cf2b702__0.trigger(0U, 
                                                             nullptr, 
                                                             "@(negedge tb_llc_pending.clk)", 
                                                             "tb_llc_pending.sv", 
                                                             47);
        vlSelfRef.tb_llc_pending__DOT__commit = 0U;
        __Vtask_tb_llc_pending__DOT__receive__9__ee = 1U;
        __Vtask_tb_llc_pending__DOT__receive__9__eh = 0U;
        while ((1U & (~ ((IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__a_full_q) 
                         | (IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__b_full_q))))) {
            Vtb_llc_pending___024root____VbeforeTrig_h3cf2b702__0(vlSelf, 
                                                                  "@(negedge tb_llc_pending.clk)");
            co_await vlSelfRef.__VtrigSched_h3cf2b702__0.trigger(0U, 
                                                                 nullptr, 
                                                                 "@(negedge tb_llc_pending.clk)", 
                                                                 "tb_llc_pending.sv", 
                                                                 41);
        }
        if (VL_UNLIKELY(((((1U & (IData)((((IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__b_full_q)
                                            ? vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__b_data_q
                                            : vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__a_data_q) 
                                          >> 0x0000003aU))) 
                           != (IData)(__Vtask_tb_llc_pending__DOT__receive__9__eh)) 
                          | ((1U & (IData)((((IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__b_full_q)
                                              ? vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__b_data_q
                                              : vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__a_data_q) 
                                            >> 0x00000039U))) 
                             != (IData)(__Vtask_tb_llc_pending__DOT__receive__9__ee)))))) {
            VL_WRITEF_NX("[%0t] %%Fatal: tb_llc_pending.sv:42: Assertion failed in %m: tag response mismatch\n",3, 'M',vlSymsp->name(),"tb_llc_pending.receive", 'T',-9
                         , '#',64,VL_TIME_UNITED_Q(1000));
            VL_STOP_MT("tb_llc_pending.sv", 42, "", false);
        }
        vlSelfRef.tb_llc_pending__DOT__orr = 1U;
        Vtb_llc_pending___024root____VbeforeTrig_h3cf2b645__0(vlSelf, 
                                                              "@(posedge tb_llc_pending.clk)");
        co_await vlSelfRef.__VtrigSched_h3cf2b645__0.trigger(0U, 
                                                             nullptr, 
                                                             "@(posedge tb_llc_pending.clk)", 
                                                             "tb_llc_pending.sv", 
                                                             43);
        Vtb_llc_pending___024root____VbeforeTrig_h3cf2b702__0(vlSelf, 
                                                              "@(negedge tb_llc_pending.clk)");
        co_await vlSelfRef.__VtrigSched_h3cf2b702__0.trigger(0U, 
                                                             nullptr, 
                                                             "@(negedge tb_llc_pending.clk)", 
                                                             "tb_llc_pending.sv", 
                                                             43);
        vlSelfRef.tb_llc_pending__DOT__orr = 0U;
        vlSelfRef.tb_llc_pending__DOT__unnamedblk2__DOT__unnamedblk5__DOT__k = 0U;
        while (VL_GTS_III(32, 4U, vlSelfRef.tb_llc_pending__DOT__unnamedblk2__DOT__unnamedblk5__DOT__k)) {
            Vtb_llc_pending___024root____VbeforeTrig_h3cf2b702__0(vlSelf, 
                                                                  "@(negedge tb_llc_pending.clk)");
            co_await vlSelfRef.__VtrigSched_h3cf2b702__0.trigger(0U, 
                                                                 nullptr, 
                                                                 "@(negedge tb_llc_pending.clk)", 
                                                                 "tb_llc_pending.sv", 
                                                                 46);
            vlSelfRef.tb_llc_pending__DOT__commit = 1U;
            Vtb_llc_pending___024root____VbeforeTrig_h3cf2b645__0(vlSelf, 
                                                                  "@(posedge tb_llc_pending.clk)");
            co_await vlSelfRef.__VtrigSched_h3cf2b645__0.trigger(0U, 
                                                                 nullptr, 
                                                                 "@(posedge tb_llc_pending.clk)", 
                                                                 "tb_llc_pending.sv", 
                                                                 47);
            Vtb_llc_pending___024root____VbeforeTrig_h3cf2b702__0(vlSelf, 
                                                                  "@(negedge tb_llc_pending.clk)");
            co_await vlSelfRef.__VtrigSched_h3cf2b702__0.trigger(0U, 
                                                                 nullptr, 
                                                                 "@(negedge tb_llc_pending.clk)", 
                                                                 "tb_llc_pending.sv", 
                                                                 47);
            vlSelfRef.tb_llc_pending__DOT__commit = 0U;
            tb_llc_pending__DOT__unnamedblk2__DOT__unnamedblk5__DOT__unnamedblk1_3__DOT____Vrepeat2 = 2U;
            while (VL_LTS_III(32, 0U, tb_llc_pending__DOT__unnamedblk2__DOT__unnamedblk5__DOT__unnamedblk1_3__DOT____Vrepeat2)) {
                Vtb_llc_pending___024root____VbeforeTrig_h3cf2b702__0(vlSelf, 
                                                                      "@(negedge tb_llc_pending.clk)");
                co_await vlSelfRef.__VtrigSched_h3cf2b702__0.trigger(0U, 
                                                                     nullptr, 
                                                                     "@(negedge tb_llc_pending.clk)", 
                                                                     "tb_llc_pending.sv", 
                                                                     74);
                tb_llc_pending__DOT__unnamedblk2__DOT__unnamedblk5__DOT__unnamedblk1_3__DOT____Vrepeat2 
                    = (tb_llc_pending__DOT__unnamedblk2__DOT__unnamedblk5__DOT__unnamedblk1_3__DOT____Vrepeat2 
                       - (IData)(1U));
            }
            vlSelfRef.tb_llc_pending__DOT__unnamedblk2__DOT__unnamedblk5__DOT__k 
                = ((IData)(1U) + vlSelfRef.tb_llc_pending__DOT__unnamedblk2__DOT__unnamedblk5__DOT__k);
        }
        while ((0U != (IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__pending_valid_q))) {
            Vtb_llc_pending___024root____VbeforeTrig_hdc8bdab8__0(vlSelf, 
                                                                  "@( (4'h0 == tb_llc_pending.dut.pending_valid_q))");
            co_await vlSelfRef.__VtrigSched_hdc8bdab8__0.trigger(1U, 
                                                                 nullptr, 
                                                                 "@( (4'h0 == tb_llc_pending.dut.pending_valid_q))", 
                                                                 "tb_llc_pending.sv", 
                                                                 75);
        }
        vlSelfRef.tb_llc_pending__DOT__unnamedblk2__DOT__unnamedblk6__DOT__k = 0U;
        while (VL_GTS_III(32, 5U, vlSelfRef.tb_llc_pending__DOT__unnamedblk2__DOT__unnamedblk6__DOT__k)) {
            __Vtask_tb_llc_pending__DOT__send__11__dirty = 0U;
            __Vtask_tb_llc_pending__DOT__send__11__tag_value 
                = ((IData)(0x00000030U) + (VL_MULS_III(32, (IData)(0x00000010U), tb_llc_pending__DOT__unnamedblk2__DOT__round_idx) 
                                           + vlSelfRef.tb_llc_pending__DOT__unnamedblk2__DOT__unnamedblk6__DOT__k));
            __Vtask_tb_llc_pending__DOT__send__11__idx 
                = vlSelfRef.tb_llc_pending__DOT__unnamedblk2__DOT__unnamedblk6__DOT__k;
            __Vtask_tb_llc_pending__DOT__send__11__mode = 2U;
            Vtb_llc_pending___024root____VbeforeTrig_h3cf2b702__0(vlSelf, 
                                                                  "@(negedge tb_llc_pending.clk)");
            co_await vlSelfRef.__VtrigSched_h3cf2b702__0.trigger(0U, 
                                                                 nullptr, 
                                                                 "@(negedge tb_llc_pending.clk)", 
                                                                 "tb_llc_pending.sv", 
                                                                 35);
            vlSelfRef.tb_llc_pending__DOT__req[0U] 
                = (IData)((((QData)((IData)((8U | (7U 
                                                   & __Vtask_tb_llc_pending__DOT__send__11__idx)))) 
                            << 0x0000003cU) | ((0x0ffffffffffffff8ULL 
                                                & (VL_EXTENDS_QI(57,32, __Vtask_tb_llc_pending__DOT__send__11__tag_value) 
                                                   << 3U)) 
                                               | (QData)((IData)(
                                                                 ((IData)(__Vtask_tb_llc_pending__DOT__send__11__dirty) 
                                                                  << 2U))))));
            vlSelfRef.tb_llc_pending__DOT__req[1U] 
                = (IData)(((((QData)((IData)((8U | 
                                              (7U & __Vtask_tb_llc_pending__DOT__send__11__idx)))) 
                             << 0x0000003cU) | ((0x0ffffffffffffff8ULL 
                                                 & (VL_EXTENDS_QI(57,32, __Vtask_tb_llc_pending__DOT__send__11__tag_value) 
                                                    << 3U)) 
                                                | (QData)((IData)(
                                                                  ((IData)(__Vtask_tb_llc_pending__DOT__send__11__dirty) 
                                                                   << 2U))))) 
                           >> 0x00000020U));
            vlSelfRef.tb_llc_pending__DOT__req[2U] 
                = (3U & (IData)(__Vtask_tb_llc_pending__DOT__send__11__mode));
            vlSelfRef.tb_llc_pending__DOT__iv = 1U;
            do {
                Vtb_llc_pending___024root____VbeforeTrig_h3cf2b645__0(vlSelf, 
                                                                      "@(posedge tb_llc_pending.clk)");
                co_await vlSelfRef.__VtrigSched_h3cf2b645__0.trigger(0U, 
                                                                     nullptr, 
                                                                     "@(posedge tb_llc_pending.clk)", 
                                                                     "tb_llc_pending.sv", 
                                                                     37);
            } while ((1U & (~ (IData)(vlSelfRef.tb_llc_pending__DOT__ir))));
            Vtb_llc_pending___024root____VbeforeTrig_h3cf2b702__0(vlSelf, 
                                                                  "@(negedge tb_llc_pending.clk)");
            co_await vlSelfRef.__VtrigSched_h3cf2b702__0.trigger(0U, 
                                                                 nullptr, 
                                                                 "@(negedge tb_llc_pending.clk)", 
                                                                 "tb_llc_pending.sv", 
                                                                 38);
            vlSelfRef.tb_llc_pending__DOT__iv = 0U;
            __Vtask_tb_llc_pending__DOT__receive__12__ee = 0U;
            __Vtask_tb_llc_pending__DOT__receive__12__eh = 1U;
            while ((1U & (~ ((IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__a_full_q) 
                             | (IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__b_full_q))))) {
                Vtb_llc_pending___024root____VbeforeTrig_h3cf2b702__0(vlSelf, 
                                                                      "@(negedge tb_llc_pending.clk)");
                co_await vlSelfRef.__VtrigSched_h3cf2b702__0.trigger(0U, 
                                                                     nullptr, 
                                                                     "@(negedge tb_llc_pending.clk)", 
                                                                     "tb_llc_pending.sv", 
                                                                     41);
            }
            if (VL_UNLIKELY(((((1U & (IData)((((IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__b_full_q)
                                                ? vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__b_data_q
                                                : vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__a_data_q) 
                                              >> 0x0000003aU))) 
                               != (IData)(__Vtask_tb_llc_pending__DOT__receive__12__eh)) 
                              | ((1U & (IData)((((IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__b_full_q)
                                                  ? vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__b_data_q
                                                  : vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__a_data_q) 
                                                >> 0x00000039U))) 
                                 != (IData)(__Vtask_tb_llc_pending__DOT__receive__12__ee)))))) {
                VL_WRITEF_NX("[%0t] %%Fatal: tb_llc_pending.sv:42: Assertion failed in %m: tag response mismatch\n",3, 'M',vlSymsp->name(),"tb_llc_pending.receive", 'T',-9
                             , '#',64,VL_TIME_UNITED_Q(1000));
                VL_STOP_MT("tb_llc_pending.sv", 42, "", false);
            }
            vlSelfRef.tb_llc_pending__DOT__orr = 1U;
            Vtb_llc_pending___024root____VbeforeTrig_h3cf2b645__0(vlSelf, 
                                                                  "@(posedge tb_llc_pending.clk)");
            co_await vlSelfRef.__VtrigSched_h3cf2b645__0.trigger(0U, 
                                                                 nullptr, 
                                                                 "@(posedge tb_llc_pending.clk)", 
                                                                 "tb_llc_pending.sv", 
                                                                 43);
            Vtb_llc_pending___024root____VbeforeTrig_h3cf2b702__0(vlSelf, 
                                                                  "@(negedge tb_llc_pending.clk)");
            co_await vlSelfRef.__VtrigSched_h3cf2b702__0.trigger(0U, 
                                                                 nullptr, 
                                                                 "@(negedge tb_llc_pending.clk)", 
                                                                 "tb_llc_pending.sv", 
                                                                 43);
            vlSelfRef.tb_llc_pending__DOT__orr = 0U;
            vlSelfRef.tb_llc_pending__DOT__unnamedblk2__DOT__unnamedblk6__DOT__k 
                = ((IData)(1U) + vlSelfRef.tb_llc_pending__DOT__unnamedblk2__DOT__unnamedblk6__DOT__k);
        }
        tb_llc_pending__DOT__unnamedblk2__DOT__round_idx 
            = ((IData)(1U) + tb_llc_pending__DOT__unnamedblk2__DOT__round_idx);
    }
    VL_WRITEF_NX("PASS: LLC pending table full, completion escape, and 15-entry pointer wraparound\n",0);
    VL_FINISH_MT("tb_llc_pending.sv", 81, "");
    co_return;
}

VlCoroutine Vtb_llc_pending___024root___eval_initial__TOP__Vtiming__1(Vtb_llc_pending___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_llc_pending___024root___eval_initial__TOP__Vtiming__1\n"); );
    Vtb_llc_pending__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    co_await vlSelfRef.__VdlySched.delay(0x0000000005f5e100ULL, 
                                         nullptr, "tb_llc_pending.sv", 
                                         83);
    VL_WRITEF_NX("[%0t] %%Fatal: tb_llc_pending.sv:83: Assertion failed in %m: pending table timeout/deadlock\n",3, 'M',vlSymsp->name(),"tb_llc_pending", 'T',-9
                 , '#',64,VL_TIME_UNITED_Q(1000));
    VL_STOP_MT("tb_llc_pending.sv", 83, "", false);
    co_return;
}

VlCoroutine Vtb_llc_pending___024root___eval_initial__TOP__Vtiming__2(Vtb_llc_pending___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_llc_pending___024root___eval_initial__TOP__Vtiming__2\n"); );
    Vtb_llc_pending__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    while (VL_LIKELY(!vlSymsp->_vm_contextp__->gotFinish())) {
        co_await vlSelfRef.__VdlySched.delay(0x0000000000001388ULL, 
                                             nullptr, 
                                             "tb_llc_pending.sv", 
                                             25);
        vlSelfRef.tb_llc_pending__DOT__clk = (1U & 
                                              (~ (IData)(vlSelfRef.tb_llc_pending__DOT__clk)));
    }
    co_return;
}

bool Vtb_llc_pending___024root___trigger_anySet__ico(const VlUnpacked<QData/*63:0*/, 1> &in) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_llc_pending___024root___trigger_anySet__ico\n"); );
    // Locals
    IData/*31:0*/ n;
    // Body
    n = 0U;
    do {
        if (in[n]) {
            return (1U);
        }
        n = ((IData)(1U) + n);
    } while ((1U > n));
    return (0U);
}

bool Vtb_llc_pending___024root___trigger_anySet__act(const VlUnpacked<QData/*63:0*/, 1> &in) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_llc_pending___024root___trigger_anySet__act\n"); );
    // Locals
    IData/*31:0*/ n;
    // Body
    n = 0U;
    do {
        if (in[n]) {
            return (1U);
        }
        n = ((IData)(1U) + n);
    } while ((1U > n));
    return (0U);
}

extern const VlUnpacked<CData/*0:0*/, 8> Vtb_llc_pending__ConstPool__TABLE_hc820fc1c_0;

void Vtb_llc_pending___024root___act_comb__TOP__0(Vtb_llc_pending___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_llc_pending___024root___act_comb__TOP__0\n"); );
    Vtb_llc_pending__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__b_fill 
        = ((~ (IData)(vlSelfRef.tb_llc_pending__DOT__orr)) 
           & (IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__a_drain));
    vlSelfRef.tb_llc_pending__DOT__dut__DOT__switch_busy = 0U;
    vlSelfRef.tb_llc_pending__DOT__ir = 0U;
    vlSelfRef.tb_llc_pending__DOT__dut__DOT__load_req = 0U;
    vlSelfRef.tb_llc_pending__DOT__dut__DOT__res_valid = 0U;
    vlSelfRef.tb_llc_pending__DOT__dut__DOT__ram_req = 0U;
    vlSelfRef.tb_llc_pending__DOT__dut__DOT__ram_we = 0U;
    vlSelfRef.tb_llc_pending__DOT__dut__DOT__ram_index = 0U;
    vlSelfRef.tb_llc_pending__DOT__dut__DOT__ram_wdata = 0ULL;
    vlSelfRef.tb_llc_pending__DOT__dut__DOT__gen_valid = 0U;
    if (vlSelfRef.tb_llc_pending__DOT__dut__DOT__busy_q) {
        if ((2U & vlSelfRef.tb_llc_pending__DOT__dut__DOT__req_q[2U])) {
            if ((1U & vlSelfRef.tb_llc_pending__DOT__dut__DOT__req_q[2U])) {
                if (((IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__ram_rvalid) 
                     | (IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__ram_rvalid_q))) {
                    vlSelfRef.tb_llc_pending__DOT__dut__DOT__res_valid 
                        = (1U & (~ (IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__maint_pending_q)));
                }
                if (((IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__res_valid) 
                     & (IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__res_ready))) {
                    vlSelfRef.tb_llc_pending__DOT__dut__DOT__switch_busy = 1U;
                }
            } else {
                if (((IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__ram_rvalid) 
                     | (IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__ram_rvalid_q))) {
                    vlSelfRef.tb_llc_pending__DOT__dut__DOT__res_valid 
                        = ((IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__hit) 
                           || Vtb_llc_pending__ConstPool__TABLE_hc820fc1c_0
                           [vlSelfRef.__VdfgRegularize_h6e95ff9d_0_17]);
                }
                if ((IData)(((0x0200000000000000ULL 
                              == (0x0600000000000000ULL 
                                  & vlSelfRef.tb_llc_pending__DOT__dut__DOT__res)) 
                             & (IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__pending_full)))) {
                    vlSelfRef.tb_llc_pending__DOT__dut__DOT__res_valid = 0U;
                }
                if (((IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__res_valid) 
                     & (IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__res_ready))) {
                    if ((1U & (IData)((vlSelfRef.tb_llc_pending__DOT__dut__DOT__res 
                                       >> 0x0000003aU)))) {
                        if ((1U & ((vlSelfRef.tb_llc_pending__DOT__dut__DOT__req_q[0U] 
                                    >> 2U) & (~ (IData)(
                                                        (vlSelfRef.tb_llc_pending__DOT__dut__DOT__gen_tag_macros__BRA__0__KET____DOT__i_tag_store__DOT__rdata_q 
                                                         >> 0x00000039U)))))) {
                            vlSelfRef.tb_llc_pending__DOT__dut__DOT__ram_req 
                                = (1U & (IData)((vlSelfRef.tb_llc_pending__DOT__dut__DOT__res 
                                                 >> 0x0000003bU)));
                            vlSelfRef.tb_llc_pending__DOT__dut__DOT__ram_we 
                                = (1U & (IData)((vlSelfRef.tb_llc_pending__DOT__dut__DOT__res 
                                                 >> 0x0000003bU)));
                            vlSelfRef.tb_llc_pending__DOT__dut__DOT__ram_index 
                                = (7U & (vlSelfRef.tb_llc_pending__DOT__dut__DOT__req_q[1U] 
                                         >> 0x0000001cU));
                            vlSelfRef.tb_llc_pending__DOT__dut__DOT__ram_wdata 
                                = (0x0600000000000000ULL 
                                   | (0x01ffffffffffffffULL 
                                      & (((QData)((IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__req_q[1U])) 
                                          << 0x0000001dU) 
                                         | ((QData)((IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__req_q[0U])) 
                                            >> 3U))));
                            vlSelfRef.tb_llc_pending__DOT__dut__DOT__switch_busy = 1U;
                        } else if (((IData)(vlSelfRef.tb_llc_pending__DOT__iv) 
                                    & (2U == vlSelfRef.tb_llc_pending__DOT__req[2U]))) {
                            vlSelfRef.tb_llc_pending__DOT__ir = 1U;
                            vlSelfRef.tb_llc_pending__DOT__dut__DOT__ram_req 
                                = (vlSelfRef.tb_llc_pending__DOT__req[1U] 
                                   >> 0x0000001fU);
                            vlSelfRef.tb_llc_pending__DOT__dut__DOT__ram_index 
                                = (7U & (vlSelfRef.tb_llc_pending__DOT__req[1U] 
                                         >> 0x0000001cU));
                            vlSelfRef.tb_llc_pending__DOT__dut__DOT__load_req = 1U;
                        } else {
                            vlSelfRef.tb_llc_pending__DOT__dut__DOT__switch_busy = 1U;
                        }
                    } else {
                        if ((1U & (~ (IData)((vlSelfRef.tb_llc_pending__DOT__dut__DOT__res 
                                              >> 0x00000039U))))) {
                            vlSelfRef.tb_llc_pending__DOT__dut__DOT__ram_req 
                                = (1U & (IData)((vlSelfRef.tb_llc_pending__DOT__dut__DOT__res 
                                                 >> 0x0000003bU)));
                            vlSelfRef.tb_llc_pending__DOT__dut__DOT__ram_we 
                                = (1U & (IData)((vlSelfRef.tb_llc_pending__DOT__dut__DOT__res 
                                                 >> 0x0000003bU)));
                            vlSelfRef.tb_llc_pending__DOT__dut__DOT__ram_index 
                                = (7U & (vlSelfRef.tb_llc_pending__DOT__dut__DOT__req_q[1U] 
                                         >> 0x0000001cU));
                            vlSelfRef.tb_llc_pending__DOT__dut__DOT__ram_wdata 
                                = (0x0400000000000000ULL 
                                   | (((QData)((IData)(
                                                       (1U 
                                                        & (vlSelfRef.tb_llc_pending__DOT__dut__DOT__req_q[0U] 
                                                           >> 2U)))) 
                                       << 0x00000039U) 
                                      | (0x01ffffffffffffffULL 
                                         & (((QData)((IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__req_q[1U])) 
                                             << 0x0000001dU) 
                                            | ((QData)((IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__req_q[0U])) 
                                               >> 3U)))));
                        }
                        vlSelfRef.tb_llc_pending__DOT__dut__DOT__switch_busy = 1U;
                    }
                }
            }
        } else if ((1U & vlSelfRef.tb_llc_pending__DOT__dut__DOT__req_q[2U])) {
            if (((IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__ram_rvalid) 
                 | (IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__ram_rvalid_q))) {
                vlSelfRef.tb_llc_pending__DOT__dut__DOT__res_valid = 1U;
            }
            if (vlSelfRef.tb_llc_pending__DOT__dut__DOT__flush_wait_q) {
                vlSelfRef.tb_llc_pending__DOT__dut__DOT__res_valid = 0U;
            }
        } else {
            vlSelfRef.tb_llc_pending__DOT__dut__DOT__ram_req 
                = vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_tag_pattern_gen__DOT__en_cnt;
            vlSelfRef.tb_llc_pending__DOT__dut__DOT__ram_we 
                = ((IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_tag_pattern_gen__DOT__busy_q) 
                   & ((~ ((IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_tag_pattern_gen__DOT__bist_q) 
                          >> 3U)) & ((4U & (IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_tag_pattern_gen__DOT__bist_q))
                                      ? ((~ ((IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_tag_pattern_gen__DOT__bist_q) 
                                             >> 1U)) 
                                         & (IData)(vlSelfRef.__VdfgRegularize_h6e95ff9d_0_21))
                                      : (IData)(vlSelfRef.__VdfgRegularize_h6e95ff9d_0_21))));
            vlSelfRef.tb_llc_pending__DOT__dut__DOT__ram_index 
                = (7U & (IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_tag_pattern_gen__DOT__i_index_cnt__DOT__i_counter__DOT__counter_q));
            vlSelfRef.tb_llc_pending__DOT__dut__DOT__ram_wdata 
                = vlSelfRef.tb_llc_pending__DOT__dut__DOT__gen_pattern;
            if (vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_tag_pattern_gen__DOT__eoc_q) {
                vlSelfRef.tb_llc_pending__DOT__dut__DOT__switch_busy = 1U;
            }
        }
    } else {
        vlSelfRef.tb_llc_pending__DOT__ir = 1U;
        if (vlSelfRef.tb_llc_pending__DOT__iv) {
            vlSelfRef.tb_llc_pending__DOT__dut__DOT__switch_busy = 1U;
            vlSelfRef.tb_llc_pending__DOT__dut__DOT__load_req = 1U;
            if ((2U & vlSelfRef.tb_llc_pending__DOT__req[2U])) {
                vlSelfRef.tb_llc_pending__DOT__dut__DOT__ram_req 
                    = (vlSelfRef.tb_llc_pending__DOT__req[1U] 
                       >> 0x0000001fU);
                vlSelfRef.tb_llc_pending__DOT__dut__DOT__ram_index 
                    = (7U & (vlSelfRef.tb_llc_pending__DOT__req[1U] 
                             >> 0x0000001cU));
                vlSelfRef.tb_llc_pending__DOT__dut__DOT__load_req = 1U;
                vlSelfRef.tb_llc_pending__DOT__dut__DOT__switch_busy = 1U;
            } else if ((1U & vlSelfRef.tb_llc_pending__DOT__req[2U])) {
                vlSelfRef.tb_llc_pending__DOT__dut__DOT__ram_req 
                    = (vlSelfRef.tb_llc_pending__DOT__req[1U] 
                       >> 0x0000001fU);
                vlSelfRef.tb_llc_pending__DOT__dut__DOT__ram_index 
                    = (7U & (vlSelfRef.tb_llc_pending__DOT__req[1U] 
                             >> 0x0000001cU));
                vlSelfRef.tb_llc_pending__DOT__dut__DOT__load_req = 1U;
                vlSelfRef.tb_llc_pending__DOT__dut__DOT__switch_busy = 1U;
            } else {
                vlSelfRef.tb_llc_pending__DOT__dut__DOT__gen_valid = 1U;
                vlSelfRef.tb_llc_pending__DOT__ir = 
                    (1U & (~ (IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_tag_pattern_gen__DOT__busy_q)));
                vlSelfRef.tb_llc_pending__DOT__dut__DOT__switch_busy 
                    = (1U & (~ (IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_tag_pattern_gen__DOT__busy_q)));
            }
        }
    }
    if (((IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__load_req) 
         & ((IData)(vlSelfRef.__VdfgRegularize_h6e95ff9d_0_9) 
            | ((IData)(((0U == vlSelfRef.tb_llc_pending__DOT__req[2U]) 
                        & ((IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__maint_pending_q) 
                           | (0U != (IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__pending_valid_q))))) 
               | (((IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__maint_pending_q) 
                   & ((IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__maint_index_q) 
                      == (7U & (vlSelfRef.tb_llc_pending__DOT__req[1U] 
                                >> 0x0000001cU)))) 
                  | ((((IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__pending_valid_q) 
                       >> 3U) & ((7U & (vlSelfRef.tb_llc_pending__DOT__req[1U] 
                                        >> 0x0000001cU)) 
                                 == vlSelfRef.tb_llc_pending__DOT__dut__DOT__pending_index_q[3U])) 
                     | ((((IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__pending_valid_q) 
                          >> 2U) & ((7U & (vlSelfRef.tb_llc_pending__DOT__req[1U] 
                                           >> 0x0000001cU)) 
                                    == vlSelfRef.tb_llc_pending__DOT__dut__DOT__pending_index_q[2U])) 
                        | ((((IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__pending_valid_q) 
                             >> 1U) & ((7U & (vlSelfRef.tb_llc_pending__DOT__req[1U] 
                                              >> 0x0000001cU)) 
                                       == vlSelfRef.tb_llc_pending__DOT__dut__DOT__pending_index_q[1U])) 
                           | (((IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__pending_valid_q) 
                               & ((7U & (vlSelfRef.tb_llc_pending__DOT__req[1U] 
                                         >> 0x0000001cU)) 
                                  == vlSelfRef.tb_llc_pending__DOT__dut__DOT__pending_index_q[0U])) 
                              | (IData)(vlSelfRef.__VdfgRegularize_h6e95ff9d_0_10)))))))))) {
        vlSelfRef.tb_llc_pending__DOT__ir = 0U;
        vlSelfRef.tb_llc_pending__DOT__dut__DOT__load_req = 0U;
        vlSelfRef.tb_llc_pending__DOT__dut__DOT__ram_req = 0U;
        vlSelfRef.tb_llc_pending__DOT__dut__DOT__ram_we = 0U;
        vlSelfRef.tb_llc_pending__DOT__dut__DOT__gen_valid = 0U;
        vlSelfRef.tb_llc_pending__DOT__dut__DOT__switch_busy 
            = vlSelfRef.tb_llc_pending__DOT__dut__DOT__busy_q;
    }
    if (vlSelfRef.tb_llc_pending__DOT__dut__DOT__maint_finish) {
        vlSelfRef.tb_llc_pending__DOT__ir = 0U;
        vlSelfRef.tb_llc_pending__DOT__dut__DOT__load_req = 0U;
        vlSelfRef.tb_llc_pending__DOT__dut__DOT__switch_busy = 0U;
        vlSelfRef.tb_llc_pending__DOT__dut__DOT__gen_valid = 0U;
        vlSelfRef.tb_llc_pending__DOT__dut__DOT__ram_req 
            = vlSelfRef.tb_llc_pending__DOT__dut__DOT__maint_way_q;
        vlSelfRef.tb_llc_pending__DOT__dut__DOT__ram_we 
            = ((~ (IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__maint_error_q)) 
               & (IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__maint_way_q));
        vlSelfRef.tb_llc_pending__DOT__dut__DOT__ram_index 
            = vlSelfRef.tb_llc_pending__DOT__dut__DOT__maint_index_q;
        vlSelfRef.tb_llc_pending__DOT__dut__DOT__ram_wdata 
            = ((0U == (IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__maint_op_q))
                ? vlSelfRef.tb_llc_pending__DOT__dut__DOT__maint_tag_q
                : 0ULL);
    }
    if (vlSelfRef.tb_llc_pending__DOT__dut__DOT__pending_pop) {
        vlSelfRef.tb_llc_pending__DOT__ir = 0U;
        vlSelfRef.tb_llc_pending__DOT__dut__DOT__load_req = 0U;
        vlSelfRef.tb_llc_pending__DOT__dut__DOT__switch_busy = 0U;
        vlSelfRef.tb_llc_pending__DOT__dut__DOT__ram_req 
            = vlSelfRef.tb_llc_pending__DOT__dut__DOT__pending_way_q
            [vlSelfRef.tb_llc_pending__DOT__dut__DOT__pending_read_q];
        vlSelfRef.tb_llc_pending__DOT__dut__DOT__ram_we 
            = vlSelfRef.tb_llc_pending__DOT__dut__DOT__pending_way_q
            [vlSelfRef.tb_llc_pending__DOT__dut__DOT__pending_read_q];
        vlSelfRef.tb_llc_pending__DOT__dut__DOT__ram_index 
            = vlSelfRef.tb_llc_pending__DOT__dut__DOT__pending_index_q
            [vlSelfRef.tb_llc_pending__DOT__dut__DOT__pending_read_q];
        vlSelfRef.tb_llc_pending__DOT__dut__DOT__ram_wdata 
            = vlSelfRef.tb_llc_pending__DOT__dut__DOT__pending_tag_q
            [vlSelfRef.tb_llc_pending__DOT__dut__DOT__pending_read_q];
        vlSelfRef.tb_llc_pending__DOT__dut__DOT__gen_valid = 0U;
    }
    vlSelfRef.tb_llc_pending__DOT__dut__DOT____Vcellinp__gen_tag_macros__BRA__0__KET____DOT__i_shift_reg_rvalid__d_i 
        = ((~ (IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__ram_we)) 
           & (IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__ram_req));
    vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__a_fill 
        = ((IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__res_ready) 
           & (IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__res_valid));
    vlSelfRef.tb_llc_pending__DOT__dut__DOT__pending_push 
        = (((((IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__busy_q) 
              & (2U == vlSelfRef.tb_llc_pending__DOT__dut__DOT__req_q[2U])) 
             & (IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__res_valid)) 
            & (IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__res_ready)) 
           & (0x0200000000000000ULL == (0x0600000000000000ULL 
                                        & vlSelfRef.tb_llc_pending__DOT__dut__DOT__res)));
}

extern const VlUnpacked<CData/*0:0*/, 8> Vtb_llc_pending__ConstPool__TABLE_hdb06591d_0;

void Vtb_llc_pending___024root___nba_sequent__TOP__0(Vtb_llc_pending___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_llc_pending___024root___nba_sequent__TOP__0\n"); );
    Vtb_llc_pending__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    CData/*1:0*/ __Vdly__tb_llc_pending__DOT__dut__DOT__pending_write_q;
    __Vdly__tb_llc_pending__DOT__dut__DOT__pending_write_q = 0;
    CData/*1:0*/ __Vdly__tb_llc_pending__DOT__dut__DOT__pending_ack_q;
    __Vdly__tb_llc_pending__DOT__dut__DOT__pending_ack_q = 0;
    CData/*1:0*/ __Vdly__tb_llc_pending__DOT__dut__DOT__pending_read_q;
    __Vdly__tb_llc_pending__DOT__dut__DOT__pending_read_q = 0;
    CData/*0:0*/ __Vdly__tb_llc_pending__DOT__dut__DOT__i_tag_pattern_gen__DOT__busy_q;
    __Vdly__tb_llc_pending__DOT__dut__DOT__i_tag_pattern_gen__DOT__busy_q = 0;
    CData/*3:0*/ __Vdly__tb_llc_pending__DOT__dut__DOT__i_tag_pattern_gen__DOT__bist_q;
    __Vdly__tb_llc_pending__DOT__dut__DOT__i_tag_pattern_gen__DOT__bist_q = 0;
    CData/*2:0*/ __VdlyVal__tb_llc_pending__DOT__dut__DOT__pending_index_q__v0;
    __VdlyVal__tb_llc_pending__DOT__dut__DOT__pending_index_q__v0 = 0;
    CData/*1:0*/ __VdlyDim0__tb_llc_pending__DOT__dut__DOT__pending_index_q__v0;
    __VdlyDim0__tb_llc_pending__DOT__dut__DOT__pending_index_q__v0 = 0;
    CData/*0:0*/ __VdlySet__tb_llc_pending__DOT__dut__DOT__pending_index_q__v0;
    __VdlySet__tb_llc_pending__DOT__dut__DOT__pending_index_q__v0 = 0;
    CData/*0:0*/ __VdlySet__tb_llc_pending__DOT__dut__DOT__pending_index_q__v1;
    __VdlySet__tb_llc_pending__DOT__dut__DOT__pending_index_q__v1 = 0;
    CData/*0:0*/ __VdlyVal__tb_llc_pending__DOT__dut__DOT__pending_way_q__v0;
    __VdlyVal__tb_llc_pending__DOT__dut__DOT__pending_way_q__v0 = 0;
    CData/*1:0*/ __VdlyDim0__tb_llc_pending__DOT__dut__DOT__pending_way_q__v0;
    __VdlyDim0__tb_llc_pending__DOT__dut__DOT__pending_way_q__v0 = 0;
    CData/*0:0*/ __VdlySet__tb_llc_pending__DOT__dut__DOT__pending_way_q__v0;
    __VdlySet__tb_llc_pending__DOT__dut__DOT__pending_way_q__v0 = 0;
    CData/*0:0*/ __VdlySet__tb_llc_pending__DOT__dut__DOT__pending_way_q__v1;
    __VdlySet__tb_llc_pending__DOT__dut__DOT__pending_way_q__v1 = 0;
    QData/*58:0*/ __VdlyVal__tb_llc_pending__DOT__dut__DOT__pending_tag_q__v0;
    __VdlyVal__tb_llc_pending__DOT__dut__DOT__pending_tag_q__v0 = 0;
    CData/*1:0*/ __VdlyDim0__tb_llc_pending__DOT__dut__DOT__pending_tag_q__v0;
    __VdlyDim0__tb_llc_pending__DOT__dut__DOT__pending_tag_q__v0 = 0;
    CData/*0:0*/ __VdlySet__tb_llc_pending__DOT__dut__DOT__pending_tag_q__v0;
    __VdlySet__tb_llc_pending__DOT__dut__DOT__pending_tag_q__v0 = 0;
    CData/*0:0*/ __VdlySet__tb_llc_pending__DOT__dut__DOT__pending_tag_q__v1;
    __VdlySet__tb_llc_pending__DOT__dut__DOT__pending_tag_q__v1 = 0;
    QData/*58:0*/ __VdlyVal__tb_llc_pending__DOT__dut__DOT__gen_tag_macros__BRA__0__KET____DOT__i_tag_store__DOT__sram__v0;
    __VdlyVal__tb_llc_pending__DOT__dut__DOT__gen_tag_macros__BRA__0__KET____DOT__i_tag_store__DOT__sram__v0 = 0;
    CData/*2:0*/ __VdlyDim0__tb_llc_pending__DOT__dut__DOT__gen_tag_macros__BRA__0__KET____DOT__i_tag_store__DOT__sram__v0;
    __VdlyDim0__tb_llc_pending__DOT__dut__DOT__gen_tag_macros__BRA__0__KET____DOT__i_tag_store__DOT__sram__v0 = 0;
    CData/*0:0*/ __VdlySet__tb_llc_pending__DOT__dut__DOT__gen_tag_macros__BRA__0__KET____DOT__i_tag_store__DOT__sram__v0;
    __VdlySet__tb_llc_pending__DOT__dut__DOT__gen_tag_macros__BRA__0__KET____DOT__i_tag_store__DOT__sram__v0 = 0;
    // Body
    __VdlySet__tb_llc_pending__DOT__dut__DOT__gen_tag_macros__BRA__0__KET____DOT__i_tag_store__DOT__sram__v0 = 0U;
    __Vdly__tb_llc_pending__DOT__dut__DOT__pending_write_q 
        = vlSelfRef.tb_llc_pending__DOT__dut__DOT__pending_write_q;
    __VdlySet__tb_llc_pending__DOT__dut__DOT__pending_way_q__v0 = 0U;
    __VdlySet__tb_llc_pending__DOT__dut__DOT__pending_way_q__v1 = 0U;
    __Vdly__tb_llc_pending__DOT__dut__DOT__pending_read_q 
        = vlSelfRef.tb_llc_pending__DOT__dut__DOT__pending_read_q;
    __Vdly__tb_llc_pending__DOT__dut__DOT__i_tag_pattern_gen__DOT__busy_q 
        = vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_tag_pattern_gen__DOT__busy_q;
    __Vdly__tb_llc_pending__DOT__dut__DOT__pending_ack_q 
        = vlSelfRef.tb_llc_pending__DOT__dut__DOT__pending_ack_q;
    __Vdly__tb_llc_pending__DOT__dut__DOT__i_tag_pattern_gen__DOT__bist_q 
        = vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_tag_pattern_gen__DOT__bist_q;
    __VdlySet__tb_llc_pending__DOT__dut__DOT__pending_index_q__v0 = 0U;
    __VdlySet__tb_llc_pending__DOT__dut__DOT__pending_index_q__v1 = 0U;
    __VdlySet__tb_llc_pending__DOT__dut__DOT__pending_tag_q__v0 = 0U;
    __VdlySet__tb_llc_pending__DOT__dut__DOT__pending_tag_q__v1 = 0U;
    if (vlSelfRef.tb_llc_pending__DOT__rst) {
        if (((IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__b_fill) 
             | ((IData)(vlSelfRef.tb_llc_pending__DOT__orr) 
                & (IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__b_full_q)))) {
            vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__b_full_q 
                = vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__b_fill;
        }
        if (((IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_tag_pattern_gen__DOT__busy_q)
              ? ((~ ((IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_tag_pattern_gen__DOT__bist_q) 
                     >> 3U)) & (IData)(vlSelfRef.__VdfgRegularize_h6e95ff9d_0_20))
              : (IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__gen_valid))) {
            __Vdly__tb_llc_pending__DOT__dut__DOT__i_tag_pattern_gen__DOT__busy_q 
                = ((IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_tag_pattern_gen__DOT__busy_q)
                    ? ((8U & (IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_tag_pattern_gen__DOT__bist_q))
                        ? (IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_tag_pattern_gen__DOT__busy_q)
                        : ((4U & (IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_tag_pattern_gen__DOT__bist_q))
                            ? ((2U & (IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_tag_pattern_gen__DOT__bist_q))
                                ? ((IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_tag_pattern_gen__DOT__busy_q) 
                                   & (IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_tag_pattern_gen__DOT__bist_q))
                                : (IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_tag_pattern_gen__DOT__busy_q))
                            : (IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_tag_pattern_gen__DOT__busy_q)))
                    : ((IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__gen_valid) 
                       | (IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_tag_pattern_gen__DOT__busy_q)));
        }
        if (((IData)(vlSelfRef.tb_llc_pending__DOT__commit) 
             & ((IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__pending_valid_q) 
                >> (IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__pending_ack_q)))) {
            __Vdly__tb_llc_pending__DOT__dut__DOT__pending_ack_q 
                = ((3U == (IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__pending_ack_q))
                    ? 0U : (3U & ((IData)(1U) + (IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__pending_ack_q))));
        }
        if (vlSelfRef.tb_llc_pending__DOT__dut__DOT__pending_push) {
            __Vdly__tb_llc_pending__DOT__dut__DOT__pending_write_q 
                = ((3U == (IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__pending_write_q))
                    ? 0U : (3U & ((IData)(1U) + (IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__pending_write_q))));
            __VdlyVal__tb_llc_pending__DOT__dut__DOT__pending_way_q__v0 
                = (1U & (IData)((vlSelfRef.tb_llc_pending__DOT__dut__DOT__res 
                                 >> 0x0000003bU)));
            __VdlyDim0__tb_llc_pending__DOT__dut__DOT__pending_way_q__v0 
                = vlSelfRef.tb_llc_pending__DOT__dut__DOT__pending_write_q;
            __VdlySet__tb_llc_pending__DOT__dut__DOT__pending_way_q__v0 = 1U;
            __VdlyVal__tb_llc_pending__DOT__dut__DOT__pending_index_q__v0 
                = (7U & (vlSelfRef.tb_llc_pending__DOT__dut__DOT__req_q[1U] 
                         >> 0x0000001cU));
            __VdlyDim0__tb_llc_pending__DOT__dut__DOT__pending_index_q__v0 
                = vlSelfRef.tb_llc_pending__DOT__dut__DOT__pending_write_q;
            __VdlySet__tb_llc_pending__DOT__dut__DOT__pending_index_q__v0 = 1U;
            __VdlyVal__tb_llc_pending__DOT__dut__DOT__pending_tag_q__v0 
                = (0x0400000000000000ULL | (((QData)((IData)(
                                                             (1U 
                                                              & (vlSelfRef.tb_llc_pending__DOT__dut__DOT__req_q[0U] 
                                                                 >> 2U)))) 
                                             << 0x00000039U) 
                                            | (0x01ffffffffffffffULL 
                                               & (((QData)((IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__req_q[1U])) 
                                                   << 0x0000001dU) 
                                                  | ((QData)((IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__req_q[0U])) 
                                                     >> 3U)))));
            __VdlyDim0__tb_llc_pending__DOT__dut__DOT__pending_tag_q__v0 
                = vlSelfRef.tb_llc_pending__DOT__dut__DOT__pending_write_q;
            __VdlySet__tb_llc_pending__DOT__dut__DOT__pending_tag_q__v0 = 1U;
            vlSelfRef.tb_llc_pending__DOT__dut__DOT__pending_done_q 
                = ((~ ((IData)(1U) << (IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__pending_write_q))) 
                   & (IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__pending_done_q));
        }
        if (((IData)(vlSelfRef.tb_llc_pending__DOT__commit) 
             & ((IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__pending_valid_q) 
                >> (IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__pending_ack_q)))) {
            vlSelfRef.tb_llc_pending__DOT__dut__DOT__pending_done_q 
                = (((~ ((IData)(1U) << (IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__pending_ack_q))) 
                    & (IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__pending_done_q)) 
                   | (0x0fU & ((IData)(vlSelfRef.tb_llc_pending__DOT__commit) 
                               << (IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__pending_ack_q))));
        }
        if (vlSelfRef.tb_llc_pending__DOT__dut__DOT__pending_push) {
            vlSelfRef.tb_llc_pending__DOT__dut__DOT__pending_valid_q 
                = ((IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__pending_valid_q) 
                   | (0x0fU & ((IData)(1U) << (IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__pending_write_q))));
        }
        if (vlSelfRef.tb_llc_pending__DOT__dut__DOT__pending_pop) {
            __Vdly__tb_llc_pending__DOT__dut__DOT__pending_read_q 
                = ((3U == (IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__pending_read_q))
                    ? 0U : (3U & ((IData)(1U) + (IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__pending_read_q))));
            vlSelfRef.tb_llc_pending__DOT__dut__DOT__pending_done_q 
                = ((~ ((IData)(1U) << (IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__pending_read_q))) 
                   & (IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__pending_done_q));
            vlSelfRef.tb_llc_pending__DOT__dut__DOT__pending_valid_q 
                = ((~ ((IData)(1U) << (IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__pending_read_q))) 
                   & (IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__pending_valid_q));
        }
        if (((IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_tag_pattern_gen__DOT__busy_q) 
             & ((IData)(vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0) 
                & ((4U & (IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_tag_pattern_gen__DOT__bist_q))
                    ? ((2U & (IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_tag_pattern_gen__DOT__bist_q))
                        ? (IData)(vlSelfRef.__VdfgRegularize_h6e95ff9d_0_2)
                        : (IData)(vlSelfRef.__VdfgRegularize_h6e95ff9d_0_4))
                    : (IData)(vlSelfRef.__VdfgRegularize_h6e95ff9d_0_4))))) {
            __Vdly__tb_llc_pending__DOT__dut__DOT__i_tag_pattern_gen__DOT__bist_q 
                = ((IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_tag_pattern_gen__DOT__busy_q)
                    ? ((8U & (IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_tag_pattern_gen__DOT__bist_q))
                        ? (IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_tag_pattern_gen__DOT__bist_q)
                        : ((4U & (IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_tag_pattern_gen__DOT__bist_q))
                            ? ((2U & (IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_tag_pattern_gen__DOT__bist_q))
                                ? ((IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_tag_pattern_gen__DOT__bist_q) 
                                   & (- (IData)((1U 
                                                 & (IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_tag_pattern_gen__DOT__bist_q)))))
                                : ((1U & (IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_tag_pattern_gen__DOT__bist_q))
                                    ? ((8U & (IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_tag_pattern_gen__DOT__i_index_cnt__DOT__i_counter__DOT__counter_q))
                                        ? ((IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__bist_valid)
                                            ? (IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_tag_pattern_gen__DOT__bist_q)
                                            : 6U) : (IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_tag_pattern_gen__DOT__bist_q))
                                    : ((8U & (IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_tag_pattern_gen__DOT__i_index_cnt__DOT__i_counter__DOT__counter_q))
                                        ? 5U : (IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_tag_pattern_gen__DOT__bist_q))))
                            : ((2U & (IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_tag_pattern_gen__DOT__bist_q))
                                ? ((1U & (IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_tag_pattern_gen__DOT__bist_q))
                                    ? ((8U & (IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_tag_pattern_gen__DOT__i_index_cnt__DOT__i_counter__DOT__counter_q))
                                        ? ((IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__bist_valid)
                                            ? (IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_tag_pattern_gen__DOT__bist_q)
                                            : 4U) : (IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_tag_pattern_gen__DOT__bist_q))
                                    : ((8U & (IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_tag_pattern_gen__DOT__i_index_cnt__DOT__i_counter__DOT__counter_q))
                                        ? 3U : (IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_tag_pattern_gen__DOT__bist_q)))
                                : ((1U & (IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_tag_pattern_gen__DOT__bist_q))
                                    ? ((8U & (IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_tag_pattern_gen__DOT__i_index_cnt__DOT__i_counter__DOT__counter_q))
                                        ? ((IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__bist_valid)
                                            ? (IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_tag_pattern_gen__DOT__bist_q)
                                            : 2U) : (IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_tag_pattern_gen__DOT__bist_q))
                                    : ((8U & (IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_tag_pattern_gen__DOT__i_index_cnt__DOT__i_counter__DOT__counter_q))
                                        ? 1U : (IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_tag_pattern_gen__DOT__bist_q))))))
                    : (IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_tag_pattern_gen__DOT__bist_q));
        }
        vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_tag_pattern_gen__DOT__i_index_cnt__DOT__i_counter__DOT__counter_q 
            = (0x0000000fU & ((((IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_tag_pattern_gen__DOT__busy_q) 
                                & ((~ ((IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_tag_pattern_gen__DOT__bist_q) 
                                       >> 3U)) & ((4U 
                                                   & (IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_tag_pattern_gen__DOT__bist_q))
                                                   ? (IData)(
                                                             ((0U 
                                                               == 
                                                               (3U 
                                                                & (IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_tag_pattern_gen__DOT__bist_q))) 
                                                              & ((IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_tag_pattern_gen__DOT__i_index_cnt__DOT__i_counter__DOT__counter_q) 
                                                                 >> 3U)))
                                                   : 
                                                  (((IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_tag_pattern_gen__DOT__bist_q) 
                                                    >> 1U) 
                                                   & (IData)(vlSelfRef.__VdfgRegularize_h6e95ff9d_0_4)))))
                                ? (7U & (((4U & (IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_tag_pattern_gen__DOT__bist_q))
                                           ? ((- (IData)(
                                                         (1U 
                                                          & ((IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_tag_pattern_gen__DOT__i_index_cnt__DOT__i_counter__DOT__counter_q) 
                                                             >> 3U)))) 
                                              & ((- (IData)(
                                                            (1U 
                                                             & (~ 
                                                                ((IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_tag_pattern_gen__DOT__bist_q) 
                                                                 >> 1U))))) 
                                                 & (- (IData)(
                                                              (1U 
                                                               & (~ (IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_tag_pattern_gen__DOT__bist_q)))))))
                                           : (((1U 
                                                & (IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_tag_pattern_gen__DOT__bist_q))
                                                ? (- (IData)((IData)(vlSelfRef.__VdfgRegularize_h6e95ff9d_0_7)))
                                                : (- (IData)(
                                                             (1U 
                                                              & ((IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_tag_pattern_gen__DOT__i_index_cnt__DOT__i_counter__DOT__counter_q) 
                                                                 >> 3U))))) 
                                              & (- (IData)(
                                                           (1U 
                                                            & ((IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_tag_pattern_gen__DOT__bist_q) 
                                                               >> 1U)))))) 
                                         & (- (IData)((IData)(vlSelfRef.__VdfgRegularize_h6e95ff9d_0_19)))))
                                : ((IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_tag_pattern_gen__DOT__en_cnt)
                                    ? (((IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_tag_pattern_gen__DOT__busy_q) 
                                        & ((~ ((IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_tag_pattern_gen__DOT__bist_q) 
                                               >> 3U)) 
                                           & ((4U & (IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_tag_pattern_gen__DOT__bist_q))
                                               ? (IData)(vlSelfRef.__VdfgRegularize_h6e95ff9d_0_22)
                                               : ((IData)(vlSelfRef.__VdfgRegularize_h6e95ff9d_0_3) 
                                                  & (3U 
                                                     == 
                                                     (3U 
                                                      & (IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_tag_pattern_gen__DOT__bist_q)))))))
                                        ? ((IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_tag_pattern_gen__DOT__i_index_cnt__DOT__i_counter__DOT__counter_q) 
                                           - (IData)(1U))
                                        : ((IData)(1U) 
                                           + (IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_tag_pattern_gen__DOT__i_index_cnt__DOT__i_counter__DOT__counter_q)))
                                    : (IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_tag_pattern_gen__DOT__i_index_cnt__DOT__i_counter__DOT__counter_q))) 
                              & (- (IData)((1U & (~ 
                                                  ((IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_tag_pattern_gen__DOT__busy_q)
                                                    ? 
                                                   ((~ 
                                                     ((IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_tag_pattern_gen__DOT__bist_q) 
                                                      >> 3U)) 
                                                    & ((4U 
                                                        & (IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_tag_pattern_gen__DOT__bist_q))
                                                        ? (IData)(
                                                                  ((1U 
                                                                    == 
                                                                    (3U 
                                                                     & (IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_tag_pattern_gen__DOT__bist_q))) 
                                                                   & (IData)(vlSelfRef.__VdfgRegularize_h6e95ff9d_0_7)))
                                                        : 
                                                       ((~ 
                                                         ((IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_tag_pattern_gen__DOT__bist_q) 
                                                          >> 1U)) 
                                                        & (IData)(vlSelfRef.__VdfgRegularize_h6e95ff9d_0_4))))
                                                    : (IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__gen_valid))))))));
        if (vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__b_fill) {
            vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__b_data_q 
                = vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__a_data_q;
        }
        if (((IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__a_fill) 
             | (IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__a_drain))) {
            vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__a_full_q 
                = vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__a_fill;
        }
        vlSelfRef.tb_llc_pending__DOT__dut__DOT__bist_pattern 
            = vlSelfRef.tb_llc_pending__DOT__dut__DOT__gen_pattern;
        if (((IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__ram_rvalid) 
             | (IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__a_fill))) {
            vlSelfRef.tb_llc_pending__DOT__dut__DOT__ram_rvalid_q 
                = ((~ (IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__a_fill)) 
                   & (IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__ram_rvalid));
        }
        vlSelfRef.tb_llc_pending__DOT__dut__DOT__gen_tag_macros__BRA__0__KET____DOT__i_tag_store__DOT__rdata_q 
            = ((IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT____Vcellinp__gen_tag_macros__BRA__0__KET____DOT__i_shift_reg_rvalid__d_i)
                ? vlSelfRef.tb_llc_pending__DOT__dut__DOT__gen_tag_macros__BRA__0__KET____DOT__i_tag_store__DOT__sram
               [vlSelfRef.tb_llc_pending__DOT__dut__DOT__ram_index]
                : vlSelfRef.tb_llc_pending__DOT__dut__DOT__gen_tag_macros__BRA__0__KET____DOT__i_tag_store__DOT__sram
               [vlSelfRef.tb_llc_pending__DOT__dut__DOT__gen_tag_macros__BRA__0__KET____DOT__i_tag_store__DOT__r_addr_q]);
        if (vlSelfRef.tb_llc_pending__DOT__dut__DOT__ram_req) {
            if (vlSelfRef.tb_llc_pending__DOT__dut__DOT__ram_we) {
                __VdlyVal__tb_llc_pending__DOT__dut__DOT__gen_tag_macros__BRA__0__KET____DOT__i_tag_store__DOT__sram__v0 
                    = vlSelfRef.tb_llc_pending__DOT__dut__DOT__ram_wdata;
                __VdlyDim0__tb_llc_pending__DOT__dut__DOT__gen_tag_macros__BRA__0__KET____DOT__i_tag_store__DOT__sram__v0 
                    = vlSelfRef.tb_llc_pending__DOT__dut__DOT__ram_index;
                __VdlySet__tb_llc_pending__DOT__dut__DOT__gen_tag_macros__BRA__0__KET____DOT__i_tag_store__DOT__sram__v0 = 1U;
            }
            if ((1U & (~ (IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__ram_we)))) {
                vlSelfRef.tb_llc_pending__DOT__dut__DOT__gen_tag_macros__BRA__0__KET____DOT__i_tag_store__DOT__r_addr_q 
                    = vlSelfRef.tb_llc_pending__DOT__dut__DOT__ram_index;
            }
        }
        if (((((IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__busy_q) 
               & (1U == vlSelfRef.tb_llc_pending__DOT__dut__DOT__req_q[2U])) 
              & (IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__res_valid)) 
             & (IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__res_ready))) {
            vlSelfRef.tb_llc_pending__DOT__dut__DOT__flush_wait_q = 1U;
        }
        if (((((IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__busy_q) 
               & (3U == vlSelfRef.tb_llc_pending__DOT__dut__DOT__req_q[2U])) 
              & (IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__res_valid)) 
             & (IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__res_ready))) {
            vlSelfRef.tb_llc_pending__DOT__dut__DOT__maint_error_q = 0U;
            vlSelfRef.tb_llc_pending__DOT__dut__DOT__maint_index_q 
                = (7U & (vlSelfRef.tb_llc_pending__DOT__dut__DOT__req_q[1U] 
                         >> 0x0000001cU));
            vlSelfRef.tb_llc_pending__DOT__dut__DOT__maint_tag_q 
                = (0x0400000000000000ULL | (0x01ffffffffffffffULL 
                                            & (((QData)((IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__req_q[1U])) 
                                                << 0x0000001dU) 
                                               | ((QData)((IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__req_q[0U])) 
                                                  >> 3U))));
            vlSelfRef.tb_llc_pending__DOT__dut__DOT__maint_op_q 
                = (3U & vlSelfRef.tb_llc_pending__DOT__dut__DOT__req_q[0U]);
            vlSelfRef.tb_llc_pending__DOT__dut__DOT__maint_way_q 
                = (1U & (IData)((vlSelfRef.tb_llc_pending__DOT__dut__DOT__res 
                                 >> 0x0000003bU)));
            vlSelfRef.tb_llc_pending__DOT__dut__DOT__maint_result_q = 0U;
            vlSelfRef.tb_llc_pending__DOT__dut__DOT__maint_pending_q = 1U;
        }
        if (vlSelfRef.tb_llc_pending__DOT__dut__DOT__maint_finish) {
            vlSelfRef.tb_llc_pending__DOT__dut__DOT__maint_result_q = 0U;
            vlSelfRef.tb_llc_pending__DOT__dut__DOT__maint_pending_q = 0U;
        }
        if (vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__a_fill) {
            vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__a_data_q 
                = vlSelfRef.tb_llc_pending__DOT__dut__DOT__res;
        }
        if (vlSelfRef.tb_llc_pending__DOT__dut__DOT__switch_busy) {
            vlSelfRef.tb_llc_pending__DOT__dut__DOT__busy_q 
                = vlSelfRef.tb_llc_pending__DOT__dut__DOT__busy_d;
        }
        if (vlSelfRef.tb_llc_pending__DOT__dut__DOT__load_req) {
            vlSelfRef.tb_llc_pending__DOT__dut__DOT__req_q[0U] 
                = vlSelfRef.tb_llc_pending__DOT__req[0U];
            vlSelfRef.tb_llc_pending__DOT__dut__DOT__req_q[1U] 
                = vlSelfRef.tb_llc_pending__DOT__req[1U];
            vlSelfRef.tb_llc_pending__DOT__dut__DOT__req_q[2U] 
                = vlSelfRef.tb_llc_pending__DOT__req[2U];
        }
    } else {
        vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__b_full_q = 0U;
        __Vdly__tb_llc_pending__DOT__dut__DOT__pending_write_q = 0U;
        __VdlySet__tb_llc_pending__DOT__dut__DOT__pending_way_q__v1 = 1U;
        __Vdly__tb_llc_pending__DOT__dut__DOT__pending_read_q = 0U;
        __Vdly__tb_llc_pending__DOT__dut__DOT__i_tag_pattern_gen__DOT__busy_q = 0U;
        __Vdly__tb_llc_pending__DOT__dut__DOT__pending_ack_q = 0U;
        __Vdly__tb_llc_pending__DOT__dut__DOT__i_tag_pattern_gen__DOT__bist_q = 0U;
        vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_tag_pattern_gen__DOT__i_index_cnt__DOT__i_counter__DOT__counter_q = 0U;
        __VdlySet__tb_llc_pending__DOT__dut__DOT__pending_index_q__v1 = 1U;
        __VdlySet__tb_llc_pending__DOT__dut__DOT__pending_tag_q__v1 = 1U;
        vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__b_data_q = 0ULL;
        vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__a_full_q = 0U;
        vlSelfRef.tb_llc_pending__DOT__dut__DOT__bist_pattern = 0ULL;
        vlSelfRef.tb_llc_pending__DOT__dut__DOT__ram_rvalid_q = 0U;
        vlSelfRef.tb_llc_pending__DOT__dut__DOT__pending_done_q = 0U;
        vlSelfRef.tb_llc_pending__DOT__dut__DOT__flush_wait_q = 0U;
        vlSelfRef.tb_llc_pending__DOT__dut__DOT__maint_error_q = 0U;
        vlSelfRef.tb_llc_pending__DOT__dut__DOT__maint_index_q = 0U;
        vlSelfRef.tb_llc_pending__DOT__dut__DOT__maint_tag_q = 0ULL;
        vlSelfRef.tb_llc_pending__DOT__dut__DOT__maint_op_q = 0U;
        vlSelfRef.tb_llc_pending__DOT__dut__DOT__maint_way_q = 0U;
        vlSelfRef.tb_llc_pending__DOT__dut__DOT__maint_result_q = 0U;
        vlSelfRef.tb_llc_pending__DOT__dut__DOT__maint_pending_q = 0U;
        vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__a_data_q = 0ULL;
        vlSelfRef.tb_llc_pending__DOT__dut__DOT__gen_tag_macros__BRA__0__KET____DOT__i_tag_store__DOT__r_addr_q = 0U;
        vlSelfRef.tb_llc_pending__DOT__dut__DOT__pending_valid_q = 0U;
        vlSelfRef.tb_llc_pending__DOT__dut__DOT__busy_q = 0U;
        vlSelfRef.tb_llc_pending__DOT__dut__DOT__req_q[0U] = 0U;
        vlSelfRef.tb_llc_pending__DOT__dut__DOT__req_q[1U] = 0U;
        vlSelfRef.tb_llc_pending__DOT__dut__DOT__req_q[2U] = 0U;
    }
    vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_tag_pattern_gen__DOT__eoc_q 
        = ((IData)(vlSelfRef.tb_llc_pending__DOT__rst) 
           && ((IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_tag_pattern_gen__DOT__busy_q)
                ? ((8U & (IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_tag_pattern_gen__DOT__bist_q))
                    ? (IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_tag_pattern_gen__DOT__eoc_q)
                    : ((IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_tag_pattern_gen__DOT__eoc_q) 
                       | (IData)(vlSelfRef.__VdfgRegularize_h6e95ff9d_0_20)))
                : (IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_tag_pattern_gen__DOT__eoc_q)));
    if (__VdlySet__tb_llc_pending__DOT__dut__DOT__pending_way_q__v0) {
        vlSelfRef.tb_llc_pending__DOT__dut__DOT__pending_way_q[__VdlyDim0__tb_llc_pending__DOT__dut__DOT__pending_way_q__v0] 
            = __VdlyVal__tb_llc_pending__DOT__dut__DOT__pending_way_q__v0;
    }
    if (__VdlySet__tb_llc_pending__DOT__dut__DOT__pending_way_q__v1) {
        vlSelfRef.tb_llc_pending__DOT__dut__DOT__pending_way_q[0U] = 0U;
        vlSelfRef.tb_llc_pending__DOT__dut__DOT__pending_way_q[1U] = 0U;
        vlSelfRef.tb_llc_pending__DOT__dut__DOT__pending_way_q[2U] = 0U;
        vlSelfRef.tb_llc_pending__DOT__dut__DOT__pending_way_q[3U] = 0U;
    }
    vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_tag_pattern_gen__DOT__busy_q 
        = __Vdly__tb_llc_pending__DOT__dut__DOT__i_tag_pattern_gen__DOT__busy_q;
    vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_tag_pattern_gen__DOT__bist_q 
        = __Vdly__tb_llc_pending__DOT__dut__DOT__i_tag_pattern_gen__DOT__bist_q;
    if (__VdlySet__tb_llc_pending__DOT__dut__DOT__pending_index_q__v0) {
        vlSelfRef.tb_llc_pending__DOT__dut__DOT__pending_index_q[__VdlyDim0__tb_llc_pending__DOT__dut__DOT__pending_index_q__v0] 
            = __VdlyVal__tb_llc_pending__DOT__dut__DOT__pending_index_q__v0;
    }
    if (__VdlySet__tb_llc_pending__DOT__dut__DOT__pending_index_q__v1) {
        vlSelfRef.tb_llc_pending__DOT__dut__DOT__pending_index_q[0U] = 0U;
        vlSelfRef.tb_llc_pending__DOT__dut__DOT__pending_index_q[1U] = 0U;
        vlSelfRef.tb_llc_pending__DOT__dut__DOT__pending_index_q[2U] = 0U;
        vlSelfRef.tb_llc_pending__DOT__dut__DOT__pending_index_q[3U] = 0U;
    }
    if (__VdlySet__tb_llc_pending__DOT__dut__DOT__pending_tag_q__v0) {
        vlSelfRef.tb_llc_pending__DOT__dut__DOT__pending_tag_q[__VdlyDim0__tb_llc_pending__DOT__dut__DOT__pending_tag_q__v0] 
            = __VdlyVal__tb_llc_pending__DOT__dut__DOT__pending_tag_q__v0;
    }
    if (__VdlySet__tb_llc_pending__DOT__dut__DOT__pending_tag_q__v1) {
        vlSelfRef.tb_llc_pending__DOT__dut__DOT__pending_tag_q[0U] = 0ULL;
        vlSelfRef.tb_llc_pending__DOT__dut__DOT__pending_tag_q[1U] = 0ULL;
        vlSelfRef.tb_llc_pending__DOT__dut__DOT__pending_tag_q[2U] = 0ULL;
        vlSelfRef.tb_llc_pending__DOT__dut__DOT__pending_tag_q[3U] = 0ULL;
    }
    if (__VdlySet__tb_llc_pending__DOT__dut__DOT__gen_tag_macros__BRA__0__KET____DOT__i_tag_store__DOT__sram__v0) {
        vlSelfRef.tb_llc_pending__DOT__dut__DOT__gen_tag_macros__BRA__0__KET____DOT__i_tag_store__DOT__sram[__VdlyDim0__tb_llc_pending__DOT__dut__DOT__gen_tag_macros__BRA__0__KET____DOT__i_tag_store__DOT__sram__v0] 
            = __VdlyVal__tb_llc_pending__DOT__dut__DOT__gen_tag_macros__BRA__0__KET____DOT__i_tag_store__DOT__sram__v0;
    }
    vlSelfRef.tb_llc_pending__DOT__dut__DOT__pending_ack_q 
        = __Vdly__tb_llc_pending__DOT__dut__DOT__pending_ack_q;
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_3 = (1U 
                                                & (~ 
                                                   ((IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_tag_pattern_gen__DOT__i_index_cnt__DOT__i_counter__DOT__counter_q) 
                                                    >> 3U)));
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0 = (1U 
                                                & (~ 
                                                   ((IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_tag_pattern_gen__DOT__bist_q) 
                                                    >> 3U)));
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_2 = (1U 
                                                & (~ (IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_tag_pattern_gen__DOT__bist_q)));
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_20 = (IData)(
                                                        (6U 
                                                         == 
                                                         (7U 
                                                          & (IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_tag_pattern_gen__DOT__bist_q))));
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_21 = (1U 
                                                 & ((~ (IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_tag_pattern_gen__DOT__bist_q)) 
                                                    & (~ 
                                                       ((IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_tag_pattern_gen__DOT__i_index_cnt__DOT__i_counter__DOT__counter_q) 
                                                        >> 3U))));
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_19 = ((~ 
                                                  ((IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_tag_pattern_gen__DOT__bist_q) 
                                                   >> 3U)) 
                                                 & (IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_tag_pattern_gen__DOT__busy_q));
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_22 = (1U 
                                                 & ((~ 
                                                     ((IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_tag_pattern_gen__DOT__bist_q) 
                                                      >> 1U)) 
                                                    & (~ 
                                                       ((IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_tag_pattern_gen__DOT__i_index_cnt__DOT__i_counter__DOT__counter_q) 
                                                        >> 3U))));
    vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__a_drain 
        = ((~ (IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__b_full_q)) 
           & (IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__a_full_q));
    vlSelfRef.tb_llc_pending__DOT__dut__DOT__res_ready 
        = (1U & (~ ((IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__a_full_q) 
                    & (IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__b_full_q))));
    vlSelfRef.tb_llc_pending__DOT__dut__DOT__ram_rvalid 
        = ((IData)(vlSelfRef.tb_llc_pending__DOT__rst) 
           && (IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT____Vcellinp__gen_tag_macros__BRA__0__KET____DOT__i_shift_reg_rvalid__d_i));
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_9 = ((IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__maint_pending_q) 
                                                & (IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__maint_result_q));
    vlSelfRef.tb_llc_pending__DOT__dut__DOT__gen_pattern 
        = (0x07ffffffffffffffULL & ((- (QData)((IData)(
                                                       ((IData)(vlSelfRef.__VdfgRegularize_h6e95ff9d_0_19) 
                                                        & (2U 
                                                           == 
                                                           (6U 
                                                            & (IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_tag_pattern_gen__DOT__bist_q))))))) 
                                    & (- (QData)((IData)(
                                                         (1U 
                                                          & (~ 
                                                             ((IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_tag_pattern_gen__DOT__i_index_cnt__DOT__i_counter__DOT__counter_q) 
                                                              >> 3U))))))));
    vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_tag_pattern_gen__DOT__en_cnt 
        = ((IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_tag_pattern_gen__DOT__busy_q) 
           & ((~ ((IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_tag_pattern_gen__DOT__bist_q) 
                  >> 3U)) & ((4U & (IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_tag_pattern_gen__DOT__bist_q))
                              ? (IData)(vlSelfRef.__VdfgRegularize_h6e95ff9d_0_22)
                              : (~ ((IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_tag_pattern_gen__DOT__i_index_cnt__DOT__i_counter__DOT__counter_q) 
                                    >> 3U)))));
    vlSelfRef.tb_llc_pending__DOT__dut__DOT__pending_write_q 
        = __Vdly__tb_llc_pending__DOT__dut__DOT__pending_write_q;
    vlSelfRef.tb_llc_pending__DOT__dut__DOT__pending_read_q 
        = __Vdly__tb_llc_pending__DOT__dut__DOT__pending_read_q;
    vlSelfRef.tb_llc_pending__DOT__dut__DOT__pending_full 
        = (1U & ((IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__pending_valid_q) 
                 >> (IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__pending_write_q)));
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_10 = (1U 
                                                 & (((IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__pending_valid_q) 
                                                     & (IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__pending_done_q)) 
                                                    >> (IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__pending_read_q)));
    vlSelfRef.tb_llc_pending__DOT__dut__DOT__busy_d 
        = (1U & (~ (IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__busy_q)));
    vlSelfRef.tb_llc_pending__DOT__dut__DOT__maint_finish 
        = ((~ (IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__busy_q)) 
           & (IData)(vlSelfRef.__VdfgRegularize_h6e95ff9d_0_9));
    vlSelfRef.tb_llc_pending__DOT__dut__DOT__bist_valid 
        = ((IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__busy_q) 
           & ((~ vlSelfRef.tb_llc_pending__DOT__dut__DOT__req_q[2U]) 
              & ((~ (vlSelfRef.tb_llc_pending__DOT__dut__DOT__req_q[2U] 
                     >> 1U)) & (IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__ram_rvalid))));
    vlSelfRef.tb_llc_pending__DOT__dut__DOT__hit = 
        ((vlSelfRef.tb_llc_pending__DOT__dut__DOT__req_q[1U] 
          >> 0x0000001fU) & ((0x01ffffffffffffffULL 
                              == (0x01ffffffffffffffULL 
                                  & (~ (((0U == (3U 
                                                 & vlSelfRef.tb_llc_pending__DOT__dut__DOT__req_q[2U]))
                                          ? vlSelfRef.tb_llc_pending__DOT__dut__DOT__bist_pattern
                                          : (((QData)((IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__req_q[1U])) 
                                              << 0x0000003dU) 
                                             | (((QData)((IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__req_q[1U])) 
                                                 << 0x0000001dU) 
                                                | ((QData)((IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__req_q[0U])) 
                                                   >> 3U)))) 
                                        ^ vlSelfRef.tb_llc_pending__DOT__dut__DOT__gen_tag_macros__BRA__0__KET____DOT__i_tag_store__DOT__rdata_q)))) 
                             & (IData)((vlSelfRef.tb_llc_pending__DOT__dut__DOT__gen_tag_macros__BRA__0__KET____DOT__i_tag_store__DOT__rdata_q 
                                        >> 0x0000003aU))));
    vlSelfRef.tb_llc_pending__DOT__dut__DOT__pending_pop 
        = (((~ (IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__busy_q)) 
            | ((IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__pending_full) 
               & (2U == vlSelfRef.tb_llc_pending__DOT__dut__DOT__req_q[2U]))) 
           & ((~ (IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__maint_finish)) 
              & (IData)(vlSelfRef.__VdfgRegularize_h6e95ff9d_0_10)));
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_7 = ((~ (IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__bist_valid)) 
                                                & ((IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_tag_pattern_gen__DOT__i_index_cnt__DOT__i_counter__DOT__counter_q) 
                                                   >> 3U));
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_17 = ((4U 
                                                  & ((IData)(
                                                             (vlSelfRef.tb_llc_pending__DOT__dut__DOT__gen_tag_macros__BRA__0__KET____DOT__i_tag_store__DOT__rdata_q 
                                                              >> 0x00000039U)) 
                                                     << 2U)) 
                                                 | ((2U 
                                                     & ((IData)(
                                                                (vlSelfRef.tb_llc_pending__DOT__dut__DOT__gen_tag_macros__BRA__0__KET____DOT__i_tag_store__DOT__rdata_q 
                                                                 >> 0x0000003aU)) 
                                                        << 1U)) 
                                                    | ((IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__busy_q) 
                                                       & ((vlSelfRef.tb_llc_pending__DOT__dut__DOT__req_q[2U] 
                                                           >> 1U) 
                                                          & ((~ vlSelfRef.tb_llc_pending__DOT__dut__DOT__req_q[2U]) 
                                                             & ((~ (IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__hit)) 
                                                                & ((IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__ram_rvalid) 
                                                                   | (IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__ram_rvalid_q))))))));
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_4 = (1U 
                                                & ((1U 
                                                    & (IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_tag_pattern_gen__DOT__bist_q))
                                                    ? (IData)(vlSelfRef.__VdfgRegularize_h6e95ff9d_0_7)
                                                    : 
                                                   ((IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_tag_pattern_gen__DOT__i_index_cnt__DOT__i_counter__DOT__counter_q) 
                                                    >> 3U)));
    vlSelfRef.tb_llc_pending__DOT__dut__DOT__res = 
        (((2U == (3U & vlSelfRef.tb_llc_pending__DOT__dut__DOT__req_q[2U]))
           ? (((QData)((IData)(((IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__hit)
                                 ? (IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__hit)
                                 : Vtb_llc_pending__ConstPool__TABLE_hc820fc1c_0
                                [vlSelfRef.__VdfgRegularize_h6e95ff9d_0_17]))) 
               << 0x0000003bU) | (((QData)((IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__hit)) 
                                   << 0x0000003aU) 
                                  | (((QData)((IData)(
                                                      ((~ (IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__hit)) 
                                                       & Vtb_llc_pending__ConstPool__TABLE_hdb06591d_0
                                                       [vlSelfRef.__VdfgRegularize_h6e95ff9d_0_17]))) 
                                      << 0x00000039U) 
                                     | (0x01ffffffffffffffULL 
                                        & (vlSelfRef.tb_llc_pending__DOT__dut__DOT__gen_tag_macros__BRA__0__KET____DOT__i_tag_store__DOT__rdata_q 
                                           & (- (QData)((IData)(
                                                                (1U 
                                                                 & (~ (IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__hit)))))))))))
           : ((3U == (3U & vlSelfRef.tb_llc_pending__DOT__dut__DOT__req_q[2U]))
               ? (((QData)((IData)((3U & (- (IData)((IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__hit)))))) 
                   << 0x0000003aU) | (((QData)((IData)(
                                                       ((IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__hit) 
                                                        & ((IData)(
                                                                   (vlSelfRef.tb_llc_pending__DOT__dut__DOT__gen_tag_macros__BRA__0__KET____DOT__i_tag_store__DOT__rdata_q 
                                                                    >> 0x00000039U)) 
                                                           & (2U 
                                                              != 
                                                              (3U 
                                                               & vlSelfRef.tb_llc_pending__DOT__dut__DOT__req_q[0U])))))) 
                                       << 0x00000039U) 
                                      | (0x01ffffffffffffffULL 
                                         & (((QData)((IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__req_q[1U])) 
                                             << 0x0000001dU) 
                                            | ((QData)((IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__req_q[0U])) 
                                               >> 3U)))))
               : ((((QData)((IData)((vlSelfRef.tb_llc_pending__DOT__dut__DOT__req_q[1U] 
                                     >> 0x0000001fU))) 
                    << 0x0000003bU) | (((QData)((IData)(
                                                        (0x0600000000000000ULL 
                                                         == 
                                                         (0x0600000000000000ULL 
                                                          & vlSelfRef.tb_llc_pending__DOT__dut__DOT__gen_tag_macros__BRA__0__KET____DOT__i_tag_store__DOT__rdata_q)))) 
                                        << 0x00000039U) 
                                       | (0x01ffffffffffffffULL 
                                          & vlSelfRef.tb_llc_pending__DOT__dut__DOT__gen_tag_macros__BRA__0__KET____DOT__i_tag_store__DOT__rdata_q))) 
                  & (- (QData)((IData)((1U == (3U & vlSelfRef.tb_llc_pending__DOT__dut__DOT__req_q[2U])))))))) 
         & (- (QData)((IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__busy_q))));
}

void Vtb_llc_pending___024root___timing_ready(Vtb_llc_pending___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_llc_pending___024root___timing_ready\n"); );
    Vtb_llc_pending__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if ((4ULL & vlSelfRef.__VactTriggered[0U])) {
        vlSelfRef.__VtrigSched_h3cf2b702__0.ready("@(negedge tb_llc_pending.clk)");
    }
    if ((1ULL & vlSelfRef.__VactTriggered[0U])) {
        vlSelfRef.__VtrigSched_h3cf2b645__0.ready("@(posedge tb_llc_pending.clk)");
    }
    if ((8ULL & vlSelfRef.__VactTriggered[0U])) {
        vlSelfRef.__VtrigSched_h84e4166d__0.ready("@( tb_llc_pending.dut.i_tag_pattern_gen.eoc_q)");
    }
    if ((0x0000000000000010ULL & vlSelfRef.__VactTriggered[0U])) {
        vlSelfRef.__VtrigSched_hdc8bdab8__0.ready("@( (4'h0 == tb_llc_pending.dut.pending_valid_q))");
    }
}

void Vtb_llc_pending___024root___timing_resume(Vtb_llc_pending___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_llc_pending___024root___timing_resume\n"); );
    Vtb_llc_pending__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    vlSelfRef.__VtrigSched_h3cf2b702__0.moveToResumeQueue(
                                                          "@(negedge tb_llc_pending.clk)");
    vlSelfRef.__VtrigSched_h3cf2b645__0.moveToResumeQueue(
                                                          "@(posedge tb_llc_pending.clk)");
    vlSelfRef.__VtrigSched_h84e4166d__0.moveToResumeQueue(
                                                          "@( tb_llc_pending.dut.i_tag_pattern_gen.eoc_q)");
    vlSelfRef.__VtrigSched_hdc8bdab8__0.moveToResumeQueue(
                                                          "@( (4'h0 == tb_llc_pending.dut.pending_valid_q))");
    vlSelfRef.__VtrigSched_h3cf2b702__0.resume("@(negedge tb_llc_pending.clk)");
    vlSelfRef.__VtrigSched_h3cf2b645__0.resume("@(posedge tb_llc_pending.clk)");
    vlSelfRef.__VtrigSched_h84e4166d__0.resume("@( tb_llc_pending.dut.i_tag_pattern_gen.eoc_q)");
    vlSelfRef.__VtrigSched_hdc8bdab8__0.resume("@( (4'h0 == tb_llc_pending.dut.pending_valid_q))");
    if ((0x0000000000000020ULL & vlSelfRef.__VactTriggered[0U])) {
        vlSelfRef.__VdlySched.resume();
    }
}

void Vtb_llc_pending___024root___trigger_orInto__act_vec_vec(VlUnpacked<QData/*63:0*/, 1> &out, const VlUnpacked<QData/*63:0*/, 1> &in) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_llc_pending___024root___trigger_orInto__act_vec_vec\n"); );
    // Locals
    IData/*31:0*/ n;
    // Body
    n = 0U;
    do {
        out[n] = (out[n] | in[n]);
        n = ((IData)(1U) + n);
    } while ((0U >= n));
}

void Vtb_llc_pending___024root___trigger_clear__act(VlUnpacked<QData/*63:0*/, 1> &out) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_llc_pending___024root___trigger_clear__act\n"); );
    // Locals
    IData/*31:0*/ n;
    // Body
    n = 0U;
    do {
        out[n] = 0ULL;
        n = ((IData)(1U) + n);
    } while ((1U > n));
}

void Vtb_llc_pending___024root____VbeforeTrig_h3cf2b702__0(Vtb_llc_pending___024root* vlSelf, const char* __VeventDescription) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_llc_pending___024root____VbeforeTrig_h3cf2b702__0\n"); );
    Vtb_llc_pending__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    VlUnpacked<QData/*63:0*/, 1> __VTmp;
    // Body
    __VTmp[0U] = (QData)((IData)(((((~ (IData)(vlSelfRef.tb_llc_pending__DOT__clk)) 
                                    & (IData)(vlSelfRef.__Vtrigprevexpr___TOP__tb_llc_pending__DOT__clk__0)) 
                                   << 2U) | ((IData)(vlSelfRef.tb_llc_pending__DOT__clk) 
                                             & (~ (IData)(vlSelfRef.__Vtrigprevexpr___TOP__tb_llc_pending__DOT__clk__0))))));
    vlSelfRef.__Vtrigprevexpr___TOP__tb_llc_pending__DOT__clk__0 
        = vlSelfRef.tb_llc_pending__DOT__clk;
    if ((1ULL & __VTmp[0U])) {
        vlSelfRef.__VtrigSched_h3cf2b645__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h3cf2b645__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h3cf2b645__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h3cf2b645__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h3cf2b645__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h3cf2b645__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h3cf2b645__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h3cf2b645__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h3cf2b645__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h3cf2b645__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h3cf2b645__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h3cf2b645__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h3cf2b645__0.ready(__VeventDescription);
    }
    if ((4ULL & __VTmp[0U])) {
        vlSelfRef.__VtrigSched_h3cf2b702__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h3cf2b702__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h3cf2b702__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h3cf2b702__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h3cf2b702__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h3cf2b702__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h3cf2b702__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h3cf2b702__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h3cf2b702__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h3cf2b702__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h3cf2b702__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h3cf2b702__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h3cf2b702__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h3cf2b702__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h3cf2b702__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h3cf2b702__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h3cf2b702__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h3cf2b702__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h3cf2b702__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h3cf2b702__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h3cf2b702__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h3cf2b702__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h3cf2b702__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h3cf2b702__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h3cf2b702__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h3cf2b702__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h3cf2b702__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h3cf2b702__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h3cf2b702__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h3cf2b702__0.ready(__VeventDescription);
    }
    vlSelfRef.__VactTriggeredAcc[0U] = (vlSelfRef.__VactTriggeredAcc[0U] 
                                        | __VTmp[0U]);
}

void Vtb_llc_pending___024root____VbeforeTrig_h3cf2b645__0(Vtb_llc_pending___024root* vlSelf, const char* __VeventDescription) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_llc_pending___024root____VbeforeTrig_h3cf2b645__0\n"); );
    Vtb_llc_pending__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    VlUnpacked<QData/*63:0*/, 1> __VTmp;
    // Body
    __VTmp[0U] = (QData)((IData)(((((~ (IData)(vlSelfRef.tb_llc_pending__DOT__clk)) 
                                    & (IData)(vlSelfRef.__Vtrigprevexpr___TOP__tb_llc_pending__DOT__clk__0)) 
                                   << 2U) | ((IData)(vlSelfRef.tb_llc_pending__DOT__clk) 
                                             & (~ (IData)(vlSelfRef.__Vtrigprevexpr___TOP__tb_llc_pending__DOT__clk__0))))));
    vlSelfRef.__Vtrigprevexpr___TOP__tb_llc_pending__DOT__clk__0 
        = vlSelfRef.tb_llc_pending__DOT__clk;
    if ((1ULL & __VTmp[0U])) {
        vlSelfRef.__VtrigSched_h3cf2b645__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h3cf2b645__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h3cf2b645__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h3cf2b645__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h3cf2b645__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h3cf2b645__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h3cf2b645__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h3cf2b645__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h3cf2b645__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h3cf2b645__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h3cf2b645__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h3cf2b645__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h3cf2b645__0.ready(__VeventDescription);
    }
    if ((4ULL & __VTmp[0U])) {
        vlSelfRef.__VtrigSched_h3cf2b702__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h3cf2b702__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h3cf2b702__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h3cf2b702__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h3cf2b702__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h3cf2b702__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h3cf2b702__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h3cf2b702__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h3cf2b702__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h3cf2b702__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h3cf2b702__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h3cf2b702__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h3cf2b702__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h3cf2b702__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h3cf2b702__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h3cf2b702__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h3cf2b702__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h3cf2b702__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h3cf2b702__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h3cf2b702__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h3cf2b702__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h3cf2b702__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h3cf2b702__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h3cf2b702__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h3cf2b702__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h3cf2b702__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h3cf2b702__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h3cf2b702__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h3cf2b702__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h3cf2b702__0.ready(__VeventDescription);
    }
    vlSelfRef.__VactTriggeredAcc[0U] = (vlSelfRef.__VactTriggeredAcc[0U] 
                                        | __VTmp[0U]);
}

void Vtb_llc_pending___024root____VbeforeTrig_h84e4166d__0(Vtb_llc_pending___024root* vlSelf, const char* __VeventDescription) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_llc_pending___024root____VbeforeTrig_h84e4166d__0\n"); );
    Vtb_llc_pending__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    VlUnpacked<QData/*63:0*/, 1> __VTmp;
    // Body
    __VTmp[0U] = (QData)((IData)((((IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_tag_pattern_gen__DOT__eoc_q) 
                                   != (IData)(vlSelfRef.__Vtrigprevexpr___TOP__tb_llc_pending__DOT__dut__DOT__i_tag_pattern_gen__DOT__eoc_q__0)) 
                                  << 3U)));
    vlSelfRef.__Vtrigprevexpr___TOP__tb_llc_pending__DOT__dut__DOT__i_tag_pattern_gen__DOT__eoc_q__0 
        = vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_tag_pattern_gen__DOT__eoc_q;
    if ((8ULL & __VTmp[0U])) {
        vlSelfRef.__VtrigSched_h84e4166d__0.ready(__VeventDescription);
    }
    vlSelfRef.__VactTriggeredAcc[0U] = (vlSelfRef.__VactTriggeredAcc[0U] 
                                        | __VTmp[0U]);
}

void Vtb_llc_pending___024root____VbeforeTrig_hdc8bdab8__0(Vtb_llc_pending___024root* vlSelf, const char* __VeventDescription) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_llc_pending___024root____VbeforeTrig_hdc8bdab8__0\n"); );
    Vtb_llc_pending__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    VlUnpacked<QData/*63:0*/, 1> __VTmp;
    CData/*0:0*/ __Vtrigprevexpr_h88bb5eb1__0;
    __Vtrigprevexpr_h88bb5eb1__0 = 0;
    // Body
    __Vtrigprevexpr_h88bb5eb1__0 = (0U == (IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__pending_valid_q));
    __VTmp[0U] = (QData)((IData)((((IData)(__Vtrigprevexpr_h88bb5eb1__0) 
                                   != (IData)(vlSelfRef.__Vtrigprevexpr_h88bb5eb1__1)) 
                                  << 4U)));
    vlSelfRef.__Vtrigprevexpr_h88bb5eb1__1 = __Vtrigprevexpr_h88bb5eb1__0;
    if ((0x0000000000000010ULL & __VTmp[0U])) {
        vlSelfRef.__VtrigSched_hdc8bdab8__0.ready(__VeventDescription);
    }
    vlSelfRef.__VactTriggeredAcc[0U] = (vlSelfRef.__VactTriggeredAcc[0U] 
                                        | __VTmp[0U]);
}

#ifdef VL_DEBUG
void Vtb_llc_pending___024root___eval_debug_assertions(Vtb_llc_pending___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_llc_pending___024root___eval_debug_assertions\n"); );
    Vtb_llc_pending__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
}
#endif  // VL_DEBUG
