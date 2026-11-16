// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vtb_store_unit_cmo_metadata.h for the primary calling header

#include "Vtb_store_unit_cmo_metadata__pch.h"

VlCoroutine Vtb_store_unit_cmo_metadata___024root___eval_initial__TOP__Vtiming__0(Vtb_store_unit_cmo_metadata___024root* vlSelf);
VlCoroutine Vtb_store_unit_cmo_metadata___024root___eval_initial__TOP__Vtiming__1(Vtb_store_unit_cmo_metadata___024root* vlSelf);

void Vtb_store_unit_cmo_metadata___024root___eval_initial(Vtb_store_unit_cmo_metadata___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_store_unit_cmo_metadata___024root___eval_initial\n"); );
    Vtb_store_unit_cmo_metadata__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    Vtb_store_unit_cmo_metadata___024root___eval_initial__TOP__Vtiming__0(vlSelf);
    Vtb_store_unit_cmo_metadata___024root___eval_initial__TOP__Vtiming__1(vlSelf);
}

void Vtb_store_unit_cmo_metadata___024root___eval_sample(Vtb_store_unit_cmo_metadata___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_store_unit_cmo_metadata___024root___eval_sample\n"); );
    Vtb_store_unit_cmo_metadata__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    vlSelfRef.__Vsampled_TOP__tb_store_unit_cmo_metadata__DOT__dut__DOT__genblk1__DOT__i_amo_buffer__DOT__i_amo_fifo__DOT__status_cnt_q 
        = vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__genblk1__DOT__i_amo_buffer__DOT__i_amo_fifo__DOT__status_cnt_q;
    vlSelfRef.__Vsampled_TOP__tb_store_unit_cmo_metadata__DOT__dut__DOT__amo_buffer_valid 
        = vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__amo_buffer_valid;
    vlSelfRef.__Vsampled_TOP__tb_store_unit_cmo_metadata__DOT__rst_ni 
        = vlSelfRef.tb_store_unit_cmo_metadata__DOT__rst_ni;
    vlSelfRef.__Vsampled_TOP__tb_store_unit_cmo_metadata__DOT__dut__DOT__store_buffer_i__DOT__speculative_status_cnt_q 
        = vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__store_buffer_i__DOT__speculative_status_cnt_q;
    vlSelfRef.__Vsampled_TOP__tb_store_unit_cmo_metadata__DOT__dut__DOT__store_buffer_valid 
        = vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__store_buffer_valid;
}

#ifdef VL_DEBUG
VL_ATTR_COLD void Vtb_store_unit_cmo_metadata___024root___dump_triggers__ico(const VlUnpacked<QData/*63:0*/, 1> &triggers, const std::string &tag);
#endif  // VL_DEBUG

bool Vtb_store_unit_cmo_metadata___024root___eval_ico(Vtb_store_unit_cmo_metadata___024root* vlSelf, CData/*0:0*/ firstIteration) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_store_unit_cmo_metadata___024root___eval_ico\n"); );
    Vtb_store_unit_cmo_metadata__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    vlSelfRef.__VicoTriggered[0U] = ((0xfffffffffffffffeULL 
                                      & vlSelfRef.__VicoTriggered[0U]) 
                                     | (IData)((IData)(firstIteration)));
#ifdef VL_DEBUG
    if (VL_UNLIKELY(vlSymsp->_vm_contextp__->debug())) {
        Vtb_store_unit_cmo_metadata___024root___dump_triggers__ico(vlSelfRef.__VicoTriggered, "ico"s);
    }
#endif
    return (0U);
}

void Vtb_store_unit_cmo_metadata___024root___timing_ready(Vtb_store_unit_cmo_metadata___024root* vlSelf);
void Vtb_store_unit_cmo_metadata___024root___trigger_orInto__act_vec_vec(VlUnpacked<QData/*63:0*/, 1> &out, const VlUnpacked<QData/*63:0*/, 1> &in);
#ifdef VL_DEBUG
VL_ATTR_COLD void Vtb_store_unit_cmo_metadata___024root___dump_triggers__act(const VlUnpacked<QData/*63:0*/, 1> &triggers, const std::string &tag);
#endif  // VL_DEBUG
bool Vtb_store_unit_cmo_metadata___024root___trigger_anySet__act(const VlUnpacked<QData/*63:0*/, 1> &in);
void Vtb_store_unit_cmo_metadata___024root___timing_resume(Vtb_store_unit_cmo_metadata___024root* vlSelf);
void Vtb_store_unit_cmo_metadata___024root___act_comb__TOP__0(Vtb_store_unit_cmo_metadata___024root* vlSelf);

bool Vtb_store_unit_cmo_metadata___024root___eval_act(Vtb_store_unit_cmo_metadata___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_store_unit_cmo_metadata___024root___eval_act\n"); );
    Vtb_store_unit_cmo_metadata__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    CData/*0:0*/ __VactExecute;
    // Body
    {
        // Inlined CFunc: _eval_triggers_vec__act
        vlSelfRef.__VactTriggered[0U] = (QData)((IData)(
                                                        (((vlSelfRef.__VdlySched.awaitingCurrentTime() 
                                                           << 3U) 
                                                          | (((~ (IData)(vlSelfRef.tb_store_unit_cmo_metadata__DOT__clk_i)) 
                                                              & (IData)(vlSelfRef.__Vtrigprevexpr___TOP__tb_store_unit_cmo_metadata__DOT__clk_i__0)) 
                                                             << 2U)) 
                                                         | ((((~ (IData)(vlSelfRef.tb_store_unit_cmo_metadata__DOT__rst_ni)) 
                                                              & (IData)(vlSelfRef.__Vtrigprevexpr___TOP__tb_store_unit_cmo_metadata__DOT__rst_ni__0)) 
                                                             << 1U) 
                                                            | ((IData)(vlSelfRef.tb_store_unit_cmo_metadata__DOT__clk_i) 
                                                               & (~ (IData)(vlSelfRef.__Vtrigprevexpr___TOP__tb_store_unit_cmo_metadata__DOT__clk_i__0)))))));
        vlSelfRef.__Vtrigprevexpr___TOP__tb_store_unit_cmo_metadata__DOT__clk_i__0 
            = vlSelfRef.tb_store_unit_cmo_metadata__DOT__clk_i;
        vlSelfRef.__Vtrigprevexpr___TOP__tb_store_unit_cmo_metadata__DOT__rst_ni__0 
            = vlSelfRef.tb_store_unit_cmo_metadata__DOT__rst_ni;
    }
    Vtb_store_unit_cmo_metadata___024root___timing_ready(vlSelf);
    Vtb_store_unit_cmo_metadata___024root___trigger_orInto__act_vec_vec(vlSelfRef.__VactTriggered, vlSelfRef.__VactTriggeredAcc);
#ifdef VL_DEBUG
    if (VL_UNLIKELY(vlSymsp->_vm_contextp__->debug())) {
        Vtb_store_unit_cmo_metadata___024root___dump_triggers__act(vlSelfRef.__VactTriggered, "act"s);
    }
#endif
    Vtb_store_unit_cmo_metadata___024root___trigger_orInto__act_vec_vec(vlSelfRef.__VnbaTriggered, vlSelfRef.__VactTriggered);
    __VactExecute = Vtb_store_unit_cmo_metadata___024root___trigger_anySet__act(vlSelfRef.__VactTriggered);
    if (__VactExecute) {
        vlSelfRef.__VactTriggeredAcc.fill(0ULL);
        Vtb_store_unit_cmo_metadata___024root___timing_resume(vlSelf);
        {
            // Inlined CFunc: _eval_body__act
            if ((0x000000000000000dULL & vlSelfRef.__VactTriggered[0U])) {
                Vtb_store_unit_cmo_metadata___024root___act_comb__TOP__0(vlSelf);
            }
        }
    }
    return (__VactExecute);
}

