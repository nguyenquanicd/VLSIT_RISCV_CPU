// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vtb_cmo_retirement.h for the primary calling header

#include "Vtb_cmo_retirement__pch.h"

void Vtb_cmo_retirement___024root___timing_ready(Vtb_cmo_retirement___024root* vlSelf);

VL_ATTR_COLD void Vtb_cmo_retirement___024root___eval_static(Vtb_cmo_retirement___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_cmo_retirement___024root___eval_static\n"); );
    Vtb_cmo_retirement__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    {
        // Inlined CFunc: _eval_static__TOP
        vlSelfRef.tb_cmo_retirement__DOT__clk = 0U;
        vlSelfRef.tb_cmo_retirement__DOT__rst = 0U;
        vlSelfRef.tb_cmo_retirement__DOT__halt = 0U;
        vlSelfRef.tb_cmo_retirement__DOT__no_store = 0U;
        vlSelfRef.tb_cmo_retirement__DOT__ready = 0U;
        vlSelfRef.tb_cmo_retirement__DOT__done = 0U;
        vlSelfRef.tb_cmo_retirement__DOT__error = 0U;
        vlSelfRef.tb_cmo_retirement__DOT__source_va = 0xffffffff80001237ULL;
    }
    vlSelfRef.__VactTriggered[0U] = (0x0000000000000010ULL 
                                     | vlSelfRef.__VactTriggered[0U]);
    vlSelfRef.__Vtrigprevexpr___TOP__tb_cmo_retirement__DOT__clk__0 = 0U;
    vlSelfRef.__Vtrigprevexpr___TOP__tb_cmo_retirement__DOT__rst__0 = 0U;
    vlSelfRef.__Vtrigprevexpr___TOP__tb_cmo_retirement__DOT__dut__DOT__cmo_offer_q__0 
        = vlSelfRef.tb_cmo_retirement__DOT__dut__DOT__cmo_offer_q;
    Vtb_cmo_retirement___024root___timing_ready(vlSelf);
    do {
        vlSelfRef.__VactTriggeredAcc[vlSelfRef.__Vi] 
            = vlSelfRef.__VactTriggered[vlSelfRef.__Vi];
        vlSelfRef.__Vi = ((IData)(1U) + vlSelfRef.__Vi);
    } while ((0U >= vlSelfRef.__Vi));
}

#ifdef VL_DEBUG
VL_ATTR_COLD void Vtb_cmo_retirement___024root___dump_triggers__stl(const VlUnpacked<QData/*63:0*/, 1> &triggers, const std::string &tag);
#endif  // VL_DEBUG
VL_ATTR_COLD bool Vtb_cmo_retirement___024root___trigger_anySet__stl(const VlUnpacked<QData/*63:0*/, 1> &in);
VL_ATTR_COLD void Vtb_cmo_retirement___024root___stl_sequent__TOP__0(Vtb_cmo_retirement___024root* vlSelf);

VL_ATTR_COLD bool Vtb_cmo_retirement___024root___eval_stl(Vtb_cmo_retirement___024root* vlSelf, CData/*0:0*/ firstIteration) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_cmo_retirement___024root___eval_stl\n"); );
    Vtb_cmo_retirement__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    CData/*0:0*/ __VstlExecute;
    // Body
    vlSelfRef.__VstlTriggered[0U] = ((0xfffffffffffffffeULL 
                                      & vlSelfRef.__VstlTriggered[0U]) 
                                     | (IData)((IData)(firstIteration)));
#ifdef VL_DEBUG
    if (VL_UNLIKELY(vlSymsp->_vm_contextp__->debug())) {
        Vtb_cmo_retirement___024root___dump_triggers__stl(vlSelfRef.__VstlTriggered, "stl"s);
    }
#endif
    __VstlExecute = Vtb_cmo_retirement___024root___trigger_anySet__stl(vlSelfRef.__VstlTriggered);
    if (__VstlExecute) {
        {
            // Inlined CFunc: _eval_body__stl
            if ((1ULL & vlSelfRef.__VstlTriggered[0U])) {
                Vtb_cmo_retirement___024root___stl_sequent__TOP__0(vlSelf);
            }
        }
    }
    return (__VstlExecute);
}

