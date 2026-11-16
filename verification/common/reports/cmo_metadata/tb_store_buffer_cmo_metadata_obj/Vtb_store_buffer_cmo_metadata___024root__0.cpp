// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vtb_store_buffer_cmo_metadata.h for the primary calling header

#include "Vtb_store_buffer_cmo_metadata__pch.h"

VlCoroutine Vtb_store_buffer_cmo_metadata___024root___eval_initial__TOP__Vtiming__0(Vtb_store_buffer_cmo_metadata___024root* vlSelf);
VlCoroutine Vtb_store_buffer_cmo_metadata___024root___eval_initial__TOP__Vtiming__1(Vtb_store_buffer_cmo_metadata___024root* vlSelf);

void Vtb_store_buffer_cmo_metadata___024root___eval_initial(Vtb_store_buffer_cmo_metadata___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_store_buffer_cmo_metadata___024root___eval_initial\n"); );
    Vtb_store_buffer_cmo_metadata__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    Vtb_store_buffer_cmo_metadata___024root___eval_initial__TOP__Vtiming__0(vlSelf);
    Vtb_store_buffer_cmo_metadata___024root___eval_initial__TOP__Vtiming__1(vlSelf);
}

void Vtb_store_buffer_cmo_metadata___024root___eval_sample(Vtb_store_buffer_cmo_metadata___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_store_buffer_cmo_metadata___024root___eval_sample\n"); );
    Vtb_store_buffer_cmo_metadata__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    vlSelfRef.__Vsampled_TOP__tb_store_buffer_cmo_metadata__DOT__rst_ni 
        = vlSelfRef.tb_store_buffer_cmo_metadata__DOT__rst_ni;
    vlSelfRef.__Vsampled_TOP__tb_store_buffer_cmo_metadata__DOT__flush_i 
        = vlSelfRef.tb_store_buffer_cmo_metadata__DOT__flush_i;
    vlSelfRef.__Vsampled_TOP__tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_queue_q 
        = vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_queue_q;
    vlSelfRef.__Vsampled_TOP__tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_read_pointer_q 
        = vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_read_pointer_q;
    vlSelfRef.__Vsampled_TOP__tb_store_buffer_cmo_metadata__DOT__cmo_entry_op_o 
        = vlSelfRef.tb_store_buffer_cmo_metadata__DOT__cmo_entry_op_o;
    vlSelfRef.__Vsampled_TOP__tb_store_buffer_cmo_metadata__DOT__commit_i 
        = vlSelfRef.tb_store_buffer_cmo_metadata__DOT__commit_i;
    vlSelfRef.__Vsampled_TOP__tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_status_cnt_q 
        = vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_status_cnt_q;
    vlSelfRef.__Vsampled_TOP__tb_store_buffer_cmo_metadata__DOT__valid_i 
        = vlSelfRef.tb_store_buffer_cmo_metadata__DOT__valid_i;
    vlSelfRef.__Vsampled_TOP__tb_store_buffer_cmo_metadata__DOT__dut__DOT__commit_status_cnt_q 
        = vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__commit_status_cnt_q;
}

#ifdef VL_DEBUG
VL_ATTR_COLD void Vtb_store_buffer_cmo_metadata___024root___dump_triggers__ico(const VlUnpacked<QData/*63:0*/, 1> &triggers, const std::string &tag);
#endif  // VL_DEBUG

bool Vtb_store_buffer_cmo_metadata___024root___eval_ico(Vtb_store_buffer_cmo_metadata___024root* vlSelf, CData/*0:0*/ firstIteration) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_store_buffer_cmo_metadata___024root___eval_ico\n"); );
    Vtb_store_buffer_cmo_metadata__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    vlSelfRef.__VicoTriggered[0U] = ((0xfffffffffffffffeULL 
                                      & vlSelfRef.__VicoTriggered[0U]) 
                                     | (IData)((IData)(firstIteration)));
#ifdef VL_DEBUG
    if (VL_UNLIKELY(vlSymsp->_vm_contextp__->debug())) {
        Vtb_store_buffer_cmo_metadata___024root___dump_triggers__ico(vlSelfRef.__VicoTriggered, "ico"s);
    }
#endif
    return (0U);
}

void Vtb_store_buffer_cmo_metadata___024root___timing_ready(Vtb_store_buffer_cmo_metadata___024root* vlSelf);
void Vtb_store_buffer_cmo_metadata___024root___trigger_orInto__act_vec_vec(VlUnpacked<QData/*63:0*/, 1> &out, const VlUnpacked<QData/*63:0*/, 1> &in);
#ifdef VL_DEBUG
VL_ATTR_COLD void Vtb_store_buffer_cmo_metadata___024root___dump_triggers__act(const VlUnpacked<QData/*63:0*/, 1> &triggers, const std::string &tag);
#endif  // VL_DEBUG
bool Vtb_store_buffer_cmo_metadata___024root___trigger_anySet__act(const VlUnpacked<QData/*63:0*/, 1> &in);
void Vtb_store_buffer_cmo_metadata___024root___timing_resume(Vtb_store_buffer_cmo_metadata___024root* vlSelf);
void Vtb_store_buffer_cmo_metadata___024root___act_comb__TOP__0(Vtb_store_buffer_cmo_metadata___024root* vlSelf);

