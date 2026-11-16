// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vtb_llc_flush_tag.h for the primary calling header

#include "Vtb_llc_flush_tag__pch.h"

void Vtb_llc_flush_tag___024root___timing_ready(Vtb_llc_flush_tag___024root* vlSelf);

VL_ATTR_COLD void Vtb_llc_flush_tag___024root___eval_static(Vtb_llc_flush_tag___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_llc_flush_tag___024root___eval_static\n"); );
    Vtb_llc_flush_tag__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    {
        // Inlined CFunc: _eval_static__TOP
        vlSelfRef.tb_llc_flush_tag__DOT__clk = 0U;
        vlSelfRef.tb_llc_flush_tag__DOT__rst = 0U;
        vlSelfRef.tb_llc_flush_tag__DOT__iv = 0U;
        vlSelfRef.tb_llc_flush_tag__DOT__orr = 0U;
        vlSelfRef.tb_llc_flush_tag__DOT__flush_mode = 0U;
        vlSelfRef.tb_llc_flush_tag__DOT__bv = 0U;
        vlSelfRef.tb_llc_flush_tag__DOT__way_rsp_valid = 0U;
        vlSelfRef.tb_llc_flush_tag__DOT__req_tag = 0x0000000000000123ULL;
        vlSelfRef.tb_llc_flush_tag__DOT__req_index = 0U;
        vlSelfRef.tb_llc_flush_tag__DOT__beats = 0U;
    }
    vlSelfRef.__VactTriggered[0U] = (8ULL | vlSelfRef.__VactTriggered[0U]);
    vlSelfRef.__VactTriggered[0U] = (0x0000000000000010ULL 
                                     | vlSelfRef.__VactTriggered[0U]);
    vlSelfRef.__VactTriggered[0U] = (0x0000000000000040ULL 
                                     | vlSelfRef.__VactTriggered[0U]);
    vlSelfRef.__Vtrigprevexpr___TOP__tb_llc_flush_tag__DOT__clk__0 = 0U;
    vlSelfRef.__Vtrigprevexpr___TOP__tb_llc_flush_tag__DOT__rst__0 = 0U;
    vlSelfRef.__Vtrigprevexpr___TOP__tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__eoc_q__0 
        = vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__eoc_q;
    vlSelfRef.__Vtrigprevexpr_h4d792359__1 = 0U;
    vlSelfRef.__Vtrigprevexpr_h4d7acfdc__1 = 0U;
    Vtb_llc_flush_tag___024root___timing_ready(vlSelf);
    do {
        vlSelfRef.__VactTriggeredAcc[vlSelfRef.__Vi] 
            = vlSelfRef.__VactTriggered[vlSelfRef.__Vi];
        vlSelfRef.__Vi = ((IData)(1U) + vlSelfRef.__Vi);
    } while ((0U >= vlSelfRef.__Vi));
}

#ifdef VL_DEBUG
VL_ATTR_COLD void Vtb_llc_flush_tag___024root___dump_triggers__stl(const VlUnpacked<QData/*63:0*/, 1> &triggers, const std::string &tag);
#endif  // VL_DEBUG
VL_ATTR_COLD bool Vtb_llc_flush_tag___024root___trigger_anySet__stl(const VlUnpacked<QData/*63:0*/, 1> &in);
VL_ATTR_COLD void Vtb_llc_flush_tag___024root___stl_sequent__TOP__0(Vtb_llc_flush_tag___024root* vlSelf);

VL_ATTR_COLD bool Vtb_llc_flush_tag___024root___eval_stl(Vtb_llc_flush_tag___024root* vlSelf, CData/*0:0*/ firstIteration) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_llc_flush_tag___024root___eval_stl\n"); );
    Vtb_llc_flush_tag__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    CData/*0:0*/ __VstlExecute;
    // Body
    vlSelfRef.__VstlTriggered[0U] = ((0xfffffffffffffffeULL 
                                      & vlSelfRef.__VstlTriggered[0U]) 
                                     | (IData)((IData)(firstIteration)));
