// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design internal header
// See Vtb_llc_flush_tag.h for the primary calling header

#ifndef VERILATED_VTB_LLC_FLUSH_TAG___024ROOT_H_
#define VERILATED_VTB_LLC_FLUSH_TAG___024ROOT_H_  // guard

#include "verilated.h"
#include "verilated_timing.h"


class Vtb_llc_flush_tag__Syms;

class alignas(VL_CACHE_LINE_BYTES) Vtb_llc_flush_tag___024root final {
  public:

    // DESIGN-SPECIFIC STATE
    // Anonymous structures to workaround compiler member-count bugs
    struct {
        CData/*0:0*/ tb_llc_flush_tag__DOT__clk;
        CData/*0:0*/ tb_llc_flush_tag__DOT__rst;
        CData/*0:0*/ tb_llc_flush_tag__DOT__iv;
        CData/*0:0*/ tb_llc_flush_tag__DOT__ir;
        CData/*0:0*/ tb_llc_flush_tag__DOT__orr;
        CData/*0:0*/ tb_llc_flush_tag__DOT__commit;
        CData/*1:0*/ tb_llc_flush_tag__DOT__b;
        CData/*0:0*/ tb_llc_flush_tag__DOT__flush_mode;
        CData/*0:0*/ tb_llc_flush_tag__DOT__bv;
        CData/*0:0*/ tb_llc_flush_tag__DOT__br;
        CData/*0:0*/ tb_llc_flush_tag__DOT__way_rsp_valid;
        CData/*0:0*/ tb_llc_flush_tag__DOT__wb_commit;
        CData/*0:0*/ tb_llc_flush_tag__DOT__wb_error;
        CData/*0:0*/ tb_llc_flush_tag__DOT__req_index;
        CData/*0:0*/ tb_llc_flush_tag__DOT____Vcellinp__writer__desc_valid_i;
        CData/*0:0*/ tb_llc_flush_tag__DOT__dut__DOT__busy_q;
        CData/*0:0*/ tb_llc_flush_tag__DOT__dut__DOT__busy_d;
        CData/*0:0*/ tb_llc_flush_tag__DOT__dut__DOT__switch_busy;
        CData/*0:0*/ tb_llc_flush_tag__DOT__dut__DOT__load_req;
        CData/*0:0*/ tb_llc_flush_tag__DOT__dut__DOT__ram_req;
        CData/*0:0*/ tb_llc_flush_tag__DOT__dut__DOT__ram_we;
        CData/*0:0*/ tb_llc_flush_tag__DOT__dut__DOT__ram_index;
        CData/*0:0*/ tb_llc_flush_tag__DOT__dut__DOT__ram_rvalid;
        CData/*0:0*/ tb_llc_flush_tag__DOT__dut__DOT__ram_rvalid_q;
        CData/*0:0*/ tb_llc_flush_tag__DOT__dut__DOT__hit;
        CData/*0:0*/ tb_llc_flush_tag__DOT__dut__DOT__gen_valid;
        CData/*0:0*/ tb_llc_flush_tag__DOT__dut__DOT__bist_valid;
        CData/*0:0*/ tb_llc_flush_tag__DOT__dut__DOT__res_valid;
        CData/*0:0*/ tb_llc_flush_tag__DOT__dut__DOT__res_ready;
        CData/*0:0*/ tb_llc_flush_tag__DOT__dut__DOT__flush_wait_q;
        CData/*3:0*/ tb_llc_flush_tag__DOT__dut__DOT__pending_valid_q;
        CData/*3:0*/ tb_llc_flush_tag__DOT__dut__DOT__pending_done_q;
        CData/*1:0*/ tb_llc_flush_tag__DOT__dut__DOT__pending_write_q;
        CData/*1:0*/ tb_llc_flush_tag__DOT__dut__DOT__pending_ack_q;
        CData/*1:0*/ tb_llc_flush_tag__DOT__dut__DOT__pending_read_q;
        CData/*0:0*/ tb_llc_flush_tag__DOT__dut__DOT__pending_full;
        CData/*0:0*/ tb_llc_flush_tag__DOT__dut__DOT__pending_push;
        CData/*0:0*/ tb_llc_flush_tag__DOT__dut__DOT__pending_pop;
        CData/*0:0*/ tb_llc_flush_tag__DOT__dut__DOT__maint_pending_q;
        CData/*0:0*/ tb_llc_flush_tag__DOT__dut__DOT__maint_result_q;
        CData/*0:0*/ tb_llc_flush_tag__DOT__dut__DOT__maint_error_q;
        CData/*0:0*/ tb_llc_flush_tag__DOT__dut__DOT__maint_index_q;
        CData/*0:0*/ tb_llc_flush_tag__DOT__dut__DOT__maint_way_q;
        CData/*1:0*/ tb_llc_flush_tag__DOT__dut__DOT__maint_op_q;
        CData/*0:0*/ tb_llc_flush_tag__DOT__dut__DOT__maint_finish;
        CData/*0:0*/ tb_llc_flush_tag__DOT__dut__DOT____Vcellinp__gen_tag_macros__BRA__0__KET____DOT__i_shift_reg_rvalid__d_i;
        CData/*0:0*/ tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__busy_q;
        CData/*0:0*/ tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__eoc_q;
        CData/*3:0*/ tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__bist_q;
        CData/*0:0*/ tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__en_cnt;
        CData/*0:0*/ tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__load_cnt;
        CData/*1:0*/ tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__i_index_cnt__DOT__i_counter__DOT__counter_q;
        CData/*0:0*/ tb_llc_flush_tag__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__a_full_q;
        CData/*0:0*/ tb_llc_flush_tag__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__a_fill;
        CData/*0:0*/ tb_llc_flush_tag__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__a_drain;
        CData/*0:0*/ tb_llc_flush_tag__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__b_full_q;
        CData/*0:0*/ tb_llc_flush_tag__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__b_fill;
        CData/*0:0*/ tb_llc_flush_tag__DOT__dut__DOT__gen_tag_macros__BRA__0__KET____DOT__i_tag_store__DOT__r_addr_q;
        CData/*0:0*/ tb_llc_flush_tag__DOT__writer__DOT__busy_q;
        CData/*0:0*/ tb_llc_flush_tag__DOT__writer__DOT__send_q;
        CData/*0:0*/ tb_llc_flush_tag__DOT__writer__DOT__load_desc;
        CData/*0:0*/ tb_llc_flush_tag__DOT__writer__DOT__fifo_push;
        CData/*0:0*/ tb_llc_flush_tag__DOT__writer__DOT__fifo_empty;
        CData/*0:0*/ tb_llc_flush_tag__DOT__writer__DOT__wb_fault_q;
    };
    struct {
        CData/*0:0*/ tb_llc_flush_tag__DOT__writer__DOT__wb_failed_q;
        CData/*1:0*/ tb_llc_flush_tag__DOT__writer__DOT__i_w_to_send_counter__DOT__i_counter__DOT__counter_q;
        CData/*1:0*/ tb_llc_flush_tag__DOT__writer__DOT__i_block_offset_counter__DOT__i_counter__DOT__counter_q;
        CData/*0:0*/ tb_llc_flush_tag__DOT__writer__DOT__i_r_data_fifo__DOT__read_pointer_q;
        CData/*0:0*/ tb_llc_flush_tag__DOT__writer__DOT__i_r_data_fifo__DOT__write_pointer_q;
        CData/*1:0*/ tb_llc_flush_tag__DOT__writer__DOT__i_r_data_fifo__DOT__status_cnt_q;
        CData/*0:0*/ __VdfgRegularize_h6e95ff9d_0_0;
        CData/*0:0*/ __VdfgRegularize_h6e95ff9d_0_1;
        CData/*0:0*/ __VdfgRegularize_h6e95ff9d_0_3;
        CData/*0:0*/ __VdfgRegularize_h6e95ff9d_0_4;
        CData/*0:0*/ __VdfgRegularize_h6e95ff9d_0_5;
        CData/*0:0*/ __VdfgRegularize_h6e95ff9d_0_6;
        CData/*0:0*/ __VdfgRegularize_h6e95ff9d_0_11;
        CData/*0:0*/ __VdfgRegularize_h6e95ff9d_0_13;
        CData/*0:0*/ __VdfgRegularize_h6e95ff9d_0_14;
        CData/*2:0*/ __VdfgRegularize_h6e95ff9d_0_21;
        CData/*0:0*/ __VdfgRegularize_h6e95ff9d_0_24;
        CData/*1:0*/ __VdfgRegularize_h6e95ff9d_0_25;
        CData/*0:0*/ __VdfgRegularize_h6e95ff9d_0_27;
        CData/*0:0*/ __VdfgRegularize_h6e95ff9d_0_28;
        CData/*0:0*/ __VdfgRegularize_h6e95ff9d_0_29;
        CData/*0:0*/ __VdfgRegularize_h6e95ff9d_0_32;
        CData/*0:0*/ __VdfgRegularize_h6e95ff9d_0_33;
        CData/*0:0*/ __VdfgRegularize_h6e95ff9d_0_34;
        CData/*0:0*/ __VdfgRegularize_h6e95ff9d_0_35;
        CData/*1:0*/ __Vsampled_TOP__tb_llc_flush_tag__DOT__writer__DOT__i_r_data_fifo__DOT__status_cnt_q;
        CData/*0:0*/ __Vsampled_TOP__tb_llc_flush_tag__DOT__writer__DOT__fifo_push;
        CData/*0:0*/ __Vsampled_TOP__tb_llc_flush_tag__DOT__writer__DOT__fifo_empty;
        CData/*0:0*/ __Vtrigprevexpr___TOP__tb_llc_flush_tag__DOT__clk__0;
        CData/*0:0*/ __Vtrigprevexpr___TOP__tb_llc_flush_tag__DOT__rst__0;
        CData/*0:0*/ __Vtrigprevexpr___TOP__tb_llc_flush_tag__DOT__dut__DOT__i_tag_pattern_gen__DOT__eoc_q__0;
        CData/*0:0*/ __Vtrigprevexpr_h4d792359__1;
        CData/*0:0*/ __Vtrigprevexpr_h4d7acfdc__1;
        IData/*31:0*/ tb_llc_flush_tag__DOT__beats;
        IData/*31:0*/ __Vi;
        VlWide<3>/*65:0*/ tb_llc_flush_tag__DOT__req;
        QData/*61:0*/ tb_llc_flush_tag__DOT__rsp;
        VlWide<3>/*72:0*/ tb_llc_flush_tag__DOT__w;
        QData/*58:0*/ tb_llc_flush_tag__DOT__req_tag;
        VlWide<3>/*65:0*/ tb_llc_flush_tag__DOT__dut__DOT__req_q;
        QData/*60:0*/ tb_llc_flush_tag__DOT__dut__DOT__ram_wdata;
        QData/*60:0*/ tb_llc_flush_tag__DOT__dut__DOT__gen_pattern;
        QData/*60:0*/ tb_llc_flush_tag__DOT__dut__DOT__bist_pattern;
        QData/*61:0*/ tb_llc_flush_tag__DOT__dut__DOT__res;
        QData/*60:0*/ tb_llc_flush_tag__DOT__dut__DOT__maint_tag_q;
        QData/*61:0*/ tb_llc_flush_tag__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__a_data_q;
        QData/*61:0*/ tb_llc_flush_tag__DOT__dut__DOT__i_spill_register__DOT__spill_register_flushable_i__DOT__gen_spill_reg__DOT__b_data_q;
        QData/*60:0*/ tb_llc_flush_tag__DOT__dut__DOT__gen_tag_macros__BRA__0__KET____DOT__i_tag_store__DOT__rdata_q;
        VlWide<3>/*69:0*/ tb_llc_flush_tag__DOT__writer__DOT__desc_q;
        VlWide<4>/*127:0*/ tb_llc_flush_tag__DOT__writer__DOT__i_r_data_fifo__DOT__mem_n;
        VlWide<4>/*127:0*/ tb_llc_flush_tag__DOT__writer__DOT__i_r_data_fifo__DOT__mem_q;
        VlUnpacked<CData/*0:0*/, 4> tb_llc_flush_tag__DOT__dut__DOT__pending_index_q;
        VlUnpacked<CData/*0:0*/, 4> tb_llc_flush_tag__DOT__dut__DOT__pending_way_q;
        VlUnpacked<QData/*60:0*/, 4> tb_llc_flush_tag__DOT__dut__DOT__pending_tag_q;
        VlUnpacked<QData/*60:0*/, 2> tb_llc_flush_tag__DOT__dut__DOT__gen_tag_macros__BRA__0__KET____DOT__i_tag_store__DOT__sram;
        VlUnpacked<QData/*63:0*/, 1> __VstlTriggered;
        VlUnpacked<QData/*63:0*/, 1> __VicoTriggered;
        VlUnpacked<QData/*63:0*/, 1> __VactTriggered;
        VlUnpacked<QData/*63:0*/, 1> __VactTriggeredAcc;
        VlUnpacked<QData/*63:0*/, 1> __VnbaTriggered;
    };
    VlDelayScheduler __VdlySched;
    VlTriggerScheduler __VtrigSched_hb04eaffa__0;
    VlTriggerScheduler __VtrigSched_hb04eaf3d__0;
    VlTriggerScheduler __VtrigSched_ha4acadb1__0;
    VlTriggerScheduler __VtrigSched_hd94d9ee0__0;
    VlTriggerScheduler __VtrigSched_hd94c4b5f__0;

    // INTERNAL VARIABLES
    Vtb_llc_flush_tag__Syms* vlSymsp;
    const char* vlNamep;

    // CONSTRUCTORS
    Vtb_llc_flush_tag___024root(Vtb_llc_flush_tag__Syms* symsp, const char* namep);
    ~Vtb_llc_flush_tag___024root();
    VL_UNCOPYABLE(Vtb_llc_flush_tag___024root);

    // INTERNAL METHODS
};


#endif  // guard