bool Vtb_store_buffer_cmo_metadata___024root___eval_act(Vtb_store_buffer_cmo_metadata___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_store_buffer_cmo_metadata___024root___eval_act\n"); );
    Vtb_store_buffer_cmo_metadata__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    CData/*0:0*/ __VactExecute;
    // Body
    {
        // Inlined CFunc: _eval_triggers_vec__act
        vlSelfRef.__VactTriggered[0U] = (QData)((IData)(
                                                        (((((~ (IData)(vlSelfRef.tb_store_buffer_cmo_metadata__DOT__clk_i)) 
                                                            & (IData)(vlSelfRef.__Vtrigprevexpr___TOP__tb_store_buffer_cmo_metadata__DOT__clk_i__0)) 
                                                           << 3U) 
                                                          | (vlSelfRef.__VdlySched.awaitingCurrentTime() 
                                                             << 2U)) 
                                                         | ((((~ (IData)(vlSelfRef.tb_store_buffer_cmo_metadata__DOT__rst_ni)) 
                                                              & (IData)(vlSelfRef.__Vtrigprevexpr___TOP__tb_store_buffer_cmo_metadata__DOT__rst_ni__0)) 
                                                             << 1U) 
                                                            | ((IData)(vlSelfRef.tb_store_buffer_cmo_metadata__DOT__clk_i) 
                                                               & (~ (IData)(vlSelfRef.__Vtrigprevexpr___TOP__tb_store_buffer_cmo_metadata__DOT__clk_i__0)))))));
        vlSelfRef.__Vtrigprevexpr___TOP__tb_store_buffer_cmo_metadata__DOT__clk_i__0 
            = vlSelfRef.tb_store_buffer_cmo_metadata__DOT__clk_i;
        vlSelfRef.__Vtrigprevexpr___TOP__tb_store_buffer_cmo_metadata__DOT__rst_ni__0 
            = vlSelfRef.tb_store_buffer_cmo_metadata__DOT__rst_ni;
    }
    Vtb_store_buffer_cmo_metadata___024root___timing_ready(vlSelf);
    Vtb_store_buffer_cmo_metadata___024root___trigger_orInto__act_vec_vec(vlSelfRef.__VactTriggered, vlSelfRef.__VactTriggeredAcc);
#ifdef VL_DEBUG
    if (VL_UNLIKELY(vlSymsp->_vm_contextp__->debug())) {
        Vtb_store_buffer_cmo_metadata___024root___dump_triggers__act(vlSelfRef.__VactTriggered, "act"s);
    }
#endif
    Vtb_store_buffer_cmo_metadata___024root___trigger_orInto__act_vec_vec(vlSelfRef.__VnbaTriggered, vlSelfRef.__VactTriggered);
    __VactExecute = Vtb_store_buffer_cmo_metadata___024root___trigger_anySet__act(vlSelfRef.__VactTriggered);
    if (__VactExecute) {
        vlSelfRef.__VactTriggeredAcc.fill(0ULL);
        Vtb_store_buffer_cmo_metadata___024root___timing_resume(vlSelf);
        {
            // Inlined CFunc: _eval_body__act
            if ((0x000000000000000dULL & vlSelfRef.__VactTriggered[0U])) {
                Vtb_store_buffer_cmo_metadata___024root___act_comb__TOP__0(vlSelf);
            }
        }
    }
    return (__VactExecute);
}

bool Vtb_store_buffer_cmo_metadata___024root___eval_inact(Vtb_store_buffer_cmo_metadata___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_store_buffer_cmo_metadata___024root___eval_inact\n"); );
    Vtb_store_buffer_cmo_metadata__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    CData/*0:0*/ __VinactExecute;
    // Body
    __VinactExecute = vlSelfRef.__VdlySched.awaitingZeroDelay();
    if (__VinactExecute) {
        VL_FATAL_MT("tb_store_buffer_cmo_metadata.sv", 1, "", "ZERODLY: Design Verilated with '--no-sched-zero-delay', but #0 delay executed at runtime");
    }
    return (__VinactExecute);
}

void Vtb_store_buffer_cmo_metadata___024root___nba_sequent__TOP__0(Vtb_store_buffer_cmo_metadata___024root* vlSelf);
void Vtb_store_buffer_cmo_metadata___024root___nba_sequent__TOP__1(Vtb_store_buffer_cmo_metadata___024root* vlSelf);
void Vtb_store_buffer_cmo_metadata___024root___nba_comb__TOP__0(Vtb_store_buffer_cmo_metadata___024root* vlSelf);
void Vtb_store_buffer_cmo_metadata___024root___trigger_clear__act(VlUnpacked<QData/*63:0*/, 1> &out);

bool Vtb_store_buffer_cmo_metadata___024root___eval_nba(Vtb_store_buffer_cmo_metadata___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_store_buffer_cmo_metadata___024root___eval_nba\n"); );
    Vtb_store_buffer_cmo_metadata__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    CData/*0:0*/ __VnbaExecute;
    // Body
    __VnbaExecute = Vtb_store_buffer_cmo_metadata___024root___trigger_anySet__act(vlSelfRef.__VnbaTriggered);
    if (__VnbaExecute) {
        {
            // Inlined CFunc: _eval_body__nba
            if ((1ULL & vlSelfRef.__VnbaTriggered[0U])) {
                Vtb_store_buffer_cmo_metadata___024root___nba_sequent__TOP__0(vlSelf);
            }
            if ((3ULL & vlSelfRef.__VnbaTriggered[0U])) {
                Vtb_store_buffer_cmo_metadata___024root___nba_sequent__TOP__1(vlSelf);
            }
            if ((0x000000000000000fULL & vlSelfRef.__VnbaTriggered[0U])) {
                Vtb_store_buffer_cmo_metadata___024root___nba_comb__TOP__0(vlSelf);
            }
        }
        Vtb_store_buffer_cmo_metadata___024root___trigger_clear__act(vlSelfRef.__VnbaTriggered);
    }
    return (__VnbaExecute);
}

bool Vtb_store_buffer_cmo_metadata___024root___eval_obs(Vtb_store_buffer_cmo_metadata___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_store_buffer_cmo_metadata___024root___eval_obs\n"); );
    Vtb_store_buffer_cmo_metadata__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    return (0U);
}

bool Vtb_store_buffer_cmo_metadata___024root___eval_react(Vtb_store_buffer_cmo_metadata___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_store_buffer_cmo_metadata___024root___eval_react\n"); );
    Vtb_store_buffer_cmo_metadata__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    return (0U);
}

void Vtb_store_buffer_cmo_metadata___024root___eval_postponed(Vtb_store_buffer_cmo_metadata___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_store_buffer_cmo_metadata___024root___eval_postponed\n"); );
    Vtb_store_buffer_cmo_metadata__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
}

void Vtb_store_buffer_cmo_metadata___024root____VbeforeTrig_h6d618272__0(Vtb_store_buffer_cmo_metadata___024root* vlSelf, const char* __VeventDescription);
void Vtb_store_buffer_cmo_metadata___024root____VbeforeTrig_h6d618335__0(Vtb_store_buffer_cmo_metadata___024root* vlSelf, const char* __VeventDescription);

