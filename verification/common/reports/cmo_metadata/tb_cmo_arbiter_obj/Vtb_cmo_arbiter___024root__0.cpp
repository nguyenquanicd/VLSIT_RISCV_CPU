// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vtb_cmo_arbiter.h for the primary calling header

#include "Vtb_cmo_arbiter__pch.h"

VlCoroutine Vtb_cmo_arbiter___024root___eval_initial__TOP__Vtiming__0(Vtb_cmo_arbiter___024root* vlSelf);
VlCoroutine Vtb_cmo_arbiter___024root___eval_initial__TOP__Vtiming__1(Vtb_cmo_arbiter___024root* vlSelf);

void Vtb_cmo_arbiter___024root___eval_initial(Vtb_cmo_arbiter___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_cmo_arbiter___024root___eval_initial\n"); );
    Vtb_cmo_arbiter__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    Vtb_cmo_arbiter___024root___eval_initial__TOP__Vtiming__0(vlSelf);
    Vtb_cmo_arbiter___024root___eval_initial__TOP__Vtiming__1(vlSelf);
}

void Vtb_cmo_arbiter___024root___eval_sample(Vtb_cmo_arbiter___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_cmo_arbiter___024root___eval_sample\n"); );
    Vtb_cmo_arbiter__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
}

#ifdef VL_DEBUG
VL_ATTR_COLD void Vtb_cmo_arbiter___024root___dump_triggers__ico(const VlUnpacked<QData/*63:0*/, 1> &triggers, const std::string &tag);
#endif  // VL_DEBUG

bool Vtb_cmo_arbiter___024root___eval_ico(Vtb_cmo_arbiter___024root* vlSelf, CData/*0:0*/ firstIteration) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_cmo_arbiter___024root___eval_ico\n"); );
    Vtb_cmo_arbiter__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    vlSelfRef.__VicoTriggered[0U] = ((0xfffffffffffffffeULL 
                                      & vlSelfRef.__VicoTriggered[0U]) 
                                     | (IData)((IData)(firstIteration)));
#ifdef VL_DEBUG
    if (VL_UNLIKELY(vlSymsp->_vm_contextp__->debug())) {
        Vtb_cmo_arbiter___024root___dump_triggers__ico(vlSelfRef.__VicoTriggered, "ico"s);
    }
#endif
    return (0U);
}

void Vtb_cmo_arbiter___024root___timing_ready(Vtb_cmo_arbiter___024root* vlSelf);
void Vtb_cmo_arbiter___024root___trigger_orInto__act_vec_vec(VlUnpacked<QData/*63:0*/, 1> &out, const VlUnpacked<QData/*63:0*/, 1> &in);
#ifdef VL_DEBUG
VL_ATTR_COLD void Vtb_cmo_arbiter___024root___dump_triggers__act(const VlUnpacked<QData/*63:0*/, 1> &triggers, const std::string &tag);
#endif  // VL_DEBUG
bool Vtb_cmo_arbiter___024root___trigger_anySet__act(const VlUnpacked<QData/*63:0*/, 1> &in);
void Vtb_cmo_arbiter___024root___timing_resume(Vtb_cmo_arbiter___024root* vlSelf);
void Vtb_cmo_arbiter___024root___act_comb__TOP__0(Vtb_cmo_arbiter___024root* vlSelf);

bool Vtb_cmo_arbiter___024root___eval_act(Vtb_cmo_arbiter___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_cmo_arbiter___024root___eval_act\n"); );
    Vtb_cmo_arbiter__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    CData/*0:0*/ __VactExecute;
    // Body
    {
        // Inlined CFunc: _eval_triggers_vec__act
        vlSelfRef.__VactTriggered[0U] = (QData)((IData)(
                                                        (((vlSelfRef.__VdlySched.awaitingCurrentTime() 
                                                           << 3U) 
                                                          | (((~ (IData)(vlSelfRef.tb_cmo_arbiter__DOT__clk)) 
                                                              & (IData)(vlSelfRef.__Vtrigprevexpr___TOP__tb_cmo_arbiter__DOT__clk__0)) 
                                                             << 2U)) 
                                                         | ((((~ (IData)(vlSelfRef.tb_cmo_arbiter__DOT__rst)) 
                                                              & (IData)(vlSelfRef.__Vtrigprevexpr___TOP__tb_cmo_arbiter__DOT__rst__0)) 
                                                             << 1U) 
                                                            | ((IData)(vlSelfRef.tb_cmo_arbiter__DOT__clk) 
                                                               & (~ (IData)(vlSelfRef.__Vtrigprevexpr___TOP__tb_cmo_arbiter__DOT__clk__0)))))));
        vlSelfRef.__Vtrigprevexpr___TOP__tb_cmo_arbiter__DOT__clk__0 
            = vlSelfRef.tb_cmo_arbiter__DOT__clk;
        vlSelfRef.__Vtrigprevexpr___TOP__tb_cmo_arbiter__DOT__rst__0 
            = vlSelfRef.tb_cmo_arbiter__DOT__rst;
    }
    Vtb_cmo_arbiter___024root___timing_ready(vlSelf);
    Vtb_cmo_arbiter___024root___trigger_orInto__act_vec_vec(vlSelfRef.__VactTriggered, vlSelfRef.__VactTriggeredAcc);
#ifdef VL_DEBUG
    if (VL_UNLIKELY(vlSymsp->_vm_contextp__->debug())) {
        Vtb_cmo_arbiter___024root___dump_triggers__act(vlSelfRef.__VactTriggered, "act"s);
    }
#endif
    Vtb_cmo_arbiter___024root___trigger_orInto__act_vec_vec(vlSelfRef.__VnbaTriggered, vlSelfRef.__VactTriggered);
    __VactExecute = Vtb_cmo_arbiter___024root___trigger_anySet__act(vlSelfRef.__VactTriggered);
    if (__VactExecute) {
        vlSelfRef.__VactTriggeredAcc.fill(0ULL);
        Vtb_cmo_arbiter___024root___timing_resume(vlSelf);
        {
            // Inlined CFunc: _eval_body__act
            if ((0x000000000000000dULL & vlSelfRef.__VactTriggered[0U])) {
                Vtb_cmo_arbiter___024root___act_comb__TOP__0(vlSelf);
            }
        }
    }
    return (__VactExecute);
}

