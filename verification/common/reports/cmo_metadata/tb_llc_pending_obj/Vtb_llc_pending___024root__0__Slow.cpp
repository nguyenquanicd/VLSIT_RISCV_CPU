// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vtb_llc_pending.h for the primary calling header

#include "Vtb_llc_pending__pch.h"

void Vtb_llc_pending___024root___timing_ready(Vtb_llc_pending___024root* vlSelf);

VL_ATTR_COLD void Vtb_llc_pending___024root___eval_static(Vtb_llc_pending___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_llc_pending___024root___eval_static\n"); );
    Vtb_llc_pending__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    {
        // Inlined CFunc: _eval_static__TOP
        vlSelfRef.tb_llc_pending__DOT__clk = 0U;
        vlSelfRef.tb_llc_pending__DOT__rst = 0U;
        vlSelfRef.tb_llc_pending__DOT__iv = 0U;
        vlSelfRef.tb_llc_pending__DOT__orr = 0U;
        vlSelfRef.tb_llc_pending__DOT__commit = 0U;
    }
    vlSelfRef.__VactTriggered[0U] = (8ULL | vlSelfRef.__VactTriggered[0U]);
    vlSelfRef.__VactTriggered[0U] = (0x0000000000000010ULL 
                                     | vlSelfRef.__VactTriggered[0U]);
    vlSelfRef.__Vtrigprevexpr___TOP__tb_llc_pending__DOT__clk__0 = 0U;
    vlSelfRef.__Vtrigprevexpr___TOP__tb_llc_pending__DOT__rst__0 = 0U;
    vlSelfRef.__Vtrigprevexpr___TOP__tb_llc_pending__DOT__dut__DOT__i_tag_pattern_gen__DOT__eoc_q__0 
        = vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_tag_pattern_gen__DOT__eoc_q;
    vlSelfRef.__Vtrigprevexpr_h88bb5eb1__1 = (0U == (IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__pending_valid_q));
    Vtb_llc_pending___024root___timing_ready(vlSelf);
    do {
        vlSelfRef.__VactTriggeredAcc[vlSelfRef.__Vi] 
            = vlSelfRef.__VactTriggered[vlSelfRef.__Vi];
        vlSelfRef.__Vi = ((IData)(1U) + vlSelfRef.__Vi);
    } while ((0U >= vlSelfRef.__Vi));
}

#ifdef VL_DEBUG
VL_ATTR_COLD void Vtb_llc_pending___024root___dump_triggers__stl(const VlUnpacked<QData/*63:0*/, 1> &triggers, const std::string &tag);
#endif  // VL_DEBUG
VL_ATTR_COLD bool Vtb_llc_pending___024root___trigger_anySet__stl(const VlUnpacked<QData/*63:0*/, 1> &in);
VL_ATTR_COLD void Vtb_llc_pending___024root___stl_sequent__TOP__0(Vtb_llc_pending___024root* vlSelf);

VL_ATTR_COLD bool Vtb_llc_pending___024root___eval_stl(Vtb_llc_pending___024root* vlSelf, CData/*0:0*/ firstIteration) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_llc_pending___024root___eval_stl\n"); );
    Vtb_llc_pending__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    CData/*0:0*/ __VstlExecute;
    // Body
    vlSelfRef.__VstlTriggered[0U] = ((0xfffffffffffffffeULL 
                                      & vlSelfRef.__VstlTriggered[0U]) 
                                     | (IData)((IData)(firstIteration)));
#ifdef VL_DEBUG
    if (VL_UNLIKELY(vlSymsp->_vm_contextp__->debug())) {
        Vtb_llc_pending___024root___dump_triggers__stl(vlSelfRef.__VstlTriggered, "stl"s);
    }
#endif
    __VstlExecute = Vtb_llc_pending___024root___trigger_anySet__stl(vlSelfRef.__VstlTriggered);
    if (__VstlExecute) {
        {
            // Inlined CFunc: _eval_body__stl
            if ((1ULL & vlSelfRef.__VstlTriggered[0U])) {
                Vtb_llc_pending___024root___stl_sequent__TOP__0(vlSelf);
            }
        }
    }
    return (__VstlExecute);
}