bool Vtb_store_unit_cmo_metadata___024root___eval_inact(Vtb_store_unit_cmo_metadata___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_store_unit_cmo_metadata___024root___eval_inact\n"); );
    Vtb_store_unit_cmo_metadata__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    CData/*0:0*/ __VinactExecute;
    // Body
    __VinactExecute = vlSelfRef.__VdlySched.awaitingZeroDelay();
    if (__VinactExecute) {
        VL_FATAL_MT("tb_store_unit_cmo_metadata.sv", 1, "", "ZERODLY: Design Verilated with '--no-sched-zero-delay', but #0 delay executed at runtime");
    }
    return (__VinactExecute);
}

void Vtb_store_unit_cmo_metadata___024root___nba_sequent__TOP__0(Vtb_store_unit_cmo_metadata___024root* vlSelf);
void Vtb_store_unit_cmo_metadata___024root___nba_sequent__TOP__1(Vtb_store_unit_cmo_metadata___024root* vlSelf);
void Vtb_store_unit_cmo_metadata___024root___nba_comb__TOP__1(Vtb_store_unit_cmo_metadata___024root* vlSelf);
void Vtb_store_unit_cmo_metadata___024root___trigger_clear__act(VlUnpacked<QData/*63:0*/, 1> &out);

bool Vtb_store_unit_cmo_metadata___024root___eval_nba(Vtb_store_unit_cmo_metadata___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_store_unit_cmo_metadata___024root___eval_nba\n"); );
    Vtb_store_unit_cmo_metadata__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    CData/*0:0*/ __VnbaExecute;
    // Body
    __VnbaExecute = Vtb_store_unit_cmo_metadata___024root___trigger_anySet__act(vlSelfRef.__VnbaTriggered);
    if (__VnbaExecute) {
        {
            // Inlined CFunc: _eval_body__nba
            if ((1ULL & vlSelfRef.__VnbaTriggered[0U])) {
                Vtb_store_unit_cmo_metadata___024root___nba_sequent__TOP__0(vlSelf);
            }
            if ((3ULL & vlSelfRef.__VnbaTriggered[0U])) {
                Vtb_store_unit_cmo_metadata___024root___nba_sequent__TOP__1(vlSelf);
            }
            if ((0x000000000000000dULL & vlSelfRef.__VnbaTriggered[0U])) {
                {
                    // Inlined CFunc: _nba_comb__TOP__0
                    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_4 
                        = (3U & ((0x00000040U & vlSelfRef.tb_store_unit_cmo_metadata__DOT__ctrl[1U])
                                  ? (1U & (- (IData)(
                                                     (1U 
                                                      & (~ 
                                                         (vlSelfRef.tb_store_unit_cmo_metadata__DOT__ctrl[1U] 
                                                          >> 5U))))))
                                  : (2U | (- (IData)(
                                                     (1U 
                                                      & (~ 
                                                         (vlSelfRef.tb_store_unit_cmo_metadata__DOT__ctrl[1U] 
                                                          >> 5U))))))));
                    vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__instr_is_amo 
                        = ((0x3dU <= (0x000000ffU & 
                                      (vlSelfRef.tb_store_unit_cmo_metadata__DOT__ctrl[1U] 
                                       >> 5U))) & (0x52U 
                                                   >= 
                                                   (0x000000ffU 
                                                    & (vlSelfRef.tb_store_unit_cmo_metadata__DOT__ctrl[1U] 
                                                       >> 5U))));
                }
            }
            if ((0x000000000000000fULL & vlSelfRef.__VnbaTriggered[0U])) {
                Vtb_store_unit_cmo_metadata___024root___nba_comb__TOP__1(vlSelf);
            }
        }
        Vtb_store_unit_cmo_metadata___024root___trigger_clear__act(vlSelfRef.__VnbaTriggered);
    }
    return (__VnbaExecute);
}

bool Vtb_store_unit_cmo_metadata___024root___eval_obs(Vtb_store_unit_cmo_metadata___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_store_unit_cmo_metadata___024root___eval_obs\n"); );
    Vtb_store_unit_cmo_metadata__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    return (0U);
}

bool Vtb_store_unit_cmo_metadata___024root___eval_react(Vtb_store_unit_cmo_metadata___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_store_unit_cmo_metadata___024root___eval_react\n"); );
    Vtb_store_unit_cmo_metadata__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    return (0U);
}

void Vtb_store_unit_cmo_metadata___024root___eval_postponed(Vtb_store_unit_cmo_metadata___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_store_unit_cmo_metadata___024root___eval_postponed\n"); );
    Vtb_store_unit_cmo_metadata__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
}

void Vtb_store_unit_cmo_metadata___024root____VbeforeTrig_h2b5d7992__0(Vtb_store_unit_cmo_metadata___024root* vlSelf, const char* __VeventDescription);
void Vtb_store_unit_cmo_metadata___024root____VbeforeTrig_h2b5c8a55__0(Vtb_store_unit_cmo_metadata___024root* vlSelf, const char* __VeventDescription);