bool Vtb_cmo_arbiter___024root___eval_inact(Vtb_cmo_arbiter___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_cmo_arbiter___024root___eval_inact\n"); );
    Vtb_cmo_arbiter__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    CData/*0:0*/ __VinactExecute;
    // Body
    __VinactExecute = vlSelfRef.__VdlySched.awaitingZeroDelay();
    if (__VinactExecute) {
        VL_FATAL_MT("tb_cmo_arbiter.sv", 2, "", "ZERODLY: Design Verilated with '--no-sched-zero-delay', but #0 delay executed at runtime");
    }
    return (__VinactExecute);
}

void Vtb_cmo_arbiter___024root___eval_body__nba(Vtb_cmo_arbiter___024root* vlSelf);
void Vtb_cmo_arbiter___024root___trigger_clear__act(VlUnpacked<QData/*63:0*/, 1> &out);

bool Vtb_cmo_arbiter___024root___eval_nba(Vtb_cmo_arbiter___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_cmo_arbiter___024root___eval_nba\n"); );
    Vtb_cmo_arbiter__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    CData/*0:0*/ __VnbaExecute;
    // Body
    __VnbaExecute = Vtb_cmo_arbiter___024root___trigger_anySet__act(vlSelfRef.__VnbaTriggered);
    if (__VnbaExecute) {
        Vtb_cmo_arbiter___024root___eval_body__nba(vlSelf);
        Vtb_cmo_arbiter___024root___trigger_clear__act(vlSelfRef.__VnbaTriggered);
    }
    return (__VnbaExecute);
}

bool Vtb_cmo_arbiter___024root___eval_obs(Vtb_cmo_arbiter___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_cmo_arbiter___024root___eval_obs\n"); );
    Vtb_cmo_arbiter__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    return (0U);
}

bool Vtb_cmo_arbiter___024root___eval_react(Vtb_cmo_arbiter___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_cmo_arbiter___024root___eval_react\n"); );
    Vtb_cmo_arbiter__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    return (0U);
}

void Vtb_cmo_arbiter___024root___eval_postponed(Vtb_cmo_arbiter___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_cmo_arbiter___024root___eval_postponed\n"); );
    Vtb_cmo_arbiter__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
}

void Vtb_cmo_arbiter___024root____VbeforeTrig_ha124248b__0(Vtb_cmo_arbiter___024root* vlSelf, const char* __VeventDescription);
void Vtb_cmo_arbiter___024root____VbeforeTrig_ha12423cc__0(Vtb_cmo_arbiter___024root* vlSelf, const char* __VeventDescription);

