// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vtb_store_unit_cmo_metadata.h for the primary calling header

#include "Vtb_store_unit_cmo_metadata__pch.h"

void Vtb_store_unit_cmo_metadata___024root___timing_ready(Vtb_store_unit_cmo_metadata___024root* vlSelf);

VL_ATTR_COLD void Vtb_store_unit_cmo_metadata___024root___eval_static(Vtb_store_unit_cmo_metadata___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_store_unit_cmo_metadata___024root___eval_static\n"); );
    Vtb_store_unit_cmo_metadata__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    {
        // Inlined CFunc: _eval_static__TOP
        vlSelfRef.tb_store_unit_cmo_metadata__DOT__clk_i = 0U;
        vlSelfRef.tb_store_unit_cmo_metadata__DOT__rst_ni = 0U;
        vlSelfRef.tb_store_unit_cmo_metadata__DOT__valid_i = 0U;
        vlSelfRef.tb_store_unit_cmo_metadata__DOT__ctrl[0U] = 0U;
        vlSelfRef.tb_store_unit_cmo_metadata__DOT__ctrl[1U] = 0U;
        vlSelfRef.tb_store_unit_cmo_metadata__DOT__ctrl[2U] = 0U;
        vlSelfRef.tb_store_unit_cmo_metadata__DOT__ctrl[3U] = 0U;
        vlSelfRef.tb_store_unit_cmo_metadata__DOT__ctrl[4U] = 0U;
        vlSelfRef.tb_store_unit_cmo_metadata__DOT__ctrl[5U] = 0U;
        vlSelfRef.tb_store_unit_cmo_metadata__DOT__pa = 0ULL;
    }
    vlSelfRef.__Vtrigprevexpr___TOP__tb_store_unit_cmo_metadata__DOT__clk_i__0 = 0U;
    vlSelfRef.__Vtrigprevexpr___TOP__tb_store_unit_cmo_metadata__DOT__rst_ni__0 = 0U;
    Vtb_store_unit_cmo_metadata___024root___timing_ready(vlSelf);
    do {
        vlSelfRef.__VactTriggeredAcc[vlSelfRef.__Vi] 
            = vlSelfRef.__VactTriggered[vlSelfRef.__Vi];
        vlSelfRef.__Vi = ((IData)(1U) + vlSelfRef.__Vi);
    } while ((0U >= vlSelfRef.__Vi));
}

#ifdef VL_DEBUG
VL_ATTR_COLD void Vtb_store_unit_cmo_metadata___024root___dump_triggers__stl(const VlUnpacked<QData/*63:0*/, 1> &triggers, const std::string &tag);
#endif  // VL_DEBUG
VL_ATTR_COLD bool Vtb_store_unit_cmo_metadata___024root___trigger_anySet__stl(const VlUnpacked<QData/*63:0*/, 1> &in);
VL_ATTR_COLD void Vtb_store_unit_cmo_metadata___024root___stl_sequent__TOP__0(Vtb_store_unit_cmo_metadata___024root* vlSelf);

VL_ATTR_COLD bool Vtb_store_unit_cmo_metadata___024root___eval_stl(Vtb_store_unit_cmo_metadata___024root* vlSelf, CData/*0:0*/ firstIteration) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_store_unit_cmo_metadata___024root___eval_stl\n"); );
    Vtb_store_unit_cmo_metadata__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    CData/*0:0*/ __VstlExecute;
    // Body
    vlSelfRef.__VstlTriggered[0U] = ((0xfffffffffffffffeULL 
                                      & vlSelfRef.__VstlTriggered[0U]) 
                                     | (IData)((IData)(firstIteration)));
#ifdef VL_DEBUG
    if (VL_UNLIKELY(vlSymsp->_vm_contextp__->debug())) {
        Vtb_store_unit_cmo_metadata___024root___dump_triggers__stl(vlSelfRef.__VstlTriggered, "stl"s);
    }
#endif
    __VstlExecute = Vtb_store_unit_cmo_metadata___024root___trigger_anySet__stl(vlSelfRef.__VstlTriggered);
    if (__VstlExecute) {
        {
            // Inlined CFunc: _eval_body__stl
            if ((1ULL & vlSelfRef.__VstlTriggered[0U])) {
                Vtb_store_unit_cmo_metadata___024root___stl_sequent__TOP__0(vlSelf);
            }
        }
    }
    return (__VstlExecute);
}

