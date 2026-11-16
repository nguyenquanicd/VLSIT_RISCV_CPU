// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Symbol table implementation internals

#include "Vtb_llc_flush_tag__pch.h"

extern const VlScopeTableEntry Vtb_llc_flush_tag__Syms__VpiScopeTable[];


// VPI VARIABLE/SCOPE TABLES
#if defined(__GNUC__)
# pragma GCC diagnostic push
# pragma GCC diagnostic ignored "-Winvalid-offsetof"
#endif
extern const VlScopeTableEntry Vtb_llc_flush_tag__Syms__VpiScopeTable[] = {
    {offsetof(Vtb_llc_flush_tag__Syms, __Vscopep_tb_llc_flush_tag), "tb_llc_flush_tag", "tb_llc_flush_tag", "<null>", -9, VerilatedScope::SCOPE_OTHER},
    {offsetof(Vtb_llc_flush_tag__Syms, __Vscopep_tb_llc_flush_tag__receive), "tb_llc_flush_tag.receive", "receive", "<null>", -9, VerilatedScope::SCOPE_OTHER},
    {offsetof(Vtb_llc_flush_tag__Syms, __Vscopep_tb_llc_flush_tag__unnamedblk1_2), "tb_llc_flush_tag.unnamedblk1_2", "unnamedblk1_2", "<null>", -9, VerilatedScope::SCOPE_OTHER},
    {offsetof(Vtb_llc_flush_tag__Syms, __Vscopep_tb_llc_flush_tag__unnamedblk1_3), "tb_llc_flush_tag.unnamedblk1_3", "unnamedblk1_3", "<null>", -9, VerilatedScope::SCOPE_OTHER},
    {offsetof(Vtb_llc_flush_tag__Syms, __Vscopep_tb_llc_flush_tag__unnamedblk1_4), "tb_llc_flush_tag.unnamedblk1_4", "unnamedblk1_4", "<null>", -9, VerilatedScope::SCOPE_OTHER},
    {offsetof(Vtb_llc_flush_tag__Syms, __Vscopep_tb_llc_flush_tag__unnamedblk1_5), "tb_llc_flush_tag.unnamedblk1_5", "unnamedblk1_5", "<null>", -9, VerilatedScope::SCOPE_OTHER},
    {offsetof(Vtb_llc_flush_tag__Syms, __Vscopep_tb_llc_flush_tag__writer__i_r_data_fifo), "tb_llc_flush_tag.writer.i_r_data_fifo", "i_r_data_fifo", "<null>", -9, VerilatedScope::SCOPE_OTHER},
    {offsetof(Vtb_llc_flush_tag__Syms, __Vscopep_tb_llc_flush_tag__writer__i_r_data_fifo__full_write), "tb_llc_flush_tag.writer.i_r_data_fifo.full_write", "full_write", "<null>", -9, VerilatedScope::SCOPE_OTHER},
};
#if defined(__GNUC__)
# pragma GCC diagnostic pop
#endif
Vtb_llc_flush_tag__Syms::Vtb_llc_flush_tag__Syms(VerilatedContext* contextp, const char* namep, Vtb_llc_flush_tag* modelp)
    : VerilatedSyms{contextp}
    // Setup internal state of the Syms class
    , __Vm_modelp{modelp}
    , __Vm_didInit{modelp->m_didInit}
    // Setup top module instance
    , TOP{this, namep}
{
    // Check resources
    Verilated::stackCheck(888);
    // Setup sub module instances
    // Configure time unit / time precision
    _vm_contextp__->timeunit(-9);
    _vm_contextp__->timeprecision(-12);
    // Setup each module's pointers to their submodules
    // Setup scopes
    VerilatedScope::scopesConstructFromTable(Vtb_llc_flush_tag__Syms__VpiScopeTable, 8, this);
    // Setup export functions - final: 0
    // Setup export functions - final: 1
}

Vtb_llc_flush_tag__Syms::~Vtb_llc_flush_tag__Syms() {
    // Tear down scopes
    VL_DO_CLEAR(delete __Vscopep_tb_llc_flush_tag, __Vscopep_tb_llc_flush_tag = nullptr);
    VL_DO_CLEAR(delete __Vscopep_tb_llc_flush_tag__receive, __Vscopep_tb_llc_flush_tag__receive = nullptr);
    VL_DO_CLEAR(delete __Vscopep_tb_llc_flush_tag__unnamedblk1_2, __Vscopep_tb_llc_flush_tag__unnamedblk1_2 = nullptr);
    VL_DO_CLEAR(delete __Vscopep_tb_llc_flush_tag__unnamedblk1_3, __Vscopep_tb_llc_flush_tag__unnamedblk1_3 = nullptr);
    VL_DO_CLEAR(delete __Vscopep_tb_llc_flush_tag__unnamedblk1_4, __Vscopep_tb_llc_flush_tag__unnamedblk1_4 = nullptr);
    VL_DO_CLEAR(delete __Vscopep_tb_llc_flush_tag__unnamedblk1_5, __Vscopep_tb_llc_flush_tag__unnamedblk1_5 = nullptr);
    VL_DO_CLEAR(delete __Vscopep_tb_llc_flush_tag__writer__i_r_data_fifo, __Vscopep_tb_llc_flush_tag__writer__i_r_data_fifo = nullptr);
    VL_DO_CLEAR(delete __Vscopep_tb_llc_flush_tag__writer__i_r_data_fifo__full_write, __Vscopep_tb_llc_flush_tag__writer__i_r_data_fifo__full_write = nullptr);
    // Tear down sub module instances
}
