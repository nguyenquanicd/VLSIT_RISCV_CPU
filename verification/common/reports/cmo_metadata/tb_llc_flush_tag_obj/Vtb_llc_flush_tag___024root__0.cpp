// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vtb_llc_flush_tag.h for the primary calling header

#include "Vtb_llc_flush_tag__pch.h"

VlCoroutine Vtb_llc_flush_tag___024root___eval_initial__TOP__Vtiming__0(Vtb_llc_flush_tag___024root* vlSelf);
VlCoroutine Vtb_llc_flush_tag___024root___eval_initial__TOP__Vtiming__1(Vtb_llc_flush_tag___024root* vlSelf);
VlCoroutine Vtb_llc_flush_tag___024root___eval_initial__TOP__Vtiming__2(Vtb_llc_flush_tag___024root* vlSelf);

void Vtb_llc_flush_tag___024root___eval_initial(Vtb_llc_flush_tag___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_llc_flush_tag___024root___eval_initial\n"); );
    Vtb_llc_flush_tag__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    Vtb_llc_flush_tag___024root___eval_initial__TOP__Vtiming__0(vlSelf);
    Vtb_llc_flush_tag___024root___eval_initial__TOP__Vtiming__1(vlSelf);
    Vtb_llc_flush_tag___024root___eval_initial__TOP__Vtiming__2(vlSelf);
}

void Vtb_llc_flush_tag___024root___eval_sample(Vtb_llc_flush_tag___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_llc_flush_tag___024root___eval_sample\n"); );
    Vtb_llc_flush_tag__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    vlSelfRef.__Vsampled_TOP__tb_llc_flush_tag__DOT__writer__DOT__i_r_data_fifo__DOT__status_cnt_q 
        = vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__i_r_data_fifo__DOT__status_cnt_q;
    vlSelfRef.__Vsampled_TOP__tb_llc_flush_tag__DOT__writer__DOT__fifo_push 
        = vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__fifo_push;
    vlSelfRef.__Vsampled_TOP__tb_llc_flush_tag__DOT__writer__DOT__fifo_empty 
        = vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__fifo_empty;
}

#ifdef VL_DEBUG
VL_ATTR_COLD void Vtb_llc_flush_tag___024root___dump_triggers__ico(const VlUnpacked<QData/*63:0*/, 1> &triggers, const std::string &tag);
#endif  // VL_DEBUG

bool Vtb_llc_flush_tag___024root___eval_ico(Vtb_llc_flush_tag___024root* vlSelf, CData/*0:0*/ firstIteration) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_llc_flush_tag___024root___eval_ico\n"); );
    Vtb_llc_flush_tag__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    vlSelfRef.__VicoTriggered[0U] = ((0xfffffffffffffffeULL 
                                      & vlSelfRef.__VicoTriggered[0U]) 
                                     | (IData)((IData)(firstIteration)));
#ifdef VL_DEBUG
    if (VL_UNLIKELY(vlSymsp->_vm_contextp__->debug())) {
        Vtb_llc_flush_tag___024root___dump_triggers__ico(vlSelfRef.__VicoTriggered, "ico"s);
    }
#endif
    return (0U);
}

void Vtb_llc_flush_tag___024root___timing_ready(Vtb_llc_flush_tag___024root* vlSelf);
void Vtb_llc_flush_tag___024root___trigger_orInto__act_vec_vec(VlUnpacked<QData/*63:0*/, 1> &out, const VlUnpacked<QData/*63:0*/, 1> &in);
#ifdef VL_DEBUG
VL_ATTR_COLD void Vtb_llc_flush_tag___024root___dump_triggers__act(const VlUnpacked<QData/*63:0*/, 1> &triggers, const std::string &tag);
#endif  // VL_DEBUG
bool Vtb_llc_flush_tag___024root___trigger_anySet__act(const VlUnpacked<QData/*63:0*/, 1> &in);
void Vtb_llc_flush_tag___024root___timing_resume(Vtb_llc_flush_tag___024root* vlSelf);
void Vtb_llc_flush_tag___024root___act_comb__TOP__0(Vtb_llc_flush_tag___024root* vlSelf);

bool Vtb_llc_flush_tag___024root___eval_act(Vtb_llc_flush_tag___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_llc_flush_tag___024root___eval_act\n"); );
    Vtb_llc_flush_tag__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    CData/*0:0*/ __VactExecute;
    // Body
    {
        // Inlined CFunc: _eval_triggers_vec__act
        CData/*0:0*/ __Vinline_0__eval_triggers_vec__act___Vtrigprevexpr_h4d792359__0;
        __Vinline_0__eval_triggers_vec__act___Vtrigprevexpr_h4d792359__0 = 0;
        CData/*0:0*/ __Vinline_0__eval_triggers_vec__act___Vtrigprevexpr_h4d7acfdc__0;
        __Vinline_0__eval_triggers_vec__act___Vtrigprevexpr_h4d7acfdc__0 = 0;
        __Vinline_0__eval_triggers_vec__act___Vtrigprevexpr_h4d792359__0 
            = (2U == vlSelfRef.tb_llc_flush_tag__DOT__beats);
        __Vinline_0__eval_triggers_vec__act___Vtrigprevexpr_h4d7acfdc__0 
            = (4U == vlSelfRef.tb_llc_flush_tag__DOT__beats);
        vlSelfRef.__VactTriggered[0U] = (QData)((IData)(
                                                        ((((__Vinline_0__eval_triggers_vec__act___Vtrigprevexpr_h4d7acfdc__0 
                                                            != (IData)(vlSelfRef.__Vtrigprevexpr_h4d7acfdc__1)) 
                                                           << 6U) 
                                                          | ((vlSelfRef.__VdlySched.awaitingCurrentTime() 
                                                              << 5U) 
                                                             | ((__Vinline_0__eval_triggers_vec__act___Vtrigprevexpr_h4d792359__0 
                                                                 != (IData)(vlSelfRef.__Vtrigprevexpr_h4d792359__1)) 
                                                                << 4U))) 
                                                         | (((((IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__eoc_q) 
                                                               != (IData)(vlSelfRef.__Vtrigprevexpr___TOP__tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__eoc_q__0)) 
                                                              << 3U) 
                                                             | (((~ (IData)(vlSelfRef.tb_llc_flush_tag__DOT__clk)) 
                                                                 & (IData)(vlSelfRef.__Vtrigprevexpr___TOP__tb_llc_flush_tag__DOT__clk__0)) 
                                                                << 2U)) 
                                                            | ((((~ (IData)(vlSelfRef.tb_llc_flush_tag__DOT__rst)) 
                                                                 & (IData)(vlSelfRef.__Vtrigprevexpr___TOP__tb_llc_flush_tag__DOT__rst__0)) 
                                                                << 1U) 
                                                               | ((IData)(vlSelfRef.tb_llc_flush_tag__DOT__clk) 
                                                                  & (~ (IData)(vlSelfRef.__Vtrigprevexpr___TOP__tb_llc_flush_tag__DOT__clk__0))))))));
        vlSelfRef.__Vtrigprevexpr___TOP__tb_llc_flush_tag__DOT__clk__0 
            = vlSelfRef.tb_llc_flush_tag__DOT__clk;
        vlSelfRef.__Vtrigprevexpr___TOP__tb_llc_flush_tag__DOT__rst__0 
            = vlSelfRef.tb_llc_flush_tag__DOT__rst;
        vlSelfRef.__Vtrigprevexpr___TOP__tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__eoc_q__0 
            = vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__eoc_q;
        vlSelfRef.__Vtrigprevexpr_h4d792359__1 = __Vinline_0__eval_triggers_vec__act___Vtrigprevexpr_h4d792359__0;
        vlSelfRef.__Vtrigprevexpr_h4d7acfdc__1 = __Vinline_0__eval_triggers_vec__act___Vtrigprevexpr_h4d7acfdc__0;
    }
    Vtb_llc_flush_tag___024root___timing_ready(vlSelf);
    Vtb_llc_flush_tag___024root___trigger_orInto__act_vec_vec(vlSelfRef.__VactTriggered, vlSelfRef.__VactTriggeredAcc);
#ifdef VL_DEBUG
    if (VL_UNLIKELY(vlSymsp->_vm_contextp__->debug())) {
        Vtb_llc_flush_tag___024root___dump_triggers__act(vlSelfRef.__VactTriggered, "act"s);
    }
#endif
    Vtb_llc_flush_tag___024root___trigger_orInto__act_vec_vec(vlSelfRef.__VnbaTriggered, vlSelfRef.__VactTriggered);
    __VactExecute = Vtb_llc_flush_tag___024root___trigger_anySet__act(vlSelfRef.__VactTriggered);
    if (__VactExecute) {
        vlSelfRef.__VactTriggeredAcc.fill(0ULL);
        Vtb_llc_flush_tag___024root___timing_resume(vlSelf);
        {
            // Inlined CFunc: _eval_body__act
            if ((0x000000000000007dULL & vlSelfRef.__VactTriggered[0U])) {
                Vtb_llc_flush_tag___024root___act_comb__TOP__0(vlSelf);
            }
        }
    }
    return (__VactExecute);
}

bool Vtb_llc_flush_tag___024root___eval_inact(Vtb_llc_flush_tag___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_llc_flush_tag___024root___eval_inact\n"); );
    Vtb_llc_flush_tag__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    CData/*0:0*/ __VinactExecute;
    // Body
    __VinactExecute = vlSelfRef.__VdlySched.awaitingZeroDelay();
    if (__VinactExecute) {
        VL_FATAL_MT("tb_llc_flush_tag.sv", 2, "", "ZERODLY: Design Verilated with '--no-sched-zero-delay', but #0 delay executed at runtime");
    }
    return (__VinactExecute);
}

void Vtb_llc_flush_tag___024root___nba_sequent__TOP__0(Vtb_llc_flush_tag___024root* vlSelf);
void Vtb_llc_flush_tag___024root___nba_sequent__TOP__1(Vtb_llc_flush_tag___024root* vlSelf);
void Vtb_llc_flush_tag___024root___nba_comb__TOP__0(Vtb_llc_flush_tag___024root* vlSelf);
void Vtb_llc_flush_tag___024root___nba_comb__TOP__1(Vtb_llc_flush_tag___024root* vlSelf);
void Vtb_llc_flush_tag___024root___trigger_clear__act(VlUnpacked<QData/*63:0*/, 1> &out);

bool Vtb_llc_flush_tag___024root___eval_nba(Vtb_llc_flush_tag___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_llc_flush_tag___024root___eval_nba\n"); );
    Vtb_llc_flush_tag__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    CData/*0:0*/ __VnbaExecute;
    // Body
    __VnbaExecute = Vtb_llc_flush_tag___024root___trigger_anySet__act(vlSelfRef.__VnbaTriggered);
    if (__VnbaExecute) {
        {
            // Inlined CFunc: _eval_body__nba
            if ((1ULL & vlSelfRef.__VnbaTriggered[0U])) {
                Vtb_llc_flush_tag___024root___nba_sequent__TOP__0(vlSelf);
            }
            if ((3ULL & vlSelfRef.__VnbaTriggered[0U])) {
                Vtb_llc_flush_tag___024root___nba_sequent__TOP__1(vlSelf);
            }
            if ((3ULL & vlSelfRef.__VnbaTriggered[0U])) {
                Vtb_llc_flush_tag___024root___nba_comb__TOP__0(vlSelf);
            }
            if ((0x000000000000007fULL & vlSelfRef.__VnbaTriggered[0U])) {
                Vtb_llc_flush_tag___024root___nba_comb__TOP__1(vlSelf);
            }
        }
        Vtb_llc_flush_tag___024root___trigger_clear__act(vlSelfRef.__VnbaTriggered);
    }
    return (__VnbaExecute);
}

bool Vtb_llc_flush_tag___024root___eval_obs(Vtb_llc_flush_tag___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_llc_flush_tag___024root___eval_obs\n"); );
    Vtb_llc_flush_tag__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    return (0U);
}

bool Vtb_llc_flush_tag___024root___eval_react(Vtb_llc_flush_tag___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_llc_flush_tag___024root___eval_react\n"); );
    Vtb_llc_flush_tag__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    return (0U);
}

void Vtb_llc_flush_tag___024root___eval_postponed(Vtb_llc_flush_tag___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_llc_flush_tag___024root___eval_postponed\n"); );
    Vtb_llc_flush_tag__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
}

void Vtb_llc_flush_tag___024root____VbeforeTrig_hb04eaffa__0(Vtb_llc_flush_tag___024root* vlSelf, const char* __VeventDescription);
void Vtb_llc_flush_tag___024root____VbeforeTrig_hb04eaf3d__0(Vtb_llc_flush_tag___024root* vlSelf, const char* __VeventDescription);
void Vtb_llc_flush_tag___024root____VbeforeTrig_ha4acadb1__0(Vtb_llc_flush_tag___024root* vlSelf, const char* __VeventDescription);
void Vtb_llc_flush_tag___024root____VbeforeTrig_hd94d9ee0__0(Vtb_llc_flush_tag___024root* vlSelf, const char* __VeventDescription);
void Vtb_llc_flush_tag___024root____VbeforeTrig_hd94c4b5f__0(Vtb_llc_flush_tag___024root* vlSelf, const char* __VeventDescription);

