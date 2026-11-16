// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vtb_store_buffer_cmo_metadata.h for the primary calling header

#include "Vtb_store_buffer_cmo_metadata__pch.h"

void Vtb_store_buffer_cmo_metadata___024root___timing_ready(Vtb_store_buffer_cmo_metadata___024root* vlSelf);

VL_ATTR_COLD void Vtb_store_buffer_cmo_metadata___024root___eval_static(Vtb_store_buffer_cmo_metadata___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_store_buffer_cmo_metadata___024root___eval_static\n"); );
    Vtb_store_buffer_cmo_metadata__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    {
        // Inlined CFunc: _eval_static__TOP
        vlSelfRef.tb_store_buffer_cmo_metadata__DOT__clk_i = 0U;
        vlSelfRef.tb_store_buffer_cmo_metadata__DOT__rst_ni = 0U;
        vlSelfRef.tb_store_buffer_cmo_metadata__DOT__flush_i = 0U;
        vlSelfRef.tb_store_buffer_cmo_metadata__DOT__commit_i = 0U;
        vlSelfRef.tb_store_buffer_cmo_metadata__DOT__valid_i = 0U;
        vlSelfRef.tb_store_buffer_cmo_metadata__DOT__paddr_i = 0U;
        vlSelfRef.tb_store_buffer_cmo_metadata__DOT__vaddr_i = 0U;
        vlSelfRef.tb_store_buffer_cmo_metadata__DOT__data_i = 0U;
        vlSelfRef.tb_store_buffer_cmo_metadata__DOT__be_i = 0U;
        vlSelfRef.tb_store_buffer_cmo_metadata__DOT__cbo_op_i = 0U;
    }
    vlSelfRef.__Vtrigprevexpr___TOP__tb_store_buffer_cmo_metadata__DOT__clk_i__0 = 0U;
    vlSelfRef.__Vtrigprevexpr___TOP__tb_store_buffer_cmo_metadata__DOT__rst_ni__0 = 0U;
    Vtb_store_buffer_cmo_metadata___024root___timing_ready(vlSelf);
    do {
        vlSelfRef.__VactTriggeredAcc[vlSelfRef.__Vi] 
            = vlSelfRef.__VactTriggered[vlSelfRef.__Vi];
        vlSelfRef.__Vi = ((IData)(1U) + vlSelfRef.__Vi);
    } while ((0U >= vlSelfRef.__Vi));
}

#ifdef VL_DEBUG
VL_ATTR_COLD void Vtb_store_buffer_cmo_metadata___024root___dump_triggers__stl(const VlUnpacked<QData/*63:0*/, 1> &triggers, const std::string &tag);
#endif  // VL_DEBUG
VL_ATTR_COLD bool Vtb_store_buffer_cmo_metadata___024root___trigger_anySet__stl(const VlUnpacked<QData/*63:0*/, 1> &in);
VL_ATTR_COLD void Vtb_store_buffer_cmo_metadata___024root___stl_sequent__TOP__0(Vtb_store_buffer_cmo_metadata___024root* vlSelf);

VL_ATTR_COLD bool Vtb_store_buffer_cmo_metadata___024root___eval_stl(Vtb_store_buffer_cmo_metadata___024root* vlSelf, CData/*0:0*/ firstIteration) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_store_buffer_cmo_metadata___024root___eval_stl\n"); );
    Vtb_store_buffer_cmo_metadata__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    CData/*0:0*/ __VstlExecute;
    // Body
    vlSelfRef.__VstlTriggered[0U] = ((0xfffffffffffffffeULL 
                                      & vlSelfRef.__VstlTriggered[0U]) 
                                     | (IData)((IData)(firstIteration)));
#ifdef VL_DEBUG
    if (VL_UNLIKELY(vlSymsp->_vm_contextp__->debug())) {
        Vtb_store_buffer_cmo_metadata___024root___dump_triggers__stl(vlSelfRef.__VstlTriggered, "stl"s);
    }
#endif
    __VstlExecute = Vtb_store_buffer_cmo_metadata___024root___trigger_anySet__stl(vlSelfRef.__VstlTriggered);
    if (__VstlExecute) {
        {
            // Inlined CFunc: _eval_body__stl
            if ((1ULL & vlSelfRef.__VstlTriggered[0U])) {
                Vtb_store_buffer_cmo_metadata___024root___stl_sequent__TOP__0(vlSelf);
            }
        }
    }
    return (__VstlExecute);
}