VlCoroutine Vtb_store_buffer_cmo_metadata___024root___eval_initial__TOP__Vtiming__0(Vtb_store_buffer_cmo_metadata___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_store_buffer_cmo_metadata___024root___eval_initial__TOP__Vtiming__0\n"); );
    Vtb_store_buffer_cmo_metadata__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    IData/*31:0*/ tb_store_buffer_cmo_metadata__DOT__unnamedblk1_1__DOT____Vrepeat0;
    tb_store_buffer_cmo_metadata__DOT__unnamedblk1_1__DOT____Vrepeat0 = 0;
    IData/*31:0*/ tb_store_buffer_cmo_metadata__DOT__unnamedblk1_2__DOT____Vrepeat1;
    tb_store_buffer_cmo_metadata__DOT__unnamedblk1_2__DOT____Vrepeat1 = 0;
    IData/*31:0*/ __Vtask_tb_store_buffer_cmo_metadata__DOT__push_entry__0__paddr;
    __Vtask_tb_store_buffer_cmo_metadata__DOT__push_entry__0__paddr = 0;
    IData/*31:0*/ __Vtask_tb_store_buffer_cmo_metadata__DOT__push_entry__0__vaddr;
    __Vtask_tb_store_buffer_cmo_metadata__DOT__push_entry__0__vaddr = 0;
    CData/*7:0*/ __Vtask_tb_store_buffer_cmo_metadata__DOT__push_entry__0__op;
    __Vtask_tb_store_buffer_cmo_metadata__DOT__push_entry__0__op = 0;
    IData/*31:0*/ __Vtask_tb_store_buffer_cmo_metadata__DOT__push_entry__1__paddr;
    __Vtask_tb_store_buffer_cmo_metadata__DOT__push_entry__1__paddr = 0;
    IData/*31:0*/ __Vtask_tb_store_buffer_cmo_metadata__DOT__push_entry__1__vaddr;
    __Vtask_tb_store_buffer_cmo_metadata__DOT__push_entry__1__vaddr = 0;
    CData/*7:0*/ __Vtask_tb_store_buffer_cmo_metadata__DOT__push_entry__1__op;
    __Vtask_tb_store_buffer_cmo_metadata__DOT__push_entry__1__op = 0;
    IData/*31:0*/ __Vtask_tb_store_buffer_cmo_metadata__DOT__push_entry__2__paddr;
    __Vtask_tb_store_buffer_cmo_metadata__DOT__push_entry__2__paddr = 0;
    IData/*31:0*/ __Vtask_tb_store_buffer_cmo_metadata__DOT__push_entry__2__vaddr;
    __Vtask_tb_store_buffer_cmo_metadata__DOT__push_entry__2__vaddr = 0;
    CData/*7:0*/ __Vtask_tb_store_buffer_cmo_metadata__DOT__push_entry__2__op;
    __Vtask_tb_store_buffer_cmo_metadata__DOT__push_entry__2__op = 0;
    // Body
    tb_store_buffer_cmo_metadata__DOT__unnamedblk1_1__DOT____Vrepeat0 = 2U;
    while (VL_LTS_III(32, 0U, tb_store_buffer_cmo_metadata__DOT__unnamedblk1_1__DOT____Vrepeat0)) {
        Vtb_store_buffer_cmo_metadata___024root____VbeforeTrig_h6d618272__0(vlSelf, 
                                                                            "@(posedge tb_store_buffer_cmo_metadata.clk_i)");
        co_await vlSelfRef.__VtrigSched_h6d618272__0.trigger(0U, 
                                                             nullptr, 
                                                             "@(posedge tb_store_buffer_cmo_metadata.clk_i)", 
                                                             "tb_store_buffer_cmo_metadata.sv", 
                                                             110);
        tb_store_buffer_cmo_metadata__DOT__unnamedblk1_1__DOT____Vrepeat0 
            = (tb_store_buffer_cmo_metadata__DOT__unnamedblk1_1__DOT____Vrepeat0 
               - (IData)(1U));
    }
    co_await vlSelfRef.__VdlySched.delay(1ULL, nullptr, 
                                         "tb_store_buffer_cmo_metadata.sv", 
                                         111);
    vlSelfRef.tb_store_buffer_cmo_metadata__DOT__rst_ni = 1U;
    __Vtask_tb_store_buffer_cmo_metadata__DOT__push_entry__0__op = 0U;
    __Vtask_tb_store_buffer_cmo_metadata__DOT__push_entry__0__vaddr = 0x40001010U;
    __Vtask_tb_store_buffer_cmo_metadata__DOT__push_entry__0__paddr = 0x80001010U;
    Vtb_store_buffer_cmo_metadata___024root____VbeforeTrig_h6d618335__0(vlSelf, 
                                                                        "@(negedge tb_store_buffer_cmo_metadata.clk_i)");
    co_await vlSelfRef.__VtrigSched_h6d618335__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(negedge tb_store_buffer_cmo_metadata.clk_i)", 
                                                         "tb_store_buffer_cmo_metadata.sv", 
                                                         94);
    vlSelfRef.tb_store_buffer_cmo_metadata__DOT__valid_i = 1U;
    vlSelfRef.tb_store_buffer_cmo_metadata__DOT__paddr_i 
        = __Vtask_tb_store_buffer_cmo_metadata__DOT__push_entry__0__paddr;
    vlSelfRef.tb_store_buffer_cmo_metadata__DOT__vaddr_i 
        = __Vtask_tb_store_buffer_cmo_metadata__DOT__push_entry__0__vaddr;
    vlSelfRef.tb_store_buffer_cmo_metadata__DOT__cbo_op_i 
        = __Vtask_tb_store_buffer_cmo_metadata__DOT__push_entry__0__op;
    vlSelfRef.tb_store_buffer_cmo_metadata__DOT__data_i = 0x5a5aa5a5U;
    vlSelfRef.tb_store_buffer_cmo_metadata__DOT__be_i = 0x0fU;
    Vtb_store_buffer_cmo_metadata___024root____VbeforeTrig_h6d618272__0(vlSelf, 
                                                                        "@(posedge tb_store_buffer_cmo_metadata.clk_i)");
    co_await vlSelfRef.__VtrigSched_h6d618272__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge tb_store_buffer_cmo_metadata.clk_i)", 
                                                         "tb_store_buffer_cmo_metadata.sv", 
                                                         102);
    co_await vlSelfRef.__VdlySched.delay(1ULL, nullptr, 
                                         "tb_store_buffer_cmo_metadata.sv", 
                                         103);
    vlSelfRef.tb_store_buffer_cmo_metadata__DOT__valid_i = 0U;
    vlSelfRef.tb_store_buffer_cmo_metadata__DOT__cbo_op_i = 0U;
    __Vtask_tb_store_buffer_cmo_metadata__DOT__push_entry__1__op = 1U;
    __Vtask_tb_store_buffer_cmo_metadata__DOT__push_entry__1__vaddr = 0x40002020U;
    __Vtask_tb_store_buffer_cmo_metadata__DOT__push_entry__1__paddr = 0x80002020U;
    if (VL_UNLIKELY((((vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_queue_q
                       [vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_read_pointer_q][0U] 
                       >> 1U) & (0U != (IData)(vlSelfRef.tb_store_buffer_cmo_metadata__DOT__cmo_entry_op_o)))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_store_buffer_cmo_metadata.sv:115: Assertion failed in %m: ordinary store was incorrectly exposed as a CMO entry\n",3, 'M',vlSymsp->name(),"tb_store_buffer_cmo_metadata", 'T',-12
                     , '#',64,VL_TIME_UNITED_Q(1));
        VL_STOP_MT("tb_store_buffer_cmo_metadata.sv", 115, "", false);
    }
    Vtb_store_buffer_cmo_metadata___024root____VbeforeTrig_h6d618335__0(vlSelf, 
                                                                        "@(negedge tb_store_buffer_cmo_metadata.clk_i)");
    co_await vlSelfRef.__VtrigSched_h6d618335__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(negedge tb_store_buffer_cmo_metadata.clk_i)", 
                                                         "tb_store_buffer_cmo_metadata.sv", 
                                                         94);
    vlSelfRef.tb_store_buffer_cmo_metadata__DOT__valid_i = 1U;
    vlSelfRef.tb_store_buffer_cmo_metadata__DOT__paddr_i 
        = __Vtask_tb_store_buffer_cmo_metadata__DOT__push_entry__1__paddr;
    vlSelfRef.tb_store_buffer_cmo_metadata__DOT__vaddr_i 
        = __Vtask_tb_store_buffer_cmo_metadata__DOT__push_entry__1__vaddr;
    vlSelfRef.tb_store_buffer_cmo_metadata__DOT__cbo_op_i 
        = __Vtask_tb_store_buffer_cmo_metadata__DOT__push_entry__1__op;
    vlSelfRef.tb_store_buffer_cmo_metadata__DOT__data_i = 0x5a5aa5a5U;
    vlSelfRef.tb_store_buffer_cmo_metadata__DOT__be_i = 0x0fU;
    Vtb_store_buffer_cmo_metadata___024root____VbeforeTrig_h6d618272__0(vlSelf, 
                                                                        "@(posedge tb_store_buffer_cmo_metadata.clk_i)");
    co_await vlSelfRef.__VtrigSched_h6d618272__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge tb_store_buffer_cmo_metadata.clk_i)", 
                                                         "tb_store_buffer_cmo_metadata.sv", 
                                                         102);
    co_await vlSelfRef.__VdlySched.delay(1ULL, nullptr, 
                                         "tb_store_buffer_cmo_metadata.sv", 
                                         103);
    vlSelfRef.tb_store_buffer_cmo_metadata__DOT__valid_i = 0U;
    vlSelfRef.tb_store_buffer_cmo_metadata__DOT__cbo_op_i = 0U;
    if (VL_UNLIKELY((((vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_queue_q
                       [vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_read_pointer_q][0U] 
                       >> 1U) & (0U != (IData)(vlSelfRef.tb_store_buffer_cmo_metadata__DOT__cmo_entry_op_o)))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_store_buffer_cmo_metadata.sv:119: Assertion failed in %m: CBO bypassed an older speculative store\n",3, 'M',vlSymsp->name(),"tb_store_buffer_cmo_metadata", 'T',-12
                     , '#',64,VL_TIME_UNITED_Q(1));
        VL_STOP_MT("tb_store_buffer_cmo_metadata.sv", 119, "", false);
    }
    Vtb_store_buffer_cmo_metadata___024root____VbeforeTrig_h6d618335__0(vlSelf, 
                                                                        "@(negedge tb_store_buffer_cmo_metadata.clk_i)");
    co_await vlSelfRef.__VtrigSched_h6d618335__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(negedge tb_store_buffer_cmo_metadata.clk_i)", 
                                                         "tb_store_buffer_cmo_metadata.sv", 
                                                         121);
    vlSelfRef.tb_store_buffer_cmo_metadata__DOT__commit_i = 1U;
    Vtb_store_buffer_cmo_metadata___024root____VbeforeTrig_h6d618272__0(vlSelf, 
                                                                        "@(posedge tb_store_buffer_cmo_metadata.clk_i)");
    co_await vlSelfRef.__VtrigSched_h6d618272__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge tb_store_buffer_cmo_metadata.clk_i)", 
                                                         "tb_store_buffer_cmo_metadata.sv", 
                                                         123);
    co_await vlSelfRef.__VdlySched.delay(1ULL, nullptr, 
                                         "tb_store_buffer_cmo_metadata.sv", 
                                         124);
    vlSelfRef.tb_store_buffer_cmo_metadata__DOT__commit_i = 0U;
    if (VL_UNLIKELY(((1U & ((((~ ((vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_queue_q
                                   [vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_read_pointer_q][0U] 
                                   >> 1U) & (0U != (IData)(vlSelfRef.tb_store_buffer_cmo_metadata__DOT__cmo_entry_op_o)))) 
                              | (1U != (IData)(vlSelfRef.tb_store_buffer_cmo_metadata__DOT__cmo_entry_op_o))) 
                             | (0x80002020U != ((vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_queue_q
                                                 [vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_read_pointer_q][3U] 
                                                 << 0x00000010U) 
                                                | (vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_queue_q
                                                   [vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_read_pointer_q][2U] 
                                                   >> 0x00000010U)))) 
                            | (0x40002020U != ((vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_queue_q
                                                [vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_read_pointer_q][2U] 
                                                << 0x00000010U) 
                                               | (vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_queue_q
                                                  [vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_read_pointer_q][1U] 
                                                  >> 0x00000010U)))))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_store_buffer_cmo_metadata.sv:129: Assertion failed in %m: head CBO metadata does not match the queued PA/VA/op\n",3, 'M',vlSymsp->name(),"tb_store_buffer_cmo_metadata", 'T',-12
                     , '#',64,VL_TIME_UNITED_Q(1));
        VL_STOP_MT("tb_store_buffer_cmo_metadata.sv", 129, "", false);
    }
    tb_store_buffer_cmo_metadata__DOT__unnamedblk1_2__DOT____Vrepeat1 = 3U;
    while (VL_LTS_III(32, 0U, tb_store_buffer_cmo_metadata__DOT__unnamedblk1_2__DOT____Vrepeat1)) {
        Vtb_store_buffer_cmo_metadata___024root____VbeforeTrig_h6d618272__0(vlSelf, 
                                                                            "@(posedge tb_store_buffer_cmo_metadata.clk_i)");
        co_await vlSelfRef.__VtrigSched_h6d618272__0.trigger(0U, 
                                                             nullptr, 
                                                             "@(posedge tb_store_buffer_cmo_metadata.clk_i)", 
                                                             "tb_store_buffer_cmo_metadata.sv", 
                                                             132);
        co_await vlSelfRef.__VdlySched.delay(1ULL, 
                                             nullptr, 
                                             "tb_store_buffer_cmo_metadata.sv", 
                                             133);
        if (VL_UNLIKELY(((1U & ((((~ ((vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_queue_q
                                       [vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_read_pointer_q][0U] 
                                       >> 1U) & (0U 
                                                 != (IData)(vlSelfRef.tb_store_buffer_cmo_metadata__DOT__cmo_entry_op_o)))) 
                                  | (0x80002020U != 
                                     ((vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_queue_q
                                       [vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_read_pointer_q][3U] 
                                       << 0x00000010U) 
                                      | (vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_queue_q
                                         [vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_read_pointer_q][2U] 
                                         >> 0x00000010U)))) 
                                 | (0x40002020U != 
                                    ((vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_queue_q
                                      [vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_read_pointer_q][2U] 
                                      << 0x00000010U) 
                                     | (vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_queue_q
                                        [vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_read_pointer_q][1U] 
                                        >> 0x00000010U)))) 
                                | (1U != (IData)(vlSelfRef.tb_store_buffer_cmo_metadata__DOT__cmo_entry_op_o))))))) {
            VL_WRITEF_NX("[%0t] %%Fatal: tb_store_buffer_cmo_metadata.sv:136: Assertion failed in %m: head CBO metadata changed without dequeue\n",3, 'M',vlSymsp->name(),"tb_store_buffer_cmo_metadata.unnamedblk1_2", 'T',-12
                         , '#',64,VL_TIME_UNITED_Q(1));
            VL_STOP_MT("tb_store_buffer_cmo_metadata.sv", 136, "", false);
        }
        tb_store_buffer_cmo_metadata__DOT__unnamedblk1_2__DOT____Vrepeat1 
            = (tb_store_buffer_cmo_metadata__DOT__unnamedblk1_2__DOT____Vrepeat1 
               - (IData)(1U));
    }
    Vtb_store_buffer_cmo_metadata___024root____VbeforeTrig_h6d618335__0(vlSelf, 
                                                                        "@(negedge tb_store_buffer_cmo_metadata.clk_i)");
    co_await vlSelfRef.__VtrigSched_h6d618335__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(negedge tb_store_buffer_cmo_metadata.clk_i)", 
                                                         "tb_store_buffer_cmo_metadata.sv", 
                                                         142);
    vlSelfRef.tb_store_buffer_cmo_metadata__DOT__commit_i = 1U;
    vlSelfRef.tb_store_buffer_cmo_metadata__DOT__flush_i = 1U;
    Vtb_store_buffer_cmo_metadata___024root____VbeforeTrig_h6d618272__0(vlSelf, 
                                                                        "@(posedge tb_store_buffer_cmo_metadata.clk_i)");
    co_await vlSelfRef.__VtrigSched_h6d618272__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge tb_store_buffer_cmo_metadata.clk_i)", 
                                                         "tb_store_buffer_cmo_metadata.sv", 
                                                         143);
    co_await vlSelfRef.__VdlySched.delay(1ULL, nullptr, 
                                         "tb_store_buffer_cmo_metadata.sv", 
                                         143);
    vlSelfRef.tb_store_buffer_cmo_metadata__DOT__commit_i = 0U;
    vlSelfRef.tb_store_buffer_cmo_metadata__DOT__flush_i = 0U;
    if (VL_UNLIKELY(((((vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_queue_q
                        [vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_read_pointer_q][0U] 
                        >> 1U) & (0U != (IData)(vlSelfRef.tb_store_buffer_cmo_metadata__DOT__cmo_entry_op_o))) 
                      | (1U != (IData)(vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__commit_status_cnt_q)))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_store_buffer_cmo_metadata.sv:145: Assertion failed in %m: external CBO duplicated in local commit queue\n",3, 'M',vlSymsp->name(),"tb_store_buffer_cmo_metadata", 'T',-12
                     , '#',64,VL_TIME_UNITED_Q(1));
        VL_STOP_MT("tb_store_buffer_cmo_metadata.sv", 145, "", false);
    }
    __Vtask_tb_store_buffer_cmo_metadata__DOT__push_entry__2__op = 3U;
    __Vtask_tb_store_buffer_cmo_metadata__DOT__push_entry__2__vaddr = 0x40003030U;
    __Vtask_tb_store_buffer_cmo_metadata__DOT__push_entry__2__paddr = 0x80003030U;
    Vtb_store_buffer_cmo_metadata___024root____VbeforeTrig_h6d618335__0(vlSelf, 
                                                                        "@(negedge tb_store_buffer_cmo_metadata.clk_i)");
    co_await vlSelfRef.__VtrigSched_h6d618335__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(negedge tb_store_buffer_cmo_metadata.clk_i)", 
                                                         "tb_store_buffer_cmo_metadata.sv", 
                                                         94);
    vlSelfRef.tb_store_buffer_cmo_metadata__DOT__valid_i = 1U;
    vlSelfRef.tb_store_buffer_cmo_metadata__DOT__paddr_i 
        = __Vtask_tb_store_buffer_cmo_metadata__DOT__push_entry__2__paddr;
    vlSelfRef.tb_store_buffer_cmo_metadata__DOT__vaddr_i 
        = __Vtask_tb_store_buffer_cmo_metadata__DOT__push_entry__2__vaddr;
    vlSelfRef.tb_store_buffer_cmo_metadata__DOT__cbo_op_i 
        = __Vtask_tb_store_buffer_cmo_metadata__DOT__push_entry__2__op;
    vlSelfRef.tb_store_buffer_cmo_metadata__DOT__data_i = 0x5a5aa5a5U;
    vlSelfRef.tb_store_buffer_cmo_metadata__DOT__be_i = 0x0fU;
    Vtb_store_buffer_cmo_metadata___024root____VbeforeTrig_h6d618272__0(vlSelf, 
                                                                        "@(posedge tb_store_buffer_cmo_metadata.clk_i)");
    co_await vlSelfRef.__VtrigSched_h6d618272__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge tb_store_buffer_cmo_metadata.clk_i)", 
                                                         "tb_store_buffer_cmo_metadata.sv", 
                                                         102);
    co_await vlSelfRef.__VdlySched.delay(1ULL, nullptr, 
                                         "tb_store_buffer_cmo_metadata.sv", 
                                         103);
    vlSelfRef.tb_store_buffer_cmo_metadata__DOT__valid_i = 0U;
    vlSelfRef.tb_store_buffer_cmo_metadata__DOT__cbo_op_i = 0U;
    if (VL_UNLIKELY(((1U & ((~ ((vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_queue_q
                                 [vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_read_pointer_q][0U] 
                                 >> 1U) & (0U != (IData)(vlSelfRef.tb_store_buffer_cmo_metadata__DOT__cmo_entry_op_o)))) 
                            | (0x40003030U != ((vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_queue_q
                                                [vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_read_pointer_q][2U] 
                                                << 0x00000010U) 
                                               | (vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_queue_q
                                                  [vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_read_pointer_q][1U] 
                                                  >> 0x00000010U)))))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_store_buffer_cmo_metadata.sv:148: Assertion failed in %m: commit-plus-flush corrupted speculative queue pointers\n",3, 'M',vlSymsp->name(),"tb_store_buffer_cmo_metadata", 'T',-12
                     , '#',64,VL_TIME_UNITED_Q(1));
        VL_STOP_MT("tb_store_buffer_cmo_metadata.sv", 148, "", false);
    }
    Vtb_store_buffer_cmo_metadata___024root____VbeforeTrig_h6d618335__0(vlSelf, 
                                                                        "@(negedge tb_store_buffer_cmo_metadata.clk_i)");
    co_await vlSelfRef.__VtrigSched_h6d618335__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(negedge tb_store_buffer_cmo_metadata.clk_i)", 
                                                         "tb_store_buffer_cmo_metadata.sv", 
                                                         150);
    vlSelfRef.tb_store_buffer_cmo_metadata__DOT__flush_i = 1U;
    Vtb_store_buffer_cmo_metadata___024root____VbeforeTrig_h6d618272__0(vlSelf, 
                                                                        "@(posedge tb_store_buffer_cmo_metadata.clk_i)");
    co_await vlSelfRef.__VtrigSched_h6d618272__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge tb_store_buffer_cmo_metadata.clk_i)", 
                                                         "tb_store_buffer_cmo_metadata.sv", 
                                                         152);
    co_await vlSelfRef.__VdlySched.delay(1ULL, nullptr, 
                                         "tb_store_buffer_cmo_metadata.sv", 
                                         153);
    if (VL_UNLIKELY((((vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_queue_q
                       [vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_read_pointer_q][0U] 
                       >> 1U) & (0U != (IData)(vlSelfRef.tb_store_buffer_cmo_metadata__DOT__cmo_entry_op_o)))))) {
        VL_WRITEF_NX("[%0t] %%Fatal: tb_store_buffer_cmo_metadata.sv:155: Assertion failed in %m: flush did not clear speculative CBO metadata\n",3, 'M',vlSymsp->name(),"tb_store_buffer_cmo_metadata", 'T',-12
                     , '#',64,VL_TIME_UNITED_Q(1));
        VL_STOP_MT("tb_store_buffer_cmo_metadata.sv", 155, "", false);
    }
    vlSelfRef.tb_store_buffer_cmo_metadata__DOT__flush_i = 0U;
    VL_WRITEF_NX("PASS: store-buffer CMO metadata capture, ordering, stability, and flush\n",0);
    VL_FINISH_MT("tb_store_buffer_cmo_metadata.sv", 158, "");
    co_return;
}