VlCoroutine Vtb_llc_flush_tag___024root___eval_initial__TOP__Vtiming__0(Vtb_llc_flush_tag___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_llc_flush_tag___024root___eval_initial__TOP__Vtiming__0\n"); );
    Vtb_llc_flush_tag__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    IData/*31:0*/ tb_llc_flush_tag__DOT__unnamedblk1_1__DOT____Vrepeat0;
    tb_llc_flush_tag__DOT__unnamedblk1_1__DOT____Vrepeat0 = 0;
    IData/*31:0*/ tb_llc_flush_tag__DOT__unnamedblk1_2__DOT____Vrepeat1;
    tb_llc_flush_tag__DOT__unnamedblk1_2__DOT____Vrepeat1 = 0;
    IData/*31:0*/ tb_llc_flush_tag__DOT__unnamedblk1_3__DOT____Vrepeat2;
    tb_llc_flush_tag__DOT__unnamedblk1_3__DOT____Vrepeat2 = 0;
    IData/*31:0*/ tb_llc_flush_tag__DOT__unnamedblk1_4__DOT____Vrepeat3;
    tb_llc_flush_tag__DOT__unnamedblk1_4__DOT____Vrepeat3 = 0;
    IData/*31:0*/ tb_llc_flush_tag__DOT__unnamedblk1_5__DOT____Vrepeat4;
    tb_llc_flush_tag__DOT__unnamedblk1_5__DOT____Vrepeat4 = 0;
    CData/*1:0*/ __Vtask_tb_llc_flush_tag__DOT__send__0__mode;
    __Vtask_tb_llc_flush_tag__DOT__send__0__mode = 0;
    CData/*0:0*/ __Vtask_tb_llc_flush_tag__DOT__send__0__dirty;
    __Vtask_tb_llc_flush_tag__DOT__send__0__dirty = 0;
    CData/*1:0*/ __Vtask_tb_llc_flush_tag__DOT__send__1__mode;
    __Vtask_tb_llc_flush_tag__DOT__send__1__mode = 0;
    CData/*0:0*/ __Vtask_tb_llc_flush_tag__DOT__send__1__dirty;
    __Vtask_tb_llc_flush_tag__DOT__send__1__dirty = 0;
    CData/*0:0*/ __Vtask_tb_llc_flush_tag__DOT__receive__2__expected_hit;
    __Vtask_tb_llc_flush_tag__DOT__receive__2__expected_hit = 0;
    CData/*0:0*/ __Vtask_tb_llc_flush_tag__DOT__receive__2__expected_evict;
    __Vtask_tb_llc_flush_tag__DOT__receive__2__expected_evict = 0;
    CData/*1:0*/ __Vtask_tb_llc_flush_tag__DOT__send__3__mode;
    __Vtask_tb_llc_flush_tag__DOT__send__3__mode = 0;
    CData/*0:0*/ __Vtask_tb_llc_flush_tag__DOT__send__3__dirty;
    __Vtask_tb_llc_flush_tag__DOT__send__3__dirty = 0;
    CData/*0:0*/ __Vtask_tb_llc_flush_tag__DOT__receive__4__expected_hit;
    __Vtask_tb_llc_flush_tag__DOT__receive__4__expected_hit = 0;
    CData/*0:0*/ __Vtask_tb_llc_flush_tag__DOT__receive__4__expected_evict;
    __Vtask_tb_llc_flush_tag__DOT__receive__4__expected_evict = 0;
    CData/*1:0*/ __Vtask_tb_llc_flush_tag__DOT__send__5__mode;
    __Vtask_tb_llc_flush_tag__DOT__send__5__mode = 0;
    CData/*0:0*/ __Vtask_tb_llc_flush_tag__DOT__send__5__dirty;
    __Vtask_tb_llc_flush_tag__DOT__send__5__dirty = 0;
    CData/*0:0*/ __Vtask_tb_llc_flush_tag__DOT__receive__6__expected_hit;
    __Vtask_tb_llc_flush_tag__DOT__receive__6__expected_hit = 0;
    CData/*0:0*/ __Vtask_tb_llc_flush_tag__DOT__receive__6__expected_evict;
    __Vtask_tb_llc_flush_tag__DOT__receive__6__expected_evict = 0;
    CData/*1:0*/ __Vtask_tb_llc_flush_tag__DOT__send__7__mode;
    __Vtask_tb_llc_flush_tag__DOT__send__7__mode = 0;
    CData/*0:0*/ __Vtask_tb_llc_flush_tag__DOT__send__7__dirty;
    __Vtask_tb_llc_flush_tag__DOT__send__7__dirty = 0;
    CData/*0:0*/ __Vtask_tb_llc_flush_tag__DOT__receive__8__expected_hit;
    __Vtask_tb_llc_flush_tag__DOT__receive__8__expected_hit = 0;
    CData/*0:0*/ __Vtask_tb_llc_flush_tag__DOT__receive__8__expected_evict;
    __Vtask_tb_llc_flush_tag__DOT__receive__8__expected_evict = 0;
    CData/*1:0*/ __Vtask_tb_llc_flush_tag__DOT__send__9__mode;
    __Vtask_tb_llc_flush_tag__DOT__send__9__mode = 0;
    CData/*0:0*/ __Vtask_tb_llc_flush_tag__DOT__send__9__dirty;
    __Vtask_tb_llc_flush_tag__DOT__send__9__dirty = 0;
    CData/*0:0*/ __Vtask_tb_llc_flush_tag__DOT__receive__10__expected_hit;
    __Vtask_tb_llc_flush_tag__DOT__receive__10__expected_hit = 0;
    CData/*0:0*/ __Vtask_tb_llc_flush_tag__DOT__receive__10__expected_evict;
    __Vtask_tb_llc_flush_tag__DOT__receive__10__expected_evict = 0;
    CData/*1:0*/ __Vtask_tb_llc_flush_tag__DOT__send__11__mode;
    __Vtask_tb_llc_flush_tag__DOT__send__11__mode = 0;
    CData/*0:0*/ __Vtask_tb_llc_flush_tag__DOT__send__11__dirty;
    __Vtask_tb_llc_flush_tag__DOT__send__11__dirty = 0;
    CData/*0:0*/ __Vtask_tb_llc_flush_tag__DOT__receive__12__expected_hit;
    __Vtask_tb_llc_flush_tag__DOT__receive__12__expected_hit = 0;
    CData/*0:0*/ __Vtask_tb_llc_flush_tag__DOT__receive__12__expected_evict;
    __Vtask_tb_llc_flush_tag__DOT__receive__12__expected_evict = 0;
    CData/*1:0*/ __Vtask_tb_llc_flush_tag__DOT__send__13__mode;
    __Vtask_tb_llc_flush_tag__DOT__send__13__mode = 0;
    CData/*0:0*/ __Vtask_tb_llc_flush_tag__DOT__send__13__dirty;
    __Vtask_tb_llc_flush_tag__DOT__send__13__dirty = 0;
    CData/*0:0*/ __Vtask_tb_llc_flush_tag__DOT__receive__14__expected_hit;
    __Vtask_tb_llc_flush_tag__DOT__receive__14__expected_hit = 0;
    CData/*0:0*/ __Vtask_tb_llc_flush_tag__DOT__receive__14__expected_evict;
    __Vtask_tb_llc_flush_tag__DOT__receive__14__expected_evict = 0;
    // Body
    vlSelfRef.tb_llc_flush_tag__DOT__req[0U] = 0U;
    vlSelfRef.tb_llc_flush_tag__DOT__req[1U] = 0U;
    vlSelfRef.tb_llc_flush_tag__DOT__req[2U] = 0U;
    tb_llc_flush_tag__DOT__unnamedblk1_1__DOT____Vrepeat0 = 2U;
    while (VL_LTS_III(32, 0U, tb_llc_flush_tag__DOT__unnamedblk1_1__DOT____Vrepeat0)) {
        Vtb_llc_flush_tag___024root____VbeforeTrig_hb04eaffa__0(vlSelf, 
                                                                "@(negedge tb_llc_flush_tag.clk)");
        co_await vlSelfRef.__VtrigSched_hb04eaffa__0.trigger(0U, 
                                                             nullptr, 
                                                             "@(negedge tb_llc_flush_tag.clk)", 
                                                             "tb_llc_flush_tag.sv", 
                                                             97);
        tb_llc_flush_tag__DOT__unnamedblk1_1__DOT____Vrepeat0 
            = (tb_llc_flush_tag__DOT__unnamedblk1_1__DOT____Vrepeat0 
               - (IData)(1U));
    }
    vlSelfRef.tb_llc_flush_tag__DOT__rst = 1U;
    __Vtask_tb_llc_flush_tag__DOT__send__0__dirty = 0U;
    __Vtask_tb_llc_flush_tag__DOT__send__0__mode = 0U;
    Vtb_llc_flush_tag___024root____VbeforeTrig_hb04eaffa__0(vlSelf, 
                                                            "@(negedge tb_llc_flush_tag.clk)");
    co_await vlSelfRef.__VtrigSched_hb04eaffa__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(negedge tb_llc_flush_tag.clk)", 
                                                         "tb_llc_flush_tag.sv", 
                                                         84);
    vlSelfRef.tb_llc_flush_tag__DOT__req[0U] = (IData)(
                                                       (((QData)((IData)(
                                                                         (2U 
                                                                          | (IData)(vlSelfRef.tb_llc_flush_tag__DOT__req_index)))) 
                                                         << 0x0000003eU) 
                                                        | ((vlSelfRef.tb_llc_flush_tag__DOT__req_tag 
                                                            << 3U) 
                                                           | (QData)((IData)(
                                                                             ((IData)(__Vtask_tb_llc_flush_tag__DOT__send__0__dirty) 
                                                                              << 2U))))));
    vlSelfRef.tb_llc_flush_tag__DOT__req[1U] = (IData)(
                                                       ((((QData)((IData)(
                                                                          (2U 
                                                                           | (IData)(vlSelfRef.tb_llc_flush_tag__DOT__req_index)))) 
                                                          << 0x0000003eU) 
                                                         | ((vlSelfRef.tb_llc_flush_tag__DOT__req_tag 
                                                             << 3U) 
                                                            | (QData)((IData)(
                                                                              ((IData)(__Vtask_tb_llc_flush_tag__DOT__send__0__dirty) 
                                                                               << 2U))))) 
                                                        >> 0x00000020U));
    vlSelfRef.tb_llc_flush_tag__DOT__req[2U] = (3U 
                                                & (IData)(__Vtask_tb_llc_flush_tag__DOT__send__0__mode));
    vlSelfRef.tb_llc_flush_tag__DOT__iv = 1U;
    do {
        Vtb_llc_flush_tag___024root____VbeforeTrig_hb04eaf3d__0(vlSelf, 
                                                                "@(posedge tb_llc_flush_tag.clk)");
        co_await vlSelfRef.__VtrigSched_hb04eaf3d__0.trigger(0U, 
                                                             nullptr, 
                                                             "@(posedge tb_llc_flush_tag.clk)", 
                                                             "tb_llc_flush_tag.sv", 
                                                             85);
    } while ((1U & (~ (IData)(vlSelfRef.tb_llc_flush_tag__DOT__ir))));
    Vtb_llc_flush_tag___024root____VbeforeTrig_hb04eaffa__0(vlSelf, 
                                                            "@(negedge tb_llc_flush_tag.clk)");
    co_await vlSelfRef.__VtrigSched_hb04eaffa__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(negedge tb_llc_flush_tag.clk)", 
                                                         "tb_llc_flush_tag.sv", 
                                                         86);
    vlSelfRef.tb_llc_flush_tag__DOT__iv = 0U;
    while ((1U & (~ (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__eoc_q)))) {
        Vtb_llc_flush_tag___024root____VbeforeTrig_ha4acadb1__0(vlSelf, 
                                                                "@( tb_llc_flush_tag.dut.i_tag_pattern_gen.eoc_q)");
        co_await vlSelfRef.__VtrigSched_ha4acadb1__0.trigger(1U, 
                                                             nullptr, 
                                                             "@( tb_llc_flush_tag.dut.i_tag_pattern_gen.eoc_q)", 
                                                             "tb_llc_flush_tag.sv", 
                                                             99);
    }
    Vtb_llc_flush_tag___024root____VbeforeTrig_hb04eaffa__0(vlSelf, 
                                                            "@(negedge tb_llc_flush_tag.clk)");
    co_await vlSelfRef.__VtrigSched_hb04eaffa__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(negedge tb_llc_flush_tag.clk)", 
                                                         "tb_llc_flush_tag.sv", 
                                                         99);
    __Vtask_tb_llc_flush_tag__DOT__send__1__dirty = 1U;
    __Vtask_tb_llc_flush_tag__DOT__send__1__mode = 2U;
    Vtb_llc_flush_tag___024root____VbeforeTrig_hb04eaffa__0(vlSelf, 
                                                            "@(negedge tb_llc_flush_tag.clk)");
    co_await vlSelfRef.__VtrigSched_hb04eaffa__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(negedge tb_llc_flush_tag.clk)", 
                                                         "tb_llc_flush_tag.sv", 
                                                         84);
    vlSelfRef.tb_llc_flush_tag__DOT__req[0U] = (IData)(
                                                       (((QData)((IData)(
                                                                         (2U 
                                                                          | (IData)(vlSelfRef.tb_llc_flush_tag__DOT__req_index)))) 
                                                         << 0x0000003eU) 
                                                        | ((vlSelfRef.tb_llc_flush_tag__DOT__req_tag 
                                                            << 3U) 
                                                           | (QData)((IData)(
                                                                             ((IData)(__Vtask_tb_llc_flush_tag__DOT__send__1__dirty) 
                                                                              << 2U))))));
    vlSelfRef.tb_llc_flush_tag__DOT__req[1U] = (IData)(
                                                       ((((QData)((IData)(
                                                                          (2U 
                                                                           | (IData)(vlSelfRef.tb_llc_flush_tag__DOT__req_index)))) 
                                                          << 0x0000003eU) 
                                                         | ((vlSelfRef.tb_llc_flush_tag__DOT__req_tag 
                                                             << 3U) 
                                                            | (QData)((IData)(
                                                                              ((IData)(__Vtask_tb_llc_flush_tag__DOT__send__1__dirty) 
                                                                               << 2U))))) 
                                                        >> 0x00000020U));
    vlSelfRef.tb_llc_flush_tag__DOT__req[2U] = (3U 
                                                & (IData)(__Vtask_tb_llc_flush_tag__DOT__send__1__mode));
    vlSelfRef.tb_llc_flush_tag__DOT__iv = 1U;
    do {
        Vtb_llc_flush_tag___024root____VbeforeTrig_hb04eaf3d__0(vlSelf, 
                                                                "@(posedge tb_llc_flush_tag.clk)");
        co_await vlSelfRef.__VtrigSched_hb04eaf3d__0.trigger(0U, 
                                                             nullptr, 
                                                             "@(posedge tb_llc_flush_tag.clk)", 
                                                             "tb_llc_flush_tag.sv", 
                                                             85);
    } while ((1U & (~ (IData)(vlSelfRef.tb_llc_flush_tag__DOT__ir))));
    Vtb_llc_flush_tag___024root____VbeforeTrig_hb04eaffa__0(vlSelf, 
                                                            "@(negedge tb_llc_flush_tag.clk)");
    co_await vlSelfRef.__VtrigSched_hb04eaffa__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(negedge tb_llc_flush_tag.clk)", 
                                                         "tb_llc_flush_tag.sv", 
                                                         86);
    vlSelfRef.tb_llc_flush_tag__DOT__iv = 0U;
    __Vtask_tb_llc_flush_tag__DOT__receive__2__expected_evict = 0U;
    __Vtask_tb_llc_flush_tag__DOT__receive__2__expected_hit = 0U;
    while ((1U & (~ ((IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__a_full_q) 
                     | (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__b_full_q))))) {
        Vtb_llc_flush_tag___024root____VbeforeTrig_hb04eaffa__0(vlSelf, 
                                                                "@(negedge tb_llc_flush_tag.clk)");
        co_await vlSelfRef.__VtrigSched_hb04eaffa__0.trigger(0U, 
                                                             nullptr, 
                                                             "@(negedge tb_llc_flush_tag.clk)", 
                                                             "tb_llc_flush_tag.sv", 
                                                             89);
    }
    if (VL_UNLIKELY(((((1U & (IData)((vlSelfRef.tb_llc_flush_tag__DOT__rsp 
                                      >> 0x0000003cU))) 
                       != (IData)(__Vtask_tb_llc_flush_tag__DOT__receive__2__expected_hit)) 
                      | ((1U & (IData)((vlSelfRef.tb_llc_flush_tag__DOT__rsp 
                                        >> 0x0000003bU))) 
                         != (IData)(__Vtask_tb_llc_flush_tag__DOT__receive__2__expected_evict)))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_llc_flush_tag.sv:91: Assertion failed in %m: Unexpected lookup/flush result hit=%b evict=%b\n",5, 'M',vlSymsp->name(),"tb_llc_flush_tag.receive", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000)
                     , '#',1,(1U & (IData)((vlSelfRef.tb_llc_flush_tag__DOT__rsp 
                                            >> 0x0000003cU)))
                     , '#',1,(1U & (IData)((vlSelfRef.tb_llc_flush_tag__DOT__rsp 
                                            >> 0x0000003bU))));
        VL_STOP_MT("tb_llc_flush_tag.sv", 91, "", false);
    }
    vlSelfRef.tb_llc_flush_tag__DOT__orr = 1U;
    Vtb_llc_flush_tag___024root____VbeforeTrig_hb04eaf3d__0(vlSelf, 
                                                            "@(posedge tb_llc_flush_tag.clk)");
    co_await vlSelfRef.__VtrigSched_hb04eaf3d__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge tb_llc_flush_tag.clk)", 
                                                         "tb_llc_flush_tag.sv", 
                                                         93);
    Vtb_llc_flush_tag___024root____VbeforeTrig_hb04eaffa__0(vlSelf, 
                                                            "@(negedge tb_llc_flush_tag.clk)");
    co_await vlSelfRef.__VtrigSched_hb04eaffa__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(negedge tb_llc_flush_tag.clk)", 
                                                         "tb_llc_flush_tag.sv", 
                                                         93);
    vlSelfRef.tb_llc_flush_tag__DOT__orr = 0U;
    vlSelfRef.tb_llc_flush_tag__DOT__flush_mode = 1U;
    vlSelfRef.tb_llc_flush_tag__DOT__req_tag = 0x0000000000000456ULL;
    __Vtask_tb_llc_flush_tag__DOT__send__3__dirty = 0U;
    __Vtask_tb_llc_flush_tag__DOT__send__3__mode = 2U;
    Vtb_llc_flush_tag___024root____VbeforeTrig_hb04eaffa__0(vlSelf, 
                                                            "@(negedge tb_llc_flush_tag.clk)");
    co_await vlSelfRef.__VtrigSched_hb04eaffa__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(negedge tb_llc_flush_tag.clk)", 
                                                         "tb_llc_flush_tag.sv", 
                                                         84);
    vlSelfRef.tb_llc_flush_tag__DOT__req[0U] = (IData)(
                                                       (((QData)((IData)(
                                                                         (2U 
                                                                          | (IData)(vlSelfRef.tb_llc_flush_tag__DOT__req_index)))) 
                                                         << 0x0000003eU) 
                                                        | ((vlSelfRef.tb_llc_flush_tag__DOT__req_tag 
                                                            << 3U) 
                                                           | (QData)((IData)(
                                                                             ((IData)(__Vtask_tb_llc_flush_tag__DOT__send__3__dirty) 
                                                                              << 2U))))));
    vlSelfRef.tb_llc_flush_tag__DOT__req[1U] = (IData)(
                                                       ((((QData)((IData)(
                                                                          (2U 
                                                                           | (IData)(vlSelfRef.tb_llc_flush_tag__DOT__req_index)))) 
                                                          << 0x0000003eU) 
                                                         | ((vlSelfRef.tb_llc_flush_tag__DOT__req_tag 
                                                             << 3U) 
                                                            | (QData)((IData)(
                                                                              ((IData)(__Vtask_tb_llc_flush_tag__DOT__send__3__dirty) 
                                                                               << 2U))))) 
                                                        >> 0x00000020U));
    vlSelfRef.tb_llc_flush_tag__DOT__req[2U] = (3U 
                                                & (IData)(__Vtask_tb_llc_flush_tag__DOT__send__3__mode));
    vlSelfRef.tb_llc_flush_tag__DOT__iv = 1U;
    do {
        Vtb_llc_flush_tag___024root____VbeforeTrig_hb04eaf3d__0(vlSelf, 
                                                                "@(posedge tb_llc_flush_tag.clk)");
        co_await vlSelfRef.__VtrigSched_hb04eaf3d__0.trigger(0U, 
                                                             nullptr, 
                                                             "@(posedge tb_llc_flush_tag.clk)", 
                                                             "tb_llc_flush_tag.sv", 
                                                             85);
    } while ((1U & (~ (IData)(vlSelfRef.tb_llc_flush_tag__DOT__ir))));
    Vtb_llc_flush_tag___024root____VbeforeTrig_hb04eaffa__0(vlSelf, 
                                                            "@(negedge tb_llc_flush_tag.clk)");
    co_await vlSelfRef.__VtrigSched_hb04eaffa__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(negedge tb_llc_flush_tag.clk)", 
                                                         "tb_llc_flush_tag.sv", 
                                                         86);
    vlSelfRef.tb_llc_flush_tag__DOT__iv = 0U;
    __Vtask_tb_llc_flush_tag__DOT__receive__4__expected_evict = 1U;
    __Vtask_tb_llc_flush_tag__DOT__receive__4__expected_hit = 0U;
    while ((1U & (~ ((IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__a_full_q) 
                     | (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__b_full_q))))) {
        Vtb_llc_flush_tag___024root____VbeforeTrig_hb04eaffa__0(vlSelf, 
                                                                "@(negedge tb_llc_flush_tag.clk)");
        co_await vlSelfRef.__VtrigSched_hb04eaffa__0.trigger(0U, 
                                                             nullptr, 
                                                             "@(negedge tb_llc_flush_tag.clk)", 
                                                             "tb_llc_flush_tag.sv", 
                                                             89);
    }
    if (VL_UNLIKELY(((((1U & (IData)((vlSelfRef.tb_llc_flush_tag__DOT__rsp 
                                      >> 0x0000003cU))) 
                       != (IData)(__Vtask_tb_llc_flush_tag__DOT__receive__4__expected_hit)) 
                      | ((1U & (IData)((vlSelfRef.tb_llc_flush_tag__DOT__rsp 
                                        >> 0x0000003bU))) 
                         != (IData)(__Vtask_tb_llc_flush_tag__DOT__receive__4__expected_evict)))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_llc_flush_tag.sv:91: Assertion failed in %m: Unexpected lookup/flush result hit=%b evict=%b\n",5, 'M',vlSymsp->name(),"tb_llc_flush_tag.receive", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000)
                     , '#',1,(1U & (IData)((vlSelfRef.tb_llc_flush_tag__DOT__rsp 
                                            >> 0x0000003cU)))
                     , '#',1,(1U & (IData)((vlSelfRef.tb_llc_flush_tag__DOT__rsp 
                                            >> 0x0000003bU))));
        VL_STOP_MT("tb_llc_flush_tag.sv", 91, "", false);
    }
    vlSelfRef.tb_llc_flush_tag__DOT__orr = 1U;
    Vtb_llc_flush_tag___024root____VbeforeTrig_hb04eaf3d__0(vlSelf, 
                                                            "@(posedge tb_llc_flush_tag.clk)");
    co_await vlSelfRef.__VtrigSched_hb04eaf3d__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge tb_llc_flush_tag.clk)", 
                                                         "tb_llc_flush_tag.sv", 
                                                         93);
    Vtb_llc_flush_tag___024root____VbeforeTrig_hb04eaffa__0(vlSelf, 
                                                            "@(negedge tb_llc_flush_tag.clk)");
    co_await vlSelfRef.__VtrigSched_hb04eaffa__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(negedge tb_llc_flush_tag.clk)", 
                                                         "tb_llc_flush_tag.sv", 
                                                         93);
    vlSelfRef.tb_llc_flush_tag__DOT__orr = 0U;
    while ((2U != vlSelfRef.tb_llc_flush_tag__DOT__beats)) {
        Vtb_llc_flush_tag___024root____VbeforeTrig_hd94d9ee0__0(vlSelf, 
                                                                "@( (32'sh2 == tb_llc_flush_tag.beats))");
        co_await vlSelfRef.__VtrigSched_hd94d9ee0__0.trigger(1U, 
                                                             nullptr, 
                                                             "@( (32'sh2 == tb_llc_flush_tag.beats))", 
                                                             "tb_llc_flush_tag.sv", 
                                                             105);
    }
    vlSelfRef.tb_llc_flush_tag__DOT__req_index = 1U;
    vlSelfRef.tb_llc_flush_tag__DOT__req_tag = 0x0000000000000789ULL;
    __Vtask_tb_llc_flush_tag__DOT__send__5__dirty = 0U;
    __Vtask_tb_llc_flush_tag__DOT__send__5__mode = 2U;
    Vtb_llc_flush_tag___024root____VbeforeTrig_hb04eaffa__0(vlSelf, 
                                                            "@(negedge tb_llc_flush_tag.clk)");
    co_await vlSelfRef.__VtrigSched_hb04eaffa__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(negedge tb_llc_flush_tag.clk)", 
                                                         "tb_llc_flush_tag.sv", 
                                                         84);
    vlSelfRef.tb_llc_flush_tag__DOT__req[0U] = (IData)(
                                                       (((QData)((IData)(
                                                                         (2U 
                                                                          | (IData)(vlSelfRef.tb_llc_flush_tag__DOT__req_index)))) 
                                                         << 0x0000003eU) 
                                                        | ((vlSelfRef.tb_llc_flush_tag__DOT__req_tag 
                                                            << 3U) 
                                                           | (QData)((IData)(
                                                                             ((IData)(__Vtask_tb_llc_flush_tag__DOT__send__5__dirty) 
                                                                              << 2U))))));
    vlSelfRef.tb_llc_flush_tag__DOT__req[1U] = (IData)(
                                                       ((((QData)((IData)(
                                                                          (2U 
                                                                           | (IData)(vlSelfRef.tb_llc_flush_tag__DOT__req_index)))) 
                                                          << 0x0000003eU) 
                                                         | ((vlSelfRef.tb_llc_flush_tag__DOT__req_tag 
                                                             << 3U) 
                                                            | (QData)((IData)(
                                                                              ((IData)(__Vtask_tb_llc_flush_tag__DOT__send__5__dirty) 
                                                                               << 2U))))) 
                                                        >> 0x00000020U));
    vlSelfRef.tb_llc_flush_tag__DOT__req[2U] = (3U 
                                                & (IData)(__Vtask_tb_llc_flush_tag__DOT__send__5__mode));
    vlSelfRef.tb_llc_flush_tag__DOT__iv = 1U;
    do {
        Vtb_llc_flush_tag___024root____VbeforeTrig_hb04eaf3d__0(vlSelf, 
                                                                "@(posedge tb_llc_flush_tag.clk)");
        co_await vlSelfRef.__VtrigSched_hb04eaf3d__0.trigger(0U, 
                                                             nullptr, 
                                                             "@(posedge tb_llc_flush_tag.clk)", 
                                                             "tb_llc_flush_tag.sv", 
                                                             85);
    } while ((1U & (~ (IData)(vlSelfRef.tb_llc_flush_tag__DOT__ir))));
    Vtb_llc_flush_tag___024root____VbeforeTrig_hb04eaffa__0(vlSelf, 
                                                            "@(negedge tb_llc_flush_tag.clk)");
    co_await vlSelfRef.__VtrigSched_hb04eaffa__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(negedge tb_llc_flush_tag.clk)", 
                                                         "tb_llc_flush_tag.sv", 
                                                         86);
    vlSelfRef.tb_llc_flush_tag__DOT__iv = 0U;
    __Vtask_tb_llc_flush_tag__DOT__receive__6__expected_evict = 0U;
    __Vtask_tb_llc_flush_tag__DOT__receive__6__expected_hit = 0U;
    while ((1U & (~ ((IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__a_full_q) 
                     | (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__b_full_q))))) {
        Vtb_llc_flush_tag___024root____VbeforeTrig_hb04eaffa__0(vlSelf, 
                                                                "@(negedge tb_llc_flush_tag.clk)");
        co_await vlSelfRef.__VtrigSched_hb04eaffa__0.trigger(0U, 
                                                             nullptr, 
                                                             "@(negedge tb_llc_flush_tag.clk)", 
                                                             "tb_llc_flush_tag.sv", 
                                                             89);
    }
    if (VL_UNLIKELY(((((1U & (IData)((vlSelfRef.tb_llc_flush_tag__DOT__rsp 
                                      >> 0x0000003cU))) 
                       != (IData)(__Vtask_tb_llc_flush_tag__DOT__receive__6__expected_hit)) 
                      | ((1U & (IData)((vlSelfRef.tb_llc_flush_tag__DOT__rsp 
                                        >> 0x0000003bU))) 
                         != (IData)(__Vtask_tb_llc_flush_tag__DOT__receive__6__expected_evict)))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_llc_flush_tag.sv:91: Assertion failed in %m: Unexpected lookup/flush result hit=%b evict=%b\n",5, 'M',vlSymsp->name(),"tb_llc_flush_tag.receive", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000)
                     , '#',1,(1U & (IData)((vlSelfRef.tb_llc_flush_tag__DOT__rsp 
                                            >> 0x0000003cU)))
                     , '#',1,(1U & (IData)((vlSelfRef.tb_llc_flush_tag__DOT__rsp 
                                            >> 0x0000003bU))));
        VL_STOP_MT("tb_llc_flush_tag.sv", 91, "", false);
    }
    vlSelfRef.tb_llc_flush_tag__DOT__orr = 1U;
    Vtb_llc_flush_tag___024root____VbeforeTrig_hb04eaf3d__0(vlSelf, 
                                                            "@(posedge tb_llc_flush_tag.clk)");
    co_await vlSelfRef.__VtrigSched_hb04eaf3d__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge tb_llc_flush_tag.clk)", 
                                                         "tb_llc_flush_tag.sv", 
                                                         93);
    Vtb_llc_flush_tag___024root____VbeforeTrig_hb04eaffa__0(vlSelf, 
                                                            "@(negedge tb_llc_flush_tag.clk)");
    co_await vlSelfRef.__VtrigSched_hb04eaffa__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(negedge tb_llc_flush_tag.clk)", 
                                                         "tb_llc_flush_tag.sv", 
                                                         93);
    vlSelfRef.tb_llc_flush_tag__DOT__orr = 0U;
    vlSelfRef.tb_llc_flush_tag__DOT__req_index = 0U;
    vlSelfRef.tb_llc_flush_tag__DOT__req_tag = 0x0000000000000456ULL;
    tb_llc_flush_tag__DOT__unnamedblk1_2__DOT____Vrepeat1 = 8U;
    while (VL_LTS_III(32, 0U, tb_llc_flush_tag__DOT__unnamedblk1_2__DOT____Vrepeat1)) {
        Vtb_llc_flush_tag___024root____VbeforeTrig_hb04eaffa__0(vlSelf, 
                                                                "@(negedge tb_llc_flush_tag.clk)");
        co_await vlSelfRef.__VtrigSched_hb04eaffa__0.trigger(0U, 
                                                             nullptr, 
                                                             "@(negedge tb_llc_flush_tag.clk)", 
                                                             "tb_llc_flush_tag.sv", 
                                                             111);
        if (VL_UNLIKELY(((1U & ((IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__ram_we) 
                                | (~ (0U != (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__pending_valid_q)))))))) {
            VL_WRITEF_NX("[%0t] %%Fatal: tb_llc_flush_tag.sv:113: Assertion failed in %m: normal eviction overwrote dirty victim before B\n",3, 'M',vlSymsp->name(),"tb_llc_flush_tag.unnamedblk1_2", 'T',-9
                         , '#',64,VL_TIME_UNITED_Q(1000));
            VL_STOP_MT("tb_llc_flush_tag.sv", 113, "", false);
        }
        tb_llc_flush_tag__DOT__unnamedblk1_2__DOT____Vrepeat1 
            = (tb_llc_flush_tag__DOT__unnamedblk1_2__DOT____Vrepeat1 
               - (IData)(1U));
    }
    vlSelfRef.tb_llc_flush_tag__DOT__b = 2U;
    vlSelfRef.tb_llc_flush_tag__DOT__bv = 1U;
    do {
        Vtb_llc_flush_tag___024root____VbeforeTrig_hb04eaf3d__0(vlSelf, 
                                                                "@(posedge tb_llc_flush_tag.clk)");
        co_await vlSelfRef.__VtrigSched_hb04eaf3d__0.trigger(0U, 
                                                             nullptr, 
                                                             "@(posedge tb_llc_flush_tag.clk)", 
                                                             "tb_llc_flush_tag.sv", 
                                                             116);
    } while ((1U & (~ (IData)(vlSelfRef.tb_llc_flush_tag__DOT__br))));
    Vtb_llc_flush_tag___024root____VbeforeTrig_hb04eaffa__0(vlSelf, 
                                                            "@(negedge tb_llc_flush_tag.clk)");
    co_await vlSelfRef.__VtrigSched_hb04eaffa__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(negedge tb_llc_flush_tag.clk)", 
                                                         "tb_llc_flush_tag.sv", 
                                                         117);
    vlSelfRef.tb_llc_flush_tag__DOT__bv = 0U;
    tb_llc_flush_tag__DOT__unnamedblk1_3__DOT____Vrepeat2 = 8U;
    while (VL_LTS_III(32, 0U, tb_llc_flush_tag__DOT__unnamedblk1_3__DOT____Vrepeat2)) {
        Vtb_llc_flush_tag___024root____VbeforeTrig_hb04eaffa__0(vlSelf, 
                                                                "@(negedge tb_llc_flush_tag.clk)");
        co_await vlSelfRef.__VtrigSched_hb04eaffa__0.trigger(0U, 
                                                             nullptr, 
                                                             "@(negedge tb_llc_flush_tag.clk)", 
                                                             "tb_llc_flush_tag.sv", 
                                                             120);
        if (VL_UNLIKELY(((1U & (((((IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__ram_we) 
                                   | (IData)(vlSelfRef.tb_llc_flush_tag__DOT__wb_commit)) 
                                  | ((((~ (IData)(vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__busy_q)) 
                                       & (IData)(vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__send_q)) 
                                      & (0U == (0x18U 
                                                & vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__desc_q[2U]))) 
                                     & (~ (IData)(vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__wb_failed_q)))) 
                                 | (~ (0U != (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__pending_valid_q)))) 
                                | (~ (IData)(vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__wb_fault_q))))))) {
            VL_WRITEF_NX("[%0t] %%Fatal: tb_llc_flush_tag.sv:122: Assertion failed in %m: failed normal eviction released victim/refill\n",3, 'M',vlSymsp->name(),"tb_llc_flush_tag.unnamedblk1_3", 'T',-9
                         , '#',64,VL_TIME_UNITED_Q(1000));
            VL_STOP_MT("tb_llc_flush_tag.sv", 122, "", false);
        }
        tb_llc_flush_tag__DOT__unnamedblk1_3__DOT____Vrepeat2 
            = (tb_llc_flush_tag__DOT__unnamedblk1_3__DOT____Vrepeat2 
               - (IData)(1U));
    }
    VL_WRITEF_NX("PASS: normal eviction SLVERR preserves victim tag and blocks refill\n",0);
    VL_FINISH_MT("tb_llc_flush_tag.sv", 130, "");
    vlSelfRef.tb_llc_flush_tag__DOT__flush_mode = 1U;
    __Vtask_tb_llc_flush_tag__DOT__send__7__dirty = 0U;
    __Vtask_tb_llc_flush_tag__DOT__send__7__mode = 1U;
    Vtb_llc_flush_tag___024root____VbeforeTrig_hb04eaffa__0(vlSelf, 
                                                            "@(negedge tb_llc_flush_tag.clk)");
    co_await vlSelfRef.__VtrigSched_hb04eaffa__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(negedge tb_llc_flush_tag.clk)", 
                                                         "tb_llc_flush_tag.sv", 
                                                         84);
    vlSelfRef.tb_llc_flush_tag__DOT__req[0U] = (IData)(
                                                       (((QData)((IData)(
                                                                         (2U 
                                                                          | (IData)(vlSelfRef.tb_llc_flush_tag__DOT__req_index)))) 
                                                         << 0x0000003eU) 
                                                        | ((vlSelfRef.tb_llc_flush_tag__DOT__req_tag 
                                                            << 3U) 
                                                           | (QData)((IData)(
                                                                             ((IData)(__Vtask_tb_llc_flush_tag__DOT__send__7__dirty) 
                                                                              << 2U))))));
    vlSelfRef.tb_llc_flush_tag__DOT__req[1U] = (IData)(
                                                       ((((QData)((IData)(
                                                                          (2U 
                                                                           | (IData)(vlSelfRef.tb_llc_flush_tag__DOT__req_index)))) 
                                                          << 0x0000003eU) 
                                                         | ((vlSelfRef.tb_llc_flush_tag__DOT__req_tag 
                                                             << 3U) 
                                                            | (QData)((IData)(
                                                                              ((IData)(__Vtask_tb_llc_flush_tag__DOT__send__7__dirty) 
                                                                               << 2U))))) 
                                                        >> 0x00000020U));
    vlSelfRef.tb_llc_flush_tag__DOT__req[2U] = (3U 
                                                & (IData)(__Vtask_tb_llc_flush_tag__DOT__send__7__mode));
    vlSelfRef.tb_llc_flush_tag__DOT__iv = 1U;
    do {
        Vtb_llc_flush_tag___024root____VbeforeTrig_hb04eaf3d__0(vlSelf, 
                                                                "@(posedge tb_llc_flush_tag.clk)");
        co_await vlSelfRef.__VtrigSched_hb04eaf3d__0.trigger(0U, 
                                                             nullptr, 
                                                             "@(posedge tb_llc_flush_tag.clk)", 
                                                             "tb_llc_flush_tag.sv", 
                                                             85);
    } while ((1U & (~ (IData)(vlSelfRef.tb_llc_flush_tag__DOT__ir))));
    Vtb_llc_flush_tag___024root____VbeforeTrig_hb04eaffa__0(vlSelf, 
                                                            "@(negedge tb_llc_flush_tag.clk)");
    co_await vlSelfRef.__VtrigSched_hb04eaffa__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(negedge tb_llc_flush_tag.clk)", 
                                                         "tb_llc_flush_tag.sv", 
                                                         86);
    vlSelfRef.tb_llc_flush_tag__DOT__iv = 0U;
    __Vtask_tb_llc_flush_tag__DOT__receive__8__expected_evict = 1U;
    __Vtask_tb_llc_flush_tag__DOT__receive__8__expected_hit = 0U;
    while ((1U & (~ ((IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__a_full_q) 
                     | (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__b_full_q))))) {
        Vtb_llc_flush_tag___024root____VbeforeTrig_hb04eaffa__0(vlSelf, 
                                                                "@(negedge tb_llc_flush_tag.clk)");
        co_await vlSelfRef.__VtrigSched_hb04eaffa__0.trigger(0U, 
                                                             nullptr, 
                                                             "@(negedge tb_llc_flush_tag.clk)", 
                                                             "tb_llc_flush_tag.sv", 
                                                             89);
    }
    if (VL_UNLIKELY(((((1U & (IData)((vlSelfRef.tb_llc_flush_tag__DOT__rsp 
                                      >> 0x0000003cU))) 
                       != (IData)(__Vtask_tb_llc_flush_tag__DOT__receive__8__expected_hit)) 
                      | ((1U & (IData)((vlSelfRef.tb_llc_flush_tag__DOT__rsp 
                                        >> 0x0000003bU))) 
                         != (IData)(__Vtask_tb_llc_flush_tag__DOT__receive__8__expected_evict)))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_llc_flush_tag.sv:91: Assertion failed in %m: Unexpected lookup/flush result hit=%b evict=%b\n",5, 'M',vlSymsp->name(),"tb_llc_flush_tag.receive", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000)
                     , '#',1,(1U & (IData)((vlSelfRef.tb_llc_flush_tag__DOT__rsp 
                                            >> 0x0000003cU)))
                     , '#',1,(1U & (IData)((vlSelfRef.tb_llc_flush_tag__DOT__rsp 
                                            >> 0x0000003bU))));
        VL_STOP_MT("tb_llc_flush_tag.sv", 91, "", false);
    }
    vlSelfRef.tb_llc_flush_tag__DOT__orr = 1U;
    Vtb_llc_flush_tag___024root____VbeforeTrig_hb04eaf3d__0(vlSelf, 
                                                            "@(posedge tb_llc_flush_tag.clk)");
    co_await vlSelfRef.__VtrigSched_hb04eaf3d__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge tb_llc_flush_tag.clk)", 
                                                         "tb_llc_flush_tag.sv", 
                                                         93);
    Vtb_llc_flush_tag___024root____VbeforeTrig_hb04eaffa__0(vlSelf, 
                                                            "@(negedge tb_llc_flush_tag.clk)");
    co_await vlSelfRef.__VtrigSched_hb04eaffa__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(negedge tb_llc_flush_tag.clk)", 
                                                         "tb_llc_flush_tag.sv", 
                                                         93);
    vlSelfRef.tb_llc_flush_tag__DOT__orr = 0U;
    while ((2U != vlSelfRef.tb_llc_flush_tag__DOT__beats)) {
        Vtb_llc_flush_tag___024root____VbeforeTrig_hd94d9ee0__0(vlSelf, 
                                                                "@( (32'sh2 == tb_llc_flush_tag.beats))");
        co_await vlSelfRef.__VtrigSched_hd94d9ee0__0.trigger(1U, 
                                                             nullptr, 
                                                             "@( (32'sh2 == tb_llc_flush_tag.beats))", 
                                                             "tb_llc_flush_tag.sv", 
                                                             135);
    }
    tb_llc_flush_tag__DOT__unnamedblk1_4__DOT____Vrepeat3 = 8U;
    while (VL_LTS_III(32, 0U, tb_llc_flush_tag__DOT__unnamedblk1_4__DOT____Vrepeat3)) {
        Vtb_llc_flush_tag___024root____VbeforeTrig_hb04eaffa__0(vlSelf, 
                                                                "@(negedge tb_llc_flush_tag.clk)");
        co_await vlSelfRef.__VtrigSched_hb04eaffa__0.trigger(0U, 
                                                             nullptr, 
                                                             "@(negedge tb_llc_flush_tag.clk)", 
                                                             "tb_llc_flush_tag.sv", 
                                                             138);
        if (VL_UNLIKELY((((IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__ram_we) 
                          | (IData)(vlSelfRef.tb_llc_flush_tag__DOT__ir))))) {
            VL_WRITEF_NX("[%0t] %%Fatal: tb_llc_flush_tag.sv:140: Assertion failed in %m: dirty tag released before writeback commit\n",3, 'M',vlSymsp->name(),"tb_llc_flush_tag.unnamedblk1_4", 'T',-9
                         , '#',64,VL_TIME_UNITED_Q(1000));
            VL_STOP_MT("tb_llc_flush_tag.sv", 140, "", false);
        }
        tb_llc_flush_tag__DOT__unnamedblk1_4__DOT____Vrepeat3 
            = (tb_llc_flush_tag__DOT__unnamedblk1_4__DOT____Vrepeat3 
               - (IData)(1U));
    }
    vlSelfRef.tb_llc_flush_tag__DOT__b = 0U;
    vlSelfRef.tb_llc_flush_tag__DOT__bv = 1U;
    do {
        Vtb_llc_flush_tag___024root____VbeforeTrig_hb04eaf3d__0(vlSelf, 
                                                                "@(posedge tb_llc_flush_tag.clk)");
        co_await vlSelfRef.__VtrigSched_hb04eaf3d__0.trigger(0U, 
                                                             nullptr, 
                                                             "@(posedge tb_llc_flush_tag.clk)", 
                                                             "tb_llc_flush_tag.sv", 
                                                             143);
    } while ((1U & (~ (IData)(vlSelfRef.tb_llc_flush_tag__DOT__br))));
    Vtb_llc_flush_tag___024root____VbeforeTrig_hb04eaffa__0(vlSelf, 
                                                            "@(negedge tb_llc_flush_tag.clk)");
    co_await vlSelfRef.__VtrigSched_hb04eaffa__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(negedge tb_llc_flush_tag.clk)", 
                                                         "tb_llc_flush_tag.sv", 
                                                         144);
    vlSelfRef.tb_llc_flush_tag__DOT__bv = 0U;
    co_await vlSelfRef.__VdlySched.delay(0x00000000000003e8ULL, 
                                         nullptr, "tb_llc_flush_tag.sv", 
                                         145);
    if (VL_UNLIKELY(((1U & ((~ (IData)(vlSelfRef.tb_llc_flush_tag__DOT__commit)) 
                            | (~ (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__ram_we))))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_llc_flush_tag.sv:145: Assertion failed in %m: successful B did not commit tag invalidation\n",3, 'M',vlSymsp->name(),"tb_llc_flush_tag", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb_llc_flush_tag.sv", 145, "", false);
    }
    Vtb_llc_flush_tag___024root____VbeforeTrig_hb04eaf3d__0(vlSelf, 
                                                            "@(posedge tb_llc_flush_tag.clk)");
    co_await vlSelfRef.__VtrigSched_hb04eaf3d__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge tb_llc_flush_tag.clk)", 
                                                         "tb_llc_flush_tag.sv", 
                                                         146);
    Vtb_llc_flush_tag___024root____VbeforeTrig_hb04eaffa__0(vlSelf, 
                                                            "@(negedge tb_llc_flush_tag.clk)");
    co_await vlSelfRef.__VtrigSched_hb04eaffa__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(negedge tb_llc_flush_tag.clk)", 
                                                         "tb_llc_flush_tag.sv", 
                                                         146);
    vlSelfRef.tb_llc_flush_tag__DOT__flush_mode = 0U;
    __Vtask_tb_llc_flush_tag__DOT__send__9__dirty = 0U;
    __Vtask_tb_llc_flush_tag__DOT__send__9__mode = 2U;
    Vtb_llc_flush_tag___024root____VbeforeTrig_hb04eaffa__0(vlSelf, 
                                                            "@(negedge tb_llc_flush_tag.clk)");
    co_await vlSelfRef.__VtrigSched_hb04eaffa__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(negedge tb_llc_flush_tag.clk)", 
                                                         "tb_llc_flush_tag.sv", 
                                                         84);
    vlSelfRef.tb_llc_flush_tag__DOT__req[0U] = (IData)(
                                                       (((QData)((IData)(
                                                                         (2U 
                                                                          | (IData)(vlSelfRef.tb_llc_flush_tag__DOT__req_index)))) 
                                                         << 0x0000003eU) 
                                                        | ((vlSelfRef.tb_llc_flush_tag__DOT__req_tag 
                                                            << 3U) 
                                                           | (QData)((IData)(
                                                                             ((IData)(__Vtask_tb_llc_flush_tag__DOT__send__9__dirty) 
                                                                              << 2U))))));
    vlSelfRef.tb_llc_flush_tag__DOT__req[1U] = (IData)(
                                                       ((((QData)((IData)(
                                                                          (2U 
                                                                           | (IData)(vlSelfRef.tb_llc_flush_tag__DOT__req_index)))) 
                                                          << 0x0000003eU) 
                                                         | ((vlSelfRef.tb_llc_flush_tag__DOT__req_tag 
                                                             << 3U) 
                                                            | (QData)((IData)(
                                                                              ((IData)(__Vtask_tb_llc_flush_tag__DOT__send__9__dirty) 
                                                                               << 2U))))) 
                                                        >> 0x00000020U));
    vlSelfRef.tb_llc_flush_tag__DOT__req[2U] = (3U 
                                                & (IData)(__Vtask_tb_llc_flush_tag__DOT__send__9__mode));
    vlSelfRef.tb_llc_flush_tag__DOT__iv = 1U;
    do {
        Vtb_llc_flush_tag___024root____VbeforeTrig_hb04eaf3d__0(vlSelf, 
                                                                "@(posedge tb_llc_flush_tag.clk)");
        co_await vlSelfRef.__VtrigSched_hb04eaf3d__0.trigger(0U, 
                                                             nullptr, 
                                                             "@(posedge tb_llc_flush_tag.clk)", 
                                                             "tb_llc_flush_tag.sv", 
                                                             85);
    } while ((1U & (~ (IData)(vlSelfRef.tb_llc_flush_tag__DOT__ir))));
    Vtb_llc_flush_tag___024root____VbeforeTrig_hb04eaffa__0(vlSelf, 
                                                            "@(negedge tb_llc_flush_tag.clk)");
    co_await vlSelfRef.__VtrigSched_hb04eaffa__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(negedge tb_llc_flush_tag.clk)", 
                                                         "tb_llc_flush_tag.sv", 
                                                         86);
    vlSelfRef.tb_llc_flush_tag__DOT__iv = 0U;
    __Vtask_tb_llc_flush_tag__DOT__receive__10__expected_evict = 0U;
    __Vtask_tb_llc_flush_tag__DOT__receive__10__expected_hit = 0U;
    while ((1U & (~ ((IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__a_full_q) 
                     | (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__b_full_q))))) {
        Vtb_llc_flush_tag___024root____VbeforeTrig_hb04eaffa__0(vlSelf, 
                                                                "@(negedge tb_llc_flush_tag.clk)");
        co_await vlSelfRef.__VtrigSched_hb04eaffa__0.trigger(0U, 
                                                             nullptr, 
                                                             "@(negedge tb_llc_flush_tag.clk)", 
                                                             "tb_llc_flush_tag.sv", 
                                                             89);
    }
    if (VL_UNLIKELY(((((1U & (IData)((vlSelfRef.tb_llc_flush_tag__DOT__rsp 
                                      >> 0x0000003cU))) 
                       != (IData)(__Vtask_tb_llc_flush_tag__DOT__receive__10__expected_hit)) 
                      | ((1U & (IData)((vlSelfRef.tb_llc_flush_tag__DOT__rsp 
                                        >> 0x0000003bU))) 
                         != (IData)(__Vtask_tb_llc_flush_tag__DOT__receive__10__expected_evict)))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_llc_flush_tag.sv:91: Assertion failed in %m: Unexpected lookup/flush result hit=%b evict=%b\n",5, 'M',vlSymsp->name(),"tb_llc_flush_tag.receive", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000)
                     , '#',1,(1U & (IData)((vlSelfRef.tb_llc_flush_tag__DOT__rsp 
                                            >> 0x0000003cU)))
                     , '#',1,(1U & (IData)((vlSelfRef.tb_llc_flush_tag__DOT__rsp 
                                            >> 0x0000003bU))));
        VL_STOP_MT("tb_llc_flush_tag.sv", 91, "", false);
    }
    vlSelfRef.tb_llc_flush_tag__DOT__orr = 1U;
    Vtb_llc_flush_tag___024root____VbeforeTrig_hb04eaf3d__0(vlSelf, 
                                                            "@(posedge tb_llc_flush_tag.clk)");
    co_await vlSelfRef.__VtrigSched_hb04eaf3d__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge tb_llc_flush_tag.clk)", 
                                                         "tb_llc_flush_tag.sv", 
                                                         93);
    Vtb_llc_flush_tag___024root____VbeforeTrig_hb04eaffa__0(vlSelf, 
                                                            "@(negedge tb_llc_flush_tag.clk)");
    co_await vlSelfRef.__VtrigSched_hb04eaffa__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(negedge tb_llc_flush_tag.clk)", 
                                                         "tb_llc_flush_tag.sv", 
                                                         93);
    vlSelfRef.tb_llc_flush_tag__DOT__orr = 0U;
    __Vtask_tb_llc_flush_tag__DOT__send__11__dirty = 1U;
    __Vtask_tb_llc_flush_tag__DOT__send__11__mode = 2U;
    Vtb_llc_flush_tag___024root____VbeforeTrig_hb04eaffa__0(vlSelf, 
                                                            "@(negedge tb_llc_flush_tag.clk)");
    co_await vlSelfRef.__VtrigSched_hb04eaffa__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(negedge tb_llc_flush_tag.clk)", 
                                                         "tb_llc_flush_tag.sv", 
                                                         84);
    vlSelfRef.tb_llc_flush_tag__DOT__req[0U] = (IData)(
                                                       (((QData)((IData)(
                                                                         (2U 
                                                                          | (IData)(vlSelfRef.tb_llc_flush_tag__DOT__req_index)))) 
                                                         << 0x0000003eU) 
                                                        | ((vlSelfRef.tb_llc_flush_tag__DOT__req_tag 
                                                            << 3U) 
                                                           | (QData)((IData)(
                                                                             ((IData)(__Vtask_tb_llc_flush_tag__DOT__send__11__dirty) 
                                                                              << 2U))))));
    vlSelfRef.tb_llc_flush_tag__DOT__req[1U] = (IData)(
                                                       ((((QData)((IData)(
                                                                          (2U 
                                                                           | (IData)(vlSelfRef.tb_llc_flush_tag__DOT__req_index)))) 
                                                          << 0x0000003eU) 
                                                         | ((vlSelfRef.tb_llc_flush_tag__DOT__req_tag 
                                                             << 3U) 
                                                            | (QData)((IData)(
                                                                              ((IData)(__Vtask_tb_llc_flush_tag__DOT__send__11__dirty) 
                                                                               << 2U))))) 
                                                        >> 0x00000020U));
    vlSelfRef.tb_llc_flush_tag__DOT__req[2U] = (3U 
                                                & (IData)(__Vtask_tb_llc_flush_tag__DOT__send__11__mode));
    vlSelfRef.tb_llc_flush_tag__DOT__iv = 1U;
    do {
        Vtb_llc_flush_tag___024root____VbeforeTrig_hb04eaf3d__0(vlSelf, 
                                                                "@(posedge tb_llc_flush_tag.clk)");
        co_await vlSelfRef.__VtrigSched_hb04eaf3d__0.trigger(0U, 
                                                             nullptr, 
                                                             "@(posedge tb_llc_flush_tag.clk)", 
                                                             "tb_llc_flush_tag.sv", 
                                                             85);
    } while ((1U & (~ (IData)(vlSelfRef.tb_llc_flush_tag__DOT__ir))));
    Vtb_llc_flush_tag___024root____VbeforeTrig_hb04eaffa__0(vlSelf, 
                                                            "@(negedge tb_llc_flush_tag.clk)");
    co_await vlSelfRef.__VtrigSched_hb04eaffa__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(negedge tb_llc_flush_tag.clk)", 
                                                         "tb_llc_flush_tag.sv", 
                                                         86);
    vlSelfRef.tb_llc_flush_tag__DOT__iv = 0U;
    __Vtask_tb_llc_flush_tag__DOT__receive__12__expected_evict = 0U;
    __Vtask_tb_llc_flush_tag__DOT__receive__12__expected_hit = 1U;
    while ((1U & (~ ((IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__a_full_q) 
                     | (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__b_full_q))))) {
        Vtb_llc_flush_tag___024root____VbeforeTrig_hb04eaffa__0(vlSelf, 
                                                                "@(negedge tb_llc_flush_tag.clk)");
        co_await vlSelfRef.__VtrigSched_hb04eaffa__0.trigger(0U, 
                                                             nullptr, 
                                                             "@(negedge tb_llc_flush_tag.clk)", 
                                                             "tb_llc_flush_tag.sv", 
                                                             89);
    }
    if (VL_UNLIKELY(((((1U & (IData)((vlSelfRef.tb_llc_flush_tag__DOT__rsp 
                                      >> 0x0000003cU))) 
                       != (IData)(__Vtask_tb_llc_flush_tag__DOT__receive__12__expected_hit)) 
                      | ((1U & (IData)((vlSelfRef.tb_llc_flush_tag__DOT__rsp 
                                        >> 0x0000003bU))) 
                         != (IData)(__Vtask_tb_llc_flush_tag__DOT__receive__12__expected_evict)))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_llc_flush_tag.sv:91: Assertion failed in %m: Unexpected lookup/flush result hit=%b evict=%b\n",5, 'M',vlSymsp->name(),"tb_llc_flush_tag.receive", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000)
                     , '#',1,(1U & (IData)((vlSelfRef.tb_llc_flush_tag__DOT__rsp 
                                            >> 0x0000003cU)))
                     , '#',1,(1U & (IData)((vlSelfRef.tb_llc_flush_tag__DOT__rsp 
                                            >> 0x0000003bU))));
        VL_STOP_MT("tb_llc_flush_tag.sv", 91, "", false);
    }
    vlSelfRef.tb_llc_flush_tag__DOT__orr = 1U;
    Vtb_llc_flush_tag___024root____VbeforeTrig_hb04eaf3d__0(vlSelf, 
                                                            "@(posedge tb_llc_flush_tag.clk)");
    co_await vlSelfRef.__VtrigSched_hb04eaf3d__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge tb_llc_flush_tag.clk)", 
                                                         "tb_llc_flush_tag.sv", 
                                                         93);
    Vtb_llc_flush_tag___024root____VbeforeTrig_hb04eaffa__0(vlSelf, 
                                                            "@(negedge tb_llc_flush_tag.clk)");
    co_await vlSelfRef.__VtrigSched_hb04eaffa__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(negedge tb_llc_flush_tag.clk)", 
                                                         "tb_llc_flush_tag.sv", 
                                                         93);
    vlSelfRef.tb_llc_flush_tag__DOT__orr = 0U;
    vlSelfRef.tb_llc_flush_tag__DOT__flush_mode = 1U;
    __Vtask_tb_llc_flush_tag__DOT__send__13__dirty = 0U;
    __Vtask_tb_llc_flush_tag__DOT__send__13__mode = 1U;
    Vtb_llc_flush_tag___024root____VbeforeTrig_hb04eaffa__0(vlSelf, 
                                                            "@(negedge tb_llc_flush_tag.clk)");
    co_await vlSelfRef.__VtrigSched_hb04eaffa__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(negedge tb_llc_flush_tag.clk)", 
                                                         "tb_llc_flush_tag.sv", 
                                                         84);
    vlSelfRef.tb_llc_flush_tag__DOT__req[0U] = (IData)(
                                                       (((QData)((IData)(
                                                                         (2U 
                                                                          | (IData)(vlSelfRef.tb_llc_flush_tag__DOT__req_index)))) 
                                                         << 0x0000003eU) 
                                                        | ((vlSelfRef.tb_llc_flush_tag__DOT__req_tag 
                                                            << 3U) 
                                                           | (QData)((IData)(
                                                                             ((IData)(__Vtask_tb_llc_flush_tag__DOT__send__13__dirty) 
                                                                              << 2U))))));
    vlSelfRef.tb_llc_flush_tag__DOT__req[1U] = (IData)(
                                                       ((((QData)((IData)(
                                                                          (2U 
                                                                           | (IData)(vlSelfRef.tb_llc_flush_tag__DOT__req_index)))) 
                                                          << 0x0000003eU) 
                                                         | ((vlSelfRef.tb_llc_flush_tag__DOT__req_tag 
                                                             << 3U) 
                                                            | (QData)((IData)(
                                                                              ((IData)(__Vtask_tb_llc_flush_tag__DOT__send__13__dirty) 
                                                                               << 2U))))) 
                                                        >> 0x00000020U));
    vlSelfRef.tb_llc_flush_tag__DOT__req[2U] = (3U 
                                                & (IData)(__Vtask_tb_llc_flush_tag__DOT__send__13__mode));
    vlSelfRef.tb_llc_flush_tag__DOT__iv = 1U;
    do {
        Vtb_llc_flush_tag___024root____VbeforeTrig_hb04eaf3d__0(vlSelf, 
                                                                "@(posedge tb_llc_flush_tag.clk)");
        co_await vlSelfRef.__VtrigSched_hb04eaf3d__0.trigger(0U, 
                                                             nullptr, 
                                                             "@(posedge tb_llc_flush_tag.clk)", 
                                                             "tb_llc_flush_tag.sv", 
                                                             85);
    } while ((1U & (~ (IData)(vlSelfRef.tb_llc_flush_tag__DOT__ir))));
    Vtb_llc_flush_tag___024root____VbeforeTrig_hb04eaffa__0(vlSelf, 
                                                            "@(negedge tb_llc_flush_tag.clk)");
    co_await vlSelfRef.__VtrigSched_hb04eaffa__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(negedge tb_llc_flush_tag.clk)", 
                                                         "tb_llc_flush_tag.sv", 
                                                         86);
    vlSelfRef.tb_llc_flush_tag__DOT__iv = 0U;
    __Vtask_tb_llc_flush_tag__DOT__receive__14__expected_evict = 1U;
    __Vtask_tb_llc_flush_tag__DOT__receive__14__expected_hit = 0U;
    while ((1U & (~ ((IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__a_full_q) 
                     | (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__b_full_q))))) {
        Vtb_llc_flush_tag___024root____VbeforeTrig_hb04eaffa__0(vlSelf, 
                                                                "@(negedge tb_llc_flush_tag.clk)");
        co_await vlSelfRef.__VtrigSched_hb04eaffa__0.trigger(0U, 
                                                             nullptr, 
                                                             "@(negedge tb_llc_flush_tag.clk)", 
                                                             "tb_llc_flush_tag.sv", 
                                                             89);
    }
    if (VL_UNLIKELY(((((1U & (IData)((vlSelfRef.tb_llc_flush_tag__DOT__rsp 
                                      >> 0x0000003cU))) 
                       != (IData)(__Vtask_tb_llc_flush_tag__DOT__receive__14__expected_hit)) 
                      | ((1U & (IData)((vlSelfRef.tb_llc_flush_tag__DOT__rsp 
                                        >> 0x0000003bU))) 
                         != (IData)(__Vtask_tb_llc_flush_tag__DOT__receive__14__expected_evict)))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_llc_flush_tag.sv:91: Assertion failed in %m: Unexpected lookup/flush result hit=%b evict=%b\n",5, 'M',vlSymsp->name(),"tb_llc_flush_tag.receive", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000)
                     , '#',1,(1U & (IData)((vlSelfRef.tb_llc_flush_tag__DOT__rsp 
                                            >> 0x0000003cU)))
                     , '#',1,(1U & (IData)((vlSelfRef.tb_llc_flush_tag__DOT__rsp 
                                            >> 0x0000003bU))));
        VL_STOP_MT("tb_llc_flush_tag.sv", 91, "", false);
    }
    vlSelfRef.tb_llc_flush_tag__DOT__orr = 1U;
    Vtb_llc_flush_tag___024root____VbeforeTrig_hb04eaf3d__0(vlSelf, 
                                                            "@(posedge tb_llc_flush_tag.clk)");
    co_await vlSelfRef.__VtrigSched_hb04eaf3d__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge tb_llc_flush_tag.clk)", 
                                                         "tb_llc_flush_tag.sv", 
                                                         93);
    Vtb_llc_flush_tag___024root____VbeforeTrig_hb04eaffa__0(vlSelf, 
                                                            "@(negedge tb_llc_flush_tag.clk)");
    co_await vlSelfRef.__VtrigSched_hb04eaffa__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(negedge tb_llc_flush_tag.clk)", 
                                                         "tb_llc_flush_tag.sv", 
                                                         93);
    vlSelfRef.tb_llc_flush_tag__DOT__orr = 0U;
    while ((4U != vlSelfRef.tb_llc_flush_tag__DOT__beats)) {
        Vtb_llc_flush_tag___024root____VbeforeTrig_hd94c4b5f__0(vlSelf, 
                                                                "@( (32'sh4 == tb_llc_flush_tag.beats))");
        co_await vlSelfRef.__VtrigSched_hd94c4b5f__0.trigger(1U, 
                                                             nullptr, 
                                                             "@( (32'sh4 == tb_llc_flush_tag.beats))", 
                                                             "tb_llc_flush_tag.sv", 
                                                             152);
    }
    Vtb_llc_flush_tag___024root____VbeforeTrig_hb04eaffa__0(vlSelf, 
                                                            "@(negedge tb_llc_flush_tag.clk)");
    co_await vlSelfRef.__VtrigSched_hb04eaffa__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(negedge tb_llc_flush_tag.clk)", 
                                                         "tb_llc_flush_tag.sv", 
                                                         153);
    vlSelfRef.tb_llc_flush_tag__DOT__b = 2U;
    vlSelfRef.tb_llc_flush_tag__DOT__bv = 1U;
    do {
        Vtb_llc_flush_tag___024root____VbeforeTrig_hb04eaf3d__0(vlSelf, 
                                                                "@(posedge tb_llc_flush_tag.clk)");
        co_await vlSelfRef.__VtrigSched_hb04eaf3d__0.trigger(0U, 
                                                             nullptr, 
                                                             "@(posedge tb_llc_flush_tag.clk)", 
                                                             "tb_llc_flush_tag.sv", 
                                                             154);
    } while ((1U & (~ (IData)(vlSelfRef.tb_llc_flush_tag__DOT__br))));
    Vtb_llc_flush_tag___024root____VbeforeTrig_hb04eaffa__0(vlSelf, 
                                                            "@(negedge tb_llc_flush_tag.clk)");
    co_await vlSelfRef.__VtrigSched_hb04eaffa__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(negedge tb_llc_flush_tag.clk)", 
                                                         "tb_llc_flush_tag.sv", 
                                                         155);
    vlSelfRef.tb_llc_flush_tag__DOT__bv = 0U;
    tb_llc_flush_tag__DOT__unnamedblk1_5__DOT____Vrepeat4 = 8U;
    while (VL_LTS_III(32, 0U, tb_llc_flush_tag__DOT__unnamedblk1_5__DOT____Vrepeat4)) {
        Vtb_llc_flush_tag___024root____VbeforeTrig_hb04eaffa__0(vlSelf, 
                                                                "@(negedge tb_llc_flush_tag.clk)");
        co_await vlSelfRef.__VtrigSched_hb04eaffa__0.trigger(0U, 
                                                             nullptr, 
                                                             "@(negedge tb_llc_flush_tag.clk)", 
                                                             "tb_llc_flush_tag.sv", 
                                                             157);
        if (VL_UNLIKELY(((1U & ((((IData)(vlSelfRef.tb_llc_flush_tag__DOT__commit) 
                                  | (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__ram_we)) 
                                 | (IData)(vlSelfRef.tb_llc_flush_tag__DOT__ir)) 
                                | (~ (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__flush_wait_q))))))) {
            VL_WRITEF_NX("[%0t] %%Fatal: tb_llc_flush_tag.sv:159: Assertion failed in %m: failed B released or overwrote dirty tag\n",3, 'M',vlSymsp->name(),"tb_llc_flush_tag.unnamedblk1_5", 'T',-9
                         , '#',64,VL_TIME_UNITED_Q(1000));
            VL_STOP_MT("tb_llc_flush_tag.sv", 159, "", false);
        }
        tb_llc_flush_tag__DOT__unnamedblk1_5__DOT____Vrepeat4 
            = (tb_llc_flush_tag__DOT__unnamedblk1_5__DOT____Vrepeat4 
               - (IData)(1U));
    }
    VL_WRITEF_NX("PASS: native LLC tag/writeback path, delayed OKAY commit and SLVERR preservation\n",0);
    VL_FINISH_MT("tb_llc_flush_tag.sv", 162, "");
    co_return;
}