VlCoroutine Vtb_store_unit_cmo_metadata___024root___eval_initial__TOP__Vtiming__0(Vtb_store_unit_cmo_metadata___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_store_unit_cmo_metadata___024root___eval_initial__TOP__Vtiming__0\n"); );
    Vtb_store_unit_cmo_metadata__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    IData/*31:0*/ tb_store_unit_cmo_metadata__DOT__unnamedblk1_1__DOT____Vrepeat0;
    tb_store_unit_cmo_metadata__DOT__unnamedblk1_1__DOT____Vrepeat0 = 0;
    // Body
    tb_store_unit_cmo_metadata__DOT__unnamedblk1_1__DOT____Vrepeat0 = 2U;
    while (VL_LTS_III(32, 0U, tb_store_unit_cmo_metadata__DOT__unnamedblk1_1__DOT____Vrepeat0)) {
        Vtb_store_unit_cmo_metadata___024root____VbeforeTrig_h2b5d7992__0(vlSelf, 
                                                                          "@(posedge tb_store_unit_cmo_metadata.clk_i)");
        co_await vlSelfRef.__VtrigSched_h2b5d7992__0.trigger(0U, 
                                                             nullptr, 
                                                             "@(posedge tb_store_unit_cmo_metadata.clk_i)", 
                                                             "tb_store_unit_cmo_metadata.sv", 
                                                             65);
        tb_store_unit_cmo_metadata__DOT__unnamedblk1_1__DOT____Vrepeat0 
            = (tb_store_unit_cmo_metadata__DOT__unnamedblk1_1__DOT____Vrepeat0 
               - (IData)(1U));
    }
    Vtb_store_unit_cmo_metadata___024root____VbeforeTrig_h2b5c8a55__0(vlSelf, 
                                                                      "@(negedge tb_store_unit_cmo_metadata.clk_i)");
    co_await vlSelfRef.__VtrigSched_h2b5c8a55__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(negedge tb_store_unit_cmo_metadata.clk_i)", 
                                                         "tb_store_unit_cmo_metadata.sv", 
                                                         66);
    vlSelfRef.tb_store_unit_cmo_metadata__DOT__rst_ni = 1U;
    vlSelfRef.tb_store_unit_cmo_metadata__DOT__valid_i = 1U;
    vlSelfRef.tb_store_unit_cmo_metadata__DOT__ctrl[3U] 
        = (0x46000000U | (0x001fffffU & vlSelfRef.tb_store_unit_cmo_metadata__DOT__ctrl[3U]));
    vlSelfRef.tb_store_unit_cmo_metadata__DOT__ctrl[4U] = 0x00080002U;
    vlSelfRef.tb_store_unit_cmo_metadata__DOT__ctrl[5U] = 0U;
    vlSelfRef.tb_store_unit_cmo_metadata__DOT__ctrl[1U] 
        = (0x00000a60U | (0xffffe01fU & vlSelfRef.tb_store_unit_cmo_metadata__DOT__ctrl[1U]));
    Vtb_store_unit_cmo_metadata___024root____VbeforeTrig_h2b5c8a55__0(vlSelf, 
                                                                      "@(negedge tb_store_unit_cmo_metadata.clk_i)");
    co_await vlSelfRef.__VtrigSched_h2b5c8a55__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(negedge tb_store_unit_cmo_metadata.clk_i)", 
                                                         "tb_store_unit_cmo_metadata.sv", 
                                                         68);
    vlSelfRef.tb_store_unit_cmo_metadata__DOT__ctrl[3U] 
        = (0xac000000U | (0x001fffffU & vlSelfRef.tb_store_unit_cmo_metadata__DOT__ctrl[3U]));
    vlSelfRef.tb_store_unit_cmo_metadata__DOT__ctrl[4U] = 0x000a0008U;
    vlSelfRef.tb_store_unit_cmo_metadata__DOT__ctrl[5U] = 0U;
    vlSelfRef.tb_store_unit_cmo_metadata__DOT__ctrl[1U] 
        = (0x00000a80U | (0xffffe01fU & vlSelfRef.tb_store_unit_cmo_metadata__DOT__ctrl[1U]));
    vlSelfRef.tb_store_unit_cmo_metadata__DOT__pa = 0x0000000080001230ULL;
    Vtb_store_unit_cmo_metadata___024root____VbeforeTrig_h2b5d7992__0(vlSelf, 
                                                                      "@(posedge tb_store_unit_cmo_metadata.clk_i)");
    co_await vlSelfRef.__VtrigSched_h2b5d7992__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge tb_store_unit_cmo_metadata.clk_i)", 
                                                         "tb_store_unit_cmo_metadata.sv", 
                                                         72);
    co_await vlSelfRef.__VdlySched.delay(1ULL, nullptr, 
                                         "tb_store_unit_cmo_metadata.sv", 
                                         72);
    if (VL_UNLIKELY(((1U & ((((~ ((vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__store_buffer_i__DOT__speculative_queue_q
                                   [vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__store_buffer_i__DOT__speculative_read_pointer_q][0U] 
                                   >> 1U) & (0x56U 
                                             != (0x000000ffU 
                                                 & (vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__store_buffer_i__DOT__speculative_queue_q
                                                    [vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__store_buffer_i__DOT__speculative_read_pointer_q][0U] 
                                                    >> 2U))))) 
                              | (0x53U != (0x000000ffU 
                                           & (vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__store_buffer_i__DOT__speculative_queue_q
                                              [vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__store_buffer_i__DOT__speculative_read_pointer_q][0U] 
                                              >> 2U)))) 
                             | (0x0000000040001230ULL 
                                != (((QData)((IData)(vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__store_buffer_i__DOT__speculative_queue_q
                                                     [vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__store_buffer_i__DOT__speculative_read_pointer_q][4U])) 
                                     << 0x0000002cU) 
                                    | (((QData)((IData)(vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__store_buffer_i__DOT__speculative_queue_q
                                                        [vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__store_buffer_i__DOT__speculative_read_pointer_q][3U])) 
                                        << 0x0000000cU) 
                                       | ((QData)((IData)(vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__store_buffer_i__DOT__speculative_queue_q
                                                          [vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__store_buffer_i__DOT__speculative_read_pointer_q][2U])) 
                                          >> 0x00000014U))))) 
                            | (0x0000000080001230ULL 
                               != (0x00ffffffffffffffULL 
                                   & (((QData)((IData)(vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__store_buffer_i__DOT__speculative_queue_q
                                                       [vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__store_buffer_i__DOT__speculative_read_pointer_q][6U])) 
                                       << 0x0000002cU) 
                                      | (((QData)((IData)(vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__store_buffer_i__DOT__speculative_queue_q
                                                          [vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__store_buffer_i__DOT__speculative_read_pointer_q][5U])) 
                                          << 0x0000000cU) 
                                         | ((QData)((IData)(vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__store_buffer_i__DOT__speculative_queue_q
                                                            [vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__store_buffer_i__DOT__speculative_read_pointer_q][4U])) 
                                            >> 0x00000014U)))))))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_store_unit_cmo_metadata.sv:74: Assertion failed in %m: CBO metadata captured a younger instruction VA/op\n",3, 'M',vlSymsp->name(),"tb_store_unit_cmo_metadata", 'T',-12
                     , '#',64,VL_TIME_UNITED_Q(1));
        VL_STOP_MT("tb_store_unit_cmo_metadata.sv", 74, "", false);
    }
    vlSelfRef.tb_store_unit_cmo_metadata__DOT__valid_i = 0U;
    Vtb_store_unit_cmo_metadata___024root____VbeforeTrig_h2b5d7992__0(vlSelf, 
                                                                      "@(posedge tb_store_unit_cmo_metadata.clk_i)");
    co_await vlSelfRef.__VtrigSched_h2b5d7992__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge tb_store_unit_cmo_metadata.clk_i)", 
                                                         "tb_store_unit_cmo_metadata.sv", 
                                                         76);
    co_await vlSelfRef.__VdlySched.delay(1ULL, nullptr, 
                                         "tb_store_unit_cmo_metadata.sv", 
                                         76);
    if (VL_UNLIKELY(((0x0000000040001230ULL != (((QData)((IData)(vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__store_buffer_i__DOT__speculative_queue_q
                                                                 [vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__store_buffer_i__DOT__speculative_read_pointer_q][4U])) 
                                                 << 0x0000002cU) 
                                                | (((QData)((IData)(vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__store_buffer_i__DOT__speculative_queue_q
                                                                    [vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__store_buffer_i__DOT__speculative_read_pointer_q][3U])) 
                                                    << 0x0000000cU) 
                                                   | ((QData)((IData)(vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__store_buffer_i__DOT__speculative_queue_q
                                                                      [vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__store_buffer_i__DOT__speculative_read_pointer_q][2U])) 
                                                      >> 0x00000014U))))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_store_unit_cmo_metadata.sv:77: Assertion failed in %m: oldest CBO metadata changed\n",3, 'M',vlSymsp->name(),"tb_store_unit_cmo_metadata", 'T',-12
                     , '#',64,VL_TIME_UNITED_Q(1));
        VL_STOP_MT("tb_store_unit_cmo_metadata.sv", 77, "", false);
    }
    VL_WRITEF_NX("PASS: store-unit back-to-back CBO VA/op/PA alignment\n",0);
    VL_FINISH_MT("tb_store_unit_cmo_metadata.sv", 79, "");
    co_return;
}

