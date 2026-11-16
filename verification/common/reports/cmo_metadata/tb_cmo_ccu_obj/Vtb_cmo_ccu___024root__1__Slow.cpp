// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vtb_cmo_ccu.h for the primary calling header

#include "Vtb_cmo_ccu__pch.h"

VL_ATTR_COLD void Vtb_cmo_ccu___024root___stl_sequent__TOP__1(Vtb_cmo_ccu___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_cmo_ccu___024root___stl_sequent__TOP__1\n"); );
    Vtb_cmo_ccu__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    CData/*0:0*/ __VdfgRegularize_h6e95ff9d_0_479;
    __VdfgRegularize_h6e95ff9d_0_479 = 0;
    CData/*0:0*/ __VdfgRegularize_h6e95ff9d_0_482;
    __VdfgRegularize_h6e95ff9d_0_482 = 0;
    CData/*0:0*/ __VdfgRegularize_h6e95ff9d_0_485;
    __VdfgRegularize_h6e95ff9d_0_485 = 0;
    CData/*0:0*/ __VdfgRegularize_h6e95ff9d_0_489;
    __VdfgRegularize_h6e95ff9d_0_489 = 0;
    // Body
    vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__w_fsm_ctx_nxt_state[6U] 
        = vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__reg_fsm_ctx_current_state[6U];
    if ((0x00000010U & vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__reg_fsm_ctx_current_state[6U])) {
        if ((8U & vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__reg_fsm_ctx_current_state[6U])) {
            vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__w_fsm_ctx_nxt_state[6U] = 0U;
        } else if ((4U & vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__reg_fsm_ctx_current_state[6U])) {
            vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__w_fsm_ctx_nxt_state[6U] = 0U;
        } else if ((2U & vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__reg_fsm_ctx_current_state[6U])) {
            vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__w_fsm_ctx_nxt_state[6U] = 0U;
        } else if ((1U & vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__reg_fsm_ctx_current_state[6U])) {
            if (((IData)(vlSelfRef.tb_cmo_ccu__DOT__fv) 
                 & (IData)(vlSelfRef.tb_cmo_ccu__DOT__fr))) {
                vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__w_fsm_ctx_nxt_state[6U] 
                    = (((IData)(vlSelfRef.tb_cmo_ccu__DOT__fc) 
                        & (~ ((IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__reg_ctx_gnt_err) 
                              >> 6U))) ? 8U : 0x0aU);
            }
        } else if (vlSelfRef.tb_cmo_ccu__DOT__pr) {
            vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__w_fsm_ctx_nxt_state[6U] = 0x11U;
        }
    } else if ((8U & vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__reg_fsm_ctx_current_state[6U])) {
        if ((4U & vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__reg_fsm_ctx_current_state[6U])) {
            if ((2U & vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__reg_fsm_ctx_current_state[6U])) {
                if ((1U & vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__reg_fsm_ctx_current_state[6U])) {
                    if ((0x00000040U & (IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__w_release_hs))) {
                        vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__w_fsm_ctx_nxt_state[6U] = 0U;
                    }
                } else if ((1U == (7U & (vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_txn_table__DOT__reg_ctx_src 
                                         >> 0x12U)))) {
                    if ((0x00000040U & (IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__w_release_hs))) {
                        vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__w_fsm_ctx_nxt_state[6U] = 0U;
                    }
                } else if ((1U & ((IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__w_gnt_load) 
                                  >> (3U & ((IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__reg_ctx_hart) 
                                            >> 0x0cU))))) {
                    vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__w_fsm_ctx_nxt_state[6U] = 0x0fU;
                }
            } else if ((1U & vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__reg_fsm_ctx_current_state[6U])) {
                if ((1U & ((~ ((IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__reg_ctx_dir_reserved) 
                               >> 6U)) | ((IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_sharer_directory__DOT__w_cancel_hs) 
                                          >> (3U & 
                                              (vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_txn_table__DOT__reg_ctx_pa_line[9U] 
                                               >> 0x00000018U)))))) {
                    vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__w_fsm_ctx_nxt_state[6U] = 0x0eU;
                }
            } else if ((1U & ((IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_sharer_directory__DOT__w_update_hs) 
                              >> (3U & (vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_txn_table__DOT__reg_ctx_pa_line[9U] 
                                        >> 0x00000018U))))) {
                vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__w_fsm_ctx_nxt_state[6U] = 0x0eU;
            }
        } else if ((2U & vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__reg_fsm_ctx_current_state[6U])) {
            if ((1U & vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__reg_fsm_ctx_current_state[6U])) {
                if ((1U & (((IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_txn_table__DOT__reg_ctx_phase_done) 
                            >> 6U) & (~ ((IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_txn_table__DOT__reg_ctx_phase_err) 
                                         >> 6U))))) {
                    vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__w_fsm_ctx_nxt_state[6U] 
                        = ((0x00000040U & (IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__reg_ctx_is_victim))
                            ? ((0x00000040U & (IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__w_release_hs))
                                ? 0U : 0x0fU) : ((0x00000040U 
                                                  & (IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__reg_ctx_dir_reserved))
                                                  ? 0x0dU
                                                  : 0x0eU));
                }
            } else if ((((IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__w_phase_start_hs) 
                         & (2U == (IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__w_phase_start_phase))) 
                        & (6U == (IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__w_phase_start_tag)))) {
                vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__w_fsm_ctx_nxt_state[6U] = 0x0bU;
            }
        } else if ((1U & vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__reg_fsm_ctx_current_state[6U])) {
            if ((1U & (((IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_txn_table__DOT__reg_ctx_phase_done) 
                        >> 6U) & (~ ((IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_txn_table__DOT__reg_ctx_phase_err) 
                                     >> 6U))))) {
                vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__w_fsm_ctx_nxt_state[6U] 
                    = ((0x00000040U & (IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__reg_ctx_is_victim))
                        ? ((0x00000040U & (IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__w_release_hs))
                            ? 0U : 0x0fU) : ((IData)(
                                                     ((0x00040000U 
                                                       == 
                                                       (0x001c0000U 
                                                        & vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_txn_table__DOT__reg_ctx_src)) 
                                                      & (~ 
                                                         ((IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__reg_ctx_cmo_dir_hit) 
                                                          >> 6U))))
                                              ? 0x0dU
                                              : 0x0cU));
            }
        } else if ((((IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__w_phase_start_hs) 
                     & (1U == (IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__w_phase_start_phase))) 
                    & (6U == (IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__w_phase_start_tag)))) {
            vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__w_fsm_ctx_nxt_state[6U] = 9U;
        }
    } else if ((4U & vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__reg_fsm_ctx_current_state[6U])) {
        if ((2U & vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__reg_fsm_ctx_current_state[6U])) {
            if ((1U & vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__reg_fsm_ctx_current_state[6U])) {
                if ((0x00000040U & (IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_txn_table__DOT__reg_ctx_phase_done))) {
                    vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__w_fsm_ctx_nxt_state[6U] 
                        = ((1U == (7U & (vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_txn_table__DOT__reg_ctx_src 
                                         >> 0x12U)))
                            ? 0x10U : ((1U & (((((IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_txn_table__DOT__reg_ctx_phase_err) 
                                                 | (IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_txn_table__DOT__reg_ctx_txn_err)) 
                                                | (IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_txn_table__DOT__reg_ctx_owner_wback_err)) 
                                               >> 6U) 
                                              | ((((IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_txn_table__DOT__reg_ctx_owner_present) 
                                                   & (IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_txn_table__DOT__reg_ctx_wback_en)) 
                                                  >> 6U) 
                                                 & (~ 
                                                    ((IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_txn_table__DOT__reg_ctx_owner_wback_done) 
                                                     >> 6U)))))
                                        ? 0x0aU : 8U));
                }
            } else if ((((IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__w_phase_start_hs) 
                         & (0U == (IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__w_phase_start_phase))) 
                        & (6U == (IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__w_phase_start_tag)))) {
                vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__w_fsm_ctx_nxt_state[6U] = 7U;
            }
        } else if ((1U & vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__reg_fsm_ctx_current_state[6U])) {
            if (((IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__w_owner_capture_valid) 
                 & (6U == (IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__w_owner_capture_tag)))) {
                vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__w_fsm_ctx_nxt_state[6U] = 6U;
            }
        }
    } else if ((2U & vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__reg_fsm_ctx_current_state[6U])) {
        if ((1U & vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__reg_fsm_ctx_current_state[6U])) {
            if (((((IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__w_alloc_valid) 
                   & (IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__w_alloc_ready)) 
                  & (IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__w_internal_pick_valid)) 
                 & (6U != (IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_txn_table__DOT__w_alloc_tag)))) {
                vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__w_fsm_ctx_nxt_state[6U] = 4U;
            }
        } else if ((0x00000040U & (IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__w_lookup_rsp_hs))) {
            vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__w_fsm_ctx_nxt_state[6U] 
                = ((1U == (7U & (vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_txn_table__DOT__reg_ctx_src 
                                 >> 0x12U))) ? 5U : 
                   ((((~ ((IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_sharer_directory__DOT__reg_lookup_hit) 
                          >> (3U & (vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_txn_table__DOT__reg_ctx_pa_line[9U] 
                                    >> 0x00000018U)))) 
                      & ((IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_sharer_directory__DOT__reg_lookup_victim_valid) 
                         >> (3U & (vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_txn_table__DOT__reg_ctx_pa_line[9U] 
                                   >> 0x00000018U)))) 
                     & (0U != (0x0000000fU & ((IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_sharer_directory__DOT__reg_lookup_holders) 
                                              >> (0x0000000cU 
                                                  & (vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_txn_table__DOT__reg_ctx_pa_line[9U] 
                                                     >> 0x00000016U))))))
                     ? 3U : 5U));
        }
    } else if ((1U & vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__reg_fsm_ctx_current_state[6U])) {
        if ((1U & (((IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__w_dir_lookup_valid) 
                    >> (3U & (vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_txn_table__DOT__reg_ctx_pa_line[9U] 
                              >> 0x00000018U))) & ((IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__w_dir_lookup_ready) 
                                                   >> 
                                                   (3U 
                                                    & (vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_txn_table__DOT__reg_ctx_pa_line[9U] 
                                                       >> 0x00000018U)))))) {
            vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__w_fsm_ctx_nxt_state[6U] = 2U;
        }
    }
    vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__w_fsm_ctx_nxt_state[7U] 
        = vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__reg_fsm_ctx_current_state[7U];
    if ((0x00000010U & vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__reg_fsm_ctx_current_state[7U])) {
        if ((8U & vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__reg_fsm_ctx_current_state[7U])) {
            vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__w_fsm_ctx_nxt_state[7U] = 0U;
        } else if ((4U & vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__reg_fsm_ctx_current_state[7U])) {
            vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__w_fsm_ctx_nxt_state[7U] = 0U;
        } else if ((2U & vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__reg_fsm_ctx_current_state[7U])) {
            vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__w_fsm_ctx_nxt_state[7U] = 0U;
        } else if ((1U & vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__reg_fsm_ctx_current_state[7U])) {
            if (((IData)(vlSelfRef.tb_cmo_ccu__DOT__fv) 
                 & (IData)(vlSelfRef.tb_cmo_ccu__DOT__fr))) {
                vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__w_fsm_ctx_nxt_state[7U] 
                    = (((IData)(vlSelfRef.tb_cmo_ccu__DOT__fc) 
                        & (~ ((IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__reg_ctx_gnt_err) 
                              >> 7U))) ? 8U : 0x0aU);
            }
        } else if (vlSelfRef.tb_cmo_ccu__DOT__pr) {
            vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__w_fsm_ctx_nxt_state[7U] = 0x11U;
        }
    } else if ((8U & vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__reg_fsm_ctx_current_state[7U])) {
        if ((4U & vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__reg_fsm_ctx_current_state[7U])) {
            if ((2U & vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__reg_fsm_ctx_current_state[7U])) {
                if ((1U & vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__reg_fsm_ctx_current_state[7U])) {
                    if ((0x00000080U & (IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__w_release_hs))) {
                        vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__w_fsm_ctx_nxt_state[7U] = 0U;
                    }
                } else if ((1U == (7U & (vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_txn_table__DOT__reg_ctx_src 
                                         >> 0x15U)))) {
                    if ((0x00000080U & (IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__w_release_hs))) {
                        vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__w_fsm_ctx_nxt_state[7U] = 0U;
                    }
                } else if ((1U & ((IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__w_gnt_load) 
                                  >> (3U & ((IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__reg_ctx_hart) 
                                            >> 0x0eU))))) {
                    vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__w_fsm_ctx_nxt_state[7U] = 0x0fU;
                }
            } else if ((1U & vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__reg_fsm_ctx_current_state[7U])) {
                if ((1U & ((~ ((IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__reg_ctx_dir_reserved) 
                               >> 7U)) | ((IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_sharer_directory__DOT__w_cancel_hs) 
                                          >> (3U & 
                                              (vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_txn_table__DOT__reg_ctx_pa_line[11U] 
                                               >> 0x0000000cU)))))) {
                    vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__w_fsm_ctx_nxt_state[7U] = 0x0eU;
                }
            } else if ((1U & ((IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_sharer_directory__DOT__w_update_hs) 
                              >> (3U & (vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_txn_table__DOT__reg_ctx_pa_line[11U] 
                                        >> 0x0000000cU))))) {
                vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__w_fsm_ctx_nxt_state[7U] = 0x0eU;
            }
        } else if ((2U & vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__reg_fsm_ctx_current_state[7U])) {
            if ((1U & vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__reg_fsm_ctx_current_state[7U])) {
                if ((IData)((((IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_txn_table__DOT__reg_ctx_phase_done) 
                              >> 7U) & (~ ((IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_txn_table__DOT__reg_ctx_phase_err) 
                                           >> 7U))))) {
                    vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__w_fsm_ctx_nxt_state[7U] 
                        = ((0x00000080U & (IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__reg_ctx_is_victim))
                            ? ((0x00000080U & (IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__w_release_hs))
                                ? 0U : 0x0fU) : ((0x00000080U 
                                                  & (IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__reg_ctx_dir_reserved))
                                                  ? 0x0dU
                                                  : 0x0eU));
                }
            } else if ((((IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__w_phase_start_hs) 
                         & (2U == (IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__w_phase_start_phase))) 
                        & (7U == (IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__w_phase_start_tag)))) {
                vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__w_fsm_ctx_nxt_state[7U] = 0x0bU;
            }
        } else if ((1U & vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__reg_fsm_ctx_current_state[7U])) {
            if ((IData)((((IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_txn_table__DOT__reg_ctx_phase_done) 
                          >> 7U) & (~ ((IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_txn_table__DOT__reg_ctx_phase_err) 
                                       >> 7U))))) {
                vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__w_fsm_ctx_nxt_state[7U] 
                    = ((0x00000080U & (IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__reg_ctx_is_victim))
                        ? ((0x00000080U & (IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__w_release_hs))
                            ? 0U : 0x0fU) : ((IData)(
                                                     ((0x00200000U 
                                                       == 
                                                       (0x00e00000U 
                                                        & vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_txn_table__DOT__reg_ctx_src)) 
                                                      & (~ 
                                                         ((IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__reg_ctx_cmo_dir_hit) 
                                                          >> 7U))))
                                              ? 0x0dU
                                              : 0x0cU));
            }
        } else if ((((IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__w_phase_start_hs) 
                     & (1U == (IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__w_phase_start_phase))) 
                    & (7U == (IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__w_phase_start_tag)))) {
            vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__w_fsm_ctx_nxt_state[7U] = 9U;
        }
    } else if ((4U & vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__reg_fsm_ctx_current_state[7U])) {
        if ((2U & vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__reg_fsm_ctx_current_state[7U])) {
            if ((1U & vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__reg_fsm_ctx_current_state[7U])) {
                if ((0x00000080U & (IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_txn_table__DOT__reg_ctx_phase_done))) {
                    vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__w_fsm_ctx_nxt_state[7U] 
                        = ((1U == (7U & (vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_txn_table__DOT__reg_ctx_src 
                                         >> 0x15U)))
                            ? 0x10U : ((1U & (((((IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_txn_table__DOT__reg_ctx_phase_err) 
                                                 | (IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_txn_table__DOT__reg_ctx_txn_err)) 
                                                | (IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_txn_table__DOT__reg_ctx_owner_wback_err)) 
                                               >> 7U) 
                                              | ((((IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_txn_table__DOT__reg_ctx_owner_present) 
                                                   & (IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_txn_table__DOT__reg_ctx_wback_en)) 
                                                  >> 7U) 
                                                 & (~ 
                                                    ((IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_txn_table__DOT__reg_ctx_owner_wback_done) 
                                                     >> 7U)))))
                                        ? 0x0aU : 8U));
                }
            } else if ((((IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__w_phase_start_hs) 
                         & (0U == (IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__w_phase_start_phase))) 
                        & (7U == (IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__w_phase_start_tag)))) {
                vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__w_fsm_ctx_nxt_state[7U] = 7U;
            }
        } else if ((1U & vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__reg_fsm_ctx_current_state[7U])) {
            if (((IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__w_owner_capture_valid) 
                 & (7U == (IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__w_owner_capture_tag)))) {
                vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__w_fsm_ctx_nxt_state[7U] = 6U;
            }
        }
    } else if ((2U & vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__reg_fsm_ctx_current_state[7U])) {
        if ((1U & vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__reg_fsm_ctx_current_state[7U])) {
            if (((((IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__w_alloc_valid) 
                   & (IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__w_alloc_ready)) 
                  & (IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__w_internal_pick_valid)) 
                 & (7U != (IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_txn_table__DOT__w_alloc_tag)))) {
                vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__w_fsm_ctx_nxt_state[7U] = 4U;
            }
        } else if ((0x00000080U & (IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__w_lookup_rsp_hs))) {
            vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__w_fsm_ctx_nxt_state[7U] 
                = ((1U == (7U & (vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_txn_table__DOT__reg_ctx_src 
                                 >> 0x15U))) ? 5U : 
                   ((((~ ((IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_sharer_directory__DOT__reg_lookup_hit) 
                          >> (3U & (vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_txn_table__DOT__reg_ctx_pa_line[11U] 
                                    >> 0x0000000cU)))) 
                      & ((IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_sharer_directory__DOT__reg_lookup_victim_valid) 
                         >> (3U & (vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_txn_table__DOT__reg_ctx_pa_line[11U] 
                                   >> 0x0000000cU)))) 
                     & (0U != (0x0000000fU & ((IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_sharer_directory__DOT__reg_lookup_holders) 
                                              >> (0x0000000cU 
                                                  & (vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_txn_table__DOT__reg_ctx_pa_line[11U] 
                                                     >> 0x0000000aU))))))
                     ? 3U : 5U));
        }
    } else if ((1U & vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__reg_fsm_ctx_current_state[7U])) {
        if ((1U & (((IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__w_dir_lookup_valid) 
                    >> (3U & (vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_txn_table__DOT__reg_ctx_pa_line[11U] 
                              >> 0x0000000cU))) & ((IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__w_dir_lookup_ready) 
                                                   >> 
                                                   (3U 
                                                    & (vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_txn_table__DOT__reg_ctx_pa_line[11U] 
                                                       >> 0x0000000cU)))))) {
            vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__w_fsm_ctx_nxt_state[7U] = 2U;
        }
    }
    if (((IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__w_alloc_valid) 
         & (IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__w_alloc_ready))) {
        vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__w_fsm_ctx_nxt_state[vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_txn_table__DOT__w_alloc_tag] 
            = ((IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__w_internal_pick_valid)
                ? 5U : ((IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__w_cmo_alloc_pick)
                         ? 1U : 0x0eU));
    }
    if (((((9U == vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__reg_fsm_ctx_current_state[0U]) 
           & (IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_txn_table__DOT__reg_ctx_phase_done)) 
          & (~ (IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_txn_table__DOT__reg_ctx_phase_err))) 
         & (IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__reg_ctx_is_victim))) {
        vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__w_fsm_ctx_nxt_state[(7U 
                                                                  & vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__reg_ctx_parent_tag)] = 0x0cU;
    }
    if (((((0x0bU == vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__reg_fsm_ctx_current_state[0U]) 
           & (IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_txn_table__DOT__reg_ctx_phase_done)) 
          & (~ (IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_txn_table__DOT__reg_ctx_phase_err))) 
         & (IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__reg_ctx_is_victim))) {
        vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__w_fsm_ctx_nxt_state[(7U 
                                                                  & vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__reg_ctx_parent_tag)] = 0x0dU;
    }
    if (((((9U == vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__reg_fsm_ctx_current_state[1U]) 
           & ((IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_txn_table__DOT__reg_ctx_phase_done) 
              >> 1U)) & (~ ((IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_txn_table__DOT__reg_ctx_phase_err) 
                            >> 1U))) & ((IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__reg_ctx_is_victim) 
                                        >> 1U))) {
        vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__w_fsm_ctx_nxt_state[(7U 
                                                                  & (vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__reg_ctx_parent_tag 
                                                                     >> 3U))] = 0x0cU;
    }
    if (((((0x0bU == vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__reg_fsm_ctx_current_state[1U]) 
           & ((IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_txn_table__DOT__reg_ctx_phase_done) 
              >> 1U)) & (~ ((IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_txn_table__DOT__reg_ctx_phase_err) 
                            >> 1U))) & ((IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__reg_ctx_is_victim) 
                                        >> 1U))) {
        vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__w_fsm_ctx_nxt_state[(7U 
                                                                  & (vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__reg_ctx_parent_tag 
                                                                     >> 3U))] = 0x0dU;
    }
    if (((((9U == vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__reg_fsm_ctx_current_state[2U]) 
           & ((IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_txn_table__DOT__reg_ctx_phase_done) 
              >> 2U)) & (~ ((IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_txn_table__DOT__reg_ctx_phase_err) 
                            >> 2U))) & ((IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__reg_ctx_is_victim) 
                                        >> 2U))) {
        vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__w_fsm_ctx_nxt_state[(7U 
                                                                  & (vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__reg_ctx_parent_tag 
                                                                     >> 6U))] = 0x0cU;
    }
    if (((((0x0bU == vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__reg_fsm_ctx_current_state[2U]) 
           & ((IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_txn_table__DOT__reg_ctx_phase_done) 
              >> 2U)) & (~ ((IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_txn_table__DOT__reg_ctx_phase_err) 
                            >> 2U))) & ((IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__reg_ctx_is_victim) 
                                        >> 2U))) {
        vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__w_fsm_ctx_nxt_state[(7U 
                                                                  & (vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__reg_ctx_parent_tag 
                                                                     >> 6U))] = 0x0dU;
    }
    if (((((9U == vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__reg_fsm_ctx_current_state[3U]) 
           & ((IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_txn_table__DOT__reg_ctx_phase_done) 
              >> 3U)) & (~ ((IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_txn_table__DOT__reg_ctx_phase_err) 
                            >> 3U))) & ((IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__reg_ctx_is_victim) 
                                        >> 3U))) {
        vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__w_fsm_ctx_nxt_state[(7U 
                                                                  & (vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__reg_ctx_parent_tag 
                                                                     >> 9U))] = 0x0cU;
    }
    if (((((0x0bU == vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__reg_fsm_ctx_current_state[3U]) 
           & ((IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_txn_table__DOT__reg_ctx_phase_done) 
              >> 3U)) & (~ ((IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_txn_table__DOT__reg_ctx_phase_err) 
                            >> 3U))) & ((IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__reg_ctx_is_victim) 
                                        >> 3U))) {
        vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__w_fsm_ctx_nxt_state[(7U 
                                                                  & (vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__reg_ctx_parent_tag 
                                                                     >> 9U))] = 0x0dU;
    }
    if (((((9U == vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__reg_fsm_ctx_current_state[4U]) 
           & ((IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_txn_table__DOT__reg_ctx_phase_done) 
              >> 4U)) & (~ ((IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_txn_table__DOT__reg_ctx_phase_err) 
                            >> 4U))) & ((IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__reg_ctx_is_victim) 
                                        >> 4U))) {
        vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__w_fsm_ctx_nxt_state[(7U 
                                                                  & (vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__reg_ctx_parent_tag 
                                                                     >> 0x0cU))] = 0x0cU;
    }
    if (((((0x0bU == vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__reg_fsm_ctx_current_state[4U]) 
           & ((IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_txn_table__DOT__reg_ctx_phase_done) 
              >> 4U)) & (~ ((IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_txn_table__DOT__reg_ctx_phase_err) 
                            >> 4U))) & ((IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__reg_ctx_is_victim) 
                                        >> 4U))) {
        vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__w_fsm_ctx_nxt_state[(7U 
                                                                  & (vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__reg_ctx_parent_tag 
                                                                     >> 0x0cU))] = 0x0dU;
    }
    if (((((9U == vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__reg_fsm_ctx_current_state[5U]) 
           & ((IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_txn_table__DOT__reg_ctx_phase_done) 
              >> 5U)) & (~ ((IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_txn_table__DOT__reg_ctx_phase_err) 
                            >> 5U))) & ((IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__reg_ctx_is_victim) 
                                        >> 5U))) {
        vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__w_fsm_ctx_nxt_state[(7U 
                                                                  & (vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__reg_ctx_parent_tag 
                                                                     >> 0x0fU))] = 0x0cU;
    }
    if (((((0x0bU == vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__reg_fsm_ctx_current_state[5U]) 
           & ((IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_txn_table__DOT__reg_ctx_phase_done) 
              >> 5U)) & (~ ((IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_txn_table__DOT__reg_ctx_phase_err) 
                            >> 5U))) & ((IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__reg_ctx_is_victim) 
                                        >> 5U))) {
        vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__w_fsm_ctx_nxt_state[(7U 
                                                                  & (vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__reg_ctx_parent_tag 
                                                                     >> 0x0fU))] = 0x0dU;
    }
    if (((((9U == vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__reg_fsm_ctx_current_state[6U]) 
           & ((IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_txn_table__DOT__reg_ctx_phase_done) 
              >> 6U)) & (~ ((IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_txn_table__DOT__reg_ctx_phase_err) 
                            >> 6U))) & ((IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__reg_ctx_is_victim) 
                                        >> 6U))) {
        vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__w_fsm_ctx_nxt_state[(7U 
                                                                  & (vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__reg_ctx_parent_tag 
                                                                     >> 0x12U))] = 0x0cU;
    }
    if (((((0x0bU == vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__reg_fsm_ctx_current_state[6U]) 
           & ((IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_txn_table__DOT__reg_ctx_phase_done) 
              >> 6U)) & (~ ((IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_txn_table__DOT__reg_ctx_phase_err) 
                            >> 6U))) & ((IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__reg_ctx_is_victim) 
                                        >> 6U))) {
        vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__w_fsm_ctx_nxt_state[(7U 
                                                                  & (vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__reg_ctx_parent_tag 
                                                                     >> 0x12U))] = 0x0dU;
    }
    if (((((9U == vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__reg_fsm_ctx_current_state[7U]) 
           & ((IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_txn_table__DOT__reg_ctx_phase_done) 
              >> 7U)) & (~ ((IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_txn_table__DOT__reg_ctx_phase_err) 
                            >> 7U))) & ((IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__reg_ctx_is_victim) 
                                        >> 7U))) {
        vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__w_fsm_ctx_nxt_state[(7U 
                                                                  & (vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__reg_ctx_parent_tag 
                                                                     >> 0x15U))] = 0x0cU;
    }
    if (((((0x0bU == vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__reg_fsm_ctx_current_state[7U]) 
           & ((IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_txn_table__DOT__reg_ctx_phase_done) 
              >> 7U)) & (~ ((IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_txn_table__DOT__reg_ctx_phase_err) 
                            >> 7U))) & ((IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__reg_ctx_is_victim) 
                                        >> 7U))) {
        vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__w_fsm_ctx_nxt_state[(7U 
                                                                  & (vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__reg_ctx_parent_tag 
                                                                     >> 0x15U))] = 0x0dU;
    }
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_276 = (1U 
                                                  & ((~ (IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_bank_arb__DOT__gen_bank__BRA__3__KET____DOT__reg_gnt_valid)) 
                                                     | (IData)(vlSelfRef.__VdfgRegularize_h6e95ff9d_0_663)));
    vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_bank_arb__DOT__gen_bank__BRA__3__KET____DOT__w_gnt_hs 
        = ((IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_bank_arb__DOT__gen_bank__BRA__3__KET____DOT__reg_gnt_valid) 
           & (IData)(vlSelfRef.__VdfgRegularize_h6e95ff9d_0_663));
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_319 = ((~ (IData)(vlSelfRef.__VdfgRegularize_h6e95ff9d_0_492)) 
                                                  & (((IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__w_bank_req_valid) 
                                                      >> 
                                                      (7U 
                                                       & vlSelfRef.__VdfgRegularize_h6e95ff9d_0_427)) 
                                                     & (((IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_bank_arb__DOT__gen_bank__BRA__2__KET____DOT__reg_req_armed) 
                                                         >> 
                                                         (7U 
                                                          & vlSelfRef.__VdfgRegularize_h6e95ff9d_0_427)) 
                                                        & ((~ 
                                                            ((vlSelfRef.__VdfgRegularize_h6e95ff9d_0_427 
                                                              == (IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_bank_arb__DOT__gen_bank__BRA__2__KET____DOT__reg_gnt_slot)) 
                                                             & (IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_bank_arb__DOT__gen_bank__BRA__2__KET____DOT__w_gnt_hs))) 
                                                           & (2U 
                                                              == 
                                                              (3U 
                                                               & ((IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__w_bank_req_bank) 
                                                                  >> 
                                                                  (0x0000000eU 
                                                                   & (vlSelfRef.__VdfgRegularize_h6e95ff9d_0_427 
                                                                      << 1U)))))))));
    vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_bank_arb__DOT__gen_bank__BRA__3__KET____DOT__w_start_slot 
        = (7U & ((IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_bank_arb__DOT__gen_bank__BRA__3__KET____DOT__w_gnt_hs)
                  ? (((IData)(1U) + (IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_bank_arb__DOT__gen_bank__BRA__3__KET____DOT__reg_gnt_slot)) 
                     & (- (IData)((7U != (IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_bank_arb__DOT__gen_bank__BRA__3__KET____DOT__reg_gnt_slot)))))
                  : (IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_bank_arb__DOT__gen_bank__BRA__3__KET____DOT__reg_rr_slot)));
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_488 = ((~ (IData)(vlSelfRef.__VdfgRegularize_h6e95ff9d_0_492)) 
                                                  & ((~ (IData)(vlSelfRef.__VdfgRegularize_h6e95ff9d_0_319)) 
                                                     & (((IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__w_bank_req_valid) 
                                                         >> 
                                                         (7U 
                                                          & vlSelfRef.__VdfgRegularize_h6e95ff9d_0_428)) 
                                                        & (((IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_bank_arb__DOT__gen_bank__BRA__2__KET____DOT__reg_req_armed) 
                                                            >> 
                                                            (7U 
                                                             & vlSelfRef.__VdfgRegularize_h6e95ff9d_0_428)) 
                                                           & ((~ 
                                                               ((vlSelfRef.__VdfgRegularize_h6e95ff9d_0_428 
                                                                 == (IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_bank_arb__DOT__gen_bank__BRA__2__KET____DOT__reg_gnt_slot)) 
                                                                & (IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_bank_arb__DOT__gen_bank__BRA__2__KET____DOT__w_gnt_hs))) 
                                                              & (2U 
                                                                 == 
                                                                 (3U 
                                                                  & ((IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__w_bank_req_bank) 
                                                                     >> 
                                                                     (0x0000000eU 
                                                                      & (vlSelfRef.__VdfgRegularize_h6e95ff9d_0_428 
                                                                         << 1U))))))))));
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_438 = ((8U 
                                                   <= 
                                                   ((IData)(7U) 
                                                    + (IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_bank_arb__DOT__gen_bank__BRA__3__KET____DOT__w_start_slot)))
                                                   ? 
                                                  ((IData)(0xffffffffU) 
                                                   + (IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_bank_arb__DOT__gen_bank__BRA__3__KET____DOT__w_start_slot))
                                                   : 
                                                  ((IData)(7U) 
                                                   + (IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_bank_arb__DOT__gen_bank__BRA__3__KET____DOT__w_start_slot)));
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_437 = ((8U 
                                                   <= 
                                                   ((IData)(6U) 
                                                    + (IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_bank_arb__DOT__gen_bank__BRA__3__KET____DOT__w_start_slot)))
                                                   ? 
                                                  ((IData)(0xfffffffeU) 
                                                   + (IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_bank_arb__DOT__gen_bank__BRA__3__KET____DOT__w_start_slot))
                                                   : 
                                                  ((IData)(6U) 
                                                   + (IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_bank_arb__DOT__gen_bank__BRA__3__KET____DOT__w_start_slot)));
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_436 = ((8U 
                                                   <= 
                                                   ((IData)(5U) 
                                                    + (IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_bank_arb__DOT__gen_bank__BRA__3__KET____DOT__w_start_slot)))
                                                   ? 
                                                  ((IData)(0xfffffffdU) 
                                                   + (IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_bank_arb__DOT__gen_bank__BRA__3__KET____DOT__w_start_slot))
                                                   : 
                                                  ((IData)(5U) 
                                                   + (IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_bank_arb__DOT__gen_bank__BRA__3__KET____DOT__w_start_slot)));
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_435 = ((8U 
                                                   <= 
                                                   ((IData)(4U) 
                                                    + (IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_bank_arb__DOT__gen_bank__BRA__3__KET____DOT__w_start_slot)))
                                                   ? 
                                                  ((IData)(0xfffffffcU) 
                                                   + (IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_bank_arb__DOT__gen_bank__BRA__3__KET____DOT__w_start_slot))
                                                   : 
                                                  ((IData)(4U) 
                                                   + (IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_bank_arb__DOT__gen_bank__BRA__3__KET____DOT__w_start_slot)));
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_434 = ((8U 
                                                   <= 
                                                   ((IData)(3U) 
                                                    + (IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_bank_arb__DOT__gen_bank__BRA__3__KET____DOT__w_start_slot)))
                                                   ? 
                                                  ((IData)(0xfffffffbU) 
                                                   + (IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_bank_arb__DOT__gen_bank__BRA__3__KET____DOT__w_start_slot))
                                                   : 
                                                  ((IData)(3U) 
                                                   + (IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_bank_arb__DOT__gen_bank__BRA__3__KET____DOT__w_start_slot)));
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_433 = ((8U 
                                                   <= 
                                                   ((IData)(2U) 
                                                    + (IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_bank_arb__DOT__gen_bank__BRA__3__KET____DOT__w_start_slot)))
                                                   ? 
                                                  ((IData)(0xfffffffaU) 
                                                   + (IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_bank_arb__DOT__gen_bank__BRA__3__KET____DOT__w_start_slot))
                                                   : 
                                                  ((IData)(2U) 
                                                   + (IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_bank_arb__DOT__gen_bank__BRA__3__KET____DOT__w_start_slot)));
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_432 = ((8U 
                                                   <= 
                                                   ((IData)(1U) 
                                                    + (IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_bank_arb__DOT__gen_bank__BRA__3__KET____DOT__w_start_slot)))
                                                   ? 
                                                  ((IData)(0xfffffff9U) 
                                                   + (IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_bank_arb__DOT__gen_bank__BRA__3__KET____DOT__w_start_slot))
                                                   : 
                                                  ((IData)(1U) 
                                                   + (IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_bank_arb__DOT__gen_bank__BRA__3__KET____DOT__w_start_slot)));
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_317 = (((IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__w_bank_req_valid) 
                                                   >> (IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_bank_arb__DOT__gen_bank__BRA__3__KET____DOT__w_start_slot)) 
                                                  & (((IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_bank_arb__DOT__gen_bank__BRA__3__KET____DOT__reg_req_armed) 
                                                      >> (IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_bank_arb__DOT__gen_bank__BRA__3__KET____DOT__w_start_slot)) 
                                                     & ((~ 
                                                         (((IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_bank_arb__DOT__gen_bank__BRA__3__KET____DOT__w_start_slot) 
                                                           == (IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_bank_arb__DOT__gen_bank__BRA__3__KET____DOT__reg_gnt_slot)) 
                                                          & (IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_bank_arb__DOT__gen_bank__BRA__3__KET____DOT__w_gnt_hs))) 
                                                        & (3U 
                                                           == 
                                                           (3U 
                                                            & ((IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__w_bank_req_bank) 
                                                               >> 
                                                               ((IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_bank_arb__DOT__gen_bank__BRA__3__KET____DOT__w_start_slot) 
                                                                << 1U)))))));
    __VdfgRegularize_h6e95ff9d_0_489 = ((IData)(vlSelfRef.__VdfgRegularize_h6e95ff9d_0_488) 
                                        | ((IData)(vlSelfRef.__VdfgRegularize_h6e95ff9d_0_319) 
                                           | (IData)(vlSelfRef.__VdfgRegularize_h6e95ff9d_0_492)));
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_484 = ((~ (IData)(vlSelfRef.__VdfgRegularize_h6e95ff9d_0_317)) 
                                                  & (((IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__w_bank_req_valid) 
                                                      >> 
                                                      (7U 
                                                       & vlSelfRef.__VdfgRegularize_h6e95ff9d_0_432)) 
                                                     & (((IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_bank_arb__DOT__gen_bank__BRA__3__KET____DOT__reg_req_armed) 
                                                         >> 
                                                         (7U 
                                                          & vlSelfRef.__VdfgRegularize_h6e95ff9d_0_432)) 
                                                        & ((~ 
                                                            ((vlSelfRef.__VdfgRegularize_h6e95ff9d_0_432 
                                                              == (IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_bank_arb__DOT__gen_bank__BRA__3__KET____DOT__reg_gnt_slot)) 
                                                             & (IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_bank_arb__DOT__gen_bank__BRA__3__KET____DOT__w_gnt_hs))) 
                                                           & (3U 
                                                              == 
                                                              (3U 
                                                               & ((IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__w_bank_req_bank) 
                                                                  >> 
                                                                  (0x0000000eU 
                                                                   & (vlSelfRef.__VdfgRegularize_h6e95ff9d_0_432 
                                                                      << 1U)))))))));
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_318 = ((~ (IData)(__VdfgRegularize_h6e95ff9d_0_489)) 
                                                  & (((IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__w_bank_req_valid) 
                                                      >> 
                                                      (7U 
                                                       & vlSelfRef.__VdfgRegularize_h6e95ff9d_0_429)) 
                                                     & (((IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_bank_arb__DOT__gen_bank__BRA__2__KET____DOT__reg_req_armed) 
                                                         >> 
                                                         (7U 
                                                          & vlSelfRef.__VdfgRegularize_h6e95ff9d_0_429)) 
                                                        & ((~ 
                                                            ((vlSelfRef.__VdfgRegularize_h6e95ff9d_0_429 
                                                              == (IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_bank_arb__DOT__gen_bank__BRA__2__KET____DOT__reg_gnt_slot)) 
                                                             & (IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_bank_arb__DOT__gen_bank__BRA__2__KET____DOT__w_gnt_hs))) 
                                                           & (2U 
                                                              == 
                                                              (3U 
                                                               & ((IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__w_bank_req_bank) 
                                                                  >> 
                                                                  (0x0000000eU 
                                                                   & (vlSelfRef.__VdfgRegularize_h6e95ff9d_0_429 
                                                                      << 1U)))))))));
    __VdfgRegularize_h6e95ff9d_0_485 = ((IData)(vlSelfRef.__VdfgRegularize_h6e95ff9d_0_484) 
                                        | (IData)(vlSelfRef.__VdfgRegularize_h6e95ff9d_0_317));
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_486 = ((~ (IData)(__VdfgRegularize_h6e95ff9d_0_489)) 
                                                  & ((~ (IData)(vlSelfRef.__VdfgRegularize_h6e95ff9d_0_318)) 
                                                     & (((IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__w_bank_req_valid) 
                                                         >> 
                                                         (7U 
                                                          & vlSelfRef.__VdfgRegularize_h6e95ff9d_0_430)) 
                                                        & (((IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_bank_arb__DOT__gen_bank__BRA__2__KET____DOT__reg_req_armed) 
                                                            >> 
                                                            (7U 
                                                             & vlSelfRef.__VdfgRegularize_h6e95ff9d_0_430)) 
                                                           & ((~ 
                                                               ((vlSelfRef.__VdfgRegularize_h6e95ff9d_0_430 
                                                                 == (IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_bank_arb__DOT__gen_bank__BRA__2__KET____DOT__reg_gnt_slot)) 
                                                                & (IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_bank_arb__DOT__gen_bank__BRA__2__KET____DOT__w_gnt_hs))) 
                                                              & (2U 
                                                                 == 
                                                                 (3U 
                                                                  & ((IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__w_bank_req_bank) 
                                                                     >> 
                                                                     (0x0000000eU 
                                                                      & (vlSelfRef.__VdfgRegularize_h6e95ff9d_0_430 
                                                                         << 1U))))))))));
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_316 = ((~ (IData)(__VdfgRegularize_h6e95ff9d_0_485)) 
                                                  & (((IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__w_bank_req_valid) 
                                                      >> 
                                                      (7U 
                                                       & vlSelfRef.__VdfgRegularize_h6e95ff9d_0_433)) 
                                                     & (((IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_bank_arb__DOT__gen_bank__BRA__3__KET____DOT__reg_req_armed) 
                                                         >> 
                                                         (7U 
                                                          & vlSelfRef.__VdfgRegularize_h6e95ff9d_0_433)) 
                                                        & ((~ 
                                                            ((vlSelfRef.__VdfgRegularize_h6e95ff9d_0_433 
                                                              == (IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_bank_arb__DOT__gen_bank__BRA__3__KET____DOT__reg_gnt_slot)) 
                                                             & (IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_bank_arb__DOT__gen_bank__BRA__3__KET____DOT__w_gnt_hs))) 
                                                           & (3U 
                                                              == 
                                                              (3U 
                                                               & ((IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__w_bank_req_bank) 
                                                                  >> 
                                                                  (0x0000000eU 
                                                                   & (vlSelfRef.__VdfgRegularize_h6e95ff9d_0_433 
                                                                      << 1U)))))))));
    vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_bank_arb__DOT__gen_bank__BRA__2__KET____DOT__w_pick_valid 
        = ((IData)(vlSelfRef.__VdfgRegularize_h6e95ff9d_0_318) 
           | ((IData)(vlSelfRef.__VdfgRegularize_h6e95ff9d_0_486) 
              | (IData)(__VdfgRegularize_h6e95ff9d_0_489)));
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_481 = ((~ (IData)(__VdfgRegularize_h6e95ff9d_0_485)) 
                                                  & ((~ (IData)(vlSelfRef.__VdfgRegularize_h6e95ff9d_0_316)) 
                                                     & (((IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__w_bank_req_valid) 
                                                         >> 
                                                         (7U 
                                                          & vlSelfRef.__VdfgRegularize_h6e95ff9d_0_434)) 
                                                        & (((IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_bank_arb__DOT__gen_bank__BRA__3__KET____DOT__reg_req_armed) 
                                                            >> 
                                                            (7U 
                                                             & vlSelfRef.__VdfgRegularize_h6e95ff9d_0_434)) 
                                                           & ((~ 
                                                               ((vlSelfRef.__VdfgRegularize_h6e95ff9d_0_434 
                                                                 == (IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_bank_arb__DOT__gen_bank__BRA__3__KET____DOT__reg_gnt_slot)) 
                                                                & (IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_bank_arb__DOT__gen_bank__BRA__3__KET____DOT__w_gnt_hs))) 
                                                              & (3U 
                                                                 == 
                                                                 (3U 
                                                                  & ((IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__w_bank_req_bank) 
                                                                     >> 
                                                                     (0x0000000eU 
                                                                      & (vlSelfRef.__VdfgRegularize_h6e95ff9d_0_434 
                                                                         << 1U))))))))));
    __VdfgRegularize_h6e95ff9d_0_482 = ((IData)(vlSelfRef.__VdfgRegularize_h6e95ff9d_0_481) 
                                        | ((IData)(vlSelfRef.__VdfgRegularize_h6e95ff9d_0_316) 
                                           | (IData)(__VdfgRegularize_h6e95ff9d_0_485)));
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_315 = ((~ (IData)(__VdfgRegularize_h6e95ff9d_0_482)) 
                                                  & (((IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__w_bank_req_valid) 
                                                      >> 
                                                      (7U 
                                                       & vlSelfRef.__VdfgRegularize_h6e95ff9d_0_435)) 
                                                     & (((IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_bank_arb__DOT__gen_bank__BRA__3__KET____DOT__reg_req_armed) 
                                                         >> 
                                                         (7U 
                                                          & vlSelfRef.__VdfgRegularize_h6e95ff9d_0_435)) 
                                                        & ((~ 
                                                            ((vlSelfRef.__VdfgRegularize_h6e95ff9d_0_435 
                                                              == (IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_bank_arb__DOT__gen_bank__BRA__3__KET____DOT__reg_gnt_slot)) 
                                                             & (IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_bank_arb__DOT__gen_bank__BRA__3__KET____DOT__w_gnt_hs))) 
                                                           & (3U 
                                                              == 
                                                              (3U 
                                                               & ((IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__w_bank_req_bank) 
                                                                  >> 
                                                                  (0x0000000eU 
                                                                   & (vlSelfRef.__VdfgRegularize_h6e95ff9d_0_435 
                                                                      << 1U)))))))));
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_478 = ((~ (IData)(__VdfgRegularize_h6e95ff9d_0_482)) 
                                                  & ((~ (IData)(vlSelfRef.__VdfgRegularize_h6e95ff9d_0_315)) 
                                                     & (((IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__w_bank_req_valid) 
                                                         >> 
                                                         (7U 
                                                          & vlSelfRef.__VdfgRegularize_h6e95ff9d_0_436)) 
                                                        & (((IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_bank_arb__DOT__gen_bank__BRA__3__KET____DOT__reg_req_armed) 
                                                            >> 
                                                            (7U 
                                                             & vlSelfRef.__VdfgRegularize_h6e95ff9d_0_436)) 
                                                           & ((~ 
                                                               ((vlSelfRef.__VdfgRegularize_h6e95ff9d_0_436 
                                                                 == (IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_bank_arb__DOT__gen_bank__BRA__3__KET____DOT__reg_gnt_slot)) 
                                                                & (IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_bank_arb__DOT__gen_bank__BRA__3__KET____DOT__w_gnt_hs))) 
                                                              & (3U 
                                                                 == 
                                                                 (3U 
                                                                  & ((IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__w_bank_req_bank) 
                                                                     >> 
                                                                     (0x0000000eU 
                                                                      & (vlSelfRef.__VdfgRegularize_h6e95ff9d_0_436 
                                                                         << 1U))))))))));
    __VdfgRegularize_h6e95ff9d_0_479 = ((IData)(vlSelfRef.__VdfgRegularize_h6e95ff9d_0_478) 
                                        | ((IData)(vlSelfRef.__VdfgRegularize_h6e95ff9d_0_315) 
                                           | (IData)(__VdfgRegularize_h6e95ff9d_0_482)));
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_314 = ((~ (IData)(__VdfgRegularize_h6e95ff9d_0_479)) 
                                                  & (((IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__w_bank_req_valid) 
                                                      >> 
                                                      (7U 
                                                       & vlSelfRef.__VdfgRegularize_h6e95ff9d_0_437)) 
                                                     & (((IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_bank_arb__DOT__gen_bank__BRA__3__KET____DOT__reg_req_armed) 
                                                         >> 
                                                         (7U 
                                                          & vlSelfRef.__VdfgRegularize_h6e95ff9d_0_437)) 
                                                        & ((~ 
                                                            ((vlSelfRef.__VdfgRegularize_h6e95ff9d_0_437 
                                                              == (IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_bank_arb__DOT__gen_bank__BRA__3__KET____DOT__reg_gnt_slot)) 
                                                             & (IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_bank_arb__DOT__gen_bank__BRA__3__KET____DOT__w_gnt_hs))) 
                                                           & (3U 
                                                              == 
                                                              (3U 
                                                               & ((IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__w_bank_req_bank) 
                                                                  >> 
                                                                  (0x0000000eU 
                                                                   & (vlSelfRef.__VdfgRegularize_h6e95ff9d_0_437 
                                                                      << 1U)))))))));
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_476 = ((~ (IData)(__VdfgRegularize_h6e95ff9d_0_479)) 
                                                  & ((~ (IData)(vlSelfRef.__VdfgRegularize_h6e95ff9d_0_314)) 
                                                     & (((IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__w_bank_req_valid) 
                                                         >> 
                                                         (7U 
                                                          & vlSelfRef.__VdfgRegularize_h6e95ff9d_0_438)) 
                                                        & (((IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_bank_arb__DOT__gen_bank__BRA__3__KET____DOT__reg_req_armed) 
                                                            >> 
                                                            (7U 
                                                             & vlSelfRef.__VdfgRegularize_h6e95ff9d_0_438)) 
                                                           & ((~ 
                                                               ((vlSelfRef.__VdfgRegularize_h6e95ff9d_0_438 
                                                                 == (IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_bank_arb__DOT__gen_bank__BRA__3__KET____DOT__reg_gnt_slot)) 
                                                                & (IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_bank_arb__DOT__gen_bank__BRA__3__KET____DOT__w_gnt_hs))) 
                                                              & (3U 
                                                                 == 
                                                                 (3U 
                                                                  & ((IData)(vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__w_bank_req_bank) 
                                                                     >> 
                                                                     (0x0000000eU 
                                                                      & (vlSelfRef.__VdfgRegularize_h6e95ff9d_0_438 
                                                                         << 1U))))))))));
    vlSelfRef.tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_bank_arb__DOT__gen_bank__BRA__3__KET____DOT__w_pick_valid 
        = ((IData)(vlSelfRef.__VdfgRegularize_h6e95ff9d_0_314) 
           | ((IData)(vlSelfRef.__VdfgRegularize_h6e95ff9d_0_476) 
              | (IData)(__VdfgRegularize_h6e95ff9d_0_479)));
}