VL_ATTR_COLD void Vtb_store_buffer_cmo_metadata___024root___eval_dump_triggers__stl(Vtb_store_buffer_cmo_metadata___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_store_buffer_cmo_metadata___024root___eval_dump_triggers__stl\n"); );
    Vtb_store_buffer_cmo_metadata__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
#ifdef VL_DEBUG
    Vtb_store_buffer_cmo_metadata___024root___dump_triggers__stl(vlSelfRef.__VstlTriggered, "stl"s);
#endif
}

#ifdef VL_DEBUG
VL_ATTR_COLD void Vtb_store_buffer_cmo_metadata___024root___dump_triggers__ico(const VlUnpacked<QData/*63:0*/, 1> &triggers, const std::string &tag);
#endif  // VL_DEBUG

VL_ATTR_COLD void Vtb_store_buffer_cmo_metadata___024root___eval_dump_triggers__ico(Vtb_store_buffer_cmo_metadata___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_store_buffer_cmo_metadata___024root___eval_dump_triggers__ico\n"); );
    Vtb_store_buffer_cmo_metadata__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
#ifdef VL_DEBUG
    Vtb_store_buffer_cmo_metadata___024root___dump_triggers__ico(vlSelfRef.__VicoTriggered, "ico"s);
#endif
}

#ifdef VL_DEBUG
VL_ATTR_COLD void Vtb_store_buffer_cmo_metadata___024root___dump_triggers__act(const VlUnpacked<QData/*63:0*/, 1> &triggers, const std::string &tag);
#endif  // VL_DEBUG

VL_ATTR_COLD void Vtb_store_buffer_cmo_metadata___024root___eval_dump_triggers__act(Vtb_store_buffer_cmo_metadata___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_store_buffer_cmo_metadata___024root___eval_dump_triggers__act\n"); );
    Vtb_store_buffer_cmo_metadata__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
#ifdef VL_DEBUG
    Vtb_store_buffer_cmo_metadata___024root___dump_triggers__act(vlSelfRef.__VactTriggered, "act"s);
#endif
}

VL_ATTR_COLD void Vtb_store_buffer_cmo_metadata___024root___eval_dump_triggers__nba(Vtb_store_buffer_cmo_metadata___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_store_buffer_cmo_metadata___024root___eval_dump_triggers__nba\n"); );
    Vtb_store_buffer_cmo_metadata__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
#ifdef VL_DEBUG
    Vtb_store_buffer_cmo_metadata___024root___dump_triggers__act(vlSelfRef.__VnbaTriggered, "nba"s);
#endif
}

VL_ATTR_COLD void Vtb_store_buffer_cmo_metadata___024root___eval_dump_triggers__obs(Vtb_store_buffer_cmo_metadata___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_store_buffer_cmo_metadata___024root___eval_dump_triggers__obs\n"); );
    Vtb_store_buffer_cmo_metadata__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
}

VL_ATTR_COLD void Vtb_store_buffer_cmo_metadata___024root___eval_dump_triggers__react(Vtb_store_buffer_cmo_metadata___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_store_buffer_cmo_metadata___024root___eval_dump_triggers__react\n"); );
    Vtb_store_buffer_cmo_metadata__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
}

VL_ATTR_COLD void Vtb_store_buffer_cmo_metadata___024root___eval_final(Vtb_store_buffer_cmo_metadata___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_store_buffer_cmo_metadata___024root___eval_final\n"); );
    Vtb_store_buffer_cmo_metadata__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
}

#ifdef VL_DEBUG
VL_ATTR_COLD void Vtb_store_buffer_cmo_metadata___024root___dump_triggers__stl(const VlUnpacked<QData/*63:0*/, 1> &triggers, const std::string &tag) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_store_buffer_cmo_metadata___024root___dump_triggers__stl\n"); );
    // Body
    if ((1U & (~ (IData)(Vtb_store_buffer_cmo_metadata___024root___trigger_anySet__stl(triggers))))) {
        VL_DBG_MSGS("         No '" + tag + "' region triggers active\n");
    }
    if ((1U & (IData)(triggers[0U]))) {
        VL_DBG_MSGS("         '" + tag + "' region trigger index 0 is active: Internal 'stl' trigger - first iteration\n");
    }
}
#endif  // VL_DEBUG

VL_ATTR_COLD bool Vtb_store_buffer_cmo_metadata___024root___trigger_anySet__stl(const VlUnpacked<QData/*63:0*/, 1> &in) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_store_buffer_cmo_metadata___024root___trigger_anySet__stl\n"); );
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