VlCoroutine Vtb_store_unit_cmo_metadata___024root___eval_initial__TOP__Vtiming__1(Vtb_store_unit_cmo_metadata___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_store_unit_cmo_metadata___024root___eval_initial__TOP__Vtiming__1\n"); );
    Vtb_store_unit_cmo_metadata__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    while (VL_LIKELY(!vlSymsp->_vm_contextp__->gotFinish())) {
        co_await vlSelfRef.__VdlySched.delay(5ULL, 
                                             nullptr, 
                                             "tb_store_unit_cmo_metadata.sv", 
                                             53);
        vlSelfRef.tb_store_unit_cmo_metadata__DOT__clk_i 
            = (1U & (~ (IData)(vlSelfRef.tb_store_unit_cmo_metadata__DOT__clk_i)));
    }
    co_return;
}

bool Vtb_store_unit_cmo_metadata___024root___trigger_anySet__ico(const VlUnpacked<QData/*63:0*/, 1> &in) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_store_unit_cmo_metadata___024root___trigger_anySet__ico\n"); );
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

bool Vtb_store_unit_cmo_metadata___024root___trigger_anySet__act(const VlUnpacked<QData/*63:0*/, 1> &in) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_store_unit_cmo_metadata___024root___trigger_anySet__act\n"); );
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

void Vtb_store_unit_cmo_metadata___024root___act_comb__TOP__0(Vtb_store_unit_cmo_metadata___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_store_unit_cmo_metadata___024root___act_comb__TOP__0\n"); );
    Vtb_store_unit_cmo_metadata__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
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
}

void Vtb_store_unit_cmo_metadata___024root___nba_sequent__TOP__0(Vtb_store_unit_cmo_metadata___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_store_unit_cmo_metadata___024root___nba_sequent__TOP__0\n"); );
    Vtb_store_unit_cmo_metadata__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if (vlSymsp->_vm_contextp__->assertCtlGet(VerilatedAssertCtlQuery::ASSERT_CTL_ON, 1, 1)) {
        if (vlSymsp->_vm_contextp__->assertCtlGet(VerilatedAssertCtlQuery::ASSERT_CTL_FAIL_ON, 1, 1)) {
            if (VL_UNLIKELY(((1U & (~ ((~ ((IData)(vlSelfRef.__Vsampled_TOP__tb_store_unit_cmo_metadata__DOT__rst_ni) 
                                           & (4U == (IData)(vlSelfRef.__Vsampled_TOP__tb_store_unit_cmo_metadata__DOT__dut__DOT__store_buffer_i__DOT__speculative_status_cnt_q)))) 
                                       | (~ (IData)(vlSelfRef.__Vsampled_TOP__tb_store_unit_cmo_metadata__DOT__dut__DOT__store_buffer_valid)))))))) {
                VL_WRITEF_NX("[%0t] %%Error: store_buffer.sv:327: Assertion failed in %m: [Speculative Queue] You are trying to push new data although the buffer is not ready\n",3, 'M',vlSymsp->name(),"tb_store_unit_cmo_metadata.dut.store_buffer_i.speculative_buffer_overflow", 'T',-12
                             , '#',64,VL_TIME_UNITED_Q(1));
                VL_STOP_MT("C:/HQuan/102_MyGithub/VLSIT_RISCV_CPU/rtl/modified/cva6/core\\store_buffer.sv", 327, "");
            }
            if (vlSelfRef.tb_store_unit_cmo_metadata__DOT__rst_ni) {
                if (VL_UNLIKELY(((1U & (~ ((1U != (IData)(vlSelfRef.__Vsampled_TOP__tb_store_unit_cmo_metadata__DOT__dut__DOT__genblk1__DOT__i_amo_buffer__DOT__i_amo_fifo__DOT__status_cnt_q)) 
                                           | (~ (IData)(vlSelfRef.__Vsampled_TOP__tb_store_unit_cmo_metadata__DOT__dut__DOT__amo_buffer_valid)))))))) {
                    VL_WRITEF_NX("[%0t] %%Fatal: cva6_fifo_v3.sv:224: Assertion failed in %m: Trying to push new data although the FIFO is full.\n",3, 'M',vlSymsp->name(),"tb_store_unit_cmo_metadata.dut.genblk1.i_amo_buffer.i_amo_fifo.full_write", 'T',-12
                                 , '#',64,VL_TIME_UNITED_Q(1));
                    VL_STOP_MT("C:/HQuan/102_MyGithub/VLSIT_RISCV_CPU/rtl/third_party/cva6/core\\cva6_fifo_v3.sv", 224, "", false);
                }
            }
        }
    }
}

extern const VlWide<256>/*8191:0*/ Vtb_store_unit_cmo_metadata__ConstPool__CONST_h07167e63_0;
extern const VlWide<256>/*8191:0*/ Vtb_store_unit_cmo_metadata__ConstPool__CONST_hed66896b_0;

