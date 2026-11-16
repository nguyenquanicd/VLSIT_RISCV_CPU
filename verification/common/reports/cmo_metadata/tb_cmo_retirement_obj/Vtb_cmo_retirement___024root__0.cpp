// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vtb_cmo_retirement.h for the primary calling header

#include "Vtb_cmo_retirement__pch.h"

VlCoroutine Vtb_cmo_retirement___024root___eval_initial__TOP__Vtiming__0(Vtb_cmo_retirement___024root* vlSelf);
VlCoroutine Vtb_cmo_retirement___024root___eval_initial__TOP__Vtiming__1(Vtb_cmo_retirement___024root* vlSelf);
VlCoroutine Vtb_cmo_retirement___024root___eval_initial__TOP__Vtiming__2(Vtb_cmo_retirement___024root* vlSelf);

void Vtb_cmo_retirement___024root___eval_initial(Vtb_cmo_retirement___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_cmo_retirement___024root___eval_initial\n"); );
    Vtb_cmo_retirement__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    Vtb_cmo_retirement___024root___eval_initial__TOP__Vtiming__0(vlSelf);
    Vtb_cmo_retirement___024root___eval_initial__TOP__Vtiming__1(vlSelf);
    Vtb_cmo_retirement___024root___eval_initial__TOP__Vtiming__2(vlSelf);
}

void Vtb_cmo_retirement___024root___eval_sample(Vtb_cmo_retirement___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_cmo_retirement___024root___eval_sample\n"); );
    Vtb_cmo_retirement__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
}

#ifdef VL_DEBUG
VL_ATTR_COLD void Vtb_cmo_retirement___024root___dump_triggers__ico(const VlUnpacked<QData/*63:0*/, 1> &triggers, const std::string &tag);
#endif  // VL_DEBUG

bool Vtb_cmo_retirement___024root___eval_ico(Vtb_cmo_retirement___024root* vlSelf, CData/*0:0*/ firstIteration) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_cmo_retirement___024root___eval_ico\n"); );
    Vtb_cmo_retirement__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    vlSelfRef.__VicoTriggered[0U] = ((0xfffffffffffffffeULL 
                                      & vlSelfRef.__VicoTriggered[0U]) 
                                     | (IData)((IData)(firstIteration)));
#ifdef VL_DEBUG
    if (VL_UNLIKELY(vlSymsp->_vm_contextp__->debug())) {
        Vtb_cmo_retirement___024root___dump_triggers__ico(vlSelfRef.__VicoTriggered, "ico"s);
    }
#endif
    return (0U);
}

void Vtb_cmo_retirement___024root___timing_ready(Vtb_cmo_retirement___024root* vlSelf);
void Vtb_cmo_retirement___024root___trigger_orInto__act_vec_vec(VlUnpacked<QData/*63:0*/, 1> &out, const VlUnpacked<QData/*63:0*/, 1> &in);
#ifdef VL_DEBUG
VL_ATTR_COLD void Vtb_cmo_retirement___024root___dump_triggers__act(const VlUnpacked<QData/*63:0*/, 1> &triggers, const std::string &tag);
#endif  // VL_DEBUG
bool Vtb_cmo_retirement___024root___trigger_anySet__act(const VlUnpacked<QData/*63:0*/, 1> &in);
void Vtb_cmo_retirement___024root___timing_resume(Vtb_cmo_retirement___024root* vlSelf);
void Vtb_cmo_retirement___024root___act_comb__TOP__0(Vtb_cmo_retirement___024root* vlSelf);

bool Vtb_cmo_retirement___024root___eval_act(Vtb_cmo_retirement___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_cmo_retirement___024root___eval_act\n"); );
    Vtb_cmo_retirement__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    CData/*0:0*/ __VactExecute;
    // Body
    {
        // Inlined CFunc: _eval_triggers_vec__act
        vlSelfRef.__VactTriggered[0U] = (QData)((IData)(
                                                        ((((IData)(vlSelfRef.tb_cmo_retirement__DOT__dut__DOT__cmo_offer_q) 
                                                           != (IData)(vlSelfRef.__Vtrigprevexpr___TOP__tb_cmo_retirement__DOT__dut__DOT__cmo_offer_q__0)) 
                                                          << 4U) 
                                                         | (((vlSelfRef.__VdlySched.awaitingCurrentTime() 
                                                              << 3U) 
                                                             | (((~ (IData)(vlSelfRef.tb_cmo_retirement__DOT__clk)) 
                                                                 & (IData)(vlSelfRef.__Vtrigprevexpr___TOP__tb_cmo_retirement__DOT__clk__0)) 
                                                                << 2U)) 
                                                            | ((((~ (IData)(vlSelfRef.tb_cmo_retirement__DOT__rst)) 
                                                                 & (IData)(vlSelfRef.__Vtrigprevexpr___TOP__tb_cmo_retirement__DOT__rst__0)) 
                                                                << 1U) 
                                                               | ((IData)(vlSelfRef.tb_cmo_retirement__DOT__clk) 
                                                                  & (~ (IData)(vlSelfRef.__Vtrigprevexpr___TOP__tb_cmo_retirement__DOT__clk__0))))))));
        vlSelfRef.__Vtrigprevexpr___TOP__tb_cmo_retirement__DOT__clk__0 
            = vlSelfRef.tb_cmo_retirement__DOT__clk;
        vlSelfRef.__Vtrigprevexpr___TOP__tb_cmo_retirement__DOT__rst__0 
            = vlSelfRef.tb_cmo_retirement__DOT__rst;
        vlSelfRef.__Vtrigprevexpr___TOP__tb_cmo_retirement__DOT__dut__DOT__cmo_offer_q__0 
            = vlSelfRef.tb_cmo_retirement__DOT__dut__DOT__cmo_offer_q;
    }
    Vtb_cmo_retirement___024root___timing_ready(vlSelf);
    Vtb_cmo_retirement___024root___trigger_orInto__act_vec_vec(vlSelfRef.__VactTriggered, vlSelfRef.__VactTriggeredAcc);
#ifdef VL_DEBUG
    if (VL_UNLIKELY(vlSymsp->_vm_contextp__->debug())) {
        Vtb_cmo_retirement___024root___dump_triggers__act(vlSelfRef.__VactTriggered, "act"s);
    }
#endif
    Vtb_cmo_retirement___024root___trigger_orInto__act_vec_vec(vlSelfRef.__VnbaTriggered, vlSelfRef.__VactTriggered);
    __VactExecute = Vtb_cmo_retirement___024root___trigger_anySet__act(vlSelfRef.__VactTriggered);
    if (__VactExecute) {
        vlSelfRef.__VactTriggeredAcc.fill(0ULL);
        Vtb_cmo_retirement___024root___timing_resume(vlSelf);
        {
            // Inlined CFunc: _eval_body__act
            if ((0x000000000000001dULL & vlSelfRef.__VactTriggered[0U])) {
                Vtb_cmo_retirement___024root___act_comb__TOP__0(vlSelf);
            }
        }
    }
    return (__VactExecute);
}

bool Vtb_cmo_retirement___024root___eval_inact(Vtb_cmo_retirement___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_cmo_retirement___024root___eval_inact\n"); );
    Vtb_cmo_retirement__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    CData/*0:0*/ __VinactExecute;
    // Body
    __VinactExecute = vlSelfRef.__VdlySched.awaitingZeroDelay();
    if (__VinactExecute) {
        VL_FATAL_MT("tb_cmo_retirement.sv", 2, "", "ZERODLY: Design Verilated with '--no-sched-zero-delay', but #0 delay executed at runtime");
    }
    return (__VinactExecute);
}

void Vtb_cmo_retirement___024root___nba_comb__TOP__0(Vtb_cmo_retirement___024root* vlSelf);
void Vtb_cmo_retirement___024root___nba_comb__TOP__1(Vtb_cmo_retirement___024root* vlSelf);
void Vtb_cmo_retirement___024root___trigger_clear__act(VlUnpacked<QData/*63:0*/, 1> &out);

bool Vtb_cmo_retirement___024root___eval_nba(Vtb_cmo_retirement___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_cmo_retirement___024root___eval_nba\n"); );
    Vtb_cmo_retirement__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    CData/*0:0*/ __VnbaExecute;
    // Body
    __VnbaExecute = Vtb_cmo_retirement___024root___trigger_anySet__act(vlSelfRef.__VnbaTriggered);
    if (__VnbaExecute) {
        {
            // Inlined CFunc: _eval_body__nba
            if ((3ULL & vlSelfRef.__VnbaTriggered[0U])) {
                {
                    // Inlined CFunc: _nba_sequent__TOP__0
                    CData/*0:0*/ __Vinline_0__eval_body__nba___Vinline_0__nba_sequent__TOP__0___Vdly__tb_cmo_retirement__DOT__dut__DOT__cmo_busy_q;
                    __Vinline_0__eval_body__nba___Vinline_0__nba_sequent__TOP__0___Vdly__tb_cmo_retirement__DOT__dut__DOT__cmo_busy_q = 0;
                    CData/*0:0*/ __Vinline_0__eval_body__nba___Vinline_0__nba_sequent__TOP__0___Vdly__tb_cmo_retirement__DOT__dut__DOT__cmo_complete_q;
                    __Vinline_0__eval_body__nba___Vinline_0__nba_sequent__TOP__0___Vdly__tb_cmo_retirement__DOT__dut__DOT__cmo_complete_q = 0;
                    __Vinline_0__eval_body__nba___Vinline_0__nba_sequent__TOP__0___Vdly__tb_cmo_retirement__DOT__dut__DOT__cmo_busy_q 
                        = vlSelfRef.tb_cmo_retirement__DOT__dut__DOT__cmo_busy_q;
                    __Vinline_0__eval_body__nba___Vinline_0__nba_sequent__TOP__0___Vdly__tb_cmo_retirement__DOT__dut__DOT__cmo_complete_q 
                        = vlSelfRef.tb_cmo_retirement__DOT__dut__DOT__cmo_complete_q;
                    if (vlSelfRef.tb_cmo_retirement__DOT__rst) {
                        if (vlSelfRef.tb_cmo_retirement__DOT__dut__DOT__cmo_take) {
                            __Vinline_0__eval_body__nba___Vinline_0__nba_sequent__TOP__0___Vdly__tb_cmo_retirement__DOT__dut__DOT__cmo_busy_q = 1U;
                        }
                        if ((((IData)(vlSelfRef.tb_cmo_retirement__DOT__dut__DOT__cmo_busy_q) 
                              | (IData)(vlSelfRef.tb_cmo_retirement__DOT__dut__DOT__cmo_take)) 
                             & (IData)(vlSelfRef.tb_cmo_retirement__DOT__done))) {
                            __Vinline_0__eval_body__nba___Vinline_0__nba_sequent__TOP__0___Vdly__tb_cmo_retirement__DOT__dut__DOT__cmo_busy_q = 0U;
                            __Vinline_0__eval_body__nba___Vinline_0__nba_sequent__TOP__0___Vdly__tb_cmo_retirement__DOT__dut__DOT__cmo_complete_q = 1U;
                            vlSelfRef.tb_cmo_retirement__DOT__dut__DOT__cmo_error_q 
                                = vlSelfRef.tb_cmo_retirement__DOT__error;
                        }
                        if ((((IData)(vlSelfRef.tb_cmo_retirement__DOT__dut__DOT__cmo_complete_q) 
                              & (IData)(vlSelfRef.tb_cmo_retirement__DOT__dut__DOT__cmo_head)) 
                             & (~ (IData)(vlSelfRef.tb_cmo_retirement__DOT__halt)))) {
                            __Vinline_0__eval_body__nba___Vinline_0__nba_sequent__TOP__0___Vdly__tb_cmo_retirement__DOT__dut__DOT__cmo_complete_q = 0U;
                            vlSelfRef.tb_cmo_retirement__DOT__dut__DOT__cmo_error_q = 0U;
                        }
                        if (vlSelfRef.tb_cmo_retirement__DOT__dut__DOT__cmo_eligible) {
                            vlSelfRef.tb_cmo_retirement__DOT__dut__DOT__cmo_line_q = 0x0000000008000123ULL;
                            vlSelfRef.tb_cmo_retirement__DOT__dut__DOT__cmo_op_q 
                                = ((0x53U == (0x000000ffU 
                                              & (vlSelfRef.tb_cmo_retirement__DOT__entry[6U] 
                                                 >> 0x00000015U)))
                                    ? 0U : ((0x54U 
                                             == (0x000000ffU 
                                                 & (vlSelfRef.tb_cmo_retirement__DOT__entry[6U] 
                                                    >> 0x00000015U)))
                                             ? 1U : 2U));
                            vlSelfRef.tb_cmo_retirement__DOT__dut__DOT__cmo_pc_q 
                                = (((QData)((IData)(vlSelfRef.tb_cmo_retirement__DOT__entry[11U])) 
                                    << 0x0000003cU) 
                                   | (((QData)((IData)(vlSelfRef.tb_cmo_retirement__DOT__entry[10U])) 
                                       << 0x0000001cU) 
                                      | ((QData)((IData)(vlSelfRef.tb_cmo_retirement__DOT__entry[9U])) 
                                         >> 4U)));
                            vlSelfRef.tb_cmo_retirement__DOT__dut__DOT__cmo_fault_vaddr_q 
                                = vlSelfRef.tb_cmo_retirement__DOT__source_va;
                            vlSelfRef.tb_cmo_retirement__DOT__dut__DOT__cmo_offer_q = 1U;
                        }
                        if (vlSelfRef.tb_cmo_retirement__DOT__dut__DOT__cmo_take) {
                            vlSelfRef.tb_cmo_retirement__DOT__dut__DOT__cmo_offer_q = 0U;
                        }
                    } else {
                        __Vinline_0__eval_body__nba___Vinline_0__nba_sequent__TOP__0___Vdly__tb_cmo_retirement__DOT__dut__DOT__cmo_busy_q = 0U;
                        __Vinline_0__eval_body__nba___Vinline_0__nba_sequent__TOP__0___Vdly__tb_cmo_retirement__DOT__dut__DOT__cmo_complete_q = 0U;
                        vlSelfRef.tb_cmo_retirement__DOT__dut__DOT__cmo_line_q = 0ULL;
                        vlSelfRef.tb_cmo_retirement__DOT__dut__DOT__cmo_op_q = 0U;
                        vlSelfRef.tb_cmo_retirement__DOT__dut__DOT__cmo_pc_q = 0ULL;
                        vlSelfRef.tb_cmo_retirement__DOT__dut__DOT__cmo_fault_vaddr_q = 0ULL;
                        vlSelfRef.tb_cmo_retirement__DOT__dut__DOT__cmo_offer_q = 0U;
                        vlSelfRef.tb_cmo_retirement__DOT__dut__DOT__cmo_error_q = 0U;
                    }
                    vlSelfRef.tb_cmo_retirement__DOT__dut__DOT__cmo_busy_q 
                        = __Vinline_0__eval_body__nba___Vinline_0__nba_sequent__TOP__0___Vdly__tb_cmo_retirement__DOT__dut__DOT__cmo_busy_q;
                    vlSelfRef.tb_cmo_retirement__DOT__dut__DOT__cmo_complete_q 
                        = __Vinline_0__eval_body__nba___Vinline_0__nba_sequent__TOP__0___Vdly__tb_cmo_retirement__DOT__dut__DOT__cmo_complete_q;
                    vlSelfRef.tb_cmo_retirement__DOT__active 
                        = ((IData)(vlSelfRef.tb_cmo_retirement__DOT__dut__DOT__cmo_offer_q) 
                           | ((IData)(vlSelfRef.tb_cmo_retirement__DOT__dut__DOT__cmo_busy_q) 
                              | (IData)(vlSelfRef.tb_cmo_retirement__DOT__dut__DOT__cmo_complete_q)));
                }
            }
            if ((0x000000000000001dULL & vlSelfRef.__VnbaTriggered[0U])) {
                Vtb_cmo_retirement___024root___nba_comb__TOP__0(vlSelf);
            }
            if ((0x000000000000001fULL & vlSelfRef.__VnbaTriggered[0U])) {
                Vtb_cmo_retirement___024root___nba_comb__TOP__1(vlSelf);
            }
        }
        Vtb_cmo_retirement___024root___trigger_clear__act(vlSelfRef.__VnbaTriggered);
    }
    return (__VnbaExecute);
}