VL_ATTR_COLD void Vtb_store_buffer_cmo_metadata___024root___stl_sequent__TOP__0(Vtb_store_buffer_cmo_metadata___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_store_buffer_cmo_metadata___024root___stl_sequent__TOP__0\n"); );
    Vtb_store_buffer_cmo_metadata__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_1 = vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__commit_status_cnt_q;
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_3 = vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__commit_read_pointer_q;
    vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__commit_queue_n 
        = vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__commit_queue_q;
    if (((IData)(vlSelfRef.tb_store_buffer_cmo_metadata__DOT__commit_i) 
         & (0U == (0x000000ffU & (vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_queue_q
                                  [vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_read_pointer_q][0U] 
                                  >> 2U))))) {
        vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__commit_queue_n[vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__commit_write_pointer_q][0U] 
            = vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_queue_q
            [vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_read_pointer_q][0U];
        vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__commit_queue_n[vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__commit_write_pointer_q][1U] 
            = vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_queue_q
            [vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_read_pointer_q][1U];
        vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__commit_queue_n[vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__commit_write_pointer_q][2U] 
            = vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_queue_q
            [vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_read_pointer_q][2U];
        vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__commit_queue_n[vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__commit_write_pointer_q][3U] 
            = vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_queue_q
            [vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_read_pointer_q][3U];
    }
    vlSelfRef.tb_store_buffer_cmo_metadata__DOT__cmo_entry_op_o 
        = (0x000000ffU & (vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_queue_q
                          [vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_read_pointer_q][0U] 
                          >> 2U));
    vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_read_pointer_n 
        = vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_read_pointer_q;
    vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_write_pointer_n 
        = vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_write_pointer_q;
    if (vlSelfRef.tb_store_buffer_cmo_metadata__DOT__valid_i) {
        vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_write_pointer_n 
            = (3U & ((IData)(1U) + (IData)(vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_write_pointer_q)));
    }
    if (vlSelfRef.tb_store_buffer_cmo_metadata__DOT__commit_i) {
        vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_read_pointer_n 
            = (3U & ((IData)(1U) + (IData)(vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_read_pointer_q)));
    }
    vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_queue_n 
        = vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_queue_q;
    if (vlSelfRef.tb_store_buffer_cmo_metadata__DOT__valid_i) {
        vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_queue_n[vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_write_pointer_q][2U] 
            = ((0x0000ffffU & vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_queue_n
                [vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_write_pointer_q][2U]) 
               | (vlSelfRef.tb_store_buffer_cmo_metadata__DOT__paddr_i 
                  << 0x00000010U));
        vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_queue_n[vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_write_pointer_q][3U] 
            = (vlSelfRef.tb_store_buffer_cmo_metadata__DOT__paddr_i 
               >> 0x00000010U);
        vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_queue_n[vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_write_pointer_q][1U] 
            = ((0x0000ffffU & vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_queue_n
                [vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_write_pointer_q][1U]) 
               | (vlSelfRef.tb_store_buffer_cmo_metadata__DOT__vaddr_i 
                  << 0x00000010U));
        vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_queue_n[vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_write_pointer_q][2U] 
            = ((0xffff0000U & vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_queue_n
                [vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_write_pointer_q][2U]) 
               | (vlSelfRef.tb_store_buffer_cmo_metadata__DOT__vaddr_i 
                  >> 0x00000010U));
        vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_queue_n[vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_write_pointer_q][0U] 
            = ((0x0000ffffU & vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_queue_n
                [vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_write_pointer_q][0U]) 
               | (vlSelfRef.tb_store_buffer_cmo_metadata__DOT__data_i 
                  << 0x00000010U));
        vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_queue_n[vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_write_pointer_q][1U] 
            = ((0xffff0000U & vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_queue_n
                [vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_write_pointer_q][1U]) 
               | (vlSelfRef.tb_store_buffer_cmo_metadata__DOT__data_i 
                  >> 0x00000010U));
        vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_queue_n[vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_write_pointer_q][0U] 
            = ((0xffff0fffU & vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_queue_n
                [vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_write_pointer_q][0U]) 
               | ((IData)(vlSelfRef.tb_store_buffer_cmo_metadata__DOT__be_i) 
                  << 0x0000000cU));
        vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_queue_n[vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_write_pointer_q][0U] 
            = (0xfffff3ffU & vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_queue_n
               [vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_write_pointer_q][0U]);
        vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_queue_n[vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_write_pointer_q][0U] 
            = (2U | vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_queue_n
               [vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_write_pointer_q][0U]);
        vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_queue_n[vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_write_pointer_q][0U] 
            = ((0xfffffc03U & vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_queue_n
                [vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_write_pointer_q][0U]) 
               | ((IData)(vlSelfRef.tb_store_buffer_cmo_metadata__DOT__cbo_op_i) 
                  << 2U));
        vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_queue_n[vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_write_pointer_q][0U] 
            = (0xfffffffeU & vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_queue_n
               [vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_write_pointer_q][0U]);
    }
    if (vlSelfRef.tb_store_buffer_cmo_metadata__DOT__commit_i) {
        vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_queue_n[vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_read_pointer_q][0U] 
            = (0xfffffffdU & vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_queue_n
               [vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_read_pointer_q][0U]);
    }
    if (vlSelfRef.tb_store_buffer_cmo_metadata__DOT__flush_i) {
        vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_write_pointer_n 
            = vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_read_pointer_n;
        vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_queue_n[0U][0U] 
            = (0xfffffffdU & vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_queue_n[0U][0U]);
        vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_queue_n[1U][0U] 
            = (0xfffffffdU & vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_queue_n[1U][0U]);
        vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_queue_n[2U][0U] 
            = (0xfffffffdU & vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_queue_n[2U][0U]);
        vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_queue_n[3U][0U] 
            = (0xfffffffdU & vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_queue_n[3U][0U]);
    }
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_2 = ((IData)(vlSelfRef.tb_store_buffer_cmo_metadata__DOT__commit_i) 
                                                & (0U 
                                                   == (IData)(vlSelfRef.tb_store_buffer_cmo_metadata__DOT__cmo_entry_op_o)));
}