VL_ATTR_COLD void Vtb_cmo_retirement___024root___eval_dump_triggers__stl(Vtb_cmo_retirement___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_cmo_retirement___024root___eval_dump_triggers__stl\n"); );
    Vtb_cmo_retirement__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
#ifdef VL_DEBUG
    Vtb_cmo_retirement___024root___dump_triggers__stl(vlSelfRef.__VstlTriggered, "stl"s);
#endif
}

#ifdef VL_DEBUG
VL_ATTR_COLD void Vtb_cmo_retirement___024root___dump_triggers__ico(const VlUnpacked<QData/*63:0*/, 1> &triggers, const std::string &tag);
#endif  // VL_DEBUG

VL_ATTR_COLD void Vtb_cmo_retirement___024root___eval_dump_triggers__ico(Vtb_cmo_retirement___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_cmo_retirement___024root___eval_dump_triggers__ico\n"); );
    Vtb_cmo_retirement__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
#ifdef VL_DEBUG
    Vtb_cmo_retirement___024root___dump_triggers__ico(vlSelfRef.__VicoTriggered, "ico"s);
#endif
}

#ifdef VL_DEBUG
VL_ATTR_COLD void Vtb_cmo_retirement___024root___dump_triggers__act(const VlUnpacked<QData/*63:0*/, 1> &triggers, const std::string &tag);
#endif  // VL_DEBUG

VL_ATTR_COLD void Vtb_cmo_retirement___024root___eval_dump_triggers__act(Vtb_cmo_retirement___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_cmo_retirement___024root___eval_dump_triggers__act\n"); );
    Vtb_cmo_retirement__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
#ifdef VL_DEBUG
    Vtb_cmo_retirement___024root___dump_triggers__act(vlSelfRef.__VactTriggered, "act"s);
#endif
}

VL_ATTR_COLD void Vtb_cmo_retirement___024root___eval_dump_triggers__nba(Vtb_cmo_retirement___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_cmo_retirement___024root___eval_dump_triggers__nba\n"); );
    Vtb_cmo_retirement__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
#ifdef VL_DEBUG
    Vtb_cmo_retirement___024root___dump_triggers__act(vlSelfRef.__VnbaTriggered, "nba"s);
#endif
}

VL_ATTR_COLD void Vtb_cmo_retirement___024root___eval_dump_triggers__obs(Vtb_cmo_retirement___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_cmo_retirement___024root___eval_dump_triggers__obs\n"); );
    Vtb_cmo_retirement__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
}

VL_ATTR_COLD void Vtb_cmo_retirement___024root___eval_dump_triggers__react(Vtb_cmo_retirement___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_cmo_retirement___024root___eval_dump_triggers__react\n"); );
    Vtb_cmo_retirement__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
}

VL_ATTR_COLD void Vtb_cmo_retirement___024root___eval_final(Vtb_cmo_retirement___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_cmo_retirement___024root___eval_final\n"); );
    Vtb_cmo_retirement__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
}

#ifdef VL_DEBUG
VL_ATTR_COLD void Vtb_cmo_retirement___024root___dump_triggers__stl(const VlUnpacked<QData/*63:0*/, 1> &triggers, const std::string &tag) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_cmo_retirement___024root___dump_triggers__stl\n"); );
    // Body
    if ((1U & (~ (IData)(Vtb_cmo_retirement___024root___trigger_anySet__stl(triggers))))) {
        VL_DBG_MSGS("         No '" + tag + "' region triggers active\n");
    }
    if ((1U & (IData)(triggers[0U]))) {
        VL_DBG_MSGS("         '" + tag + "' region trigger index 0 is active: Internal 'stl' trigger - first iteration\n");
    }
}
#endif  // VL_DEBUG