VlCoroutine Vtb_cmo_arbiter___024root___eval_initial__TOP__Vtiming__0(Vtb_cmo_arbiter___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_cmo_arbiter___024root___eval_initial__TOP__Vtiming__0\n"); );
    Vtb_cmo_arbiter__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    CData/*7:0*/ tb_cmo_arbiter__DOT__op;
    tb_cmo_arbiter__DOT__op = 0;
    IData/*31:0*/ tb_cmo_arbiter__DOT__unnamedblk1_1__DOT____Vrepeat0;
    tb_cmo_arbiter__DOT__unnamedblk1_1__DOT____Vrepeat0 = 0;
    IData/*31:0*/ tb_cmo_arbiter__DOT__unnamedblk2__DOT__h;
    tb_cmo_arbiter__DOT__unnamedblk2__DOT__h = 0;
    IData/*31:0*/ tb_cmo_arbiter__DOT__unnamedblk2__DOT__unnamedblk1_2__DOT____Vrepeat1;
    tb_cmo_arbiter__DOT__unnamedblk2__DOT__unnamedblk1_2__DOT____Vrepeat1 = 0;
    // Body
    tb_cmo_arbiter__DOT__unnamedblk1_1__DOT____Vrepeat0 = 2U;
    while (VL_LTS_III(32, 0U, tb_cmo_arbiter__DOT__unnamedblk1_1__DOT____Vrepeat0)) {
        Vtb_cmo_arbiter___024root____VbeforeTrig_ha124248b__0(vlSelf, 
                                                              "@(negedge tb_cmo_arbiter.clk)");
        co_await vlSelfRef.__VtrigSched_ha124248b__0.trigger(0U, 
                                                             nullptr, 
                                                             "@(negedge tb_cmo_arbiter.clk)", 
                                                             "tb_cmo_arbiter.sv", 
                                                             22);
        tb_cmo_arbiter__DOT__unnamedblk1_1__DOT____Vrepeat0 
            = (tb_cmo_arbiter__DOT__unnamedblk1_1__DOT____Vrepeat0 
               - (IData)(1U));
    }
    vlSelfRef.tb_cmo_arbiter__DOT__rst = 1U;
    vlSelfRef.tb_cmo_arbiter__DOT__pa[0U] = 0x00000010U;
    vlSelfRef.tb_cmo_arbiter__DOT__pa[1U] = (0xfff00000U 
                                             & vlSelfRef.tb_cmo_arbiter__DOT__pa[1U]);
    vlSelfRef.tb_cmo_arbiter__DOT__va[0U] = 0x00000100U;
    vlSelfRef.tb_cmo_arbiter__DOT__va[1U] = 0U;
    vlSelfRef.tb_cmo_arbiter__DOT__pc[0U] = 0x00000200U;
    vlSelfRef.tb_cmo_arbiter__DOT__pc[1U] = 0U;
    tb_cmo_arbiter__DOT__op = (0xfcU & (IData)(tb_cmo_arbiter__DOT__op));
    vlSelfRef.tb_cmo_arbiter__DOT__pa[1U] = (0x01100000U 
                                             | (0x000fffffU 
                                                & vlSelfRef.tb_cmo_arbiter__DOT__pa[1U]));
    vlSelfRef.tb_cmo_arbiter__DOT__pa[2U] = 0U;
    vlSelfRef.tb_cmo_arbiter__DOT__pa[3U] = (0xffffff00U 
                                             & vlSelfRef.tb_cmo_arbiter__DOT__pa[3U]);
    vlSelfRef.tb_cmo_arbiter__DOT__va[2U] = 0x00000101U;
    vlSelfRef.tb_cmo_arbiter__DOT__va[3U] = 0U;
    vlSelfRef.tb_cmo_arbiter__DOT__pc[2U] = 0x00000201U;
    vlSelfRef.tb_cmo_arbiter__DOT__pc[3U] = 0U;
    tb_cmo_arbiter__DOT__op = (4U | (0xf3U & (IData)(tb_cmo_arbiter__DOT__op)));
    vlSelfRef.tb_cmo_arbiter__DOT__pa[3U] = (0x00001200U 
                                             | (0x000000ffU 
                                                & vlSelfRef.tb_cmo_arbiter__DOT__pa[3U]));
    vlSelfRef.tb_cmo_arbiter__DOT__pa[4U] = (0xf0000000U 
                                             & vlSelfRef.tb_cmo_arbiter__DOT__pa[4U]);
    vlSelfRef.tb_cmo_arbiter__DOT__va[4U] = 0x00000102U;
    vlSelfRef.tb_cmo_arbiter__DOT__va[5U] = 0U;
    vlSelfRef.tb_cmo_arbiter__DOT__pc[4U] = 0x00000202U;
    vlSelfRef.tb_cmo_arbiter__DOT__pc[5U] = 0U;
    tb_cmo_arbiter__DOT__op = (0x00000020U | (0xcfU 
                                              & (IData)(tb_cmo_arbiter__DOT__op)));
    vlSelfRef.tb_cmo_arbiter__DOT__pa[4U] = (0x30000000U 
                                             | (0x0fffffffU 
                                                & vlSelfRef.tb_cmo_arbiter__DOT__pa[4U]));
    vlSelfRef.tb_cmo_arbiter__DOT__pa[5U] = 1U;
    vlSelfRef.tb_cmo_arbiter__DOT__pa[6U] = 0U;
    vlSelfRef.tb_cmo_arbiter__DOT__va[6U] = 0x00000103U;
    vlSelfRef.tb_cmo_arbiter__DOT__va[7U] = 0U;
    vlSelfRef.tb_cmo_arbiter__DOT__pc[6U] = 0x00000203U;
    vlSelfRef.tb_cmo_arbiter__DOT__pc[7U] = 0U;
    tb_cmo_arbiter__DOT__op = (0x3fU & (IData)(tb_cmo_arbiter__DOT__op));
    vlSelfRef.tb_cmo_arbiter__DOT__valid = 3U;
    tb_cmo_arbiter__DOT__unnamedblk2__DOT__h = 0U;
    while (VL_GTS_III(32, 2U, tb_cmo_arbiter__DOT__unnamedblk2__DOT__h)) {
        co_await vlSelfRef.__VdlySched.delay(0x00000000000003e8ULL, 
                                             nullptr, 
                                             "tb_cmo_arbiter.sv", 
                                             30);
        if (VL_UNLIKELY((((IData)(vlSelfRef.tb_cmo_arbiter__DOT__ready) 
                          != (0x0000000fU & VL_SHIFTL_III(4,4,32, (IData)(1U), tb_cmo_arbiter__DOT__unnamedblk2__DOT__h)))))) {
            VL_WRITEF_NX("[%0t] %%Fatal: tb_cmo_arbiter.sv:31: Assertion failed in %m: round-robin selection mismatch\n",3, 'M',vlSymsp->name(),"tb_cmo_arbiter.unnamedblk2", 'T',-9
                         , '#',64,VL_TIME_UNITED_Q(1000));
            VL_STOP_MT("tb_cmo_arbiter.sv", 31, "", false);
        }
        Vtb_cmo_arbiter___024root____VbeforeTrig_ha12423cc__0(vlSelf, 
                                                              "@(posedge tb_cmo_arbiter.clk)");
        co_await vlSelfRef.__VtrigSched_ha12423cc__0.trigger(0U, 
                                                             nullptr, 
                                                             "@(posedge tb_cmo_arbiter.clk)", 
                                                             "tb_cmo_arbiter.sv", 
                                                             32);
        co_await vlSelfRef.__VdlySched.delay(0x00000000000003e8ULL, 
                                             nullptr, 
                                             "tb_cmo_arbiter.sv", 
                                             32);
        vlSelfRef.tb_cmo_arbiter__DOT__valid = ((~ 
                                                 ((IData)(1U) 
                                                  << 
                                                  (3U 
                                                   & tb_cmo_arbiter__DOT__unnamedblk2__DOT__h))) 
                                                & (IData)(vlSelfRef.tb_cmo_arbiter__DOT__valid));
        if (VL_UNLIKELY(((1U & (((((~ (IData)(vlSelfRef.tb_cmo_arbiter__DOT__cv)) 
                                   | ((IData)(vlSelfRef.tb_cmo_arbiter__DOT__dut__DOT__reg_cmd_hart) 
                                      != (3U & tb_cmo_arbiter__DOT__unnamedblk2__DOT__h))) 
                                  | (vlSelfRef.tb_cmo_arbiter__DOT__dut__DOT__reg_cmd_pa_line 
                                     != (0x000fffffffffffffULL 
                                         & (0x0000000000000010ULL 
                                            + VL_EXTENDS_QI(52,32, tb_cmo_arbiter__DOT__unnamedblk2__DOT__h))))) 
                                 | (vlSelfRef.tb_cmo_arbiter__DOT__dut__DOT__reg_cmd_vaddr 
                                    != (0x0000000000000100ULL 
                                        + VL_EXTENDS_QI(64,32, tb_cmo_arbiter__DOT__unnamedblk2__DOT__h)))) 
                                | (vlSelfRef.tb_cmo_arbiter__DOT__dut__DOT__reg_cmd_pc 
                                   != (0x0000000000000200ULL 
                                       + VL_EXTENDS_QI(64,32, tb_cmo_arbiter__DOT__unnamedblk2__DOT__h)))))))) {
            VL_WRITEF_NX("[%0t] %%Fatal: tb_cmo_arbiter.sv:35: Assertion failed in %m: buffered command metadata mismatch\n",3, 'M',vlSymsp->name(),"tb_cmo_arbiter.unnamedblk2", 'T',-9
                         , '#',64,VL_TIME_UNITED_Q(1000));
            VL_STOP_MT("tb_cmo_arbiter.sv", 35, "", false);
        }
        tb_cmo_arbiter__DOT__unnamedblk2__DOT__unnamedblk1_2__DOT____Vrepeat1 = 3U;
        while (VL_LTS_III(32, 0U, tb_cmo_arbiter__DOT__unnamedblk2__DOT__unnamedblk1_2__DOT____Vrepeat1)) {
            Vtb_cmo_arbiter___024root____VbeforeTrig_ha124248b__0(vlSelf, 
                                                                  "@(negedge tb_cmo_arbiter.clk)");
            co_await vlSelfRef.__VtrigSched_ha124248b__0.trigger(0U, 
                                                                 nullptr, 
                                                                 "@(negedge tb_cmo_arbiter.clk)", 
                                                                 "tb_cmo_arbiter.sv", 
                                                                 38);
            if (VL_LIKELY(((0xcfU >= (0x000000ffU & 
                                      ((IData)(0x00000034U) 
                                       * tb_cmo_arbiter__DOT__unnamedblk2__DOT__h)))))) {
                VL_ASSIGNSEL_WQ(208, 52, (0x000000ffU 
                                          & ((IData)(0x00000034U) 
                                             * tb_cmo_arbiter__DOT__unnamedblk2__DOT__h)), vlSelfRef.tb_cmo_arbiter__DOT__pa, 0x000fffffffffffffULL);
            }
            VL_ASSIGNSEL_WQ(256, 64, (0x000000ffU & 
                                      (tb_cmo_arbiter__DOT__unnamedblk2__DOT__h 
                                       << 6U)), vlSelfRef.tb_cmo_arbiter__DOT__va, 0xffffffffffffffffULL);
            VL_ASSIGNSEL_WQ(256, 64, (0x000000ffU & 
                                      (tb_cmo_arbiter__DOT__unnamedblk2__DOT__h 
                                       << 6U)), vlSelfRef.tb_cmo_arbiter__DOT__pc, 0xffffffffffffffffULL);
            Vtb_cmo_arbiter___024root____VbeforeTrig_ha12423cc__0(vlSelf, 
                                                                  "@(posedge tb_cmo_arbiter.clk)");
            co_await vlSelfRef.__VtrigSched_ha12423cc__0.trigger(0U, 
                                                                 nullptr, 
                                                                 "@(posedge tb_cmo_arbiter.clk)", 
                                                                 "tb_cmo_arbiter.sv", 
                                                                 39);
            co_await vlSelfRef.__VdlySched.delay(0x00000000000003e8ULL, 
                                                 nullptr, 
                                                 "tb_cmo_arbiter.sv", 
                                                 39);
            if (VL_UNLIKELY(((1U & ((((((~ (IData)(vlSelfRef.tb_cmo_arbiter__DOT__cv)) 
                                        | ((IData)(vlSelfRef.tb_cmo_arbiter__DOT__dut__DOT__reg_cmd_hart) 
                                           != (3U & tb_cmo_arbiter__DOT__unnamedblk2__DOT__h))) 
                                       | (vlSelfRef.tb_cmo_arbiter__DOT__dut__DOT__reg_cmd_pa_line 
                                          != (0x000fffffffffffffULL 
                                              & (0x0000000000000010ULL 
                                                 + 
                                                 VL_EXTENDS_QI(52,32, tb_cmo_arbiter__DOT__unnamedblk2__DOT__h))))) 
                                      | (vlSelfRef.tb_cmo_arbiter__DOT__dut__DOT__reg_cmd_vaddr 
                                         != (0x0000000000000100ULL 
                                             + VL_EXTENDS_QI(64,32, tb_cmo_arbiter__DOT__unnamedblk2__DOT__h)))) 
                                     | (vlSelfRef.tb_cmo_arbiter__DOT__dut__DOT__reg_cmd_pc 
                                        != (0x0000000000000200ULL 
                                            + VL_EXTENDS_QI(64,32, tb_cmo_arbiter__DOT__unnamedblk2__DOT__h)))) 
                                    | (0U != (IData)(vlSelfRef.tb_cmo_arbiter__DOT__ready))))))) {
                VL_WRITEF_NX("[%0t] %%Fatal: tb_cmo_arbiter.sv:41: Assertion failed in %m: command changed during controller stall\n",3, 'M',vlSymsp->name(),"tb_cmo_arbiter.unnamedblk2.unnamedblk1_2", 'T',-9
                             , '#',64,VL_TIME_UNITED_Q(1000));
                VL_STOP_MT("tb_cmo_arbiter.sv", 41, "", false);
            }
            tb_cmo_arbiter__DOT__unnamedblk2__DOT__unnamedblk1_2__DOT____Vrepeat1 
                = (tb_cmo_arbiter__DOT__unnamedblk2__DOT__unnamedblk1_2__DOT____Vrepeat1 
                   - (IData)(1U));
        }
        Vtb_cmo_arbiter___024root____VbeforeTrig_ha124248b__0(vlSelf, 
                                                              "@(negedge tb_cmo_arbiter.clk)");
        co_await vlSelfRef.__VtrigSched_ha124248b__0.trigger(0U, 
                                                             nullptr, 
                                                             "@(negedge tb_cmo_arbiter.clk)", 
                                                             "tb_cmo_arbiter.sv", 
                                                             43);
        vlSelfRef.tb_cmo_arbiter__DOT__cr = 1U;
        Vtb_cmo_arbiter___024root____VbeforeTrig_ha12423cc__0(vlSelf, 
                                                              "@(posedge tb_cmo_arbiter.clk)");
        co_await vlSelfRef.__VtrigSched_ha12423cc__0.trigger(0U, 
                                                             nullptr, 
                                                             "@(posedge tb_cmo_arbiter.clk)", 
                                                             "tb_cmo_arbiter.sv", 
                                                             44);
        co_await vlSelfRef.__VdlySched.delay(0x00000000000003e8ULL, 
                                             nullptr, 
                                             "tb_cmo_arbiter.sv", 
                                             44);
        vlSelfRef.tb_cmo_arbiter__DOT__cr = 0U;
        if (VL_UNLIKELY(((((IData)(vlSelfRef.tb_cmo_arbiter__DOT__cv) 
                           | (0U != (IData)(vlSelfRef.tb_cmo_arbiter__DOT__ready))) 
                          | (0U != (IData)(vlSelfRef.tb_cmo_arbiter__DOT__done)))))) {
            VL_WRITEF_NX("[%0t] %%Fatal: tb_cmo_arbiter.sv:45: Assertion failed in %m: accepted command not held busy\n",3, 'M',vlSymsp->name(),"tb_cmo_arbiter.unnamedblk2", 'T',-9
                         , '#',64,VL_TIME_UNITED_Q(1000));
            VL_STOP_MT("tb_cmo_arbiter.sv", 45, "", false);
        }
        Vtb_cmo_arbiter___024root____VbeforeTrig_ha124248b__0(vlSelf, 
                                                              "@(negedge tb_cmo_arbiter.clk)");
        co_await vlSelfRef.__VtrigSched_ha124248b__0.trigger(0U, 
                                                             nullptr, 
                                                             "@(negedge tb_cmo_arbiter.clk)", 
                                                             "tb_cmo_arbiter.sv", 
                                                             46);
        vlSelfRef.tb_cmo_arbiter__DOT__cd = 1U;
        vlSelfRef.tb_cmo_arbiter__DOT__ce = (1U & VL_MODDIVS_III(32, tb_cmo_arbiter__DOT__unnamedblk2__DOT__h, (IData)(2U)));
        co_await vlSelfRef.__VdlySched.delay(0x00000000000003e8ULL, 
                                             nullptr, 
                                             "tb_cmo_arbiter.sv", 
                                             47);
        if (VL_UNLIKELY(((((IData)(vlSelfRef.tb_cmo_arbiter__DOT__done) 
                           != (0x0000000fU & VL_SHIFTL_III(4,4,32, (IData)(1U), tb_cmo_arbiter__DOT__unnamedblk2__DOT__h))) 
                          | ((IData)(vlSelfRef.tb_cmo_arbiter__DOT__err) 
                             != ((0U != VL_MODDIVS_III(32, tb_cmo_arbiter__DOT__unnamedblk2__DOT__h, (IData)(2U)))
                                  ? (0x0000000fU & 
                                     VL_SHIFTL_III(4,4,32, (IData)(1U), tb_cmo_arbiter__DOT__unnamedblk2__DOT__h))
                                  : 0U)))))) {
            VL_WRITEF_NX("[%0t] %%Fatal: tb_cmo_arbiter.sv:49: Assertion failed in %m: completion delivered to incorrect hart\n",3, 'M',vlSymsp->name(),"tb_cmo_arbiter.unnamedblk2", 'T',-9
                         , '#',64,VL_TIME_UNITED_Q(1000));
            VL_STOP_MT("tb_cmo_arbiter.sv", 49, "", false);
        }
        Vtb_cmo_arbiter___024root____VbeforeTrig_ha12423cc__0(vlSelf, 
                                                              "@(posedge tb_cmo_arbiter.clk)");
        co_await vlSelfRef.__VtrigSched_ha12423cc__0.trigger(0U, 
                                                             nullptr, 
                                                             "@(posedge tb_cmo_arbiter.clk)", 
                                                             "tb_cmo_arbiter.sv", 
                                                             50);
        co_await vlSelfRef.__VdlySched.delay(0x00000000000003e8ULL, 
                                             nullptr, 
                                             "tb_cmo_arbiter.sv", 
                                             50);
        vlSelfRef.tb_cmo_arbiter__DOT__cd = 0U;
        vlSelfRef.tb_cmo_arbiter__DOT__ce = 0U;
        tb_cmo_arbiter__DOT__unnamedblk2__DOT__h = 
            ((IData)(1U) + tb_cmo_arbiter__DOT__unnamedblk2__DOT__h);
    }
    Vtb_cmo_arbiter___024root____VbeforeTrig_ha124248b__0(vlSelf, 
                                                          "@(negedge tb_cmo_arbiter.clk)");
    co_await vlSelfRef.__VtrigSched_ha124248b__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(negedge tb_cmo_arbiter.clk)", 
                                                         "tb_cmo_arbiter.sv", 
                                                         53);
    vlSelfRef.tb_cmo_arbiter__DOT__cd = 1U;
    co_await vlSelfRef.__VdlySched.delay(0x00000000000003e8ULL, 
                                         nullptr, "tb_cmo_arbiter.sv", 
                                         54);
    if (VL_UNLIKELY(((0U != (IData)(vlSelfRef.tb_cmo_arbiter__DOT__done))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_cmo_arbiter.sv:54: Assertion failed in %m: unsolicited completion escaped\n",3, 'M',vlSymsp->name(),"tb_cmo_arbiter", 'T',-9
                     , '#',64,VL_TIME_UNITED_Q(1000));
        VL_STOP_MT("tb_cmo_arbiter.sv", 54, "", false);
    }
    VL_WRITEF_NX("PASS: CMO arbitration, stable payload, exclusive ownership, error demultiplexing\n",0);
    VL_FINISH_MT("tb_cmo_arbiter.sv", 56, "");
    co_return;
}