void Vtb_store_unit_cmo_metadata___024root___nba_sequent__TOP__1(Vtb_store_unit_cmo_metadata___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_store_unit_cmo_metadata___024root___nba_sequent__TOP__1\n"); );
    Vtb_store_unit_cmo_metadata__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    CData/*0:0*/ tb_store_unit_cmo_metadata__DOT__dut__DOT__st_valid;
    tb_store_unit_cmo_metadata__DOT__dut__DOT__st_valid = 0;
    // Body
    if (vlSelfRef.tb_store_unit_cmo_metadata__DOT__rst_ni) {
        vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__store_buffer_i__DOT__speculative_read_pointer_q 
            = vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__store_buffer_i__DOT__speculative_read_pointer_q;
        vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__genblk1__DOT__i_amo_buffer__DOT__i_amo_fifo__DOT__status_cnt_q 
            = (3U & ((IData)(vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__genblk1__DOT__i_amo_buffer__DOT__i_amo_fifo__DOT__status_cnt_q) 
                     + (IData)(vlSelfRef.__VdfgRegularize_h6e95ff9d_0_2)));
        vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__store_buffer_i__DOT__speculative_write_pointer_q 
            = (3U & ((IData)(vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__store_buffer_i__DOT__speculative_write_pointer_q) 
                     + (IData)(vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__store_buffer_valid)));
        vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__state_q 
            = ((0U == (IData)(vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__state_q))
                ? ((IData)(vlSelfRef.tb_store_unit_cmo_metadata__DOT__valid_i)
                    ? (1U | (IData)(vlSelfRef.__VdfgRegularize_h6e95ff9d_0_10))
                    : (IData)(vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__state_q))
                : ((1U == (IData)(vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__state_q))
                    ? ((- (IData)(((~ (IData)(vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__instr_is_amo)) 
                                   & (IData)(vlSelfRef.tb_store_unit_cmo_metadata__DOT__valid_i)))) 
                       & (1U | (IData)(vlSelfRef.__VdfgRegularize_h6e95ff9d_0_10)))
                    : ((3U == (IData)(vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__state_q))
                        ? ((IData)(vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__state_q) 
                           & (IData)(vlSelfRef.__VdfgRegularize_h6e95ff9d_0_10))
                        : ((IData)(vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__state_q) 
                           & (- (IData)((2U != (IData)(vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__state_q))))))));
        vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__store_buffer_i__DOT__speculative_status_cnt_q 
            = vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__store_buffer_i__DOT__speculative_status_cnt_n;
        vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__st_be_q 
            = (0x000000ffU & (vlSelfRef.tb_store_unit_cmo_metadata__DOT__ctrl[1U] 
                              >> 0x0000000dU));
        vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__st_vaddr_q 
            = (((QData)((IData)(vlSelfRef.tb_store_unit_cmo_metadata__DOT__ctrl[5U])) 
                << 0x0000002bU) | (((QData)((IData)(vlSelfRef.tb_store_unit_cmo_metadata__DOT__ctrl[4U])) 
                                    << 0x0000000bU) 
                                   | ((QData)((IData)(vlSelfRef.tb_store_unit_cmo_metadata__DOT__ctrl[3U])) 
                                      >> 0x00000015U)));
        vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__store_buffer_i__DOT__speculative_queue_q 
            = vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__store_buffer_i__DOT__speculative_queue_n;
        vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__cbo_op_q 
            = (0x000000ffU & Vtb_store_unit_cmo_metadata__ConstPool__CONST_h07167e63_0
               [(0x000000ffU & (vlSelfRef.tb_store_unit_cmo_metadata__DOT__ctrl[1U] 
                                >> 5U))]);
        vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__st_data_size_q 
            = (3U & (((0x00000800U & vlSelfRef.tb_store_unit_cmo_metadata__DOT__ctrl[1U])
                       ? ((0x00000400U & vlSelfRef.tb_store_unit_cmo_metadata__DOT__ctrl[1U])
                           ? (((0x00000100U & vlSelfRef.tb_store_unit_cmo_metadata__DOT__ctrl[1U])
                                ? ((IData)(vlSelfRef.__VdfgRegularize_h6e95ff9d_0_4) 
                                   | (- (IData)((1U 
                                                 & (vlSelfRef.tb_store_unit_cmo_metadata__DOT__ctrl[1U] 
                                                    >> 7U)))))
                                : ((IData)(vlSelfRef.__VdfgRegularize_h6e95ff9d_0_4) 
                                   | (- (IData)((1U 
                                                 & (~ 
                                                    (vlSelfRef.tb_store_unit_cmo_metadata__DOT__ctrl[1U] 
                                                     >> 7U))))))) 
                              | (- (IData)((1U & (vlSelfRef.tb_store_unit_cmo_metadata__DOT__ctrl[1U] 
                                                  >> 9U)))))
                           : ((0x00000200U & vlSelfRef.tb_store_unit_cmo_metadata__DOT__ctrl[1U])
                               ? (((0x00000080U & vlSelfRef.tb_store_unit_cmo_metadata__DOT__ctrl[1U])
                                    ? (- (IData)((1U 
                                                  & (vlSelfRef.tb_store_unit_cmo_metadata__DOT__ctrl[1U] 
                                                     >> 6U))))
                                    : ((- (IData)((1U 
                                                   & (~ 
                                                      (vlSelfRef.tb_store_unit_cmo_metadata__DOT__ctrl[1U] 
                                                       >> 6U))))) 
                                       | (- (IData)(
                                                    (1U 
                                                     & (~ 
                                                        (vlSelfRef.tb_store_unit_cmo_metadata__DOT__ctrl[1U] 
                                                         >> 5U))))))) 
                                  | (- (IData)((1U 
                                                & (vlSelfRef.tb_store_unit_cmo_metadata__DOT__ctrl[1U] 
                                                   >> 8U)))))
                               : ((0x00000100U & vlSelfRef.tb_store_unit_cmo_metadata__DOT__ctrl[1U])
                                   ? (2U | ((- (IData)(
                                                       (1U 
                                                        & (vlSelfRef.tb_store_unit_cmo_metadata__DOT__ctrl[1U] 
                                                           >> 6U)))) 
                                            | (- (IData)(
                                                         (1U 
                                                          & (vlSelfRef.tb_store_unit_cmo_metadata__DOT__ctrl[1U] 
                                                             >> 7U))))))
                                   : ((0x00000080U 
                                       & vlSelfRef.tb_store_unit_cmo_metadata__DOT__ctrl[1U])
                                       ? 2U : ((0x00000040U 
                                                & vlSelfRef.tb_store_unit_cmo_metadata__DOT__ctrl[1U])
                                                ? 2U
                                                : (2U 
                                                   | (- (IData)(
                                                                (1U 
                                                                 & (~ 
                                                                    (vlSelfRef.tb_store_unit_cmo_metadata__DOT__ctrl[1U] 
                                                                     >> 5U)))))))))))
                       : (((0x00000200U & vlSelfRef.tb_store_unit_cmo_metadata__DOT__ctrl[1U])
                            ? ((0x00000100U & vlSelfRef.tb_store_unit_cmo_metadata__DOT__ctrl[1U])
                                ? ((0x00000080U & vlSelfRef.tb_store_unit_cmo_metadata__DOT__ctrl[1U])
                                    ? (2U | (- (IData)(
                                                       (1U 
                                                        & (~ 
                                                           (vlSelfRef.tb_store_unit_cmo_metadata__DOT__ctrl[1U] 
                                                            >> 5U))))))
                                    : ((0x00000040U 
                                        & vlSelfRef.tb_store_unit_cmo_metadata__DOT__ctrl[1U])
                                        ? (2U | (- (IData)(
                                                           (1U 
                                                            & (vlSelfRef.tb_store_unit_cmo_metadata__DOT__ctrl[1U] 
                                                               >> 5U)))))
                                        : ((0x00000020U 
                                            & vlSelfRef.tb_store_unit_cmo_metadata__DOT__ctrl[1U])
                                            ? 2U : 1U)))
                                : ((0x00000080U & vlSelfRef.tb_store_unit_cmo_metadata__DOT__ctrl[1U])
                                    ? ((0x00000040U 
                                        & vlSelfRef.tb_store_unit_cmo_metadata__DOT__ctrl[1U])
                                        ? (2U & (- (IData)(
                                                           (1U 
                                                            & (~ 
                                                               (vlSelfRef.tb_store_unit_cmo_metadata__DOT__ctrl[1U] 
                                                                >> 5U))))))
                                        : ((0x00000020U 
                                            & vlSelfRef.tb_store_unit_cmo_metadata__DOT__ctrl[1U])
                                            ? 2U : 1U))
                                    : (1U & (- (IData)(
                                                       (1U 
                                                        & (vlSelfRef.tb_store_unit_cmo_metadata__DOT__ctrl[1U] 
                                                           >> 6U)))))))
                            : ((0x00000100U & vlSelfRef.tb_store_unit_cmo_metadata__DOT__ctrl[1U])
                                ? ((0x00000080U & vlSelfRef.tb_store_unit_cmo_metadata__DOT__ctrl[1U])
                                    ? (1U & ((- (IData)(
                                                        (1U 
                                                         & (~ 
                                                            (vlSelfRef.tb_store_unit_cmo_metadata__DOT__ctrl[1U] 
                                                             >> 6U))))) 
                                             & (- (IData)(
                                                          (1U 
                                                           & (~ 
                                                              (vlSelfRef.tb_store_unit_cmo_metadata__DOT__ctrl[1U] 
                                                               >> 5U)))))))
                                    : ((0x00000040U 
                                        & vlSelfRef.tb_store_unit_cmo_metadata__DOT__ctrl[1U])
                                        ? 1U : 2U))
                                : (2U | ((- (IData)(
                                                    (1U 
                                                     & (~ 
                                                        (vlSelfRef.tb_store_unit_cmo_metadata__DOT__ctrl[1U] 
                                                         >> 5U))))) 
                                         | ((- (IData)(
                                                       (1U 
                                                        & (~ 
                                                           (vlSelfRef.tb_store_unit_cmo_metadata__DOT__ctrl[1U] 
                                                            >> 7U))))) 
                                            | (- (IData)(
                                                         (1U 
                                                          & (~ 
                                                             (vlSelfRef.tb_store_unit_cmo_metadata__DOT__ctrl[1U] 
                                                              >> 6U)))))))))) 
                          | (- (IData)((1U & (~ (vlSelfRef.tb_store_unit_cmo_metadata__DOT__ctrl[1U] 
                                                 >> 0x0000000aU))))))) 
                     | (- (IData)((1U & (vlSelfRef.tb_store_unit_cmo_metadata__DOT__ctrl[1U] 
                                         >> 0x0000000cU))))));
        vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__st_data_q 
            = ((IData)(vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__instr_is_amo)
                ? (((QData)((IData)(vlSelfRef.tb_store_unit_cmo_metadata__DOT__ctrl[3U])) 
                    << 0x0000002bU) | (((QData)((IData)(vlSelfRef.tb_store_unit_cmo_metadata__DOT__ctrl[2U])) 
                                        << 0x0000000bU) 
                                       | ((QData)((IData)(vlSelfRef.tb_store_unit_cmo_metadata__DOT__ctrl[1U])) 
                                          >> 0x00000015U)))
                : ((0x00800000U & vlSelfRef.tb_store_unit_cmo_metadata__DOT__ctrl[3U])
                    ? ((0x00400000U & vlSelfRef.tb_store_unit_cmo_metadata__DOT__ctrl[3U])
                        ? ((0x00200000U & vlSelfRef.tb_store_unit_cmo_metadata__DOT__ctrl[3U])
                            ? (((QData)((IData)((0x000000ffU 
                                                 & (vlSelfRef.tb_store_unit_cmo_metadata__DOT__ctrl[1U] 
                                                    >> 0x00000015U)))) 
                                << 0x00000038U) | (0x00ffffffffffffffULL 
                                                   & (((QData)((IData)(vlSelfRef.tb_store_unit_cmo_metadata__DOT__ctrl[3U])) 
                                                       << 0x00000023U) 
                                                      | (((QData)((IData)(vlSelfRef.tb_store_unit_cmo_metadata__DOT__ctrl[2U])) 
                                                          << 3U) 
                                                         | ((QData)((IData)(vlSelfRef.tb_store_unit_cmo_metadata__DOT__ctrl[1U])) 
                                                            >> 0x0000001dU)))))
                            : (((QData)((IData)((0x0000ffffU 
                                                 & ((vlSelfRef.tb_store_unit_cmo_metadata__DOT__ctrl[2U] 
                                                     << 0x0000000bU) 
                                                    | (vlSelfRef.tb_store_unit_cmo_metadata__DOT__ctrl[1U] 
                                                       >> 0x00000015U))))) 
                                << 0x00000030U) | (0x0000ffffffffffffULL 
                                                   & (((QData)((IData)(vlSelfRef.tb_store_unit_cmo_metadata__DOT__ctrl[3U])) 
                                                       << 0x0000001bU) 
                                                      | ((QData)((IData)(vlSelfRef.tb_store_unit_cmo_metadata__DOT__ctrl[2U])) 
                                                         >> 5U)))))
                        : ((0x00200000U & vlSelfRef.tb_store_unit_cmo_metadata__DOT__ctrl[3U])
                            ? (((QData)((IData)((0x00ffffffU 
                                                 & ((vlSelfRef.tb_store_unit_cmo_metadata__DOT__ctrl[2U] 
                                                     << 0x0000000bU) 
                                                    | (vlSelfRef.tb_store_unit_cmo_metadata__DOT__ctrl[1U] 
                                                       >> 0x00000015U))))) 
                                << 0x00000028U) | (0x000000ffffffffffULL 
                                                   & (((QData)((IData)(vlSelfRef.tb_store_unit_cmo_metadata__DOT__ctrl[3U])) 
                                                       << 0x00000013U) 
                                                      | ((QData)((IData)(vlSelfRef.tb_store_unit_cmo_metadata__DOT__ctrl[2U])) 
                                                         >> 0x0000000dU))))
                            : (((QData)((IData)(((vlSelfRef.tb_store_unit_cmo_metadata__DOT__ctrl[2U] 
                                                  << 0x0000000bU) 
                                                 | (vlSelfRef.tb_store_unit_cmo_metadata__DOT__ctrl[1U] 
                                                    >> 0x00000015U)))) 
                                << 0x00000020U) | (QData)((IData)(
                                                                  ((vlSelfRef.tb_store_unit_cmo_metadata__DOT__ctrl[3U] 
                                                                    << 0x0000000bU) 
                                                                   | (vlSelfRef.tb_store_unit_cmo_metadata__DOT__ctrl[2U] 
                                                                      >> 0x00000015U)))))))
                    : ((0x00400000U & vlSelfRef.tb_store_unit_cmo_metadata__DOT__ctrl[3U])
                        ? ((0x00200000U & vlSelfRef.tb_store_unit_cmo_metadata__DOT__ctrl[3U])
                            ? ((0xffffffffff000000ULL 
                                & (((QData)((IData)(vlSelfRef.tb_store_unit_cmo_metadata__DOT__ctrl[2U])) 
                                    << 0x00000023U) 
                                   | (0xffffffffff000000ULL 
                                      & ((QData)((IData)(vlSelfRef.tb_store_unit_cmo_metadata__DOT__ctrl[1U])) 
                                         << 3U)))) 
                               | (QData)((IData)((0x00ffffffU 
                                                  & ((vlSelfRef.tb_store_unit_cmo_metadata__DOT__ctrl[3U] 
                                                      << 3U) 
                                                     | (vlSelfRef.tb_store_unit_cmo_metadata__DOT__ctrl[2U] 
                                                        >> 0x0000001dU))))))
                            : ((0xffffffffffff0000ULL 
                                & (((QData)((IData)(vlSelfRef.tb_store_unit_cmo_metadata__DOT__ctrl[3U])) 
                                    << 0x0000003bU) 
                                   | (((QData)((IData)(vlSelfRef.tb_store_unit_cmo_metadata__DOT__ctrl[2U])) 
                                       << 0x0000001bU) 
                                      | (0x07ffffffffff0000ULL 
                                         & ((QData)((IData)(vlSelfRef.tb_store_unit_cmo_metadata__DOT__ctrl[1U])) 
                                            >> 5U))))) 
                               | (QData)((IData)((0x0000ffffU 
                                                  & (vlSelfRef.tb_store_unit_cmo_metadata__DOT__ctrl[3U] 
                                                     >> 5U))))))
                        : ((0x00200000U & vlSelfRef.tb_store_unit_cmo_metadata__DOT__ctrl[3U])
                            ? ((0xffffffffffffff00ULL 
                                & (((QData)((IData)(vlSelfRef.tb_store_unit_cmo_metadata__DOT__ctrl[3U])) 
                                    << 0x00000033U) 
                                   | (((QData)((IData)(vlSelfRef.tb_store_unit_cmo_metadata__DOT__ctrl[2U])) 
                                       << 0x00000013U) 
                                      | (0x0007ffffffffff00ULL 
                                         & ((QData)((IData)(vlSelfRef.tb_store_unit_cmo_metadata__DOT__ctrl[1U])) 
                                            >> 0x0000000dU))))) 
                               | (QData)((IData)((0x000000ffU 
                                                  & (vlSelfRef.tb_store_unit_cmo_metadata__DOT__ctrl[3U] 
                                                     >> 0x0000000dU)))))
                            : (((QData)((IData)(vlSelfRef.tb_store_unit_cmo_metadata__DOT__ctrl[3U])) 
                                << 0x0000002bU) | (
                                                   ((QData)((IData)(vlSelfRef.tb_store_unit_cmo_metadata__DOT__ctrl[2U])) 
                                                    << 0x0000000bU) 
                                                   | ((QData)((IData)(vlSelfRef.tb_store_unit_cmo_metadata__DOT__ctrl[1U])) 
                                                      >> 0x00000015U)))))));
        vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__amo_op_q 
            = (0x0000000fU & Vtb_store_unit_cmo_metadata__ConstPool__CONST_hed66896b_0
               [(0x000000ffU & (vlSelfRef.tb_store_unit_cmo_metadata__DOT__ctrl[1U] 
                                >> 5U))]);
    } else {
        vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__store_buffer_i__DOT__speculative_read_pointer_q = 0U;
        vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__genblk1__DOT__i_amo_buffer__DOT__i_amo_fifo__DOT__status_cnt_q = 0U;
        vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__store_buffer_i__DOT__speculative_write_pointer_q = 0U;
        vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__state_q = 0U;
        vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__store_buffer_i__DOT__speculative_status_cnt_q = 0U;
        vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__st_be_q = 0U;
        vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__st_vaddr_q = 0ULL;
        vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__store_buffer_i__DOT__speculative_queue_q[3U][0U] = 0U;
        vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__store_buffer_i__DOT__speculative_queue_q[3U][1U] = 0U;
        vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__store_buffer_i__DOT__speculative_queue_q[3U][2U] = 0U;
        vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__store_buffer_i__DOT__speculative_queue_q[3U][3U] = 0U;
        vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__store_buffer_i__DOT__speculative_queue_q[3U][4U] = 0U;
        vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__store_buffer_i__DOT__speculative_queue_q[3U][5U] = 0U;
        vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__store_buffer_i__DOT__speculative_queue_q[3U][6U] = 0U;
        vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__store_buffer_i__DOT__speculative_queue_q[2U][0U] = 0U;
        vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__store_buffer_i__DOT__speculative_queue_q[2U][1U] = 0U;
        vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__store_buffer_i__DOT__speculative_queue_q[2U][2U] = 0U;
        vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__store_buffer_i__DOT__speculative_queue_q[2U][3U] = 0U;
        vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__store_buffer_i__DOT__speculative_queue_q[2U][4U] = 0U;
        vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__store_buffer_i__DOT__speculative_queue_q[2U][5U] = 0U;
        vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__store_buffer_i__DOT__speculative_queue_q[2U][6U] = 0U;
        vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__store_buffer_i__DOT__speculative_queue_q[1U][0U] = 0U;
        vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__store_buffer_i__DOT__speculative_queue_q[1U][1U] = 0U;
        vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__store_buffer_i__DOT__speculative_queue_q[1U][2U] = 0U;
        vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__store_buffer_i__DOT__speculative_queue_q[1U][3U] = 0U;
        vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__store_buffer_i__DOT__speculative_queue_q[1U][4U] = 0U;
        vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__store_buffer_i__DOT__speculative_queue_q[1U][5U] = 0U;
        vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__store_buffer_i__DOT__speculative_queue_q[1U][6U] = 0U;
        vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__store_buffer_i__DOT__speculative_queue_q[0U][0U] = 0U;
        vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__store_buffer_i__DOT__speculative_queue_q[0U][1U] = 0U;
        vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__store_buffer_i__DOT__speculative_queue_q[0U][2U] = 0U;
        vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__store_buffer_i__DOT__speculative_queue_q[0U][3U] = 0U;
        vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__store_buffer_i__DOT__speculative_queue_q[0U][4U] = 0U;
        vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__store_buffer_i__DOT__speculative_queue_q[0U][5U] = 0U;
        vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__store_buffer_i__DOT__speculative_queue_q[0U][6U] = 0U;
        vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__cbo_op_q = 0x00000056U;
        vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__st_data_size_q = 0U;
        vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__st_data_q = 0ULL;
        vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__amo_op_q = 0U;
    }
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
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_10 = (3U 
                                                 & (- (IData)(
                                                              (1U 
                                                               & (~ 
                                                                  ((0U 
                                                                    == (IData)(vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__genblk1__DOT__i_amo_buffer__DOT__i_amo_fifo__DOT__status_cnt_q)) 
                                                                   & (4U 
                                                                      > (IData)(vlSelfRef.tb_store_unit_cmo_metadata__DOT__dut__DOT__store_buffer_i__DOT__speculative_status_cnt_n))))))));
}