VL_ATTR_COLD void Vtb_llc_pending___024root___eval_dump_triggers__stl(Vtb_llc_pending___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_llc_pending___024root___eval_dump_triggers__stl\n"); );
    Vtb_llc_pending__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
#ifdef VL_DEBUG
    Vtb_llc_pending___024root___dump_triggers__stl(vlSelfRef.__VstlTriggered, "stl"s);
#endif
}

#ifdef VL_DEBUG
VL_ATTR_COLD void Vtb_llc_pending___024root___dump_triggers__ico(const VlUnpacked<QData/*63:0*/, 1> &triggers, const std::string &tag);
#endif  // VL_DEBUG

VL_ATTR_COLD void Vtb_llc_pending___024root___eval_dump_triggers__ico(Vtb_llc_pending___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_llc_pending___024root___eval_dump_triggers__ico\n"); );
    Vtb_llc_pending__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
#ifdef VL_DEBUG
    Vtb_llc_pending___024root___dump_triggers__ico(vlSelfRef.__VicoTriggered, "ico"s);
#endif
}

#ifdef VL_DEBUG
VL_ATTR_COLD void Vtb_llc_pending___024root___dump_triggers__act(const VlUnpacked<QData/*63:0*/, 1> &triggers, const std::string &tag);
#endif  // VL_DEBUG

VL_ATTR_COLD void Vtb_llc_pending___024root___eval_dump_triggers__act(Vtb_llc_pending___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_llc_pending___024root___eval_dump_triggers__act\n"); );
    Vtb_llc_pending__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
#ifdef VL_DEBUG
    Vtb_llc_pending___024root___dump_triggers__act(vlSelfRef.__VactTriggered, "act"s);
#endif
}

VL_ATTR_COLD void Vtb_llc_pending___024root___eval_dump_triggers__nba(Vtb_llc_pending___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_llc_pending___024root___eval_dump_triggers__nba\n"); );
    Vtb_llc_pending__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
#ifdef VL_DEBUG
    Vtb_llc_pending___024root___dump_triggers__act(vlSelfRef.__VnbaTriggered, "nba"s);
#endif
}

VL_ATTR_COLD void Vtb_llc_pending___024root___eval_dump_triggers__obs(Vtb_llc_pending___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_llc_pending___024root___eval_dump_triggers__obs\n"); );
    Vtb_llc_pending__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
}

VL_ATTR_COLD void Vtb_llc_pending___024root___eval_dump_triggers__react(Vtb_llc_pending___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_llc_pending___024root___eval_dump_triggers__react\n"); );
    Vtb_llc_pending__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
}

VL_ATTR_COLD void Vtb_llc_pending___024root___eval_final(Vtb_llc_pending___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_llc_pending___024root___eval_final\n"); );
    Vtb_llc_pending__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
}

#ifdef VL_DEBUG
VL_ATTR_COLD void Vtb_llc_pending___024root___dump_triggers__stl(const VlUnpacked<QData/*63:0*/, 1> &triggers, const std::string &tag) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_llc_pending___024root___dump_triggers__stl\n"); );
    // Body
    if ((1U & (~ (IData)(Vtb_llc_pending___024root___trigger_anySet__stl(triggers))))) {
        VL_DBG_MSGS("         No '" + tag + "' region triggers active\n");
    }
    if ((1U & (IData)(triggers[0U]))) {
        VL_DBG_MSGS("         '" + tag + "' region trigger index 0 is active: Internal 'stl' trigger - first iteration\n");
    }
}
#endif  // VL_DEBUG

VL_ATTR_COLD bool Vtb_llc_pending___024root___trigger_anySet__stl(const VlUnpacked<QData/*63:0*/, 1> &in) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_llc_pending___024root___trigger_anySet__stl\n"); );
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
extern const VlUnpacked<CData/*0:0*/, 8> Vtb_llc_pending__ConstPool__TABLE_hdb06591d_0;