VL_ATTR_COLD bool Vtb_cmo_retirement___024root___trigger_anySet__stl(const VlUnpacked<QData/*63:0*/, 1> &in) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_cmo_retirement___024root___trigger_anySet__stl\n"); );
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

VL_ATTR_COLD void Vtb_cmo_retirement___024root___stl_sequent__TOP__0(Vtb_cmo_retirement___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_cmo_retirement___024root___stl_sequent__TOP__0\n"); );
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
    vlSelfRef.tb_cmo_retirement__DOT__active = ((IData)(vlSelfRef.tb_cmo_retirement__DOT__dut__DOT__cmo_offer_q) 
                                                | ((IData)(vlSelfRef.tb_cmo_retirement__DOT__dut__DOT__cmo_busy_q) 
                                                   | (IData)(vlSelfRef.tb_cmo_retirement__DOT__dut__DOT__cmo_complete_q)));
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

bool Vtb_cmo_retirement___024root___trigger_anySet__ico(const VlUnpacked<QData/*63:0*/, 1> &in);

#ifdef VL_DEBUG
VL_ATTR_COLD void Vtb_cmo_retirement___024root___dump_triggers__ico(const VlUnpacked<QData/*63:0*/, 1> &triggers, const std::string &tag) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_cmo_retirement___024root___dump_triggers__ico\n"); );
    // Body
    if ((1U & (~ (IData)(Vtb_cmo_retirement___024root___trigger_anySet__ico(triggers))))) {
        VL_DBG_MSGS("         No '" + tag + "' region triggers active\n");
    }
    if ((1U & (IData)(triggers[0U]))) {
        VL_DBG_MSGS("         '" + tag + "' region trigger index 0 is active: Internal 'ico' trigger - first iteration\n");
    }
}
#endif  // VL_DEBUG

bool Vtb_cmo_retirement___024root___trigger_anySet__act(const VlUnpacked<QData/*63:0*/, 1> &in);

#ifdef VL_DEBUG
VL_ATTR_COLD void Vtb_cmo_retirement___024root___dump_triggers__act(const VlUnpacked<QData/*63:0*/, 1> &triggers, const std::string &tag) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_cmo_retirement___024root___dump_triggers__act\n"); );
    // Body
    if ((1U & (~ (IData)(Vtb_cmo_retirement___024root___trigger_anySet__act(triggers))))) {
        VL_DBG_MSGS("         No '" + tag + "' region triggers active\n");
    }
    if ((1U & (IData)(triggers[0U]))) {
        VL_DBG_MSGS("         '" + tag + "' region trigger index 0 is active: @(posedge tb_cmo_retirement.clk)\n");
    }
    if ((1U & (IData)((triggers[0U] >> 1U)))) {
        VL_DBG_MSGS("         '" + tag + "' region trigger index 1 is active: @(negedge tb_cmo_retirement.rst)\n");
    }
    if ((1U & (IData)((triggers[0U] >> 2U)))) {
        VL_DBG_MSGS("         '" + tag + "' region trigger index 2 is active: @(negedge tb_cmo_retirement.clk)\n");
    }
    if ((1U & (IData)((triggers[0U] >> 3U)))) {
        VL_DBG_MSGS("         '" + tag + "' region trigger index 3 is active: @([true] __VdlySched.awaitingCurrentTime())\n");
    }
    if ((1U & (IData)((triggers[0U] >> 4U)))) {
        VL_DBG_MSGS("         '" + tag + "' region trigger index 4 is active: @( tb_cmo_retirement.dut.cmo_offer_q)\n");
    }
}
#endif  // VL_DEBUG