void Vtb_store_unit_cmo_metadata___024root___nba_comb__TOP__1(Vtb_store_unit_cmo_metadata___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_store_unit_cmo_metadata___024root___nba_comb__TOP__1\n"); );
    Vtb_store_unit_cmo_metadata__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
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
}

void Vtb_store_unit_cmo_metadata___024root___timing_ready(Vtb_store_unit_cmo_metadata___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_store_unit_cmo_metadata___024root___timing_ready\n"); );
    Vtb_store_unit_cmo_metadata__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if ((1ULL & vlSelfRef.__VactTriggered[0U])) {
        vlSelfRef.__VtrigSched_h2b5d7992__0.ready("@(posedge tb_store_unit_cmo_metadata.clk_i)");
    }
    if ((4ULL & vlSelfRef.__VactTriggered[0U])) {
        vlSelfRef.__VtrigSched_h2b5c8a55__0.ready("@(negedge tb_store_unit_cmo_metadata.clk_i)");
    }
}

void Vtb_store_unit_cmo_metadata___024root___timing_resume(Vtb_store_unit_cmo_metadata___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_store_unit_cmo_metadata___024root___timing_resume\n"); );
    Vtb_store_unit_cmo_metadata__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    vlSelfRef.__VtrigSched_h2b5d7992__0.moveToResumeQueue(
                                                          "@(posedge tb_store_unit_cmo_metadata.clk_i)");
    vlSelfRef.__VtrigSched_h2b5c8a55__0.moveToResumeQueue(
                                                          "@(negedge tb_store_unit_cmo_metadata.clk_i)");
    vlSelfRef.__VtrigSched_h2b5d7992__0.resume("@(posedge tb_store_unit_cmo_metadata.clk_i)");
    vlSelfRef.__VtrigSched_h2b5c8a55__0.resume("@(negedge tb_store_unit_cmo_metadata.clk_i)");
    if ((8ULL & vlSelfRef.__VactTriggered[0U])) {
        vlSelfRef.__VdlySched.resume();
    }
}