VlCoroutine Vtb_llc_flush_tag___024root___eval_initial__TOP__Vtiming__1(Vtb_llc_flush_tag___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_llc_flush_tag___024root___eval_initial__TOP__Vtiming__1\n"); );
    Vtb_llc_flush_tag__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    co_await vlSelfRef.__VdlySched.delay(0x0000000005f5e100ULL, 
                                         nullptr, "tb_llc_flush_tag.sv", 
                                         165);
    VL_WRITEF_NX("[%0t] %%Fatal: tb_llc_flush_tag.sv:165: Assertion failed in %m: test timeout\n",3, 'M',vlSymsp->name(),"tb_llc_flush_tag", 'T',-9
                 , '#',64,VL_TIME_UNITED_Q(1000));
    VL_STOP_MT("tb_llc_flush_tag.sv", 165, "", false);
    co_return;
}

VlCoroutine Vtb_llc_flush_tag___024root___eval_initial__TOP__Vtiming__2(Vtb_llc_flush_tag___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_llc_flush_tag___024root___eval_initial__TOP__Vtiming__2\n"); );
    Vtb_llc_flush_tag__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    while (VL_LIKELY(!vlSymsp->_vm_contextp__->gotFinish())) {
        co_await vlSelfRef.__VdlySched.delay(0x0000000000001388ULL, 
                                             nullptr, 
                                             "tb_llc_flush_tag.sv", 
                                             76);
        vlSelfRef.tb_llc_flush_tag__DOT__clk = (1U 
                                                & (~ (IData)(vlSelfRef.tb_llc_flush_tag__DOT__clk)));
    }
    co_return;
}