#ifdef VL_DEBUG
    if (VL_UNLIKELY(vlSymsp->_vm_contextp__->debug())) {
        Vtb_llc_flush_tag___024root___dump_triggers__stl(vlSelfRef.__VstlTriggered, "stl"s);
    }
#endif
    __VstlExecute = Vtb_llc_flush_tag___024root___trigger_anySet__stl(vlSelfRef.__VstlTriggered);
    if (__VstlExecute) {
        {
            // Inlined CFunc: _eval_body__stl
            if ((1ULL & vlSelfRef.__VstlTriggered[0U])) {
                Vtb_llc_flush_tag___024root___stl_sequent__TOP__0(vlSelf);
            }
        }
    }
    return (__VstlExecute);
}

VL_ATTR_COLD void Vtb_llc_flush_tag___024root___eval_dump_triggers__stl(Vtb_llc_flush_tag___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_llc_flush_tag___024root___eval_dump_triggers__stl\n"); );
    Vtb_llc_flush_tag__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
#ifdef VL_DEBUG
    Vtb_llc_flush_tag___024root___dump_triggers__stl(vlSelfRef.__VstlTriggered, "stl"s);
#endif
}

#ifdef VL_DEBUG
VL_ATTR_COLD void Vtb_llc_flush_tag___024root___dump_triggers__ico(const VlUnpacked<QData/*63:0*/, 1> &triggers, const std::string &tag);
#endif  // VL_DEBUG

VL_ATTR_COLD void Vtb_llc_flush_tag___024root___eval_dump_triggers__ico(Vtb_llc_flush_tag___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_llc_flush_tag___024root___eval_dump_triggers__ico\n"); );
    Vtb_llc_flush_tag__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
#ifdef VL_DEBUG
    Vtb_llc_flush_tag___024root___dump_triggers__ico(vlSelfRef.__VicoTriggered, "ico"s);
#endif
}

#ifdef VL_DEBUG
VL_ATTR_COLD void Vtb_llc_flush_tag___024root___dump_triggers__act(const VlUnpacked<QData/*63:0*/, 1> &triggers, const std::string &tag);
#endif  // VL_DEBUG

VL_ATTR_COLD void Vtb_llc_flush_tag___024root___eval_dump_triggers__act(Vtb_llc_flush_tag___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_llc_flush_tag___024root___eval_dump_triggers__act\n"); );
    Vtb_llc_flush_tag__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
#ifdef VL_DEBUG
    Vtb_llc_flush_tag___024root___dump_triggers__act(vlSelfRef.__VactTriggered, "act"s);
#endif
}

VL_ATTR_COLD void Vtb_llc_flush_tag___024root___eval_dump_triggers__nba(Vtb_llc_flush_tag___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_llc_flush_tag___024root___eval_dump_triggers__nba\n"); );
    Vtb_llc_flush_tag__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
#ifdef VL_DEBUG
    Vtb_llc_flush_tag___024root___dump_triggers__act(vlSelfRef.__VnbaTriggered, "nba"s);
#endif
}

VL_ATTR_COLD void Vtb_llc_flush_tag___024root___eval_dump_triggers__obs(Vtb_llc_flush_tag___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_llc_flush_tag___024root___eval_dump_triggers__obs\n"); );
    Vtb_llc_flush_tag__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
}

VL_ATTR_COLD void Vtb_llc_flush_tag___024root___eval_dump_triggers__react(Vtb_llc_flush_tag___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_llc_flush_tag___024root___eval_dump_triggers__react\n"); );
    Vtb_llc_flush_tag__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
}

VL_ATTR_COLD void Vtb_llc_flush_tag___024root___eval_final(Vtb_llc_flush_tag___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_llc_flush_tag___024root___eval_final\n"); );
    Vtb_llc_flush_tag__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
}