void Vtb_store_unit_cmo_metadata___024root___trigger_orInto__act_vec_vec(VlUnpacked<QData/*63:0*/, 1> &out, const VlUnpacked<QData/*63:0*/, 1> &in) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_store_unit_cmo_metadata___024root___trigger_orInto__act_vec_vec\n"); );
    // Locals
    IData/*31:0*/ n;
    // Body
    n = 0U;
    do {
        out[n] = (out[n] | in[n]);
        n = ((IData)(1U) + n);
    } while ((0U >= n));
}

void Vtb_store_unit_cmo_metadata___024root___trigger_clear__act(VlUnpacked<QData/*63:0*/, 1> &out) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_store_unit_cmo_metadata___024root___trigger_clear__act\n"); );
    // Locals
    IData/*31:0*/ n;
    // Body
    n = 0U;
    do {
        out[n] = 0ULL;
        n = ((IData)(1U) + n);
    } while ((1U > n));
}

void Vtb_store_unit_cmo_metadata___024root____VbeforeTrig_h2b5d7992__0(Vtb_store_unit_cmo_metadata___024root* vlSelf, const char* __VeventDescription) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_store_unit_cmo_metadata___024root____VbeforeTrig_h2b5d7992__0\n"); );
    Vtb_store_unit_cmo_metadata__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    VlUnpacked<QData/*63:0*/, 1> __VTmp;
    // Body
    __VTmp[0U] = (QData)((IData)(((((~ (IData)(vlSelfRef.tb_store_unit_cmo_metadata__DOT__clk_i)) 
                                    & (IData)(vlSelfRef.__Vtrigprevexpr___TOP__tb_store_unit_cmo_metadata__DOT__clk_i__0)) 
                                   << 2U) | ((IData)(vlSelfRef.tb_store_unit_cmo_metadata__DOT__clk_i) 
                                             & (~ (IData)(vlSelfRef.__Vtrigprevexpr___TOP__tb_store_unit_cmo_metadata__DOT__clk_i__0))))));
    vlSelfRef.__Vtrigprevexpr___TOP__tb_store_unit_cmo_metadata__DOT__clk_i__0 
        = vlSelfRef.tb_store_unit_cmo_metadata__DOT__clk_i;
    if ((1ULL & __VTmp[0U])) {
        vlSelfRef.__VtrigSched_h2b5d7992__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h2b5d7992__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h2b5d7992__0.ready(__VeventDescription);
    }
    if ((4ULL & __VTmp[0U])) {
        vlSelfRef.__VtrigSched_h2b5c8a55__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h2b5c8a55__0.ready(__VeventDescription);
    }
    vlSelfRef.__VactTriggeredAcc[0U] = (vlSelfRef.__VactTriggeredAcc[0U] 
                                        | __VTmp[0U]);
}