VlCoroutine Vtb_store_buffer_cmo_metadata___024root___eval_initial__TOP__Vtiming__1(Vtb_store_buffer_cmo_metadata___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_store_buffer_cmo_metadata___024root___eval_initial__TOP__Vtiming__1\n"); );
    Vtb_store_buffer_cmo_metadata__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    while (VL_LIKELY(!vlSymsp->_vm_contextp__->gotFinish())) {
        co_await vlSelfRef.__VdlySched.delay(5ULL, 
                                             nullptr, 
                                             "tb_store_buffer_cmo_metadata.sv", 
                                             55);
        vlSelfRef.tb_store_buffer_cmo_metadata__DOT__clk_i 
            = (1U & (~ (IData)(vlSelfRef.tb_store_buffer_cmo_metadata__DOT__clk_i)));
    }
    co_return;
}

bool Vtb_store_buffer_cmo_metadata___024root___trigger_anySet__ico(const VlUnpacked<QData/*63:0*/, 1> &in) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_store_buffer_cmo_metadata___024root___trigger_anySet__ico\n"); );
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

bool Vtb_store_buffer_cmo_metadata___024root___trigger_anySet__act(const VlUnpacked<QData/*63:0*/, 1> &in) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_store_buffer_cmo_metadata___024root___trigger_anySet__act\n"); );
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