VL_ATTR_COLD void Vtb_store_unit_cmo_metadata___024root___eval_dump_triggers__stl(Vtb_store_unit_cmo_metadata___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_store_unit_cmo_metadata___024root___eval_dump_triggers__stl\n"); );
    Vtb_store_unit_cmo_metadata__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
#ifdef VL_DEBUG
    Vtb_store_unit_cmo_metadata___024root___dump_triggers__stl(vlSelfRef.__VstlTriggered, "stl"s);
#endif
}

#ifdef VL_DEBUG
VL_ATTR_COLD void Vtb_store_unit_cmo_metadata___024root___dump_triggers__ico(const VlUnpacked<QData/*63:0*/, 1> &triggers, const std::string &tag);
#endif  // VL_DEBUG

VL_ATTR_COLD void Vtb_store_unit_cmo_metadata___024root___eval_dump_triggers__ico(Vtb_store_unit_cmo_metadata___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_store_unit_cmo_metadata___024root___eval_dump_triggers__ico\n"); );
    Vtb_store_unit_cmo_metadata__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
#ifdef VL_DEBUG
    Vtb_store_unit_cmo_metadata___024root___dump_triggers__ico(vlSelfRef.__VicoTriggered, "ico"s);
#endif
}

#ifdef VL_DEBUG
VL_ATTR_COLD void Vtb_store_unit_cmo_metadata___024root___dump_triggers__act(const VlUnpacked<QData/*63:0*/, 1> &triggers, const std::string &tag);
#endif  // VL_DEBUG

VL_ATTR_COLD void Vtb_store_unit_cmo_metadata___024root___eval_dump_triggers__act(Vtb_store_unit_cmo_metadata___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_store_unit_cmo_metadata___024root___eval_dump_triggers__act\n"); );
    Vtb_store_unit_cmo_metadata__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
#ifdef VL_DEBUG
    Vtb_store_unit_cmo_metadata___024root___dump_triggers__act(vlSelfRef.__VactTriggered, "act"s);
#endif
}

VL_ATTR_COLD void Vtb_store_unit_cmo_metadata___024root___eval_dump_triggers__nba(Vtb_store_unit_cmo_metadata___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_store_unit_cmo_metadata___024root___eval_dump_triggers__nba\n"); );
    Vtb_store_unit_cmo_metadata__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
#ifdef VL_DEBUG
    Vtb_store_unit_cmo_metadata___024root___dump_triggers__act(vlSelfRef.__VnbaTriggered, "nba"s);
#endif
}

VL_ATTR_COLD void Vtb_store_unit_cmo_metadata___024root___eval_dump_triggers__obs(Vtb_store_unit_cmo_metadata___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_store_unit_cmo_metadata___024root___eval_dump_triggers__obs\n"); );
    Vtb_store_unit_cmo_metadata__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
}

VL_ATTR_COLD void Vtb_store_unit_cmo_metadata___024root___eval_dump_triggers__react(Vtb_store_unit_cmo_metadata___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_store_unit_cmo_metadata___024root___eval_dump_triggers__react\n"); );
    Vtb_store_unit_cmo_metadata__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
}

VL_ATTR_COLD void Vtb_store_unit_cmo_metadata___024root___eval_final(Vtb_store_unit_cmo_metadata___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_store_unit_cmo_metadata___024root___eval_final\n"); );
    Vtb_store_unit_cmo_metadata__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
}

#ifdef VL_DEBUG
VL_ATTR_COLD void Vtb_store_unit_cmo_metadata___024root___dump_triggers__stl(const VlUnpacked<QData/*63:0*/, 1> &triggers, const std::string &tag) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_store_unit_cmo_metadata___024root___dump_triggers__stl\n"); );
    // Body
    if ((1U & (~ (IData)(Vtb_store_unit_cmo_metadata___024root___trigger_anySet__stl(triggers))))) {
        VL_DBG_MSGS("         No '" + tag + "' region triggers active\n");
    }
    if ((1U & (IData)(triggers[0U]))) {
        VL_DBG_MSGS("         '" + tag + "' region trigger index 0 is active: Internal 'stl' trigger - first iteration\n");
    }
}
#endif  // VL_DEBUG