VlCoroutine Vtb_cmo_arbiter___024root___eval_initial__TOP__Vtiming__1(Vtb_cmo_arbiter___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_cmo_arbiter___024root___eval_initial__TOP__Vtiming__1\n"); );
    Vtb_cmo_arbiter__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    while (VL_LIKELY(!vlSymsp->_vm_contextp__->gotFinish())) {
        co_await vlSelfRef.__VdlySched.delay(0x0000000000001388ULL, 
                                             nullptr, 
                                             "tb_cmo_arbiter.sv", 
                                             12);
        vlSelfRef.tb_cmo_arbiter__DOT__clk = (1U & 
                                              (~ (IData)(vlSelfRef.tb_cmo_arbiter__DOT__clk)));
    }
    co_return;
}

bool Vtb_cmo_arbiter___024root___trigger_anySet__ico(const VlUnpacked<QData/*63:0*/, 1> &in) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_cmo_arbiter___024root___trigger_anySet__ico\n"); );
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

bool Vtb_cmo_arbiter___024root___trigger_anySet__act(const VlUnpacked<QData/*63:0*/, 1> &in) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_cmo_arbiter___024root___trigger_anySet__act\n"); );
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

void Vtb_cmo_arbiter___024root___act_comb__TOP__0(Vtb_cmo_arbiter___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_cmo_arbiter___024root___act_comb__TOP__0\n"); );
    Vtb_cmo_arbiter__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    CData/*0:0*/ tb_cmo_arbiter__DOT__dut__DOT__w_pick_valid;
    tb_cmo_arbiter__DOT__dut__DOT__w_pick_valid = 0;
    IData/*31:0*/ tb_cmo_arbiter__DOT__dut__DOT__w_scan_hart;
    tb_cmo_arbiter__DOT__dut__DOT__w_scan_hart = 0;
    // Body
    vlSelfRef.tb_cmo_arbiter__DOT__cv = ((IData)(vlSelfRef.tb_cmo_arbiter__DOT__rst) 
                                         & (IData)(vlSelfRef.tb_cmo_arbiter__DOT__dut__DOT__reg_cmd_valid));
    tb_cmo_arbiter__DOT__dut__DOT__w_pick_valid = 0U;
    vlSelfRef.tb_cmo_arbiter__DOT__dut__DOT__w_pick_hart = 0U;
    tb_cmo_arbiter__DOT__dut__DOT__w_scan_hart = vlSelfRef.tb_cmo_arbiter__DOT__dut__DOT__reg_rr_hart;
    if ((2U <= tb_cmo_arbiter__DOT__dut__DOT__w_scan_hart)) {
        tb_cmo_arbiter__DOT__dut__DOT__w_scan_hart 
            = (tb_cmo_arbiter__DOT__dut__DOT__w_scan_hart 
               - (IData)(2U));
    }
    if ((1U & ((IData)(vlSelfRef.tb_cmo_arbiter__DOT__valid) 
               >> (3U & tb_cmo_arbiter__DOT__dut__DOT__w_scan_hart)))) {
        tb_cmo_arbiter__DOT__dut__DOT__w_pick_valid = 1U;
        vlSelfRef.tb_cmo_arbiter__DOT__dut__DOT__w_pick_hart 
            = (3U & tb_cmo_arbiter__DOT__dut__DOT__w_scan_hart);
    }
    tb_cmo_arbiter__DOT__dut__DOT__w_scan_hart = ((IData)(1U) 
                                                  + (IData)(vlSelfRef.tb_cmo_arbiter__DOT__dut__DOT__reg_rr_hart));
    if ((2U <= tb_cmo_arbiter__DOT__dut__DOT__w_scan_hart)) {
        tb_cmo_arbiter__DOT__dut__DOT__w_scan_hart 
            = (tb_cmo_arbiter__DOT__dut__DOT__w_scan_hart 
               - (IData)(2U));
    }
    if ((1U & ((~ (IData)(tb_cmo_arbiter__DOT__dut__DOT__w_pick_valid)) 
               & ((IData)(vlSelfRef.tb_cmo_arbiter__DOT__valid) 
                  >> (3U & tb_cmo_arbiter__DOT__dut__DOT__w_scan_hart))))) {
        tb_cmo_arbiter__DOT__dut__DOT__w_pick_valid = 1U;
        vlSelfRef.tb_cmo_arbiter__DOT__dut__DOT__w_pick_hart 
            = (3U & tb_cmo_arbiter__DOT__dut__DOT__w_scan_hart);
    }
    vlSelfRef.tb_cmo_arbiter__DOT__ready = 0U;
    if (((((~ (IData)(vlSelfRef.tb_cmo_arbiter__DOT__dut__DOT__reg_cmd_valid)) 
           & (~ (IData)(vlSelfRef.tb_cmo_arbiter__DOT__dut__DOT__reg_busy))) 
          & (IData)(vlSelfRef.tb_cmo_arbiter__DOT__rst)) 
         & (IData)(tb_cmo_arbiter__DOT__dut__DOT__w_pick_valid))) {
        vlSelfRef.tb_cmo_arbiter__DOT__ready = ((IData)(vlSelfRef.tb_cmo_arbiter__DOT__ready) 
                                                | (0x0fU 
                                                   & ((IData)(1U) 
                                                      << (IData)(vlSelfRef.tb_cmo_arbiter__DOT__dut__DOT__w_pick_hart))));
    }
    vlSelfRef.tb_cmo_arbiter__DOT__dut__DOT__w_issue 
        = ((IData)(vlSelfRef.tb_cmo_arbiter__DOT__cr) 
           & ((IData)(vlSelfRef.tb_cmo_arbiter__DOT__rst) 
              & (IData)(vlSelfRef.tb_cmo_arbiter__DOT__dut__DOT__reg_cmd_valid)));
    vlSelfRef.tb_cmo_arbiter__DOT__dut__DOT__w_capture 
        = (0U != ((IData)(vlSelfRef.tb_cmo_arbiter__DOT__valid) 
                  & (IData)(vlSelfRef.tb_cmo_arbiter__DOT__ready)));
    vlSelfRef.tb_cmo_arbiter__DOT__dut__DOT__w_complete 
        = ((IData)(vlSelfRef.tb_cmo_arbiter__DOT__rst) 
           & ((IData)(vlSelfRef.tb_cmo_arbiter__DOT__cd) 
              & ((IData)(vlSelfRef.tb_cmo_arbiter__DOT__dut__DOT__reg_busy) 
                 | (IData)(vlSelfRef.tb_cmo_arbiter__DOT__dut__DOT__w_issue))));
    vlSelfRef.tb_cmo_arbiter__DOT__done = 0U;
    vlSelfRef.tb_cmo_arbiter__DOT__err = 0U;
    if (vlSelfRef.tb_cmo_arbiter__DOT__dut__DOT__w_complete) {
        vlSelfRef.tb_cmo_arbiter__DOT__done = ((IData)(vlSelfRef.tb_cmo_arbiter__DOT__done) 
                                               | (0x0fU 
                                                  & ((IData)(1U) 
                                                     << (IData)(vlSelfRef.tb_cmo_arbiter__DOT__dut__DOT__reg_cmd_hart))));
        vlSelfRef.tb_cmo_arbiter__DOT__err = (((~ ((IData)(1U) 
                                                   << (IData)(vlSelfRef.tb_cmo_arbiter__DOT__dut__DOT__reg_cmd_hart))) 
                                               & (IData)(vlSelfRef.tb_cmo_arbiter__DOT__err)) 
                                              | (0x0fU 
                                                 & ((IData)(vlSelfRef.tb_cmo_arbiter__DOT__ce) 
                                                    << (IData)(vlSelfRef.tb_cmo_arbiter__DOT__dut__DOT__reg_cmd_hart))));
    }
}