bool Vtb_cmo_retirement___024root___eval_obs(Vtb_cmo_retirement___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_cmo_retirement___024root___eval_obs\n"); );
    Vtb_cmo_retirement__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    return (0U);
}

bool Vtb_cmo_retirement___024root___eval_react(Vtb_cmo_retirement___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_cmo_retirement___024root___eval_react\n"); );
    Vtb_cmo_retirement__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    return (0U);
}

void Vtb_cmo_retirement___024root___eval_postponed(Vtb_cmo_retirement___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_cmo_retirement___024root___eval_postponed\n"); );
    Vtb_cmo_retirement__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
}

extern const VlWide<23>/*735:0*/ Vtb_cmo_retirement__ConstPool__CONST_h14c113d2_0;
void Vtb_cmo_retirement___024root____VbeforeTrig_hd76ea377__0(Vtb_cmo_retirement___024root* vlSelf, const char* __VeventDescription);
void Vtb_cmo_retirement___024root____VbeforeTrig_hd76ea2b8__0(Vtb_cmo_retirement___024root* vlSelf, const char* __VeventDescription);
void Vtb_cmo_retirement___024root____VbeforeTrig_h03c8db67__0(Vtb_cmo_retirement___024root* vlSelf, const char* __VeventDescription);

VlCoroutine Vtb_cmo_retirement___024root___eval_initial__TOP__Vtiming__0(Vtb_cmo_retirement___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_cmo_retirement___024root___eval_initial__TOP__Vtiming__0\n"); );
    Vtb_cmo_retirement__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    IData/*31:0*/ tb_cmo_retirement__DOT__unnamedblk1_1__DOT____Vrepeat0;
    tb_cmo_retirement__DOT__unnamedblk1_1__DOT____Vrepeat0 = 0;
    IData/*31:0*/ tb_cmo_retirement__DOT__unnamedblk1_2__DOT____Vrepeat1;
    tb_cmo_retirement__DOT__unnamedblk1_2__DOT____Vrepeat1 = 0;
    IData/*31:0*/ tb_cmo_retirement__DOT__unnamedblk1_3__DOT____Vrepeat2;
    tb_cmo_retirement__DOT__unnamedblk1_3__DOT____Vrepeat2 = 0;
    IData/*31:0*/ tb_cmo_retirement__DOT__unnamedblk1_4__DOT____Vrepeat3;
    tb_cmo_retirement__DOT__unnamedblk1_4__DOT____Vrepeat3 = 0;
    IData/*31:0*/ tb_cmo_retirement__DOT__unnamedblk1_5__DOT____Vrepeat4;
    tb_cmo_retirement__DOT__unnamedblk1_5__DOT____Vrepeat4 = 0;
    // Body
    VL_ASSIGN_W(712, vlSelfRef.tb_cmo_retirement__DOT__entry, Vtb_cmo_retirement__ConstPool__CONST_h14c113d2_0);
    vlSelfRef.tb_cmo_retirement__DOT__irq[0U] = 0U;
    vlSelfRef.tb_cmo_retirement__DOT__irq[1U] = 0U;
    vlSelfRef.tb_cmo_retirement__DOT__irq[2U] = 0U;
    vlSelfRef.tb_cmo_retirement__DOT__irq[3U] = 0U;
    vlSelfRef.tb_cmo_retirement__DOT__irq[4U] = 0U;
    vlSelfRef.tb_cmo_retirement__DOT__irq[5U] = 0U;
    vlSelfRef.tb_cmo_retirement__DOT__irq[6U] = 0U;
    tb_cmo_retirement__DOT__unnamedblk1_1__DOT____Vrepeat0 = 2U;
    while (VL_LTS_III(32, 0U, tb_cmo_retirement__DOT__unnamedblk1_1__DOT____Vrepeat0)) {
        Vtb_cmo_retirement___024root____VbeforeTrig_hd76ea377__0(vlSelf, 
                                                                 "@(negedge tb_cmo_retirement.clk)");
        co_await vlSelfRef.__VtrigSched_hd76ea377__0.trigger(0U, 
                                                             nullptr, 
                                                             "@(negedge tb_cmo_retirement.clk)", 
                                                             "tb_cmo_retirement.sv", 
                                                             59);
        tb_cmo_retirement__DOT__unnamedblk1_1__DOT____Vrepeat0 
            = (tb_cmo_retirement__DOT__unnamedblk1_1__DOT____Vrepeat0 
               - (IData)(1U));
    }
    vlSelfRef.tb_cmo_retirement__DOT__rst = 1U;
    Vtb_cmo_retirement___024root____VbeforeTrig_hd76ea377__0(vlSelf, 
                                                             "@(negedge tb_cmo_retirement.clk)");
    co_await vlSelfRef.__VtrigSched_hd76ea377__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(negedge tb_cmo_retirement.clk)", 
                                                         "tb_cmo_retirement.sv", 
                                                         46);
    VL_ASSIGN_W(712, vlSelfRef.tb_cmo_retirement__DOT__entry, Vtb_cmo_retirement__ConstPool__CONST_h14c113d2_0);
    vlSelfRef.tb_cmo_retirement__DOT__irq[0U] = 0U;
    vlSelfRef.tb_cmo_retirement__DOT__irq[1U] = 0U;
    vlSelfRef.tb_cmo_retirement__DOT__irq[2U] = 0U;
    vlSelfRef.tb_cmo_retirement__DOT__irq[3U] = 0U;
    vlSelfRef.tb_cmo_retirement__DOT__irq[4U] = 0U;
    vlSelfRef.tb_cmo_retirement__DOT__irq[5U] = 0U;
    vlSelfRef.tb_cmo_retirement__DOT__irq[6U] = 0U;
    vlSelfRef.tb_cmo_retirement__DOT__entry[6U] = (0x00008000U 
                                                   | vlSelfRef.tb_cmo_retirement__DOT__entry[6U]);
    vlSelfRef.tb_cmo_retirement__DOT__entry[6U] = (0x4a600000U 
                                                   | (0x001fffffU 
                                                      & vlSelfRef.tb_cmo_retirement__DOT__entry[6U]));
    vlSelfRef.tb_cmo_retirement__DOT__entry[7U] = (0xfffffffeU 
                                                   & vlSelfRef.tb_cmo_retirement__DOT__entry[7U]);
    vlSelfRef.tb_cmo_retirement__DOT__entry[9U] = (0x00001000U 
                                                   | (0x0000000fU 
                                                      & vlSelfRef.tb_cmo_retirement__DOT__entry[9U]));
    vlSelfRef.tb_cmo_retirement__DOT__entry[10U] = 8U;
    vlSelfRef.tb_cmo_retirement__DOT__entry[11U] = 
        (0xfffffff0U & vlSelfRef.tb_cmo_retirement__DOT__entry[11U]);
    vlSelfRef.tb_cmo_retirement__DOT__entry[17U] = 
        (0x00080000U | vlSelfRef.tb_cmo_retirement__DOT__entry[17U]);
    vlSelfRef.tb_cmo_retirement__DOT__entry[17U] = 
        (0x01ffffffU & vlSelfRef.tb_cmo_retirement__DOT__entry[17U]);
    vlSelfRef.tb_cmo_retirement__DOT__entry[18U] = 
        (6U | (0xffffffe0U & vlSelfRef.tb_cmo_retirement__DOT__entry[18U]));
    tb_cmo_retirement__DOT__unnamedblk1_2__DOT____Vrepeat1 = 3U;
    while (VL_LTS_III(32, 0U, tb_cmo_retirement__DOT__unnamedblk1_2__DOT____Vrepeat1)) {
        Vtb_cmo_retirement___024root____VbeforeTrig_hd76ea2b8__0(vlSelf, 
                                                                 "@(posedge tb_cmo_retirement.clk)");
        co_await vlSelfRef.__VtrigSched_hd76ea2b8__0.trigger(0U, 
                                                             nullptr, 
                                                             "@(posedge tb_cmo_retirement.clk)", 
                                                             "tb_cmo_retirement.sv", 
                                                             61);
        co_await vlSelfRef.__VdlySched.delay(0x00000000000003e8ULL, 
                                             nullptr, 
                                             "tb_cmo_retirement.sv", 
                                             53);
        if (VL_UNLIKELY(((1U & (((0U != (IData)(vlSelfRef.tb_cmo_retirement__DOT__ack)) 
                                 | (IData)(vlSelfRef.tb_cmo_retirement__DOT__pop)) 
                                | (vlSelfRef.tb_cmo_retirement__DOT__fault[0U] 
                                   >> 1U)))))) {
            VL_WRITEF_NX("[%0t] %%Fatal: tb_cmo_retirement.sv:55: Assertion failed in %m: CBO/younger retirement or trap before terminal completion\n",3, 'M',vlSymsp->name(),"tb_cmo_retirement.check_held", 'T',-9
                         , '#',64,VL_TIME_UNITED_Q(1000));
            VL_STOP_MT("tb_cmo_retirement.sv", 55, "", false);
        }
        if (VL_UNLIKELY((vlSelfRef.tb_cmo_retirement__DOT__dut__DOT__cmo_offer_q))) {
            VL_WRITEF_NX("[%0t] %%Fatal: tb_cmo_retirement.sv:61: Assertion failed in %m: older store not drained\n",3, 'M',vlSymsp->name(),"tb_cmo_retirement.unnamedblk1_2", 'T',-9
                         , '#',64,VL_TIME_UNITED_Q(1000));
            VL_STOP_MT("tb_cmo_retirement.sv", 61, "", false);
        }
        tb_cmo_retirement__DOT__unnamedblk1_2__DOT____Vrepeat1 
            = (tb_cmo_retirement__DOT__unnamedblk1_2__DOT____Vrepeat1 
               - (IData)(1U));
    }
    Vtb_cmo_retirement___024root____VbeforeTrig_hd76ea377__0(vlSelf, 
                                                             "@(negedge tb_cmo_retirement.clk)");
    co_await vlSelfRef.__VtrigSched_hd76ea377__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(negedge tb_cmo_retirement.clk)", 
                                                         "tb_cmo_retirement.sv", 
                                                         62);
    vlSelfRef.tb_cmo_retirement__DOT__no_store = 1U;
    while ((1U & (~ (IData)(vlSelfRef.tb_cmo_retirement__DOT__dut__DOT__cmo_offer_q)))) {
        Vtb_cmo_retirement___024root____VbeforeTrig_h03c8db67__0(vlSelf, 
                                                                 "@( tb_cmo_retirement.dut.cmo_offer_q)");
        co_await vlSelfRef.__VtrigSched_h03c8db67__0.trigger(1U, 
                                                             nullptr, 
                                                             "@( tb_cmo_retirement.dut.cmo_offer_q)", 
                                                             "tb_cmo_retirement.sv", 
                                                             63);
    }
    co_await vlSelfRef.__VdlySched.delay(0x00000000000003e8ULL, 
                                         nullptr, "tb_cmo_retirement.sv", 
                                         63);
    if (VL_UNLIKELY((((((0U != (IData)(vlSelfRef.tb_cmo_retirement__DOT__dut__DOT__cmo_op_q)) 
                        | (0x0000000008000123ULL != vlSelfRef.tb_cmo_retirement__DOT__dut__DOT__cmo_line_q)) 
                       | (vlSelfRef.tb_cmo_retirement__DOT__dut__DOT__cmo_fault_vaddr_q 
                          != vlSelfRef.tb_cmo_retirement__DOT__source_va)) 
                      | (0x0000000080000100ULL != vlSelfRef.tb_cmo_retirement__DOT__dut__DOT__cmo_pc_q))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_cmo_retirement.sv:65: Assertion failed in %m: command metadata mismatch\n",3, 'M',vlSymsp->name(),"tb_cmo_retirement", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb_cmo_retirement.sv", 65, "", false);
    }
    Vtb_cmo_retirement___024root____VbeforeTrig_hd76ea377__0(vlSelf, 
                                                             "@(negedge tb_cmo_retirement.clk)");
    co_await vlSelfRef.__VtrigSched_hd76ea377__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(negedge tb_cmo_retirement.clk)", 
                                                         "tb_cmo_retirement.sv", 
                                                         67);
    vlSelfRef.tb_cmo_retirement__DOT__irq[0U] = (2U 
                                                 | vlSelfRef.tb_cmo_retirement__DOT__irq[0U]);
    vlSelfRef.tb_cmo_retirement__DOT__irq[4U] = (0x0000b000U 
                                                 | (0x00000fffU 
                                                    & vlSelfRef.tb_cmo_retirement__DOT__irq[4U]));
    vlSelfRef.tb_cmo_retirement__DOT__irq[5U] = 0U;
    vlSelfRef.tb_cmo_retirement__DOT__irq[6U] = 0x00000800U;
    vlSelfRef.tb_cmo_retirement__DOT__source_va = 0x0000000000005555ULL;
    tb_cmo_retirement__DOT__unnamedblk1_3__DOT____Vrepeat2 = 3U;
    while (VL_LTS_III(32, 0U, tb_cmo_retirement__DOT__unnamedblk1_3__DOT____Vrepeat2)) {
        Vtb_cmo_retirement___024root____VbeforeTrig_hd76ea2b8__0(vlSelf, 
                                                                 "@(posedge tb_cmo_retirement.clk)");
        co_await vlSelfRef.__VtrigSched_hd76ea2b8__0.trigger(0U, 
                                                             nullptr, 
                                                             "@(posedge tb_cmo_retirement.clk)", 
                                                             "tb_cmo_retirement.sv", 
                                                             70);
        co_await vlSelfRef.__VdlySched.delay(0x00000000000003e8ULL, 
                                             nullptr, 
                                             "tb_cmo_retirement.sv", 
                                             53);
        if (VL_UNLIKELY(((1U & (((0U != (IData)(vlSelfRef.tb_cmo_retirement__DOT__ack)) 
                                 | (IData)(vlSelfRef.tb_cmo_retirement__DOT__pop)) 
                                | (vlSelfRef.tb_cmo_retirement__DOT__fault[0U] 
                                   >> 1U)))))) {
            VL_WRITEF_NX("[%0t] %%Fatal: tb_cmo_retirement.sv:55: Assertion failed in %m: CBO/younger retirement or trap before terminal completion\n",3, 'M',vlSymsp->name(),"tb_cmo_retirement.check_held", 'T',-9
                         , '#',64,VL_TIME_UNITED_Q(1000));
            VL_STOP_MT("tb_cmo_retirement.sv", 55, "", false);
        }
        if (VL_UNLIKELY(((1U & ((~ (IData)(vlSelfRef.tb_cmo_retirement__DOT__dut__DOT__cmo_offer_q)) 
                                | (0xffffffff80001237ULL 
                                   != vlSelfRef.tb_cmo_retirement__DOT__dut__DOT__cmo_fault_vaddr_q)))))) {
            VL_WRITEF_NX("[%0t] %%Fatal: tb_cmo_retirement.sv:71: Assertion failed in %m: VALID/payload not held under stall\n",3, 'M',vlSymsp->name(),"tb_cmo_retirement.unnamedblk1_3", 'T',-9
                         , '#',64,VL_TIME_UNITED_Q(1000));
            VL_STOP_MT("tb_cmo_retirement.sv", 71, "", false);
        }
        tb_cmo_retirement__DOT__unnamedblk1_3__DOT____Vrepeat2 
            = (tb_cmo_retirement__DOT__unnamedblk1_3__DOT____Vrepeat2 
               - (IData)(1U));
    }
    Vtb_cmo_retirement___024root____VbeforeTrig_hd76ea377__0(vlSelf, 
                                                             "@(negedge tb_cmo_retirement.clk)");
    co_await vlSelfRef.__VtrigSched_hd76ea377__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(negedge tb_cmo_retirement.clk)", 
                                                         "tb_cmo_retirement.sv", 
                                                         73);
    vlSelfRef.tb_cmo_retirement__DOT__ready = 1U;
    Vtb_cmo_retirement___024root____VbeforeTrig_hd76ea2b8__0(vlSelf, 
                                                             "@(posedge tb_cmo_retirement.clk)");
    co_await vlSelfRef.__VtrigSched_hd76ea2b8__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge tb_cmo_retirement.clk)", 
                                                         "tb_cmo_retirement.sv", 
                                                         74);
    co_await vlSelfRef.__VdlySched.delay(0x00000000000003e8ULL, 
                                         nullptr, "tb_cmo_retirement.sv", 
                                         74);
    vlSelfRef.tb_cmo_retirement__DOT__ready = 0U;
    tb_cmo_retirement__DOT__unnamedblk1_4__DOT____Vrepeat3 = 3U;
    while (VL_LTS_III(32, 0U, tb_cmo_retirement__DOT__unnamedblk1_4__DOT____Vrepeat3)) {
        Vtb_cmo_retirement___024root____VbeforeTrig_hd76ea2b8__0(vlSelf, 
                                                                 "@(posedge tb_cmo_retirement.clk)");
        co_await vlSelfRef.__VtrigSched_hd76ea2b8__0.trigger(0U, 
                                                             nullptr, 
                                                             "@(posedge tb_cmo_retirement.clk)", 
                                                             "tb_cmo_retirement.sv", 
                                                             75);
        co_await vlSelfRef.__VdlySched.delay(0x00000000000003e8ULL, 
                                             nullptr, 
                                             "tb_cmo_retirement.sv", 
                                             53);
        if (VL_UNLIKELY(((1U & (((0U != (IData)(vlSelfRef.tb_cmo_retirement__DOT__ack)) 
                                 | (IData)(vlSelfRef.tb_cmo_retirement__DOT__pop)) 
                                | (vlSelfRef.tb_cmo_retirement__DOT__fault[0U] 
                                   >> 1U)))))) {
            VL_WRITEF_NX("[%0t] %%Fatal: tb_cmo_retirement.sv:55: Assertion failed in %m: CBO/younger retirement or trap before terminal completion\n",3, 'M',vlSymsp->name(),"tb_cmo_retirement.check_held", 'T',-9
                         , '#',64,VL_TIME_UNITED_Q(1000));
            VL_STOP_MT("tb_cmo_retirement.sv", 55, "", false);
        }
        if (VL_UNLIKELY((vlSelfRef.tb_cmo_retirement__DOT__dut__DOT__cmo_offer_q))) {
            VL_WRITEF_NX("[%0t] %%Fatal: tb_cmo_retirement.sv:75: Assertion failed in %m: duplicate command\n",3, 'M',vlSymsp->name(),"tb_cmo_retirement.unnamedblk1_4", 'T',-9
                         , '#',64,VL_TIME_UNITED_Q(1000));
            VL_STOP_MT("tb_cmo_retirement.sv", 75, "", false);
        }
        tb_cmo_retirement__DOT__unnamedblk1_4__DOT____Vrepeat3 
            = (tb_cmo_retirement__DOT__unnamedblk1_4__DOT____Vrepeat3 
               - (IData)(1U));
    }
    Vtb_cmo_retirement___024root____VbeforeTrig_hd76ea377__0(vlSelf, 
                                                             "@(negedge tb_cmo_retirement.clk)");
    co_await vlSelfRef.__VtrigSched_hd76ea377__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(negedge tb_cmo_retirement.clk)", 
                                                         "tb_cmo_retirement.sv", 
                                                         76);
    vlSelfRef.tb_cmo_retirement__DOT__done = 1U;
    Vtb_cmo_retirement___024root____VbeforeTrig_hd76ea2b8__0(vlSelf, 
                                                             "@(posedge tb_cmo_retirement.clk)");
    co_await vlSelfRef.__VtrigSched_hd76ea2b8__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge tb_cmo_retirement.clk)", 
                                                         "tb_cmo_retirement.sv", 
                                                         77);
    co_await vlSelfRef.__VdlySched.delay(0x00000000000003e8ULL, 
                                         nullptr, "tb_cmo_retirement.sv", 
                                         77);
    vlSelfRef.tb_cmo_retirement__DOT__done = 0U;
    if (VL_UNLIKELY(((1U & (((1U != (IData)(vlSelfRef.tb_cmo_retirement__DOT__ack)) 
                             | (~ (IData)(vlSelfRef.tb_cmo_retirement__DOT__pop))) 
                            | (vlSelfRef.tb_cmo_retirement__DOT__fault[0U] 
                               >> 1U)))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_cmo_retirement.sv:78: Assertion failed in %m: success not retired exactly once\n",3, 'M',vlSymsp->name(),"tb_cmo_retirement", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb_cmo_retirement.sv", 78, "", false);
    }
    Vtb_cmo_retirement___024root____VbeforeTrig_hd76ea2b8__0(vlSelf, 
                                                             "@(posedge tb_cmo_retirement.clk)");
    co_await vlSelfRef.__VtrigSched_hd76ea2b8__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge tb_cmo_retirement.clk)", 
                                                         "tb_cmo_retirement.sv", 
                                                         79);
    co_await vlSelfRef.__VdlySched.delay(0x00000000000003e8ULL, 
                                         nullptr, "tb_cmo_retirement.sv", 
                                         79);
    VL_ASSIGN_W(712, vlSelfRef.tb_cmo_retirement__DOT__entry, Vtb_cmo_retirement__ConstPool__CONST_h14c113d2_0);
    Vtb_cmo_retirement___024root____VbeforeTrig_hd76ea377__0(vlSelf, 
                                                             "@(negedge tb_cmo_retirement.clk)");
    co_await vlSelfRef.__VtrigSched_hd76ea377__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(negedge tb_cmo_retirement.clk)", 
                                                         "tb_cmo_retirement.sv", 
                                                         80);
    vlSelfRef.tb_cmo_retirement__DOT__irq[0U] = 0U;
    vlSelfRef.tb_cmo_retirement__DOT__irq[1U] = 0U;
    vlSelfRef.tb_cmo_retirement__DOT__irq[2U] = 0U;
    vlSelfRef.tb_cmo_retirement__DOT__irq[3U] = 0U;
    vlSelfRef.tb_cmo_retirement__DOT__irq[4U] = 0U;
    vlSelfRef.tb_cmo_retirement__DOT__irq[5U] = 0U;
    vlSelfRef.tb_cmo_retirement__DOT__irq[6U] = 0U;
    Vtb_cmo_retirement___024root____VbeforeTrig_hd76ea377__0(vlSelf, 
                                                             "@(negedge tb_cmo_retirement.clk)");
    co_await vlSelfRef.__VtrigSched_hd76ea377__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(negedge tb_cmo_retirement.clk)", 
                                                         "tb_cmo_retirement.sv", 
                                                         46);
    VL_ASSIGN_W(712, vlSelfRef.tb_cmo_retirement__DOT__entry, Vtb_cmo_retirement__ConstPool__CONST_h14c113d2_0);
    vlSelfRef.tb_cmo_retirement__DOT__irq[0U] = 0U;
    vlSelfRef.tb_cmo_retirement__DOT__irq[1U] = 0U;
    vlSelfRef.tb_cmo_retirement__DOT__irq[2U] = 0U;
    vlSelfRef.tb_cmo_retirement__DOT__irq[3U] = 0U;
    vlSelfRef.tb_cmo_retirement__DOT__irq[4U] = 0U;
    vlSelfRef.tb_cmo_retirement__DOT__irq[5U] = 0U;
    vlSelfRef.tb_cmo_retirement__DOT__irq[6U] = 0U;
    vlSelfRef.tb_cmo_retirement__DOT__entry[6U] = (0x00008000U 
                                                   | vlSelfRef.tb_cmo_retirement__DOT__entry[6U]);
    vlSelfRef.tb_cmo_retirement__DOT__entry[6U] = (0x4a600000U 
                                                   | (0x001fffffU 
                                                      & vlSelfRef.tb_cmo_retirement__DOT__entry[6U]));
    vlSelfRef.tb_cmo_retirement__DOT__entry[7U] = (0xfffffffeU 
                                                   & vlSelfRef.tb_cmo_retirement__DOT__entry[7U]);
    vlSelfRef.tb_cmo_retirement__DOT__entry[9U] = (0x00001000U 
                                                   | (0x0000000fU 
                                                      & vlSelfRef.tb_cmo_retirement__DOT__entry[9U]));
    vlSelfRef.tb_cmo_retirement__DOT__entry[10U] = 8U;
    vlSelfRef.tb_cmo_retirement__DOT__entry[11U] = 
        (0xfffffff0U & vlSelfRef.tb_cmo_retirement__DOT__entry[11U]);
    vlSelfRef.tb_cmo_retirement__DOT__entry[17U] = 
        (0x00080000U | vlSelfRef.tb_cmo_retirement__DOT__entry[17U]);
    vlSelfRef.tb_cmo_retirement__DOT__entry[17U] = 
        (0x01ffffffU & vlSelfRef.tb_cmo_retirement__DOT__entry[17U]);
    vlSelfRef.tb_cmo_retirement__DOT__entry[18U] = 
        (6U | (0xffffffe0U & vlSelfRef.tb_cmo_retirement__DOT__entry[18U]));
    while ((1U & (~ (IData)(vlSelfRef.tb_cmo_retirement__DOT__dut__DOT__cmo_offer_q)))) {
        Vtb_cmo_retirement___024root____VbeforeTrig_h03c8db67__0(vlSelf, 
                                                                 "@( tb_cmo_retirement.dut.cmo_offer_q)");
        co_await vlSelfRef.__VtrigSched_h03c8db67__0.trigger(1U, 
                                                             nullptr, 
                                                             "@( tb_cmo_retirement.dut.cmo_offer_q)", 
                                                             "tb_cmo_retirement.sv", 
                                                             82);
    }
    Vtb_cmo_retirement___024root____VbeforeTrig_hd76ea377__0(vlSelf, 
                                                             "@(negedge tb_cmo_retirement.clk)");
    co_await vlSelfRef.__VtrigSched_hd76ea377__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(negedge tb_cmo_retirement.clk)", 
                                                         "tb_cmo_retirement.sv", 
                                                         82);
    vlSelfRef.tb_cmo_retirement__DOT__ready = 1U;
    Vtb_cmo_retirement___024root____VbeforeTrig_hd76ea2b8__0(vlSelf, 
                                                             "@(posedge tb_cmo_retirement.clk)");
    co_await vlSelfRef.__VtrigSched_hd76ea2b8__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge tb_cmo_retirement.clk)", 
                                                         "tb_cmo_retirement.sv", 
                                                         83);
    co_await vlSelfRef.__VdlySched.delay(0x00000000000003e8ULL, 
                                         nullptr, "tb_cmo_retirement.sv", 
                                         83);
    vlSelfRef.tb_cmo_retirement__DOT__ready = 0U;
    Vtb_cmo_retirement___024root____VbeforeTrig_hd76ea377__0(vlSelf, 
                                                             "@(negedge tb_cmo_retirement.clk)");
    co_await vlSelfRef.__VtrigSched_hd76ea377__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(negedge tb_cmo_retirement.clk)", 
                                                         "tb_cmo_retirement.sv", 
                                                         84);
    vlSelfRef.tb_cmo_retirement__DOT__halt = 1U;
    vlSelfRef.tb_cmo_retirement__DOT__done = 1U;
    vlSelfRef.tb_cmo_retirement__DOT__error = 1U;
    Vtb_cmo_retirement___024root____VbeforeTrig_hd76ea2b8__0(vlSelf, 
                                                             "@(posedge tb_cmo_retirement.clk)");
    co_await vlSelfRef.__VtrigSched_hd76ea2b8__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge tb_cmo_retirement.clk)", 
                                                         "tb_cmo_retirement.sv", 
                                                         85);
    co_await vlSelfRef.__VdlySched.delay(0x00000000000003e8ULL, 
                                         nullptr, "tb_cmo_retirement.sv", 
                                         85);
    vlSelfRef.tb_cmo_retirement__DOT__done = 0U;
    tb_cmo_retirement__DOT__unnamedblk1_5__DOT____Vrepeat4 = 3U;
    while (VL_LTS_III(32, 0U, tb_cmo_retirement__DOT__unnamedblk1_5__DOT____Vrepeat4)) {
        Vtb_cmo_retirement___024root____VbeforeTrig_hd76ea2b8__0(vlSelf, 
                                                                 "@(posedge tb_cmo_retirement.clk)");
        co_await vlSelfRef.__VtrigSched_hd76ea2b8__0.trigger(0U, 
                                                             nullptr, 
                                                             "@(posedge tb_cmo_retirement.clk)", 
                                                             "tb_cmo_retirement.sv", 
                                                             86);
        co_await vlSelfRef.__VdlySched.delay(0x00000000000003e8ULL, 
                                             nullptr, 
                                             "tb_cmo_retirement.sv", 
                                             53);
        if (VL_UNLIKELY(((1U & (((0U != (IData)(vlSelfRef.tb_cmo_retirement__DOT__ack)) 
                                 | (IData)(vlSelfRef.tb_cmo_retirement__DOT__pop)) 
                                | (vlSelfRef.tb_cmo_retirement__DOT__fault[0U] 
                                   >> 1U)))))) {
            VL_WRITEF_NX("[%0t] %%Fatal: tb_cmo_retirement.sv:55: Assertion failed in %m: CBO/younger retirement or trap before terminal completion\n",3, 'M',vlSymsp->name(),"tb_cmo_retirement.check_held", 'T',-9
                         , '#',64,VL_TIME_UNITED_Q(1000));
            VL_STOP_MT("tb_cmo_retirement.sv", 55, "", false);
        }
        tb_cmo_retirement__DOT__unnamedblk1_5__DOT____Vrepeat4 
            = (tb_cmo_retirement__DOT__unnamedblk1_5__DOT____Vrepeat4 
               - (IData)(1U));
    }
    Vtb_cmo_retirement___024root____VbeforeTrig_hd76ea377__0(vlSelf, 
                                                             "@(negedge tb_cmo_retirement.clk)");
    co_await vlSelfRef.__VtrigSched_hd76ea377__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(negedge tb_cmo_retirement.clk)", 
                                                         "tb_cmo_retirement.sv", 
                                                         87);
    vlSelfRef.tb_cmo_retirement__DOT__halt = 0U;
    co_await vlSelfRef.__VdlySched.delay(0x00000000000003e8ULL, 
                                         nullptr, "tb_cmo_retirement.sv", 
                                         88);
    if (VL_UNLIKELY(((1U & (((((~ (vlSelfRef.tb_cmo_retirement__DOT__fault[0U] 
                                   >> 1U)) | (7ULL 
                                              != (((QData)((IData)(vlSelfRef.tb_cmo_retirement__DOT__fault[6U])) 
                                                   << 0x00000034U) 
                                                  | (((QData)((IData)(vlSelfRef.tb_cmo_retirement__DOT__fault[5U])) 
                                                      << 0x00000014U) 
                                                     | ((QData)((IData)(vlSelfRef.tb_cmo_retirement__DOT__fault[4U])) 
                                                        >> 0x0000000cU))))) 
                              | (0x0000000000005555ULL 
                                 != (((QData)((IData)(vlSelfRef.tb_cmo_retirement__DOT__fault[4U])) 
                                      << 0x00000034U) 
                                     | (((QData)((IData)(vlSelfRef.tb_cmo_retirement__DOT__fault[3U])) 
                                         << 0x00000014U) 
                                        | ((QData)((IData)(vlSelfRef.tb_cmo_retirement__DOT__fault[2U])) 
                                           >> 0x0000000cU))))) 
                             | (0U != (IData)(vlSelfRef.tb_cmo_retirement__DOT__ack))) 
                            | (IData)(vlSelfRef.tb_cmo_retirement__DOT__pop)))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_cmo_retirement.sv:90: Assertion failed in %m: precise CBO fault or halt completion retention failed\n",3, 'M',vlSymsp->name(),"tb_cmo_retirement", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb_cmo_retirement.sv", 90, "", false);
    }
    Vtb_cmo_retirement___024root____VbeforeTrig_hd76ea2b8__0(vlSelf, 
                                                             "@(posedge tb_cmo_retirement.clk)");
    co_await vlSelfRef.__VtrigSched_hd76ea2b8__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge tb_cmo_retirement.clk)", 
                                                         "tb_cmo_retirement.sv", 
                                                         91);
    co_await vlSelfRef.__VdlySched.delay(0x00000000000003e8ULL, 
                                         nullptr, "tb_cmo_retirement.sv", 
                                         91);
    VL_ASSIGN_W(712, vlSelfRef.tb_cmo_retirement__DOT__entry, Vtb_cmo_retirement__ConstPool__CONST_h14c113d2_0);
    Vtb_cmo_retirement___024root____VbeforeTrig_hd76ea377__0(vlSelf, 
                                                             "@(negedge tb_cmo_retirement.clk)");
    co_await vlSelfRef.__VtrigSched_hd76ea377__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(negedge tb_cmo_retirement.clk)", 
                                                         "tb_cmo_retirement.sv", 
                                                         92);
    if (VL_UNLIKELY((vlSelfRef.tb_cmo_retirement__DOT__active))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_cmo_retirement.sv:93: Assertion failed in %m: terminal context not released\n",3, 'M',vlSymsp->name(),"tb_cmo_retirement", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb_cmo_retirement.sv", 93, "", false);
    }
    VL_WRITEF_NX("PASS: native CVA6 retirement CBO hold, payload, interrupt deferral, success and precise error\n",0);
    VL_FINISH_MT("tb_cmo_retirement.sv", 95, "");
    co_return;
}