VL_ATTR_COLD bool Vtb_store_unit_cmo_metadata___024root___trigger_anySet__stl(const VlUnpacked<QData/*63:0*/, 1> &in) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_store_unit_cmo_metadata___024root___trigger_anySet__stl\n"); );
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

VL_ATTR_COLD void Vtb_store_unit_cmo_metadata___024root___stl_sequent__TOP__0(Vtb_store_unit_cmo_metadata___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_store_unit_cmo_metadata___024root___stl_sequent__TOP__0\n"); );
    Vtb_store_unit_cmo_metadata__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    CData/*0:0*/ tb_store_unit_cmo_metadata__DOT__dut__DOT__st_valid;
    tb_store_unit_cmo_metadata__DOT__dut__DOT__st_valid = 0;
    // Body
    vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__instr_is_amo 
        = ((0x3dU <= (0x000000ffU & (vlSelfRef.tb_store_unit_cmo_metadata__DOT__ctrl[1U] 
                                     >> 5U))) & (0x52U 
                                                 >= 
                                                 (0x000000ffU 
                                                  & (vlSelfRef.tb_store_unit_cmo_metadata__DOT__ctrl[1U] 
                                                     >> 5U))));
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_4 = (3U 
                                                & ((0x00000040U 
                                                    & vlSelfRef.tb_store_unit_cmo_metadata__DOT__ctrl[1U])
                                                    ? 
                                                   (1U 
                                                    & (- (IData)(
                                                                 (1U 
                                                                  & (~ 
                                                                     (vlSelfRef.tb_store_unit_cmo_metadata__DOT__ctrl[1U] 
                                                                      >> 5U))))))
                                                    : 
                                                   (2U 
                                                    | (- (IData)(
                                                                 (1U 
                                                                  & (~ 
                                                                     (vlSelfRef.tb_store_unit_cmo_metadata__DOT__ctrl[1U] 
                                                                      >> 5U))))))));
    tb_store_unit_cmo_metadata__DOT__dut__DOT__st_valid 
        = ((0U != (IData)(vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__state_q)) 
           & (1U == (IData)(vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__state_q)));
    vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__amo_buffer_valid 
        = ((0U != (IData)(vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__amo_op_q)) 
           & (IData)(tb_store_unit_cmo_metadata__DOT__dut__DOT__st_valid));
    vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__store_buffer_valid 
        = ((0U == (IData)(vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__amo_op_q)) 
           & (IData)(tb_store_unit_cmo_metadata__DOT__dut__DOT__st_valid));
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_2 = ((1U 
                                                 != (IData)(vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__genblk1__DOT__i_amo_buffer__DOT__i_amo_fifo__DOT__status_cnt_q)) 
                                                & (IData)(vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__amo_buffer_valid));
    vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__store_buffer_i__DOT__speculative_status_cnt_n 
        = (7U & ((IData)(vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__store_buffer_i__DOT__speculative_status_cnt_q) 
                 + (IData)(vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__store_buffer_valid)));
    vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__store_buffer_i__DOT__speculative_queue_n 
        = vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__store_buffer_i__DOT__speculative_queue_q;
    if (vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__store_buffer_valid) {
        vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__store_buffer_i__DOT__speculative_queue_n[vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__store_buffer_i__DOT__speculative_write_pointer_q][4U] 
            = ((0x000fffffU & vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__store_buffer_i__DOT__speculative_queue_n
                [vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__store_buffer_i__DOT__speculative_write_pointer_q][4U]) 
               | ((IData)(vlSelfRef.tb_store_unit_cmo_metadata__DOT__pa) 
                  << 0x00000014U));
        vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__store_buffer_i__DOT__speculative_queue_n[vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__store_buffer_i__DOT__speculative_write_pointer_q][5U] 
            = (((IData)(vlSelfRef.tb_store_unit_cmo_metadata__DOT__pa) 
                >> 0x0000000cU) | ((IData)((vlSelfRef.tb_store_unit_cmo_metadata__DOT__pa 
                                            >> 0x00000020U)) 
                                   << 0x00000014U));
        vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__store_buffer_i__DOT__speculative_queue_n[vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__store_buffer_i__DOT__speculative_write_pointer_q][6U] 
            = (0x00000fffU & ((IData)((vlSelfRef.tb_store_unit_cmo_metadata__DOT__pa 
                                       >> 0x00000020U)) 
                              >> 0x0000000cU));
        vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__store_buffer_i__DOT__speculative_queue_n[vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__store_buffer_i__DOT__speculative_write_pointer_q][2U] 
            = ((0x000fffffU & vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__store_buffer_i__DOT__speculative_queue_n
                [vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__store_buffer_i__DOT__speculative_write_pointer_q][2U]) 
               | ((IData)(vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__st_vaddr_q) 
                  << 0x00000014U));
        vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__store_buffer_i__DOT__speculative_queue_n[vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__store_buffer_i__DOT__speculative_write_pointer_q][3U] 
            = (((IData)(vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__st_vaddr_q) 
                >> 0x0000000cU) | ((IData)((vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__st_vaddr_q 
                                            >> 0x00000020U)) 
                                   << 0x00000014U));
        vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__store_buffer_i__DOT__speculative_queue_n[vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__store_buffer_i__DOT__speculative_write_pointer_q][4U] 
            = ((0xfff00000U & vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__store_buffer_i__DOT__speculative_queue_n
                [vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__store_buffer_i__DOT__speculative_write_pointer_q][4U]) 
               | ((IData)((vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__st_vaddr_q 
                           >> 0x00000020U)) >> 0x0000000cU));
        vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__store_buffer_i__DOT__speculative_queue_n[vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__store_buffer_i__DOT__speculative_write_pointer_q][0U] 
            = ((0x000fffffU & vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__store_buffer_i__DOT__speculative_queue_n
                [vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__store_buffer_i__DOT__speculative_write_pointer_q][0U]) 
               | ((IData)(vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__st_data_q) 
                  << 0x00000014U));
        vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__store_buffer_i__DOT__speculative_queue_n[vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__store_buffer_i__DOT__speculative_write_pointer_q][1U] 
            = (((IData)(vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__st_data_q) 
                >> 0x0000000cU) | ((IData)((vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__st_data_q 
                                            >> 0x00000020U)) 
                                   << 0x00000014U));
        vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__store_buffer_i__DOT__speculative_queue_n[vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__store_buffer_i__DOT__speculative_write_pointer_q][2U] 
            = ((0xfff00000U & vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__store_buffer_i__DOT__speculative_queue_n
                [vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__store_buffer_i__DOT__speculative_write_pointer_q][2U]) 
               | ((IData)((vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__st_data_q 
                           >> 0x00000020U)) >> 0x0000000cU));
        vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__store_buffer_i__DOT__speculative_queue_n[vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__store_buffer_i__DOT__speculative_write_pointer_q][0U] 
            = ((0xfff00fffU & vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__store_buffer_i__DOT__speculative_queue_n
                [vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__store_buffer_i__DOT__speculative_write_pointer_q][0U]) 
               | ((IData)(vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__st_be_q) 
                  << 0x0000000cU));
        vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__store_buffer_i__DOT__speculative_queue_n[vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__store_buffer_i__DOT__speculative_write_pointer_q][0U] 
            = ((0xfffff3ffU & vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__store_buffer_i__DOT__speculative_queue_n
                [vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__store_buffer_i__DOT__speculative_write_pointer_q][0U]) 
               | ((IData)(vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__st_data_size_q) 
                  << 0x0000000aU));
        vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__store_buffer_i__DOT__speculative_queue_n[vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__store_buffer_i__DOT__speculative_write_pointer_q][0U] 
            = (2U | vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__store_buffer_i__DOT__speculative_queue_n
               [vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__store_buffer_i__DOT__speculative_write_pointer_q][0U]);
        vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__store_buffer_i__DOT__speculative_queue_n[vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__store_buffer_i__DOT__speculative_write_pointer_q][0U] 
            = ((0xfffffc03U & vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__store_buffer_i__DOT__speculative_queue_n
                [vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__store_buffer_i__DOT__speculative_write_pointer_q][0U]) 
               | ((IData)(vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__cbo_op_q) 
                  << 2U));
        vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__store_buffer_i__DOT__speculative_queue_n[vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__store_buffer_i__DOT__speculative_write_pointer_q][0U] 
            = (0xfffffffeU & vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__store_buffer_i__DOT__speculative_queue_n
               [vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__store_buffer_i__DOT__speculative_write_pointer_q][0U]);
    }
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_10 = (3U 
                                                 & (- (IData)(
                                                              (1U 
                                                               & (~ 
                                                                  ((0U 
                                                                    == (IData)(vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__genblk1__DOT__i_amo_buffer__DOT__i_amo_fifo__DOT__status_cnt_q)) 
                                                                   & (4U 
                                                                      > (IData)(vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__store_buffer_i__DOT__speculative_status_cnt_n))))))));
}