bool Vtb_store_buffer_cmo_metadata___024root___trigger_anySet__ico(const VlUnpacked<QData/*63:0*/, 1> &in);

#ifdef VL_DEBUG
VL_ATTR_COLD void Vtb_store_buffer_cmo_metadata___024root___dump_triggers__ico(const VlUnpacked<QData/*63:0*/, 1> &triggers, const std::string &tag) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_store_buffer_cmo_metadata___024root___dump_triggers__ico\n"); );
    // Body
    if ((1U & (~ (IData)(Vtb_store_buffer_cmo_metadata___024root___trigger_anySet__ico(triggers))))) {
        VL_DBG_MSGS("         No '" + tag + "' region triggers active\n");
    }
    if ((1U & (IData)(triggers[0U]))) {
        VL_DBG_MSGS("         '" + tag + "' region trigger index 0 is active: Internal 'ico' trigger - first iteration\n");
    }
}
#endif  // VL_DEBUG

bool Vtb_store_buffer_cmo_metadata___024root___trigger_anySet__act(const VlUnpacked<QData/*63:0*/, 1> &in);

#ifdef VL_DEBUG
VL_ATTR_COLD void Vtb_store_buffer_cmo_metadata___024root___dump_triggers__act(const VlUnpacked<QData/*63:0*/, 1> &triggers, const std::string &tag) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_store_buffer_cmo_metadata___024root___dump_triggers__act\n"); );
    // Body
    if ((1U & (~ (IData)(Vtb_store_buffer_cmo_metadata___024root___trigger_anySet__act(triggers))))) {
        VL_DBG_MSGS("         No '" + tag + "' region triggers active\n");
    }
    if ((1U & (IData)(triggers[0U]))) {
        VL_DBG_MSGS("         '" + tag + "' region trigger index 0 is active: @(posedge tb_store_buffer_cmo_metadata.clk_i)\n");
    }
    if ((1U & (IData)((triggers[0U] >> 1U)))) {
        VL_DBG_MSGS("         '" + tag + "' region trigger index 1 is active: @(negedge tb_store_buffer_cmo_metadata.rst_ni)\n");
    }
    if ((1U & (IData)((triggers[0U] >> 2U)))) {
        VL_DBG_MSGS("         '" + tag + "' region trigger index 2 is active: @([true] __VdlySched.awaitingCurrentTime())\n");
    }
    if ((1U & (IData)((triggers[0U] >> 3U)))) {
        VL_DBG_MSGS("         '" + tag + "' region trigger index 3 is active: @(negedge tb_store_buffer_cmo_metadata.clk_i)\n");
    }
}
#endif  // VL_DEBUG