VlCoroutine Vtb_cmo_retirement___024root___eval_initial__TOP__Vtiming__1(Vtb_cmo_retirement___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_cmo_retirement___024root___eval_initial__TOP__Vtiming__1\n"); );
    Vtb_cmo_retirement__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    co_await vlSelfRef.__VdlySched.delay(0x0000000000989680ULL, 
                                         nullptr, "tb_cmo_retirement.sv", 
                                         97);
    VL_WRITEF_NX("[%0t] %%Fatal: tb_cmo_retirement.sv:97: Assertion failed in %m: retirement watchdog\n",3, 'M',vlSymsp->name(),"tb_cmo_retirement", 'T',-9
                 , '#',64,VL_TIME_UNITED_Q(1000));
    VL_STOP_MT("tb_cmo_retirement.sv", 97, "", false);
    co_return;
}

VlCoroutine Vtb_cmo_retirement___024root___eval_initial__TOP__Vtiming__2(Vtb_cmo_retirement___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_cmo_retirement___024root___eval_initial__TOP__Vtiming__2\n"); );
    Vtb_cmo_retirement__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    while (VL_LIKELY(!vlSymsp->_vm_contextp__->gotFinish())) {
        co_await vlSelfRef.__VdlySched.delay(0x0000000000001388ULL, 
                                             nullptr, 
                                             "tb_cmo_retirement.sv", 
                                             29);
        vlSelfRef.tb_cmo_retirement__DOT__clk = (1U 
                                                 & (~ (IData)(vlSelfRef.tb_cmo_retirement__DOT__clk)));
    }
    co_return;
}