bool Vtb_store_unit_cmo_metadata___024root___trigger_anySet__ico(const VlUnpacked<QData/*63:0*/, 1> &in);

#ifdef VL_DEBUG
VL_ATTR_COLD void Vtb_store_unit_cmo_metadata___024root___dump_triggers__ico(const VlUnpacked<QData/*63:0*/, 1> &triggers, const std::string &tag) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_store_unit_cmo_metadata___024root___dump_triggers__ico\n"); );
    // Body
    if ((1U & (~ (IData)(Vtb_store_unit_cmo_metadata___024root___trigger_anySet__ico(triggers))))) {
        VL_DBG_MSGS("         No '" + tag + "' region triggers active\n");
    }
    if ((1U & (IData)(triggers[0U]))) {
        VL_DBG_MSGS("         '" + tag + "' region trigger index 0 is active: Internal 'ico' trigger - first iteration\n");
    }
}
#endif  // VL_DEBUG

bool Vtb_store_unit_cmo_metadata___024root___trigger_anySet__act(const VlUnpacked<QData/*63:0*/, 1> &in);

#ifdef VL_DEBUG
VL_ATTR_COLD void Vtb_store_unit_cmo_metadata___024root___dump_triggers__act(const VlUnpacked<QData/*63:0*/, 1> &triggers, const std::string &tag) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_store_unit_cmo_metadata___024root___dump_triggers__act\n"); );
    // Body
    if ((1U & (~ (IData)(Vtb_store_unit_cmo_metadata___024root___trigger_anySet__act(triggers))))) {
        VL_DBG_MSGS("         No '" + tag + "' region triggers active\n");
    }
    if ((1U & (IData)(triggers[0U]))) {
        VL_DBG_MSGS("         '" + tag + "' region trigger index 0 is active: @(posedge tb_store_unit_cmo_metadata.clk_i)\n");
    }
    if ((1U & (IData)((triggers[0U] >> 1U)))) {
        VL_DBG_MSGS("         '" + tag + "' region trigger index 1 is active: @(negedge tb_store_unit_cmo_metadata.rst_ni)\n");
    }
    if ((1U & (IData)((triggers[0U] >> 2U)))) {
        VL_DBG_MSGS("         '" + tag + "' region trigger index 2 is active: @(negedge tb_store_unit_cmo_metadata.clk_i)\n");
    }
    if ((1U & (IData)((triggers[0U] >> 3U)))) {
        VL_DBG_MSGS("         '" + tag + "' region trigger index 3 is active: @([true] __VdlySched.awaitingCurrentTime())\n");
    }
}
#endif  // VL_DEBUG