VL_ATTR_COLD void Vtb_cmo_retirement___024root___ctor_var_reset(Vtb_cmo_retirement___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_cmo_retirement___024root___ctor_var_reset\n"); );
    Vtb_cmo_retirement__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    const uint64_t __VscopeHash = VL_MURMUR64_HASH(vlSelf->vlNamep);
    VL_SCOPED_RAND_RESET_W(712, vlSelf->tb_cmo_retirement__DOT__entry, __VscopeHash, 6127994277130558684ull);
    VL_SCOPED_RAND_RESET_W(204, vlSelf->tb_cmo_retirement__DOT__irq, __VscopeHash, 9193144512230520346ull);
    VL_SCOPED_RAND_RESET_W(204, vlSelf->tb_cmo_retirement__DOT__fault, __VscopeHash, 14411415671897840776ull);
    vlSelf->tb_cmo_retirement__DOT__active = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 10797534167442975925ull);
    vlSelf->tb_cmo_retirement__DOT__pop = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 14983772941236297250ull);
    vlSelf->tb_cmo_retirement__DOT__ack = VL_SCOPED_RAND_RESET_I(2, __VscopeHash, 17570643020895155482ull);
    vlSelf->tb_cmo_retirement__DOT__dut__DOT__cmo_head = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 16138771805391840606ull);
    vlSelf->tb_cmo_retirement__DOT__dut__DOT__cmo_busy_q = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 8367255362937042842ull);
    vlSelf->tb_cmo_retirement__DOT__dut__DOT__cmo_complete_q = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 9759447652202415326ull);
    vlSelf->tb_cmo_retirement__DOT__dut__DOT__cmo_error_q = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 8169659313292020139ull);
    vlSelf->tb_cmo_retirement__DOT__dut__DOT__cmo_offer_q = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 17842441243958631860ull);
    vlSelf->tb_cmo_retirement__DOT__dut__DOT__cmo_eligible = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 7583085672223194259ull);
    vlSelf->tb_cmo_retirement__DOT__dut__DOT__cmo_op_q = VL_SCOPED_RAND_RESET_I(2, __VscopeHash, 6712198013909964369ull);
    vlSelf->tb_cmo_retirement__DOT__dut__DOT__cmo_line_q = VL_SCOPED_RAND_RESET_Q(52, __VscopeHash, 10615045944816459874ull);
    vlSelf->tb_cmo_retirement__DOT__dut__DOT__cmo_pc_q = VL_SCOPED_RAND_RESET_Q(64, __VscopeHash, 9729227241016407772ull);
    vlSelf->tb_cmo_retirement__DOT__dut__DOT__cmo_fault_vaddr_q = VL_SCOPED_RAND_RESET_Q(64, __VscopeHash, 5494475717984821394ull);
    vlSelf->tb_cmo_retirement__DOT__dut__DOT__cmo_take = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 6516821727961294763ull);
    vlSelf->__VdfgRegularize_h6e95ff9d_0_3 = 0;
    VL_ZERO_RESET_W(204, vlSelf->__VdfgRegularize_h6e95ff9d_0_4);
    VL_ZERO_RESET_W(202, vlSelf->__VdfgRegularize_h6e95ff9d_0_7);
    vlSelf->__VdfgRegularize_h6e95ff9d_0_11 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_12 = 0;
    for (int __Vi0 = 0; __Vi0 < 1; ++__Vi0) {
        vlSelf->__VstlTriggered[__Vi0] = 0;
    }
    for (int __Vi0 = 0; __Vi0 < 1; ++__Vi0) {
        vlSelf->__VicoTriggered[__Vi0] = 0;
    }
    for (int __Vi0 = 0; __Vi0 < 1; ++__Vi0) {
        vlSelf->__VactTriggered[__Vi0] = 0;
    }
    for (int __Vi0 = 0; __Vi0 < 1; ++__Vi0) {
        vlSelf->__VactTriggeredAcc[__Vi0] = 0;
    }
    vlSelf->__Vtrigprevexpr___TOP__tb_cmo_retirement__DOT__clk__0 = 0;
    vlSelf->__Vtrigprevexpr___TOP__tb_cmo_retirement__DOT__rst__0 = 0;
    vlSelf->__Vtrigprevexpr___TOP__tb_cmo_retirement__DOT__dut__DOT__cmo_offer_q__0 = 0;
    for (int __Vi0 = 0; __Vi0 < 1; ++__Vi0) {
        vlSelf->__VnbaTriggered[__Vi0] = 0;
    }
    vlSelf->__Vi = 0;
}