bool Vtb_llc_flush_tag___024root___trigger_anySet__ico(const VlUnpacked<QData/*63:0*/, 1> &in) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_llc_flush_tag___024root___trigger_anySet__ico\n"); );
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

bool Vtb_llc_flush_tag___024root___trigger_anySet__act(const VlUnpacked<QData/*63:0*/, 1> &in) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_llc_flush_tag___024root___trigger_anySet__act\n"); );
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

extern const VlUnpacked<CData/*0:0*/, 8> Vtb_llc_flush_tag__ConstPool__TABLE_hc820fc1c_0;

void Vtb_llc_flush_tag___024root___act_comb__TOP__0(Vtb_llc_flush_tag___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_llc_flush_tag___024root___act_comb__TOP__0\n"); );
    Vtb_llc_flush_tag__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    CData/*0:0*/ __VdfgRegularize_h6e95ff9d_0_30;
    __VdfgRegularize_h6e95ff9d_0_30 = 0;
    // Body
    vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__b_fill 
        = ((~ (IData)(vlSelfRef.tb_llc_flush_tag__DOT__orr)) 
           & (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__a_drain));
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_29 = ((~ (IData)(vlSelfRef.tb_llc_flush_tag__DOT__bv)) 
                                                 & (IData)(vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__busy_q));
    __VdfgRegularize_h6e95ff9d_0_30 = (IData)((((0x20U 
                                                 == 
                                                 (0x30U 
                                                  & vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__desc_q[2U])) 
                                                & (IData)(vlSelfRef.tb_llc_flush_tag__DOT__bv)) 
                                               & (IData)(vlSelfRef.tb_llc_flush_tag__DOT__br)));
    vlSelfRef.tb_llc_flush_tag__DOT____Vcellinp__writer__desc_valid_i 
        = (((IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__a_full_q) 
            | (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__b_full_q)) 
           & ((IData)(vlSelfRef.tb_llc_flush_tag__DOT__orr) 
              & (IData)(vlSelfRef.tb_llc_flush_tag__DOT__flush_mode)));
    vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__switch_busy = 0U;
    vlSelfRef.tb_llc_flush_tag__DOT__ir = 0U;
    vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__load_req = 0U;
    vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__res_valid = 0U;
    vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__ram_req = 0U;
    vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__ram_we = 0U;
    vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__ram_index = 0U;
    vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__ram_wdata = 0ULL;
    vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__gen_valid = 0U;
    if (vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__busy_q) {
        if ((2U & vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__req_q[2U])) {
            if ((1U & vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__req_q[2U])) {
                if (((IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__ram_rvalid) 
                     | (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__ram_rvalid_q))) {
                    vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__res_valid 
                        = (1U & (~ (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__maint_pending_q)));
                }
                if (((IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__res_valid) 
                     & (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__res_ready))) {
                    vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__switch_busy = 1U;
                }
            } else {
                if (((IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__ram_rvalid) 
                     | (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__ram_rvalid_q))) {
                    vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__res_valid 
                        = ((IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__hit) 
                           || Vtb_llc_flush_tag__ConstPool__TABLE_hc820fc1c_0
                           [vlSelfRef.__VdfgRegularize_h6e95ff9d_0_21]);
                }
                if ((IData)(((0x0800000000000000ULL 
                              == (0x1800000000000000ULL 
                                  & vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__res)) 
                             & (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__pending_full)))) {
                    vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__res_valid = 0U;
                }
                if (((IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__res_valid) 
                     & (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__res_ready))) {
                    if ((1U & (IData)((vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__res 
                                       >> 0x0000003cU)))) {
                        if ((1U & ((vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__req_q[0U] 
                                    >> 2U) & (~ (IData)(
                                                        (vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__gen_tag_macros__BRA__0__KET____DOT__i_tag_store__DOT__rdata_q 
                                                         >> 0x0000003bU)))))) {
                            vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__ram_req 
                                = (1U & (IData)((vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__res 
                                                 >> 0x0000003dU)));
                            vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__ram_we 
                                = (1U & (IData)((vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__res 
                                                 >> 0x0000003dU)));
                            vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__ram_index 
                                = (1U & (vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__req_q[1U] 
                                         >> 0x0000001eU));
                            vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__ram_wdata 
                                = (0x1800000000000000ULL 
                                   | (0x07ffffffffffffffULL 
                                      & (((QData)((IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__req_q[1U])) 
                                          << 0x0000001dU) 
                                         | ((QData)((IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__req_q[0U])) 
                                            >> 3U))));
                            vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__switch_busy = 1U;
                        } else if (((IData)(vlSelfRef.tb_llc_flush_tag__DOT__iv) 
                                    & (2U == vlSelfRef.tb_llc_flush_tag__DOT__req[2U]))) {
                            vlSelfRef.tb_llc_flush_tag__DOT__ir = 1U;
                            vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__ram_req 
                                = (vlSelfRef.tb_llc_flush_tag__DOT__req[1U] 
                                   >> 0x0000001fU);
                            vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__ram_index 
                                = (1U & (vlSelfRef.tb_llc_flush_tag__DOT__req[1U] 
                                         >> 0x0000001eU));
                            vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__load_req = 1U;
                        } else {
                            vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__switch_busy = 1U;
                        }
                    } else {
                        if ((1U & (~ (IData)((vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__res 
                                              >> 0x0000003bU))))) {
                            vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__ram_req 
                                = (1U & (IData)((vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__res 
                                                 >> 0x0000003dU)));
                            vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__ram_we 
                                = (1U & (IData)((vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__res 
                                                 >> 0x0000003dU)));
                            vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__ram_index 
                                = (1U & (vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__req_q[1U] 
                                         >> 0x0000001eU));
                            vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__ram_wdata 
                                = (0x1000000000000000ULL 
                                   | (((QData)((IData)(
                                                       (1U 
                                                        & (vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__req_q[0U] 
                                                           >> 2U)))) 
                                       << 0x0000003bU) 
                                      | (0x07ffffffffffffffULL 
                                         & (((QData)((IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__req_q[1U])) 
                                             << 0x0000001dU) 
                                            | ((QData)((IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__req_q[0U])) 
                                               >> 3U)))));
                        }
                        vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__switch_busy = 1U;
                    }
                }
            }
        } else if ((1U & vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__req_q[2U])) {
            if (((IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__ram_rvalid) 
                 | (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__ram_rvalid_q))) {
                vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__res_valid = 1U;
            }
            if (((IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__flush_wait_q) 
                 & (IData)(vlSelfRef.tb_llc_flush_tag__DOT__commit))) {
                vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__ram_req 
                    = (vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__req_q[1U] 
                       >> 0x0000001fU);
                vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__ram_we 
                    = (vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__req_q[1U] 
                       >> 0x0000001fU);
                vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__ram_index 
                    = (1U & (vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__req_q[1U] 
                             >> 0x0000001eU));
                vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__ram_wdata = 0ULL;
                vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__switch_busy = 1U;
            }
            if (vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__flush_wait_q) {
                vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__res_valid = 0U;
            }
        } else {
            vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__ram_req 
                = vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__en_cnt;
            vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__ram_we 
                = ((IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__busy_q) 
                   & ((~ ((IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__bist_q) 
                          >> 3U)) & ((4U & (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__bist_q))
                                      ? ((~ ((IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__bist_q) 
                                             >> 1U)) 
                                         & (IData)(vlSelfRef.__VdfgRegularize_h6e95ff9d_0_33))
                                      : (IData)(vlSelfRef.__VdfgRegularize_h6e95ff9d_0_33))));
            vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__ram_index 
                = (1U & (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__i_index_cnt__DOT__i_counter__DOT__counter_q));
            vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__ram_wdata 
                = vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__gen_pattern;
            if (vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__eoc_q) {
                vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__switch_busy = 1U;
            }
        }
    } else {
        vlSelfRef.tb_llc_flush_tag__DOT__ir = 1U;
        if (vlSelfRef.tb_llc_flush_tag__DOT__iv) {
            vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__switch_busy = 1U;
            vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__load_req = 1U;
            if ((2U & vlSelfRef.tb_llc_flush_tag__DOT__req[2U])) {
                vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__ram_req 
                    = (vlSelfRef.tb_llc_flush_tag__DOT__req[1U] 
                       >> 0x0000001fU);
                vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__ram_index 
                    = (1U & (vlSelfRef.tb_llc_flush_tag__DOT__req[1U] 
                             >> 0x0000001eU));
                vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__load_req = 1U;
                vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__switch_busy = 1U;
            } else if ((1U & vlSelfRef.tb_llc_flush_tag__DOT__req[2U])) {
                vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__ram_req 
                    = (vlSelfRef.tb_llc_flush_tag__DOT__req[1U] 
                       >> 0x0000001fU);
                vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__ram_index 
                    = (1U & (vlSelfRef.tb_llc_flush_tag__DOT__req[1U] 
                             >> 0x0000001eU));
                vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__load_req = 1U;
                vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__switch_busy = 1U;
            } else {
                vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__gen_valid = 1U;
                vlSelfRef.tb_llc_flush_tag__DOT__ir 
                    = (1U & (~ (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__busy_q)));
                vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__switch_busy 
                    = (1U & (~ (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__busy_q)));
            }
        }
    }
    if (((IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__load_req) 
         & ((IData)(vlSelfRef.__VdfgRegularize_h6e95ff9d_0_13) 
            | ((IData)(((0U == vlSelfRef.tb_llc_flush_tag__DOT__req[2U]) 
                        & ((IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__maint_pending_q) 
                           | (0U != (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__pending_valid_q))))) 
               | (((IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__maint_pending_q) 
                   & ((IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__maint_index_q) 
                      == (1U & (vlSelfRef.tb_llc_flush_tag__DOT__req[1U] 
                                >> 0x0000001eU)))) 
                  | ((((IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__pending_valid_q) 
                       >> 3U) & ((1U & (vlSelfRef.tb_llc_flush_tag__DOT__req[1U] 
                                        >> 0x0000001eU)) 
                                 == vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__pending_index_q[3U])) 
                     | ((((IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__pending_valid_q) 
                          >> 2U) & ((1U & (vlSelfRef.tb_llc_flush_tag__DOT__req[1U] 
                                           >> 0x0000001eU)) 
                                    == vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__pending_index_q[2U])) 
                        | ((((IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__pending_valid_q) 
                             >> 1U) & ((1U & (vlSelfRef.tb_llc_flush_tag__DOT__req[1U] 
                                              >> 0x0000001eU)) 
                                       == vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__pending_index_q[1U])) 
                           | (((IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__pending_valid_q) 
                               & ((1U & (vlSelfRef.tb_llc_flush_tag__DOT__req[1U] 
                                         >> 0x0000001eU)) 
                                  == vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__pending_index_q[0U])) 
                              | (IData)(vlSelfRef.__VdfgRegularize_h6e95ff9d_0_14)))))))))) {
        vlSelfRef.tb_llc_flush_tag__DOT__ir = 0U;
        vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__load_req = 0U;
        vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__ram_req = 0U;
        vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__ram_we = 0U;
        vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__gen_valid = 0U;
        vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__switch_busy 
            = vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__busy_q;
    }
    if (vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__maint_finish) {
        vlSelfRef.tb_llc_flush_tag__DOT__ir = 0U;
        vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__load_req = 0U;
        vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__switch_busy = 0U;
        vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__gen_valid = 0U;
        vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__ram_req 
            = vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__maint_way_q;
        vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__ram_we 
            = ((~ (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__maint_error_q)) 
               & (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__maint_way_q));
        vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__ram_index 
            = vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__maint_index_q;
        vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__ram_wdata 
            = ((0U == (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__maint_op_q))
                ? vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__maint_tag_q
                : 0ULL);
    }
    if (vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__pending_pop) {
        vlSelfRef.tb_llc_flush_tag__DOT__ir = 0U;
        vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__load_req = 0U;
        vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__switch_busy = 0U;
        vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__ram_req 
            = vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__pending_way_q
            [vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__pending_read_q];
        vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__ram_we 
            = vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__pending_way_q
            [vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__pending_read_q];
        vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__ram_index 
            = vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__pending_index_q
            [vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__pending_read_q];
        vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__ram_wdata 
            = vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__pending_tag_q
            [vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__pending_read_q];
        vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__gen_valid = 0U;
    }
    vlSelfRef.tb_llc_flush_tag__DOT__wb_commit = ((0U 
                                                   == (IData)(vlSelfRef.tb_llc_flush_tag__DOT__b)) 
                                                  & (IData)(__VdfgRegularize_h6e95ff9d_0_30));
    vlSelfRef.tb_llc_flush_tag__DOT__wb_error = ((0U 
                                                  != (IData)(vlSelfRef.tb_llc_flush_tag__DOT__b)) 
                                                 & (IData)(__VdfgRegularize_h6e95ff9d_0_30));
    vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__load_desc 
        = ((~ (IData)(vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__busy_q)) 
           & (IData)(vlSelfRef.tb_llc_flush_tag__DOT____Vcellinp__writer__desc_valid_i));
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_6 = ((IData)(
                                                        (vlSelfRef.tb_llc_flush_tag__DOT__rsp 
                                                         >> 0x0000003bU)) 
                                                & (IData)(vlSelfRef.tb_llc_flush_tag__DOT____Vcellinp__writer__desc_valid_i));
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_28 = ((~ (IData)(
                                                            (vlSelfRef.tb_llc_flush_tag__DOT__rsp 
                                                             >> 0x0000003bU))) 
                                                 & (IData)(vlSelfRef.tb_llc_flush_tag__DOT____Vcellinp__writer__desc_valid_i));
    vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT____Vcellinp__gen_tag_macros__BRA__0__KET____DOT__i_shift_reg_rvalid__d_i 
        = ((~ (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__ram_we)) 
           & (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__ram_req));
    vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__a_fill 
        = ((IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__res_ready) 
           & (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__res_valid));
    vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__pending_push 
        = (((((IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__busy_q) 
              & (2U == vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__req_q[2U])) 
             & (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__res_valid)) 
            & (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__res_ready)) 
           & (0x0800000000000000ULL == (0x1800000000000000ULL 
                                        & vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__res)));
}