bool Vtb_cmo_retirement___024root___trigger_anySet__ico(const VlUnpacked<QData/*63:0*/, 1> &in) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_cmo_retirement___024root___trigger_anySet__ico\n"); );
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

bool Vtb_cmo_retirement___024root___trigger_anySet__act(const VlUnpacked<QData/*63:0*/, 1> &in) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_cmo_retirement___024root___trigger_anySet__act\n"); );
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

void Vtb_cmo_retirement___024root___act_comb__TOP__0(Vtb_cmo_retirement___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_cmo_retirement___024root___act_comb__TOP__0\n"); );
    Vtb_cmo_retirement__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    CData/*0:0*/ __VdfgRegularize_h6e95ff9d_0_8;
    __VdfgRegularize_h6e95ff9d_0_8 = 0;
    CData/*0:0*/ __VdfgRegularize_h6e95ff9d_0_9;
    __VdfgRegularize_h6e95ff9d_0_9 = 0;
    CData/*0:0*/ __VdfgRegularize_h6e95ff9d_0_10;
    __VdfgRegularize_h6e95ff9d_0_10 = 0;
    VlWide<7>/*223:0*/ __Vtemp_2;
    // Body
    vlSelfRef.tb_cmo_retirement__DOT__dut__DOT__cmo_take 
        = ((IData)(vlSelfRef.tb_cmo_retirement__DOT__ready) 
           & (IData)(vlSelfRef.tb_cmo_retirement__DOT__dut__DOT__cmo_offer_q));
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_12 = (1U 
                                                 & ((~ (IData)(vlSelfRef.tb_cmo_retirement__DOT__halt)) 
                                                    & (vlSelfRef.tb_cmo_retirement__DOT__entry[6U] 
                                                       >> 0x0000000fU)));
    if ((0x00008000U & vlSelfRef.tb_cmo_retirement__DOT__entry[6U])) {
        if ((2U & vlSelfRef.tb_cmo_retirement__DOT__entry[0U])) {
            __Vtemp_2[0U] = vlSelfRef.tb_cmo_retirement__DOT__entry[0U];
            __Vtemp_2[1U] = vlSelfRef.tb_cmo_retirement__DOT__entry[1U];
            __Vtemp_2[2U] = vlSelfRef.tb_cmo_retirement__DOT__entry[2U];
            __Vtemp_2[3U] = vlSelfRef.tb_cmo_retirement__DOT__entry[3U];
            __Vtemp_2[4U] = vlSelfRef.tb_cmo_retirement__DOT__entry[4U];
            __Vtemp_2[5U] = vlSelfRef.tb_cmo_retirement__DOT__entry[5U];
            __Vtemp_2[6U] = vlSelfRef.tb_cmo_retirement__DOT__entry[6U];
        } else if ((2U & vlSelfRef.tb_cmo_retirement__DOT__irq[0U])) {
            __Vtemp_2[0U] = vlSelfRef.tb_cmo_retirement__DOT__irq[0U];
            __Vtemp_2[1U] = vlSelfRef.tb_cmo_retirement__DOT__irq[1U];
            __Vtemp_2[2U] = (((IData)((((QData)((IData)(vlSelfRef.tb_cmo_retirement__DOT__entry[4U])) 
                                        << 0x00000034U) 
                                       | (((QData)((IData)(vlSelfRef.tb_cmo_retirement__DOT__entry[3U])) 
                                           << 0x00000014U) 
                                          | ((QData)((IData)(vlSelfRef.tb_cmo_retirement__DOT__entry[2U])) 
                                             >> 0x0000000cU)))) 
                              << 0x0000000cU) | (0x00000fffU 
                                                 & vlSelfRef.tb_cmo_retirement__DOT__irq[2U]));
            __Vtemp_2[3U] = (((IData)((((QData)((IData)(vlSelfRef.tb_cmo_retirement__DOT__entry[4U])) 
                                        << 0x00000034U) 
                                       | (((QData)((IData)(vlSelfRef.tb_cmo_retirement__DOT__entry[3U])) 
                                           << 0x00000014U) 
                                          | ((QData)((IData)(vlSelfRef.tb_cmo_retirement__DOT__entry[2U])) 
                                             >> 0x0000000cU)))) 
                              >> 0x00000014U) | ((IData)(
                                                         ((((QData)((IData)(vlSelfRef.tb_cmo_retirement__DOT__entry[4U])) 
                                                            << 0x00000034U) 
                                                           | (((QData)((IData)(vlSelfRef.tb_cmo_retirement__DOT__entry[3U])) 
                                                               << 0x00000014U) 
                                                              | ((QData)((IData)(vlSelfRef.tb_cmo_retirement__DOT__entry[2U])) 
                                                                 >> 0x0000000cU))) 
                                                          >> 0x00000020U)) 
                                                 << 0x0000000cU));
            __Vtemp_2[4U] = (((IData)(((((QData)((IData)(vlSelfRef.tb_cmo_retirement__DOT__entry[4U])) 
                                         << 0x00000034U) 
                                        | (((QData)((IData)(vlSelfRef.tb_cmo_retirement__DOT__entry[3U])) 
                                            << 0x00000014U) 
                                           | ((QData)((IData)(vlSelfRef.tb_cmo_retirement__DOT__entry[2U])) 
                                              >> 0x0000000cU))) 
                                       >> 0x00000020U)) 
                              >> 0x00000014U) | ((IData)(
                                                         (((QData)((IData)(vlSelfRef.tb_cmo_retirement__DOT__irq[6U])) 
                                                           << 0x00000034U) 
                                                          | (((QData)((IData)(vlSelfRef.tb_cmo_retirement__DOT__irq[5U])) 
                                                              << 0x00000014U) 
                                                             | ((QData)((IData)(vlSelfRef.tb_cmo_retirement__DOT__irq[4U])) 
                                                                >> 0x0000000cU)))) 
                                                 << 0x0000000cU));
            __Vtemp_2[5U] = (((IData)((((QData)((IData)(vlSelfRef.tb_cmo_retirement__DOT__irq[6U])) 
                                        << 0x00000034U) 
                                       | (((QData)((IData)(vlSelfRef.tb_cmo_retirement__DOT__irq[5U])) 
                                           << 0x00000014U) 
                                          | ((QData)((IData)(vlSelfRef.tb_cmo_retirement__DOT__irq[4U])) 
                                             >> 0x0000000cU)))) 
                              >> 0x00000014U) | ((IData)(
                                                         ((((QData)((IData)(vlSelfRef.tb_cmo_retirement__DOT__irq[6U])) 
                                                            << 0x00000034U) 
                                                           | (((QData)((IData)(vlSelfRef.tb_cmo_retirement__DOT__irq[5U])) 
                                                               << 0x00000014U) 
                                                              | ((QData)((IData)(vlSelfRef.tb_cmo_retirement__DOT__irq[4U])) 
                                                                 >> 0x0000000cU))) 
                                                          >> 0x00000020U)) 
                                                 << 0x0000000cU));
            __Vtemp_2[6U] = ((IData)(((((QData)((IData)(vlSelfRef.tb_cmo_retirement__DOT__irq[6U])) 
                                        << 0x00000034U) 
                                       | (((QData)((IData)(vlSelfRef.tb_cmo_retirement__DOT__irq[5U])) 
                                           << 0x00000014U) 
                                          | ((QData)((IData)(vlSelfRef.tb_cmo_retirement__DOT__irq[4U])) 
                                             >> 0x0000000cU))) 
                                      >> 0x00000020U)) 
                             >> 0x00000014U);
        } else {
            __Vtemp_2[0U] = 0U;
            __Vtemp_2[1U] = 0U;
            __Vtemp_2[2U] = 0U;
            __Vtemp_2[3U] = 0U;
            __Vtemp_2[4U] = 0U;
            __Vtemp_2[5U] = 0U;
            __Vtemp_2[6U] = 0U;
        }
    } else {
        __Vtemp_2[0U] = 0U;
        __Vtemp_2[1U] = 0U;
        __Vtemp_2[2U] = 0U;
        __Vtemp_2[3U] = 0U;
        __Vtemp_2[4U] = 0U;
        __Vtemp_2[5U] = 0U;
        __Vtemp_2[6U] = 0U;
    }
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_4[0U] = __Vtemp_2[0U];
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_4[1U] = __Vtemp_2[1U];
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_4[2U] = __Vtemp_2[2U];
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_4[3U] = __Vtemp_2[3U];
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_4[4U] = __Vtemp_2[4U];
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_4[5U] = __Vtemp_2[5U];
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_4[6U] = 
        (0x00000fffU & __Vtemp_2[6U]);
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_3 = (1U 
                                                & (~ 
                                                   ((0x3dU 
                                                     <= 
                                                     (0x000000ffU 
                                                      & (vlSelfRef.tb_cmo_retirement__DOT__entry[6U] 
                                                         >> 0x00000015U))) 
                                                    & (0x52U 
                                                       >= 
                                                       (0x000000ffU 
                                                        & (vlSelfRef.tb_cmo_retirement__DOT__entry[6U] 
                                                           >> 0x00000015U))))));
    vlSelfRef.tb_cmo_retirement__DOT__dut__DOT__cmo_head 
        = ((vlSelfRef.tb_cmo_retirement__DOT__entry[6U] 
            >> 0x0000000fU) & ((0x53U == (0x000000ffU 
                                          & (vlSelfRef.tb_cmo_retirement__DOT__entry[6U] 
                                             >> 0x00000015U))) 
                               | ((0x54U == (0x000000ffU 
                                             & (vlSelfRef.tb_cmo_retirement__DOT__entry[6U] 
                                                >> 0x00000015U))) 
                                  | (0x55U == (0x000000ffU 
                                               & (vlSelfRef.tb_cmo_retirement__DOT__entry[6U] 
                                                  >> 0x00000015U))))));
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_7[0U] = 
        ((vlSelfRef.__VdfgRegularize_h6e95ff9d_0_4[1U] 
          << 0x0000001eU) | (vlSelfRef.__VdfgRegularize_h6e95ff9d_0_4[0U] 
                             >> 2U));
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_7[1U] = 
        ((vlSelfRef.__VdfgRegularize_h6e95ff9d_0_4[2U] 
          << 0x0000001eU) | (vlSelfRef.__VdfgRegularize_h6e95ff9d_0_4[1U] 
                             >> 2U));
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_7[2U] = 
        ((vlSelfRef.__VdfgRegularize_h6e95ff9d_0_4[3U] 
          << 0x0000001eU) | (vlSelfRef.__VdfgRegularize_h6e95ff9d_0_4[2U] 
                             >> 2U));
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_7[3U] = 
        ((vlSelfRef.__VdfgRegularize_h6e95ff9d_0_4[4U] 
          << 0x0000001eU) | (vlSelfRef.__VdfgRegularize_h6e95ff9d_0_4[3U] 
                             >> 2U));
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_7[4U] = 
        ((vlSelfRef.__VdfgRegularize_h6e95ff9d_0_4[5U] 
          << 0x0000001eU) | (vlSelfRef.__VdfgRegularize_h6e95ff9d_0_4[4U] 
                             >> 2U));
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_7[5U] = 
        ((vlSelfRef.__VdfgRegularize_h6e95ff9d_0_4[6U] 
          << 0x0000001eU) | (vlSelfRef.__VdfgRegularize_h6e95ff9d_0_4[5U] 
                             >> 2U));
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_7[6U] = 
        (0x000003ffU & (vlSelfRef.__VdfgRegularize_h6e95ff9d_0_4[6U] 
                        >> 2U));
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_11 = ((IData)(vlSelfRef.__VdfgRegularize_h6e95ff9d_0_3) 
                                                 & (2U 
                                                    == 
                                                    (0x0000000fU 
                                                     & ((vlSelfRef.tb_cmo_retirement__DOT__entry[7U] 
                                                         << 3U) 
                                                        | (vlSelfRef.tb_cmo_retirement__DOT__entry[6U] 
                                                           >> 0x0000001dU)))));
    vlSelfRef.tb_cmo_retirement__DOT__dut__DOT__cmo_eligible 
        = (((((((IData)(vlSelfRef.tb_cmo_retirement__DOT__dut__DOT__cmo_head) 
                & (~ (IData)(vlSelfRef.tb_cmo_retirement__DOT__halt))) 
               & (~ (vlSelfRef.tb_cmo_retirement__DOT__entry[0U] 
                     >> 1U))) & (0x0a600000U == (0x1fe00000U 
                                                 & vlSelfRef.tb_cmo_retirement__DOT__entry[6U]))) 
             & (~ (vlSelfRef.tb_cmo_retirement__DOT__irq[0U] 
                   >> 1U))) & (IData)(vlSelfRef.tb_cmo_retirement__DOT__no_store)) 
           & (~ (IData)(vlSelfRef.tb_cmo_retirement__DOT__active)));
    __VdfgRegularize_h6e95ff9d_0_10 = (1U & ((~ (IData)(vlSelfRef.tb_cmo_retirement__DOT__dut__DOT__cmo_head)) 
                                             | ((~ (IData)(vlSelfRef.tb_cmo_retirement__DOT__dut__DOT__cmo_error_q)) 
                                                & (IData)(vlSelfRef.tb_cmo_retirement__DOT__dut__DOT__cmo_complete_q))));
    if (vlSelfRef.tb_cmo_retirement__DOT__active) {
        if (((IData)(vlSelfRef.tb_cmo_retirement__DOT__dut__DOT__cmo_complete_q) 
             & ((IData)(vlSelfRef.tb_cmo_retirement__DOT__dut__DOT__cmo_error_q) 
                & ((~ (IData)(vlSelfRef.tb_cmo_retirement__DOT__halt)) 
                   & (IData)(vlSelfRef.tb_cmo_retirement__DOT__dut__DOT__cmo_head))))) {
            vlSelfRef.tb_cmo_retirement__DOT__fault[0U] = 2U;
            vlSelfRef.tb_cmo_retirement__DOT__fault[1U] = 0U;
            vlSelfRef.tb_cmo_retirement__DOT__fault[2U] 
                = ((IData)(vlSelfRef.tb_cmo_retirement__DOT__dut__DOT__cmo_fault_vaddr_q) 
                   << 0x0000000cU);
            vlSelfRef.tb_cmo_retirement__DOT__fault[3U] 
                = (((IData)(vlSelfRef.tb_cmo_retirement__DOT__dut__DOT__cmo_fault_vaddr_q) 
                    >> 0x00000014U) | ((IData)((vlSelfRef.tb_cmo_retirement__DOT__dut__DOT__cmo_fault_vaddr_q 
                                                >> 0x00000020U)) 
                                       << 0x0000000cU));
            vlSelfRef.tb_cmo_retirement__DOT__fault[4U] 
                = (0x00007000U | ((IData)((vlSelfRef.tb_cmo_retirement__DOT__dut__DOT__cmo_fault_vaddr_q 
                                           >> 0x00000020U)) 
                                  >> 0x00000014U));
            vlSelfRef.tb_cmo_retirement__DOT__fault[5U] = 0U;
            vlSelfRef.tb_cmo_retirement__DOT__fault[6U] = 0U;
        } else {
            vlSelfRef.tb_cmo_retirement__DOT__fault[0U] 
                = ((vlSelfRef.__VdfgRegularize_h6e95ff9d_0_7[0U] 
                    << 2U) | (1U & vlSelfRef.__VdfgRegularize_h6e95ff9d_0_4[0U]));
            vlSelfRef.tb_cmo_retirement__DOT__fault[1U] 
                = ((vlSelfRef.__VdfgRegularize_h6e95ff9d_0_7[0U] 
                    >> 0x0000001eU) | (vlSelfRef.__VdfgRegularize_h6e95ff9d_0_7[1U] 
                                       << 2U));
            vlSelfRef.tb_cmo_retirement__DOT__fault[2U] 
                = ((vlSelfRef.__VdfgRegularize_h6e95ff9d_0_7[1U] 
                    >> 0x0000001eU) | (vlSelfRef.__VdfgRegularize_h6e95ff9d_0_7[2U] 
                                       << 2U));
            vlSelfRef.tb_cmo_retirement__DOT__fault[3U] 
                = ((vlSelfRef.__VdfgRegularize_h6e95ff9d_0_7[2U] 
                    >> 0x0000001eU) | (vlSelfRef.__VdfgRegularize_h6e95ff9d_0_7[3U] 
                                       << 2U));
            vlSelfRef.tb_cmo_retirement__DOT__fault[4U] 
                = ((vlSelfRef.__VdfgRegularize_h6e95ff9d_0_7[3U] 
                    >> 0x0000001eU) | (vlSelfRef.__VdfgRegularize_h6e95ff9d_0_7[4U] 
                                       << 2U));
            vlSelfRef.tb_cmo_retirement__DOT__fault[5U] 
                = ((vlSelfRef.__VdfgRegularize_h6e95ff9d_0_7[4U] 
                    >> 0x0000001eU) | (vlSelfRef.__VdfgRegularize_h6e95ff9d_0_7[5U] 
                                       << 2U));
            vlSelfRef.tb_cmo_retirement__DOT__fault[6U] 
                = ((vlSelfRef.__VdfgRegularize_h6e95ff9d_0_7[5U] 
                    >> 0x0000001eU) | (vlSelfRef.__VdfgRegularize_h6e95ff9d_0_7[6U] 
                                       << 2U));
        }
    } else {
        vlSelfRef.tb_cmo_retirement__DOT__fault[0U] 
            = ((vlSelfRef.__VdfgRegularize_h6e95ff9d_0_7[0U] 
                << 2U) | ((2U & (((~ (IData)(vlSelfRef.tb_cmo_retirement__DOT__halt)) 
                                  << 1U) & vlSelfRef.__VdfgRegularize_h6e95ff9d_0_4[0U])) 
                          | (1U & vlSelfRef.__VdfgRegularize_h6e95ff9d_0_4[0U])));
        vlSelfRef.tb_cmo_retirement__DOT__fault[1U] 
            = ((vlSelfRef.__VdfgRegularize_h6e95ff9d_0_7[0U] 
                >> 0x0000001eU) | (vlSelfRef.__VdfgRegularize_h6e95ff9d_0_7[1U] 
                                   << 2U));
        vlSelfRef.tb_cmo_retirement__DOT__fault[2U] 
            = ((vlSelfRef.__VdfgRegularize_h6e95ff9d_0_7[1U] 
                >> 0x0000001eU) | (vlSelfRef.__VdfgRegularize_h6e95ff9d_0_7[2U] 
                                   << 2U));
        vlSelfRef.tb_cmo_retirement__DOT__fault[3U] 
            = ((vlSelfRef.__VdfgRegularize_h6e95ff9d_0_7[2U] 
                >> 0x0000001eU) | (vlSelfRef.__VdfgRegularize_h6e95ff9d_0_7[3U] 
                                   << 2U));
        vlSelfRef.tb_cmo_retirement__DOT__fault[4U] 
            = ((vlSelfRef.__VdfgRegularize_h6e95ff9d_0_7[3U] 
                >> 0x0000001eU) | (vlSelfRef.__VdfgRegularize_h6e95ff9d_0_7[4U] 
                                   << 2U));
        vlSelfRef.tb_cmo_retirement__DOT__fault[5U] 
            = ((vlSelfRef.__VdfgRegularize_h6e95ff9d_0_7[4U] 
                >> 0x0000001eU) | (vlSelfRef.__VdfgRegularize_h6e95ff9d_0_7[5U] 
                                   << 2U));
        vlSelfRef.tb_cmo_retirement__DOT__fault[6U] 
            = ((vlSelfRef.__VdfgRegularize_h6e95ff9d_0_7[5U] 
                >> 0x0000001eU) | (vlSelfRef.__VdfgRegularize_h6e95ff9d_0_7[6U] 
                                   << 2U));
    }
    vlSelfRef.tb_cmo_retirement__DOT__pop = ((~ (vlSelfRef.tb_cmo_retirement__DOT__entry[0U] 
                                                 >> 1U)) 
                                             & ((IData)(vlSelfRef.__VdfgRegularize_h6e95ff9d_0_11) 
                                                & ((IData)(__VdfgRegularize_h6e95ff9d_0_10) 
                                                   & (IData)(vlSelfRef.__VdfgRegularize_h6e95ff9d_0_12))));
    __VdfgRegularize_h6e95ff9d_0_9 = (1U & ((~ (IData)(vlSelfRef.__VdfgRegularize_h6e95ff9d_0_11)) 
                                            | (IData)(__VdfgRegularize_h6e95ff9d_0_10)));
    __VdfgRegularize_h6e95ff9d_0_8 = ((~ (vlSelfRef.tb_cmo_retirement__DOT__entry[0U] 
                                          >> 1U)) & 
                                      ((IData)(vlSelfRef.__VdfgRegularize_h6e95ff9d_0_3) 
                                       & (((0x1cU == 
                                            (0x000000ffU 
                                             & (vlSelfRef.tb_cmo_retirement__DOT__entry[6U] 
                                                >> 0x00000015U)))
                                            ? (IData)(vlSelfRef.tb_cmo_retirement__DOT__no_store)
                                            : ((0x1dU 
                                                == 
                                                (0x000000ffU 
                                                 & (vlSelfRef.tb_cmo_retirement__DOT__entry[6U] 
                                                    >> 0x00000015U)))
                                                ? (IData)(vlSelfRef.tb_cmo_retirement__DOT__no_store)
                                                : (
                                                   (0x1eU 
                                                    == 
                                                    (0x000000ffU 
                                                     & (vlSelfRef.tb_cmo_retirement__DOT__entry[6U] 
                                                        >> 0x00000015U)))
                                                    ? (IData)(vlSelfRef.tb_cmo_retirement__DOT__no_store)
                                                    : 
                                                   ((6U 
                                                     == 
                                                     (0x0000000fU 
                                                      & ((vlSelfRef.tb_cmo_retirement__DOT__entry[7U] 
                                                          << 3U) 
                                                         | (vlSelfRef.tb_cmo_retirement__DOT__entry[6U] 
                                                            >> 0x0000001dU))))
                                                     ? 
                                                    ((~ 
                                                      (vlSelfRef.tb_cmo_retirement__DOT__irq[0U] 
                                                       >> 1U)) 
                                                     & (IData)(__VdfgRegularize_h6e95ff9d_0_9))
                                                     : (IData)(__VdfgRegularize_h6e95ff9d_0_9))))) 
                                          & (IData)(vlSelfRef.__VdfgRegularize_h6e95ff9d_0_12))));
    vlSelfRef.tb_cmo_retirement__DOT__ack = ((((IData)(__VdfgRegularize_h6e95ff9d_0_8) 
                                               & ((~ (IData)(vlSelfRef.tb_cmo_retirement__DOT__halt)) 
                                                  & ((IData)(vlSelfRef.__VdfgRegularize_h6e95ff9d_0_3) 
                                                     & ((~ (IData)(vlSelfRef.tb_cmo_retirement__DOT__dut__DOT__cmo_head)) 
                                                        & ((vlSelfRef.tb_cmo_retirement__DOT__entry[17U] 
                                                            >> 0x00000013U) 
                                                           & ((6U 
                                                               != 
                                                               (0x0000000fU 
                                                                & ((vlSelfRef.tb_cmo_retirement__DOT__entry[7U] 
                                                                    << 3U) 
                                                                   | (vlSelfRef.tb_cmo_retirement__DOT__entry[6U] 
                                                                      >> 0x0000001dU)))) 
                                                              & ((~ 
                                                                  (vlSelfRef.tb_cmo_retirement__DOT__entry[11U] 
                                                                   >> 5U)) 
                                                                 & ((3U 
                                                                     == 
                                                                     (0x0000000fU 
                                                                      & (vlSelfRef.tb_cmo_retirement__DOT__entry[18U] 
                                                                         >> 1U))) 
                                                                    | ((1U 
                                                                        == 
                                                                        (0x0000000fU 
                                                                         & (vlSelfRef.tb_cmo_retirement__DOT__entry[18U] 
                                                                            >> 1U))) 
                                                                       | ((4U 
                                                                           == 
                                                                           (0x0000000fU 
                                                                            & (vlSelfRef.tb_cmo_retirement__DOT__entry[18U] 
                                                                               >> 1U))) 
                                                                          | ((5U 
                                                                              == 
                                                                              (0x0000000fU 
                                                                               & (vlSelfRef.tb_cmo_retirement__DOT__entry[18U] 
                                                                                >> 1U))) 
                                                                             | ((7U 
                                                                                == 
                                                                                (0x0000000fU 
                                                                                & (vlSelfRef.tb_cmo_retirement__DOT__entry[18U] 
                                                                                >> 1U))) 
                                                                                | (8U 
                                                                                == 
                                                                                (0x0000000fU 
                                                                                & (vlSelfRef.tb_cmo_retirement__DOT__entry[18U] 
                                                                                >> 1U))))))))))))))) 
                                              << 1U) 
                                             | (IData)(__VdfgRegularize_h6e95ff9d_0_8));
}