void Vtb_cmo_arbiter___024root___eval_body__nba(Vtb_cmo_arbiter___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_cmo_arbiter___024root___eval_body__nba\n"); );
    Vtb_cmo_arbiter__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if ((3ULL & vlSelfRef.__VnbaTriggered[0U])) {
        {
            // Inlined CFunc: _nba_sequent__TOP__0
            CData/*31:0*/ __Vinline_0__nba_sequent__TOP__0___VExpandSel_Lsb_1;
            if (vlSelfRef.tb_cmo_arbiter__DOT__rst) {
                if (vlSelfRef.tb_cmo_arbiter__DOT__dut__DOT__w_capture) {
                    __Vinline_0__nba_sequent__TOP__0___VExpandSel_Lsb_1 
                        = (0x000000ffU & ((IData)(0x00000034U) 
                                          * (IData)(vlSelfRef.tb_cmo_arbiter__DOT__dut__DOT__w_pick_hart)));
                    vlSelfRef.tb_cmo_arbiter__DOT__dut__DOT__reg_cmd_pa_line 
                        = ((0xcfU >= (0x000000ffU & 
                                      ((IData)(0x00000034U) 
                                       * (IData)(vlSelfRef.tb_cmo_arbiter__DOT__dut__DOT__w_pick_hart))))
                            ? (0x000fffffffffffffULL 
                               & (((QData)((IData)(vlSelfRef.tb_cmo_arbiter__DOT__pa
                                                   [
                                                   (((IData)(0x00000033U) 
                                                     + __Vinline_0__nba_sequent__TOP__0___VExpandSel_Lsb_1) 
                                                    >> 5U)])) 
                                   << ((0U == (0x0000001fU 
                                               & ((IData)(0x00000034U) 
                                                  * (IData)(vlSelfRef.tb_cmo_arbiter__DOT__dut__DOT__w_pick_hart))))
                                        ? 0x00000020U
                                        : ((IData)(0x00000040U) 
                                           - (0x0000001fU 
                                              & ((IData)(0x00000034U) 
                                                 * (IData)(vlSelfRef.tb_cmo_arbiter__DOT__dut__DOT__w_pick_hart)))))) 
                                  | (((0U == (0x0000001fU 
                                              & ((IData)(0x00000034U) 
                                                 * (IData)(vlSelfRef.tb_cmo_arbiter__DOT__dut__DOT__w_pick_hart))))
                                       ? 0ULL : ((QData)((IData)(vlSelfRef.tb_cmo_arbiter__DOT__pa
                                                                 [
                                                                 (((IData)(0x0000001fU) 
                                                                   + __Vinline_0__nba_sequent__TOP__0___VExpandSel_Lsb_1) 
                                                                  >> 5U)])) 
                                                 << 
                                                 ((IData)(0x00000020U) 
                                                  - 
                                                  (0x0000001fU 
                                                   & ((IData)(0x00000034U) 
                                                      * (IData)(vlSelfRef.tb_cmo_arbiter__DOT__dut__DOT__w_pick_hart)))))) 
                                     | ((QData)((IData)(vlSelfRef.tb_cmo_arbiter__DOT__pa
                                                        [
                                                        (7U 
                                                         & (((IData)(0x00000034U) 
                                                             * (IData)(vlSelfRef.tb_cmo_arbiter__DOT__dut__DOT__w_pick_hart)) 
                                                            >> 5U))])) 
                                        >> (0x0000001fU 
                                            & ((IData)(0x00000034U) 
                                               * (IData)(vlSelfRef.tb_cmo_arbiter__DOT__dut__DOT__w_pick_hart)))))))
                            : 0ULL);
                    vlSelfRef.tb_cmo_arbiter__DOT__dut__DOT__reg_cmd_vaddr 
                        = (((QData)((IData)(vlSelfRef.tb_cmo_arbiter__DOT__va
                                            [(((IData)(0x0000003fU) 
                                               + (0x000000ffU 
                                                  & ((IData)(vlSelfRef.tb_cmo_arbiter__DOT__dut__DOT__w_pick_hart) 
                                                     << 6U))) 
                                              >> 5U)])) 
                            << 0x00000020U) | (QData)((IData)(vlSelfRef.tb_cmo_arbiter__DOT__va
                                                              [
                                                              (6U 
                                                               & ((IData)(vlSelfRef.tb_cmo_arbiter__DOT__dut__DOT__w_pick_hart) 
                                                                  << 1U))])));
                    vlSelfRef.tb_cmo_arbiter__DOT__dut__DOT__reg_cmd_pc 
                        = (((QData)((IData)(vlSelfRef.tb_cmo_arbiter__DOT__pc
                                            [(((IData)(0x0000003fU) 
                                               + (0x000000ffU 
                                                  & ((IData)(vlSelfRef.tb_cmo_arbiter__DOT__dut__DOT__w_pick_hart) 
                                                     << 6U))) 
                                              >> 5U)])) 
                            << 0x00000020U) | (QData)((IData)(vlSelfRef.tb_cmo_arbiter__DOT__pc
                                                              [
                                                              (6U 
                                                               & ((IData)(vlSelfRef.tb_cmo_arbiter__DOT__dut__DOT__w_pick_hart) 
                                                                  << 1U))])));
                    vlSelfRef.tb_cmo_arbiter__DOT__dut__DOT__reg_cmd_hart 
                        = vlSelfRef.tb_cmo_arbiter__DOT__dut__DOT__w_pick_hart;
                    vlSelfRef.tb_cmo_arbiter__DOT__dut__DOT__reg_rr_hart 
                        = ((1U == (IData)(vlSelfRef.tb_cmo_arbiter__DOT__dut__DOT__w_pick_hart))
                            ? 0U : (3U & ((IData)(1U) 
                                          + (IData)(vlSelfRef.tb_cmo_arbiter__DOT__dut__DOT__w_pick_hart))));
                    vlSelfRef.tb_cmo_arbiter__DOT__dut__DOT__reg_cmd_valid = 1U;
                }
                if (vlSelfRef.tb_cmo_arbiter__DOT__dut__DOT__w_issue) {
                    vlSelfRef.tb_cmo_arbiter__DOT__dut__DOT__reg_busy = 1U;
                    vlSelfRef.tb_cmo_arbiter__DOT__dut__DOT__reg_cmd_valid = 0U;
                }
                if (vlSelfRef.tb_cmo_arbiter__DOT__dut__DOT__w_complete) {
                    vlSelfRef.tb_cmo_arbiter__DOT__dut__DOT__reg_busy = 0U;
                }
            } else {
                vlSelfRef.tb_cmo_arbiter__DOT__dut__DOT__reg_cmd_pa_line = 0ULL;
                vlSelfRef.tb_cmo_arbiter__DOT__dut__DOT__reg_cmd_vaddr = 0ULL;
                vlSelfRef.tb_cmo_arbiter__DOT__dut__DOT__reg_cmd_pc = 0ULL;
                vlSelfRef.tb_cmo_arbiter__DOT__dut__DOT__reg_cmd_hart = 0U;
                vlSelfRef.tb_cmo_arbiter__DOT__dut__DOT__reg_rr_hart = 0U;
                vlSelfRef.tb_cmo_arbiter__DOT__dut__DOT__reg_busy = 0U;
                vlSelfRef.tb_cmo_arbiter__DOT__dut__DOT__reg_cmd_valid = 0U;
            }
        }
    }
    if ((0x000000000000000fULL & vlSelfRef.__VnbaTriggered[0U])) {
        Vtb_cmo_arbiter___024root___act_comb__TOP__0(vlSelf);
    }
}