void Vtb_llc_flush_tag___024root___nba_sequent__TOP__0(Vtb_llc_flush_tag___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_llc_flush_tag___024root___nba_sequent__TOP__0\n"); );
    Vtb_llc_flush_tag__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if (vlSymsp->_vm_contextp__->assertCtlGet(VerilatedAssertCtlQuery::ASSERT_CTL_ON, 1, 1)) {
        if (vlSymsp->_vm_contextp__->assertCtlGet(VerilatedAssertCtlQuery::ASSERT_CTL_FAIL_ON, 1, 1)) {
            if (vlSelfRef.tb_llc_flush_tag__DOT__rst) {
                if (VL_UNLIKELY(((1U & (~ ((2U != (IData)(vlSelfRef.__Vsampled_TOP__tb_llc_flush_tag__DOT__writer__DOT__i_r_data_fifo__DOT__status_cnt_q)) 
                                           | (~ (IData)(vlSelfRef.__Vsampled_TOP__tb_llc_flush_tag__DOT__writer__DOT__fifo_push)))))))) {
                    VL_WRITEF_NX("[%0t] %%Fatal: fifo_v3.sv:148: Assertion failed in %m: Trying to push new data although the FIFO is full.\n",3, 'M',vlSymsp->name(),"tb_llc_flush_tag.writer.i_r_data_fifo.full_write", 'T',-9
                                 , '#',64,VL_TIME_UNITED_Q(1000));
                    VL_STOP_MT("C:/HQuan/102_MyGithub/VLSIT_RISCV_CPU/rtl/third_party/cva6/vendor/pulp-platform/common_cells/src\\fifo_v3.sv", 148, "", false);
                }
            }
        }
    }
    if (vlSelfRef.tb_llc_flush_tag__DOT__rst) {
        if ((1U & (~ (IData)(vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__fifo_empty)))) {
            if (VL_UNLIKELY(((0x123456789abcdef0ULL 
                              != (((QData)((IData)(vlSelfRef.tb_llc_flush_tag__DOT__w[2U])) 
                                   << 0x00000037U) 
                                  | (((QData)((IData)(vlSelfRef.tb_llc_flush_tag__DOT__w[1U])) 
                                      << 0x00000017U) 
                                     | ((QData)((IData)(vlSelfRef.tb_llc_flush_tag__DOT__w[0U])) 
                                        >> 9U))))))) {
                VL_WRITEF_NX("[%0t] %%Fatal: tb_llc_flush_tag.sv:59: Assertion failed in %m: writeback data mismatch\n",3, 'M',vlSymsp->name(),"tb_llc_flush_tag", 'T',-9
                             , '#',64,VL_TIME_UNITED_Q(1000));
                VL_STOP_MT("tb_llc_flush_tag.sv", 59, "", false);
            }
            if (VL_UNLIKELY((((1U & vlSelfRef.tb_llc_flush_tag__DOT__w[0U]) 
                              != (1U & VL_MODDIVS_III(32, vlSelfRef.tb_llc_flush_tag__DOT__beats, (IData)(2U))))))) {
                VL_WRITEF_NX("[%0t] %%Fatal: tb_llc_flush_tag.sv:60: Assertion failed in %m: incorrect writeback WLAST\n",3, 'M',vlSymsp->name(),"tb_llc_flush_tag", 'T',-9
                             , '#',64,VL_TIME_UNITED_Q(1000));
                VL_STOP_MT("tb_llc_flush_tag.sv", 60, "", false);
            }
            vlSelfRef.tb_llc_flush_tag__DOT__beats 
                = ((IData)(1U) + vlSelfRef.tb_llc_flush_tag__DOT__beats);
        }
        if ((2U != (IData)(vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__i_r_data_fifo__DOT__status_cnt_q))) {
            vlSelfRef.tb_llc_flush_tag__DOT__way_rsp_valid 
                = ((IData)(vlSelfRef.__VdfgRegularize_h6e95ff9d_0_27) 
                   & (IData)(vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__busy_q));
        }
    } else {
        vlSelfRef.tb_llc_flush_tag__DOT__beats = 0U;
        vlSelfRef.tb_llc_flush_tag__DOT__way_rsp_valid = 0U;
    }
}

extern const VlUnpacked<CData/*0:0*/, 8> Vtb_llc_flush_tag__ConstPool__TABLE_hdb06591d_0;