VL_ATTR_COLD void Vtb_llc_pending___024root___stl_sequent__TOP__0(Vtb_llc_pending___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_llc_pending___024root___stl_sequent__TOP__0\n"); );
    Vtb_llc_pending__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    vlSelfRef.tb_llc_pending__DOT__dut__DOT__busy_d 
        = (1U & (~ (IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__busy_q)));
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0 = (1U 
                                                & (~ 
                                                   ((IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_tag_pattern_gen__DOT__bist_q) 
                                                    >> 3U)));
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_2 = (1U 
                                                & (~ (IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_tag_pattern_gen__DOT__bist_q)));
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_3 = (1U 
                                                & (~ 
                                                   ((IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_tag_pattern_gen__DOT__i_index_cnt__DOT__i_counter__DOT__counter_q) 
                                                    >> 3U)));
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_20 = (IData)(
                                                        (6U 
                                                         == 
                                                         (7U 
                                                          & (IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_tag_pattern_gen__DOT__bist_q))));
    vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__a_drain 
        = ((~ (IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__b_full_q)) 
           & (IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__a_full_q));
    vlSelfRef.tb_llc_pending__DOT__dut__DOT__bist_valid 
        = ((IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__busy_q) 
           & ((~ vlSelfRef.tb_llc_pending__DOT__dut__DOT__req_q[2U]) 
              & ((~ (vlSelfRef.tb_llc_pending__DOT__dut__DOT__req_q[2U] 
                     >> 1U)) & (IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__ram_rvalid))));
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
    vlSelfRef.tb_llc_pending__DOT__dut__DOT__res_ready 
        = (1U & (~ ((IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__a_full_q) 
                    & (IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__b_full_q))));
    vlSelfRef.tb_llc_pending__DOT__dut__DOT__pending_full 
        = (1U & ((IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__pending_valid_q) 
                 >> (IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__pending_write_q)));
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_10 = (1U 
                                                 & (((IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__pending_valid_q) 
                                                     & (IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__pending_done_q)) 
                                                    >> (IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__pending_read_q)));
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_9 = ((IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__maint_pending_q) 
                                                & (IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__maint_result_q));
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
    vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__b_fill 
        = ((~ (IData)(vlSelfRef.tb_llc_pending__DOT__orr)) 
           & (IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__a_drain));
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_7 = ((~ (IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__bist_valid)) 
                                                & ((IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__i_tag_pattern_gen__DOT__i_index_cnt__DOT__i_counter__DOT__counter_q) 
                                                   >> 3U));
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
    vlSelfRef.tb_llc_pending__DOT__dut__DOT__maint_finish 
        = ((~ (IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__busy_q)) 
           & (IData)(vlSelfRef.__VdfgRegularize_h6e95ff9d_0_9));
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
    vlSelfRef.tb_llc_pending__DOT__dut__DOT__pending_pop 
        = (((~ (IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__busy_q)) 
            | ((IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__pending_full) 
               & (2U == vlSelfRef.tb_llc_pending__DOT__dut__DOT__req_q[2U]))) 
           & ((~ (IData)(vlSelfRef.tb_llc_pending__DOT__dut__DOT__maint_finish)) 
              & (IData)(vlSelfRef.__VdfgRegularize_h6e95ff9d_0_10)));
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

bool Vtb_llc_pending___024root___trigger_anySet__ico(const VlUnpacked<QData/*63:0*/, 1> &in);

#ifdef VL_DEBUG
VL_ATTR_COLD void Vtb_llc_pending___024root___dump_triggers__ico(const VlUnpacked<QData/*63:0*/, 1> &triggers, const std::string &tag) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_llc_pending___024root___dump_triggers__ico\n"); );
    // Body
    if ((1U & (~ (IData)(Vtb_llc_pending___024root___trigger_anySet__ico(triggers))))) {
        VL_DBG_MSGS("         No '" + tag + "' region triggers active\n");
    }
    if ((1U & (IData)(triggers[0U]))) {
        VL_DBG_MSGS("         '" + tag + "' region trigger index 0 is active: Internal 'ico' trigger - first iteration\n");
    }
}
#endif  // VL_DEBUG

bool Vtb_llc_pending___024root___trigger_anySet__act(const VlUnpacked<QData/*63:0*/, 1> &in);