void Vtb_store_buffer_cmo_metadata___024root___act_comb__TOP__0(Vtb_store_buffer_cmo_metadata___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_store_buffer_cmo_metadata___024root___act_comb__TOP__0\n"); );
    Vtb_store_buffer_cmo_metadata__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_2 = ((IData)(vlSelfRef.tb_store_buffer_cmo_metadata__DOT__commit_i) 
                                                & (0U 
                                                   == (IData)(vlSelfRef.tb_store_buffer_cmo_metadata__DOT__cmo_entry_op_o)));
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
}

void Vtb_store_buffer_cmo_metadata___024root___nba_sequent__TOP__0(Vtb_store_buffer_cmo_metadata___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_store_buffer_cmo_metadata___024root___nba_sequent__TOP__0\n"); );
    Vtb_store_buffer_cmo_metadata__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if (vlSymsp->_vm_contextp__->assertCtlGet(VerilatedAssertCtlQuery::ASSERT_CTL_ON, 1, 1)) {
        if (vlSymsp->_vm_contextp__->assertCtlGet(VerilatedAssertCtlQuery::ASSERT_CTL_FAIL_ON, 1, 1)) {
            if (VL_UNLIKELY(((1U & (~ ((~ ((IData)(vlSelfRef.__Vsampled_TOP__tb_store_buffer_cmo_metadata__DOT__rst_ni) 
                                           & (4U == (IData)(vlSelfRef.__Vsampled_TOP__tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_status_cnt_q)))) 
                                       | (~ (IData)(vlSelfRef.__Vsampled_TOP__tb_store_buffer_cmo_metadata__DOT__valid_i)))))))) {
                VL_WRITEF_NX("[%0t] %%Error: store_buffer.sv:329: Assertion failed in %m: [Speculative Queue] You are trying to push new data although the buffer is not ready\n",3, 'M',vlSymsp->name(),"tb_store_buffer_cmo_metadata.dut.speculative_buffer_overflow", 'T',-12
                             , '#',64,VL_TIME_UNITED_Q(1));
                VL_STOP_MT("../../modified/cva6/core\\store_buffer.sv", 329, "");
            }
            if (VL_UNLIKELY(((1U & (~ ((~ ((IData)(vlSelfRef.__Vsampled_TOP__tb_store_buffer_cmo_metadata__DOT__rst_ni) 
                                           & (4U == (IData)(vlSelfRef.__Vsampled_TOP__tb_store_buffer_cmo_metadata__DOT__dut__DOT__commit_status_cnt_q)))) 
                                       | (~ (IData)(vlSelfRef.__Vsampled_TOP__tb_store_buffer_cmo_metadata__DOT__commit_i)))))))) {
                VL_WRITEF_NX("[%0t] %%Error: store_buffer.sv:337: Assertion failed in %m: [Commit Queue] You are trying to commit a store although the buffer is full\n",3, 'M',vlSymsp->name(),"tb_store_buffer_cmo_metadata.dut.commit_buffer_overflow", 'T',-12
                             , '#',64,VL_TIME_UNITED_Q(1));
                VL_STOP_MT("../../modified/cva6/core\\store_buffer.sv", 337, "");
            }
            if (VL_UNLIKELY(((1U & (~ ((~ ((IData)(vlSelfRef.__Vsampled_TOP__tb_store_buffer_cmo_metadata__DOT__rst_ni) 
                                           & (0U == (IData)(vlSelfRef.__Vsampled_TOP__tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_status_cnt_q)))) 
                                       | (~ (IData)(vlSelfRef.__Vsampled_TOP__tb_store_buffer_cmo_metadata__DOT__commit_i)))))))) {
                VL_WRITEF_NX("[%0t] %%Error: store_buffer.sv:333: Assertion failed in %m: [Speculative Queue] You are committing although there are no stores to commit\n",3, 'M',vlSymsp->name(),"tb_store_buffer_cmo_metadata.dut.speculative_buffer_underflow", 'T',-12
                             , '#',64,VL_TIME_UNITED_Q(1));
                VL_STOP_MT("../../modified/cva6/core\\store_buffer.sv", 333, "");
            }
            if (VL_UNLIKELY(((1U & (~ ((~ (((IData)(vlSelfRef.__Vsampled_TOP__tb_store_buffer_cmo_metadata__DOT__rst_ni) 
                                            & (IData)(vlSelfRef.__Vsampled_TOP__tb_store_buffer_cmo_metadata__DOT__flush_i)) 
                                           & (~ ((vlSelfRef.__Vsampled_TOP__tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_queue_q
                                                  [vlSelfRef.__Vsampled_TOP__tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_read_pointer_q][0U] 
                                                  >> 1U) 
                                                 & (0U 
                                                    != (IData)(vlSelfRef.__Vsampled_TOP__tb_store_buffer_cmo_metadata__DOT__cmo_entry_op_o)))))) 
                                       | (~ (IData)(vlSelfRef.__Vsampled_TOP__tb_store_buffer_cmo_metadata__DOT__commit_i)))))))) {
                VL_WRITEF_NX("[%0t] %%Error: store_buffer.sv:324: Assertion failed in %m: [Commit Queue] You are trying to commit and flush in the same cycle\n",3, 'M',vlSymsp->name(),"tb_store_buffer_cmo_metadata.dut.commit_and_flush", 'T',-12
                             , '#',64,VL_TIME_UNITED_Q(1));
                VL_STOP_MT("../../modified/cva6/core\\store_buffer.sv", 324, "");
            }
        }
    }
}