void Vtb_llc_flush_tag___024root___nba_sequent__TOP__1(Vtb_llc_flush_tag___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_llc_flush_tag___024root___nba_sequent__TOP__1\n"); );
    Vtb_llc_flush_tag__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    CData/*1:0*/ __Vdly__tb_llc_flush_tag__DOT__dut__DOT__pending_write_q;
    __Vdly__tb_llc_flush_tag__DOT__dut__DOT__pending_write_q = 0;
    CData/*1:0*/ __Vdly__tb_llc_flush_tag__DOT__dut__DOT__pending_ack_q;
    __Vdly__tb_llc_flush_tag__DOT__dut__DOT__pending_ack_q = 0;
    CData/*1:0*/ __Vdly__tb_llc_flush_tag__DOT__dut__DOT__pending_read_q;
    __Vdly__tb_llc_flush_tag__DOT__dut__DOT__pending_read_q = 0;
    CData/*0:0*/ __Vdly__tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__busy_q;
    __Vdly__tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__busy_q = 0;
    CData/*3:0*/ __Vdly__tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__bist_q;
    __Vdly__tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__bist_q = 0;
    VlWide<3>/*69:0*/ __Vdly__tb_llc_flush_tag__DOT__writer__DOT__desc_q;
    VL_ZERO_W(70, __Vdly__tb_llc_flush_tag__DOT__writer__DOT__desc_q);
    CData/*0:0*/ __Vdly__tb_llc_flush_tag__DOT__writer__DOT__send_q;
    __Vdly__tb_llc_flush_tag__DOT__writer__DOT__send_q = 0;
    CData/*1:0*/ __Vdly__tb_llc_flush_tag__DOT__writer__DOT__i_w_to_send_counter__DOT__i_counter__DOT__counter_q;
    __Vdly__tb_llc_flush_tag__DOT__writer__DOT__i_w_to_send_counter__DOT__i_counter__DOT__counter_q = 0;
    CData/*0:0*/ __VdlyVal__tb_llc_flush_tag__DOT__dut__DOT__pending_index_q__v0;
    __VdlyVal__tb_llc_flush_tag__DOT__dut__DOT__pending_index_q__v0 = 0;
    CData/*1:0*/ __VdlyDim0__tb_llc_flush_tag__DOT__dut__DOT__pending_index_q__v0;
    __VdlyDim0__tb_llc_flush_tag__DOT__dut__DOT__pending_index_q__v0 = 0;
    CData/*0:0*/ __VdlySet__tb_llc_flush_tag__DOT__dut__DOT__pending_index_q__v0;
    __VdlySet__tb_llc_flush_tag__DOT__dut__DOT__pending_index_q__v0 = 0;
    CData/*0:0*/ __VdlySet__tb_llc_flush_tag__DOT__dut__DOT__pending_index_q__v1;
    __VdlySet__tb_llc_flush_tag__DOT__dut__DOT__pending_index_q__v1 = 0;
    CData/*0:0*/ __VdlyVal__tb_llc_flush_tag__DOT__dut__DOT__pending_way_q__v0;
    __VdlyVal__tb_llc_flush_tag__DOT__dut__DOT__pending_way_q__v0 = 0;
    CData/*1:0*/ __VdlyDim0__tb_llc_flush_tag__DOT__dut__DOT__pending_way_q__v0;
    __VdlyDim0__tb_llc_flush_tag__DOT__dut__DOT__pending_way_q__v0 = 0;
    CData/*0:0*/ __VdlySet__tb_llc_flush_tag__DOT__dut__DOT__pending_way_q__v0;
    __VdlySet__tb_llc_flush_tag__DOT__dut__DOT__pending_way_q__v0 = 0;
    CData/*0:0*/ __VdlySet__tb_llc_flush_tag__DOT__dut__DOT__pending_way_q__v1;
    __VdlySet__tb_llc_flush_tag__DOT__dut__DOT__pending_way_q__v1 = 0;
    QData/*60:0*/ __VdlyVal__tb_llc_flush_tag__DOT__dut__DOT__pending_tag_q__v0;
    __VdlyVal__tb_llc_flush_tag__DOT__dut__DOT__pending_tag_q__v0 = 0;
    CData/*1:0*/ __VdlyDim0__tb_llc_flush_tag__DOT__dut__DOT__pending_tag_q__v0;
    __VdlyDim0__tb_llc_flush_tag__DOT__dut__DOT__pending_tag_q__v0 = 0;
    CData/*0:0*/ __VdlySet__tb_llc_flush_tag__DOT__dut__DOT__pending_tag_q__v0;
    __VdlySet__tb_llc_flush_tag__DOT__dut__DOT__pending_tag_q__v0 = 0;
    CData/*0:0*/ __VdlySet__tb_llc_flush_tag__DOT__dut__DOT__pending_tag_q__v1;
    __VdlySet__tb_llc_flush_tag__DOT__dut__DOT__pending_tag_q__v1 = 0;
    QData/*60:0*/ __VdlyVal__tb_llc_flush_tag__DOT__dut__DOT__gen_tag_macros__BRA__0__KET____DOT__i_tag_store__DOT__sram__v0;
    __VdlyVal__tb_llc_flush_tag__DOT__dut__DOT__gen_tag_macros__BRA__0__KET____DOT__i_tag_store__DOT__sram__v0 = 0;
    CData/*0:0*/ __VdlyDim0__tb_llc_flush_tag__DOT__dut__DOT__gen_tag_macros__BRA__0__KET____DOT__i_tag_store__DOT__sram__v0;
    __VdlyDim0__tb_llc_flush_tag__DOT__dut__DOT__gen_tag_macros__BRA__0__KET____DOT__i_tag_store__DOT__sram__v0 = 0;
    CData/*0:0*/ __VdlySet__tb_llc_flush_tag__DOT__dut__DOT__gen_tag_macros__BRA__0__KET____DOT__i_tag_store__DOT__sram__v0;
    __VdlySet__tb_llc_flush_tag__DOT__dut__DOT__gen_tag_macros__BRA__0__KET____DOT__i_tag_store__DOT__sram__v0 = 0;
    // Body
    __VdlySet__tb_llc_flush_tag__DOT__dut__DOT__gen_tag_macros__BRA__0__KET____DOT__i_tag_store__DOT__sram__v0 = 0U;
    __Vdly__tb_llc_flush_tag__DOT__writer__DOT__i_w_to_send_counter__DOT__i_counter__DOT__counter_q 
        = vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__i_w_to_send_counter__DOT__i_counter__DOT__counter_q;
    __Vdly__tb_llc_flush_tag__DOT__writer__DOT__desc_q[0U] 
        = vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__desc_q[0U];
    __Vdly__tb_llc_flush_tag__DOT__writer__DOT__desc_q[1U] 
        = vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__desc_q[1U];
    __Vdly__tb_llc_flush_tag__DOT__writer__DOT__desc_q[2U] 
        = vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__desc_q[2U];
    __Vdly__tb_llc_flush_tag__DOT__dut__DOT__pending_write_q 
        = vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__pending_write_q;
    __Vdly__tb_llc_flush_tag__DOT__writer__DOT__send_q 
        = vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__send_q;
    __VdlySet__tb_llc_flush_tag__DOT__dut__DOT__pending_way_q__v0 = 0U;
    __VdlySet__tb_llc_flush_tag__DOT__dut__DOT__pending_way_q__v1 = 0U;
    __Vdly__tb_llc_flush_tag__DOT__dut__DOT__pending_read_q 
        = vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__pending_read_q;
    __Vdly__tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__busy_q 
        = vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__busy_q;
    __Vdly__tb_llc_flush_tag__DOT__dut__DOT__pending_ack_q 
        = vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__pending_ack_q;
    __Vdly__tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__bist_q 
        = vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__bist_q;
    __VdlySet__tb_llc_flush_tag__DOT__dut__DOT__pending_index_q__v0 = 0U;
    __VdlySet__tb_llc_flush_tag__DOT__dut__DOT__pending_index_q__v1 = 0U;
    __VdlySet__tb_llc_flush_tag__DOT__dut__DOT__pending_tag_q__v0 = 0U;
    __VdlySet__tb_llc_flush_tag__DOT__dut__DOT__pending_tag_q__v1 = 0U;
    vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__i_r_data_fifo__DOT__read_pointer_q 
        = ((IData)(vlSelfRef.tb_llc_flush_tag__DOT__rst) 
           && (1U & ((IData)(vlSelfRef.__VdfgRegularize_h6e95ff9d_0_5)
                      ? (IData)(vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__i_r_data_fifo__DOT__read_pointer_q)
                      : ((IData)(vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__fifo_empty)
                          ? (IData)(vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__i_r_data_fifo__DOT__read_pointer_q)
                          : ((IData)(1U) + (IData)(vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__i_r_data_fifo__DOT__read_pointer_q))))));
    vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__i_r_data_fifo__DOT__write_pointer_q 
        = ((IData)(vlSelfRef.tb_llc_flush_tag__DOT__rst) 
           && ((IData)(vlSelfRef.__VdfgRegularize_h6e95ff9d_0_5)
                ? ((IData)(vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__fifo_empty)
                    ? (IData)(vlSelfRef.__VdfgRegularize_h6e95ff9d_0_24)
                    : (IData)(vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__i_r_data_fifo__DOT__write_pointer_q))
                : (IData)(vlSelfRef.__VdfgRegularize_h6e95ff9d_0_24)));
    if (vlSelfRef.tb_llc_flush_tag__DOT__rst) {
        vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__i_block_offset_counter__DOT__i_counter__DOT__counter_q 
            = (3U & ((- (IData)((1U & ((~ (IData)(vlSelfRef.__VdfgRegularize_h6e95ff9d_0_6)) 
                                       | (IData)(vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__busy_q))))) 
                     & ((IData)(vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__i_block_offset_counter__DOT__i_counter__DOT__counter_q) 
                        + ((IData)(vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__busy_q) 
                           & ((2U != (IData)(vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__i_r_data_fifo__DOT__status_cnt_q)) 
                              & (IData)(vlSelfRef.__VdfgRegularize_h6e95ff9d_0_27))))));
        __Vdly__tb_llc_flush_tag__DOT__writer__DOT__i_w_to_send_counter__DOT__i_counter__DOT__counter_q 
            = (((~ (IData)(vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__busy_q)) 
                & (IData)(vlSelfRef.__VdfgRegularize_h6e95ff9d_0_6))
                ? 1U : (3U & ((IData)(vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__i_w_to_send_counter__DOT__i_counter__DOT__counter_q) 
                              - ((~ ((IData)(vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__send_q) 
                                     | (IData)(vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__fifo_empty))) 
                                 & (IData)(vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__busy_q)))));
        if (((IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__b_fill) 
             | ((IData)(vlSelfRef.tb_llc_flush_tag__DOT__orr) 
                & (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__b_full_q)))) {
            vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__b_full_q 
                = vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__b_fill;
        }
        vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__i_r_data_fifo__DOT__status_cnt_q 
            = ((IData)(vlSelfRef.__VdfgRegularize_h6e95ff9d_0_5)
                ? ((IData)(vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__fifo_empty)
                    ? (IData)(vlSelfRef.__VdfgRegularize_h6e95ff9d_0_25)
                    : (IData)(vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__i_r_data_fifo__DOT__status_cnt_q))
                : (IData)(vlSelfRef.__VdfgRegularize_h6e95ff9d_0_25));
        if (vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__load_desc) {
            if (vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__busy_q) {
                __Vdly__tb_llc_flush_tag__DOT__writer__DOT__desc_q[0U] 
                    = vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__desc_q[0U];
                __Vdly__tb_llc_flush_tag__DOT__writer__DOT__desc_q[1U] 
                    = vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__desc_q[1U];
                __Vdly__tb_llc_flush_tag__DOT__writer__DOT__desc_q[2U] 
                    = vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__desc_q[2U];
            } else if (vlSelfRef.tb_llc_flush_tag__DOT____Vcellinp__writer__desc_valid_i) {
                __Vdly__tb_llc_flush_tag__DOT__writer__DOT__desc_q[0U] = 0x00002460U;
                __Vdly__tb_llc_flush_tag__DOT__writer__DOT__desc_q[1U] = 0U;
                __Vdly__tb_llc_flush_tag__DOT__writer__DOT__desc_q[2U] 
                    = (1U | (0x00000020U & ((IData)(
                                                    (vlSelfRef.tb_llc_flush_tag__DOT__rsp 
                                                     >> 0x0000003bU)) 
                                            << 5U)));
            } else {
                __Vdly__tb_llc_flush_tag__DOT__writer__DOT__desc_q[0U] 
                    = vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__desc_q[0U];
                __Vdly__tb_llc_flush_tag__DOT__writer__DOT__desc_q[1U] 
                    = vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__desc_q[1U];
                __Vdly__tb_llc_flush_tag__DOT__writer__DOT__desc_q[2U] 
                    = vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__desc_q[2U];
            }
            vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__wb_failed_q = 0U;
        }
        if (((IData)(vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__busy_q)
              ? ((~ (IData)(vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__send_q)) 
                 & (IData)(vlSelfRef.__VdfgRegularize_h6e95ff9d_0_11))
              : ((IData)(vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__send_q) 
                 | (IData)(vlSelfRef.__VdfgRegularize_h6e95ff9d_0_28)))) {
            __Vdly__tb_llc_flush_tag__DOT__writer__DOT__send_q 
                = (1U & ((IData)(vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__busy_q)
                          ? ((IData)(vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__send_q) 
                             | ((IData)(vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__fifo_empty)
                                 ? (IData)(vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__send_q)
                                 : ((~ (IData)(vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__i_w_to_send_counter__DOT__i_counter__DOT__counter_q)) 
                                    | (IData)(vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__send_q))))
                          : (IData)(vlSelfRef.__VdfgRegularize_h6e95ff9d_0_28)));
        }
        if (((IData)(vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__busy_q)
              ? ((IData)(vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__send_q)
                  ? (IData)(vlSelfRef.tb_llc_flush_tag__DOT__bv)
                  : ((IData)(vlSelfRef.tb_llc_flush_tag__DOT__bv) 
                     & (IData)(vlSelfRef.__VdfgRegularize_h6e95ff9d_0_11)))
              : (IData)(vlSelfRef.__VdfgRegularize_h6e95ff9d_0_6))) {
            vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__busy_q 
                = ((IData)(vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__busy_q)
                    ? ((IData)(vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__send_q)
                        ? (IData)(vlSelfRef.__VdfgRegularize_h6e95ff9d_0_29)
                        : ((IData)(vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__fifo_empty)
                            ? (IData)(vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__busy_q)
                            : ((1U & (IData)(vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__i_w_to_send_counter__DOT__i_counter__DOT__counter_q))
                                ? (IData)(vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__busy_q)
                                : (IData)(vlSelfRef.__VdfgRegularize_h6e95ff9d_0_29))))
                    : ((IData)(vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__busy_q) 
                       | (IData)(vlSelfRef.__VdfgRegularize_h6e95ff9d_0_6)));
        }
        if (((IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__busy_q)
              ? ((~ ((IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__bist_q) 
                     >> 3U)) & (IData)(vlSelfRef.__VdfgRegularize_h6e95ff9d_0_32))
              : (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__gen_valid))) {
            __Vdly__tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__busy_q 
                = ((IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__busy_q)
                    ? ((8U & (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__bist_q))
                        ? (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__busy_q)
                        : ((4U & (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__bist_q))
                            ? ((2U & (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__bist_q))
                                ? ((IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__busy_q) 
                                   & (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__bist_q))
                                : (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__busy_q))
                            : (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__busy_q)))
                    : ((IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__gen_valid) 
                       | (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__busy_q)));
        }
        if ((((IData)(vlSelfRef.tb_llc_flush_tag__DOT__wb_commit) 
              | (IData)(vlSelfRef.tb_llc_flush_tag__DOT__wb_error)) 
             & ((IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__pending_valid_q) 
                >> (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__pending_ack_q)))) {
            __Vdly__tb_llc_flush_tag__DOT__dut__DOT__pending_ack_q 
                = ((3U == (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__pending_ack_q))
                    ? 0U : (3U & ((IData)(1U) + (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__pending_ack_q))));
        }
        if (vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__pending_push) {
            __Vdly__tb_llc_flush_tag__DOT__dut__DOT__pending_write_q 
                = ((3U == (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__pending_write_q))
                    ? 0U : (3U & ((IData)(1U) + (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__pending_write_q))));
            __VdlyVal__tb_llc_flush_tag__DOT__dut__DOT__pending_way_q__v0 
                = (1U & (IData)((vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__res 
                                 >> 0x0000003dU)));
            __VdlyDim0__tb_llc_flush_tag__DOT__dut__DOT__pending_way_q__v0 
                = vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__pending_write_q;
            __VdlySet__tb_llc_flush_tag__DOT__dut__DOT__pending_way_q__v0 = 1U;
            __VdlyVal__tb_llc_flush_tag__DOT__dut__DOT__pending_index_q__v0 
                = (1U & (vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__req_q[1U] 
                         >> 0x0000001eU));
            __VdlyDim0__tb_llc_flush_tag__DOT__dut__DOT__pending_index_q__v0 
                = vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__pending_write_q;
            __VdlySet__tb_llc_flush_tag__DOT__dut__DOT__pending_index_q__v0 = 1U;
            __VdlyVal__tb_llc_flush_tag__DOT__dut__DOT__pending_tag_q__v0 
                = (0x1000000000000000ULL | (((QData)((IData)(
                                                             (1U 
                                                              & (vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__req_q[0U] 
                                                                 >> 2U)))) 
                                             << 0x0000003bU) 
                                            | (0x07ffffffffffffffULL 
                                               & (((QData)((IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__req_q[1U])) 
                                                   << 0x0000001dU) 
                                                  | ((QData)((IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__req_q[0U])) 
                                                     >> 3U)))));
            __VdlyDim0__tb_llc_flush_tag__DOT__dut__DOT__pending_tag_q__v0 
                = vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__pending_write_q;
            __VdlySet__tb_llc_flush_tag__DOT__dut__DOT__pending_tag_q__v0 = 1U;
            vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__pending_done_q 
                = ((~ ((IData)(1U) << (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__pending_write_q))) 
                   & (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__pending_done_q));
        }
        if ((((IData)(vlSelfRef.tb_llc_flush_tag__DOT__wb_commit) 
              | (IData)(vlSelfRef.tb_llc_flush_tag__DOT__wb_error)) 
             & ((IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__pending_valid_q) 
                >> (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__pending_ack_q)))) {
            vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__pending_done_q 
                = (((~ ((IData)(1U) << (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__pending_ack_q))) 
                    & (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__pending_done_q)) 
                   | (0x0fU & ((IData)(vlSelfRef.tb_llc_flush_tag__DOT__wb_commit) 
                               << (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__pending_ack_q))));
        }
        if (vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__pending_push) {
            vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__pending_valid_q 
                = ((IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__pending_valid_q) 
                   | (0x0fU & ((IData)(1U) << (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__pending_write_q))));
        }
        if (vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__pending_pop) {
            __Vdly__tb_llc_flush_tag__DOT__dut__DOT__pending_read_q 
                = ((3U == (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__pending_read_q))
                    ? 0U : (3U & ((IData)(1U) + (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__pending_read_q))));
            vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__pending_done_q 
                = ((~ ((IData)(1U) << (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__pending_read_q))) 
                   & (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__pending_done_q));
            vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__pending_valid_q 
                = ((~ ((IData)(1U) << (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__pending_read_q))) 
                   & (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__pending_valid_q));
        }
        if (((IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__busy_q) 
             & ((IData)(vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0) 
                & ((4U & (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__bist_q))
                    ? ((2U & (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__bist_q))
                        ? (IData)(vlSelfRef.__VdfgRegularize_h6e95ff9d_0_3)
                        : (IData)(vlSelfRef.__VdfgRegularize_h6e95ff9d_0_4))
                    : (IData)(vlSelfRef.__VdfgRegularize_h6e95ff9d_0_4))))) {
            __Vdly__tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__bist_q 
                = ((IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__busy_q)
                    ? ((8U & (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__bist_q))
                        ? (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__bist_q)
                        : ((4U & (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__bist_q))
                            ? ((2U & (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__bist_q))
                                ? ((IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__bist_q) 
                                   & (- (IData)((1U 
                                                 & (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__bist_q)))))
                                : ((1U & (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__bist_q))
                                    ? ((2U & (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__i_index_cnt__DOT__i_counter__DOT__counter_q))
                                        ? ((IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__bist_valid)
                                            ? (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__bist_q)
                                            : 6U) : (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__bist_q))
                                    : ((2U & (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__i_index_cnt__DOT__i_counter__DOT__counter_q))
                                        ? 5U : (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__bist_q))))
                            : ((2U & (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__bist_q))
                                ? ((1U & (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__bist_q))
                                    ? ((2U & (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__i_index_cnt__DOT__i_counter__DOT__counter_q))
                                        ? ((IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__bist_valid)
                                            ? (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__bist_q)
                                            : 4U) : (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__bist_q))
                                    : ((2U & (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__i_index_cnt__DOT__i_counter__DOT__counter_q))
                                        ? 3U : (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__bist_q)))
                                : ((1U & (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__bist_q))
                                    ? ((2U & (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__i_index_cnt__DOT__i_counter__DOT__counter_q))
                                        ? ((IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__bist_valid)
                                            ? (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__bist_q)
                                            : 2U) : (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__bist_q))
                                    : ((2U & (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__i_index_cnt__DOT__i_counter__DOT__counter_q))
                                        ? 1U : (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__bist_q))))))
                    : (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__bist_q));
        }
        vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__i_index_cnt__DOT__i_counter__DOT__counter_q 
            = (3U & (((IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__load_cnt)
                       ? (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__load_cnt)
                       : ((IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__en_cnt)
                           ? (((IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__busy_q) 
                               & ((~ ((IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__bist_q) 
                                      >> 3U)) & ((4U 
                                                  & (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__bist_q))
                                                  ? (IData)(vlSelfRef.__VdfgRegularize_h6e95ff9d_0_34)
                                                  : 
                                                 ((IData)(vlSelfRef.__VdfgRegularize_h6e95ff9d_0_1) 
                                                  & (3U 
                                                     == 
                                                     (3U 
                                                      & (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__bist_q)))))))
                               ? ((IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__i_index_cnt__DOT__i_counter__DOT__counter_q) 
                                  - (IData)(1U)) : 
                              ((IData)(1U) + (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__i_index_cnt__DOT__i_counter__DOT__counter_q)))
                           : (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__i_index_cnt__DOT__i_counter__DOT__counter_q))) 
                     & (- (IData)((1U & (~ ((IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__busy_q)
                                             ? ((~ 
                                                 ((IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__bist_q) 
                                                  >> 3U)) 
                                                & ((4U 
                                                    & (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__bist_q))
                                                    ? (IData)(
                                                              ((1U 
                                                                == 
                                                                (3U 
                                                                 & (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__bist_q))) 
                                                               & (IData)(vlSelfRef.__VdfgRegularize_h6e95ff9d_0_35)))
                                                    : 
                                                   ((~ 
                                                     ((IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__bist_q) 
                                                      >> 1U)) 
                                                    & (IData)(vlSelfRef.__VdfgRegularize_h6e95ff9d_0_4))))
                                             : (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__gen_valid))))))));
        if (vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__fifo_push) {
            vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__i_r_data_fifo__DOT__mem_q[0U] 
                = vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__i_r_data_fifo__DOT__mem_n[0U];
            vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__i_r_data_fifo__DOT__mem_q[1U] 
                = vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__i_r_data_fifo__DOT__mem_n[1U];
            vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__i_r_data_fifo__DOT__mem_q[2U] 
                = vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__i_r_data_fifo__DOT__mem_n[2U];
            vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__i_r_data_fifo__DOT__mem_q[3U] 
                = vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__i_r_data_fifo__DOT__mem_n[3U];
        }
        if ((IData)(((((0x20U == (0x28U & vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__desc_q[2U])) 
                       & (IData)(vlSelfRef.tb_llc_flush_tag__DOT__bv)) 
                      & (IData)(vlSelfRef.tb_llc_flush_tag__DOT__br)) 
                     & (0U != (IData)(vlSelfRef.tb_llc_flush_tag__DOT__b))))) {
            vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__wb_fault_q = 1U;
        }
        if (((IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__a_fill) 
             | (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__a_drain))) {
            vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__a_full_q 
                = vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__a_fill;
        }
        if (vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__b_fill) {
            vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__b_data_q 
                = vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__a_data_q;
        }
        if (((((vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__desc_q[2U] 
                >> 5U) & (IData)(vlSelfRef.tb_llc_flush_tag__DOT__bv)) 
              & (IData)(vlSelfRef.tb_llc_flush_tag__DOT__br)) 
             & (0U != (IData)(vlSelfRef.tb_llc_flush_tag__DOT__b)))) {
            vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__wb_failed_q = 1U;
        }
        vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__bist_pattern 
            = vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__gen_pattern;
        if (((IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__ram_rvalid) 
             | (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__a_fill))) {
            vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__ram_rvalid_q 
                = ((~ (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__a_fill)) 
                   & (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__ram_rvalid));
        }
        vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__gen_tag_macros__BRA__0__KET____DOT__i_tag_store__DOT__rdata_q 
            = ((IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT____Vcellinp__gen_tag_macros__BRA__0__KET____DOT__i_shift_reg_rvalid__d_i)
                ? vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__gen_tag_macros__BRA__0__KET____DOT__i_tag_store__DOT__sram
               [vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__ram_index]
                : vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__gen_tag_macros__BRA__0__KET____DOT__i_tag_store__DOT__sram
               [vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__gen_tag_macros__BRA__0__KET____DOT__i_tag_store__DOT__r_addr_q]);
        if (vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__ram_req) {
            if (vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__ram_we) {
                __VdlyVal__tb_llc_flush_tag__DOT__dut__DOT__gen_tag_macros__BRA__0__KET____DOT__i_tag_store__DOT__sram__v0 
                    = vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__ram_wdata;
                __VdlyDim0__tb_llc_flush_tag__DOT__dut__DOT__gen_tag_macros__BRA__0__KET____DOT__i_tag_store__DOT__sram__v0 
                    = vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__ram_index;
                __VdlySet__tb_llc_flush_tag__DOT__dut__DOT__gen_tag_macros__BRA__0__KET____DOT__i_tag_store__DOT__sram__v0 = 1U;
            }
            if ((1U & (~ (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__ram_we)))) {
                vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__gen_tag_macros__BRA__0__KET____DOT__i_tag_store__DOT__r_addr_q 
                    = vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__ram_index;
            }
        }
        if (((((IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__busy_q) 
               & (3U == vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__req_q[2U])) 
              & (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__res_valid)) 
             & (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__res_ready))) {
            vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__maint_error_q = 0U;
            vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__maint_index_q 
                = (1U & (vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__req_q[1U] 
                         >> 0x0000001eU));
            vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__maint_tag_q 
                = (0x1000000000000000ULL | (0x07ffffffffffffffULL 
                                            & (((QData)((IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__req_q[1U])) 
                                                << 0x0000001dU) 
                                               | ((QData)((IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__req_q[0U])) 
                                                  >> 3U))));
            vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__maint_op_q 
                = (3U & vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__req_q[0U]);
            vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__maint_way_q 
                = (1U & (IData)((vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__res 
                                 >> 0x0000003dU)));
            vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__maint_result_q = 0U;
            vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__maint_pending_q = 1U;
        }
        if (((((IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__busy_q) 
               & (1U == vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__req_q[2U])) 
              & (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__res_valid)) 
             & (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__res_ready))) {
            vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__flush_wait_q = 1U;
        }
        if (vlSelfRef.tb_llc_flush_tag__DOT__commit) {
            vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__flush_wait_q = 0U;
        }
        if (vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__maint_finish) {
            vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__maint_result_q = 0U;
            vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__maint_pending_q = 0U;
        }
        if (vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__a_fill) {
            vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__a_data_q 
                = vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__res;
        }
        if (vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__switch_busy) {
            vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__busy_q 
                = vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__busy_d;
        }
        if (vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__load_req) {
            vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__req_q[0U] 
                = vlSelfRef.tb_llc_flush_tag__DOT__req[0U];
            vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__req_q[1U] 
                = vlSelfRef.tb_llc_flush_tag__DOT__req[1U];
            vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__req_q[2U] 
                = vlSelfRef.tb_llc_flush_tag__DOT__req[2U];
        }
    } else {
        vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__i_block_offset_counter__DOT__i_counter__DOT__counter_q = 0U;
        __Vdly__tb_llc_flush_tag__DOT__writer__DOT__i_w_to_send_counter__DOT__i_counter__DOT__counter_q = 0U;
        vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__b_full_q = 0U;
        vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__i_r_data_fifo__DOT__status_cnt_q = 0U;
        __Vdly__tb_llc_flush_tag__DOT__writer__DOT__desc_q[0U] = 0U;
        __Vdly__tb_llc_flush_tag__DOT__writer__DOT__desc_q[1U] = 0U;
        __Vdly__tb_llc_flush_tag__DOT__writer__DOT__desc_q[2U] = 0U;
        __Vdly__tb_llc_flush_tag__DOT__dut__DOT__pending_write_q = 0U;
        __Vdly__tb_llc_flush_tag__DOT__writer__DOT__send_q = 0U;
        vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__busy_q = 0U;
        __VdlySet__tb_llc_flush_tag__DOT__dut__DOT__pending_way_q__v1 = 1U;
        __Vdly__tb_llc_flush_tag__DOT__dut__DOT__pending_read_q = 0U;
        __Vdly__tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__busy_q = 0U;
        __Vdly__tb_llc_flush_tag__DOT__dut__DOT__pending_ack_q = 0U;
        __Vdly__tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__bist_q = 0U;
        vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__i_index_cnt__DOT__i_counter__DOT__counter_q = 0U;
        __VdlySet__tb_llc_flush_tag__DOT__dut__DOT__pending_index_q__v1 = 1U;
        __VdlySet__tb_llc_flush_tag__DOT__dut__DOT__pending_tag_q__v1 = 1U;
        vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__i_r_data_fifo__DOT__mem_q[0U] = 0U;
        vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__i_r_data_fifo__DOT__mem_q[1U] = 0U;
        vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__i_r_data_fifo__DOT__mem_q[2U] = 0U;
        vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__i_r_data_fifo__DOT__mem_q[3U] = 0U;
        vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__wb_fault_q = 0U;
        vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__a_full_q = 0U;
        vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__b_data_q = 0ULL;
        vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__wb_failed_q = 0U;
        vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__bist_pattern = 0ULL;
        vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__ram_rvalid_q = 0U;
        vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__pending_done_q = 0U;
        vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__maint_error_q = 0U;
        vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__maint_index_q = 0U;
        vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__maint_tag_q = 0ULL;
        vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__maint_op_q = 0U;
        vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__flush_wait_q = 0U;
        vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__maint_way_q = 0U;
        vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__maint_result_q = 0U;
        vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__maint_pending_q = 0U;
        vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__a_data_q = 0ULL;
        vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__gen_tag_macros__BRA__0__KET____DOT__i_tag_store__DOT__r_addr_q = 0U;
        vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__pending_valid_q = 0U;
        vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__busy_q = 0U;
        vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__req_q[0U] = 0U;
        vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__req_q[1U] = 0U;
        vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__req_q[2U] = 0U;
    }
    vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__eoc_q 
        = ((IData)(vlSelfRef.tb_llc_flush_tag__DOT__rst) 
           && ((IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__busy_q)
                ? ((8U & (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__bist_q))
                    ? (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__eoc_q)
                    : ((IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__eoc_q) 
                       | (IData)(vlSelfRef.__VdfgRegularize_h6e95ff9d_0_32)))
                : (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__eoc_q)));
    vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__i_w_to_send_counter__DOT__i_counter__DOT__counter_q 
        = __Vdly__tb_llc_flush_tag__DOT__writer__DOT__i_w_to_send_counter__DOT__i_counter__DOT__counter_q;
    vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__send_q 
        = __Vdly__tb_llc_flush_tag__DOT__writer__DOT__send_q;
    if (__VdlySet__tb_llc_flush_tag__DOT__dut__DOT__pending_way_q__v0) {
        vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__pending_way_q[__VdlyDim0__tb_llc_flush_tag__DOT__dut__DOT__pending_way_q__v0] 
            = __VdlyVal__tb_llc_flush_tag__DOT__dut__DOT__pending_way_q__v0;
    }
    if (__VdlySet__tb_llc_flush_tag__DOT__dut__DOT__pending_way_q__v1) {
        vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__pending_way_q[0U] = 0U;
        vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__pending_way_q[1U] = 0U;
        vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__pending_way_q[2U] = 0U;
        vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__pending_way_q[3U] = 0U;
    }
    vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__busy_q 
        = __Vdly__tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__busy_q;
    vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__bist_q 
        = __Vdly__tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__bist_q;
    if (__VdlySet__tb_llc_flush_tag__DOT__dut__DOT__pending_index_q__v0) {
        vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__pending_index_q[__VdlyDim0__tb_llc_flush_tag__DOT__dut__DOT__pending_index_q__v0] 
            = __VdlyVal__tb_llc_flush_tag__DOT__dut__DOT__pending_index_q__v0;
    }
    if (__VdlySet__tb_llc_flush_tag__DOT__dut__DOT__pending_index_q__v1) {
        vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__pending_index_q[0U] = 0U;
        vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__pending_index_q[1U] = 0U;
        vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__pending_index_q[2U] = 0U;
        vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__pending_index_q[3U] = 0U;
    }
    if (__VdlySet__tb_llc_flush_tag__DOT__dut__DOT__pending_tag_q__v0) {
        vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__pending_tag_q[__VdlyDim0__tb_llc_flush_tag__DOT__dut__DOT__pending_tag_q__v0] 
            = __VdlyVal__tb_llc_flush_tag__DOT__dut__DOT__pending_tag_q__v0;
    }
    if (__VdlySet__tb_llc_flush_tag__DOT__dut__DOT__pending_tag_q__v1) {
        vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__pending_tag_q[0U] = 0ULL;
        vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__pending_tag_q[1U] = 0ULL;
        vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__pending_tag_q[2U] = 0ULL;
        vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__pending_tag_q[3U] = 0ULL;
    }
    vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__desc_q[0U] 
        = __Vdly__tb_llc_flush_tag__DOT__writer__DOT__desc_q[0U];
    vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__desc_q[1U] 
        = __Vdly__tb_llc_flush_tag__DOT__writer__DOT__desc_q[1U];
    vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__desc_q[2U] 
        = __Vdly__tb_llc_flush_tag__DOT__writer__DOT__desc_q[2U];
    if (__VdlySet__tb_llc_flush_tag__DOT__dut__DOT__gen_tag_macros__BRA__0__KET____DOT__i_tag_store__DOT__sram__v0) {
        vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__gen_tag_macros__BRA__0__KET____DOT__i_tag_store__DOT__sram[__VdlyDim0__tb_llc_flush_tag__DOT__dut__DOT__gen_tag_macros__BRA__0__KET____DOT__i_tag_store__DOT__sram__v0] 
            = __VdlyVal__tb_llc_flush_tag__DOT__dut__DOT__gen_tag_macros__BRA__0__KET____DOT__i_tag_store__DOT__sram__v0;
    }
    vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__pending_ack_q 
        = __Vdly__tb_llc_flush_tag__DOT__dut__DOT__pending_ack_q;
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_27 = (1U 
                                                 & (~ 
                                                    ((IData)(vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__send_q) 
                                                     | ((IData)(vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__i_block_offset_counter__DOT__i_counter__DOT__counter_q) 
                                                        >> 1U))));
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0 = (1U 
                                                & (~ 
                                                   ((IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__bist_q) 
                                                    >> 3U)));
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_3 = (1U 
                                                & (~ (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__bist_q)));
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_32 = (IData)(
                                                        (6U 
                                                         == 
                                                         (7U 
                                                          & (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__bist_q))));
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_1 = (1U 
                                                & (~ 
                                                   ((IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__i_index_cnt__DOT__i_counter__DOT__counter_q) 
                                                    >> 1U)));
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_33 = (1U 
                                                 & ((~ (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__bist_q)) 
                                                    & (~ 
                                                       ((IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__i_index_cnt__DOT__i_counter__DOT__counter_q) 
                                                        >> 1U))));
    vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__gen_pattern 
        = (0x1fffffffffffffffULL & ((- (QData)((IData)(
                                                       ((2U 
                                                         == 
                                                         (0x0eU 
                                                          & (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__bist_q))) 
                                                        & (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__busy_q))))) 
                                    & (- (QData)((IData)(
                                                         (1U 
                                                          & (~ 
                                                             ((IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__i_index_cnt__DOT__i_counter__DOT__counter_q) 
                                                              >> 1U))))))));
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_34 = (1U 
                                                 & ((~ 
                                                     ((IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__bist_q) 
                                                      >> 1U)) 
                                                    & (~ 
                                                       ((IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__i_index_cnt__DOT__i_counter__DOT__counter_q) 
                                                        >> 1U))));
    vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__a_drain 
        = ((~ (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__b_full_q)) 
           & (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__a_full_q));
    vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__res_ready 
        = (1U & (~ ((IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__a_full_q) 
                    & (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__b_full_q))));
    vlSelfRef.tb_llc_flush_tag__DOT__commit = ((((IData)(vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__send_q) 
                                                 & (~ (IData)(vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__wb_failed_q))) 
                                                & (~ (IData)(vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__busy_q))) 
                                               & (0x10U 
                                                  == 
                                                  (0x18U 
                                                   & vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__desc_q[2U])));
    vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__ram_rvalid 
        = ((IData)(vlSelfRef.tb_llc_flush_tag__DOT__rst) 
           && (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT____Vcellinp__gen_tag_macros__BRA__0__KET____DOT__i_shift_reg_rvalid__d_i));
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_13 = ((IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__maint_pending_q) 
                                                 & (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__maint_result_q));
    vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__en_cnt 
        = ((IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__busy_q) 
           & ((~ ((IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__bist_q) 
                  >> 3U)) & ((4U & (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__bist_q))
                              ? (IData)(vlSelfRef.__VdfgRegularize_h6e95ff9d_0_34)
                              : (~ ((IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__i_index_cnt__DOT__i_counter__DOT__counter_q) 
                                    >> 1U)))));
    vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__pending_write_q 
        = __Vdly__tb_llc_flush_tag__DOT__dut__DOT__pending_write_q;
    vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__pending_read_q 
        = __Vdly__tb_llc_flush_tag__DOT__dut__DOT__pending_read_q;
    vlSelfRef.tb_llc_flush_tag__DOT__rsp = ((IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__b_full_q)
                                             ? vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__b_data_q
                                             : vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__a_data_q);
    vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__pending_full 
        = (1U & ((IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__pending_valid_q) 
                 >> (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__pending_write_q)));
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_14 = (1U 
                                                 & (((IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__pending_valid_q) 
                                                     & (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__pending_done_q)) 
                                                    >> (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__pending_read_q)));
    vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__busy_d 
        = (1U & (~ (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__busy_q)));
    vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__maint_finish 
        = ((~ (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__busy_q)) 
           & (IData)(vlSelfRef.__VdfgRegularize_h6e95ff9d_0_13));
    vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__bist_valid 
        = ((IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__busy_q) 
           & ((~ vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__req_q[2U]) 
              & ((~ (vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__req_q[2U] 
                     >> 1U)) & (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__ram_rvalid))));
    vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__hit 
        = ((vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__req_q[1U] 
            >> 0x0000001fU) & ((0x07ffffffffffffffULL 
                                == (0x07ffffffffffffffULL 
                                    & (~ (((0U == (3U 
                                                   & vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__req_q[2U]))
                                            ? vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__bist_pattern
                                            : (((QData)((IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__req_q[1U])) 
                                                << 0x0000003dU) 
                                               | (((QData)((IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__req_q[1U])) 
                                                   << 0x0000001dU) 
                                                  | ((QData)((IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__req_q[0U])) 
                                                     >> 3U)))) 
                                          ^ vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__gen_tag_macros__BRA__0__KET____DOT__i_tag_store__DOT__rdata_q)))) 
                               & (IData)((vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__gen_tag_macros__BRA__0__KET____DOT__i_tag_store__DOT__rdata_q 
                                          >> 0x0000003cU))));
    vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__pending_pop 
        = (((~ (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__busy_q)) 
            | ((IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__pending_full) 
               & (2U == vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__req_q[2U]))) 
           & ((~ (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__maint_finish)) 
              & (IData)(vlSelfRef.__VdfgRegularize_h6e95ff9d_0_14)));
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_35 = ((~ (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__bist_valid)) 
                                                 & ((IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__i_index_cnt__DOT__i_counter__DOT__counter_q) 
                                                    >> 1U));
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_21 = ((4U 
                                                  & ((IData)(
                                                             (vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__gen_tag_macros__BRA__0__KET____DOT__i_tag_store__DOT__rdata_q 
                                                              >> 0x0000003bU)) 
                                                     << 2U)) 
                                                 | ((2U 
                                                     & ((IData)(
                                                                (vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__gen_tag_macros__BRA__0__KET____DOT__i_tag_store__DOT__rdata_q 
                                                                 >> 0x0000003cU)) 
                                                        << 1U)) 
                                                    | ((IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__busy_q) 
                                                       & ((vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__req_q[2U] 
                                                           >> 1U) 
                                                          & ((~ vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__req_q[2U]) 
                                                             & ((~ (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__hit)) 
                                                                & ((IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__ram_rvalid) 
                                                                   | (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__ram_rvalid_q))))))));
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_4 = (1U 
                                                & ((1U 
                                                    & (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__bist_q))
                                                    ? (IData)(vlSelfRef.__VdfgRegularize_h6e95ff9d_0_35)
                                                    : 
                                                   ((IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__i_index_cnt__DOT__i_counter__DOT__counter_q) 
                                                    >> 1U)));
    vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__res 
        = (((2U == (3U & vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__req_q[2U]))
             ? (((QData)((IData)(((IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__hit)
                                   ? (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__hit)
                                   : Vtb_llc_flush_tag__ConstPool__TABLE_hc820fc1c_0
                                  [vlSelfRef.__VdfgRegularize_h6e95ff9d_0_21]))) 
                 << 0x0000003dU) | (((QData)((IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__hit)) 
                                     << 0x0000003cU) 
                                    | (((QData)((IData)(
                                                        ((~ (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__hit)) 
                                                         & Vtb_llc_flush_tag__ConstPool__TABLE_hdb06591d_0
                                                         [vlSelfRef.__VdfgRegularize_h6e95ff9d_0_21]))) 
                                        << 0x0000003bU) 
                                       | (0x07ffffffffffffffULL 
                                          & (vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__gen_tag_macros__BRA__0__KET____DOT__i_tag_store__DOT__rdata_q 
                                             & (- (QData)((IData)(
                                                                  (1U 
                                                                   & (~ (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__hit)))))))))))
             : ((3U == (3U & vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__req_q[2U]))
                 ? (((QData)((IData)((3U & (- (IData)((IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__hit)))))) 
                     << 0x0000003cU) | (((QData)((IData)(
                                                         ((IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__hit) 
                                                          & ((IData)(
                                                                     (vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__gen_tag_macros__BRA__0__KET____DOT__i_tag_store__DOT__rdata_q 
                                                                      >> 0x0000003bU)) 
                                                             & (2U 
                                                                != 
                                                                (3U 
                                                                 & vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__req_q[0U])))))) 
                                         << 0x0000003bU) 
                                        | (0x07ffffffffffffffULL 
                                           & (((QData)((IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__req_q[1U])) 
                                               << 0x0000001dU) 
                                              | ((QData)((IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__req_q[0U])) 
                                                 >> 3U)))))
                 : ((((QData)((IData)((vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__req_q[1U] 
                                       >> 0x0000001fU))) 
                      << 0x0000003dU) | (((QData)((IData)(
                                                          (0x1800000000000000ULL 
                                                           == 
                                                           (0x1800000000000000ULL 
                                                            & vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__gen_tag_macros__BRA__0__KET____DOT__i_tag_store__DOT__rdata_q)))) 
                                          << 0x0000003bU) 
                                         | (0x07ffffffffffffffULL 
                                            & vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__gen_tag_macros__BRA__0__KET____DOT__i_tag_store__DOT__rdata_q))) 
                    & (- (QData)((IData)((1U == (3U 
                                                 & vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__req_q[2U])))))))) 
           & (- (QData)((IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__busy_q))));
    vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__load_cnt 
        = ((IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__busy_q) 
           & ((~ ((IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__bist_q) 
                  >> 3U)) & ((4U & (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__bist_q))
                              ? (IData)(((0U == (3U 
                                                 & (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__bist_q))) 
                                         & ((IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__i_index_cnt__DOT__i_counter__DOT__counter_q) 
                                            >> 1U)))
                              : (((IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__bist_q) 
                                  >> 1U) & (IData)(vlSelfRef.__VdfgRegularize_h6e95ff9d_0_4)))));
}