#ifdef VL_DEBUG
VL_ATTR_COLD void Vtb_llc_pending___024root___dump_triggers__act(const VlUnpacked<QData/*63:0*/, 1> &triggers, const std::string &tag) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_llc_pending___024root___dump_triggers__act\n"); );
    // Body
    if ((1U & (~ (IData)(Vtb_llc_pending___024root___trigger_anySet__act(triggers))))) {
        VL_DBG_MSGS("         No '" + tag + "' region triggers active\n");
    }
    if ((1U & (IData)(triggers[0U]))) {
        VL_DBG_MSGS("         '" + tag + "' region trigger index 0 is active: @(posedge tb_llc_pending.clk)\n");
    }
    if ((1U & (IData)((triggers[0U] >> 1U)))) {
        VL_DBG_MSGS("         '" + tag + "' region trigger index 1 is active: @(negedge tb_llc_pending.rst)\n");
    }
    if ((1U & (IData)((triggers[0U] >> 2U)))) {
        VL_DBG_MSGS("         '" + tag + "' region trigger index 2 is active: @(negedge tb_llc_pending.clk)\n");
    }
    if ((1U & (IData)((triggers[0U] >> 3U)))) {
        VL_DBG_MSGS("         '" + tag + "' region trigger index 3 is active: @( tb_llc_pending.dut.i_tag_pattern_gen.eoc_q)\n");
    }
    if ((1U & (IData)((triggers[0U] >> 4U)))) {
        VL_DBG_MSGS("         '" + tag + "' region trigger index 4 is active: @( (4'h0 == tb_llc_pending.dut.pending_valid_q))\n");
    }
    if ((1U & (IData)((triggers[0U] >> 5U)))) {
        VL_DBG_MSGS("         '" + tag + "' region trigger index 5 is active: @([true] __VdlySched.awaitingCurrentTime())\n");
    }
}
#endif  // VL_DEBUG