#ifdef VL_DEBUG
VL_ATTR_COLD void Vtb_llc_flush_tag___024root___dump_triggers__stl(const VlUnpacked<QData/*63:0*/, 1> &triggers, const std::string &tag) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_llc_flush_tag___024root___dump_triggers__stl\n"); );
    // Body
    if ((1U & (~ (IData)(Vtb_llc_flush_tag___024root___trigger_anySet__stl(triggers))))) {
        VL_DBG_MSGS("         No '" + tag + "' region triggers active\n");
    }
    if ((1U & (IData)(triggers[0U]))) {
        VL_DBG_MSGS("         '" + tag + "' region trigger index 0 is active: Internal 'stl' trigger - first iteration\n");
    }
}
#endif  // VL_DEBUG

VL_ATTR_COLD bool Vtb_llc_flush_tag___024root___trigger_anySet__stl(const VlUnpacked<QData/*63:0*/, 1> &in) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_llc_flush_tag___024root___trigger_anySet__stl\n"); );
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
extern const VlUnpacked<CData/*0:0*/, 8> Vtb_llc_flush_tag__ConstPool__TABLE_hdb06591d_0;

VL_ATTR_COLD void Vtb_llc_flush_tag___024root___stl_sequent__TOP__0(Vtb_llc_flush_tag___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_llc_flush_tag___024root___stl_sequent__TOP__0\n"); );
    Vtb_llc_flush_tag__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    CData/*0:0*/ __VdfgRegularize_h6e95ff9d_0_30;
    __VdfgRegularize_h6e95ff9d_0_30 = 0;
    // Body
    vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__busy_d 
        = (1U & (~ (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__busy_q)));
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0 = (1U 
                                                & (~ 
                                                   ((IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__bist_q) 
                                                    >> 3U)));
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_1 = (1U 
                                                & (~ 
                                                   ((IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__i_index_cnt__DOT__i_counter__DOT__counter_q) 
                                                    >> 1U)));
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_3 = (1U 
                                                & (~ (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__bist_q)));
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_32 = (IData)(
                                                        (6U 
                                                         == 
                                                         (7U 
                                                          & (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__bist_q))));
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_27 = (1U 
                                                 & (~ 
                                                    ((IData)(vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__send_q) 
                                                     | ((IData)(vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__i_block_offset_counter__DOT__i_counter__DOT__counter_q) 
                                                        >> 1U))));
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_29 = ((~ (IData)(vlSelfRef.tb_llc_flush_tag__DOT__bv)) 
                                                 & (IData)(vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__busy_q));
    vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__a_drain 
        = ((~ (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__b_full_q)) 
           & (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__a_full_q));
    vlSelfRef.tb_llc_flush_tag__DOT__rsp = ((IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__b_full_q)
                                             ? vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__b_data_q
                                             : vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__a_data_q);
    vlSelfRef.tb_llc_flush_tag__DOT____Vcellinp__writer__desc_valid_i 
        = (((IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__a_full_q) 
            | (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__b_full_q)) 
           & ((IData)(vlSelfRef.tb_llc_flush_tag__DOT__orr) 
              & (IData)(vlSelfRef.tb_llc_flush_tag__DOT__flush_mode)));
    vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__bist_valid 
        = ((IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__busy_q) 
           & ((~ vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__req_q[2U]) 
              & ((~ (vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__req_q[2U] 
                     >> 1U)) & (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__ram_rvalid))));
    vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__fifo_push 
        = ((2U != (IData)(vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__i_r_data_fifo__DOT__status_cnt_q)) 
           & (IData)(vlSelfRef.tb_llc_flush_tag__DOT__way_rsp_valid));
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
    vlSelfRef.tb_llc_flush_tag__DOT__commit = ((((IData)(vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__send_q) 
                                                 & (~ (IData)(vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__wb_failed_q))) 
                                                & (~ (IData)(vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__busy_q))) 
                                               & (0x10U 
                                                  == 
                                                  (0x18U 
                                                   & vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__desc_q[2U])));
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_34 = (1U 
                                                 & ((~ 
                                                     ((IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__bist_q) 
                                                      >> 1U)) 
                                                    & (~ 
                                                       ((IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__i_index_cnt__DOT__i_counter__DOT__counter_q) 
                                                        >> 1U))));
    vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__res_ready 
        = (1U & (~ ((IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__a_full_q) 
                    & (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__b_full_q))));
    vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__pending_full 
        = (1U & ((IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__pending_valid_q) 
                 >> (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__pending_write_q)));
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_14 = (1U 
                                                 & (((IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__pending_valid_q) 
                                                     & (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__pending_done_q)) 
                                                    >> (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__pending_read_q)));
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_13 = ((IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__maint_pending_q) 
                                                 & (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__maint_result_q));
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
    vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__b_fill 
        = ((~ (IData)(vlSelfRef.tb_llc_flush_tag__DOT__orr)) 
           & (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__a_drain));
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
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_35 = ((~ (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__bist_valid)) 
                                                 & ((IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__i_index_cnt__DOT__i_counter__DOT__counter_q) 
                                                    >> 1U));
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
    vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__en_cnt 
        = ((IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__busy_q) 
           & ((~ ((IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__bist_q) 
                  >> 3U)) & ((4U & (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__bist_q))
                              ? (IData)(vlSelfRef.__VdfgRegularize_h6e95ff9d_0_34)
                              : (~ ((IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__i_index_cnt__DOT__i_counter__DOT__counter_q) 
                                    >> 1U)))));
    vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__maint_finish 
        = ((~ (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__busy_q)) 
           & (IData)(vlSelfRef.__VdfgRegularize_h6e95ff9d_0_13));
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
    vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__pending_pop 
        = (((~ (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__busy_q)) 
            | ((IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__pending_full) 
               & (2U == vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__req_q[2U]))) 
           & ((~ (IData)(vlSelfRef.tb_llc_flush_tag__DOT__dut__DOT__maint_finish)) 
              & (IData)(vlSelfRef.__VdfgRegularize_h6e95ff9d_0_14)));
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
    vlSelfRef.tb_llc_flush_tag__DOT__br = ((IData)(vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__busy_q) 
                                           & ((IData)(vlSelfRef.tb_llc_flush_tag__DOT__writer__DOT__send_q) 
                                              | (IData)(vlSelfRef.__VdfgRegularize_h6e95ff9d_0_11)));
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

bool Vtb_llc_flush_tag___024root___trigger_anySet__ico(const VlUnpacked<QData/*63:0*/, 1> &in);

#ifdef VL_DEBUG
VL_ATTR_COLD void Vtb_llc_flush_tag___024root___dump_triggers__ico(const VlUnpacked<QData/*63:0*/, 1> &triggers, const std::string &tag) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_llc_flush_tag___024root___dump_triggers__ico\n"); );
    // Body
    if ((1U & (~ (IData)(Vtb_llc_flush_tag___024root___trigger_anySet__ico(triggers))))) {
        VL_DBG_MSGS("         No '" + tag + "' region triggers active\n");
    }
    if ((1U & (IData)(triggers[0U]))) {
        VL_DBG_MSGS("         '" + tag + "' region trigger index 0 is active: Internal 'ico' trigger - first iteration\n");
    }
}
#endif  // VL_DEBUG