void Vtb_cmo_retirement___024root___nba_comb__TOP__0(Vtb_cmo_retirement___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_cmo_retirement___024root___nba_comb__TOP__0\n"); );
    Vtb_cmo_retirement__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    VlWide<7>/*223:0*/ __Vtemp_2;
    // Body
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_12 = (1U 
                                                 & ((~ (IData)(vlSelfRef.tb_cmo_retirement__DOT__halt)) 
                                                    & (vlSelfRef.tb_cmo_retirement__DOT__entry[6U] 
                                                       >> 0x0000000fU)));
    if ((0x00008000U & vlSelfRef.tb_cmo_retirement__DOT__entry[6U])) {
        if ((2U & vlSelfRef.tb_cmo_retirement__DOT__entry[0U])) {
            __Vtemp_2[0U] = vlSelfRef.tb_cmo_retirement__DOT__entry[0U];
            __Vtemp_2[1U] = vlSelfRef.tb_cmo_retirement__DOT__entry[1U];
            __Vtemp_2[2U] = vlSelfRef.tb_cmo_retirement__DOT__entry[2U];
            __Vtemp_2[3U] = vlSelfRef.tb_cmo_retirement__DOT__entry[3U];
            __Vtemp_2[4U] = vlSelfRef.tb_cmo_retirement__DOT__entry[4U];
            __Vtemp_2[5U] = vlSelfRef.tb_cmo_retirement__DOT__entry[5U];
            __Vtemp_2[6U] = vlSelfRef.tb_cmo_retirement__DOT__entry[6U];
        } else if ((2U & vlSelfRef.tb_cmo_retirement__DOT__irq[0U])) {
            __Vtemp_2[0U] = vlSelfRef.tb_cmo_retirement__DOT__irq[0U];
            __Vtemp_2[1U] = vlSelfRef.tb_cmo_retirement__DOT__irq[1U];
            __Vtemp_2[2U] = (((IData)((((QData)((IData)(vlSelfRef.tb_cmo_retirement__DOT__entry[4U])) 
                                        << 0x00000034U) 
                                       | (((QData)((IData)(vlSelfRef.tb_cmo_retirement__DOT__entry[3U])) 
                                           << 0x00000014U) 
                                          | ((QData)((IData)(vlSelfRef.tb_cmo_retirement__DOT__entry[2U])) 
                                             >> 0x0000000cU)))) 
                              << 0x0000000cU) | (0x00000fffU 
                                                 & vlSelfRef.tb_cmo_retirement__DOT__irq[2U]));
            __Vtemp_2[3U] = (((IData)((((QData)((IData)(vlSelfRef.tb_cmo_retirement__DOT__entry[4U])) 
                                        << 0x00000034U) 
                                       | (((QData)((IData)(vlSelfRef.tb_cmo_retirement__DOT__entry[3U])) 
                                           << 0x00000014U) 
                                          | ((QData)((IData)(vlSelfRef.tb_cmo_retirement__DOT__entry[2U])) 
                                             >> 0x0000000cU)))) 
                              >> 0x00000014U) | ((IData)(
                                                         ((((QData)((IData)(vlSelfRef.tb_cmo_retirement__DOT__entry[4U])) 
                                                            << 0x00000034U) 
                                                           | (((QData)((IData)(vlSelfRef.tb_cmo_retirement__DOT__entry[3U])) 
                                                               << 0x00000014U) 
                                                              | ((QData)((IData)(vlSelfRef.tb_cmo_retirement__DOT__entry[2U])) 
                                                                 >> 0x0000000cU))) 
                                                          >> 0x00000020U)) 
                                                 << 0x0000000cU));
            __Vtemp_2[4U] = (((IData)(((((QData)((IData)(vlSelfRef.tb_cmo_retirement__DOT__entry[4U])) 
                                         << 0x00000034U) 
                                        | (((QData)((IData)(vlSelfRef.tb_cmo_retirement__DOT__entry[3U])) 
                                            << 0x00000014U) 
                                           | ((QData)((IData)(vlSelfRef.tb_cmo_retirement__DOT__entry[2U])) 
                                              >> 0x0000000cU))) 
                                       >> 0x00000020U)) 
                              >> 0x00000014U) | ((IData)(
                                                         (((QData)((IData)(vlSelfRef.tb_cmo_retirement__DOT__irq[6U])) 
                                                           << 0x00000034U) 
                                                          | (((QData)((IData)(vlSelfRef.tb_cmo_retirement__DOT__irq[5U])) 
                                                              << 0x00000014U) 
                                                             | ((QData)((IData)(vlSelfRef.tb_cmo_retirement__DOT__irq[4U])) 
                                                                >> 0x0000000cU)))) 
                                                 << 0x0000000cU));
            __Vtemp_2[5U] = (((IData)((((QData)((IData)(vlSelfRef.tb_cmo_retirement__DOT__irq[6U])) 
                                        << 0x00000034U) 
                                       | (((QData)((IData)(vlSelfRef.tb_cmo_retirement__DOT__irq[5U])) 
                                           << 0x00000014U) 
                                          | ((QData)((IData)(vlSelfRef.tb_cmo_retirement__DOT__irq[4U])) 
                                             >> 0x0000000cU)))) 
                              >> 0x00000014U) | ((IData)(
                                                         ((((QData)((IData)(vlSelfRef.tb_cmo_retirement__DOT__irq[6U])) 
                                                            << 0x00000034U) 
                                                           | (((QData)((IData)(vlSelfRef.tb_cmo_retirement__DOT__irq[5U])) 
                                                               << 0x00000014U) 
                                                              | ((QData)((IData)(vlSelfRef.tb_cmo_retirement__DOT__irq[4U])) 
                                                                 >> 0x0000000cU))) 
                                                          >> 0x00000020U)) 
                                                 << 0x0000000cU));
            __Vtemp_2[6U] = ((IData)(((((QData)((IData)(vlSelfRef.tb_cmo_retirement__DOT__irq[6U])) 
                                        << 0x00000034U) 
                                       | (((QData)((IData)(vlSelfRef.tb_cmo_retirement__DOT__irq[5U])) 
                                           << 0x00000014U) 
                                          | ((QData)((IData)(vlSelfRef.tb_cmo_retirement__DOT__irq[4U])) 
                                             >> 0x0000000cU))) 
                                      >> 0x00000020U)) 
                             >> 0x00000014U);
        } else {
            __Vtemp_2[0U] = 0U;
            __Vtemp_2[1U] = 0U;
            __Vtemp_2[2U] = 0U;
            __Vtemp_2[3U] = 0U;
            __Vtemp_2[4U] = 0U;
            __Vtemp_2[5U] = 0U;
            __Vtemp_2[6U] = 0U;
        }
    } else {
        __Vtemp_2[0U] = 0U;
        __Vtemp_2[1U] = 0U;
        __Vtemp_2[2U] = 0U;
        __Vtemp_2[3U] = 0U;
        __Vtemp_2[4U] = 0U;
        __Vtemp_2[5U] = 0U;
        __Vtemp_2[6U] = 0U;
    }
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_4[0U] = __Vtemp_2[0U];
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_4[1U] = __Vtemp_2[1U];
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_4[2U] = __Vtemp_2[2U];
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_4[3U] = __Vtemp_2[3U];
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_4[4U] = __Vtemp_2[4U];
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_4[5U] = __Vtemp_2[5U];
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_4[6U] = 
        (0x00000fffU & __Vtemp_2[6U]);
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_3 = (1U 
                                                & (~ 
                                                   ((0x3dU 
                                                     <= 
                                                     (0x000000ffU 
                                                      & (vlSelfRef.tb_cmo_retirement__DOT__entry[6U] 
                                                         >> 0x00000015U))) 
                                                    & (0x52U 
                                                       >= 
                                                       (0x000000ffU 
                                                        & (vlSelfRef.tb_cmo_retirement__DOT__entry[6U] 
                                                           >> 0x00000015U))))));
    vlSelfRef.tb_cmo_retirement__DOT__dut__DOT__cmo_head 
        = ((vlSelfRef.tb_cmo_retirement__DOT__entry[6U] 
            >> 0x0000000fU) & ((0x53U == (0x000000ffU 
                                          & (vlSelfRef.tb_cmo_retirement__DOT__entry[6U] 
                                             >> 0x00000015U))) 
                               | ((0x54U == (0x000000ffU 
                                             & (vlSelfRef.tb_cmo_retirement__DOT__entry[6U] 
                                                >> 0x00000015U))) 
                                  | (0x55U == (0x000000ffU 
                                               & (vlSelfRef.tb_cmo_retirement__DOT__entry[6U] 
                                                  >> 0x00000015U))))));
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_7[0U] = 
        ((vlSelfRef.__VdfgRegularize_h6e95ff9d_0_4[1U] 
          << 0x0000001eU) | (vlSelfRef.__VdfgRegularize_h6e95ff9d_0_4[0U] 
                             >> 2U));
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_7[1U] = 
        ((vlSelfRef.__VdfgRegularize_h6e95ff9d_0_4[2U] 
          << 0x0000001eU) | (vlSelfRef.__VdfgRegularize_h6e95ff9d_0_4[1U] 
                             >> 2U));
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_7[2U] = 
        ((vlSelfRef.__VdfgRegularize_h6e95ff9d_0_4[3U] 
          << 0x0000001eU) | (vlSelfRef.__VdfgRegularize_h6e95ff9d_0_4[2U] 
                             >> 2U));
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_7[3U] = 
        ((vlSelfRef.__VdfgRegularize_h6e95ff9d_0_4[4U] 
          << 0x0000001eU) | (vlSelfRef.__VdfgRegularize_h6e95ff9d_0_4[3U] 
                             >> 2U));
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_7[4U] = 
        ((vlSelfRef.__VdfgRegularize_h6e95ff9d_0_4[5U] 
          << 0x0000001eU) | (vlSelfRef.__VdfgRegularize_h6e95ff9d_0_4[4U] 
                             >> 2U));
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_7[5U] = 
        ((vlSelfRef.__VdfgRegularize_h6e95ff9d_0_4[6U] 
          << 0x0000001eU) | (vlSelfRef.__VdfgRegularize_h6e95ff9d_0_4[5U] 
                             >> 2U));
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_7[6U] = 
        (0x000003ffU & (vlSelfRef.__VdfgRegularize_h6e95ff9d_0_4[6U] 
                        >> 2U));
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_11 = ((IData)(vlSelfRef.__VdfgRegularize_h6e95ff9d_0_3) 
                                                 & (2U 
                                                    == 
                                                    (0x0000000fU 
                                                     & ((vlSelfRef.tb_cmo_retirement__DOT__entry[7U] 
                                                         << 3U) 
                                                        | (vlSelfRef.tb_cmo_retirement__DOT__entry[6U] 
                                                           >> 0x0000001dU)))));
}