VL_ATTR_COLD void Vtb_store_unit_cmo_metadata___024root___ctor_var_reset(Vtb_store_unit_cmo_metadata___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_store_unit_cmo_metadata___024root___ctor_var_reset\n"); );
    Vtb_store_unit_cmo_metadata__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    const uint64_t __VscopeHash = VL_MURMUR64_HASH(vlSelf->vlNamep);
    vlSelf->tb_store_unit_cmo_metadata__DOT__dut__DOT__state_q = VL_SCOPED_RAND_RESET_I(2, __VscopeHash, 14797876185164048138ull);
    vlSelf->tb_store_unit_cmo_metadata__DOT__dut__DOT__instr_is_amo = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 17587224728986546018ull);
    vlSelf->tb_store_unit_cmo_metadata__DOT__dut__DOT__st_data_q = VL_SCOPED_RAND_RESET_Q(64, __VscopeHash, 2973997270497022167ull);
    vlSelf->tb_store_unit_cmo_metadata__DOT__dut__DOT__st_vaddr_q = VL_SCOPED_RAND_RESET_Q(64, __VscopeHash, 16278645772340464678ull);
    vlSelf->tb_store_unit_cmo_metadata__DOT__dut__DOT__st_be_q = VL_SCOPED_RAND_RESET_I(8, __VscopeHash, 10895504251656845373ull);
    vlSelf->tb_store_unit_cmo_metadata__DOT__dut__DOT__st_data_size_q = VL_SCOPED_RAND_RESET_I(2, __VscopeHash, 920180323696708859ull);
    vlSelf->tb_store_unit_cmo_metadata__DOT__dut__DOT__amo_op_q = VL_SCOPED_RAND_RESET_I(4, __VscopeHash, 726508087960103394ull);
    vlSelf->tb_store_unit_cmo_metadata__DOT__dut__DOT__cbo_op_q = VL_SCOPED_RAND_RESET_I(8, __VscopeHash, 8512222625377137477ull);
    vlSelf->tb_store_unit_cmo_metadata__DOT__dut__DOT__store_buffer_valid = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 205306169598011952ull);
    vlSelf->tb_store_unit_cmo_metadata__DOT__dut__DOT__amo_buffer_valid = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 11993249336671428602ull);
    vlSelf->tb_store_unit_cmo_metadata__DOT__dut__DOT__genblk1__DOT__i_amo_buffer__DOT__i_amo_fifo__DOT__status_cnt_q = VL_SCOPED_RAND_RESET_I(2, __VscopeHash, 6796383876351547944ull);
    for (int __Vi0 = 0; __Vi0 < 4; ++__Vi0) {
        VL_SCOPED_RAND_RESET_W(204, vlSelf->tb_store_unit_cmo_metadata__DOT__dut__DOT__store_buffer_i__DOT__speculative_queue_n[__Vi0], __VscopeHash, 8276661152965852023ull);
    }
    for (int __Vi0 = 0; __Vi0 < 4; ++__Vi0) {
        VL_SCOPED_RAND_RESET_W(204, vlSelf->tb_store_unit_cmo_metadata__DOT__dut__DOT__store_buffer_i__DOT__speculative_queue_q[__Vi0], __VscopeHash, 14010508631414969914ull);
    }
    vlSelf->tb_store_unit_cmo_metadata__DOT__dut__DOT__store_buffer_i__DOT__speculative_status_cnt_n = VL_SCOPED_RAND_RESET_I(3, __VscopeHash, 16004008692300443663ull);
    vlSelf->tb_store_unit_cmo_metadata__DOT__dut__DOT__store_buffer_i__DOT__speculative_status_cnt_q = VL_SCOPED_RAND_RESET_I(3, __VscopeHash, 9407936067900065914ull);
    vlSelf->tb_store_unit_cmo_metadata__DOT__dut__DOT__store_buffer_i__DOT__speculative_read_pointer_q = VL_SCOPED_RAND_RESET_I(2, __VscopeHash, 12129603207126294485ull);
    vlSelf->tb_store_unit_cmo_metadata__DOT__dut__DOT__store_buffer_i__DOT__speculative_write_pointer_q = VL_SCOPED_RAND_RESET_I(2, __VscopeHash, 7030929343061595761ull);
    vlSelf->__VdfgRegularize_h6e95ff9d_0_2 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_4 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_10 = 0;
    vlSelf->__Vsampled_TOP__tb_store_unit_cmo_metadata__DOT__dut__DOT__genblk1__DOT__i_amo_buffer__DOT__i_amo_fifo__DOT__status_cnt_q = 0;
    vlSelf->__Vsampled_TOP__tb_store_unit_cmo_metadata__DOT__dut__DOT__amo_buffer_valid = 0;
    vlSelf->__Vsampled_TOP__tb_store_unit_cmo_metadata__DOT__rst_ni = 0;
    vlSelf->__Vsampled_TOP__tb_store_unit_cmo_metadata__DOT__dut__DOT__store_buffer_i__DOT__speculative_status_cnt_q = 0;
    vlSelf->__Vsampled_TOP__tb_store_unit_cmo_metadata__DOT__dut__DOT__store_buffer_valid = 0;
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
    vlSelf->__Vtrigprevexpr___TOP__tb_store_unit_cmo_metadata__DOT__clk_i__0 = 0;
    vlSelf->__Vtrigprevexpr___TOP__tb_store_unit_cmo_metadata__DOT__rst_ni__0 = 0;
    for (int __Vi0 = 0; __Vi0 < 1; ++__Vi0) {
        vlSelf->__VnbaTriggered[__Vi0] = 0;
    }
    vlSelf->__Vi = 0;
}