void Vtb_store_buffer_cmo_metadata___024root___nba_sequent__TOP__1(Vtb_store_buffer_cmo_metadata___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_store_buffer_cmo_metadata___024root___nba_sequent__TOP__1\n"); );
    Vtb_store_buffer_cmo_metadata__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if (vlSelfRef.tb_store_buffer_cmo_metadata__DOT__rst_ni) {
        vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_status_cnt_q 
            = (7U & ((- (IData)((1U & (~ (IData)(vlSelfRef.tb_store_buffer_cmo_metadata__DOT__flush_i))))) 
                     & (((IData)(vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_status_cnt_q) 
                         + (IData)(vlSelfRef.tb_store_buffer_cmo_metadata__DOT__valid_i)) 
                        - (IData)(vlSelfRef.tb_store_buffer_cmo_metadata__DOT__commit_i))));
        vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__commit_write_pointer_q 
            = (3U & ((IData)(vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__commit_write_pointer_q) 
                     + (IData)(vlSelfRef.__VdfgRegularize_h6e95ff9d_0_2)));
        vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__commit_read_pointer_q 
            = vlSelfRef.__VdfgRegularize_h6e95ff9d_0_3;
        vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__commit_status_cnt_q 
            = (7U & ((IData)(vlSelfRef.__VdfgRegularize_h6e95ff9d_0_1) 
                     + (IData)(vlSelfRef.__VdfgRegularize_h6e95ff9d_0_2)));
        vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__commit_queue_q 
            = vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__commit_queue_n;
        vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_write_pointer_q 
            = vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_write_pointer_n;
        vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_queue_q 
            = vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_queue_n;
        vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_read_pointer_q 
            = vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_read_pointer_n;
    } else {
        vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_status_cnt_q = 0U;
        vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__commit_write_pointer_q = 0U;
        vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__commit_read_pointer_q = 0U;
        vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__commit_status_cnt_q = 0U;
        vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__commit_queue_q[3U][0U] = 0U;
        vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__commit_queue_q[3U][1U] = 0U;
        vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__commit_queue_q[3U][2U] = 0U;
        vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__commit_queue_q[3U][3U] = 0U;
        vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__commit_queue_q[2U][0U] = 0U;
        vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__commit_queue_q[2U][1U] = 0U;
        vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__commit_queue_q[2U][2U] = 0U;
        vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__commit_queue_q[2U][3U] = 0U;
        vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__commit_queue_q[1U][0U] = 0U;
        vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__commit_queue_q[1U][1U] = 0U;
        vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__commit_queue_q[1U][2U] = 0U;
        vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__commit_queue_q[1U][3U] = 0U;
        vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__commit_queue_q[0U][0U] = 0U;
        vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__commit_queue_q[0U][1U] = 0U;
        vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__commit_queue_q[0U][2U] = 0U;
        vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__commit_queue_q[0U][3U] = 0U;
        vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_write_pointer_q = 0U;
        vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_queue_q[3U][0U] = 0U;
        vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_queue_q[3U][1U] = 0U;
        vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_queue_q[3U][2U] = 0U;
        vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_queue_q[3U][3U] = 0U;
        vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_queue_q[2U][0U] = 0U;
        vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_queue_q[2U][1U] = 0U;
        vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_queue_q[2U][2U] = 0U;
        vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_queue_q[2U][3U] = 0U;
        vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_queue_q[1U][0U] = 0U;
        vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_queue_q[1U][1U] = 0U;
        vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_queue_q[1U][2U] = 0U;
        vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_queue_q[1U][3U] = 0U;
        vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_queue_q[0U][0U] = 0U;
        vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_queue_q[0U][1U] = 0U;
        vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_queue_q[0U][2U] = 0U;
        vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_queue_q[0U][3U] = 0U;
        vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_read_pointer_q = 0U;
    }
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_3 = vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__commit_read_pointer_q;
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_1 = vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__commit_status_cnt_q;
    vlSelfRef.tb_store_buffer_cmo_metadata__DOT__cmo_entry_op_o 
        = (0x000000ffU & (vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_queue_q
                          [vlSelfRef.tb_store_buffer_cmo_metadata__DOT__dut__DOT__speculative_read_pointer_q][0U] 
                          >> 2U));
}