void Vtb_cmo_retirement___024root___nba_comb__TOP__1(Vtb_cmo_retirement___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_cmo_retirement___024root___nba_comb__TOP__1\n"); );
    Vtb_cmo_retirement__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    CData/*0:0*/ __VdfgRegularize_h6e95ff9d_0_8;
    __VdfgRegularize_h6e95ff9d_0_8 = 0;
    CData/*0:0*/ __VdfgRegularize_h6e95ff9d_0_9;
    __VdfgRegularize_h6e95ff9d_0_9 = 0;
    CData/*0:0*/ __VdfgRegularize_h6e95ff9d_0_10;
    __VdfgRegularize_h6e95ff9d_0_10 = 0;
    // Body
    vlSelfRef.tb_cmo_retirement__DOT__dut__DOT__cmo_take 
        = ((IData)(vlSelfRef.tb_cmo_retirement__DOT__ready) 
           & (IData)(vlSelfRef.tb_cmo_retirement__DOT__dut__DOT__cmo_offer_q));
    __VdfgRegularize_h6e95ff9d_0_10 = (1U & ((~ (IData)(vlSelfRef.tb_cmo_retirement__DOT__dut__DOT__cmo_head)) 
                                             | ((~ (IData)(vlSelfRef.tb_cmo_retirement__DOT__dut__DOT__cmo_error_q)) 
                                                & (IData)(vlSelfRef.tb_cmo_retirement__DOT__dut__DOT__cmo_complete_q))));
    vlSelfRef.tb_cmo_retirement__DOT__dut__DOT__cmo_eligible 
        = (((((((IData)(vlSelfRef.tb_cmo_retirement__DOT__dut__DOT__cmo_head) 
                & (~ (IData)(vlSelfRef.tb_cmo_retirement__DOT__halt))) 
               & (~ (vlSelfRef.tb_cmo_retirement__DOT__entry[0U] 
                     >> 1U))) & (0x0a600000U == (0x1fe00000U 
                                                 & vlSelfRef.tb_cmo_retirement__DOT__entry[6U]))) 
             & (~ (vlSelfRef.tb_cmo_retirement__DOT__irq[0U] 
                   >> 1U))) & (IData)(vlSelfRef.tb_cmo_retirement__DOT__no_store)) 
           & (~ (IData)(vlSelfRef.tb_cmo_retirement__DOT__active)));
    if (vlSelfRef.tb_cmo_retirement__DOT__active) {
        if (((IData)(vlSelfRef.tb_cmo_retirement__DOT__dut__DOT__cmo_complete_q) 
             & ((IData)(vlSelfRef.tb_cmo_retirement__DOT__dut__DOT__cmo_error_q) 
                & ((~ (IData)(vlSelfRef.tb_cmo_retirement__DOT__halt)) 
                   & (IData)(vlSelfRef.tb_cmo_retirement__DOT__dut__DOT__cmo_head))))) {
            vlSelfRef.tb_cmo_retirement__DOT__fault[0U] = 2U;
            vlSelfRef.tb_cmo_retirement__DOT__fault[1U] = 0U;
            vlSelfRef.tb_cmo_retirement__DOT__fault[2U] 
                = ((IData)(vlSelfRef.tb_cmo_retirement__DOT__dut__DOT__cmo_fault_vaddr_q) 
                   << 0x0000000cU);
            vlSelfRef.tb_cmo_retirement__DOT__fault[3U] 
                = (((IData)(vlSelfRef.tb_cmo_retirement__DOT__dut__DOT__cmo_fault_vaddr_q) 
                    >> 0x00000014U) | ((IData)((vlSelfRef.tb_cmo_retirement__DOT__dut__DOT__cmo_fault_vaddr_q 
                                                >> 0x00000020U)) 
                                       << 0x0000000cU));
            vlSelfRef.tb_cmo_retirement__DOT__fault[4U] 
                = (0x00007000U | ((IData)((vlSelfRef.tb_cmo_retirement__DOT__dut__DOT__cmo_fault_vaddr_q 
                                           >> 0x00000020U)) 
                                  >> 0x00000014U));
            vlSelfRef.tb_cmo_retirement__DOT__fault[5U] = 0U;
            vlSelfRef.tb_cmo_retirement__DOT__fault[6U] = 0U;
        } else {
            vlSelfRef.tb_cmo_retirement__DOT__fault[0U] 
                = ((vlSelfRef.__VdfgRegularize_h6e95ff9d_0_7[0U] 
                    << 2U) | (1U & vlSelfRef.__VdfgRegularize_h6e95ff9d_0_4[0U]));
            vlSelfRef.tb_cmo_retirement__DOT__fault[1U] 
                = ((vlSelfRef.__VdfgRegularize_h6e95ff9d_0_7[0U] 
                    >> 0x0000001eU) | (vlSelfRef.__VdfgRegularize_h6e95ff9d_0_7[1U] 
                                       << 2U));
            vlSelfRef.tb_cmo_retirement__DOT__fault[2U] 
                = ((vlSelfRef.__VdfgRegularize_h6e95ff9d_0_7[1U] 
                    >> 0x0000001eU) | (vlSelfRef.__VdfgRegularize_h6e95ff9d_0_7[2U] 
                                       << 2U));
            vlSelfRef.tb_cmo_retirement__DOT__fault[3U] 
                = ((vlSelfRef.__VdfgRegularize_h6e95ff9d_0_7[2U] 
                    >> 0x0000001eU) | (vlSelfRef.__VdfgRegularize_h6e95ff9d_0_7[3U] 
                                       << 2U));
            vlSelfRef.tb_cmo_retirement__DOT__fault[4U] 
                = ((vlSelfRef.__VdfgRegularize_h6e95ff9d_0_7[3U] 
                    >> 0x0000001eU) | (vlSelfRef.__VdfgRegularize_h6e95ff9d_0_7[4U] 
                                       << 2U));
            vlSelfRef.tb_cmo_retirement__DOT__fault[5U] 
                = ((vlSelfRef.__VdfgRegularize_h6e95ff9d_0_7[4U] 
                    >> 0x0000001eU) | (vlSelfRef.__VdfgRegularize_h6e95ff9d_0_7[5U] 
                                       << 2U));
            vlSelfRef.tb_cmo_retirement__DOT__fault[6U] 
                = ((vlSelfRef.__VdfgRegularize_h6e95ff9d_0_7[5U] 
                    >> 0x0000001eU) | (vlSelfRef.__VdfgRegularize_h6e95ff9d_0_7[6U] 
                                       << 2U));
        }
    } else {
        vlSelfRef.tb_cmo_retirement__DOT__fault[0U] 
            = ((vlSelfRef.__VdfgRegularize_h6e95ff9d_0_7[0U] 
                << 2U) | ((2U & (((~ (IData)(vlSelfRef.tb_cmo_retirement__DOT__halt)) 
                                  << 1U) & vlSelfRef.__VdfgRegularize_h6e95ff9d_0_4[0U])) 
                          | (1U & vlSelfRef.__VdfgRegularize_h6e95ff9d_0_4[0U])));
        vlSelfRef.tb_cmo_retirement__DOT__fault[1U] 
            = ((vlSelfRef.__VdfgRegularize_h6e95ff9d_0_7[0U] 
                >> 0x0000001eU) | (vlSelfRef.__VdfgRegularize_h6e95ff9d_0_7[1U] 
                                   << 2U));
        vlSelfRef.tb_cmo_retirement__DOT__fault[2U] 
            = ((vlSelfRef.__VdfgRegularize_h6e95ff9d_0_7[1U] 
                >> 0x0000001eU) | (vlSelfRef.__VdfgRegularize_h6e95ff9d_0_7[2U] 
                                   << 2U));
        vlSelfRef.tb_cmo_retirement__DOT__fault[3U] 
            = ((vlSelfRef.__VdfgRegularize_h6e95ff9d_0_7[2U] 
                >> 0x0000001eU) | (vlSelfRef.__VdfgRegularize_h6e95ff9d_0_7[3U] 
                                   << 2U));
        vlSelfRef.tb_cmo_retirement__DOT__fault[4U] 
            = ((vlSelfRef.__VdfgRegularize_h6e95ff9d_0_7[3U] 
                >> 0x0000001eU) | (vlSelfRef.__VdfgRegularize_h6e95ff9d_0_7[4U] 
                                   << 2U));
        vlSelfRef.tb_cmo_retirement__DOT__fault[5U] 
            = ((vlSelfRef.__VdfgRegularize_h6e95ff9d_0_7[4U] 
                >> 0x0000001eU) | (vlSelfRef.__VdfgRegularize_h6e95ff9d_0_7[5U] 
                                   << 2U));
        vlSelfRef.tb_cmo_retirement__DOT__fault[6U] 
            = ((vlSelfRef.__VdfgRegularize_h6e95ff9d_0_7[5U] 
                >> 0x0000001eU) | (vlSelfRef.__VdfgRegularize_h6e95ff9d_0_7[6U] 
                                   << 2U));
    }
    vlSelfRef.tb_cmo_retirement__DOT__pop = ((~ (vlSelfRef.tb_cmo_retirement__DOT__entry[0U] 
                                                 >> 1U)) 
                                             & ((IData)(vlSelfRef.__VdfgRegularize_h6e95ff9d_0_11) 
                                                & ((IData)(__VdfgRegularize_h6e95ff9d_0_10) 
                                                   & (IData)(vlSelfRef.__VdfgRegularize_h6e95ff9d_0_12))));
    __VdfgRegularize_h6e95ff9d_0_9 = (1U & ((~ (IData)(vlSelfRef.__VdfgRegularize_h6e95ff9d_0_11)) 
                                            | (IData)(__VdfgRegularize_h6e95ff9d_0_10)));
    __VdfgRegularize_h6e95ff9d_0_8 = ((~ (vlSelfRef.tb_cmo_retirement__DOT__entry[0U] 
                                          >> 1U)) & 
                                      ((IData)(vlSelfRef.__VdfgRegularize_h6e95ff9d_0_3) 
                                       & (((0x1cU == 
                                            (0x000000ffU 
                                             & (vlSelfRef.tb_cmo_retirement__DOT__entry[6U] 
                                                >> 0x00000015U)))
                                            ? (IData)(vlSelfRef.tb_cmo_retirement__DOT__no_store)
                                            : ((0x1dU 
                                                == 
                                                (0x000000ffU 
                                                 & (vlSelfRef.tb_cmo_retirement__DOT__entry[6U] 
                                                    >> 0x00000015U)))
                                                ? (IData)(vlSelfRef.tb_cmo_retirement__DOT__no_store)
                                                : (
                                                   (0x1eU 
                                                    == 
                                                    (0x000000ffU 
                                                     & (vlSelfRef.tb_cmo_retirement__DOT__entry[6U] 
                                                        >> 0x00000015U)))
                                                    ? (IData)(vlSelfRef.tb_cmo_retirement__DOT__no_store)
                                                    : 
                                                   ((6U 
                                                     == 
                                                     (0x0000000fU 
                                                      & ((vlSelfRef.tb_cmo_retirement__DOT__entry[7U] 
                                                          << 3U) 
                                                         | (vlSelfRef.tb_cmo_retirement__DOT__entry[6U] 
                                                            >> 0x0000001dU))))
                                                     ? 
                                                    ((~ 
                                                      (vlSelfRef.tb_cmo_retirement__DOT__irq[0U] 
                                                       >> 1U)) 
                                                     & (IData)(__VdfgRegularize_h6e95ff9d_0_9))
                                                     : (IData)(__VdfgRegularize_h6e95ff9d_0_9))))) 
                                          & (IData)(vlSelfRef.__VdfgRegularize_h6e95ff9d_0_12))));
    vlSelfRef.tb_cmo_retirement__DOT__ack = ((((IData)(__VdfgRegularize_h6e95ff9d_0_8) 
                                               & ((~ (IData)(vlSelfRef.tb_cmo_retirement__DOT__halt)) 
                                                  & ((IData)(vlSelfRef.__VdfgRegularize_h6e95ff9d_0_3) 
                                                     & ((~ (IData)(vlSelfRef.tb_cmo_retirement__DOT__dut__DOT__cmo_head)) 
                                                        & ((vlSelfRef.tb_cmo_retirement__DOT__entry[17U] 
                                                            >> 0x00000013U) 
                                                           & ((6U 
                                                               != 
                                                               (0x0000000fU 
                                                                & ((vlSelfRef.tb_cmo_retirement__DOT__entry[7U] 
                                                                    << 3U) 
                                                                   | (vlSelfRef.tb_cmo_retirement__DOT__entry[6U] 
                                                                      >> 0x0000001dU)))) 
                                                              & ((~ 
                                                                  (vlSelfRef.tb_cmo_retirement__DOT__entry[11U] 
                                                                   >> 5U)) 
                                                                 & ((3U 
                                                                     == 
                                                                     (0x0000000fU 
                                                                      & (vlSelfRef.tb_cmo_retirement__DOT__entry[18U] 
                                                                         >> 1U))) 
                                                                    | ((1U 
                                                                        == 
                                                                        (0x0000000fU 
                                                                         & (vlSelfRef.tb_cmo_retirement__DOT__entry[18U] 
                                                                            >> 1U))) 
                                                                       | ((4U 
                                                                           == 
                                                                           (0x0000000fU 
                                                                            & (vlSelfRef.tb_cmo_retirement__DOT__entry[18U] 
                                                                               >> 1U))) 
                                                                          | ((5U 
                                                                              == 
                                                                              (0x0000000fU 
                                                                               & (vlSelfRef.tb_cmo_retirement__DOT__entry[18U] 
                                                                                >> 1U))) 
                                                                             | ((7U 
                                                                                == 
                                                                                (0x0000000fU 
                                                                                & (vlSelfRef.tb_cmo_retirement__DOT__entry[18U] 
                                                                                >> 1U))) 
                                                                                | (8U 
                                                                                == 
                                                                                (0x0000000fU 
                                                                                & (vlSelfRef.tb_cmo_retirement__DOT__entry[18U] 
                                                                                >> 1U))))))))))))))) 
                                              << 1U) 
                                             | (IData)(__VdfgRegularize_h6e95ff9d_0_8));
}