void Vtb_cmo_arbiter___024root___timing_ready(Vtb_cmo_arbiter___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_cmo_arbiter___024root___timing_ready\n"); );
    Vtb_cmo_arbiter__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if ((4ULL & vlSelfRef.__VactTriggered[0U])) {
        vlSelfRef.__VtrigSched_ha124248b__0.ready("@(negedge tb_cmo_arbiter.clk)");
    }
    if ((1ULL & vlSelfRef.__VactTriggered[0U])) {
        vlSelfRef.__VtrigSched_ha12423cc__0.ready("@(posedge tb_cmo_arbiter.clk)");
    }
}

void Vtb_cmo_arbiter___024root___timing_resume(Vtb_cmo_arbiter___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_cmo_arbiter___024root___timing_resume\n"); );
    Vtb_cmo_arbiter__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    vlSelfRef.__VtrigSched_ha124248b__0.moveToResumeQueue(
                                                          "@(negedge tb_cmo_arbiter.clk)");
    vlSelfRef.__VtrigSched_ha12423cc__0.moveToResumeQueue(
                                                          "@(posedge tb_cmo_arbiter.clk)");
    vlSelfRef.__VtrigSched_ha124248b__0.resume("@(negedge tb_cmo_arbiter.clk)");
    vlSelfRef.__VtrigSched_ha12423cc__0.resume("@(posedge tb_cmo_arbiter.clk)");
    if ((8ULL & vlSelfRef.__VactTriggered[0U])) {
        vlSelfRef.__VdlySched.resume();
    }
}