bool Vtb_cmo_ccu___024root___trigger_anySet__ico(const VlUnpacked<QData/*63:0*/, 1> &in);

#ifdef VL_DEBUG
VL_ATTR_COLD void Vtb_cmo_ccu___024root___dump_triggers__ico(const VlUnpacked<QData/*63:0*/, 1> &triggers, const std::string &tag) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_cmo_ccu___024root___dump_triggers__ico\n"); );
    // Body
    if ((1U & (~ (IData)(Vtb_cmo_ccu___024root___trigger_anySet__ico(triggers))))) {
        VL_DBG_MSGS("         No '" + tag + "' region triggers active\n");
    }
    if ((1U & (IData)(triggers[0U]))) {
        VL_DBG_MSGS("         '" + tag + "' region trigger index 0 is active: Internal 'ico' trigger - first iteration\n");
    }
}
#endif  // VL_DEBUG

bool Vtb_cmo_ccu___024root___trigger_anySet__act(const VlUnpacked<QData/*63:0*/, 1> &in);

#ifdef VL_DEBUG
VL_ATTR_COLD void Vtb_cmo_ccu___024root___dump_triggers__act(const VlUnpacked<QData/*63:0*/, 1> &triggers, const std::string &tag) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_cmo_ccu___024root___dump_triggers__act\n"); );
    // Body
    if ((1U & (~ (IData)(Vtb_cmo_ccu___024root___trigger_anySet__act(triggers))))) {
        VL_DBG_MSGS("         No '" + tag + "' region triggers active\n");
    }
    if ((1U & (IData)(triggers[0U]))) {
        VL_DBG_MSGS("         '" + tag + "' region trigger index 0 is active: @(posedge tb_cmo_ccu.clk)\n");
    }
    if ((1U & (IData)((triggers[0U] >> 1U)))) {
        VL_DBG_MSGS("         '" + tag + "' region trigger index 1 is active: @(negedge tb_cmo_ccu.rst)\n");
    }
    if ((1U & (IData)((triggers[0U] >> 2U)))) {
        VL_DBG_MSGS("         '" + tag + "' region trigger index 2 is active: @(negedge tb_cmo_ccu.clk)\n");
    }
    if ((1U & (IData)((triggers[0U] >> 3U)))) {
        VL_DBG_MSGS("         '" + tag + "' region trigger index 3 is active: @( (tb_cmo_ccu.dut.reg_cmo_active & (5'h10 == (tb_cmo_ccu.dut.reg_fsm_ctx_current_state[tb_cmo_ccu.dut.reg_cmo_tag]))))\n");
    }
    if ((1U & (IData)((triggers[0U] >> 4U)))) {
        VL_DBG_MSGS("         '" + tag + "' region trigger index 4 is active: @( (tb_cmo_ccu.dut.reg_cmo_active & ((5'he == (tb_cmo_ccu.dut.reg_fsm_ctx_current_state[tb_cmo_ccu.dut.reg_cmo_tag])) & tb_cmo_ccu.dut.w_release_hs[tb_cmo_ccu.dut.reg_cmo_tag+:1])))\n");
    }
    if ((1U & (IData)((triggers[0U] >> 5U)))) {
        VL_DBG_MSGS("         '" + tag + "' region trigger index 5 is active: @([true] __VdlySched.awaitingCurrentTime())\n");
    }
}
#endif  // VL_DEBUG