bool Vtb_llc_flush_tag___024root___trigger_anySet__act(const VlUnpacked<QData/*63:0*/, 1> &in);

#ifdef VL_DEBUG
VL_ATTR_COLD void Vtb_llc_flush_tag___024root___dump_triggers__act(const VlUnpacked<QData/*63:0*/, 1> &triggers, const std::string &tag) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_llc_flush_tag___024root___dump_triggers__act\n"); );
    // Body
    if ((1U & (~ (IData)(Vtb_llc_flush_tag___024root___trigger_anySet__act(triggers))))) {
        VL_DBG_MSGS("         No '" + tag + "' region triggers active\n");
    }
    if ((1U & (IData)(triggers[0U]))) {
        VL_DBG_MSGS("         '" + tag + "' region trigger index 0 is active: @(posedge tb_llc_flush_tag.clk)\n");
    }
    if ((1U & (IData)((triggers[0U] >> 1U)))) {
        VL_DBG_MSGS("         '" + tag + "' region trigger index 1 is active: @(negedge tb_llc_flush_tag.rst)\n");
    }
    if ((1U & (IData)((triggers[0U] >> 2U)))) {
        VL_DBG_MSGS("         '" + tag + "' region trigger index 2 is active: @(negedge tb_llc_flush_tag.clk)\n");
    }
    if ((1U & (IData)((triggers[0U] >> 3U)))) {
        VL_DBG_MSGS("         '" + tag + "' region trigger index 3 is active: @( tb_llc_flush_tag.dut.i_tag_pattern_gen.eoc_q)\n");
    }
    if ((1U & (IData)((triggers[0U] >> 4U)))) {
        VL_DBG_MSGS("         '" + tag + "' region trigger index 4 is active: @( (32'sh2 == tb_llc_flush_tag.beats))\n");
    }
    if ((1U & (IData)((triggers[0U] >> 5U)))) {
        VL_DBG_MSGS("         '" + tag + "' region trigger index 5 is active: @([true] __VdlySched.awaitingCurrentTime())\n");
    }
    if ((1U & (IData)((triggers[0U] >> 6U)))) {
        VL_DBG_MSGS("         '" + tag + "' region trigger index 6 is active: @( (32'sh4 == tb_llc_flush_tag.beats))\n");
    }
}
#endif  // VL_DEBUG