void Vtb_cmo_arbiter___024root___trigger_orInto__act_vec_vec(VlUnpacked<QData/*63:0*/, 1> &out, const VlUnpacked<QData/*63:0*/, 1> &in) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_cmo_arbiter___024root___trigger_orInto__act_vec_vec\n"); );
    // Locals
    IData/*31:0*/ n;
    // Body
    n = 0U;
    do {
        out[n] = (out[n] | in[n]);
        n = ((IData)(1U) + n);
    } while ((0U >= n));
}

void Vtb_cmo_arbiter___024root___trigger_clear__act(VlUnpacked<QData/*63:0*/, 1> &out) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_cmo_arbiter___024root___trigger_clear__act\n"); );
    // Locals
    IData/*31:0*/ n;
    // Body
    n = 0U;
    do {
        out[n] = 0ULL;
        n = ((IData)(1U) + n);
    } while ((1U > n));
}

void Vtb_cmo_arbiter___024root____VbeforeTrig_ha124248b__0(Vtb_cmo_arbiter___024root* vlSelf, const char* __VeventDescription) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_cmo_arbiter___024root____VbeforeTrig_ha124248b__0\n"); );
    Vtb_cmo_arbiter__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    VlUnpacked<QData/*63:0*/, 1> __VTmp;
    // Body
    __VTmp[0U] = (QData)((IData)(((((~ (IData)(vlSelfRef.tb_cmo_arbiter__DOT__clk)) 
                                    & (IData)(vlSelfRef.__Vtrigprevexpr___TOP__tb_cmo_arbiter__DOT__clk__0)) 
                                   << 2U) | ((IData)(vlSelfRef.tb_cmo_arbiter__DOT__clk) 
                                             & (~ (IData)(vlSelfRef.__Vtrigprevexpr___TOP__tb_cmo_arbiter__DOT__clk__0))))));
    vlSelfRef.__Vtrigprevexpr___TOP__tb_cmo_arbiter__DOT__clk__0 
        = vlSelfRef.tb_cmo_arbiter__DOT__clk;
    if ((1ULL & __VTmp[0U])) {
        vlSelfRef.__VtrigSched_ha12423cc__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_ha12423cc__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_ha12423cc__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_ha12423cc__0.ready(__VeventDescription);
    }
    if ((4ULL & __VTmp[0U])) {
        vlSelfRef.__VtrigSched_ha124248b__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_ha124248b__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_ha124248b__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_ha124248b__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_ha124248b__0.ready(__VeventDescription);
    }
    vlSelfRef.__VactTriggeredAcc[0U] = (vlSelfRef.__VactTriggeredAcc[0U] 
                                        | __VTmp[0U]);
}