VL_ATTR_COLD void Vtb_cmo_ccu___024root___ctor_var_reset(Vtb_cmo_ccu___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_cmo_ccu___024root___ctor_var_reset\n"); );
    Vtb_cmo_ccu__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    const uint64_t __VscopeHash = VL_MURMUR64_HASH(vlSelf->vlNamep);
    vlSelf->tb_cmo_ccu__DOT__br = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 15814811710277220837ull);
    vlSelf->tb_cmo_ccu__DOT__fr = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 13748333977896100931ull);
    vlSelf->tb_cmo_ccu__DOT__dut__DOT__reg_cmo_active = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 9592423419892697976ull);
    vlSelf->tb_cmo_ccu__DOT__dut__DOT__reg_cmo_tag = VL_SCOPED_RAND_RESET_I(3, __VscopeHash, 930182152750577427ull);
    vlSelf->tb_cmo_ccu__DOT__dut__DOT__reg_ctx_cmo_dir_hit = VL_SCOPED_RAND_RESET_I(8, __VscopeHash, 7165796073511449635ull);
    vlSelf->tb_cmo_ccu__DOT__dut__DOT__w_cmo_alloc_pick = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 16104782785537683584ull);
    for (int __Vi0 = 0; __Vi0 < 8; ++__Vi0) {
        vlSelf->tb_cmo_ccu__DOT__dut__DOT__reg_fsm_ctx_current_state[__Vi0] = VL_SCOPED_RAND_RESET_I(5, __VscopeHash, 2935965748033899110ull);
    }
    for (int __Vi0 = 0; __Vi0 < 8; ++__Vi0) {
        vlSelf->tb_cmo_ccu__DOT__dut__DOT__w_fsm_ctx_nxt_state[__Vi0] = VL_SCOPED_RAND_RESET_I(5, __VscopeHash, 13351185025930797243ull);
    }
    vlSelf->tb_cmo_ccu__DOT__dut__DOT__reg_ctx_is_victim = VL_SCOPED_RAND_RESET_I(8, __VscopeHash, 269722016759781728ull);
    vlSelf->tb_cmo_ccu__DOT__dut__DOT__reg_ctx_dir_reserved = VL_SCOPED_RAND_RESET_I(8, __VscopeHash, 8662690342884747927ull);
    vlSelf->tb_cmo_ccu__DOT__dut__DOT__reg_ctx_hart = VL_SCOPED_RAND_RESET_I(16, __VscopeHash, 1855282974098034172ull);
    vlSelf->tb_cmo_ccu__DOT__dut__DOT__reg_ctx_gnt_state = VL_SCOPED_RAND_RESET_I(16, __VscopeHash, 16785415639063273170ull);
    vlSelf->tb_cmo_ccu__DOT__dut__DOT__reg_ctx_dir_way = VL_SCOPED_RAND_RESET_I(24, __VscopeHash, 15395371993402030192ull);
    vlSelf->tb_cmo_ccu__DOT__dut__DOT__reg_ctx_probe_holders = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 6263837746967901738ull);
    vlSelf->tb_cmo_ccu__DOT__dut__DOT__reg_ctx_new_holders = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 9768024528254239236ull);
    vlSelf->tb_cmo_ccu__DOT__dut__DOT__reg_ctx_old_owner = VL_SCOPED_RAND_RESET_I(16, __VscopeHash, 1966764412428887428ull);
    vlSelf->tb_cmo_ccu__DOT__dut__DOT__reg_ctx_new_owner = VL_SCOPED_RAND_RESET_I(16, __VscopeHash, 16818122434329432268ull);
    vlSelf->tb_cmo_ccu__DOT__dut__DOT__reg_ctx_old_state = VL_SCOPED_RAND_RESET_I(16, __VscopeHash, 4839528453975720152ull);
    VL_SCOPED_RAND_RESET_W(416, vlSelf->tb_cmo_ccu__DOT__dut__DOT__reg_ctx_victim_line, __VscopeHash, 16176282804657591826ull);
    vlSelf->tb_cmo_ccu__DOT__dut__DOT__reg_ctx_victim_holders = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 11291385721071881898ull);
    vlSelf->tb_cmo_ccu__DOT__dut__DOT__reg_ctx_victim_owner = VL_SCOPED_RAND_RESET_I(16, __VscopeHash, 15899725711932813784ull);
    vlSelf->tb_cmo_ccu__DOT__dut__DOT__reg_ctx_victim_state = VL_SCOPED_RAND_RESET_I(16, __VscopeHash, 7179717714068469447ull);
    vlSelf->tb_cmo_ccu__DOT__dut__DOT__reg_ctx_parent_tag = VL_SCOPED_RAND_RESET_I(24, __VscopeHash, 2605315346302482017ull);
    vlSelf->tb_cmo_ccu__DOT__dut__DOT__reg_ctx_gnt_err = VL_SCOPED_RAND_RESET_I(8, __VscopeHash, 7361711105012455618ull);
    vlSelf->tb_cmo_ccu__DOT__dut__DOT__reg_ctx_gnt_accepted = VL_SCOPED_RAND_RESET_I(8, __VscopeHash, 3368023785889439304ull);
    vlSelf->tb_cmo_ccu__DOT__dut__DOT__w_alloc_valid = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 4239477602888500365ull);
    vlSelf->tb_cmo_ccu__DOT__dut__DOT__w_alloc_ready = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 7413304811404975861ull);
    vlSelf->tb_cmo_ccu__DOT__dut__DOT__w_alloc_src = VL_SCOPED_RAND_RESET_I(3, __VscopeHash, 9422688690859701124ull);
    vlSelf->tb_cmo_ccu__DOT__dut__DOT__w_alloc_pa_line = VL_SCOPED_RAND_RESET_Q(52, __VscopeHash, 3152444632530094711ull);
    vlSelf->tb_cmo_ccu__DOT__dut__DOT__w_alloc_kind = VL_SCOPED_RAND_RESET_I(2, __VscopeHash, 2204069551747116945ull);
    vlSelf->tb_cmo_ccu__DOT__dut__DOT__w_alloc_target_state = VL_SCOPED_RAND_RESET_I(2, __VscopeHash, 15943501298486583183ull);
    vlSelf->tb_cmo_ccu__DOT__dut__DOT__w_alloc_wback_en = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 7362661305702382965ull);
    vlSelf->tb_cmo_ccu__DOT__dut__DOT__w_release_valid = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 9309047843432975022ull);
    vlSelf->tb_cmo_ccu__DOT__dut__DOT__w_release_tag = VL_SCOPED_RAND_RESET_I(3, __VscopeHash, 15242394043575151254ull);
    vlSelf->tb_cmo_ccu__DOT__dut__DOT__w_release_ready = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 16687199730885053025ull);
    vlSelf->tb_cmo_ccu__DOT__dut__DOT__w_phase_start_valid = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 251770902911030228ull);
    vlSelf->tb_cmo_ccu__DOT__dut__DOT__w_phase_start_tag = VL_SCOPED_RAND_RESET_I(3, __VscopeHash, 16683853188849572739ull);
    vlSelf->tb_cmo_ccu__DOT__dut__DOT__w_phase_start_phase = VL_SCOPED_RAND_RESET_I(2, __VscopeHash, 13114509930118777756ull);
    vlSelf->tb_cmo_ccu__DOT__dut__DOT__w_phase_expected = VL_SCOPED_RAND_RESET_I(4, __VscopeHash, 2415039052686413859ull);
    vlSelf->tb_cmo_ccu__DOT__dut__DOT__w_phase_start_ready = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 17140880140645134748ull);
    vlSelf->tb_cmo_ccu__DOT__dut__DOT__w_owner_capture_valid = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 8817933674839692779ull);
    vlSelf->tb_cmo_ccu__DOT__dut__DOT__w_owner_capture_tag = VL_SCOPED_RAND_RESET_I(3, __VscopeHash, 16318150094850121418ull);
    vlSelf->tb_cmo_ccu__DOT__dut__DOT__w_owner_capture_present = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 16902917457581199341ull);
    vlSelf->tb_cmo_ccu__DOT__dut__DOT__w_owner_capture_hart = VL_SCOPED_RAND_RESET_I(2, __VscopeHash, 15023039288041617704ull);
    vlSelf->tb_cmo_ccu__DOT__dut__DOT__w_bank_req_valid = VL_SCOPED_RAND_RESET_I(8, __VscopeHash, 16124812691595879861ull);
    vlSelf->tb_cmo_ccu__DOT__dut__DOT__w_bank_req_bank = VL_SCOPED_RAND_RESET_I(16, __VscopeHash, 6857302824073142050ull);
    vlSelf->tb_cmo_ccu__DOT__dut__DOT__w_dir_lookup_valid = VL_SCOPED_RAND_RESET_I(4, __VscopeHash, 13461298441269092741ull);
    vlSelf->tb_cmo_ccu__DOT__dut__DOT__w_dir_lookup_ready = VL_SCOPED_RAND_RESET_I(4, __VscopeHash, 17153663544493030349ull);
    vlSelf->tb_cmo_ccu__DOT__dut__DOT__w_dir_lookup_tag = VL_SCOPED_RAND_RESET_I(12, __VscopeHash, 9021197684474373617ull);
    vlSelf->tb_cmo_ccu__DOT__dut__DOT__w_dir_update_tag = VL_SCOPED_RAND_RESET_I(12, __VscopeHash, 14091111676117956516ull);
    VL_SCOPED_RAND_RESET_W(208, vlSelf->tb_cmo_ccu__DOT__dut__DOT__w_dir_update_line, __VscopeHash, 13505716476435566761ull);
    vlSelf->tb_cmo_ccu__DOT__dut__DOT__w_dir_update_way = VL_SCOPED_RAND_RESET_I(12, __VscopeHash, 6451723230357013453ull);
    vlSelf->tb_cmo_ccu__DOT__dut__DOT__w_dir_update_holders = VL_SCOPED_RAND_RESET_I(16, __VscopeHash, 2692126929761627104ull);
    vlSelf->tb_cmo_ccu__DOT__dut__DOT__w_dir_update_owner = VL_SCOPED_RAND_RESET_I(8, __VscopeHash, 1719887589238778022ull);
    vlSelf->tb_cmo_ccu__DOT__dut__DOT__w_dir_update_state = VL_SCOPED_RAND_RESET_I(8, __VscopeHash, 9841085374255477211ull);
    vlSelf->tb_cmo_ccu__DOT__dut__DOT__w_dir_cancel_tag = VL_SCOPED_RAND_RESET_I(12, __VscopeHash, 1988417944166980378ull);
    vlSelf->tb_cmo_ccu__DOT__dut__DOT__reg_gnt_valid = VL_SCOPED_RAND_RESET_I(4, __VscopeHash, 2131586460012925280ull);
    vlSelf->tb_cmo_ccu__DOT__dut__DOT__reg_gnt_tag = VL_SCOPED_RAND_RESET_I(12, __VscopeHash, 746529919076085940ull);
    vlSelf->tb_cmo_ccu__DOT__dut__DOT__w_gnt_load = VL_SCOPED_RAND_RESET_I(4, __VscopeHash, 6770264676305243887ull);
    vlSelf->tb_cmo_ccu__DOT__dut__DOT__w_gnt_load_tag = VL_SCOPED_RAND_RESET_I(12, __VscopeHash, 11340416483913160786ull);
    vlSelf->tb_cmo_ccu__DOT__dut__DOT__w_internal_pick_valid = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 10095391187764656518ull);
    vlSelf->tb_cmo_ccu__DOT__dut__DOT__w_internal_parent_tag = VL_SCOPED_RAND_RESET_I(3, __VscopeHash, 18338668418132912552ull);
    vlSelf->tb_cmo_ccu__DOT__dut__DOT__w_lookup_rsp_hs = VL_SCOPED_RAND_RESET_I(8, __VscopeHash, 8534928435555230457ull);
    vlSelf->tb_cmo_ccu__DOT__dut__DOT__w_lookup_rsp_accept = VL_SCOPED_RAND_RESET_I(4, __VscopeHash, 10846583645062858918ull);
    vlSelf->tb_cmo_ccu__DOT__dut__DOT__w_release_hs = VL_SCOPED_RAND_RESET_I(8, __VscopeHash, 7352816350004509356ull);
    vlSelf->tb_cmo_ccu__DOT__dut__DOT__w_phase_start_hs = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 10982473148384909680ull);
    vlSelf->tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_probe_scheduler__DOT__reg_req_valid = VL_SCOPED_RAND_RESET_I(4, __VscopeHash, 13604958584631121975ull);
    vlSelf->tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_probe_scheduler__DOT__reg_req_tag = VL_SCOPED_RAND_RESET_I(12, __VscopeHash, 17468202998675322543ull);
    VL_SCOPED_RAND_RESET_W(208, vlSelf->tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_probe_scheduler__DOT__reg_req_pa_line, __VscopeHash, 12287547382070483690ull);
    vlSelf->tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_probe_scheduler__DOT__reg_req_phase = VL_SCOPED_RAND_RESET_I(8, __VscopeHash, 15967944475727584150ull);
    vlSelf->tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_probe_scheduler__DOT__reg_rr_ptr = VL_SCOPED_RAND_RESET_I(12, __VscopeHash, 7216862542653482421ull);
    vlSelf->tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_probe_scheduler__DOT__reg_probe_active = VL_SCOPED_RAND_RESET_I(4, __VscopeHash, 17269548996772159627ull);
    vlSelf->tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_probe_scheduler__DOT__reg_ack_valid = VL_SCOPED_RAND_RESET_I(4, __VscopeHash, 9324731270085411540ull);
    vlSelf->tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_probe_scheduler__DOT__reg_ack_tag = VL_SCOPED_RAND_RESET_I(12, __VscopeHash, 12302881746223729567ull);
    vlSelf->tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_probe_scheduler__DOT__reg_ack_phase = VL_SCOPED_RAND_RESET_I(8, __VscopeHash, 1770526954492368574ull);
    vlSelf->tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_probe_scheduler__DOT__reg_ack_state = VL_SCOPED_RAND_RESET_I(8, __VscopeHash, 12428332162032276642ull);
    vlSelf->tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_probe_scheduler__DOT__reg_ack_err = VL_SCOPED_RAND_RESET_I(4, __VscopeHash, 17641304550867915647ull);
    vlSelf->tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_probe_scheduler__DOT__reg_ack_wback_done = VL_SCOPED_RAND_RESET_I(4, __VscopeHash, 2509898480410674982ull);
    vlSelf->tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_probe_scheduler__DOT__w_pick_found = VL_SCOPED_RAND_RESET_I(4, __VscopeHash, 9516544072026435299ull);
    vlSelf->tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_probe_scheduler__DOT__w_pick_tag = VL_SCOPED_RAND_RESET_I(12, __VscopeHash, 18285794705105127844ull);
    for (int __Vi0 = 0; __Vi0 < 4; ++__Vi0) {
        for (int __Vi1 = 0; __Vi1 < 256; ++__Vi1) {
            for (int __Vi2 = 0; __Vi2 < 8; ++__Vi2) {
                vlSelf->tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_sharer_directory__DOT__reg_dir_tag[__Vi0][__Vi1][__Vi2] = VL_SCOPED_RAND_RESET_Q(42, __VscopeHash, 14412750043744296070ull);
            }
        }
    }
    for (int __Vi0 = 0; __Vi0 < 4; ++__Vi0) {
        for (int __Vi1 = 0; __Vi1 < 256; ++__Vi1) {
            for (int __Vi2 = 0; __Vi2 < 8; ++__Vi2) {
                vlSelf->tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_sharer_directory__DOT__reg_dir_holders[__Vi0][__Vi1][__Vi2] = VL_SCOPED_RAND_RESET_I(4, __VscopeHash, 4243022874256498666ull);
            }
        }
    }
    for (int __Vi0 = 0; __Vi0 < 4; ++__Vi0) {
        for (int __Vi1 = 0; __Vi1 < 256; ++__Vi1) {
            for (int __Vi2 = 0; __Vi2 < 8; ++__Vi2) {
                vlSelf->tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_sharer_directory__DOT__reg_dir_owner[__Vi0][__Vi1][__Vi2] = VL_SCOPED_RAND_RESET_I(2, __VscopeHash, 17011162051993146309ull);
            }
        }
    }
    for (int __Vi0 = 0; __Vi0 < 4; ++__Vi0) {
        for (int __Vi1 = 0; __Vi1 < 256; ++__Vi1) {
            for (int __Vi2 = 0; __Vi2 < 8; ++__Vi2) {
                vlSelf->tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_sharer_directory__DOT__reg_dir_state[__Vi0][__Vi1][__Vi2] = VL_SCOPED_RAND_RESET_I(2, __VscopeHash, 12752643085173640792ull);
            }
        }
    }
    for (int __Vi0 = 0; __Vi0 < 4; ++__Vi0) {
        for (int __Vi1 = 0; __Vi1 < 256; ++__Vi1) {
            for (int __Vi2 = 0; __Vi2 < 8; ++__Vi2) {
                vlSelf->tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_sharer_directory__DOT__reg_dir_valid[__Vi0][__Vi1][__Vi2] = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 13014472734092568508ull);
            }
        }
    }
    for (int __Vi0 = 0; __Vi0 < 4; ++__Vi0) {
        for (int __Vi1 = 0; __Vi1 < 256; ++__Vi1) {
            vlSelf->tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_sharer_directory__DOT__reg_dir_plru[__Vi0][__Vi1] = VL_SCOPED_RAND_RESET_I(7, __VscopeHash, 12872518223789507448ull);
        }
    }
    for (int __Vi0 = 0; __Vi0 < 4; ++__Vi0) {
        for (int __Vi1 = 0; __Vi1 < 256; ++__Vi1) {
            vlSelf->tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_sharer_directory__DOT__reg_dir_resv_valid[__Vi0][__Vi1] = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 7746011252086361260ull);
        }
    }
    for (int __Vi0 = 0; __Vi0 < 4; ++__Vi0) {
        for (int __Vi1 = 0; __Vi1 < 256; ++__Vi1) {
            vlSelf->tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_sharer_directory__DOT__reg_dir_resv_tag[__Vi0][__Vi1] = VL_SCOPED_RAND_RESET_I(3, __VscopeHash, 7847436967340968540ull);
        }
    }
    vlSelf->tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_sharer_directory__DOT__reg_lookup_rsp_valid = VL_SCOPED_RAND_RESET_I(4, __VscopeHash, 15763258267733342258ull);
    vlSelf->tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_sharer_directory__DOT__reg_lookup_hit = VL_SCOPED_RAND_RESET_I(4, __VscopeHash, 8505399628808705872ull);
    vlSelf->tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_sharer_directory__DOT__reg_lookup_rsp_tag = VL_SCOPED_RAND_RESET_I(12, __VscopeHash, 13449507624382737441ull);
    vlSelf->tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_sharer_directory__DOT__reg_lookup_way = VL_SCOPED_RAND_RESET_I(12, __VscopeHash, 3150459883221090358ull);
    vlSelf->tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_sharer_directory__DOT__reg_lookup_victim_valid = VL_SCOPED_RAND_RESET_I(4, __VscopeHash, 10533588767367106597ull);
    VL_SCOPED_RAND_RESET_W(208, vlSelf->tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_sharer_directory__DOT__reg_lookup_victim_pa_line, __VscopeHash, 6266317704901056821ull);
    vlSelf->tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_sharer_directory__DOT__reg_lookup_holders = VL_SCOPED_RAND_RESET_I(16, __VscopeHash, 18103487258489777404ull);
    vlSelf->tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_sharer_directory__DOT__reg_lookup_owner = VL_SCOPED_RAND_RESET_I(8, __VscopeHash, 2280429959823611420ull);
    vlSelf->tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_sharer_directory__DOT__reg_lookup_state = VL_SCOPED_RAND_RESET_I(8, __VscopeHash, 11835340235371535056ull);
    vlSelf->tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_sharer_directory__DOT__w_lookup_hs = VL_SCOPED_RAND_RESET_I(4, __VscopeHash, 1846313331227321330ull);
    vlSelf->tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_sharer_directory__DOT__w_update_hs = VL_SCOPED_RAND_RESET_I(4, __VscopeHash, 1520886956412486098ull);
    vlSelf->tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_sharer_directory__DOT__w_cancel_hs = VL_SCOPED_RAND_RESET_I(4, __VscopeHash, 13267269319748940533ull);
    vlSelf->tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_sharer_directory__DOT__reg_dir_op_rr_ptr = VL_SCOPED_RAND_RESET_I(8, __VscopeHash, 11559405273717972258ull);
    vlSelf->tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_sharer_directory__DOT__w_dir_op_rr_ptr_nxt = VL_SCOPED_RAND_RESET_I(8, __VscopeHash, 5126116867526243245ull);
    vlSelf->tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_sharer_directory__DOT__w_lookup_set = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 5383105999801033900ull);
    vlSelf->tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_sharer_directory__DOT__w_update_set = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 11028175290596074167ull);
    vlSelf->tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_sharer_directory__DOT__w_cancel_set = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 16527586693354484442ull);
    vlSelf->tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_sharer_directory__DOT__w_lookup_hit = VL_SCOPED_RAND_RESET_I(4, __VscopeHash, 4073610133340754723ull);
    vlSelf->tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_sharer_directory__DOT__w_lookup_hit_way = VL_SCOPED_RAND_RESET_I(12, __VscopeHash, 17396458418372639821ull);
    vlSelf->tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_sharer_directory__DOT__w_lookup_victim_way = VL_SCOPED_RAND_RESET_I(12, __VscopeHash, 1308936174566059341ull);
    vlSelf->tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_sharer_directory__DOT__w_lookup_victim_valid = VL_SCOPED_RAND_RESET_I(4, __VscopeHash, 7853281689249207721ull);
    VL_SCOPED_RAND_RESET_W(208, vlSelf->tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_sharer_directory__DOT__w_lookup_victim_pa_line, __VscopeHash, 9905582373952897034ull);
    vlSelf->tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_sharer_directory__DOT__w_lookup_holders = VL_SCOPED_RAND_RESET_I(16, __VscopeHash, 3489235181118765431ull);
    vlSelf->tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_sharer_directory__DOT__w_lookup_owner = VL_SCOPED_RAND_RESET_I(8, __VscopeHash, 3385686881880447187ull);
    vlSelf->tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_sharer_directory__DOT__w_lookup_state = VL_SCOPED_RAND_RESET_I(8, __VscopeHash, 3383607627969766454ull);
    vlSelf->tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_sharer_directory__DOT__p_ff_dir_storage__DOT__unnamedblk5__DOT__unnamedblk6__DOT__set_idx = 0;
    vlSelf->tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_bank_arb__DOT__gen_bank__BRA__0__KET____DOT__reg_gnt_valid = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 12091015908213854911ull);
    vlSelf->tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_bank_arb__DOT__gen_bank__BRA__0__KET____DOT__reg_gnt_slot = VL_SCOPED_RAND_RESET_I(3, __VscopeHash, 10139443160788986122ull);
    vlSelf->tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_bank_arb__DOT__gen_bank__BRA__0__KET____DOT__reg_rr_slot = VL_SCOPED_RAND_RESET_I(3, __VscopeHash, 50903573699553245ull);
    vlSelf->tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_bank_arb__DOT__gen_bank__BRA__0__KET____DOT__w_start_slot = VL_SCOPED_RAND_RESET_I(3, __VscopeHash, 16781244474303489102ull);
    vlSelf->tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_bank_arb__DOT__gen_bank__BRA__0__KET____DOT__w_pick_valid = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 17156983031113312477ull);
    vlSelf->tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_bank_arb__DOT__gen_bank__BRA__0__KET____DOT__reg_req_armed = VL_SCOPED_RAND_RESET_I(8, __VscopeHash, 15681699588940412650ull);
    vlSelf->tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_bank_arb__DOT__gen_bank__BRA__0__KET____DOT__w_gnt_hs = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 1295691425887147552ull);
    vlSelf->tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_bank_arb__DOT__gen_bank__BRA__1__KET____DOT__reg_gnt_valid = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 2168230217767901440ull);
    vlSelf->tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_bank_arb__DOT__gen_bank__BRA__1__KET____DOT__reg_gnt_slot = VL_SCOPED_RAND_RESET_I(3, __VscopeHash, 17382801081693468365ull);
    vlSelf->tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_bank_arb__DOT__gen_bank__BRA__1__KET____DOT__reg_rr_slot = VL_SCOPED_RAND_RESET_I(3, __VscopeHash, 9984847717793693214ull);
    vlSelf->tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_bank_arb__DOT__gen_bank__BRA__1__KET____DOT__w_start_slot = VL_SCOPED_RAND_RESET_I(3, __VscopeHash, 12130391717715877163ull);
    vlSelf->tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_bank_arb__DOT__gen_bank__BRA__1__KET____DOT__w_pick_valid = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 7708176636020762121ull);
    vlSelf->tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_bank_arb__DOT__gen_bank__BRA__1__KET____DOT__reg_req_armed = VL_SCOPED_RAND_RESET_I(8, __VscopeHash, 16724169030846946698ull);
    vlSelf->tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_bank_arb__DOT__gen_bank__BRA__1__KET____DOT__w_gnt_hs = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 2883562689641716696ull);
    vlSelf->tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_bank_arb__DOT__gen_bank__BRA__2__KET____DOT__reg_gnt_valid = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 6120209103055954025ull);
    vlSelf->tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_bank_arb__DOT__gen_bank__BRA__2__KET____DOT__reg_gnt_slot = VL_SCOPED_RAND_RESET_I(3, __VscopeHash, 2624079317866433929ull);
    vlSelf->tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_bank_arb__DOT__gen_bank__BRA__2__KET____DOT__reg_rr_slot = VL_SCOPED_RAND_RESET_I(3, __VscopeHash, 3411803521508082813ull);
    vlSelf->tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_bank_arb__DOT__gen_bank__BRA__2__KET____DOT__w_start_slot = VL_SCOPED_RAND_RESET_I(3, __VscopeHash, 18091799958690933790ull);
    vlSelf->tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_bank_arb__DOT__gen_bank__BRA__2__KET____DOT__w_pick_valid = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 18069053716900862411ull);
    vlSelf->tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_bank_arb__DOT__gen_bank__BRA__2__KET____DOT__reg_req_armed = VL_SCOPED_RAND_RESET_I(8, __VscopeHash, 9118167856447058623ull);
    vlSelf->tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_bank_arb__DOT__gen_bank__BRA__2__KET____DOT__w_gnt_hs = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 14957456589811482691ull);
    vlSelf->tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_bank_arb__DOT__gen_bank__BRA__3__KET____DOT__reg_gnt_valid = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 3605966533505357248ull);
    vlSelf->tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_bank_arb__DOT__gen_bank__BRA__3__KET____DOT__reg_gnt_slot = VL_SCOPED_RAND_RESET_I(3, __VscopeHash, 5645966003963906499ull);
    vlSelf->tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_bank_arb__DOT__gen_bank__BRA__3__KET____DOT__reg_rr_slot = VL_SCOPED_RAND_RESET_I(3, __VscopeHash, 14455597641078268631ull);
    vlSelf->tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_bank_arb__DOT__gen_bank__BRA__3__KET____DOT__w_start_slot = VL_SCOPED_RAND_RESET_I(3, __VscopeHash, 17641727011253159438ull);
    vlSelf->tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_bank_arb__DOT__gen_bank__BRA__3__KET____DOT__w_pick_valid = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 12368276088621572257ull);
    vlSelf->tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_bank_arb__DOT__gen_bank__BRA__3__KET____DOT__reg_req_armed = VL_SCOPED_RAND_RESET_I(8, __VscopeHash, 17086349846908094875ull);
    vlSelf->tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_bank_arb__DOT__gen_bank__BRA__3__KET____DOT__w_gnt_hs = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 17845049963333204291ull);
    vlSelf->tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_txn_table__DOT__reg_ctx_valid = VL_SCOPED_RAND_RESET_I(8, __VscopeHash, 13593826803587550461ull);
    vlSelf->tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_txn_table__DOT__reg_ctx_src = VL_SCOPED_RAND_RESET_I(24, __VscopeHash, 7789511322396647416ull);
    VL_SCOPED_RAND_RESET_W(416, vlSelf->tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_txn_table__DOT__reg_ctx_pa_line, __VscopeHash, 16450776400074980859ull);
    vlSelf->tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_txn_table__DOT__reg_ctx_kind = VL_SCOPED_RAND_RESET_I(16, __VscopeHash, 31915406512853736ull);
    vlSelf->tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_txn_table__DOT__reg_ctx_target_state = VL_SCOPED_RAND_RESET_I(16, __VscopeHash, 3776484449699405920ull);
    vlSelf->tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_txn_table__DOT__reg_ctx_wback_en = VL_SCOPED_RAND_RESET_I(8, __VscopeHash, 18287663725174613340ull);
    vlSelf->tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_txn_table__DOT__reg_ctx_owner_known = VL_SCOPED_RAND_RESET_I(8, __VscopeHash, 8222100144171573353ull);
    vlSelf->tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_txn_table__DOT__reg_ctx_owner_present = VL_SCOPED_RAND_RESET_I(8, __VscopeHash, 1454424537533516798ull);
    vlSelf->tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_txn_table__DOT__reg_ctx_owner_hart = VL_SCOPED_RAND_RESET_I(16, __VscopeHash, 7175097650619041853ull);
    vlSelf->tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_txn_table__DOT__reg_ctx_phase = VL_SCOPED_RAND_RESET_I(16, __VscopeHash, 1711920348193201560ull);
    vlSelf->tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_txn_table__DOT__reg_ctx_ack_expected = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 710120837956969255ull);
    vlSelf->tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_txn_table__DOT__reg_ctx_ack_received = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 3160702780954592825ull);
    vlSelf->tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_txn_table__DOT__reg_ctx_phase_active = VL_SCOPED_RAND_RESET_I(8, __VscopeHash, 7411822289758793039ull);
    vlSelf->tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_txn_table__DOT__reg_ctx_phase_done = VL_SCOPED_RAND_RESET_I(8, __VscopeHash, 13540660576467304992ull);
    vlSelf->tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_txn_table__DOT__reg_ctx_phase_err = VL_SCOPED_RAND_RESET_I(8, __VscopeHash, 7540261257811515092ull);
    vlSelf->tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_txn_table__DOT__reg_ctx_owner_wback_done = VL_SCOPED_RAND_RESET_I(8, __VscopeHash, 13714637004372292137ull);
    vlSelf->tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_txn_table__DOT__reg_ctx_txn_err = VL_SCOPED_RAND_RESET_I(8, __VscopeHash, 2040593059759919417ull);
    vlSelf->tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_txn_table__DOT__reg_ctx_owner_wback_err = VL_SCOPED_RAND_RESET_I(8, __VscopeHash, 6768617514122579680ull);
    vlSelf->tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_txn_table__DOT__w_ack_take = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 16724361458253319704ull);
    vlSelf->tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_txn_table__DOT__w_ack_err = VL_SCOPED_RAND_RESET_I(8, __VscopeHash, 5457915488805257573ull);
    vlSelf->tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_txn_table__DOT__w_ack_wback_done = VL_SCOPED_RAND_RESET_I(8, __VscopeHash, 13022407164231162945ull);
    vlSelf->tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_txn_table__DOT__w_ack_owner_wback_err = VL_SCOPED_RAND_RESET_I(8, __VscopeHash, 18346626972714423529ull);
    vlSelf->tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_txn_table__DOT__w_owner_capture_take = VL_SCOPED_RAND_RESET_I(8, __VscopeHash, 15280048208884043349ull);
    vlSelf->tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_txn_table__DOT__w_alloc_found = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 17705030208521168680ull);
    vlSelf->tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_coh_txn_table__DOT__w_alloc_tag = VL_SCOPED_RAND_RESET_I(3, __VscopeHash, 4697566713165633641ull);
    vlSelf->__Vfunc_tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_sharer_directory__DOT__fun_plru_victim__4__i_plru = 0;
    vlSelf->__Vfunc_tb_cmo_ccu__DOT__dut__DOT__u_vlsit_riscv_sharer_directory__DOT__fun_plru_victim__4__w_way = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_1 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_2 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_3 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_4 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_14 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_16 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_18 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_23 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_93 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_94 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_95 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_96 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_97 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_98 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_99 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_100 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_144 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_156 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_157 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_158 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_159 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_160 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_161 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_162 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_164 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_165 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_166 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_167 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_168 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_169 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_170 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_171 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_173 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_174 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_175 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_176 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_177 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_178 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_179 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_183 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_184 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_185 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_186 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_187 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_188 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_189 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_191 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_252 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_260 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_268 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_276 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_278 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_279 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_280 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_281 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_282 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_283 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_284 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_285 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_286 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_287 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_288 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_289 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_314 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_315 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_316 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_317 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_318 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_319 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_320 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_321 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_322 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_323 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_324 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_325 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_326 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_327 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_328 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_329 = 0;
    VL_ZERO_RESET_W(208, vlSelf->__VdfgRegularize_h6e95ff9d_0_377);
    vlSelf->__VdfgRegularize_h6e95ff9d_0_408 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_409 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_410 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_411 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_412 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_413 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_414 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_416 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_417 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_418 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_419 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_420 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_421 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_422 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_424 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_425 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_426 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_427 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_428 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_429 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_430 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_432 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_433 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_434 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_435 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_436 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_437 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_438 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_476 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_478 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_481 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_484 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_486 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_488 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_491 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_492 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_494 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_496 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_498 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_501 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_504 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_506 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_508 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_511 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_514 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_595 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_598 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_599 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_600 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_601 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_663 = 0;
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
    vlSelf->__Vtrigprevexpr___TOP__tb_cmo_ccu__DOT__clk__0 = 0;
    vlSelf->__Vtrigprevexpr___TOP__tb_cmo_ccu__DOT__rst__0 = 0;
    vlSelf->__Vtrigprevexpr_hc129541c__1 = 0;
    vlSelf->__Vtrigprevexpr_h55d26132__1 = 0;
    for (int __Vi0 = 0; __Vi0 < 1; ++__Vi0) {
        vlSelf->__VnbaTriggered[__Vi0] = 0;
    }
    vlSelf->__Vi = 0;
}