void Vtb_llc_flush_tag___024root___nba_comb__TOP__0(Vtb_llc_flush_tag___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_llc_flush_tag___024root___nba_comb__TOP__0\n"); );
    Vtb_llc_flush_tag__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__fifo_push 
        = ((2U != (IData)(vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__i_r_data_fifo__DOT__status_cnt_q)) 
           & (IData)(vlSelfRef.tb_llc_flush_tag__DOT__way_rsp_valid));
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_24 = (1U 
                                                 & ((IData)(vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__fifo_push)
                                                     ? 
                                                    ((IData)(1U) 
                                                     + (IData)(vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__i_r_data_fifo__DOT__write_pointer_q))
                                                     : (IData)(vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__i_r_data_fifo__DOT__write_pointer_q)));
    vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__i_r_data_fifo__DOT__mem_n[0U] 
        = vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__i_r_data_fifo__DOT__mem_q[0U];
    vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__i_r_data_fifo__DOT__mem_n[1U] 
        = vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__i_r_data_fifo__DOT__mem_q[1U];
    vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__i_r_data_fifo__DOT__mem_n[2U] 
        = vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__i_r_data_fifo__DOT__mem_q[2U];
    vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__i_r_data_fifo__DOT__mem_n[3U] 
        = vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__i_r_data_fifo__DOT__mem_q[3U];
    if (((IData)(vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__fifo_push) 
         & (2U != (IData)(vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__i_r_data_fifo__DOT__status_cnt_q)))) {
        VL_ASSIGNSEL_WQ(128, 64, (0x0000007fU & ((IData)(vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__i_r_data_fifo__DOT__write_pointer_q) 
                                                 << 6U)), vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__i_r_data_fifo__DOT__mem_n, 0x123456789abcdef0ULL);
    }
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_5 = ((0U 
                                                 == (IData)(vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__i_r_data_fifo__DOT__status_cnt_q)) 
                                                & (IData)(vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__fifo_push));
    vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__fifo_empty 
        = ((~ (IData)(vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__fifo_push)) 
           & (0U == (IData)(vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__i_r_data_fifo__DOT__status_cnt_q)));
    vlSelfRef.tb_llc_flush_tag__DOT__w[0U] = (0x000001feU 
                                              | ((0xfffffe00U 
                                                  & vlSelfRef.tb_llc_flush_tag__DOT__w[0U]) 
                                                 | (1U 
                                                    & (~ (IData)(vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__i_w_to_send_counter__DOT__i_counter__DOT__counter_q)))));
    vlSelfRef.tb_llc_flush_tag__DOT__w[0U] = ((0x000001ffU 
                                               & vlSelfRef.tb_llc_flush_tag__DOT__w[0U]) 
                                              | ((IData)(
                                                         ((IData)(vlSelfRef.__VdfgRegularize_h6e95ff9d_0_5)
                                                           ? 0x123456789abcdef0ULL
                                                           : 
                                                          (((QData)((IData)(vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__i_r_data_fifo__DOT__mem_q
                                                                            [
                                                                            (((IData)(0x0000003fU) 
                                                                              + 
                                                                              ((IData)(vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__i_r_data_fifo__DOT__read_pointer_q) 
                                                                               << 6U)) 
                                                                             >> 5U)])) 
                                                            << 0x00000020U) 
                                                           | (QData)((IData)(vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__i_r_data_fifo__DOT__mem_q
                                                                             [
                                                                             (0x07fffffeU 
                                                                              & ((IData)(vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__i_r_data_fifo__DOT__read_pointer_q) 
                                                                                << 1U))]))))) 
                                                 << 9U));
    vlSelfRef.tb_llc_flush_tag__DOT__w[1U] = (((IData)(
                                                       ((IData)(vlSelfRef.__VdfgRegularize_h6e95ff9d_0_5)
                                                         ? 0x123456789abcdef0ULL
                                                         : 
                                                        (((QData)((IData)(vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__i_r_data_fifo__DOT__mem_q
                                                                          [
                                                                          (((IData)(0x0000003fU) 
                                                                            + 
                                                                            ((IData)(vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__i_r_data_fifo__DOT__read_pointer_q) 
                                                                             << 6U)) 
                                                                           >> 5U)])) 
                                                          << 0x00000020U) 
                                                         | (QData)((IData)(vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__i_r_data_fifo__DOT__mem_q
                                                                           [
                                                                           (0x07fffffeU 
                                                                            & ((IData)(vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__i_r_data_fifo__DOT__read_pointer_q) 
                                                                               << 1U))]))))) 
                                               >> 0x00000017U) 
                                              | ((IData)(
                                                         (((IData)(vlSelfRef.__VdfgRegularize_h6e95ff9d_0_5)
                                                            ? 0x123456789abcdef0ULL
                                                            : 
                                                           (((QData)((IData)(vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__i_r_data_fifo__DOT__mem_q
                                                                             [
                                                                             (((IData)(0x0000003fU) 
                                                                               + 
                                                                               ((IData)(vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__i_r_data_fifo__DOT__read_pointer_q) 
                                                                                << 6U)) 
                                                                              >> 5U)])) 
                                                             << 0x00000020U) 
                                                            | (QData)((IData)(vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__i_r_data_fifo__DOT__mem_q
                                                                              [
                                                                              (0x07fffffeU 
                                                                               & ((IData)(vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__i_r_data_fifo__DOT__read_pointer_q) 
                                                                                << 1U))])))) 
                                                          >> 0x00000020U)) 
                                                 << 9U));
    vlSelfRef.tb_llc_flush_tag__DOT__w[2U] = ((IData)(
                                                      (((IData)(vlSelfRef.__VdfgRegularize_h6e95ff9d_0_5)
                                                         ? 0x123456789abcdef0ULL
                                                         : 
                                                        (((QData)((IData)(vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__i_r_data_fifo__DOT__mem_q
                                                                          [
                                                                          (((IData)(0x0000003fU) 
                                                                            + 
                                                                            ((IData)(vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__i_r_data_fifo__DOT__read_pointer_q) 
                                                                             << 6U)) 
                                                                           >> 5U)])) 
                                                          << 0x00000020U) 
                                                         | (QData)((IData)(vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__i_r_data_fifo__DOT__mem_q
                                                                           [
                                                                           (0x07fffffeU 
                                                                            & ((IData)(vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__i_r_data_fifo__DOT__read_pointer_q) 
                                                                               << 1U))])))) 
                                                       >> 0x00000020U)) 
                                              >> 0x00000017U);
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_25 = (3U 
                                                 & (((~ (IData)(vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__fifo_empty)) 
                                                     & (IData)(vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__fifo_push))
                                                     ? (IData)(vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__i_r_data_fifo__DOT__status_cnt_q)
                                                     : 
                                                    ((IData)(vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__fifo_empty)
                                                      ? 
                                                     ((IData)(vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__i_r_data_fifo__DOT__status_cnt_q) 
                                                      + (IData)(vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__fifo_push))
                                                      : 
                                                     ((IData)(vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__i_r_data_fifo__DOT__status_cnt_q) 
                                                      - (IData)(1U)))));
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_11 = (1U 
                                                 & ((~ (IData)(vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__fifo_empty)) 
                                                    & (~ (IData)(vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__i_w_to_send_counter__DOT__i_counter__DOT__counter_q))));
    vlSelfRef.tb_llc_flush_tag__DOT__br = ((IData)(vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__busy_q) 
                                           & ((IData)(vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__send_q) 
                                              | (IData)(vlSelfRef.__VdfgRegularize_h6e95ff9d_0_11)));
}