void Vtb_cmo_arbiter___024root____VbeforeTrig_ha12423cc__0(Vtb_cmo_arbiter___024root* vlSelf, const char* __VeventDescription) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_cmo_arbiter___024root____VbeforeTrig_ha12423cc__0\n"); );
    Vtb_cmo_arbiter__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    VlUnpacked<QData/*63:0*/, 1> __VTmp;
    // Body
    __VTmp[0U] = (QData)((IData)(((((~ (IData)(vlSelfRef.tb_cmo_arbiter__DOT__clk)) 
                                    & (IData)(vlSelfRef.__Vtrigprevexpr___TOP__tb_cmo_arbiter__DOT__clk__0)) 
                                   << 2U) | ((IData)(vlSelfRef.tb_cmo_arbiter__DOT__clk) 
                                             & (~ (IData)(vlSelfRef.__Vtrigprevexpr___TOP__tb_cmo_arbiter__DOT__clk__0))))));
    vlSelfRef.__Vtrigprevexpr___TOP__tb_cmo_arbiter__DOT__clk__0 
        = vlSelfRef.tb_cmo_arbiter__DOT__clk;
    if ((1ULL & __VTmp[0U])) {
        vlSelfRef.__VtrigSched_ha12423cc__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_ha12423cc__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_ha12423cc__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_ha12423cc__0.ready(__VeventDescription);
    }
    if ((4ULL & __VTmp[0U])) {
        vlSelfRef.__VtrigSched_ha124248b__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_ha124248b__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_ha124248b__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_ha124248b__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_ha124248b__0.ready(__VeventDescription);
    }
    vlSelfRef.__VactTriggeredAcc[0U] = (vlSelfRef.__VactTriggeredAcc[0U] 
                                        | __VTmp[0U]);
}

#ifdef VL_DEBUG
void Vtb_cmo_arbiter___024root___eval_debug_assertions(Vtb_cmo_arbiter___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_cmo_arbiter___024root___eval_debug_assertions\n"); );
    Vtb_cmo_arbiter__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
}
#endif  // VL_DEBUG