void Vtb_cmo_retirement___024root___timing_ready(Vtb_cmo_retirement___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_cmo_retirement___024root___timing_ready\n"); );
    Vtb_cmo_retirement__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if ((4ULL & vlSelfRef.__VactTriggered[0U])) {
        vlSelfRef.__VtrigSched_hd76ea377__0.ready("@(negedge tb_cmo_retirement.clk)");
    }
    if ((1ULL & vlSelfRef.__VactTriggered[0U])) {
        vlSelfRef.__VtrigSched_hd76ea2b8__0.ready("@(posedge tb_cmo_retirement.clk)");
    }
    if ((0x0000000000000010ULL & vlSelfRef.__VactTriggered[0U])) {
        vlSelfRef.__VtrigSched_h03c8db67__0.ready("@( tb_cmo_retirement.dut.cmo_offer_q)");
    }
}

void Vtb_cmo_retirement___024root___timing_resume(Vtb_cmo_retirement___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_cmo_retirement___024root___timing_resume\n"); );
    Vtb_cmo_retirement__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    vlSelfRef.__VtrigSched_hd76ea377__0.moveToResumeQueue(
                                                          "@(negedge tb_cmo_retirement.clk)");
    vlSelfRef.__VtrigSched_hd76ea2b8__0.moveToResumeQueue(
                                                          "@(posedge tb_cmo_retirement.clk)");
    vlSelfRef.__VtrigSched_h03c8db67__0.moveToResumeQueue(
                                                          "@( tb_cmo_retirement.dut.cmo_offer_q)");
    vlSelfRef.__VtrigSched_hd76ea377__0.resume("@(negedge tb_cmo_retirement.clk)");
    vlSelfRef.__VtrigSched_hd76ea2b8__0.resume("@(posedge tb_cmo_retirement.clk)");
    vlSelfRef.__VtrigSched_h03c8db67__0.resume("@( tb_cmo_retirement.dut.cmo_offer_q)");
    if ((8ULL & vlSelfRef.__VactTriggered[0U])) {
        vlSelfRef.__VdlySched.resume();
    }
}