void Vtb_store_buffer_cmo_metadata___024root___nba_comb__TOP__0(Vtb_store_buffer_cmo_metadata___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_store_buffer_cmo_metadata___024root___nba_comb__TOP__0\n"); );
    Vtb_store_buffer_cmo_metadata__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
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

void Vtb_store_buffer_cmo_metadata___024root___timing_ready(Vtb_store_buffer_cmo_metadata___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_store_buffer_cmo_metadata___024root___timing_ready\n"); );
    Vtb_store_buffer_cmo_metadata__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if ((1ULL & vlSelfRef.__VactTriggered[0U])) {
        vlSelfRef.__VtrigSched_h6d618272__0.ready("@(posedge tb_store_buffer_cmo_metadata.clk_i)");
    }
    if ((8ULL & vlSelfRef.__VactTriggered[0U])) {
        vlSelfRef.__VtrigSched_h6d618335__0.ready("@(negedge tb_store_buffer_cmo_metadata.clk_i)");
    }
}

void Vtb_store_buffer_cmo_metadata___024root___timing_resume(Vtb_store_buffer_cmo_metadata___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_store_buffer_cmo_metadata___024root___timing_resume\n"); );
    Vtb_store_buffer_cmo_metadata__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    vlSelfRef.__VtrigSched_h6d618272__0.moveToResumeQueue(
                                                          "@(posedge tb_store_buffer_cmo_metadata.clk_i)");
    vlSelfRef.__VtrigSched_h6d618335__0.moveToResumeQueue(
                                                          "@(negedge tb_store_buffer_cmo_metadata.clk_i)");
    vlSelfRef.__VtrigSched_h6d618272__0.resume("@(posedge tb_store_buffer_cmo_metadata.clk_i)");
    vlSelfRef.__VtrigSched_h6d618335__0.resume("@(negedge tb_store_buffer_cmo_metadata.clk_i)");
    if ((4ULL & vlSelfRef.__VactTriggered[0U])) {
        vlSelfRef.__VdlySched.resume();
    }
}

void Vtb_store_buffer_cmo_metadata___024root___trigger_orInto__act_vec_vec(VlUnpacked<QData/*63:0*/, 1> &out, const VlUnpacked<QData/*63:0*/, 1> &in) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_store_buffer_cmo_metadata___024root___trigger_orInto__act_vec_vec\n"); );
    // Locals
    IData/*31:0*/ n;
    // Body
    n = 0U;
    do {
        out[n] = (out[n] | in[n]);
        n = ((IData)(1U) + n);
    } while ((0U >= n));
}