void Vtb_store_unit_cmo_metadata___024root____VbeforeTrig_h2b5c8a55__0(Vtb_store_unit_cmo_metadata___024root* vlSelf, const char* __VeventDescription) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_store_unit_cmo_metadata___024root____VbeforeTrig_h2b5c8a55__0\n"); );
    Vtb_store_unit_cmo_metadata__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    VlUnpacked<QData/*63:0*/, 1> __VTmp;
    // Body
    __VTmp[0U] = (QData)((IData)(((((~ (IData)(vlSelfRef.tb_store_unit_cmo_metadata__DOT__clk_i)) 
                                    & (IData)(vlSelfRef.__Vtrigprevexpr___TOP__tb_store_unit_cmo_metadata__DOT__clk_i__0)) 
                                   << 2U) | ((IData)(vlSelfRef.tb_store_unit_cmo_metadata__DOT__clk_i) 
                                             & (~ (IData)(vlSelfRef.__Vtrigprevexpr___TOP__tb_store_unit_cmo_metadata__DOT__clk_i__0))))));
    vlSelfRef.__Vtrigprevexpr___TOP__tb_store_unit_cmo_metadata__DOT__clk_i__0 
        = vlSelfRef.tb_store_unit_cmo_metadata__DOT__clk_i;
    if ((1ULL & __VTmp[0U])) {
        vlSelfRef.__VtrigSched_h2b5d7992__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h2b5d7992__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h2b5d7992__0.ready(__VeventDescription);
    }
    if ((4ULL & __VTmp[0U])) {
        vlSelfRef.__VtrigSched_h2b5c8a55__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h2b5c8a55__0.ready(__VeventDescription);
    }
    vlSelfRef.__VactTriggeredAcc[0U] = (vlSelfRef.__VactTriggeredAcc[0U] 
                                        | __VTmp[0U]);
}

#ifdef VL_DEBUG
void Vtb_store_unit_cmo_metadata___024root___eval_debug_assertions(Vtb_store_unit_cmo_metadata___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_store_unit_cmo_metadata___024root___eval_debug_assertions\n"); );
    Vtb_store_unit_cmo_metadata__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
}
#endif  // VL_DEBUG