void Vtb_cmo_retirement___024root___trigger_orInto__act_vec_vec(VlUnpacked<QData/*63:0*/, 1> &out, const VlUnpacked<QData/*63:0*/, 1> &in) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_cmo_retirement___024root___trigger_orInto__act_vec_vec\n"); );
    // Locals
    IData/*31:0*/ n;
    // Body
    n = 0U;
    do {
        out[n] = (out[n] | in[n]);
        n = ((IData)(1U) + n);
    } while ((0U >= n));
}

void Vtb_cmo_retirement___024root___trigger_clear__act(VlUnpacked<QData/*63:0*/, 1> &out) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_cmo_retirement___024root___trigger_clear__act\n"); );
    // Locals
    IData/*31:0*/ n;
    // Body
    n = 0U;
    do {
        out[n] = 0ULL;
        n = ((IData)(1U) + n);
    } while ((1U > n));
}

void Vtb_cmo_retirement___024root____VbeforeTrig_hd76ea377__0(Vtb_cmo_retirement___024root* vlSelf, const char* __VeventDescription) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_cmo_retirement___024root____VbeforeTrig_hd76ea377__0\n"); );
    Vtb_cmo_retirement__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    VlUnpacked<QData/*63:0*/, 1> __VTmp;
    // Body
    __VTmp[0U] = (QData)((IData)(((((~ (IData)(vlSelfRef.tb_cmo_retirement__DOT__clk)) 
                                    & (IData)(vlSelfRef.__Vtrigprevexpr___TOP__tb_cmo_retirement__DOT__clk__0)) 
                                   << 2U) | ((IData)(vlSelfRef.tb_cmo_retirement__DOT__clk) 
                                             & (~ (IData)(vlSelfRef.__Vtrigprevexpr___TOP__tb_cmo_retirement__DOT__clk__0))))));
    vlSelfRef.__Vtrigprevexpr___TOP__tb_cmo_retirement__DOT__clk__0 
        = vlSelfRef.tb_cmo_retirement__DOT__clk;
    if ((1ULL & __VTmp[0U])) {
        vlSelfRef.__VtrigSched_hd76ea2b8__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hd76ea2b8__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hd76ea2b8__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hd76ea2b8__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hd76ea2b8__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hd76ea2b8__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hd76ea2b8__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hd76ea2b8__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hd76ea2b8__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hd76ea2b8__0.ready(__VeventDescription);
    }
    if ((4ULL & __VTmp[0U])) {
        vlSelfRef.__VtrigSched_hd76ea377__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hd76ea377__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hd76ea377__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hd76ea377__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hd76ea377__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hd76ea377__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hd76ea377__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hd76ea377__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hd76ea377__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hd76ea377__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hd76ea377__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hd76ea377__0.ready(__VeventDescription);
    }
    vlSelfRef.__VactTriggeredAcc[0U] = (vlSelfRef.__VactTriggeredAcc[0U] 
                                        | __VTmp[0U]);
}

void Vtb_cmo_retirement___024root____VbeforeTrig_hd76ea2b8__0(Vtb_cmo_retirement___024root* vlSelf, const char* __VeventDescription) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_cmo_retirement___024root____VbeforeTrig_hd76ea2b8__0\n"); );
    Vtb_cmo_retirement__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    VlUnpacked<QData/*63:0*/, 1> __VTmp;
    // Body
    __VTmp[0U] = (QData)((IData)(((((~ (IData)(vlSelfRef.tb_cmo_retirement__DOT__clk)) 
                                    & (IData)(vlSelfRef.__Vtrigprevexpr___TOP__tb_cmo_retirement__DOT__clk__0)) 
                                   << 2U) | ((IData)(vlSelfRef.tb_cmo_retirement__DOT__clk) 
                                             & (~ (IData)(vlSelfRef.__Vtrigprevexpr___TOP__tb_cmo_retirement__DOT__clk__0))))));
    vlSelfRef.__Vtrigprevexpr___TOP__tb_cmo_retirement__DOT__clk__0 
        = vlSelfRef.tb_cmo_retirement__DOT__clk;
    if ((1ULL & __VTmp[0U])) {
        vlSelfRef.__VtrigSched_hd76ea2b8__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hd76ea2b8__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hd76ea2b8__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hd76ea2b8__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hd76ea2b8__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hd76ea2b8__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hd76ea2b8__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hd76ea2b8__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hd76ea2b8__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hd76ea2b8__0.ready(__VeventDescription);
    }
    if ((4ULL & __VTmp[0U])) {
        vlSelfRef.__VtrigSched_hd76ea377__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hd76ea377__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hd76ea377__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hd76ea377__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hd76ea377__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hd76ea377__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hd76ea377__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hd76ea377__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hd76ea377__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hd76ea377__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hd76ea377__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_hd76ea377__0.ready(__VeventDescription);
    }
    vlSelfRef.__VactTriggeredAcc[0U] = (vlSelfRef.__VactTriggeredAcc[0U] 
                                        | __VTmp[0U]);
}

void Vtb_cmo_retirement___024root____VbeforeTrig_h03c8db67__0(Vtb_cmo_retirement___024root* vlSelf, const char* __VeventDescription) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_cmo_retirement___024root____VbeforeTrig_h03c8db67__0\n"); );
    Vtb_cmo_retirement__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    VlUnpacked<QData/*63:0*/, 1> __VTmp;
    // Body
    __VTmp[0U] = (QData)((IData)((((IData)(vlSelfRef.tb_cmo_retirement__DOT__dut__DOT__cmo_offer_q) 
                                   != (IData)(vlSelfRef.__Vtrigprevexpr___TOP__tb_cmo_retirement__DOT__dut__DOT__cmo_offer_q__0)) 
                                  << 4U)));
    vlSelfRef.__Vtrigprevexpr___TOP__tb_cmo_retirement__DOT__dut__DOT__cmo_offer_q__0 
        = vlSelfRef.tb_cmo_retirement__DOT__dut__DOT__cmo_offer_q;
    if ((0x0000000000000010ULL & __VTmp[0U])) {
        vlSelfRef.__VtrigSched_h03c8db67__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h03c8db67__0.ready(__VeventDescription);
    }
    vlSelfRef.__VactTriggeredAcc[0U] = (vlSelfRef.__VactTriggeredAcc[0U] 
                                        | __VTmp[0U]);
}

#ifdef VL_DEBUG
void Vtb_cmo_retirement___024root___eval_debug_assertions(Vtb_cmo_retirement___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_cmo_retirement___024root___eval_debug_assertions\n"); );
    Vtb_cmo_retirement__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
}
#endif  // VL_DEBUG