void Vtb_store_buffer_cmo_metadata___024root___trigger_clear__act(VlUnpacked<QData/*63:0*/, 1> &out) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_store_buffer_cmo_metadata___024root___trigger_clear__act\n"); );
    // Locals
    IData/*31:0*/ n;
    // Body
    n = 0U;
    do {
        out[n] = 0ULL;
        n = ((IData)(1U) + n);
    } while ((1U > n));
}

void Vtb_store_buffer_cmo_metadata___024root____VbeforeTrig_h6d618272__0(Vtb_store_buffer_cmo_metadata___024root* vlSelf, const char* __VeventDescription) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_store_buffer_cmo_metadata___024root____VbeforeTrig_h6d618272__0\n"); );
    Vtb_store_buffer_cmo_metadata__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    VlUnpacked<QData/*63:0*/, 1> __VTmp;
    // Body
    __VTmp[0U] = (QData)((IData)(((((~ (IData)(vlSelfRef.tb_store_buffer_cmo_metadata__DOT__clk_i)) 
                                    & (IData)(vlSelfRef.__Vtrigprevexpr___TOP__tb_store_buffer_cmo_metadata__DOT__clk_i__0)) 
                                   << 3U) | ((IData)(vlSelfRef.tb_store_buffer_cmo_metadata__DOT__clk_i) 
                                             & (~ (IData)(vlSelfRef.__Vtrigprevexpr___TOP__tb_store_buffer_cmo_metadata__DOT__clk_i__0))))));
    vlSelfRef.__Vtrigprevexpr___TOP__tb_store_buffer_cmo_metadata__DOT__clk_i__0 
        = vlSelfRef.tb_store_buffer_cmo_metadata__DOT__clk_i;
    if ((1ULL & __VTmp[0U])) {
        vlSelfRef.__VtrigSched_h6d618272__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h6d618272__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h6d618272__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h6d618272__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h6d618272__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h6d618272__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h6d618272__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h6d618272__0.ready(__VeventDescription);
    }
    if ((8ULL & __VTmp[0U])) {
        vlSelfRef.__VtrigSched_h6d618335__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h6d618335__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h6d618335__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h6d618335__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h6d618335__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h6d618335__0.ready(__VeventDescription);
    }
    vlSelfRef.__VactTriggeredAcc[0U] = (vlSelfRef.__VactTriggeredAcc[0U] 
                                        | __VTmp[0U]);
}

void Vtb_store_buffer_cmo_metadata___024root____VbeforeTrig_h6d618335__0(Vtb_store_buffer_cmo_metadata___024root* vlSelf, const char* __VeventDescription) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_store_buffer_cmo_metadata___024root____VbeforeTrig_h6d618335__0\n"); );
    Vtb_store_buffer_cmo_metadata__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    VlUnpacked<QData/*63:0*/, 1> __VTmp;
    // Body
    __VTmp[0U] = (QData)((IData)(((((~ (IData)(vlSelfRef.tb_store_buffer_cmo_metadata__DOT__clk_i)) 
                                    & (IData)(vlSelfRef.__Vtrigprevexpr___TOP__tb_store_buffer_cmo_metadata__DOT__clk_i__0)) 
                                   << 3U) | ((IData)(vlSelfRef.tb_store_buffer_cmo_metadata__DOT__clk_i) 
                                             & (~ (IData)(vlSelfRef.__Vtrigprevexpr___TOP__tb_store_buffer_cmo_metadata__DOT__clk_i__0))))));
    vlSelfRef.__Vtrigprevexpr___TOP__tb_store_buffer_cmo_metadata__DOT__clk_i__0 
        = vlSelfRef.tb_store_buffer_cmo_metadata__DOT__clk_i;
    if ((1ULL & __VTmp[0U])) {
        vlSelfRef.__VtrigSched_h6d618272__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h6d618272__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h6d618272__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h6d618272__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h6d618272__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h6d618272__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h6d618272__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h6d618272__0.ready(__VeventDescription);
    }
    if ((8ULL & __VTmp[0U])) {
        vlSelfRef.__VtrigSched_h6d618335__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h6d618335__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h6d618335__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h6d618335__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h6d618335__0.ready(__VeventDescription);
        vlSelfRef.__VtrigSched_h6d618335__0.ready(__VeventDescription);
    }
    vlSelfRef.__VactTriggeredAcc[0U] = (vlSelfRef.__VactTriggeredAcc[0U] 
                                        | __VTmp[0U]);
}

#ifdef VL_DEBUG
void Vtb_store_buffer_cmo_metadata___024root___eval_debug_assertions(Vtb_store_buffer_cmo_metadata___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_store_buffer_cmo_metadata___024root___eval_debug_assertions\n"); );
    Vtb_store_buffer_cmo_metadata__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
}
#endif  // VL_DEBUG