VL_ATTR_COLD void Vtb_llc_pending___024root___ctor_var_reset(Vtb_llc_pending___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_llc_pending___024root___ctor_var_reset\n"); );
    Vtb_llc_pending__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    const uint64_t __VscopeHash = VL_MURMUR64_HASH(vlSelf->vlNamep);
    vlSelf->tb_llc_pending__DOT__ir = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 1358964128204049450ull);
    VL_SCOPED_RAND_RESET_W(66, vlSelf->tb_llc_pending__DOT__req, __VscopeHash, 15808294553108734037ull);
    vlSelf->tb_llc_pending__DOT__unnamedblk2__DOT__unnamedblk3__DOT__k = 0;
    vlSelf->tb_llc_pending__DOT__unnamedblk2__DOT__unnamedblk4__DOT__k = 0;
    vlSelf->tb_llc_pending__DOT__unnamedblk2__DOT__unnamedblk5__DOT__k = 0;
    vlSelf->tb_llc_pending__DOT__unnamedblk2__DOT__unnamedblk6__DOT__k = 0;
    vlSelf->tb_llc_pending__DOT__dut__DOT__busy_q = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 13827201355050982212ull);
    vlSelf->tb_llc_pending__DOT__dut__DOT__busy_d = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 6706857414135002385ull);
    vlSelf->tb_llc_pending__DOT__dut__DOT__switch_busy = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 187244203513273877ull);
    VL_SCOPED_RAND_RESET_W(66, vlSelf->tb_llc_pending__DOT__dut__DOT__req_q, __VscopeHash, 15073872986163821956ull);
    vlSelf->tb_llc_pending__DOT__dut__DOT__load_req = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 4085686822918592330ull);
    vlSelf->tb_llc_pending__DOT__dut__DOT__ram_req = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 1427001937280609191ull);
    vlSelf->tb_llc_pending__DOT__dut__DOT__ram_we = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 12435246472646620135ull);
    vlSelf->tb_llc_pending__DOT__dut__DOT__ram_index = VL_SCOPED_RAND_RESET_I(3, __VscopeHash, 9594393722543428179ull);
    vlSelf->tb_llc_pending__DOT__dut__DOT__ram_wdata = VL_SCOPED_RAND_RESET_Q(59, __VscopeHash, 8205189094755940902ull);
    vlSelf->tb_llc_pending__DOT__dut__DOT__ram_rvalid = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 13179278230974500332ull);
    vlSelf->tb_llc_pending__DOT__dut__DOT__ram_rvalid_q = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 15101410446306043762ull);
    vlSelf->tb_llc_pending__DOT__dut__DOT__hit = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 12859429029576982402ull);
    vlSelf->tb_llc_pending__DOT__dut__DOT__gen_valid = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 2051395613590009881ull);
    vlSelf->tb_llc_pending__DOT__dut__DOT__gen_pattern = VL_SCOPED_RAND_RESET_Q(59, __VscopeHash, 10069451931835543349ull);
    vlSelf->tb_llc_pending__DOT__dut__DOT__bist_pattern = VL_SCOPED_RAND_RESET_Q(59, __VscopeHash, 4825062399322636428ull);
    vlSelf->tb_llc_pending__DOT__dut__DOT__bist_valid = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 16530451911897788721ull);
    vlSelf->tb_llc_pending__DOT__dut__DOT__res = VL_SCOPED_RAND_RESET_Q(60, __VscopeHash, 9175984043760525553ull);
    vlSelf->tb_llc_pending__DOT__dut__DOT__res_valid = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 9075433264442887076ull);
    vlSelf->tb_llc_pending__DOT__dut__DOT__res_ready = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 17391231426276073625ull);
    vlSelf->tb_llc_pending__DOT__dut__DOT__flush_wait_q = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 409287374812626908ull);
    vlSelf->tb_llc_pending__DOT__dut__DOT__pending_valid_q = VL_SCOPED_RAND_RESET_I(4, __VscopeHash, 1351261119734427355ull);
    vlSelf->tb_llc_pending__DOT__dut__DOT__pending_done_q = VL_SCOPED_RAND_RESET_I(4, __VscopeHash, 16202913857383019611ull);
    for (int __Vi0 = 0; __Vi0 < 4; ++__Vi0) {
        vlSelf->tb_llc_pending__DOT__dut__DOT__pending_index_q[__Vi0] = VL_SCOPED_RAND_RESET_I(3, __VscopeHash, 8132691048728487848ull);
    }
    for (int __Vi0 = 0; __Vi0 < 4; ++__Vi0) {
        vlSelf->tb_llc_pending__DOT__dut__DOT__pending_way_q[__Vi0] = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 3114070999325346462ull);
    }
    for (int __Vi0 = 0; __Vi0 < 4; ++__Vi0) {
        vlSelf->tb_llc_pending__DOT__dut__DOT__pending_tag_q[__Vi0] = VL_SCOPED_RAND_RESET_Q(59, __VscopeHash, 18094308399586359230ull);
    }
    vlSelf->tb_llc_pending__DOT__dut__DOT__pending_write_q = VL_SCOPED_RAND_RESET_I(2, __VscopeHash, 15188750102194038789ull);
    vlSelf->tb_llc_pending__DOT__dut__DOT__pending_ack_q = VL_SCOPED_RAND_RESET_I(2, __VscopeHash, 8623504220910958025ull);
    vlSelf->tb_llc_pending__DOT__dut__DOT__pending_read_q = VL_SCOPED_RAND_RESET_I(2, __VscopeHash, 3365895384184617830ull);
    vlSelf->tb_llc_pending__DOT__dut__DOT__pending_full = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 5708999979478808934ull);
    vlSelf->tb_llc_pending__DOT__dut__DOT__pending_push = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 17131285591877202041ull);
    vlSelf->tb_llc_pending__DOT__dut__DOT__pending_pop = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 13770468226490660433ull);
    vlSelf->tb_llc_pending__DOT__dut__DOT__maint_pending_q = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 7537841786911990968ull);
    vlSelf->tb_llc_pending__DOT__dut__DOT__maint_result_q = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 15276412256061831576ull);
    vlSelf->tb_llc_pending__DOT__dut__DOT__maint_error_q = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 6370009773145486933ull);
    vlSelf->tb_llc_pending__DOT__dut__DOT__maint_index_q = VL_SCOPED_RAND_RESET_I(3, __VscopeHash, 14634975881395095191ull);
    vlSelf->tb_llc_pending__DOT__dut__DOT__maint_way_q = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 1313378536610833546ull);
    vlSelf->tb_llc_pending__DOT__dut__DOT__maint_tag_q = VL_SCOPED_RAND_RESET_Q(59, __VscopeHash, 453816008727179723ull);
    vlSelf->tb_llc_pending__DOT__dut__DOT__maint_op_q = VL_SCOPED_RAND_RESET_I(2, __VscopeHash, 9029859847842917180ull);
    vlSelf->tb_llc_pending__DOT__dut__DOT__maint_finish = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 17877105153618666119ull);
    vlSelf->tb_llc_pending__DOT__dut__DOT____Vcellinp__gen_tag_macros__BRA__0__KET____DOT__i_shift_reg_rvalid__d_i = 0;
    vlSelf->tb_llc_pending__DOT__dut__DOT__i_tag_pattern_gen__DOT__busy_q = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 12541085203835873106ull);
    vlSelf->tb_llc_pending__DOT__dut__DOT__i_tag_pattern_gen__DOT__eoc_q = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 7166973616079186247ull);
    vlSelf->tb_llc_pending__DOT__dut__DOT__i_tag_pattern_gen__DOT__bist_q = VL_SCOPED_RAND_RESET_I(4, __VscopeHash, 5390621696286237615ull);
    vlSelf->tb_llc_pending__DOT__dut__DOT__i_tag_pattern_gen__DOT__en_cnt = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 10916916617975190061ull);
    vlSelf->tb_llc_pending__DOT__dut__DOT__i_tag_pattern_gen__DOT__i_index_cnt__DOT__i_counter__DOT__counter_q = VL_SCOPED_RAND_RESET_I(4, __VscopeHash, 12825180164241628029ull);
    vlSelf->tb_llc_pending__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__a_data_q = VL_SCOPED_RAND_RESET_Q(60, __VscopeHash, 434948903778966540ull);
    vlSelf->tb_llc_pending__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__a_full_q = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 12484106886730519569ull);
    vlSelf->tb_llc_pending__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__a_fill = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 8342682675857968017ull);
    vlSelf->tb_llc_pending__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__a_drain = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 1978116090837831828ull);
    vlSelf->tb_llc_pending__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__b_data_q = VL_SCOPED_RAND_RESET_Q(60, __VscopeHash, 7919495698495871940ull);
    vlSelf->tb_llc_pending__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__b_full_q = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 13514096228115083258ull);
    vlSelf->tb_llc_pending__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__b_fill = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 5893554513940965688ull);
    for (int __Vi0 = 0; __Vi0 < 8; ++__Vi0) {
        vlSelf->tb_llc_pending__DOT__dut__DOT__gen_tag_macros__BRA__0__KET____DOT__i_tag_store__DOT__sram[__Vi0] = VL_SCOPED_RAND_RESET_Q(59, __VscopeHash, 15546522561213689470ull);
    }
    vlSelf->tb_llc_pending__DOT__dut__DOT__gen_tag_macros__BRA__0__KET____DOT__i_tag_store__DOT__r_addr_q = VL_SCOPED_RAND_RESET_I(3, __VscopeHash, 1146055995206123972ull);
    vlSelf->tb_llc_pending__DOT__dut__DOT__gen_tag_macros__BRA__0__KET____DOT__i_tag_store__DOT__rdata_q = VL_SCOPED_RAND_RESET_Q(59, __VscopeHash, 4800524120236221590ull);
    vlSelf->__VdfgRegularize_h6e95ff9d_0_0 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_2 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_3 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_4 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_7 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_9 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_10 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_17 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_19 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_20 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_21 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_22 = 0;
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
    vlSelf->__Vtrigprevexpr___TOP__tb_llc_pending__DOT__clk__0 = 0;
    vlSelf->__Vtrigprevexpr___TOP__tb_llc_pending__DOT__rst__0 = 0;
    vlSelf->__Vtrigprevexpr___TOP__tb_llc_pending__DOT__dut__DOT__i_tag_pattern_gen__DOT__eoc_q__0 = 0;
    vlSelf->__Vtrigprevexpr_h88bb5eb1__1 = 0;
    for (int __Vi0 = 0; __Vi0 < 1; ++__Vi0) {
        vlSelf->__VnbaTriggered[__Vi0] = 0;
    }
    vlSelf->__Vi = 0;
}