VL_ATTR_COLD void Vtb_store_buffer_cmo_metadata___024root___ctor_var_reset(Vtb_store_buffer_cmo_metadata___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_store_buffer_cmo_metadata___024root___ctor_var_reset\n"); );
    Vtb_store_buffer_cmo_metadata__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    const uint64_t __VscopeHash = VL_MURMUR64_HASH(vlSelf->vlNamep);
    vlSelf->tb_store_buffer_cmo_metadata__DOT__cmo_entry_op_o = VL_SCOPED_RAND_RESET_I(8, __VscopeHash, 5557358703131082378ull);
    for (int __Vi0 = 0; __Vi0 < 4; ++__Vi0) {
        VL_SCOPED_RAND_RESET_W(112, vlSelf->tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_queue_n[__Vi0], __VscopeHash, 1763580543497238004ull);
    }
    for (int __Vi0 = 0; __Vi0 < 4; ++__Vi0) {
        VL_SCOPED_RAND_RESET_W(112, vlSelf->tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_queue_q[__Vi0], __VscopeHash, 12217907190569931419ull);
    }
    for (int __Vi0 = 0; __Vi0 < 4; ++__Vi0) {
        VL_SCOPED_RAND_RESET_W(112, vlSelf->tb_store_buffer_cmo_metadata__DOT__dut__DOT__commit_queue_n[__Vi0], __VscopeHash, 6875037979016021819ull);
    }
    for (int __Vi0 = 0; __Vi0 < 4; ++__Vi0) {
        VL_SCOPED_RAND_RESET_W(112, vlSelf->tb_store_buffer_cmo_metadata__DOT__dut__DOT__commit_queue_q[__Vi0], __VscopeHash, 15725406425812867588ull);
    }
    vlSelf->tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_status_cnt_q = VL_SCOPED_RAND_RESET_I(3, __VscopeHash, 11965053961137078408ull);
    vlSelf->tb_store_buffer_cmo_metadata__DOT__dut__DOT__commit_status_cnt_q = VL_SCOPED_RAND_RESET_I(3, __VscopeHash, 3474590589878428455ull);
    vlSelf->tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_read_pointer_n = VL_SCOPED_RAND_RESET_I(2, __VscopeHash, 6623468028288406907ull);
    vlSelf->tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_read_pointer_q = VL_SCOPED_RAND_RESET_I(2, __VscopeHash, 5941088698011982552ull);
    vlSelf->tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_write_pointer_n = VL_SCOPED_RAND_RESET_I(2, __VscopeHash, 12225739301572460307ull);
    vlSelf->tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_write_pointer_q = VL_SCOPED_RAND_RESET_I(2, __VscopeHash, 10112092875643556571ull);
    vlSelf->tb_store_buffer_cmo_metadata__DOT__dut__DOT__commit_read_pointer_q = VL_SCOPED_RAND_RESET_I(2, __VscopeHash, 2032266635340961678ull);
    vlSelf->tb_store_buffer_cmo_metadata__DOT__dut__DOT__commit_write_pointer_q = VL_SCOPED_RAND_RESET_I(2, __VscopeHash, 1881587519152988129ull);
    vlSelf->__VdfgRegularize_h6e95ff9d_0_1 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_2 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_3 = 0;
    vlSelf->__Vsampled_TOP__tb_store_buffer_cmo_metadata__DOT__rst_ni = 0;
    vlSelf->__Vsampled_TOP__tb_store_buffer_cmo_metadata__DOT__flush_i = 0;
    for (int __Vi0 = 0; __Vi0 < 4; ++__Vi0) {
        VL_ZERO_RESET_W(112, vlSelf->__Vsampled_TOP__tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_queue_q[__Vi0]);
    }
    vlSelf->__Vsampled_TOP__tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_read_pointer_q = 0;
    vlSelf->__Vsampled_TOP__tb_store_buffer_cmo_metadata__DOT__cmo_entry_op_o = 0;
    vlSelf->__Vsampled_TOP__tb_store_buffer_cmo_metadata__DOT__commit_i = 0;
    vlSelf->__Vsampled_TOP__tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_status_cnt_q = 0;
    vlSelf->__Vsampled_TOP__tb_store_buffer_cmo_metadata__DOT__valid_i = 0;
    vlSelf->__Vsampled_TOP__tb_store_buffer_cmo_metadata__DOT__dut__DOT__commit_status_cnt_q = 0;
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
    vlSelf->__Vtrigprevexpr___TOP__tb_store_buffer_cmo_metadata__DOT__clk_i__0 = 0;
    vlSelf->__Vtrigprevexpr___TOP__tb_store_buffer_cmo_metadata__DOT__rst_ni__0 = 0;
    for (int __Vi0 = 0; __Vi0 < 1; ++__Vi0) {
        vlSelf->__VnbaTriggered[__Vi0] = 0;
    }
    vlSelf->__Vi = 0;
}