VL_ATTR_COLD void Vtb_llc_flush_tag___024root___ctor_var_reset(Vtb_llc_flush_tag___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_llc_flush_tag___024root___ctor_var_reset\n"); );
    Vtb_llc_flush_tag__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    const uint64_t __VscopeHash = VL_MURMUR64_HASH(vlSelf->vlNamep);
    vlSelf->tb_llc_flush_tag__DOT__ir = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 953562126746590237ull);
    vlSelf->tb_llc_flush_tag__DOT__commit = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 2411983972419411604ull);
    VL_SCOPED_RAND_RESET_W(66, vlSelf->tb_llc_flush_tag__DOT__req, __VscopeHash, 4668482513454322905ull);
    vlSelf->tb_llc_flush_tag__DOT__rsp = VL_SCOPED_RAND_RESET_Q(62, __VscopeHash, 16824548092991507279ull);
    VL_SCOPED_RAND_RESET_W(73, vlSelf->tb_llc_flush_tag__DOT__w, __VscopeHash, 11694652144590185197ull);
    vlSelf->tb_llc_flush_tag__DOT__b = VL_SCOPED_RAND_RESET_I(2, __VscopeHash, 10601661734137279003ull);
    vlSelf->tb_llc_flush_tag__DOT__br = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 17563543554010350942ull);
    vlSelf->tb_llc_flush_tag__DOT__wb_commit = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 9945041121650891930ull);
    vlSelf->tb_llc_flush_tag__DOT__wb_error = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 15168408526295908912ull);
    vlSelf->tb_llc_flush_tag__DOT____Vcellinp__writer__desc_valid_i = 0;
    vlSelf->tb_llc_flush_tag__DOT__dut__DOT__busy_q = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 16947863982531713761ull);
    vlSelf->tb_llc_flush_tag__DOT__dut__DOT__busy_d = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 8994302742367797312ull);
    vlSelf->tb_llc_flush_tag__DOT__dut__DOT__switch_busy = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 3526606184127479684ull);
    VL_SCOPED_RAND_RESET_W(66, vlSelf->tb_llc_flush_tag__DOT__dut__DOT__req_q, __VscopeHash, 138569197174975296ull);
    vlSelf->tb_llc_flush_tag__DOT__dut__DOT__load_req = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 2970717136721821070ull);
    vlSelf->tb_llc_flush_tag__DOT__dut__DOT__ram_req = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 17364525148330338110ull);
    vlSelf->tb_llc_flush_tag__DOT__dut__DOT__ram_we = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 3439119898874503297ull);
    vlSelf->tb_llc_flush_tag__DOT__dut__DOT__ram_index = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 11758041752006042506ull);
    vlSelf->tb_llc_flush_tag__DOT__dut__DOT__ram_wdata = VL_SCOPED_RAND_RESET_Q(61, __VscopeHash, 2764744335717851832ull);
    vlSelf->tb_llc_flush_tag__DOT__dut__DOT__ram_rvalid = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 10966826630776663823ull);
    vlSelf->tb_llc_flush_tag__DOT__dut__DOT__ram_rvalid_q = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 5237603968107636292ull);
    vlSelf->tb_llc_flush_tag__DOT__dut__DOT__hit = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 2690125728601837592ull);
    vlSelf->tb_llc_flush_tag__DOT__dut__DOT__gen_valid = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 16016144721486292021ull);
    vlSelf->tb_llc_flush_tag__DOT__dut__DOT__gen_pattern = VL_SCOPED_RAND_RESET_Q(61, __VscopeHash, 1687601185687836943ull);
    vlSelf->tb_llc_flush_tag__DOT__dut__DOT__bist_pattern = VL_SCOPED_RAND_RESET_Q(61, __VscopeHash, 3615164261621679852ull);
    vlSelf->tb_llc_flush_tag__DOT__dut__DOT__bist_valid = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 13438062219849139747ull);
    vlSelf->tb_llc_flush_tag__DOT__dut__DOT__res = VL_SCOPED_RAND_RESET_Q(62, __VscopeHash, 15130302488238432752ull);
    vlSelf->tb_llc_flush_tag__DOT__dut__DOT__res_valid = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 16656198528609850094ull);
    vlSelf->tb_llc_flush_tag__DOT__dut__DOT__res_ready = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 17210425684474529801ull);
    vlSelf->tb_llc_flush_tag__DOT__dut__DOT__flush_wait_q = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 9200142732654940623ull);
    vlSelf->tb_llc_flush_tag__DOT__dut__DOT__pending_valid_q = VL_SCOPED_RAND_RESET_I(4, __VscopeHash, 6338411972643841538ull);
    vlSelf->tb_llc_flush_tag__DOT__dut__DOT__pending_done_q = VL_SCOPED_RAND_RESET_I(4, __VscopeHash, 11883487820222244427ull);
    for (int __Vi0 = 0; __Vi0 < 4; ++__Vi0) {
        vlSelf->tb_llc_flush_tag__DOT__dut__DOT__pending_index_q[__Vi0] = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 11931165312054910582ull);
    }
    for (int __Vi0 = 0; __Vi0 < 4; ++__Vi0) {
        vlSelf->tb_llc_flush_tag__DOT__dut__DOT__pending_way_q[__Vi0] = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 5059815415846828709ull);
    }
    for (int __Vi0 = 0; __Vi0 < 4; ++__Vi0) {
        vlSelf->tb_llc_flush_tag__DOT__dut__DOT__pending_tag_q[__Vi0] = VL_SCOPED_RAND_RESET_Q(61, __VscopeHash, 357454983757368692ull);
    }
    vlSelf->tb_llc_flush_tag__DOT__dut__DOT__pending_write_q = VL_SCOPED_RAND_RESET_I(2, __VscopeHash, 7476512028206454951ull);
    vlSelf->tb_llc_flush_tag__DOT__dut__DOT__pending_ack_q = VL_SCOPED_RAND_RESET_I(2, __VscopeHash, 8263466752712658858ull);
    vlSelf->tb_llc_flush_tag__DOT__dut__DOT__pending_read_q = VL_SCOPED_RAND_RESET_I(2, __VscopeHash, 12643168235724742320ull);
    vlSelf->tb_llc_flush_tag__DOT__dut__DOT__pending_full = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 8183493657260577774ull);
    vlSelf->tb_llc_flush_tag__DOT__dut__DOT__pending_push = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 8937607946823518504ull);
    vlSelf->tb_llc_flush_tag__DOT__dut__DOT__pending_pop = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 10557090767083774721ull);
    vlSelf->tb_llc_flush_tag__DOT__dut__DOT__maint_pending_q = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 13505948459170984031ull);
    vlSelf->tb_llc_flush_tag__DOT__dut__DOT__maint_result_q = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 10152718696698232166ull);
    vlSelf->tb_llc_flush_tag__DOT__dut__DOT__maint_error_q = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 13076662806205131429ull);
    vlSelf->tb_llc_flush_tag__DOT__dut__DOT__maint_index_q = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 6934257079096750607ull);
    vlSelf->tb_llc_flush_tag__DOT__dut__DOT__maint_way_q = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 10733052657637798073ull);
    vlSelf->tb_llc_flush_tag__DOT__dut__DOT__maint_tag_q = VL_SCOPED_RAND_RESET_Q(61, __VscopeHash, 13181848137328564485ull);
    vlSelf->tb_llc_flush_tag__DOT__dut__DOT__maint_op_q = VL_SCOPED_RAND_RESET_I(2, __VscopeHash, 17900319670057556383ull);
    vlSelf->tb_llc_flush_tag__DOT__dut__DOT__maint_finish = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 5791275408459213594ull);
    vlSelf->tb_llc_flush_tag__DOT__dut__DOT____Vcellinp__gen_tag_macros__BRA__0__KET____DOT__i_shift_reg_rvalid__d_i = 0;
    vlSelf->tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__busy_q = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 5821541066298880675ull);
    vlSelf->tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__eoc_q = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 18363809773200312964ull);
    vlSelf->tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__bist_q = VL_SCOPED_RAND_RESET_I(4, __VscopeHash, 7830468554934969769ull);
    vlSelf->tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__en_cnt = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 17249304485867930485ull);
    vlSelf->tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__load_cnt = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 8890775356501771570ull);
    vlSelf->tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__i_index_cnt__DOT__i_counter__DOT__counter_q = VL_SCOPED_RAND_RESET_I(2, __VscopeHash, 4074976512211080746ull);
    vlSelf->tb_llc_flush_tag__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__a_data_q = VL_SCOPED_RAND_RESET_Q(62, __VscopeHash, 5970619217837273792ull);
    vlSelf->tb_llc_flush_tag__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__a_full_q = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 9888442633317657093ull);
    vlSelf->tb_llc_flush_tag__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__a_fill = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 12126475478314671125ull);
    vlSelf->tb_llc_flush_tag__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__a_drain = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 6003541232365047584ull);
    vlSelf->tb_llc_flush_tag__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__b_data_q = VL_SCOPED_RAND_RESET_Q(62, __VscopeHash, 4041647815239150736ull);
    vlSelf->tb_llc_flush_tag__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__b_full_q = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 1642770259547575928ull);
    vlSelf->tb_llc_flush_tag__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__b_fill = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 11960868781174814375ull);
    for (int __Vi0 = 0; __Vi0 < 2; ++__Vi0) {
        vlSelf->tb_llc_flush_tag__DOT__dut__DOT__gen_tag_macros__BRA__0__KET____DOT__i_tag_store__DOT__sram[__Vi0] = VL_SCOPED_RAND_RESET_Q(61, __VscopeHash, 2409751995624631659ull);
    }
    vlSelf->tb_llc_flush_tag__DOT__dut__DOT__gen_tag_macros__BRA__0__KET____DOT__i_tag_store__DOT__r_addr_q = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 1644038706473380945ull);
    vlSelf->tb_llc_flush_tag__DOT__dut__DOT__gen_tag_macros__BRA__0__KET____DOT__i_tag_store__DOT__rdata_q = VL_SCOPED_RAND_RESET_Q(61, __VscopeHash, 10407170581956014457ull);
    VL_SCOPED_RAND_RESET_W(70, vlSelf->tb_llc_flush_tag__DOT__writer__DOT__desc_q, __VscopeHash, 14745490306201139139ull);
    vlSelf->tb_llc_flush_tag__DOT__writer__DOT__busy_q = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 7495116584267849675ull);
    vlSelf->tb_llc_flush_tag__DOT__writer__DOT__send_q = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 14774104972072239583ull);
    vlSelf->tb_llc_flush_tag__DOT__writer__DOT__load_desc = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 7003396269620203883ull);
    vlSelf->tb_llc_flush_tag__DOT__writer__DOT__fifo_push = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 5383030378987112585ull);
    vlSelf->tb_llc_flush_tag__DOT__writer__DOT__fifo_empty = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 15791668049797906835ull);
    vlSelf->tb_llc_flush_tag__DOT__writer__DOT__wb_fault_q = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 6807049145388502287ull);
    vlSelf->tb_llc_flush_tag__DOT__writer__DOT__wb_failed_q = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 18254632790170663814ull);
    vlSelf->tb_llc_flush_tag__DOT__writer__DOT__i_w_to_send_counter__DOT__i_counter__DOT__counter_q = VL_SCOPED_RAND_RESET_I(2, __VscopeHash, 3100447164043144689ull);
    vlSelf->tb_llc_flush_tag__DOT__writer__DOT__i_block_offset_counter__DOT__i_counter__DOT__counter_q = VL_SCOPED_RAND_RESET_I(2, __VscopeHash, 12981475422695112207ull);
    vlSelf->tb_llc_flush_tag__DOT__writer__DOT__i_r_data_fifo__DOT__read_pointer_q = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 16584607154449484480ull);
    vlSelf->tb_llc_flush_tag__DOT__writer__DOT__i_r_data_fifo__DOT__write_pointer_q = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 17198929492403825651ull);
    vlSelf->tb_llc_flush_tag__DOT__writer__DOT__i_r_data_fifo__DOT__status_cnt_q = VL_SCOPED_RAND_RESET_I(2, __VscopeHash, 16643429019125658253ull);
    VL_SCOPED_RAND_RESET_W(128, vlSelf->tb_llc_flush_tag__DOT__writer__DOT__i_r_data_fifo__DOT__mem_n, __VscopeHash, 3285283989022624318ull);
    VL_SCOPED_RAND_RESET_W(128, vlSelf->tb_llc_flush_tag__DOT__writer__DOT__i_r_data_fifo__DOT__mem_q, __VscopeHash, 80775551449431199ull);
    vlSelf->__VdfgRegularize_h6e95ff9d_0_0 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_1 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_3 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_4 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_5 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_6 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_11 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_13 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_14 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_21 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_24 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_25 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_27 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_28 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_29 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_32 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_33 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_34 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_35 = 0;
    vlSelf->__Vsampled_TOP__tb_llc_flush_tag__DOT__writer__DOT__i_r_data_fifo__DOT__status_cnt_q = 0;
    vlSelf->__Vsampled_TOP__tb_llc_flush_tag__DOT__writer__DOT__fifo_push = 0;
    vlSelf->__Vsampled_TOP__tb_llc_flush_tag__DOT__writer__DOT__fifo_empty = 0;
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
    vlSelf->__Vtrigprevexpr___TOP__tb_llc_flush_tag__DOT__clk__0 = 0;
    vlSelf->__Vtrigprevexpr___TOP__tb_llc_flush_tag__DOT__rst__0 = 0;
    vlSelf->__Vtrigprevexpr___TOP__tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__eoc_q__0 = 0;
    vlSelf->__Vtrigprevexpr_h4d792359__1 = 0;
    vlSelf->__Vtrigprevexpr_h4d7acfdc__1 = 0;
    for (int __Vi0 = 0; __Vi0 < 1; ++__Vi0) {
        vlSelf->__VnbaTriggered[__Vi0] = 0;
    }
    vlSelf->__Vi = 0;
}