void Vtb_llc_flush_tag___024root___nba_comb__TOP__1(Vtb_llc_flush_tag___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_llc_flush_tag___024root___nba_comb__TOP__1\n"); );
    Vtb_llc_flush_tag__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    CData/*0:0*/ __VdfgRegularize_h6e95ff9d_0_30;
    __VdfgRegularize_h6e95ff9d_0_30 = 0;
    // Body
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_29 = ((~ (IData)(vlSelfRef.tb_llc_flush_tag__DOT__bv)) 
                                                 & (IData)(vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__busy_q));
    vlSelfRef.tb_llc_flush_tag__DOT____Vcellinp__writer__desc_valid_i 
        = (((IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__a_full_q) 
            | (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__b_full_q)) 
           & ((IData)(vlSelfRef.tb_llc_flush_tag__DOT__orr) 
              & (IData)(vlSelfRef.tb_llc_flush_tag__DOT__flush_mode)));
    vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__b_fill 
        = ((~ (IData)(vlSelfRef.tb_llc_flush_tag__DOT__orr)) 
           & (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__a_drain));
    vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__switch_busy = 0U;
    vlSelfRef.tb_llc_flush_tag__DOT__ir = 0U;
    vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__load_req = 0U;
    vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__res_valid = 0U;
    vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__ram_req = 0U;
    vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__ram_we = 0U;
    vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__ram_index = 0U;
    vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__ram_wdata = 0ULL;
    vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__gen_valid = 0U;
    if (vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__busy_q) {
        if ((2U & vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__req_q[2U])) {
            if ((1U & vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__req_q[2U])) {
                if (((IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__ram_rvalid) 
                     | (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__ram_rvalid_q))) {
                    vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__res_valid 
                        = (1U & (~ (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__maint_pending_q)));
                }
                if (((IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__res_valid) 
                     & (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__res_ready))) {
                    vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__switch_busy = 1U;
                }
            } else {
                if (((IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__ram_rvalid) 
                     | (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__ram_rvalid_q))) {
                    vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__res_valid 
                        = ((IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__hit) 
                           || Vtb_llc_flush_tag__ConstPool__TABLE_hc820fc1c_0
                           [vlSelfRef.__VdfgRegularize_h6e95ff9d_0_21]);
                }
                if ((IData)(((0x0800000000000000ULL 
                              == (0x1800000000000000ULL 
                                  & vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__res)) 
                             & (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__pending_full)))) {
                    vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__res_valid = 0U;
                }
                if (((IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__res_valid) 
                     & (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__res_ready))) {
                    if ((1U & (IData)((vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__res 
                                       >> 0x0000003cU)))) {
                        if ((1U & ((vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__req_q[0U] 
                                    >> 2U) & (~ (IData)(
                                                        (vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__gen_tag_macros__BRA__0__KET____DOT__i_tag_store__DOT__rdata_q 
                                                         >> 0x0000003bU)))))) {
                            vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__ram_req 
                                = (1U & (IData)((vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__res 
                                                 >> 0x0000003dU)));
                            vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__ram_we 
                                = (1U & (IData)((vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__res 
                                                 >> 0x0000003dU)));
                            vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__ram_index 
                                = (1U & (vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__req_q[1U] 
                                         >> 0x0000001eU));
                            vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__ram_wdata 
                                = (0x1800000000000000ULL 
                                   | (0x07ffffffffffffffULL 
                                      & (((QData)((IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__req_q[1U])) 
                                          << 0x0000001dU) 
                                         | ((QData)((IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__req_q[0U])) 
                                            >> 3U))));
                            vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__switch_busy = 1U;
                        } else if (((IData)(vlSelfRef.tb_llc_flush_tag__DOT__iv) 
                                    & (2U == vlSelfRef.tb_llc_flush_tag__DOT__req[2U]))) {
                            vlSelfRef.tb_llc_flush_tag__DOT__ir = 1U;
                            vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__ram_req 
                                = (vlSelfRef.tb_llc_flush_tag__DOT__req[1U] 
                                   >> 0x0000001fU);
                            vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__ram_index 
                                = (1U & (vlSelfRef.tb_llc_flush_tag__DOT__req[1U] 
                                         >> 0x0000001eU));
                            vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__load_req = 1U;
                        } else {
                            vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__switch_busy = 1U;
                        }
                    } else {
                        if ((1U & (~ (IData)((vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__res 
                                              >> 0x0000003bU))))) {
                            vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__ram_req 
                                = (1U & (IData)((vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__res 
                                                 >> 0x0000003dU)));
                            vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__ram_we 
                                = (1U & (IData)((vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__res 
                                                 >> 0x0000003dU)));
                            vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__ram_index 
                                = (1U & (vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__req_q[1U] 
                                         >> 0x0000001eU));
                            vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__ram_wdata 
                                = (0x1000000000000000ULL 
                                   | (((QData)((IData)(
                                                       (1U 
                                                        & (vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__req_q[0U] 
                                                           >> 2U)))) 
                                       << 0x0000003bU) 
                                      | (0x07ffffffffffffffULL 
                                         & (((QData)((IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__req_q[1U])) 
                                             << 0x0000001dU) 
                                            | ((QData)((IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__req_q[0U])) 
                                               >> 3U)))));
                        }
                        vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__switch_busy = 1U;
                    }
                }
            }
        } else if ((1U & vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__req_q[2U])) {
            if (((IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__ram_rvalid) 
                 | (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__ram_rvalid_q))) {
                vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__res_valid = 1U;
            }
            if (((IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__flush_wait_q) 
                 & (IData)(vlSelfRef.tb_llc_flush_tag__DOT__commit))) {
                vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__ram_req 
                    = (vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__req_q[1U] 
                       >> 0x0000001fU);
                vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__ram_we 
                    = (vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__req_q[1U] 
                       >> 0x0000001fU);
                vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__ram_index 
                    = (1U & (vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__req_q[1U] 
                             >> 0x0000001eU));
                vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__ram_wdata = 0ULL;
                vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__switch_busy = 1U;
            }
            if (vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__flush_wait_q) {
                vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__res_valid = 0U;
            }
        } else {
            vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__ram_req 
                = vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__en_cnt;
            vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__ram_we 
                = ((IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__busy_q) 
                   & ((~ ((IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__bist_q) 
                          >> 3U)) & ((4U & (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__bist_q))
                                      ? ((~ ((IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__bist_q) 
                                             >> 1U)) 
                                         & (IData)(vlSelfRef.__VdfgRegularize_h6e95ff9d_0_33))
                                      : (IData)(vlSelfRef.__VdfgRegularize_h6e95ff9d_0_33))));
            vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__ram_index 
                = (1U & (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__i_index_cnt__DOT__i_counter__DOT__counter_q));
            vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__ram_wdata 
                = vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__gen_pattern;
            if (vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__eoc_q) {
                vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__switch_busy = 1U;
            }
        }
    } else {
        vlSelfRef.tb_llc_flush_tag__DOT__ir = 1U;
        if (vlSelfRef.tb_llc_flush_tag__DOT__iv) {
            vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__switch_busy = 1U;
            vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__load_req = 1U;
            if ((2U & vlSelfRef.tb_llc_flush_tag__DOT__req[2U])) {
                vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__ram_req 
                    = (vlSelfRef.tb_llc_flush_tag__DOT__req[1U] 
                       >> 0x0000001fU);
                vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__ram_index 
                    = (1U & (vlSelfRef.tb_llc_flush_tag__DOT__req[1U] 
                             >> 0x0000001eU));
                vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__load_req = 1U;
                vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__switch_busy = 1U;
            } else if ((1U & vlSelfRef.tb_llc_flush_tag__DOT__req[2U])) {
                vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__ram_req 
                    = (vlSelfRef.tb_llc_flush_tag__DOT__req[1U] 
                       >> 0x0000001fU);
                vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__ram_index 
                    = (1U & (vlSelfRef.tb_llc_flush_tag__DOT__req[1U] 
                             >> 0x0000001eU));
                vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__load_req = 1U;
                vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__switch_busy = 1U;
            } else {
                vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__gen_valid = 1U;
                vlSelfRef.tb_llc_flush_tag__DOT__ir 
                    = (1U & (~ (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__busy_q)));
                vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__switch_busy 
                    = (1U & (~ (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__busy_q)));
            }
        }
    }
    if (((IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__load_req) 
         & ((IData)(vlSelfRef.__VdfgRegularize_h6e95ff9d_0_13) 
            | ((IData)(((0U == vlSelfRef.tb_llc_flush_tag__DOT__req[2U]) 
                        & ((IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__maint_pending_q) 
                           | (0U != (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__pending_valid_q))))) 
               | (((IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__maint_pending_q) 
                   & ((IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__maint_index_q) 
                      == (1U & (vlSelfRef.tb_llc_flush_tag__DOT__req[1U] 
                                >> 0x0000001eU)))) 
                  | ((((IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__pending_valid_q) 
                       >> 3U) & ((1U & (vlSelfRef.tb_llc_flush_tag__DOT__req[1U] 
                                        >> 0x0000001eU)) 
                                 == vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__pending_index_q[3U])) 
                     | ((((IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__pending_valid_q) 
                          >> 2U) & ((1U & (vlSelfRef.tb_llc_flush_tag__DOT__req[1U] 
                                           >> 0x0000001eU)) 
                                    == vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__pending_index_q[2U])) 
                        | ((((IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__pending_valid_q) 
                             >> 1U) & ((1U & (vlSelfRef.tb_llc_flush_tag__DOT__req[1U] 
                                              >> 0x0000001eU)) 
                                       == vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__pending_index_q[1U])) 
                           | (((IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__pending_valid_q) 
                               & ((1U & (vlSelfRef.tb_llc_flush_tag__DOT__req[1U] 
                                         >> 0x0000001eU)) 
                                  == vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__pending_index_q[0U])) 
                              | (IData)(vlSelfRef.__VdfgRegularize_h6e95ff9d_0_14)))))))))) {
        vlSelfRef.tb_llc_flush_tag__DOT__ir = 0U;
        vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__load_req = 0U;
        vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__ram_req = 0U;
        vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__ram_we = 0U;
        vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__gen_valid = 0U;
        vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__switch_busy 
            = vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__busy_q;
    }
    if (vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__maint_finish) {
        vlSelfRef.tb_llc_flush_tag__DOT__ir = 0U;
        vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__load_req = 0U;
        vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__switch_busy = 0U;
        vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__gen_valid = 0U;
        vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__ram_req 
            = vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__maint_way_q;
        vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__ram_we 
            = ((~ (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__maint_error_q)) 
               & (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__maint_way_q));
        vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__ram_index 
            = vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__maint_index_q;
        vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__ram_wdata 
            = ((0U == (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__maint_op_q))
                ? vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__maint_tag_q
                : 0ULL);
    }
    if (vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__pending_pop) {
        vlSelfRef.tb_llc_flush_tag__DOT__ir = 0U;
        vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__load_req = 0U;
        vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__switch_busy = 0U;
        vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__ram_req 
            = vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__pending_way_q
            [vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__pending_read_q];
        vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__ram_we 
            = vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__pending_way_q
            [vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__pending_read_q];
        vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__ram_index 
            = vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__pending_index_q
            [vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__pending_read_q];
        vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__ram_wdata 
            = vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__pending_tag_q
            [vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__pending_read_q];
        vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__gen_valid = 0U;
    }
    __VdfgRegularize_h6e95ff9d_0_30 = (IData)((((0x20U 
                                                 == 
                                                 (0x30U 
                                                  & vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__desc_q[2U])) 
                                                & (IData)(vlSelfRef.tb_llc_flush_tag__DOT__bv)) 
                                               & (IData)(vlSelfRef.tb_llc_flush_tag__DOT__br)));
    vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__load_desc 
        = ((~ (IData)(vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__busy_q)) 
           & (IData)(vlSelfRef.tb_llc_flush_tag__DOT____Vcellinp__writer__desc_valid_i));
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_6 = ((IData)(
                                                        (vlSelfRef.tb_llc_flush_tag__DOT__rsp 
                                                         >> 0x0000003bU)) 
                                                & (IData)(vlSelfRef.tb_llc_flush_tag__DOT____Vcellinp__writer__desc_valid_i));
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_28 = ((~ (IData)(
                                                            (vlSelfRef.tb_llc_flush_tag__DOT__rsp 
                                                             >> 0x0000003bU))) 
                                                 & (IData)(vlSelfRef.tb_llc_flush_tag__DOT____Vcellinp__writer__desc_valid_i));
    vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT____Vcellinp__gen_tag_macros__BRA__0__KET____DOT__i_shift_reg_rvalid__d_i 
        = ((~ (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__ram_we)) 
           & (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__ram_req));
    vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__a_fill 
        = ((IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__res_ready) 
           & (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__res_valid));
    vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__pending_push 
        = (((((IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__busy_q) 
              & (2U == vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__req_q[2U])) 
             & (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__res_valid)) 
            & (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__res_ready)) 
           & (0x0800000000000000ULL == (0x1800000000000000ULL 
                                        & vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__res)));
    vlSelfRef.tb_llc_flush_tag__DOT__wb_commit = ((0U 
                                                   == (IData)(vlSelfRef.tb_llc_flush_tag__DOT__b)) 
                                                  & (IData)(__VdfgRegularize_h6e95ff9d_0_30));
    vlSelfRef.tb_llc_flush_tag__DOT__wb_error = ((0U 
                                                  != (IData)(vlSelfRef.tb_llc_flush_tag__DOT__b)) 
                                                 & (IData)(__VdfgRegularize_h6e95ff9d_0_30));
}

void Vtb_llc_flush_tag___024root___timing_ready(Vtb_llc_flush_tag___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_llc_flush_tag___024root___timing_ready\n"); );
    Vtb_llc_flush_tag__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if ((4ULL & vlSelfRef.__VactTriggered[0U])) {
        vlSelfRef.__VtrigSched_hb04eaffa__0.ready("@(negedge tb_llc_flush_tag.clk)");
    }
    if ((1ULL & vlSelfRef.__VactTriggered[0U])) {
        vlSelfRef.__VtrigSched_hb04eaf3d__0.ready("@(posedge tb_llc_flush_tag.clk)");
    }
    if ((8ULL & vlSelfRef.__VactTriggered[0U])) {
        vlSelfRef.__VtrigSched_ha4acadb1__0.ready("@( tb_llc_flush_tag.dut.i_tag_pattern_gen.eoc_q)");
    }
    if ((0x0000000000000010ULL & vlSelfRef.__VactTriggered[0U])) {
        vlSelfRef.__VtrigSched_hd94d9ee0__0.ready("@( (32'sh2 == tb_llc_flush_tag.beats))");
    }
    if ((0x0000000000000040ULL & vlSelfRef.__VactTriggered[0U])) {
        vlSelfRef.__VtrigSched_hd94c4b5f__0.ready("@( (32'sh4 == tb_llc_flush_tag.beats))");
    }
}

void Vtb_llc_flush_tag___024root___timing_resume(Vtb_llc_flush_tag___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_llc_flush_tag___024root___timing_resume\n"); );
    Vtb_llc_flush_tag__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    vlSelfRef.__VtrigSched_hb04eaffa__0.moveToResumeQueue(
                                                          "@(negedge tb_llc_flush_tag.clk)");
    vlSelfRef.__VtrigSched_hb04eaf3d__0.moveToResumeQueue(
                                                          "@(posedge tb_llc_flush_tag.clk)");
    vlSelfRef.__VtrigSched_ha4acadb1__0.moveToResumeQueue(
                                                          "@( tb_llc_flush_tag.dut.i_tag_pattern_gen.eoc_q)");
    vlSelfRef.__VtrigSched_hd94d9ee0__0.moveToResumeQueue(
                                                          "@( (32'sh2 == tb_llc_flush_tag.beats))");
    vlSelfRef.__VtrigSched_hd94c4b5f__0.moveToResumeQueue(
                                                          "@( (32'sh4 == tb_llc_flush_tag.beats))");
    vlSelfRef.__VtrigSched_hb04eaffa__0.resume("@(negedge tb_llc_flush_tag.clk)");
    vlSelfRef.__VtrigSched_hb04eaf3d__0.resume("@(posedge tb_llc_flush_tag.clk)");
    vlSelfRef.__VtrigSched_ha4acadb1__0.resume("@( tb_llc_flush_tag.dut.i_tag_pattern_gen.eoc_q)");
    vlSelfRef.__VtrigSched_hd94d9ee0__0.resume("@( (32'sh2 == tb_llc_flush_tag.beats))");
    vlSelfRef.__VtrigSched_hd94c4b5f__0.resume("@( (32'sh4 == tb_llc_flush_tag.beats))");
    if ((0x0000000000000020ULL & vlSelfRef.__VactTriggered[0U])) {
        vlSelfRef.__VdlySched.resume();
    }
}

void Vtb_llc_flush_tag___024root___trigger_orInto__act_vec_vec(VlUnpacked<QData/*63:0*/, 1> &out, const VlUnpacked<QData/*63:0*/, 1> &in) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_llc_flush_tag___024root___trigger_orInto__act_vec_vec\n"); );
    // Locals
    IData/*31:0*/ n;
    // Body
    n = 0U;
    do {
        out[n] = (out[n] | in[n]);
        n = ((IData)(1U) + n);
    } while ((0U >= n));
}

void Vtb_llc_flush_tag___024root___trigger_clear__act(VlUnpacked<QData/*63:0*/, 1> &out) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_llc_flush_tag___024root___trigger_clear__act\n"); );
    // Locals
    IData/*31:0*/ n;
    // Body
    n = 0U;
    do {
        out[n] = 0ULL;
        n = ((IData)(1U) + n);
    } while ((1U > n));
}

void Vtb_llc_flush_tag___024root____VbeforeTrig_hb04eaffa__0(Vtb_llc_flush_tag___024root* vlSelf, const char* __VeventDescription) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_llc_flush_tag___024root____VbeforeTrig_hb04eaffa__0\n"); );
    Vtb_llc_flush_tag__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    VlUnpacked<QData/*63:0*/, 1> __VTmp;
    // Body
    __VTmp[0U] = (QData)((IData)(((((~ (IData)(vlSelfRef.tb_llc_flush_tag__DOT__clk)) 
                                    & (IData)(vlSelfRef.__Vtrigprevexpr___TOP__tb_llc_flush_tag__DOT__clk__0)) 
                                   << 2U) | ((IData)(vlSelfRef.tb_llc_flush_tag__DOT__clk) 
                                             & (~ (IData)(vlSelfRef.__Vtrigprevexpr___TOP__tb_llc_flush_tag__DOT__clk__0))))));
    vlSelfRef.__Vtrigprevexpr___TOP__tb_llc_flush_tag__DOT__clk__0 
        = vlSelfRef.tb_llc_flush_tag__DOT__clk;
    if ((1ULL & __VTmp[0U])) {
        vlSelfRef.__VtrigSched_hb04eaf3d__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hb04eaf3d__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hb04eaf3d__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hb04eaf3d__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hb04eaf3d__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hb04eaf3d__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hb04eaf3d__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hb04eaf3d__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hb04eaf3d__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hb04eaf3d__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hb04eaf3d__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hb04eaf3d__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hb04eaf3d__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hb04eaf3d__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hb04eaf3d__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hb04eaf3d__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hb04eaf3d__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hb04eaf3d__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hb04eaf3d__0.ready(__VeventDescription);
    }
    if ((4ULL & __VTmp[0U])) {
        vlSelfRef.__VtrigSched_hb04eaffa__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hb04eaffa__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hb04eaffa__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hb04eaffa__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hb04eaffa__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hb04eaffa__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hb04eaffa__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hb04eaffa__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hb04eaffa__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hb04eaffa__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hb04eaffa__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hb04eaffa__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hb04eaffa__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hb04eaffa__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hb04eaffa__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hb04eaffa__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hb04eaffa__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hb04eaffa__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hb04eaffa__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hb04eaffa__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hb04eaffa__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hb04eaffa__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hb04eaffa__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hb04eaffa__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hb04eaffa__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hb04eaffa__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hb04eaffa__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hb04eaffa__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hb04eaffa__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hb04eaffa__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hb04eaffa__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hb04eaffa__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hb04eaffa__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hb04eaffa__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hb04eaffa__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hb04eaffa__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hb04eaffa__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hb04eaffa__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hb04eaffa__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hb04eaffa__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hb04eaffa__0.ready(__VeventDescription);
    }
    vlSelfRef.__VactTriggeredAcc[0U] = (vlSelfRef.__VactTriggeredAcc[0U] 
                                        | __VTmp[0U]);
}

void Vtb_llc_flush_tag___024root____VbeforeTrig_hb04eaf3d__0(Vtb_llc_flush_tag___024root* vlSelf, const char* __VeventDescription) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_llc_flush_tag___024root____VbeforeTrig_hb04eaf3d__0\n"); );
    Vtb_llc_flush_tag__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    VlUnpacked<QData/*63:0*/, 1> __VTmp;
    // Body
    __VTmp[0U] = (QData)((IData)(((((~ (IData)(vlSelfRef.tb_llc_flush_tag__DOT__clk)) 
                                    & (IData)(vlSelfRef.__Vtrigprevexpr___TOP__tb_llc_flush_tag__DOT__clk__0)) 
                                   << 2U) | ((IData)(vlSelfRef.tb_llc_flush_tag__DOT__clk) 
                                             & (~ (IData)(vlSelfRef.__Vtrigprevexpr___TOP__tb_llc_flush_tag__DOT__clk__0))))));
    vlSelfRef.__Vtrigprevexpr___TOP__tb_llc_flush_tag__DOT__clk__0 
        = vlSelfRef.tb_llc_flush_tag__DOT__clk;
    if ((1ULL & __VTmp[0U])) {
        vlSelfRef.__VtrigSched_hb04eaf3d__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hb04eaf3d__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hb04eaf3d__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hb04eaf3d__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hb04eaf3d__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hb04eaf3d__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hb04eaf3d__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hb04eaf3d__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hb04eaf3d__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hb04eaf3d__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hb04eaf3d__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hb04eaf3d__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hb04eaf3d__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hb04eaf3d__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hb04eaf3d__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hb04eaf3d__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hb04eaf3d__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hb04eaf3d__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hb04eaf3d__0.ready(__VeventDescription);
    }
    if ((4ULL & __VTmp[0U])) {
        vlSelfRef.__VtrigSched_hb04eaffa__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hb04eaffa__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hb04eaffa__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hb04eaffa__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hb04eaffa__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hb04eaffa__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hb04eaffa__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hb04eaffa__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hb04eaffa__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hb04eaffa__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hb04eaffa__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hb04eaffa__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hb04eaffa__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hb04eaffa__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hb04eaffa__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hb04eaffa__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hb04eaffa__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hb04eaffa__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hb04eaffa__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hb04eaffa__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hb04eaffa__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hb04eaffa__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hb04eaffa__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hb04eaffa__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hb04eaffa__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hb04eaffa__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hb04eaffa__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hb04eaffa__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hb04eaffa__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hb04eaffa__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hb04eaffa__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hb04eaffa__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hb04eaffa__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hb04eaffa__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hb04eaffa__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hb04eaffa__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hb04eaffa__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hb04eaffa__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hb04eaffa__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hb04eaffa__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hb04eaffa__0.ready(__VeventDescription);
    }
    vlSelfRef.__VactTriggeredAcc[0U] = (vlSelfRef.__VactTriggeredAcc[0U] 
                                        | __VTmp[0U]);
}

void Vtb_llc_flush_tag___024root____VbeforeTrig_ha4acadb1__0(Vtb_llc_flush_tag___024root* vlSelf, const char* __VeventDescription) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_llc_flush_tag___024root____VbeforeTrig_ha4acadb1__0\n"); );
    Vtb_llc_flush_tag__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    VlUnpacked<QData/*63:0*/, 1> __VTmp;
    // Body
    __VTmp[0U] = (QData)((IData)((((IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__eoc_q) 
                                   != (IData)(vlSelfRef.__Vtrigprevexpr___TOP__tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__eoc_q__0)) 
                                  << 3U)));
    vlSelfRef.__Vtrigprevexpr___TOP__tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__eoc_q__0 
        = vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__eoc_q;
    if ((8ULL & __VTmp[0U])) {
        vlSelfRef.__VtrigSched_ha4acadb1__0.ready(__VeventDescription);
    }
    vlSelfRef.__VactTriggeredAcc[0U] = (vlSelfRef.__VactTriggeredAcc[0U] 
                                        | __VTmp[0U]);
}

void Vtb_llc_flush_tag___024root____VbeforeTrig_hd94d9ee0__0(Vtb_llc_flush_tag___024root* vlSelf, const char* __VeventDescription) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_llc_flush_tag___024root____VbeforeTrig_hd94d9ee0__0\n"); );
    Vtb_llc_flush_tag__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    VlUnpacked<QData/*63:0*/, 1> __VTmp;
    CData/*0:0*/ __Vtrigprevexpr_h4d792359__0;
    __Vtrigprevexpr_h4d792359__0 = 0;
    // Body
    __Vtrigprevexpr_h4d792359__0 = (2U == vlSelfRef.tb_llc_flush_tag__DOT__beats);
    __VTmp[0U] = (QData)((IData)((((IData)(__Vtrigprevexpr_h4d792359__0) 
                                   != (IData)(vlSelfRef.__Vtrigprevexpr_h4d792359__1)) 
                                  << 4U)));
    vlSelfRef.__Vtrigprevexpr_h4d792359__1 = __Vtrigprevexpr_h4d792359__0;
    if ((0x0000000000000010ULL & __VTmp[0U])) {
        vlSelfRef.__VtrigSched_hd94d9ee0__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hd94d9ee0__0.ready(__VeventDescription);
    }
    vlSelfRef.__VactTriggeredAcc[0U] = (vlSelfRef.__VactTriggeredAcc[0U] 
                                        | __VTmp[0U]);
}

void Vtb_llc_flush_tag___024root____VbeforeTrig_hd94c4b5f__0(Vtb_llc_flush_tag___024root* vlSelf, const char* __VeventDescription) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_llc_flush_tag___024root____VbeforeTrig_hd94c4b5f__0\n"); );
    Vtb_llc_flush_tag__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    VlUnpacked<QData/*63:0*/, 1> __VTmp;
    CData/*0:0*/ __Vtrigprevexpr_h4d7acfdc__0;
    __Vtrigprevexpr_h4d7acfdc__0 = 0;
    // Body
    __Vtrigprevexpr_h4d7acfdc__0 = (4U == vlSelfRef.tb_llc_flush_tag__DOT__beats);
    __VTmp[0U] = (QData)((IData)((((IData)(__Vtrigprevexpr_h4d7acfdc__0) 
                                   != (IData)(vlSelfRef.__Vtrigprevexpr_h4d7acfdc__1)) 
                                  << 6U)));
    vlSelfRef.__Vtrigprevexpr_h4d7acfdc__1 = __Vtrigprevexpr_h4d7acfdc__0;
    if ((0x0000000000000040ULL & __VTmp[0U])) {
        vlSelfRef.__VtrigSched_hd94c4b5f__0.ready(__VeventDescription);
    }
    vlSelfRef.__VactTriggeredAcc[0U] = (vlSelfRef.__VactTriggeredAcc[0U] 
                                        | __VTmp[0U]);
}

#ifdef VL_DEBUG
void Vtb_llc_flush_tag___024root___eval_debug_assertions(Vtb_llc_flush_tag___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_llc_flush_tag___024root___eval_debug_assertions\n"); );
    Vtb_llc_flush_tag__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
}
#endif  // VL_DEBUG
